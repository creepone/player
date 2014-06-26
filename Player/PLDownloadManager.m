#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLDownloadManager.h"
#import "PLErrorManager.h"
#import "PLDataAccess.h"
#import "PLUtils.h"
#import "PLFileImport.h"

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
        
        return [[PLFileImport moveToDocumentsFolder:location underFileName:[track.downloadURL lastPathComponent]]
        flattenMap:^RACStream *(NSURL *fileURL) {
            PLTrack *track = [[PLDataAccess sharedDataAccess] trackWithObjectID:trackId];
            track.downloadStatus = PLTrackDownloadStatusDone;
            track.fileURL = [fileURL absoluteString];
            [track loadMetadataFromAsset];
            
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
    NSString *trackId = downloadTask.description;

    [[self taskInfoWithId:trackId] subscribeNext:^(PLTaskInfo *taskInfo) {
        [taskInfo.progressSubject sendNext:progress];
    }];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error == nil)
        return;

    NSString *trackId = task.taskDescription;

    RACSignal *workSignal = [[self tasksSignal] flattenMap:^RACStream *(NSMutableDictionary *tasks) {
        [tasks removeObjectForKey:trackId];

        PLTrack *track = [[PLDataAccess sharedDataAccess] trackWithObjectID:trackId];
        track.downloadStatus = PLTrackDownloadStatusError;
        return [[PLDataAccess sharedDataAccess] saveChangesSignal];
    }];

    [workSignal subscribeError:[PLErrorManager logErrorVoidBlock]];
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
    NSURL *downloadURL = [NSURL URLWithString:track.downloadURL];
    NSString *trackId = [[track.objectID URIRepresentation] absoluteString];

    return [[self tasksSignal] flattenMap:^RACStream *(NSMutableDictionary *tasks) {

        PLTrack *track = [[PLDataAccess sharedDataAccess] trackWithObjectID:trackId];
        track.downloadStatus = PLTrackDownloadStatusDownloading;

        return [[[PLDataAccess sharedDataAccess] saveChangesSignal] doCompleted:^{
            NSURLSessionDownloadTask *downloadTask = [_session downloadTaskWithURL:downloadURL];
            downloadTask.taskDescription = trackId;
            [downloadTask resume];

            tasks[trackId] = [PLTaskInfo infoForTask:downloadTask];
        }];
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

@end
