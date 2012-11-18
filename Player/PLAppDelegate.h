//
//  PLAppDelegate.h
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLCoreDataStack, PLViewController;

@interface PLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (nonatomic) PLCoreDataStack *coreDataStack;

@end
