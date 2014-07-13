#import <Foundation/Foundation.h>
#import "PLPathAssetSet.h"

@interface PLOneDrivePathAsset : NSObject <PLPathAsset>

- (instancetype)initWithInfo:(NSDictionary *)info parent:(PLOneDrivePathAsset *)parent;
+ (instancetype)assetWithInfo:(NSDictionary *)info parent:(PLOneDrivePathAsset *)parent;

- (NSString *)identifier;
- (NSDictionary *)info;

@end
