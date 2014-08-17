#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLRouter.h"
#import "PLSettingsViewController.h"
#import "PLPlayerViewController.h"
#import "PLImportActivityViewController.h"
#import "PLPlaylistSongsViewController.h"
#import "PLPlaylistSongsViewModel.h"

@implementation PLRouter

+ (void)showLegacy
{
    UIViewController *playerViewController = [[PLPlayerViewController alloc] initWithNibName:@"PLPlayerViewController" bundle:nil];
    UIViewController *settingsViewController = [[PLSettingsViewController alloc] initWithNibName:@"PLSettingsViewController" bundle:nil];

    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[settingsViewController, playerViewController];

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    window.rootViewController = tabBarController;
}

+ (void)showNew
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    window.rootViewController = [mainStoryboard instantiateInitialViewController];
}

+ (RACSignal *)showTrackImport
{
    __block PLImportActivityViewController *activityViewController = [[PLImportActivityViewController alloc] init];
    return [[activityViewController presentFromRootViewController] doCompleted:^{
        DDLogVerbose(@"Completed import activity.");
        activityViewController = nil;
    }];
}

@end
