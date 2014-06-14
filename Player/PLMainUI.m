#import "PLMainUI.h"
#import "PLBookmarksViewController.h"
#import "PLSettingsViewController.h"
#import "PLPlayerViewController.h"
#import "PLPlaylistViewController.h"

@implementation PLMainUI

+ (void)showLegacy
{
    UIViewController *playlistViewController = [[PLPlaylistViewController alloc] initWithNibName:@"PLPlaylistViewController" bundle:nil];
    UIViewController *playerViewController = [[PLPlayerViewController alloc] initWithNibName:@"PLPlayerViewController" bundle:nil];
    UIViewController *settingsViewController = [[PLSettingsViewController alloc] initWithNibName:@"PLSettingsViewController" bundle:nil];
    UIViewController *bookmarksViewController = [[PLBookmarksViewController alloc] initWithNibName:@"PLBookmarksViewController" bundle:nil];

    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[playlistViewController, playerViewController, bookmarksViewController, settingsViewController];

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    window.rootViewController = tabBarController;
}

+ (void)showNew
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    window.rootViewController = [mainStoryboard instantiateInitialViewController];
}

@end
