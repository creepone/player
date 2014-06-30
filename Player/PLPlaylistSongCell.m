#import <ReactiveCocoa/ReactiveCocoa.h>
#import <FFCircularProgressView/FFCircularProgressView.h>
#import "PLPlaylistSongCell.h"
#import "PLPlaylistSongCellViewModel.h"
#import "PLColors.h"
#import "UIView+PLExtensions.h"

@interface PLPlaylistSongCell () {
    NSLayoutConstraint *_progressWidthConstraint;
    RACDisposable *_bindingsDisposable;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewArtwork;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelArtist;
@property (strong, nonatomic) IBOutlet UILabel *labelDuration;
@property (strong, nonatomic) IBOutlet UIButton *buttonPlaceholder;
@property (strong, nonatomic) IBOutlet UIView *viewProgress;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintRightViewPlaceholder;

@end

const int kAccessoryProgressTag = 1;
const int kAccessoryImageTag = 2;

@implementation PLPlaylistSongCell

- (void)setViewModel:(PLPlaylistSongCellViewModel *)viewModel
{
    _viewModel = viewModel;
    [_bindingsDisposable dispose];

    if (viewModel != nil) {
        [self setupStaticValues];
        
        _bindingsDisposable = [[RACScheduler mainThreadScheduler] afterDelay:1.0 schedule:^{
            [self setupBindings];
        }];
    }    
}

- (void)setupStaticValues
{
    self.labelTitle.text = self.viewModel.titleText;
    self.labelArtist.text = self.viewModel.artistText;
    self.labelTitle.alpha = self.labelArtist.alpha = self.labelDuration.alpha = self.imageViewArtwork.alpha = self.viewProgress.alpha = self.viewModel.alpha;
    
    UIImage *imageArtwork = self.viewModel.imageArtwork;
    self.imageViewArtwork.image = imageArtwork ? : [UIImage imageNamed:@"DefaultArtwork"];
    
    self.labelDuration.text = self.viewModel.durationText;
    self.backgroundColor = self.viewModel.backgroundColor;

    [self setCellProgress:@(self.viewModel.playbackProgress)];
    self.buttonPlaceholder.rac_command = self.viewModel.accessoryCommand;
    
    NSNumber *accessoryProgress = self.viewModel.accessoryProgress;
    UIImage *accessoryImage = self.viewModel.accessoryImage;
    
    [self setAccessoryProgress:accessoryProgress];
    [self setAccessoryImage:accessoryImage];
    [self setButtonPlaceholderVisible:(accessoryProgress || accessoryImage)];

}

- (void)setupBindings
{
    RAC(self.labelTitle, text) = [RACObserve(self.viewModel, titleText) takeUntil:self.rac_prepareForReuseSignal];
    RAC(self.labelArtist, text) = [RACObserve(self.viewModel, artistText) takeUntil:self.rac_prepareForReuseSignal];
    
    [[RACObserve(self.viewModel, alpha) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *alpha) {
        self.labelTitle.alpha = self.labelArtist.alpha = self.labelDuration.alpha = self.imageViewArtwork.alpha = self.viewProgress.alpha = [alpha floatValue];
    }];
    
    RAC(self.imageViewArtwork, image, [UIImage imageNamed:@"DefaultArtwork"]) = [RACObserve(self.viewModel, imageArtwork) takeUntil:self.rac_prepareForReuseSignal];
    RAC(self.labelDuration, text) = [RACObserve(self.viewModel, durationText) takeUntil:self.rac_prepareForReuseSignal];
    RAC(self, backgroundColor) = [RACObserve(self.viewModel, backgroundColor) takeUntil:self.rac_prepareForReuseSignal];
    
    [self rac_liftSelector:@selector(setCellProgress:) withSignals:[RACObserve(self.viewModel, playbackProgress) takeUntil:self.rac_prepareForReuseSignal], nil];
    RAC(self.buttonPlaceholder, rac_command) = [RACObserve(self.viewModel, accessoryCommand) takeUntil:self.rac_prepareForReuseSignal];
    
    RACSignal *accessoryProgressSignal = [RACObserve(self.viewModel, accessoryProgress) takeUntil:self.rac_prepareForReuseSignal];
    RACSignal *accessoryImageSignal = [RACObserve(self.viewModel, accessoryImage) takeUntil:self.rac_prepareForReuseSignal];
    RACSignal *accessoryVisibleSignal = [RACSignal combineLatest:@[accessoryProgressSignal, accessoryImageSignal] reduce:^(id first, id second) { return @(first || second); }];
    
    [self rac_liftSelector:@selector(setAccessoryProgress:) withSignals:accessoryProgressSignal, nil];
    [self rac_liftSelector:@selector(setAccessoryImage:) withSignals:accessoryImageSignal, nil];
    [self rac_liftSelector:@selector(setButtonPlaceholderVisible:) withSignals:accessoryVisibleSignal, nil];
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

        [progressView pl_addHorizontalStretchConstraint];
        [progressView pl_addVerticalStretchConstraint];
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

        [imageView pl_addHorizontalStretchConstraint];
        [imageView pl_addVerticalStretchConstraint];
    }

    [imageView setImage:image];
}

- (void)setButtonPlaceholderVisible:(BOOL)visible
{
    // to keep the other constraints working, we move this view out of the visible container if it should be hidden
    if (visible)
        self.constraintRightViewPlaceholder.constant = 8.f;
    else
        self.constraintRightViewPlaceholder.constant = -25.f;
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    self.viewModel = nil;
}

@end