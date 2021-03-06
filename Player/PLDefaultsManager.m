#import "PLDefaultsManager.h"

@implementation PLDefaultsManager

static NSString *kDataStoreVersion = @"DataStoreVersion";
static NSString *kSelectedPlaylistUuid = @"SelectedPlaylistUuid";
static NSString *kPlaybackRate = @"PlaybackRate";
static NSString *kGoBackTime = @"GoBackTime";
static NSString *kMirrorTracks = @"MirrorTracks";
static NSString *kUseCustomRemoteCommands = @"UseCustomRemoteCommands";

+ (PLDefaultsManager *)sharedManager
{
    static dispatch_once_t once;
    static PLDefaultsManager *sharedManager;
    dispatch_once(&once, ^ { sharedManager = [[self alloc] init]; });
    return sharedManager;
}

#pragma mark -- since 1.0

- (NSInteger)dataStoreVersion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];    
    return [userDefaults integerForKey:kDataStoreVersion];
}

- (void)setDataStoreVersion:(NSInteger)version
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];    
    [userDefaults setInteger:version forKey:kDataStoreVersion];
    [userDefaults synchronize];
}

- (double)playbackRate
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults doubleForKey:kPlaybackRate];
}

- (void)setPlaybackRate:(double)playbackRate
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:playbackRate forKey:kPlaybackRate];
    [userDefaults synchronize];
}

- (double)goBackTime
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults doubleForKey:kGoBackTime];
}

- (void)setGoBackTime:(double)goBackTime
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:goBackTime forKey:kGoBackTime];
    [userDefaults synchronize];
}

- (NSString *)selectedPlaylistUuid
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:kSelectedPlaylistUuid];
}

- (void)setSelectedPlaylistUuid:(NSString *)playlistUuid
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:playlistUuid forKey:kSelectedPlaylistUuid];
    [userDefaults synchronize];
}

- (BOOL)mirrorTracks
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kMirrorTracks];
}

- (void)setMirrorTracks:(BOOL)mirrorTracks
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:mirrorTracks forKey:kMirrorTracks];
    [userDefaults synchronize];
}

- (BOOL)useCustomRemoteCommands
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kUseCustomRemoteCommands];
}

- (void)setUseCustomRemoteCommands:(BOOL)useCustomRemoteCommands
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:useCustomRemoteCommands forKey:kUseCustomRemoteCommands];
    [userDefaults synchronize];
}


+ (void)registerDefaults
{
    NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:0], kDataStoreVersion,
        [NSNumber numberWithDouble:1.0], kPlaybackRate,
        [NSNumber numberWithDouble:30.0], kGoBackTime,
        nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
}

@end
