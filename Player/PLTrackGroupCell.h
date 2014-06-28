#import <UIKit/UIKit.h>

@class PLTrackGroupCellModelView;

@interface PLTrackGroupCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelArtist;
@property (strong, nonatomic) IBOutlet UILabel *labelInfo;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewAddState;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewArtwork;

- (void)setupBindings:(PLTrackGroupCellModelView *)modelView;

@end
