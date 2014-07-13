#import <Foundation/Foundation.h>
#import "PLCloudImport.h"

@interface PLOneDriveManager : NSObject <PLCloudManager>

+ (PLOneDriveManager *)sharedManager;

@end
