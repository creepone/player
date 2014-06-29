#import "PLTrackCell.h"
#import "PLTrackCellViewModel.h"

@interface PLTrackCell() {
    PLTrackCellViewModel *_modelView;
}

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelDuration;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewAddState;

@end

@implementation PLTrackCell

- (void)setupBindings:(PLTrackCellViewModel *)modelView
{
    _modelView = modelView;

    self.labelTitle.text = modelView.titleText;
    self.labelDuration.text = modelView.durationText;
    self.imageViewAddState.image = modelView.imageAddState;

    self.labelTitle.alpha = modelView.alpha;
    self.labelDuration.alpha = modelView.alpha;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _modelView = nil;
}

@end
