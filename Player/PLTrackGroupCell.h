#import <UIKit/UIKit.h>

@class PLTrackGroupCellViewModel;

@interface PLTrackGroupCell : UITableViewCell

- (void)setupBindings:(PLTrackGroupCellViewModel *)modelView;

@end
