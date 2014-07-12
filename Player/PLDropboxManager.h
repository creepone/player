#import <Foundation/Foundation.h>
#import "PLDownloadProvider.h"

extern NSString * const PLDropboxURLHandledNotification;

@class RACSignal;

@interface PLDropboxManager : NSObject <PLDownloadProvider>

+ (PLDropboxManager *)sharedManager;

- (BOOL)isLinked;
- (RACSignal *)link;
- (void)unlink;

- (RACSignal *)listFolder:(NSString *)path;

@end
