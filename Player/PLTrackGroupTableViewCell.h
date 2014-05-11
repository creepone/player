#import <UIKit/UIKit.h>

@interface PLTrackGroupTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelArtist;
@property (strong, nonatomic) IBOutlet UILabel *labelInfo;
@property (strong, nonatomic) UIImage *imageArtwork;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewAddState;

@end
