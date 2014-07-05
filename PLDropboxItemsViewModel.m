#import <ReactiveCocoa/ReactiveCocoa.h>
#import <DropboxSDK/DropboxSDK.h>
#import "PLDropboxItemsViewModel.h"
#import "PLDropboxItemCellViewModel.h"
#import "PLDropboxManager.h"
#import "PLErrorManager.h"
#import "PLDropboxPathAsset.h"
#import "NSArray+PLExtensions.h"

@interface PLDropboxItemsViewModel() {
    RACSubject *_navigationSubject;
    PLPathAssetSet *_selection;
    PLDropboxPathAsset *_parent;
}

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong, readwrite) NSString *title;

@end

@implementation PLDropboxItemsViewModel

- (instancetype)init
{
    PLDropboxPathAsset *rootAsset = [PLDropboxPathAsset assetWithMetadata:nil parent:nil];
    return [self initWithSelection:[PLPathAssetSet set] parent:rootAsset];
}

- (instancetype)initWithSelection:(PLPathAssetSet *)selection parent:(PLDropboxPathAsset *)parent
{
    self = [super init];
    if (self) {
        _selection = selection;
        _parent = parent;
        
        _navigationSubject = [RACSubject subject];
        
        self.title = _parent.metadata == nil ? @"Add to playlist" : [_parent.path lastPathComponent]; // todo: localize
        
        [self loadItems];
    }
    return self;
}

- (void)loadItems
{
    self.loading = YES;
    
    @weakify(self);
    [[[PLDropboxManager sharedManager] listFolder:_parent.path] subscribeNext:^(NSArray *items) { @strongify(self);
        if (!self)
            return;
        
        self.items = [items pl_map:^id(DBMetadata *metadata) {
            return [PLDropboxPathAsset assetWithMetadata:metadata parent:self->_parent];
        }];
        
        for (PLDropboxPathAsset *asset in self.items) {
            asset.siblings = self.items;
        }
        
        self.loading = NO;
    }
    error:^(NSError *error) {
        [PLErrorManager logError:error];
    }];
}

- (PLPathAssetSet *)selection
{
    return _selection;
}


- (NSUInteger)itemsCount
{
    NSUInteger itemsCount = [self.items count];
    return itemsCount > 0 ? itemsCount + 1 : 0;
}

- (PLDropboxItemCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return [[PLDropboxItemCellViewModel alloc] initToggleWithSelected:[_selection contains:_parent]];
    
    PLDropboxPathAsset *item = (PLDropboxPathAsset *)self.items[indexPath.row - 1];
    return [[PLDropboxItemCellViewModel alloc] initWithMetadata:item.metadata selected:[_selection contains:item]];
}

- (void)toggleSelectAt:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [_selection toggle:_parent];
        return;
    }
    
    PLDropboxPathAsset *item = (PLDropboxPathAsset *)self.items[indexPath.row - 1];

    if (item.metadata.isDirectory) {
        PLDropboxItemsViewModel *viewModel = [[PLDropboxItemsViewModel alloc] initWithSelection:_selection parent:item];
        [_navigationSubject sendNext:viewModel];
    }
    else {
        [_selection toggle:item];
    }
}

- (RACSignal *)navigationSignal
{
    return _navigationSubject;
}

@end
