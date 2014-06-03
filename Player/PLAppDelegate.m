#import <SVProgressHUD.h>
#import <RXPromise.h>

#import "PLAppDelegate.h"
#import "PLCoreDataStack.h"
#import "PLMigrationManager.h"
#import "PLDefaultsManager.h"
#import "PLPlayer.h"
#import "PLPlaylistViewController.h"
#import "PLPlayerViewController.h"
#import "PLBookmarksViewController.h"
#import "PLSettingsViewController.h"
#import "PLColors.h"
#import "PLErrorManager.h"
#import "PLFileImport.h"
#import "PLUtils.h"

static const int kMigrationErrorAlertTag = 44;

@interface PLAppDelegate() <UIAlertViewDelegate>

static void onUncaughtException(NSException* exception);

@end


@implementation PLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [PLLogging setupLogging];
    NSSetUncaughtExceptionHandler(&onUncaughtException);

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = [PLColors themeColor];
    [PLDefaultsManager registerDefaults];

    // temporary VC for the progress hud
    self.window.rootViewController = [[UIViewController alloc] init];
    [self.window makeKeyAndVisible];

    [self.window.rootViewController.view setBackgroundColor:[UIColor colorWithPatternImage:[PLUtils launchImage]]];
    
    [self initializeData].then(^(id result){
        NSURL *fileToImport = launchOptions[UIApplicationLaunchOptionsURLKey];
        if (fileToImport)
            [PLFileImport importFile:fileToImport];
        return (id)nil;
    }, nil);
    

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [application endReceivingRemoteControlEvents];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [PLFileImport importFile:url];
    return YES;
}

#pragma mark - Data initialization on startup

- (RXPromise *)initializeData
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Messages.InitializingData", nil) maskType:SVProgressHUDMaskTypeBlack];

    // todo: grace time for the hud

    @weakify(self);
    return [PLMigrationManager coreDataStack].thenOnMain(^(PLCoreDataStack *coreDataStack) {
        @strongify(self);

        self.coreDataStack = coreDataStack;
        [SVProgressHUD dismiss];
        [self showMainUi];

        return coreDataStack;
    },
    ^(NSError *error) {
        @strongify(self);

        [PLErrorManager logError:error];
        [SVProgressHUD dismiss];

        // todo: localize
        UIAlertView *alert = [[UIAlertView alloc]
                initWithTitle:@"Error"
                      message:@"There was an error migrating the data."
                     delegate:self
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil];

        [alert setTag:kMigrationErrorAlertTag];
        [alert show];

        return (id)nil;
    });
}

- (void)showMainUi
{
    UIViewController *playlistViewController = [[PLPlaylistViewController alloc] initWithNibName:@"PLPlaylistViewController" bundle:nil];
    UIViewController *playerViewController = [[PLPlayerViewController alloc] initWithNibName:@"PLPlayerViewController" bundle:nil];
    UIViewController *settingsViewController = [[PLSettingsViewController alloc] initWithNibName:@"PLSettingsViewController" bundle:nil];
    UIViewController *bookmarksViewController = [[PLBookmarksViewController alloc] initWithNibName:@"PLBookmarksViewController" bundle:nil];
    
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[playlistViewController, playerViewController, bookmarksViewController, settingsViewController];
    
    self.window.rootViewController = self.tabBarController;
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kMigrationErrorAlertTag) {
        exit(1);
    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            [[PLPlayer sharedPlayer] playPause];
            break;
        case UIEventSubtypeRemoteControlPlay:
            [[PLPlayer sharedPlayer] playPause];
            break;
        case UIEventSubtypeRemoteControlPause:
            [[PLPlayer sharedPlayer] playPause];
            break;
        case UIEventSubtypeRemoteControlStop:
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [[PLPlayer sharedPlayer] makeBookmark];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [[PLPlayer sharedPlayer] goBack];
            break;
        default:
            break;
    }
}

static void onUncaughtException(NSException* exception)
{
    DDLogCError(@"Uncaught exception:\n%@\n%@\n%@", exception.name, exception.reason, exception.userInfo);
}

@end
