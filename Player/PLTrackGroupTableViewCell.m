#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLTrackGroupTableViewCell.h"
#import "PLTrackGroupCellModelView.h"

@interface PLTrackGroupTableViewCell() {
    PLTrackGroupCellModelView *_modelView;
}

@end

@implementation PLTrackGroupTableViewCell

- (void)setupBindings:(PLTrackGroupCellModelView *)modelView
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
