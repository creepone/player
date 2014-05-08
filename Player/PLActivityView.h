//
//  PLActivityView.h
//  Player
//
//  Created by Tomas Vana on 07/05/14.
//  Copyright (c) 2014 Tomas Vana. All rights reserved.
//

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
