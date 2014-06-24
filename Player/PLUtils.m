#import "PLUtils.h"
#import "PLErrorManager.h"

@implementation PLUtils

+ (BOOL)isNilOrNull:(NSObject *)object
{
    return !object || [[NSNull null] isEqual:object];
}

+ (void)dismissKeyboard
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

+ (NSString *)documentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;

    NSError *error;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:&error]) {
        [PLErrorManager logError:error];
    }
    
    return basePath;
}

+ (NSString *)libraryDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;

    NSError *error;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:&error]) {
        [PLErrorManager logError:error];
    }
    
    return basePath;
}

+ (NSString *)formatDuration:(NSTimeInterval)duration
{
    long min = (long)duration / 60;
    long sec = (long)duration % 60;

    if (min >= 60)
    {
        long hrs = min / 60;
        min = min % 60;

        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", hrs, min, sec];
    }

    return [NSString stringWithFormat:@"%02ld:%02ld", min, sec];
}

+ (UIImage *)launchImage
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    if (MAX(bounds.size.width, bounds.size.height) == 568.f)
        return [UIImage imageNamed:@"LaunchImage-568h"];
    else
        return [UIImage imageNamed:@"LaunchImage"];
}

+ (PLPredicate)isNotNilPredicate
{
    return ^BOOL(id value) { return value != nil; };
}

@end
