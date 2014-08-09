#import "PLMigrationManager+Migrations.h"
#import "PLDefaultsManager.h"
#import "PLDataAccess.h"
#import "PLUtils.h"

@implementation PLMigrationManager (Migrations)

+ (NSManagedObjectContext *)contextForCurrentVersion
{
    NSInteger version = [[PLDefaultsManager sharedManager] dataStoreVersion];
    NSManagedObjectModel *model = [PLMigrationManager modelVersion:version];
    NSString *storePath = [PLMigrationManager dataStorePathVersion:version];
    
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil];
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coordinator];
    
    return context;
}

+ (void)preMigrateWithInfo:(NSMutableDictionary *)migrationInfo
{
    NSInteger version = [[PLDefaultsManager sharedManager] dataStoreVersion];
    NSManagedObjectContext *context = [self contextForCurrentVersion];
    
    migrationInfo[@"originalVersion"] = @(version);

    // pre migration steps
    
    [context save:nil];
}

+ (void)postMigrateWithInfo:(NSDictionary *)migrationInfo
{
    // NSInteger originalVersion = [migrationInfo[@"originalVersion"] integerValue];
    PLDataAccess *dataAccess = [[PLDataAccess alloc] initWithContext:[self contextForCurrentVersion]];

    // post migration steps
    
    [dataAccess saveChanges:nil];
}


@end
