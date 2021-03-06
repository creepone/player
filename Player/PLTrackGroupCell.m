#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLTrackGroupCell.h"
#import "PLTrackGroupCellViewModel.h"

@interface PLTrackGroupCell () {
    PLTrackGroupCellViewModel *_modelView;
}

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelArtist;
@property (strong, nonatomic) IBOutlet UILabel *labelInfo;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewAddState;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewArtwork;

@end

@implementation PLTrackGroupCell

- (void)setupBindings:(PLTrackGroupCellViewModel *)modelView
{
    _modelView = modelView;

    self.labelTitle.text = modelView.titleText;
    self.labelArtist.text = modelView.artistText;
    self.labelInfo.attributedText = modelView.infoText;

    self.labelTitle.alpha = modelView.alpha;
    self.labelArtist.alpha = modelView.alpha;
    self.labelInfo.alpha = modelView.alpha;
    self.imageViewAddState.image = modelView.imageAddState;

    RAC(self.imageViewArtwork, image, [UIImage imageNamed:@"DefaultArtwork"]) = [RACObserve(modelView, imageArtwork) takeUntil:self.rac_prepareForReuseSignal];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _modelView = nil;
}

@end
