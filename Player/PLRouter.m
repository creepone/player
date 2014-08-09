#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLRouter.h"
#import "PLSettingsViewController.h"
#import "PLPlayerViewController.h"
#import "PLPlaylistViewController.h"
#import "PLImportActivityViewController.h"

@implementation PLRouter

+ (void)showLegacy
{
    UIViewController *playlistViewController = [[PLPlaylistViewController alloc] initWithNibName:@"PLPlaylistViewController" bundle:nil];
    UIViewController *playerViewController = [[PLPlayerViewController alloc] initWithNibName:@"PLPlayerViewController" bundle:nil];
    UIViewController *settingsViewController = [[PLSettingsViewController alloc] initWithNibName:@"PLSettingsViewController" bundle:nil];

    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[playlistViewController, playerViewController, settingsViewController];

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
