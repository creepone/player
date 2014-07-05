#import <DropboxSDK/DropboxSDK.h>
#import "PLDropboxItemCellViewModel.h"

@interface PLDropboxItemCellViewModel() {
    DBMetadata *_metadata;
}

@property (strong, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic, readwrite) UIImage *imageIcon;
@property (strong, nonatomic, readwrite) UIImage *imageAddState;
@property (assign, nonatomic, readwrite) CGFloat alpha;
@property (assign, nonatomic, readwrite) UITableViewCellSelectionStyle selectionStyle;

@end

@implementation PLDropboxItemCellViewModel

- (instancetype)initToggleWithSelected:(BOOL)selected
{
    self = [super init];
    if (self) {
        self.name = selected ? @"Deselect all" : @"Select all"; // todo: localize
        self.imageIcon = [UIImage imageNamed:@"FolderOpenIcon"];
        self.imageAddState = selected ? [UIImage imageNamed:@"ButtonRemove"] : [UIImage imageNamed:@"ButtonAdd"];
        self.alpha = selected ? 0.5f : 1.f;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (instancetype)initWithMetadata:(DBMetadata *)metadata selected:(BOOL)selected
{
    self = [super init];
    if (self) {
        _metadata = metadata;
        
        self.name = [[metadata path] lastPathComponent];
        self.alpha = selected ? 0.5f : 1.f;
        
        if (metadata.isDirectory) {
            self.imageIcon = [UIImage imageNamed:@"FolderIcon"];
            self.imageAddState = nil;
            self.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        else {
            self.imageIcon = [UIImage imageNamed:@"FileIcon"];
            self.imageAddState = selected ? [UIImage imageNamed:@"ButtonRemove"] : [UIImage imageNamed:@"ButtonAdd"];
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    return self;
}

@end
