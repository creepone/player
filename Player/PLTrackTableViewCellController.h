@class PLTrack, PLTrackTableViewCell;

@interface PLTrackTableViewCellController : NSObject

+ (void)configureCell:(PLTrackTableViewCell *)cell withTrack:(PLTrack *)track selected:(BOOL)selected;

@end
