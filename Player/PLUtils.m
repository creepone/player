#import "PLUtils.h"

@implementation PLUtils

+ (NSString *)documentDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL]) {
        NSLog(@"Error: Create documents folder failed %@", basePath);
    }
    
    return basePath;
}

+ (NSString *)libraryDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL]) {
        NSLog(@"Error: Create library folder failed %@", basePath);
    }
    
    return basePath;
}

+ (CGFloat)roundCoordinate:(CGFloat)coordinate {
    CGFloat scale = [[UIScreen mainScreen] scale];
    return round(coordinate * scale) / scale;
}

+ (NSString *)generateUuid {
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
        
    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}

+ (NSString *)formatDuration:(NSTimeInterval)duration {    
    long min = (long)duration / 60;
    long sec = (long)duration % 60;
    return [[NSString alloc] initWithFormat:@"%02ld:%02ld", min, sec];
}

@end
