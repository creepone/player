#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLFileSharingViewModel.h"
#import "PLServiceContainer.h"
#import "PLFileSharingManager.h"
#import "PLFileSharingCellViewModel.h"
#import "PLErrorManager.h"
#import "PLFileSharingItem.h"
#import "NSArray+PLExtensions.h"

@interface PLFileSharingViewModel() {
    NSMutableArray *_selection;
    id<PLFileSharingManager> _fileSharingManager;
}

@property (nonatomic, strong) NSArray *items;

@end

@implementation PLFileSharingViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fileSharingManager = PLResolve(PLFileSharingManager);
        _selection = [NSMutableArray array];
        [self loadItems];
    }
    return self;
}


- (void)loadItems
{
    self.loading = YES;
    
    @weakify(self);
    [[_fileSharingManager allImportableItems] subscribeNext:^(NSArray *items) { @strongify(self);
        if (!self) return;
        self.items = items;
        self.loading = NO;
    }
    error:^(NSError *error) {
      [PLErrorManager logError:error];
      self.loading = NO;
    }];
}

- (NSArray *)selection
{
    return _selection;
}


- (NSString *)cellIdentifier
{
    if (self.loading)
        return nil;
    
    if ([self.items count] == 0)
        return @"emptyCell";
    
    return @"fileSharingCell";
}

- (CGFloat)cellHeight
{
    if (self.loading)
        return 0;
    
    if ([self.items count] == 0)
        return 94.f;
    
    return 44.f;
}

- (NSUInteger)cellsCount
{
    if (self.loading)
        return 0;
    
    NSUInteger itemsCount = [self.items count];
    return itemsCount > 0 ? itemsCount + 1 : 1;
}

- (PLFileSharingCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return [[PLFileSharingCellViewModel alloc] initToggleWithSelected:[self isAllSelected]];
    
    PLFileSharingItem *item = self.items[indexPath.row - 1];
    return [[PLFileSharingCellViewModel alloc] initWithTitle:item.title selected:[self isSelected:item]];
}

- (void)toggleSelectAt:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        BOOL wasAllSelected = [self isAllSelected];
        [_selection removeAllObjects];
        
        if (!wasAllSelected)
            [_selection addObjectsFromArray:self.items];
        return;
    }
    
    PLFileSharingItem *item = self.items[indexPath.row - 1];
    if ([self isSelected:item])
        [_selection removeObject:item];
    else
        [_selection addObject:item];
}

- (BOOL)isAllSelected
{
    return [_selection count] == [self.items count];
}

- (BOOL)isSelected:(PLFileSharingItem *)item
{
    return [_selection containsObject:item];
}


@end
