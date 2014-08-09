#import "PLBookmarkCell.h"
#import "PLBookmarkCellViewModel.h"
#import "PLKVOObserver.h"
#import "UIView+PLExtensions.h"

@interface PLBookmarkCell() {
    NSLayoutConstraint *_progressWidthConstraint;
    PLKVOObserver *_viewModelObserver;
    NSLayoutConstraint *_positionConstraint;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewArtwork;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelArtist;
@property (strong, nonatomic) IBOutlet UILabel *labelDuration;
@property (strong, nonatomic) IBOutlet UIView *viewProgress;
@property (strong, nonatomic) IBOutlet UIView *viewPosition;

@end

@implementation PLBookmarkCell

- (void)setViewModel:(PLBookmarkCellViewModel *)viewModel
{
    _viewModel = viewModel;
    if (viewModel != nil) {
        [self setupBindings];
    }
}

- (void)setupBindings
{
    @weakify(self);
    
    [self setBookmarkPosition:_viewModel.bookmarkPosition];
    
    PLKVOObserver *observer = [PLKVOObserver observerWithTarget:_viewModel];
    [observer addKeyPath:@keypath(_viewModel.titleText) handler:^(id value) { @strongify(self); self.labelTitle.text = value; }];
    [observer addKeyPath:@keypath(_viewModel.artistText) handler:^(id value) { @strongify(self); self.labelArtist.text = value; }];
    [observer addKeyPath:@keypath(_viewModel.durationText) handler:^(id value) { @strongify(self); self.labelDuration.text = value; }];
    [observer addKeyPath:@keypath(_viewModel.backgroundColor) handler:^(id value) { @strongify(self); self.backgroundColor = value; }];
    [observer addKeyPath:@keypath(_viewModel.playbackProgress) handler:^(id value) { @strongify(self); [self setCellProgress:value]; }];
    
    [observer addKeyPath:@keypath(_viewModel.alpha) handler:^(id value) { @strongify(self);
        self.labelTitle.alpha = self.labelArtist.alpha = self.labelDuration.alpha = self.imageViewArtwork.alpha = self.viewProgress.alpha = [value floatValue];
    }];
    
    [observer addKeyPath:@keypath(_viewModel.imageArtwork) handler:^(id value) { @strongify(self);
        self.imageViewArtwork.image = value ? : [UIImage imageNamed:@"DefaultArtwork"];
    }];
    
    _viewModelObserver = observer;
}

- (void)setCellProgress:(NSNumber *)progress
{
    UIView *progressSuperview = self.viewProgress.superview;
    
    if (_progressWidthConstraint) {
        [progressSuperview removeConstraint:_progressWidthConstraint];
    }
    
    float multiplier = [progress floatValue];
    
    // some weird rounding errors cause unsatisfiable constraints when the multiplier is too low
    if (multiplier < 0.001f)
        multiplier = 0.f;
    
    _progressWidthConstraint = [NSLayoutConstraint constraintWithItem:self.viewProgress attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:progressSuperview attribute:NSLayoutAttributeWidth multiplier:multiplier constant:0.];
    [progressSuperview addConstraint:_progressWidthConstraint];
}

- (void)setBookmarkPosition:(double)position
{
    UIView *progressSuperview = self.viewPosition.superview;
    
    if (_positionConstraint) {
        [progressSuperview removeConstraint:_positionConstraint];
    }
    
    float multiplier = 2. * position;
    
    // some weird rounding errors cause unsatisfiable constraints when the multiplier is too low
    if (multiplier < 0.001f)
        multiplier = 0.f;
    
    _positionConstraint = [NSLayoutConstraint constraintWithItem:self.viewPosition attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:progressSuperview attribute:NSLayoutAttributeCenterX multiplier:multiplier constant:0.];
    [progressSuperview addConstraint:_positionConstraint];
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
