#import <Foundation/Foundation.h>

@class RACSignal;

@interface PLBackgroundProcess (Protected)

/**
 * @abstract
 * Delivers a signal containing a single next item to be processed.
 */
- (RACSignal *)nextItem;

/**
 * @abstract
 * Delivers a signal that is generated while processing the item, delivering a single progress object at the beginning
 * and completing the signal when the processing is done. If the signal errors out, the whole background process will be terminated.
 */
- (RACSignal *)processItem:(id)item;

@end