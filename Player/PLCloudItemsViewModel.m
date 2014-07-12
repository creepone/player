#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLCloudItemsViewModel.h"
#import "PLCloudItemCellViewModel.h"
#import "PLErrorManager.h"
#import "PLCloudImport.h"
#import "PLDropboxPathAsset.h"
#import "NSArray+PLExtensions.h"

@interface PLCloudItemsViewModel() {
    RACSubject *_navigationSubject;
    PLPathAssetSet *_selection;
    id <PLPathAsset> _parent;
    id <PLCloudManager> _cloudManager;
}

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong, readwrite) NSString *title;

@end

@implementation PLCloudItemsViewModel

- (instancetype)initWithCloudManager:(id <PLCloudManager>)cloudManager
{
    return [self initWithCloudManager:cloudManager selection:[PLPathAssetSet set] parent:cloudManager.rootAsset];
}

- (instancetype)initWithCloudManager:(id<PLCloudManager>)cloudManager selection:(PLPathAssetSet *)selection parent:(PLDropboxPathAsset *)parent
{
    self = [super init];
    if (self) {
        _cloudManager = cloudManager;
        _selection = selection;
        _parent = parent;
        
        _navigationSubject = [RACSubject subject];
        
        self.title = _parent.isRoot ? @"Add to playlist" : _parent.title; // todo: localize
        
        [self loadItems];
    }
    return self;
}

- (void)loadItems
{
    self.loading = YES;
    
    @weakify(self);
    [[_cloudManager loadChildren:_parent] subscribeNext:^(NSArray *items) { @strongify(self);
        if (!self) return;
        
        self.items = items;
        
        for (id<PLPathAsset> asset in self.items) {
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


- (NSUInteger)cellsCount
{
    if (self.loading)
        return 0;
    
    NSUInteger itemsCount = [self.items count];
    return itemsCount > 0 ? itemsCount + 1 : 1;
}

- (BOOL)useEmptyCell
{
    return !self.loading && [self.items count] == 0;
}

- (PLCloudItemCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return [[PLCloudItemCellViewModel alloc] initToggleWithSelected:[_selection contains:_parent]];
    
    id<PLPathAsset> asset = (id<PLPathAsset>)self.items[indexPath.row - 1];
    return [[PLCloudItemCellViewModel alloc] initWithAsset:asset selected:[_selection contains:asset]];
}

- (void)toggleSelectAt:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [_selection toggle:_parent];
        return;
    }
    
    id<PLPathAsset> asset = (id<PLPathAsset>)self.items[indexPath.row - 1];

    if (asset.isDirectory) {
        PLCloudItemsViewModel *viewModel = [[PLCloudItemsViewModel alloc] initWithCloudManager:_cloudManager selection:_selection parent:asset];
        [_navigationSubject sendNext:viewModel];
    }
    else {
        [_selection toggle:asset];
    }
}

- (RACSignal *)navigationSignal
{
    return _navigationSubject;
}

@end
