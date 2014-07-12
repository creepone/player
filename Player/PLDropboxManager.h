#import <Foundation/Foundation.h>
#import "PLCloudImport.h"

extern NSString * const PLDropboxURLHandledNotification;

@interface PLDropboxManager : NSObject <PLCloudManager>

+ (PLDropboxManager *)sharedManager;

@end
