#import "UIView+PLExtensions.h"

@implementation UIView (PLExtensions)

- (void)pl_addSizeConstraints:(CGSize)size
{
    [self pl_addWidthConstraint:size.width];
    [self pl_addHeightConstraint:size.height];
}

- (void)pl_addWidthConstraint:(CGFloat)width
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[self(%.0f)]", width] options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
}

- (void)pl_addHeightConstraint:(CGFloat)height
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[self(%.0f)]", height] options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];

}

- (void)pl_addHorizontalStretchConstraint
{
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
}

- (void)pl_addVerticalStretchConstraint
{
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[self]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
}

@end