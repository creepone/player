#import <RXPromise/RXPromise.h>

typedef id(^RXPromiseBackgroundBlock)();

@interface RXPromise (PLExtensions)

/**
* Executes the given block on a background queue and delivers a promise resolved with its return value.
*/
+ (RXPromise *)pl_runInBackground:(RXPromiseBackgroundBlock)block;

@end