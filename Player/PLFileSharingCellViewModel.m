#import "PLFileSharingCellViewModel.h"

@interface PLFileSharingCellViewModel()

@property (strong, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic, readwrite) UIImage *imageIcon;
@property (strong, nonatomic, readwrite) UIImage *imageAddState;
@property (assign, nonatomic, readwrite) CGFloat alpha;

@end

@implementation PLFileSharingCellViewModel

- (instancetype)initToggleWithSelected:(BOOL)selected
{
    self = [super init];
    if (self) {
        self.name = selected ? @"Deselect all" : @"Select all"; // todo: localize
        self.imageIcon = [UIImage imageNamed:@"FolderOpenIcon"];
        self.imageAddState = selected ? [UIImage imageNamed:@"ButtonRemove"] : [UIImage imageNamed:@"ButtonAdd"];
        self.alpha = selected ? 0.5f : 1.f;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title selected:(BOOL)selected
{
    self = [super init];
    if (self) {
        self.name = title;
        self.alpha = selected ? 0.5f : 1.f;
        self.imageIcon = [UIImage imageNamed:@"FileIcon"];
        self.imageAddState = selected ? [UIImage imageNamed:@"ButtonRemove"] : [UIImage imageNamed:@"ButtonAdd"];
    }
    return self;
}

@end
