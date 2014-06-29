#import "PLTrackCellViewModel.h"
#import "PLMediaItemTrack.h"
#import "PLUtils.h"

@interface PLTrackCellViewModel () {
    PLMediaItemTrack *_track;
}

@property (strong, nonatomic, readwrite) NSString *titleText;
@property (strong, nonatomic, readwrite) NSString *durationText;
@property (strong, nonatomic, readwrite) UIImage *imageAddState;
@property (assign, nonatomic, readwrite) CGFloat alpha;

@end

@implementation PLTrackCellViewModel

- (instancetype)initWithTrack:(PLMediaItemTrack *)track selected:(BOOL)selected
{
    self = [super init];
    if (self) {
        _track = track;

        self.titleText = track.title;
        self.durationText = [PLUtils formatDuration:track.duration];

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

@end
