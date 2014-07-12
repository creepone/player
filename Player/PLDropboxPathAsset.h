#import <Foundation/Foundation.h>
#import "PLPathAssetSet.h"

@class DBMetadata, PLDropboxPathAsset;

@interface PLDropboxPathAsset : NSObject <PLPathAsset>

- (instancetype)initWithMetadata:(DBMetadata *)metadata parent:(PLDropboxPathAsset *)parent;
+ (instancetype)assetWithMetadata:(DBMetadata *)metadata parent:(PLDropboxPathAsset *)parent;

@end
