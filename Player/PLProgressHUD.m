#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "PLProgressHUD.h"

@implementation PLProgressHUD

+ (RACDisposable *)showWithStatus:(NSString *)status
{
    RACDisposable *scheduledDisposable = [[RACScheduler mainThreadScheduler] afterDelay:0.5 schedule:^{
        [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeBlack];
    }];
    
    RACDisposable *dismissDisposable = [RACDisposable disposableWithBlock:^{
        [SVProgressHUD dismiss];
    }];
    
    return [RACCompoundDisposable compoundDisposableWithDisposables:@[scheduledDisposable, dismissDisposable]];
}

@end
