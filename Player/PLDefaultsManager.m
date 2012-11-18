#import "PLDefaultsManager.h"
#import "PLUtils.h"

@implementation PLDefaultsManager

NSString *kDataStoreVersion = @"DataStoreVersion";

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
        nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
}

@end
