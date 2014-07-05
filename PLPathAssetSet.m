#import "PLPathAssetSet.h"
#import "NSArray+PLExtensions.h"

@interface PLPathAssetSet() {
    NSMutableSet *_set;
}
@end

@implementation PLPathAssetSet

- (instancetype)init
{
    self = [super init];
    if (self) {
        _set = [NSMutableSet set];
    }
    return self;
}

+ (instancetype)set
{
    return [[self alloc] init];
}

- (BOOL)contains:(id<PLPathAsset>)asset
{
    for (id<PLPathAsset> includedPathAsset in _set) {
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
    
    [_set addObject:asset];
    
    // remove all descendants previously included
    for (id<PLPathAsset> includedPathAsset in [_set copy]) {
        if ([includedPathAsset.path hasPrefix:asset.path] && ![includedPathAsset.path isEqualToString:asset.path])
            [_set removeObject:includedPathAsset];
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
    
    if ([_set containsObject:asset]) {
        [_set removeObject:asset];
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
    return [_set allObjects];
}

@end
