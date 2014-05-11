@class PLTrackGroup, PLTrackGroupTableViewCell;

@interface PLTrackGroupTableViewCellController : NSObject

+ (void)configureCell:(PLTrackGroupTableViewCell *)cell withTrackGroup:(PLTrackGroup *)trackGroup;
+ (void)configureCell:(PLTrackGroupTableViewCell *)cell withTrackGroup:(PLTrackGroup *)trackGroup selected:(BOOL)selected;

@end
