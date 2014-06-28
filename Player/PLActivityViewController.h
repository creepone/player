#import <UIKit/UIKit.h>

@class RACSignal;

@interface PLActivityViewController : NSObject

/**
 Initializes this controller with the given PLActivity instances, that will be shown in two rows (the app activities in the upper one).
 */
- (instancetype)initWithActivities:(NSArray *)activities
                     appActivities:(NSArray *)appActivities;

/**
* Presents this view controller under the view of the application's root view controller.
* Delivers a signal that will complete as soon as it has performed all the work and was dismissed.
*/
- (RACSignal *)presentFromRootViewController;

/**
* Presents this view controller under the view of the given view controller.
* Delivers a signal that will complete as soon as it has performed all the work and was dismissed.
*/
- (RACSignal *)presentFromViewController:(UIViewController *)controller;

@end
