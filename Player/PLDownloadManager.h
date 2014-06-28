#import <Foundation/Foundation.h>

// Identifier of the background NSURLSession used by the app (managed by the PLDownloadManager)
extern NSString * const PLBackgroundSessionIdentifier;

@class PLTrack, RACSignal;

@interface PLDownloadManager : NSObject

+ (PLDownloadManager *)sharedManager;

/**
 The handler to be called in the URLSessionDidFinishEventsForBackgroundURLSession delegate method. Typically
 set by the application delegate when the app was started to handle session events.
 */
@property (nonatomic, copy) dispatch_block_t sessionCompletionHandler;

/**
 Creates and starts a download task for the given track. 
 Returns a signal that delivers no values but completes when the task has been started.
 */
- (RACSignal *)enqueueDownloadOfTrack:(PLTrack *)track;

/**
 Cancels the task that is currently downloading the given track, if any.
 Returns a signal that delivers no values but completes when the task has been started.
 */
- (RACSignal *)cancelDownloadOfTrack:(PLTrack *)track;

/**
 Returns a signal that delivers the progress values (float between 0. and 1.) of the task that is downloading
 the given track and completes when the track has been downloaded.
 If no tasks exists that is currently downloading the given track, completes immediately.
 */
- (RACSignal *)progressSignalForTrack:(PLTrack *)track;

@end
