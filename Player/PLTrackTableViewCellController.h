@class PLMediaItemTrack, PLTrackTableViewCell;

@interface PLTrackTableViewCellController : NSObject

+ (void)configureCell:(PLTrackTableViewCell *)cell withTrack:(PLMediaItemTrack *)track selected:(BOOL)selected;

@end
