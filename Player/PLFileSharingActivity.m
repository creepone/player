#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLServiceContainer.h"
#import "PLFileSharingManager.h"
#import "PLFileSharingActivity.h"
#import "PLFileSharingViewModel.h"
#import "PLFileSharingViewController.h"
#import "PLUtils.h"
#import "PLProgressHUD.h"

@implementation PLFileSharingActivity

- (NSString *)title
{
    return NSLocalizedString(@"Activities.FileSharing", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"FileSharingIcon"];
}

- (UIImage *)highlightedImage
{
    return [UIImage imageNamed:@"FileSharingIconHighlighted"];
}

- (RACSignal *)performActivity
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FileSharingImport" bundle:nil];
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    UINavigationController *navigationController = storyboard.instantiateInitialViewController;
    
    PLFileSharingViewModel *viewModel = [[PLFileSharingViewModel alloc] init];
    PLFileSharingViewController *itemsVc = navigationController.viewControllers[0];
    itemsVc.viewModel = viewModel;
    
    [rootViewController presentViewController:navigationController animated:YES completion:nil];
    
    __block RACDisposable *progress;
    
    return [[[[RACObserve(viewModel, dismissed) filter:[PLUtils isTruePredicate]] take:1] then:^RACSignal *{
        
        progress = [PLProgressHUD showWithStatus:@"Adding tracks"]; // todo: localize
    
        return [PLResolve(PLFileSharingManager) importItems:viewModel.selection];
    
    }]
    finally:^{
        [progress dispose];
    }];
}

@end