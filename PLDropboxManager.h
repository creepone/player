#import <Foundation/Foundation.h>

@interface PLDropboxManager : NSObject

+ (PLDropboxManager *)sharedManager;

- (NSURL *)downloadURLForPath:(NSString *)filePath;

@end
