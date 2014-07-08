#import <Foundation/Foundation.h>

@class DBMetadata;

@interface PLDropboxItemCellViewModel : NSObject

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) UIImage *imageIcon;
@property (strong, nonatomic, readonly) UIImage *imageAddState;
@property (assign, nonatomic, readonly) CGFloat alpha;
@property (assign, nonatomic, readonly) UITableViewCellSelectionStyle selectionStyle;

- (instancetype)initToggleWithSelected:(BOOL)selected;
- (instancetype)initWithMetadata:(DBMetadata *)metadata selected:(BOOL)selected;

@end
