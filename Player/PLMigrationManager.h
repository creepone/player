#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RACSignal;

extern const long PLCurrentDataStoreVersion;

@interface PLMigrationManager : NSObject

/**
 Delivers the current (latest) version of the managed object model
 */
+ (NSManagedObjectModel *)currentModel;

/**
 Delivers managed object model that was used with the specific version of the data store
 */
+ (NSManagedObjectModel *)modelVersion:(NSInteger)version;

/**
 Delivers the physical path to the sqlite file for the specific version of the data store. 
 Usually the data stores of previous versions are removed, so they won't be all available at the same time.
 */
+ (NSString *)dataStorePathVersion:(NSInteger)version;

/**
 Delivers the physical path to the sqlite, wal and shm files for the specific version of the data store.
 Usually the data stores of previous versions are removed, so they won't be all available at the same time.
 */
+ (NSArray *)dataStorePathsVersion:(NSInteger)version;

/**
 Returns a signal that delivers a core data stack ready to be used by the application, then completes.
 It takes care about ensuring that it uses the latest model and migrates the persistent data store if necessary.
 In case the data store doesn't exist, it is created and filled with default set of objects.
 */
+ (RACSignal *)coreDataStack;

/**
 Returns a signal that delivers a core data stack from a specific version of the model, then completes.
 The data store must exist in this version as no migration or initialization will be performed.
 */
+ (RACSignal *)coreDataStackForModelVersion:(NSInteger)version;

@end