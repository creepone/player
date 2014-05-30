#import "PLTrackGroupTableViewCellController.h"
#import "PLTrackGroupTableViewCell.h"
#import "PLMediaItemTrackGroup.h"
#import "NSObject+PLExtensions.h"

@implementation PLTrackGroupTableViewCellController

+ (void)configureCell:(PLTrackGroupTableViewCell *)cell withTrackGroup:(PLMediaItemTrackGroup *)trackGroup
{
    cell.labelTitle.text = trackGroup.title;
    cell.labelArtist.text = trackGroup.artist;
    cell.labelInfo.attributedText = [self infoTextForTrackGroup:trackGroup];
    [cell pl_setValueForKeyPath:@"imageArtwork" fromPromise:trackGroup.artwork];
}

+ (void)configureCell:(PLTrackGroupTableViewCell *)cell withTrackGroup:(PLMediaItemTrackGroup *)trackGroup selected:(BOOL)selected
{
    [self configureCell:cell withTrackGroup:trackGroup];
    [self setSelected:selected forCell:cell];
}

+ (void)setSelected:(BOOL)selected forCell:(PLTrackGroupTableViewCell *)cell
{
    if (selected) {
        cell.labelTitle.alpha = 0.5;
        cell.labelArtist.alpha = 0.5;
        cell.labelInfo.alpha = 0.5;
        cell.imageViewAddState.image = [UIImage imageNamed:@"ButtonRemove"];
    }
    else {
        cell.labelTitle.alpha = 1.0;
        cell.labelArtist.alpha = 1.0;
        cell.labelInfo.alpha = 1.0;
        cell.imageViewAddState.image = [UIImage imageNamed:@"ButtonAdd"];
    }
}

+ (NSAttributedString *)infoTextForTrackGroup:(PLMediaItemTrackGroup *)trackGroup
{
    NSMutableAttributedString *infoText = [[NSMutableAttributedString alloc] init];
    NSDictionary *boldAttributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:13.] };
    NSDictionary *regularAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:13.] };
    
    NSString *trackCount = [NSString stringWithFormat:@"%u ", (unsigned)trackGroup.trackCount];
    NSAttributedString *trackCountText = [[NSAttributedString alloc] initWithString:trackCount attributes:boldAttributes];
    
    NSString *tracks = [NSString stringWithFormat:@"%@, ", trackGroup.trackCount == 1 ? @"track" : @"tracks"]; // todo: localize
    NSAttributedString *tracksText = [[NSAttributedString alloc] initWithString:tracks attributes:regularAttributes];
    
    NSString *unit, *duration;
    int minutes = (int)trackGroup.duration / 60;
    
    if (minutes >= 60) {
        unit = @"hrs"; // todo: localize
        duration = [NSString stringWithFormat:@"%u:%02u ", minutes / 60, minutes % 60];
    }
    else {
        unit = @"min"; // todo: localize
        duration = [NSString stringWithFormat:@"%u ", minutes];
    }
    
    NSAttributedString *durationText = [[NSAttributedString alloc] initWithString:duration attributes:boldAttributes];
    NSAttributedString *unitText = [[NSAttributedString alloc] initWithString:unit attributes:regularAttributes];
    
    [infoText appendAttributedString:trackCountText];
    [infoText appendAttributedString:tracksText];
    [infoText appendAttributedString:durationText];
    [infoText appendAttributedString:unitText];
    return infoText;
}

@end
