#import <RXPromise/RXPromise.h>
#import "PLAlertViewDelegate.h"

@interface PLAlertViewDelegate() {
    RXPromise *_promise;
}
@end

@implementation PLAlertViewDelegate

- (RXPromise *)showAlertView:(UIAlertView *)alertView
{
    _promise = [[RXPromise alloc] init];

    alertView.delegate = self;
    [alertView show];

    return _promise;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [_promise resolveWithResult:@(buttonIndex)];
}

@end