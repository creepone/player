#import "PLDefaultsManager.h"
#import "PLUtils.h"

@implementation PLDefaultsManager

NSString *kDataStoreVersion = @"DataStoreVersion";
NSString *kSelectedPlaylist = @"SelectedPlaylist";
NSString *kPlaybackRate = @"PlaybackRate";
NSString *kGoBackTime = @"GoBackTime";

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
        [NSNumber numberWithDouble:10.0], kGoBackTime,
        nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
}

@end