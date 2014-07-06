#import <Foundation/Foundation.h>
#import "PLPathAssetSet.h"

@interface PLDropboxPathAsset : NSObject <PLPathAsset>

- (instancetype)initWithMetadata:(DBMetadata *)metadata parent:(PLDropboxPathAsset *)parent;
+ (instancetype)assetWithMetadata:(DBMetadata *)metadata parent:(PLDropboxPathAsset *)parent;

- (DBMetadata *)metadata;

@property (nonatomic, weak) NSArray *siblings;

@end
