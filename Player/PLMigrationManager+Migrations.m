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

    if (version == 1 || version == 2) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSManagedObjectID *selectedPlaylistID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:[userDefaults URLForKey:@"SelectedPlaylist"]];
        if (selectedPlaylistID) {
            NSManagedObject *selectedPlaylist = [context objectWithID:selectedPlaylistID];
            migrationInfo[@"selectedPlaylistName"] = [selectedPlaylist valueForKey:@"name"];
        }
        
        NSManagedObjectID *bookmarkPlaylistID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:[userDefaults URLForKey:@"BookmarkPlaylist"]];
        if (bookmarkPlaylistID) {
            NSManagedObject *bookmarkPlaylist = [context objectWithID:bookmarkPlaylistID];
            migrationInfo[@"bookmarkPlaylistName"] = [bookmarkPlaylist valueForKey:@"name"];
        }
    }
    
    [context save:nil];
}

+ (void)postMigrateWithInfo:(NSDictionary *)migrationInfo
{
    NSInteger originalVersion = [migrationInfo[@"originalVersion"] integerValue];
    PLDataAccess *dataAccess = [[PLDataAccess alloc] initWithContext:[self contextForCurrentVersion]];

    if (originalVersion < 3) {
        NSArray *playlists = [dataAccess allEntities:[PLPlaylist entityName]];
        for (PLPlaylist *playlist in playlists) {
            playlist.uuid = [PLUtils generateUuid];
        }
    
        NSString *selectedPlaylistName = migrationInfo[@"selectedPlaylistName"];
        if (selectedPlaylistName) {
            PLPlaylist *selectedPlaylist = [dataAccess findPlaylistWithName:selectedPlaylistName];
            if (selectedPlaylist)
                [dataAccess selectPlaylist:selectedPlaylist];
        }
        
        NSString *bookmarkPlaylistName = migrationInfo[@"bookmarkPlaylistName"];
        if (bookmarkPlaylistName) {
            PLPlaylist *bookmarkPlaylist = [dataAccess findPlaylistWithName:bookmarkPlaylistName];
            if (bookmarkPlaylist)
                [dataAccess setBookmarkPlaylist:bookmarkPlaylist];
        }
    }
    
    [dataAccess saveChanges:nil];
}


@end
