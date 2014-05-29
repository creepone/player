#import <UIKit/UIKit.h>

@class PLCoreDataStack, PLViewController;

@interface PLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (nonatomic) PLCoreDataStack *coreDataStack;

@end
