#import <Foundation/Foundation.h>

// Identifier of the background NSURLSession used by the app (managed by the PLDownloadManager)
extern NSString * const PLBackgroundSessionIdentifier;

@class PLTrack, RACSignal;

@protocol PLProgress <NSObject>

@property (nonatomic, readonly) double progress;

@end

@interface PLDownloadManager : NSObject

+ (PLDownloadManager *)sharedManager;

/**
 Delivers YES as soon as all the data from the session has been loaded and this instance is ready to use.
 It is not safe to call any of the methods before this happens.
 */
@property (nonatomic, readonly) BOOL isReady;

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
 */
- (void)cancelDownloadOfTrack:(PLTrack *)track;

/**
 Delivers a progress object that can be observed with KVO to track the progress of the download task for the given track.
 */
- (id<PLProgress>)progressForTrack:(PLTrack *)track;

@end
