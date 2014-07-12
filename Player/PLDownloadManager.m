#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLDownloadManager.h"
#import "PLErrorManager.h"
#import "PLDataAccess.h"
#import "PLUtils.h"
#import "PLFileImport.h"
#import "PLDropboxManager.h"
#import "PLServiceContainer.h"

@interface PLTaskInfo : NSObject 

@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) RACSubject *progressSubject;

+ (PLTaskInfo *)infoForTask:(NSURLSessionDownloadTask *)task;

@end

@implementation PLTaskInfo

+ (PLTaskInfo *)infoForTask:(NSURLSessionDownloadTask *)task
{
    PLTaskInfo *taskInfo = [PLTaskInfo new];
    taskInfo.task = task;
    taskInfo.progressSubject = [RACSubject subject];
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
            NSString *trackId = downloadTask.description;
            
            tasks[trackId] = [PLTaskInfo infoForTask:downloadTask];
        }
        
        self.tasks = tasks;
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

    RACSignal *workSignal = [[self tasksSignal] flattenMap:^RACStream *(NSMutableDictionary *tasks) {
        
        PLTaskInfo *taskInfo = tasks[trackId];
        [tasks removeObjectForKey:trackId];
        
        PLTrack *track = [[PLDataAccess sharedDataAccess] trackWithObjectID:trackId];
        if (track == nil)
            return nil;
        
        NSString *targetFileName = [PLUtils fileNameFromURL:[NSURL URLWithString:track.downloadURL]];
                
        return [[PLFileImport moveToDocumentsFolder:location underFileName:targetFileName]
        flattenMap:^RACStream *(NSURL *fileURL) {
            PLTrack *track = [[PLDataAccess sharedDataAccess] trackWithObjectID:trackId];
            track.fileURL = [fileURL absoluteString];
            [track loadMetadataFromAsset];
            track.downloadStatus = PLTrackDownloadStatusDone;

            return [[[PLDataAccess sharedDataAccess] saveChangesSignal] doCompleted:^{
                DDLogVerbose(@"Finished downloading track %@", track.title);
                [taskInfo.progressSubject sendCompleted];
            }];
        }];
    }];

    [workSignal subscribeError:[PLErrorManager logErrorVoidBlock]];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (totalBytesExpectedToWrite == 0)
        return;

    NSNumber *progress = @( (double)totalBytesWritten / (double)totalBytesExpectedToWrite );
    NSString *trackId = downloadTask.taskDescription;

    [[self taskInfoWithId:trackId] subscribeNext:^(PLTaskInfo *taskInfo) {
        [taskInfo.progressSubject sendNext:progress];
    }];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error == nil)
        return;
    
    [PLErrorManager logError:error];

    NSString *trackId = task.taskDescription;

    RACSignal *workSignal = [[self tasksSignal] flattenMap:^RACStream *(NSMutableDictionary *tasks) {
        [tasks removeObjectForKey:trackId];

        PLTrack *track = [[PLDataAccess sharedDataAccess] trackWithObjectID:trackId];

        BOOL wasCancelled = [error.domain isEqualToString:NSURLErrorDomain] && error.code == -999;
        track.downloadStatus = wasCancelled ? PLTrackDownloadStatusIdle : PLTrackDownloadStatusError;

        return [[PLDataAccess sharedDataAccess] saveChangesSignal];
    }];

    [workSignal subscribeError:[PLErrorManager logErrorVoidBlock]];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // nothing at the moment
}


#pragma mark -- custom methods

- (RACSignal *)tasksSignal
{
    return [[RACObserve(self, tasks) filter:[PLUtils isNotNilPredicate]] take:1];
}

- (RACSignal *)taskInfoWithId:(NSString *)trackId
{
    return [[self tasksSignal] flattenMap:^id(NSMutableDictionary *tasks) {
        PLTaskInfo *taskInfo = tasks[trackId];
        return taskInfo ? [RACSignal return:taskInfo] : nil;
    }];
}


- (RACSignal *)enqueueDownloadOfTrack:(PLTrack *)track
{
    NSURLRequest *request = [self requestForDownloadURL:[NSURL URLWithString:track.downloadURL]];
    if (request == nil)
        return [RACSignal empty];
    
    NSString *trackId = [[track.objectID URIRepresentation] absoluteString];

    return [[self tasksSignal] flattenMap:^RACStream *(NSMutableDictionary *tasks) {

        NSURLSessionDownloadTask *downloadTask = [_session downloadTaskWithRequest:request];
        downloadTask.taskDescription = trackId;
        [downloadTask resume];

        tasks[trackId] = [PLTaskInfo infoForTask:downloadTask];

        PLTrack *track = [[PLDataAccess sharedDataAccess] trackWithObjectID:trackId];
        track.downloadStatus = PLTrackDownloadStatusDownloading;

        return [[PLDataAccess sharedDataAccess] saveChangesSignal];
    }];
}

- (RACSignal *)cancelDownloadOfTrack:(PLTrack *)track
{
    NSString *trackId = [[track.objectID URIRepresentation] absoluteString];

    return [[self taskInfoWithId:trackId] flattenMap:^RACStream *(PLTaskInfo *taskInfo) {
        if (taskInfo.task.state == NSURLSessionTaskStateRunning)
            [taskInfo.task cancel];
        return nil;
    }];
}

- (RACSignal *)progressSignalForTrack:(PLTrack *)track
{
    NSString *trackId = [[track.objectID URIRepresentation] absoluteString];
    return [[self taskInfoWithId:trackId] flattenMap:^RACStream *(PLTaskInfo *taskInfo) {
        return taskInfo.progressSubject;
    }];
}


- (NSURLRequest *)requestForDownloadURL:(NSURL *)downloadURL
{
    if (downloadURL == nil)
        return nil;
    
    for (id<PLDownloadProvider> downloadProvider in PLResolveMany(PLDownloadProvider)) {
        NSURLRequest *request = [downloadProvider requestForDownloadURL:downloadURL];
        if (request != nil)
            return request;
    }

    return [NSURLRequest requestWithURL:downloadURL];
}

@end
