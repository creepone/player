#import "PLPathAssetSet.h"

@interface PLPathAssetSet() {
    NSMutableArray *_assets;
}
@end

@implementation PLPathAssetSet

- (instancetype)init
{
    self = [super init];
    if (self) {
        _assets = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)set
{
    return [[self alloc] init];
}

- (BOOL)contains:(id<PLPathAsset>)asset
{
    for (id<PLPathAsset> includedPathAsset in _assets) {
        if ([asset.path hasPrefix:includedPathAsset.path])
            return YES;
    }
        
    return NO;
}

- (void)toggle:(id<PLPathAsset>)asset
{
    if ([self contains:asset])
        [self remove:asset];
    else
        [self add:asset];
}

- (void)add:(id<PLPathAsset>)asset
{
    if ([self contains:asset])
        return;
    
    [_assets addObject:asset];
    
    // remove all descendants previously included
    for (id<PLPathAsset> includedPathAsset in [_assets copy]) {
        if ([includedPathAsset.path hasPrefix:asset.path] && ![includedPathAsset.path isEqualToString:asset.path])
            [_assets removeObject:includedPathAsset];
    }
    
    if (asset.parent != nil) {
        BOOL allSelected = YES;
        for (id<PLPathAsset> sibling in asset.siblings) {
            if (![self contains:sibling]) {
                allSelected = NO;
            }
        }
        
        if (allSelected)
            [self add:[asset parent]];
    }
}

- (void)remove:(id<PLPathAsset>)asset
{
    if (![self contains:asset])
        return;
    
    if ([_assets containsObject:asset]) {
        [_assets removeObject:asset];
        return;
    }
    
    if (asset.parent != nil) {
        // remove the parent recursively first
        [self remove:[asset parent]];
        
        // add all the other siblings
        for (id<PLPathAsset> sibling in asset.siblings) {
            if (sibling != asset)
                [self add:sibling];
        }
    }
}

- (NSArray *)allAssets
{
    return _assets;
}

@end
