#import "PLProgressTableViewCell.h"
#import "PLColors.h"
#import "FFCircularProgressView.h"
#import "UIView+PLExtensions.h"

@interface PLProgressTableViewCell() {
    FFCircularProgressView *_progressView;
    BOOL _addedConstraints;
}

@end

@implementation PLProgressTableViewCell

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _progressView = [[FFCircularProgressView alloc] init];
        _progressView.tintColor = [PLColors themeColor];
        _progressView.iconView = [[UIView alloc] initWithFrame:CGRectZero];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_progressView];

        [_progressView pl_addSizeConstraints:CGSizeMake(40, 40)];
        [_progressView startSpinProgressBackgroundLayer];
        
        [self setNeedsUpdateConstraints];

    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.superview && !_addedConstraints) {
        [_progressView pl_addHorizontalCenterConstraint];
        [_progressView pl_addVerticalCenterConstraint];
        _addedConstraints = YES;
    }
}

@end
