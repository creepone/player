#import <Foundation/Foundation.h>

@interface PLDefaultsManager : NSObject

/**
 Version of the data store used to ensure that it is compatible with the model and was
 initialized with a default set of objects
 */
+ (NSInteger)dataStoreVersion;
+ (void)setDataStoreVersion:(NSInteger)version;


+ (NSString *)preferencesPath;
+ (NSString *)preferencesName;

+ (void)mergeWithDictionary:(NSDictionary *)defaults;

/**
 Registers default values for all the settings. To be called on application startup.
 */
+ (void)registerDefaults;

@end
