//
// Created by Tomas Vana on 09/05/14.
// Copyright (c) 2014 Tomas Vana. All rights reserved.
//

#import "PLConstraints.h"


@implementation PLConstraints

+ (void)distributeViews:(NSArray *)views padding:(CGFloat)padding spacing:(CGFloat)spacing direction:(NSString *)direction;
{
    if (![views count])
        return;

    UIView *firstView = [views firstObject];
    UIView *lastView = [views lastObject];
    UIView *superview = [firstView superview];

    [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@:|-%.f-[firstView]", direction, padding] options:0 metrics:nil views:NSDictionaryOfVariableBindings(firstView)]];
    [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@:[lastView]-%.f-|", direction, padding] options:0 metrics:nil views:NSDictionaryOfVariableBindings(lastView)]];

    UIView *previousView = nil;

    for (UIView *currentView in views) {
        if (previousView != nil) {
            [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@:[previousView]-%.f-[currentView]", direction, spacing] options:0 metrics:nil views:NSDictionaryOfVariableBindings(previousView, currentView)]];
        }

        previousView = currentView;
    }
}

+ (void)setEqualAttribute:(NSLayoutAttribute)attribute forViews:(NSArray *)views
{
    if (![views count])
        return;

    UIView *firstView = [views firstObject];
    UIView *superview = [firstView superview];

    UIView *previousView = nil;

    for (UIView *currentView in views) {
        if (previousView != nil) {
            [superview addConstraint:[NSLayoutConstraint constraintWithItem:previousView attribute:attribute relatedBy:NSLayoutRelationEqual toItem:currentView attribute:attribute multiplier:1. constant:0.]];
        }

        previousView = currentView;
    }
}


+ (void)distributeViewsHorizontally:(NSArray *)views
{
    [self distributeViews:views padding:0.f spacing:0.f direction:@"H"];
}

+ (void)distributeViewsHorizontally:(NSArray *)views padding:(CGFloat)padding spacing:(CGFloat)spacing
{
    [self distributeViews:views padding:padding spacing:spacing direction:@"H"];
}

+ (void)distributeViewsVertically:(NSArray *)views
{
    [self distributeViews:views padding:0.f spacing:0.f direction:@"V"];
}

+ (void)distributeViewsVertically:(NSArray *)views padding:(CGFloat)padding spacing:(CGFloat)spacing
{
    [self distributeViews:views padding:padding spacing:spacing direction:@"V"];
}

+ (void)alignHorizontalCenters:(NSArray *)views
{
    [self setEqualAttribute:NSLayoutAttributeCenterX forViews:views];
}

@end