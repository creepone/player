#import <RXPromise.h>
#import "PLMigrationManager.h"
#import "PLDefaultsManager.h"
#import "PLCoreDataStack.h"
#import "PLDataAccess.h"
#import "PLUtils.h"
#import "RXPromise+PLExtensions.h"
#import "PLErrorManager.h"

long PLCurrentDataStoreVersion = 1;

@implementation PLMigrationManager

+ (RXPromise *)coreDataStack
{
    PLDefaultsManager *defaultsManager = [PLDefaultsManager sharedManager];
    long lastInstalledVersion = [defaultsManager dataStoreVersion];

    if (lastInstalledVersion == PLCurrentDataStoreVersion) {
        return [self coreDataStackForModelVersion:PLCurrentDataStoreVersion];
    }
    else if(lastInstalledVersion == 0) {
        return [self coreDataStackForModelVersion:PLCurrentDataStoreVersion].thenOnMain(^(PLCoreDataStack *coreDataStack) {
            return [self createDefaultObjectsInContext:coreDataStack.managedObjectContext].thenOnMain(^(id result) {
                [defaultsManager setDataStoreVersion:PLCurrentDataStoreVersion];
                return coreDataStack;
            }, nil);
        }, nil);
    }

    return [self migrateFromVersion:lastInstalledVersion].thenOnMain(^(id result) {
        return [self coreDataStackForModelVersion:PLCurrentDataStoreVersion].thenOnMain(^(PLCoreDataStack *coreDataStack) {
            [defaultsManager setDataStoreVersion:PLCurrentDataStoreVersion];
            return coreDataStack;
        }, nil);
    }, nil);
}

+ (RXPromise *)coreDataStackForModelVersion:(NSInteger)version
{
    NSURL *storeURL = [NSURL fileURLWithPath:[self dataStorePathVersion:version]];    

    NSError *error;
    PLCoreDataStack *coreDataStack = [PLCoreDataStack coreDataStackWithStoreURL:storeURL andModel:[self modelVersion:version] error:&error];
    return [RXPromise promiseWithResult:(error ? : coreDataStack)];
}

+ (NSManagedObjectModel *)currentModel
{
    NSString *momdPath = [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"];
    NSURL *momdURL = [NSURL fileURLWithPath:momdPath];
    
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:momdURL];
}

+ (NSManagedObjectModel *)modelVersion:(NSInteger)version
{
    if(version == PLCurrentDataStoreVersion) {
        return [self currentModel];
    }
    else {
        NSString *momdPath = [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"];
        NSString *resourceSubpath = [momdPath lastPathComponent];
        
        NSString *momName = version == 1 ? @"Model" : [NSString stringWithFormat:@"Model %ld", version];
        NSString *momPath = [[NSBundle mainBundle] pathForResource:momName ofType:@"mom" inDirectory:resourceSubpath];
        NSURL *momURL = [NSURL fileURLWithPath:momPath];
        
        return [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    }
}

+ (NSString *)dataStorePathVersion:(NSInteger)version
{
    NSString *sqliteName = [self dataStoreNameVersion:version];
    return [[PLUtils documentDirectoryPath] stringByAppendingPathComponent:sqliteName];
}

+ (NSString *)dataStoreNameVersion:(NSInteger)version
{
    return [NSString stringWithFormat:@".Player%ld.sqlite", version];
}


+ (RXPromise *)createDefaultObjectsInContext:(NSManagedObjectContext *)context
{
    PLPlaylist *playlist = [NSEntityDescription insertNewObjectForEntityForName:@"PLPlaylist" inManagedObjectContext:context];
    playlist.name = @"Default";
    playlist.position = [NSNumber numberWithInt:0];
    
    NSError *error;
    if (![context save:&error])
        return [RXPromise promiseWithResult:error];
    
    PLDataAccess *dataAccess = [[PLDataAccess alloc] initWithContext:context];
    [dataAccess selectPlaylist:playlist];
    return [RXPromise promiseWithResult:nil];
}

+ (RXPromise *)migrateFromVersion:(NSInteger)version
{
    return [RXPromise pl_runInBackground:^{

        @autoreleasepool {
            NSURL *sourceStoreURL = [NSURL fileURLWithPath:[self dataStorePathVersion:version]];
            NSURL *targetStoreURL = [NSURL fileURLWithPath:[self dataStorePathVersion:PLCurrentDataStoreVersion]];

            NSManagedObjectModel *sourceModel = [self modelVersion:version];
            NSManagedObjectModel *targetModel = [self modelVersion:PLCurrentDataStoreVersion];

            NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:targetModel];
            NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:targetModel];

            if (!mappingModel)
                return [PLErrorManager errorWithCode:PLErrorMappingModelNotFound description:@"Could not find the mapping model"];

            NSError *error;
            [migrationManager migrateStoreFromURL:sourceStoreURL
                                             type:NSSQLiteStoreType
                                          options:nil
                                 withMappingModel:mappingModel
                                 toDestinationURL:targetStoreURL
                                  destinationType:NSSQLiteStoreType
                               destinationOptions:nil
                                            error:&error];

            if (error)
                return error;

            NSFileManager *fileManager = [[NSFileManager alloc] init];
            [fileManager removeItemAtPath:[self dataStorePathVersion:version] error:&error];

            return error;
        }
    }];
}

@end
