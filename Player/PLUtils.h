@class MPMediaItem;

@interface PLUtils : NSObject

/**
 Returns YES if the given object is either nil or equal to [NSNull null].
 */
+ (BOOL)isNilOrNull:(NSObject *)object;

/**
 Attempts to dismiss keyboard if being shown currently.
 */
+ (void)dismissKeyboard;

+ (NSString *)documentDirectoryPath;

+ (NSString *)libraryDirectoryPath;

+ (NSString *)formatDuration:(NSTimeInterval)duration;

@end
