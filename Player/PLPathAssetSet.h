#import <Foundation/Foundation.h>

@protocol PLPathAsset <NSObject>

/**
 Represents a logical path of the asset. This does not have to correspond to any file system path, but
 it has to have the property that a child's path has the parent's path as a prefix.
 */
- (NSString *)path;

/**
 The file name of the asset. Used for the actual physical file when it gets downloaded and created locally.
 */
- (NSString *)fileName;

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
