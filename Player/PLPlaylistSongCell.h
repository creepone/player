#import <UIKit/UIKit.h>

@class PLPlaylistSongCellModelView;

@interface PLPlaylistSongCell : UITableViewCell

- (void)setupBindings:(PLPlaylistSongCellModelView *)modelView;

- (void)removeBindings;

@end
