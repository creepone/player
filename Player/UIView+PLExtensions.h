#import <Foundation/Foundation.h>

@interface UIView (PLExtensions)

- (void)pl_addSizeConstraints:(CGSize)size;
- (void)pl_addWidthConstraint:(CGFloat)width;
- (void)pl_addHeightConstraint:(CGFloat)height;
- (void)pl_addHorizontalStretchConstraint;
- (void)pl_addVerticalStretchConstraint;

@end