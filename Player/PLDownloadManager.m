#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLDownloadManager.h"
#import "PLErrorManager.h"
#import "PLDataAccess.h"
#import "PLUtils.h"
#import "PLFileImport.h"
#import "PLDropboxManager.h"
#import "PLServiceContainer.h"

@interface PLTaskInfo : NSObject <PLProgress>

@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, assign) double progress;

+ (PLTaskInfo *)infoForTask:(NSURLSessionDownloadTask *)task;

@end

@implementation PLTaskInfo

+ (PLTaskInfo *)infoForTask:(NSURLSessionDownloadTask *)task
{
    PLTaskInfo *taskInfo = [PLTaskInfo new];
    taskInfo.task = task;
    taskInfo.progress = 0.;
    return taskInfo;
}

@end


@interface PLDownloadManager() <NSURLSessionDelegate, NSURLSessionDownloadDelegate> {
    NSURLSession *_session;
}

/**
 A dictionary of task infos where the key is the string representation of the track objectID.
 Stores all the tasks currently in progress (completed tasks are removed).
 */
@property (nonatomic, strong) NSMutableDictionary *tasks;

@property (nonatomic, assign) BOOL isReady;

@end

NSString * const PLBackgroundSessionIdentifier = @"at.iosapps.Player.BackgroundSession";

@implementation PLDownloadManager

+ (PLDownloadManager *)sharedManager
{
    static dispatch_once_t once;
    static PLDownloadManager *sharedManager;
    dispatch_once(&once, ^ { sharedManager = [[self alloc] init]; });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:PLBackgroundSessionIdentifier];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        // if we're reconnecting to an existing session here, there might already be tasks running
        [self loadExistingTasks];
    }
    return self;
}

- (void)loadExistingTasks
{
    @weakify(self);
    [_session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        @strongify(self);
        if (!self) return;
        
        NSMutableDictionary *tasks = [NSMutableDictionary dictionary];
        
        for (NSURLSessionDownloadTask *downloadTask in downloadTasks) {
            NSString *trackId = downloadTask.taskDescription;
            tasks[trackId] = [PLTaskInfo infoForTask:downloadTask];
        }
        
        self.tasks = tasks;
        self.isReady = YES;
    }];
}

#pragma mark -- NSURLSessionDelegate methods

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    [PLErrorManager logError:error];
    self.tasks = nil;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    if (self.sessionCompletionHandler) {
        dispatch_block_t handler = self.sessionCompletionHandler;
        self.sessionCompletionHandler = nil;
        handler();
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSString *trackId = downloadTask.taskDescription;
    [self.tasks removeObjectForKey:trackId];
    
    PLTrack *track = [[PLDataAccess sharedDataAccess] trackWithObjectID:trackId];
    if (track == nil)
        return;
    
    // todo: maybe we should store the targetFileName separately, in case we ever want to use a different title
    NSString *targetFileName = track.title;
    
    RACSignal *workSignal = [[PLFileImport moveToDocumentsFolder:location underFileName:targetFileName]
        flattenMap:^RACStream *(NSURL *fileURL) {
            PLTrack *track = [[PLDataAccess sharedDataAccess] trackWithObjectID:trackId];
            track.fileURL = [PLUtils pathFromDocuments:fileURL];
            [track loadMetadataFromAsset];
            track.downloadStatus = PLTrackDownloadStatusDone;
            
            return [[[PLDataAccess sharedDataAccess] saveChangesSignal] doCompleted:^{
                DDLogVerbose(@"Finished downloading track %@", track.title);
            }];
        }];

    [[workSignal subscribeOn:[RACScheduler immediateScheduler]]
        subscribeError:[PLErrorManager logErrorVoidBlock]];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (totalBytesExpectedToWrite == 0)
        return;

    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    NSString *trackId = downloadTask.taskDescription;
    
    PLTaskInfo *taskInfo = self.tasks[trackId];
    taskInfo.progress = progress;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error == nil)
        return;
    
    [PLErrorManager logError:error];

    NSString *trackId = task.taskDescription;
    
    [self.tasks removeObjectForKey:trackId];
    
    PLTrack *track = [[PLDataAccess sharedDataAccess] trackWithObjectID:trackId];
    
    BOOL wasCancelled = [error.domain isEqualToString:NSURLErrorDomain] && error.code == -999;
    track.downloadStatus = wasCancelled ? PLTrackDownloadStatusIdle : PLTrackDownloadStatusError;

    [[[PLDataAccess sharedDataAccess] saveChangesSignal] subscribeError:[PLErrorManager logErrorVoidBlock]];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // nothing at the moment
}


#pragma mark -- custom methods

- (RACSignal *)addTrackToDownload:(NSURL *)downloadURL withTitle:(NSString *)title
{
    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
    PLPlaylist *playlist = [dataAccess selectedPlaylist];
    
    PLTrack *track = [dataAccess trackWithDownloadURL:[downloadURL absoluteString]];
    PLPlaylistSong *playlistSong = [dataAccess songWithTrack:track onPlaylist:playlist];
    if (!playlistSong)
        [playlist addTrack:track];
    
    // do not enqueue the download if the track already existed
    if (!track.isInserted)
        return [dataAccess saveChangesSignal] ;
    
    if (title)
        track.title = title;
    
    return [[dataAccess saveChangesSignal] then:^RACSignal *{
        return [self enqueueDownloadOfTrack:track];
    }];
}

- (RACSignal *)enqueueDownloadOfTrack:(PLTrack *)track
{
    RACSignal *requestSignal = [self requestForDownloadURL:[NSURL URLWithString:track.downloadURL]];
    if (requestSignal == nil)
        return [RACSignal empty];
    
    NSString *trackId = [[track.objectID URIRepresentation] absoluteString];
    
    return [requestSignal flattenMap:^RACStream *(NSURLRequest *request) {
        NSURLSessionDownloadTask *downloadTask = [_session downloadTaskWithRequest:request];
        downloadTask.taskDescription = trackId;
        [downloadTask resume];
        
        self.tasks[trackId] = [PLTaskInfo infoForTask:downloadTask];
        
        PLTrack *track = [[PLDataAccess sharedDataAccess] trackWithObjectID:trackId];
        track.downloadStatus = PLTrackDownloadStatusDownloading;
        
        return [[PLDataAccess sharedDataAccess] saveChangesSignal];
    }];
}

- (void)cancelDownloadOfTrack:(PLTrack *)track
{
    NSString *trackId = [[track.objectID URIRepresentation] absoluteString];
    PLTaskInfo *taskInfo = self.tasks[trackId];

    if (taskInfo && taskInfo.task.state == NSURLSessionTaskStateRunning)
        [taskInfo.task cancel];
}

- (id<PLProgress>)progressForTrack:(PLTrack *)track
{
    NSString *trackId = [[track.objectID URIRepresentation] absoluteString];
    return self.tasks[trackId];
}


- (RACSignal *)requestForDownloadURL:(NSURL *)downloadURL
{
    if (downloadURL == nil)
        return nil;
    
    for (id<PLDownloadProvider> downloadProvider in PLResolveMany(PLDownloadProvider)) {
        RACSignal *requestSignal = [downloadProvider requestForDownloadURL:downloadURL];
        if (requestSignal != nil)
            return requestSignal;
    }

    return [RACSignal return:[NSURLRequest requestWithURL:downloadURL]];
}

@end
