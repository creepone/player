#import "JCRBlurView.h"

@class PLPromise;

@interface PLActivityView : JCRBlurView

/**
 Initializes this view with the given PLActivity instances, that will be shown in two rows (the app activities in the upper one).
 */
- (instancetype)initWithActivities:(NSArray *)activities
                     appActivities:(NSArray *)appActivities;

/**
* Once an activity (@see PLActivity) is selected in this view, the given promise will be resolved with it.
* If the view is dismissed without selecting an activity, the promise will resolve to nil.
*/
- (PLPromise *)selectedActivity;

@end
