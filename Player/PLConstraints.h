#import <Foundation/Foundation.h>

@interface PLConstraints : NSObject

/**
* Adds a set of constraints that horizontally stack the given views within their common superview,
* without padding or spacing.
*/
+ (void)distributeViewsHorizontally:(NSArray *)views;

/**
* Adds a set of constraints that horizontally stack the given views within their common superview,
* adding the given padding and spacing.
*/
+ (void)distributeViewsHorizontally:(NSArray *)views padding:(CGFloat)padding spacing:(CGFloat)spacing;

/**
* Adds a set of constraints that vertically stack the given views within their common superview,
* without padding or spacing.
*/
+ (void)distributeViewsVertically:(NSArray *)views;

/**
* Adds a set of constraints that vertically stack the given views within their common superview,
* adding the given padding and spacing.
*/
+ (void)distributeViewsVertically:(NSArray *)views padding:(CGFloat)padding spacing:(CGFloat)spacing;

/**
* Adds a set of constraints that aligns the horizontal centers of the given views.
*/
+ (void)alignHorizontalCenters:(NSArray *)views;

@end