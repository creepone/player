@class PLMediaItemTrack, PLTrackCell;

@interface PLTrackTableViewCellController : NSObject

+ (void)configureCell:(PLTrackCell *)cell withTrack:(PLMediaItemTrack *)track selected:(BOOL)selected;

@end
