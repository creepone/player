#import "PLUtils.h"
#import "PLErrorManager.h"
#import <MediaPlayer/MediaPlayer.h>

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
    return [[NSString alloc] initWithFormat:@"%02ld:%02ld", min, sec];
}

+ (MPMediaItem *)mediaItemForPersistentID:(NSNumber *)persistentId
{
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:persistentId forProperty:MPMediaItemPropertyPersistentID];
    
    MPMediaQuery *songQuery = [MPMediaQuery songsQuery];
    [songQuery addFilterPredicate:predicate];
    
    NSArray *songs = [songQuery items];
    if ([songs count] > 0)
        return [songs objectAtIndex:0];
    
    MPMediaQuery *podcastQuery = [MPMediaQuery podcastsQuery];
    [podcastQuery addFilterPredicate:predicate];
    
    NSArray *podcasts = [podcastQuery items];
    if ([podcasts count] > 0)
        return [podcasts objectAtIndex:0];
    
    MPMediaQuery *audibooksQuery = [MPMediaQuery audiobooksQuery];
    [audibooksQuery addFilterPredicate:predicate];
    
    NSArray *audiobooks = [audibooksQuery items];
    if ([audiobooks count] > 0)
        return [audiobooks objectAtIndex:0];
    
    return nil;
}

@end
