#import <Foundation/Foundation.h>

@protocol PLPathAsset <NSObject>

- (NSString *)path;
- (NSString *)title;
- (id<PLPathAsset>)parent;

@property (nonatomic, weak) NSArray *siblings;

- (BOOL)isRoot;
- (BOOL)isDirectory;

@end

@interface PLPathAssetSet : NSObject

+ (instancetype)set;

- (BOOL)contains:(id<PLPathAsset>)asset;
- (void)toggle:(id<PLPathAsset>)asset;
- (void)add:(id<PLPathAsset>)asset;
- (void)remove:(id<PLPathAsset>)asset;

- (NSArray *)allAssets;

@end
