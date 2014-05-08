//
//  PLActivityView.m
//  Player
//
//  Created by Tomas Vana on 07/05/14.
//  Copyright (c) 2014 Tomas Vana. All rights reserved.
//

#import "PLActivityView.h"
#import "PLButton.h"
#import "PLPromise.h"

static CGFloat kHeight = 290;

@interface PLActivityView() {
    BOOL _didSetupConstraints;
    
    PLButton *_buttonCancel;
    PLPromise *_selectedActivityPromise;
}
@end

@implementation PLActivityView

- (instancetype)initWithActivities:(NSArray *)activities
                     appActivities:(NSArray *)appActivities
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _selectedActivityPromise = [[PLPromise alloc] init];

        _buttonCancel = [[PLButton alloc] init];
        _buttonCancel.translatesAutoresizingMaskIntoConstraints = NO;
        _buttonCancel.titleLabel.font = [UIFont systemFontOfSize:23.f];
        
        [_buttonCancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [_buttonCancel setTitleColor:self.tintColor forState:UIControlStateNormal];
        [_buttonCancel setHighlightedBackgroundColor:[UIColor colorWithRed:229./255. green:229./255. blue:229./255. alpha:1.]]; // todo: color helper
        [_buttonCancel addTarget:self action:@selector(tappedCancel:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_buttonCancel];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (PLPromise *)selectedActivity
{
    return _selectedActivityPromise;
}

- (void)setupConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[self(%.0f)]", kHeight] options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
    
    // setup button constraints
    {
        NSDictionary *viewMap = NSDictionaryOfVariableBindings(_buttonCancel);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_buttonCancel]|" options:0 metrics:nil views:viewMap]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_buttonCancel(52)]|" options:0 metrics:nil views:viewMap]];
    }
    
    _didSetupConstraints = YES;
}

- (void)updateConstraints
{
    if (!_didSetupConstraints)
        [self setupConstraints];
    [super updateConstraints];
}

- (void)tappedCancel:(id)sender
{
    [_selectedActivityPromise fulfillWithValue:nil];
}

@end
