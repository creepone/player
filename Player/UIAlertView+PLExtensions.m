#import <RXPromise/RXPromise.h>
#import "UIAlertView+PLExtensions.h"
#import "PLAlertViewDelegate.h"

@implementation UIAlertView (PLExtensions)

- (RXPromise *)pl_show
{
    __block PLAlertViewDelegate *delegate = [PLAlertViewDelegate new];
    return [delegate showAlertView:self].thenOnMain(^(id result) {
        delegate = nil;
        return result;
    }, nil);
}

@end