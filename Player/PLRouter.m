#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLRouter.h"
#import "PLSettingsViewController.h"
#import "PLImportActivityViewController.h"
#import "PLPlaylistSongsViewController.h"
#import "PLPlaylistSongsViewModel.h"

@implementation PLRouter

+ (void)showLegacy
{
    UIViewController *settingsViewController = [[PLSettingsViewController alloc] initWithNibName:@"PLSettingsViewController" bundle:nil];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    window.rootViewController = navigationController;
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
