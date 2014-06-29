#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLTrackGroupCellViewModel.h"
#import "PLMediaItemTrackGroup.h"

@interface PLTrackGroupCellViewModel () {
    PLMediaItemTrackGroup *_trackGroup;
}

@property (strong, nonatomic, readwrite) UIImage *imageArtwork;
@property (strong, nonatomic, readwrite) UIImage *imageAddState;
@property (strong, nonatomic, readwrite) NSString *titleText;
@property (strong, nonatomic, readwrite) NSString *artistText;
@property (assign, nonatomic, readwrite) CGFloat alpha;

@end

@implementation PLTrackGroupCellViewModel

- (instancetype)initWithTrackGroup:(PLMediaItemTrackGroup *)trackGroup selected:(BOOL)selected
{
    self = [super init];
    if (self) {
        _trackGroup = trackGroup;

        self.artistText = trackGroup.artist;
        self.titleText = trackGroup.title;
        RAC(self, imageArtwork) = trackGroup.artwork;

        if (selected) {
            self.alpha = 0.5;
            self.imageAddState = [UIImage imageNamed:@"ButtonRemove"];
        }
        else {
            self.alpha = 1.0;
            self.imageAddState = [UIImage imageNamed:@"ButtonAdd"];
        }
    }
    return self;
}

- (NSAttributedString *)infoText
{
    NSMutableAttributedString *infoText = [[NSMutableAttributedString alloc] init];
    NSDictionary *boldAttributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:13.f] };
    NSDictionary *regularAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:13.f] };

    NSString *trackCount = [NSString stringWithFormat:@"%u ", (unsigned)_trackGroup.trackCount];
    NSAttributedString *trackCountText = [[NSAttributedString alloc] initWithString:trackCount attributes:boldAttributes];

    NSString *tracks = [NSString stringWithFormat:@"%@, ", _trackGroup.trackCount == 1 ? @"track" : @"tracks"]; // todo: localize
    NSAttributedString *tracksText = [[NSAttributedString alloc] initWithString:tracks attributes:regularAttributes];

    NSString *unit, *duration;
    int minutes = (int)_trackGroup.duration / 60;

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