#import <UIKit/UIKit.h>

@class PLCoreDataStack, PLViewController;

@interface PLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) PLCoreDataStack *coreDataStack;

@end
