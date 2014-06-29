#import <Foundation/Foundation.h>

@class RACSignal;

@interface PLBackgroundProcess : NSObject

/**
* Signal that sends a PLBackgroundProcessProgress object for each processed item when it starts processing it.
* Completes when there's no more work to be done or has been suspended. Replayed so that the last item
* (the one currently being processed), if any, is always sent.
*/
@property (nonatomic, retain, readonly) RACSignal *progressSignal;

/**
* Starts the process, if not already running. Afterwards the progressSignal will be available
* sending the progress objects for each individual processed item.
*/
- (void)ensureRunning;

/**
* Sends a suspend signal to the process. Note that the item currently being processed will still
* be finished, but the next one won't be started. Listen to the completion of the progress signal to
* determine when this happens.
*/
- (void)suspend;

@end