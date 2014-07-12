#import <Foundation/Foundation.h>

@protocol PLPathAsset;

@interface PLCloudItemCellViewModel : NSObject

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) UIImage *imageIcon;
@property (strong, nonatomic, readonly) UIImage *imageAddState;
@property (assign, nonatomic, readonly) CGFloat alpha;
@property (assign, nonatomic, readonly) UITableViewCellSelectionStyle selectionStyle;

- (instancetype)initToggleWithSelected:(BOOL)selected;
- (instancetype)initWithAsset:(id<PLPathAsset>)asset selected:(BOOL)selected;

@end
