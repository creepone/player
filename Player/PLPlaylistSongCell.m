#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPlaylistSongCell.h"
#import "PLPlaylistSongCellModelView.h"

@interface PLPlaylistSongCell () {
    PLPlaylistSongCellModelView *_modelView;
    NSLayoutConstraint *_progressWidthConstraint;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewArtwork;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelArtist;
@property (strong, nonatomic) IBOutlet UILabel *labelDuration;
@property (strong, nonatomic) IBOutlet UIView *viewPlaceholder;
@property (strong, nonatomic) IBOutlet UIView *viewProgress;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintRightViewPlaceholder;

@end

@implementation PLPlaylistSongCell

- (void)setProgress:(NSNumber *)progress
{
    UIView *progressSuperview = self.viewProgress.superview;

    if (_progressWidthConstraint) {
        [progressSuperview removeConstraint:_progressWidthConstraint];
    }

    _progressWidthConstraint = [NSLayoutConstraint constraintWithItem:self.viewProgress attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:progressSuperview attribute:NSLayoutAttributeWidth multiplier:[progress floatValue] constant:0.];
    [progressSuperview addConstraint:_progressWidthConstraint];
}

- (void)setViewPlaceholderVisible:(BOOL)visible
{
    // to keep the other constraints working, we move this view out of the visible container if it should be hidden
    if (visible)
        self.constraintRightViewPlaceholder.constant = 8.f;
    else
        self.constraintRightViewPlaceholder.constant = -25.f;

}


- (void)setupBindings:(PLPlaylistSongCellModelView *)modelView
{
    @weakify(self);

    _modelView = modelView;

    RAC(self.imageViewArtwork, image, [UIImage imageNamed:@"DefaultArtwork"]) = RACObserve(modelView, imageArtwork);
    RAC(self.labelTitle, text) = RACObserve(modelView, titleText);
    RAC(self.labelArtist, text) = RACObserve(modelView, artistText);
    RAC(self.labelDuration, text) = RACObserve(modelView, durationText);
    RAC(self, backgroundColor) = RACObserve(modelView, backgroundColor);

    [RACObserve(modelView, progress) subscribeNext:^(NSNumber *progress) {
        @strongify(self);
        [self setProgress:progress];
    }];

    // todo: once the download logic and selection logic is in place, there will be a progress/selection indicator in the placeholder
    [self setViewPlaceholderVisible:NO];
}

- (void)removeBindings
{
    _modelView = nil;
}

@end