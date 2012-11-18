#import <UIKit/UIKit.h>


@interface SliderCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UISlider *slider;
@property (nonatomic, strong) IBOutlet UILabel *labelTitle;
@property (nonatomic, strong) IBOutlet UILabel *labelValue;

@end
