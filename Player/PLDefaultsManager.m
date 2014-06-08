#import "PLDefaultsManager.h"
#import "PLUtils.h"

@implementation PLDefaultsManager

static NSString *kDataStoreVersion = @"DataStoreVersion";
static NSString *kSelectedPlaylist = @"SelectedPlaylist";
static NSString *kBookmarkPlaylist = @"BookmarkPlaylist";
static NSString *kPlaybackRate = @"PlaybackRate";
static NSString *kGoBackTime = @"GoBackTime";
static NSString *kMirrorTracks = @"MirrorTracks";
static NSString *kShouldRemoveUnusedTracks = @"ShouldRemoveUnusedTracks";

#pragma mark -- since 1.0

+ (NSInteger)dataStoreVersion {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];    
    return [userDefaults integerForKey:kDataStoreVersion];
}

+ (void)setDataStoreVersion:(NSInteger)version {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];    
    [userDefaults setInteger:version forKey:kDataStoreVersion];
    [userDefaults synchronize];
}

+ (double)playbackRate {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults doubleForKey:kPlaybackRate];
}

+ (void)setPlaybackRate:(double)playbackRate {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:playbackRate forKey:kPlaybackRate];
    [userDefaults synchronize];
}

+ (double)goBackTime {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults doubleForKey:kGoBackTime];
}

+ (void)setGoBackTime:(double)goBackTime {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:goBackTime forKey:kGoBackTime];
    [userDefaults synchronize];
}

+ (NSURL *)selectedPlaylist {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults URLForKey:kSelectedPlaylist];
}

+ (void)setSelectedPlaylist:(NSURL *)playlist {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setURL:playlist forKey:kSelectedPlaylist];
    [userDefaults synchronize];
}

+ (NSURL *)bookmarkPlaylist {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults URLForKey:kBookmarkPlaylist];
}

+ (void)setBookmarkPlaylist:(NSURL *)playlist {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setURL:playlist forKey:kBookmarkPlaylist];
    [userDefaults synchronize];
}


+ (BOOL)mirrorTracks
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kMirrorTracks];
}

+ (void)setMirrorTracks:(BOOL)mirrorTracks
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:mirrorTracks forKey:kMirrorTracks];
    [userDefaults synchronize];
}

+ (BOOL)shouldRemoveUnusedTracks
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kShouldRemoveUnusedTracks];
}

+ (void)setShouldRemoveUnusedTracks:(BOOL)shouldRemoveUnusedTracks
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:shouldRemoveUnusedTracks forKey:kShouldRemoveUnusedTracks];
    [userDefaults synchronize];
}


+ (NSString *)preferencesPath {
    return [[PLUtils libraryDirectoryPath] stringByAppendingPathComponent:@"Preferences/at.iosapps.Player.plist"];
}

+ (NSString *)preferencesName {
    return @"at.iosapps.Player.plist";
}

+ (void)mergeWithDictionary:(NSDictionary *)defaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];    

    for(NSString *key in defaults.keyEnumerator) {
        [userDefaults setObject:[defaults objectForKey:key] forKey:key];
    }
    
    [userDefaults synchronize];
}

+ (void)registerDefaults {
    NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:0], kDataStoreVersion,
        [NSNumber numberWithDouble:1.0], kPlaybackRate,
        [NSNumber numberWithDouble:30.0], kGoBackTime,
        nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
}

@end
