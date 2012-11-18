#import "PLMigrationManager.h"
#import "PLDefaultsManager.h"
#import "PLCoreDataStack.h"
#import "PLDataAccess.h"
#import "PLUtils.h"

@interface PLMigrationManager()

+ (BOOL)createDefaultObjectsInContext:(NSManagedObjectContext *)context error:(NSError **)error;
+ (BOOL)migrateFromVersion:(NSInteger)version error:(NSError **)error;
+ (BOOL)postMigrationVersion:(NSInteger)version inContext:(NSManagedObjectContext *)context error:(NSError **)error;

@end

@implementation PLMigrationManager

+ (PLCoreDataStack *)coreDataStack:(NSError **)error {
    int lastInstalledVersion = [PLDefaultsManager dataStoreVersion];
    PLCoreDataStack *result;

    if(lastInstalledVersion == PLCurrentDataStoreVersion) {
        return [self coreDataStackForModelVersion:PLCurrentDataStoreVersion error:error];
    }
    else if(lastInstalledVersion == 0) {
        result = [self coreDataStackForModelVersion:PLCurrentDataStoreVersion error:error];
        
        if(*error != nil)
            return nil;
        
        [self createDefaultObjectsInContext:result.managedObjectContext error:error];
        
        if(*error != nil)
            return nil;
    }
    else {
        [self migrateFromVersion:lastInstalledVersion error:error];
        
        if(*error != nil)
            return nil;
        
        result = [self coreDataStackForModelVersion:PLCurrentDataStoreVersion error:error];
        
        if(*error != nil)
            return nil;
        
        [self postMigrationVersion:lastInstalledVersion inContext:result.managedObjectContext error:error];
        
        if(*error != nil)
            return nil;
    }

    [PLDefaultsManager setDataStoreVersion:PLCurrentDataStoreVersion];
    return result;
}

+ (PLCoreDataStack *)coreDataStackForModelVersion:(NSInteger)version error:(NSError **)error {
    NSURL *storeURL = [NSURL fileURLWithPath:[self dataStorePathVersion:version]];    
    return [PLCoreDataStack coreDataStackWithStoreURL:storeURL andModel:[self modelVersion:version] error:error];
}

+ (NSManagedObjectModel *)currentModel {
    NSString *momdPath = [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"];
    NSURL *momdURL = [NSURL fileURLWithPath:momdPath];
    
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:momdURL];
}

+ (NSManagedObjectModel *)modelVersion:(NSInteger)version {
    if(version == PLCurrentDataStoreVersion) {
        return [self currentModel];
    }
    else {
        NSString *momdPath = [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"];
        NSString *resourceSubpath = [momdPath lastPathComponent];
        
        NSString *momName = version == 1 ? @"Model" : [NSString stringWithFormat:@"Model %d", version];
        NSString *momPath = [[NSBundle mainBundle] pathForResource:momName ofType:@"mom" inDirectory:resourceSubpath];
        NSURL *momURL = [NSURL fileURLWithPath:momPath];
        
        return [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    }
}

+ (NSString *)dataStorePathVersion:(NSInteger)version {
    NSString *sqliteName = [self dataStoreNameVersion:version];
    return [[PLUtils documentDirectoryPath] stringByAppendingPathComponent:sqliteName];
}

+ (NSString *)dataStoreNameVersion:(NSInteger)version {
    return [NSString stringWithFormat:@".Player%d.sqlite", version];
}


+ (BOOL)createDefaultObjectsInContext:(NSManagedObjectContext *)context error:(NSError **)error  {    
    PLPlaylist *playlist = [NSEntityDescription insertNewObjectForEntityForName:@"PLPlaylist" inManagedObjectContext:context];
    playlist.name = @"Default";
    playlist.position = [NSNumber numberWithInt:0];
    
    BOOL result = [context save:error];
    
    if (*error == nil) {
        PLDataAccess *dataAccess = [[PLDataAccess alloc] initWithContext:context];
        [dataAccess selectPlaylist:playlist];
    }
    return result;
}

+ (BOOL)migrateFromVersion:(NSInteger)version error:(NSError **)error {        
    NSURL *sourceStoreURL = [NSURL fileURLWithPath:[self dataStorePathVersion:version]];
    NSURL *targetStoreURL = [NSURL fileURLWithPath:[self dataStorePathVersion:PLCurrentDataStoreVersion]];
	
    NSManagedObjectModel *sourceModel = [self modelVersion:version];
    NSManagedObjectModel *targetModel = [self modelVersion:PLCurrentDataStoreVersion];
    
    NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:targetModel];
    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:targetModel];
    
	if(mappingModel == nil) {
        return NO;
    }
    
    [migrationManager migrateStoreFromURL:sourceStoreURL
                                               type:NSSQLiteStoreType
                                            options:nil
                                   withMappingModel:mappingModel
                                   toDestinationURL:targetStoreURL
                                    destinationType:NSSQLiteStoreType
                                 destinationOptions:nil
                                              error:error];
    if(*error != nil) 
        return NO;
    
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	[fileManager removeItemAtPath:[self dataStorePathVersion:version] error:error];
    
    if(*error != nil)
        return NO;
    
    return YES;
}

+ (BOOL)postMigrationVersion:(NSInteger)version inContext:(NSManagedObjectContext *)context error:(NSError **)error {

    // do any post-migration
    
    return [context save:error];
}


@end
