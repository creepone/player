#import <Foundation/Foundation.h>

@interface PLFileSharingCellViewModel : NSObject

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) UIImage *imageIcon;
@property (strong, nonatomic, readonly) UIImage *imageAddState;
@property (assign, nonatomic, readonly) CGFloat alpha;

- (instancetype)initToggleWithSelected:(BOOL)selected;
- (instancetype)initWithTitle:(NSString *)title selected:(BOOL)selected;

@end
