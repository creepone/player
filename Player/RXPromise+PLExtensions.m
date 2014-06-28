#import <ReactiveCocoa/ReactiveCocoa/RACSignal.h>
#import "RXPromise+PLExtensions.h"

@implementation RXPromise (PLExtensions)

+ (RXPromise *)pl_runInBackground:(RXPromiseBackgroundBlock)block
{
    RXPromise *promise = [[RXPromise alloc] init];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [promise fulfillWithValue:block()];
    });

    return promise;
}

@end