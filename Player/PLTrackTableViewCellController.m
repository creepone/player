#import "PLTrackTableViewCellController.h"
#import "PLTrackTableViewCell.h"
#import "PLMediaItemTrack.h"
#import "PLUtils.h"

@implementation PLTrackTableViewCellController

+ (void)configureCell:(PLTrackTableViewCell *)cell withTrack:(PLMediaItemTrack *)track selected:(BOOL)selected
{
    cell.labelTitle.text = track.title;
    cell.labelDuration.text = [PLUtils formatDuration:track.duration];
    [self setSelected:selected forCell:cell];
}

+ (void)setSelected:(BOOL)selected forCell:(PLTrackTableViewCell *)cell
{
    if (selected) {
        cell.labelTitle.alpha = 0.5;
        cell.labelDuration.alpha = 0.5;
        cell.imageViewAddState.image = [UIImage imageNamed:@"ButtonRemove"];
    }
    else {
        cell.labelTitle.alpha = 1.0;
        cell.labelDuration.alpha = 1.0;
        cell.imageViewAddState.image = [UIImage imageNamed:@"ButtonAdd"];
    }
}

@end
