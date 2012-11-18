#import <Foundation/Foundation.h>

@interface PLUtils : NSObject

+ (NSString *)documentDirectoryPath;

+ (NSString *)libraryDirectoryPath;

+ (CGFloat)roundCoordinate:(CGFloat)coordinate;

+ (NSString *)generateUuid;

@end
