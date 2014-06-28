#import <SVProgressHUD.h>
#import <RXPromise.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "PLAppDelegate.h"
#import "PLCoreDataStack.h"
#import "PLMigrationManager.h"
#import "PLDefaultsManager.h"
#import "PLPlayer.h"
#import "PLColors.h"
#import "PLErrorManager.h"
#import "PLFileImport.h"
#import "PLUtils.h"
#import "PLMainUI.h"
#import "PLMediaMirror.h"
#import "PLDownloadManager.h"

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
    
    [self initializeData].thenOnMain(^(id result){

        [PLMainUI showNew];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

        NSURL *fileToImport = launchOptions[UIApplicationLaunchOptionsURLKey];
        if (fileToImport)
            [[PLFileImport importFile:fileToImport] subscribeError:[PLErrorManager logErrorVoidBlock]];

        [[PLMediaMirror sharedInstance] ensureRunning];
        
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

    PLMediaMirror *mediaMirror = [PLMediaMirror sharedInstance];
    RACSignal *progressSignal = [mediaMirror progressSignal];

    if (progressSignal) {
        __block UIBackgroundTaskIdentifier backgroundTask;
        backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
            [application endBackgroundTask:backgroundTask];
        }];

        [mediaMirror suspend];
        [progressSignal subscribeCompleted:^{
            [application endBackgroundTask:backgroundTask];
        }];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (self.coreDataStack)
        [[PLMediaMirror sharedInstance] ensureRunning];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [application endReceivingRemoteControlEvents];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (self.coreDataStack)
        [[PLFileImport importFile:url] subscribeError:[PLErrorManager logErrorVoidBlock]];
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    if (![identifier isEqualToString:PLBackgroundSessionIdentifier])
        return;
    
    // make sure that the coreDataStack is available to the delegate methods of the download manager
    [[[RACObserve(self, coreDataStack) filter:[PLUtils isNotNilPredicate]] take:1] subscribeNext:^(id _) {
        [[PLDownloadManager sharedManager] setSessionCompletionHandler:completionHandler];
    }];
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
