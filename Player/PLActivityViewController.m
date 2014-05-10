#import <JCRBlurView.h>
#import "PLActivityViewController.h"
#import "PLActivityView.h"
#import "PLActivity.h"
#import "PLPromise.h"

@interface PLActivityViewController () {
    UIView *_backgroundView;
    PLActivityView *_activityView;
    NSLayoutConstraint *_constraintActivityHidden;
    NSLayoutConstraint *_constraintActivityShown;

    PLPromise *_completionPromise;
}

@property (strong, nonatomic) UIView *view;

@end


@implementation PLActivityViewController

- (instancetype)initWithActivities:(NSArray *)activities
                     appActivities:(NSArray *)appActivities
{
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectZero];
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0;
        [self.view addSubview:_backgroundView];
        
        UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
        [_backgroundView addGestureRecognizer:tapRecognizer];
        
        _activityView = [[PLActivityView alloc] initWithActivities:activities appActivities:appActivities];
        _activityView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_activityView];
        
        UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(activitiesSwipe:)];
        swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        [_activityView addGestureRecognizer:swipeRecognizer];
        
        _activityView.selectedActivity.thenOnMain(^(id<PLActivity> activity) {
            [self dismiss:activity];
            return (id)nil;
        }, nil);
        
        [self addViewsConstraints];
    }
    return self;
}

- (void)backgroundTap:(UITapGestureRecognizer *)sender
{
    [self dismiss:nil];
}

- (void)activitiesSwipe:(UISwipeGestureRecognizer *)sender
{
    [self dismiss:nil];
}

- (void)dismiss:(id<PLActivity>)activity
{
    [self.view removeConstraint:_constraintActivityShown];
    [self.view addConstraint:_constraintActivityHidden];
    
    @weakify(self);
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self);
        if (!self) return;
        
        self->_backgroundView.alpha = 0;
        [self.view layoutIfNeeded];
    }
    completion:^(BOOL finished) {
        @strongify(self);
        [self.view removeFromSuperview];
        
        if (activity)
            [_completionPromise bind:[activity performActivity]];
        else
            [_completionPromise resolveWithResult:nil];
    }];
}

- (PLPromise *)presentFromRootViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    return [self presentFromViewController:rootViewController];
}

- (PLPromise *)presentFromViewController:(UIViewController *)controller
{
    _completionPromise = [[PLPromise alloc] init];

    [controller.view addSubview:self.view];
    [self addSuperviewConstraints];
    
    [self.view removeConstraint:_constraintActivityHidden];
    [self.view addConstraint:_constraintActivityShown];
    
    @weakify(self);
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self);
        if (!self) return;
        
        self->_backgroundView.alpha = 0.4;
        [self.view layoutIfNeeded];
    }];

    return _completionPromise;
}


- (void)addSuperviewConstraints
{
    UIView *superview = self.view.superview;
    NSDictionary *viewMap = NSDictionaryOfVariableBindings(_view);
    [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_view]|" options:0 metrics:nil views:viewMap]];
    [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_view]|" options:0 metrics:nil views:viewMap]];
    [superview layoutIfNeeded];
}

- (void)addViewsConstraints
{
    // add backgroundView constraints
    {
        NSDictionary *viewMap = NSDictionaryOfVariableBindings(_backgroundView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundView]|" options:0 metrics:nil views:viewMap]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundView]|" options:0 metrics:nil views:viewMap]];
    }
    
    // add activityView constraints
    {
        NSDictionary *viewMap = NSDictionaryOfVariableBindings(_activityView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_activityView]|" options:0 metrics:nil views:viewMap]];
        
        _constraintActivityHidden = [NSLayoutConstraint constraintWithItem:_activityView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
        _constraintActivityShown = [NSLayoutConstraint constraintWithItem:_activityView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
        
        [self.view addConstraint:_constraintActivityHidden];
    }
}



@end
