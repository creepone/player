#import <ReactiveCocoa/ReactiveCocoa.h>
#import <FFCircularProgressView/FFCircularProgressView.h>
#import "PLPlaylistSongCell.h"
#import "PLPlaylistSongCellViewModel.h"
#import "PLColors.h"
#import "UIView+PLExtensions.h"
#import "PLKVOObserver.h"

@interface PLPlaylistSongCell () {
    NSLayoutConstraint *_progressWidthConstraint;
    PLKVOObserver *_viewModelObserver;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewArtwork;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelArtist;
@property (strong, nonatomic) IBOutlet UILabel *labelDuration;
@property (strong, nonatomic) IBOutlet UIButton *buttonPlaceholder;
@property (strong, nonatomic) IBOutlet UIView *viewProgress;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintRightViewPlaceholder;

- (IBAction)tappedAccessory:(id)sender;

@end

static const int kAccessoryProgressTag = 1;
static const int kAccessoryImageTag = 2;

@implementation PLPlaylistSongCell

- (void)setViewModel:(PLPlaylistSongCellViewModel *)viewModel
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
    
    [observer addKeyPath:@keypath(_viewModel.accessoryProgress) handler:^(id value) { @strongify(self);
        [self setAccessoryProgress:value];
        [self updateButtonPlaceholderVisibility];
    }];
    
    [observer addKeyPath:@keypath(_viewModel.accessoryImage) handler:^(id value) { @strongify(self);
        [self setAccessoryImage:value];
        [self updateButtonPlaceholderVisibility];
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

- (void)setAccessoryProgress:(NSNumber *)progress
{
    FFCircularProgressView *progressView = (FFCircularProgressView *)[self.buttonPlaceholder viewWithTag:kAccessoryProgressTag];

    if (progress == nil) {
        [progressView removeFromSuperview];
        return;
    }
    else if (progressView == nil) {
        progressView = [[FFCircularProgressView alloc] init];
        progressView.tag = kAccessoryProgressTag;
        progressView.userInteractionEnabled = NO;
        progressView.tintColor = [PLColors themeColor];
        progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.buttonPlaceholder addSubview:progressView];
        
        [progressView pl_addSizeConstraints:CGSizeMake(25.f, 25.f)];
        [progressView pl_addHorizontalCenterConstraint];
        [progressView pl_addVerticalCenterConstraint];
    }

    [progressView setProgress:[progress floatValue]];
}

- (void)setAccessoryImage:(UIImage *)image
{
    UIImageView *imageView = (UIImageView *)[self.buttonPlaceholder viewWithTag:kAccessoryImageTag];

    if (image == nil) {
        [imageView removeFromSuperview];
        return;
    }
    else if (imageView == nil) {
        imageView = [[UIImageView alloc] init];
        imageView.tag = kAccessoryImageTag;
        imageView.userInteractionEnabled = NO;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.buttonPlaceholder addSubview:imageView];

        [imageView pl_addSizeConstraints:CGSizeMake(25.f, 25.f)];
        [imageView pl_addHorizontalCenterConstraint];
        [imageView pl_addVerticalCenterConstraint];
    }

    [imageView setImage:image];
}

- (void)updateButtonPlaceholderVisibility
{
    BOOL visible = _viewModel.accessoryProgress || _viewModel.accessoryImage;

    // to keep the other constraints working, we move this view out of the visible container if it should be hidden
    if (visible)
        self.constraintRightViewPlaceholder.constant = 8.f;
    else
        self.constraintRightViewPlaceholder.constant = -25.f;
}

- (IBAction)tappedAccessory:(id)sender
{
    dispatch_block_t accessoryBlock = _viewModel.accessoryBlock;
    if (accessoryBlock != nil)
        accessoryBlock();
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