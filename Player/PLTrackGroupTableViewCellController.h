@class PLMediaItemTrackGroup, PLTrackGroupTableViewCell;

@interface PLTrackGroupTableViewCellController : NSObject

+ (void)configureCell:(PLTrackGroupTableViewCell *)cell withTrackGroup:(PLMediaItemTrackGroup *)trackGroup;
+ (void)configureCell:(PLTrackGroupTableViewCell *)cell withTrackGroup:(PLMediaItemTrackGroup *)trackGroup selected:(BOOL)selected;

@end
