#import <RXPromise/RXPromise.h>

@class PLPromise;

typedef void (^PLPromiseProgressHandlerBlock)(float);
typedef PLPromise* (^PLPromiseProgressOnBlock)(dispatch_queue_t, PLPromiseProgressHandlerBlock);
typedef PLPromise* (^PLPromiseProgressOnMainBlock)(PLPromiseProgressHandlerBlock);

@interface PLPromise : RXPromise

/**
 Returns a registration block for a queue and a block that will be called each time a progress has been made towards
 resolving the promise.
 It is preferable to observe the progress changes this way to observing the progress's properties directly, because the progress
 object might be reset to a different one later if the underlying operation is restarted.
 */
@property (readonly, nonatomic) PLPromiseProgressOnBlock progressOn;

/**
 Returns a registration block for a block that will be called on the main queue each time a progress has been made towards
 resolving the promise.
 It is preferable to observe the progress changes this way to observing the progress's properties directly, because the progress
 object might be reset to a different one later if the underlying operation is restarted.
 */
@property (readonly, nonatomic) PLPromiseProgressOnMainBlock progressOnMain;

/**
 Attaches the given NSProgress instance. A different progress can be attached multiple times before a promise is resolved,
 e.g. when the underlying operation was restarted.
 */
@property (strong, nonatomic) NSProgress *progress;

/**
 Binds the given promise to this one (so that it shares its progress and state).
 */
- (void)bind:(PLPromise *)other;

@end