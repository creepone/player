#import <Foundation/Foundation.h>

@protocol PLPathAsset <NSObject>

- (NSString *)path;
- (id<PLPathAsset>)parent;
- (NSArray *)siblings;

@end

@interface PLPathAssetSet : NSObject

+ (instancetype)set;

- (BOOL)contains:(id<PLPathAsset>)asset;
- (void)toggle:(id<PLPathAsset>)asset;
- (void)add:(id<PLPathAsset>)asset;
- (void)remove:(id<PLPathAsset>)asset;

- (NSArray *)allAssets;

@end
