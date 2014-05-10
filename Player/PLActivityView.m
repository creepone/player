#import "PLActivityView.h"
#import "PLButton.h"
#import "PLPromise.h"
#import "PLColors.h"
#import "PLActivity.h"
#import "UIView+PLExtensions.h"
#import "NSObject+PLExtensions.h"
#import "PLConstraints.h"

static CGFloat kRowHeight = 119;
static CGFloat kButtonHeight = 52;

@interface PLActivityView() {
    NSArray *_activities, *_appActivities;
    PLPromise *_selectedActivityPromise;
}
@end

@implementation PLActivityView

- (instancetype)initWithActivities:(NSArray *)activities
                     appActivities:(NSArray *)appActivities
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _activities = activities;
        _appActivities = appActivities;
        _selectedActivityPromise = [[PLPromise alloc] init];

        [self setupViews];
    }
    return self;
}

- (PLPromise *)selectedActivity
{
    return _selectedActivityPromise;
}

- (void)setupViews
{
    PLButton *buttonCancel = [PLButton new];
    [self addSubview:buttonCancel];
    [buttonCancel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [buttonCancel.titleLabel setFont:[UIFont systemFontOfSize:23.f]];
    [buttonCancel setTitle:@"Cancel" forState:UIControlStateNormal]; // todo: localize
    [buttonCancel setHighlightedBackgroundColor:[PLColors shadeOfGrey:229]];
    [buttonCancel addTarget:self action:@selector(tappedCancel:) forControlEvents:UIControlEventTouchUpInside];
    [buttonCancel pl_addHeightConstraint:kButtonHeight];
    [buttonCancel pl_addHorizontalStretchConstraint];

    UIScrollView *bottomRow = [self setupViewsForActivities:_activities];

    UIView *separator = [UIView new];
    [self addSubview:separator];
    [separator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [separator setBackgroundColor:[UIColor colorWithRed:0. green:0. blue:0. alpha:0.4]];
    [separator pl_addHorizontalStretchConstraint];
    [separator pl_addHeightConstraint:1.];

    UIScrollView *topRow = [self setupViewsForActivities:_appActivities];

    [PLConstraints distributeViewsVertically:@[topRow, separator, bottomRow, buttonCancel]];
}

- (UIScrollView *)setupViewsForActivities:(NSArray *)activities
{
    UIScrollView *rowView = [UIScrollView new];
    [self addSubview:rowView];
    [rowView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [rowView setAlwaysBounceHorizontal:YES];
    [rowView setShowsHorizontalScrollIndicator:NO];
    [rowView setShowsVerticalScrollIndicator:NO];
    [rowView pl_addHeightConstraint:kRowHeight];
    [rowView pl_addHorizontalStretchConstraint];

    NSMutableArray *actionButtons = [NSMutableArray array];
    
    for (id <PLActivity> activity in activities) {
        PLButton *actionButton = [PLButton new];
        [rowView addSubview:actionButton];
        [actionButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [actionButton setBackgroundImage:activity.image forState:UIControlStateNormal];
        [actionButton setAdjustsImageWhenHighlighted:YES];
        [actionButton pl_addSizeConstraints:CGSizeMake(60., 60.)];
        [actionButtons addObject:actionButton];

        if ([activity respondsToSelector:@selector(highlightedImage)])
            [actionButton setBackgroundImage:activity.highlightedImage forState:UIControlStateHighlighted];

        actionButton.pl_userInfo[@"activity"] = activity;
        [actionButton addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *titleLabel = [UILabel new];
        [rowView addSubview:titleLabel];
        [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [titleLabel setText:activity.title];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setFont:[UIFont systemFontOfSize:11.]];
        [titleLabel setNumberOfLines:0];
        
        [PLConstraints alignHorizontalCenters:@[actionButton, titleLabel]];
        
        [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[actionButton]-5-[titleLabel]"
                                                                          options:0 metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(actionButton, titleLabel)]];
    }
    
    [PLConstraints distributeViewsHorizontally:actionButtons padding:10. spacing:13.];
    
    return rowView;
}

- (void)tappedCancel:(id)sender
{
    [_selectedActivityPromise fulfillWithValue:nil];
}

- (void)tappedButton:(PLButton *)sender
{
    [_selectedActivityPromise fulfillWithValue:sender.pl_userInfo[@"activity"]];
}

@end
