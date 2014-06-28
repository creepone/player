#import "JCRBlurView.h"

@class RACSignal;

@interface PLActivityView : JCRBlurView

/**
 Initializes this view with the given PLActivity instances, that will be shown in two rows (the app activities in the upper one).
 */
- (instancetype)initWithActivities:(NSArray *)activities
                     appActivities:(NSArray *)appActivities;

/**
* Once an activity (@see PLActivity) is selected in this view, the given signal will deliver it and complete.
* If the view is dismissed without selecting an activity, the signal will simply complete.
*/
- (RACSignal *)selectedActivitySignal;

@end
