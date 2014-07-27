#import "PLPodcastEpisodeCell.h"
#import "PLPodcastEpisodeCellViewModel.h"
#import "PLKVOObserver.h"

@interface PLPodcastEpisodeCell() <SWTableViewCellDelegate> {
    PLKVOObserver *_viewModelObserver;
}

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelSubtitle;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewAddState;

@end

@implementation PLPodcastEpisodeCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
    }
    return self;
}


- (void)updateButtons
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = self.viewModel.rightButtonBackgroundColor;
    [button setTitle:self.viewModel.rightButtonText forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
    [button setTitleColor:self.viewModel.rightButtonTextColor forState:UIControlStateNormal];
    
    self.rightUtilityButtons = @[button];
}

- (void)setViewModel:(PLPodcastEpisodeCellViewModel *)viewModel
{
    _viewModel = viewModel;
    if (viewModel != nil) {
        [self setupBindings];
    }
}

- (void)setupBindings
{
    @weakify(self);
    
    PLKVOObserver *observer = [PLKVOObserver observerWithTarget:_viewModel];
    
    [observer addKeyPath:@keypath(_viewModel.titleText) handler:^(id value) { @strongify(self); self.labelTitle.text = value; }];
    [observer addKeyPath:@keypath(_viewModel.subtitleText) handler:^(id value) { @strongify(self); self.labelSubtitle.text = value; }];
    [observer addKeyPath:@keypath(_viewModel.imageAddState) handler:^(id value) { @strongify(self); self.imageViewAddState.image = value; }];
    [observer addKeyPath:@keypath(_viewModel.alpha) handler:^(id value) { @strongify(self);
        CGFloat alpha = [value floatValue];
        self.labelTitle.alpha = alpha;
        self.labelSubtitle.alpha = alpha;
        self.imageViewAddState.alpha = alpha;
    }];
    
    [observer addKeyPath:@keypath(_viewModel.rightButtonText) handler:^(id value) { @strongify(self); [self updateButtons]; }];
    [observer addKeyPath:@keypath(_viewModel.rightButtonBackgroundColor) handler:^(id value) { @strongify(self); [self updateButtons]; }];
    [observer addKeyPath:@keypath(_viewModel.rightButtonTextColor) handler:^(id value) { @strongify(self); [self updateButtons]; }];

    _viewModelObserver = observer;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [self.viewModel pressedButtonAt:index];
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _viewModelObserver = nil;
    self.viewModel = nil;
}

- (void)dealloc
{
    _viewModelObserver = nil;
    self.viewModel = nil;
}

@end
