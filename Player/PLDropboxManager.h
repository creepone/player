#import <Foundation/Foundation.h>

extern NSString * const PLDropboxURLHandledNotification;

@interface PLDropboxManager : NSObject

+ (PLDropboxManager *)sharedManager;

- (BOOL)isLinked;
- (BOOL)ensureLinked;
- (void)unlink;

- (NSURLRequest *)requestForPath:(NSString *)filePath;

- (RACSignal *)listFolder:(NSString *)path;

@end
