//
//  PLAppDelegate.m
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import "PLAppDelegate.h"
#import "PLCoreDataStack.h"
#import "PLMigrationManager.h"
#import "PLDefaultsManager.h"

#import "MBProgressHUD.h"

#import "PLPlaylistViewController.h"
#import "PLPlayerViewController.h"
#import "PLBookmarksViewController.h"
#import "PLSettingsViewController.h"

#define MigrationErrorAlertTag 44


@interface PLAppDelegate() <MBProgressHUDDelegate> {
    NSError *_migrationError;
    MBProgressHUD *_progressHud;
}

- (void)startDataInitialization;

@end


@implementation PLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [PLDefaultsManager registerDefaults];

    // temporary VC for the progress hud
    self.window.rootViewController = [[UIViewController alloc] init];
    [self startDataInitialization];

    [self.window makeKeyAndVisible];
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
}

#pragma mark - Data initialization on startup

- (void)startDataInitialization {
    _progressHud = [[MBProgressHUD alloc] initWithWindow:self.window];
    
    [self.window.rootViewController.view addSubview:_progressHud];
    _progressHud.delegate = self;
    _progressHud.graceTime = 1.0;
    _progressHud.labelText = @"Initializing...";
    [_progressHud showWhileExecuting:@selector(performDataInitialization) onTarget:self withObject:nil animated:YES];
}

- (void)performDataInitialization {
    @autoreleasepool {
        NSError *error;
        self.coreDataStack = [PLMigrationManager coreDataStack:&error];
        
        if(error != nil) {
            _migrationError = error;
        }
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [_progressHud removeFromSuperview];
    _progressHud.delegate = nil;
    _progressHud = nil;
    
    if(self.coreDataStack == nil || _migrationError != nil) {
        NSLog(@"Data initialization error: %@", [_migrationError localizedDescription]);
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"MigrationErrorTitle", @"")
                              message:NSLocalizedString(@"MigrationErrorMessage", @"")
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert setTag:MigrationErrorAlertTag];
        [alert show];
        
        return;
    }
    
    UIViewController *playlistViewController = [[PLPlaylistViewController alloc] initWithNibName:@"PLPlaylistViewController" bundle:nil];
    UIViewController *playerViewController = [[PLPlayerViewController alloc] initWithNibName:@"PLPlayerViewController" bundle:nil];
    UIViewController *settingsViewController = [[PLSettingsViewController alloc] initWithNibName:@"PLSettingsViewController" bundle:nil];
    UIViewController *bookmarksViewController = [[PLBookmarksViewController alloc] initWithNibName:@"PLBookmarksViewController" bundle:nil];
    
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[playlistViewController, playerViewController, bookmarksViewController, settingsViewController];
    
    self.window.rootViewController = self.tabBarController;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView.tag == MigrationErrorAlertTag) {
        exit(1);
    }
}


@end
