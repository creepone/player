#import <ReactiveCocoa/ReactiveCocoa.h>
#import <FFCircularProgressView/FFCircularProgressView.h>
#import "PLPlaylistSongCell.h"
#import "PLPlaylistSongCellViewModel.h"
#import "PLColors.h"
#import "UIView+PLExtensions.h"

@interface PLPlaylistSongCell () {
    PLPlaylistSongCellViewModel *_modelView;
    NSLayoutConstraint *_progressWidthConstraint;
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

- (void)setupBindings:(PLPlaylistSongCellViewModel *)modelView
{
    _modelView = modelView;
    
    RAC(self.labelTitle, text) = [RACObserve(modelView, titleText) takeUntil:self.rac_prepareForReuseSignal];
    RAC(self.labelArtist, text) = [RACObserve(modelView, artistText) takeUntil:self.rac_prepareForReuseSignal];
    
    RACSignal *alphaSignal = [RACObserve(modelView, alpha) takeUntil:self.rac_prepareForReuseSignal];
    RAC(self.labelTitle, alpha) = alphaSignal;
    RAC(self.labelArtist, alpha) = alphaSignal;
    RAC(self.labelDuration, alpha) = alphaSignal;
    RAC(self.imageViewArtwork, alpha) = alphaSignal;
    RAC(self.viewProgress, alpha) = alphaSignal;
    
    RAC(self.imageViewArtwork, image, [UIImage imageNamed:@"DefaultArtwork"]) = [RACObserve(modelView, imageArtwork) takeUntil:self.rac_prepareForReuseSignal];
    RAC(self.labelDuration, text) = [RACObserve(modelView, durationText) takeUntil:self.rac_prepareForReuseSignal];
    RAC(self, backgroundColor) = [RACObserve(modelView, backgroundColor) takeUntil:self.rac_prepareForReuseSignal];
    
    [self rac_liftSelector:@selector(setCellProgress:) withSignals:[RACObserve(modelView, playbackProgress) takeUntil:self.rac_prepareForReuseSignal], nil];
    RAC(self.buttonPlaceholder, rac_command) = [RACObserve(modelView, accessoryCommand) takeUntil:self.rac_prepareForReuseSignal];
    
    RACSignal *accessoryProgressSignal = [RACObserve(modelView, accessoryProgress) takeUntil:self.rac_prepareForReuseSignal];
    RACSignal *accessoryImageSignal = [RACObserve(modelView, accessoryImage) takeUntil:self.rac_prepareForReuseSignal];
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
    _modelView = nil;
}

@end