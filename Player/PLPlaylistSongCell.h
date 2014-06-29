#import <UIKit/UIKit.h>

@class PLPlaylistSongCellViewModel;

@interface PLPlaylistSongCell : UITableViewCell

- (void)setupBindings:(PLPlaylistSongCellViewModel *)modelView;

@end
