#import <Foundation/Foundation.h>

@interface PLAlertViewDelegate : NSObject <UIAlertViewDelegate>

- (RXPromise *)showAlertView:(UIAlertView *)alertView;

@end