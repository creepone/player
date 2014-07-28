#import "PLCloudItemCellViewModel.h"
#import "PLPathAssetSet.h"

@interface PLCloudItemCellViewModel() {
    id<PLPathAsset> _asset;
}

@property (strong, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic, readwrite) UIImage *imageIcon;
@property (strong, nonatomic, readwrite) UIImage *imageAddState;
@property (assign, nonatomic, readwrite) CGFloat alpha;
@property (assign, nonatomic, readwrite) UITableViewCellSelectionStyle selectionStyle;

@end

@implementation PLCloudItemCellViewModel

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

- (instancetype)initWithAsset:(id<PLPathAsset>)asset selected:(BOOL)selected
{
    self = [super init];
    if (self) {
        _asset = asset;
        
        self.name = asset.fileName;
        self.alpha = selected ? 0.5f : 1.f;
        
        if (asset.isDirectory) {
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
