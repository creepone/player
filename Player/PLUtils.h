#import <Foundation/Foundation.h>

@class MPMediaItem;

@interface PLUtils : NSObject

+ (NSString *)documentDirectoryPath;

+ (NSString *)libraryDirectoryPath;

+ (CGFloat)roundCoordinate:(CGFloat)coordinate;

+ (NSString *)generateUuid;

+ (NSString *)formatDuration:(NSTimeInterval)duration;

+ (MPMediaItem *)mediaItemForPersistentID:(NSNumber *)persistentId;

@end
