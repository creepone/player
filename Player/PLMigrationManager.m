#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLMigrationManager.h"
#import "PLMigrationManager+Migrations.h"
#import "PLDefaultsManager.h"
#import "PLCoreDataStack.h"
#import "PLDataAccess.h"
#import "PLUtils.h"
#import "PLErrorManager.h"

const long PLCurrentDataStoreVersion = 2;

@implementation PLMigrationManager

+ (RACSignal *)coreDataStack
{
    PLDefaultsManager *defaultsManager = [PLDefaultsManager sharedManager];
    long lastInstalledVersion = [defaultsManager dataStoreVersion];

    if (lastInstalledVersion == PLCurrentDataStoreVersion) {
        return [self coreDataStackForModelVersion:PLCurrentDataStoreVersion];
    }
    else if(lastInstalledVersion == 0) {
        return [[self coreDataStackForModelVersion:PLCurrentDataStoreVersion] flattenMap:^RACStream *(PLCoreDataStack *coreDataStack) {
            return [[[self createDefaultObjectsInContext:coreDataStack.managedObjectContext] doCompleted:^{
                [defaultsManager setDataStoreVersion:PLCurrentDataStoreVersion];
            }] concat:[RACSignal return:coreDataStack]];
        }];
    }
    
    NSMutableDictionary *migrationInfo = [NSMutableDictionary dictionary];
    [self preMigrateWithInfo:migrationInfo];

    return [[self migrateFromVersion:lastInstalledVersion] then:^RACSignal *{
        return [[self coreDataStackForModelVersion:PLCurrentDataStoreVersion] flattenMap:^RACStream *(PLCoreDataStack *coreDataStack) {
            [defaultsManager setDataStoreVersion:PLCurrentDataStoreVersion];
            [self postMigrateWithInfo:migrationInfo];
            return [RACSignal return:coreDataStack];
        }];
    }];
}

+ (RACSignal *)coreDataStackForModelVersion:(NSInteger)version
{
    NSURL *storeURL = [NSURL fileURLWithPath:[self dataStorePathVersion:version]];

    NSError *error;
    PLCoreDataStack *coreDataStack = [PLCoreDataStack coreDataStackWithStoreURL:storeURL andModel:[self modelVersion:version] error:&error];

    return error ? [RACSignal error:error] : [RACSignal return:coreDataStack];
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

+ (NSArray *)dataStorePathsVersion:(NSInteger)version
{
    NSString *sqlitePath = [self dataStorePathVersion:version];
    NSString *walPath = [sqlitePath stringByAppendingString:@"-wal"];
    NSString *shmPath = [sqlitePath stringByAppendingString:@"-shm"];
    return @[sqlitePath, walPath, shmPath];
}

+ (NSString *)dataStoreNameVersion:(NSInteger)version
{
    return [NSString stringWithFormat:@".Player%ld.sqlite", version];
}


+ (RACSignal *)createDefaultObjectsInContext:(NSManagedObjectContext *)context
{
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        PLPlaylist *playlist = [NSEntityDescription insertNewObjectForEntityForName:@"PLPlaylist" inManagedObjectContext:context];
        playlist.name = @"Default";
        playlist.position = [NSNumber numberWithInt:0];

        NSError *error;
        if (![context save:&error]) {
            [subscriber sendError:error];
            return nil;
        }

        PLDataAccess *dataAccess = [[PLDataAccess alloc] initWithContext:context];
        [dataAccess selectPlaylist:playlist];
        [subscriber sendCompleted];

        return nil;
    }];
}

+ (RACSignal *)migrateFromVersion:(NSInteger)version
{
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        return [[RACScheduler scheduler] schedule:^{

            @autoreleasepool {
                NSURL *sourceStoreURL = [NSURL fileURLWithPath:[self dataStorePathVersion:version]];
                NSURL *targetStoreURL = [NSURL fileURLWithPath:[self dataStorePathVersion:PLCurrentDataStoreVersion]];

                NSManagedObjectModel *sourceModel = [self modelVersion:version];
                NSManagedObjectModel *targetModel = [self modelVersion:PLCurrentDataStoreVersion];

                NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:targetModel];
                NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:targetModel];

                if (!mappingModel) {
                    [subscriber sendError:[PLErrorManager errorWithCode:PLErrorMappingModelNotFound description:@"Could not find the mapping model"]];
                    return;
                }

                NSError *error;
                [migrationManager migrateStoreFromURL:sourceStoreURL
                                                 type:NSSQLiteStoreType
                                              options:nil
                                     withMappingModel:mappingModel
                                     toDestinationURL:targetStoreURL
                                      destinationType:NSSQLiteStoreType
                                   destinationOptions:nil
                                                error:&error];

                if (error) {
                    [subscriber sendError:error];
                    return;
                }

                NSFileManager *fileManager = [[NSFileManager alloc] init];
                
                for (NSString *path in [self dataStorePathsVersion:version]) {
                    [fileManager removeItemAtPath:path error:&error];
                    if (error) {
                        [subscriber sendError:error];
                        return;
                    }
                }
                
                [subscriber sendCompleted];
            }
        }];

    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

@end
