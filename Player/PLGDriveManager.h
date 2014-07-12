#import <Foundation/Foundation.h>

@class RACSignal;

@interface PLGDriveManager : NSObject

+ (PLGDriveManager *)sharedManager;

- (BOOL)isLinked;
- (RACSignal *)link;
- (void)unlink;

- (NSURLRequest *)requestForPath:(NSString *)filePath;

- (RACSignal *)listFolder:(NSString *)path;

@end
