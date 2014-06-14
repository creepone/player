#import <Foundation/Foundation.h>

@class RXPromise;

@interface UIAlertView (PLExtensions)

- (RXPromise *)pl_show;

@end