#import <Foundation/Foundation.h>
#import "PLPathAssetSet.h"

@class GTLDriveFile;

@interface PLGDrivePathAsset : NSObject <PLPathAsset>

- (instancetype)initWithDriveFile:(GTLDriveFile *)driveFile parent:(PLGDrivePathAsset *)parent;
+ (instancetype)assetWithDriveFile:(GTLDriveFile *)driveFile parent:(PLGDrivePathAsset *)parent;

- (NSString *)identifier;
- (GTLDriveFile *)driveFile;

@end
