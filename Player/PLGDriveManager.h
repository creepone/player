#import <Foundation/Foundation.h>
#import "PLCloudImport.h"

@class RACSignal;

@interface PLGDriveManager : NSObject <PLCloudManager>

+ (PLGDriveManager *)sharedManager;

@end
