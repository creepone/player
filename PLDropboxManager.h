#import <Foundation/Foundation.h>

extern NSString * const PLDropboxURLHandledNotification;

@interface PLDropboxManager : NSObject

+ (PLDropboxManager *)sharedManager;

- (BOOL)ensureLinked;
- (void)unlink;

- (NSURL *)downloadURLForPath:(NSString *)filePath;

- (RACSignal *)listFolder:(NSString *)path;

@end
