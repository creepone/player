#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLDataAccess.h"
#import "PLCoreDataStack.h"
#import "PLAppDelegate.h"
#import "PLDefaultsManager.h"
#import "PLErrorManager.h"

@interface PLDataAccess() {
    NSManagedObjectContext *_context;
}
@end

NSString * const PLSelectedPlaylistChange = @"PLSelectedPlaylistChange";

@implementation PLDataAccess

- (id)init {
    return [self initWithNewContext:NO];
}

- (id)initWithNewContext:(BOOL)useNewContext {
    PLAppDelegate *appDelegate = (PLAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = useNewContext ? [appDelegate.coreDataStack newContext] : nil;
    return [self initWithContext:context];
}

- (id)initWithContext:(NSManagedObjectContext *)context {
    self = [super init];
    if (self) {
        _context = context;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesIntoContext:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}


+ (PLDataAccess *)sharedDataAccess {
    static dispatch_once_t once;
    static PLDataAccess *sharedDataAccess;
    dispatch_once(&once, ^ { sharedDataAccess = [[self alloc] init]; });
    return sharedDataAccess;
}

- (NSManagedObjectContext *)context {
    if(_context == nil) {
        PLAppDelegate *appDelegate = (PLAppDelegate *)[[UIApplication sharedApplication] delegate];
        return appDelegate.coreDataStack.managedObjectContext;
    }
    else 
        return _context;
}

- (void)mergeChangesIntoContext:(NSNotification *)notification {
    if (notification.object != self.context) {
        [self.context mergeChangesFromContextDidSaveNotification:notification];
    }
}

- (BOOL)saveChanges:(NSError **)error {
	return [self.context save:error];
}

- (RACSignal *)saveChangesSignal
{
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        NSError *error;
        [self saveChanges:&error];

        if (error)
            [subscriber sendError:error];
        else
            [subscriber sendCompleted];

        return nil;
    }];
}

- (void)rollbackChanges {
    [self.context rollback];
}

- (void)processChanges {
    [self.context processPendingChanges];
}

- (PLPlaylist *)playlistWithName:(NSString *)name
{
    return [PLPlaylist playlistWithName:name inContext:self.context];
}

- (PLPlaylist *)selectedPlaylist
{
    NSString *selectedPlaylistUuid = [[PLDefaultsManager sharedManager] selectedPlaylistUuid];
    if (selectedPlaylistUuid)
        return [self playlistWithUuid:selectedPlaylistUuid];
    return nil;
}

- (void)selectPlaylist:(PLPlaylist *)playlist
{
    [[PLDefaultsManager sharedManager] setSelectedPlaylistUuid:playlist.uuid];
    [[NSNotificationCenter defaultCenter] postNotificationName:PLSelectedPlaylistChange object:nil];
}

- (PLPlaylist *)bookmarkPlaylist
{
    NSString *bookmarkPlaylistUuid = [[PLDefaultsManager sharedManager] bookmarkPlaylistUuid];
    if (bookmarkPlaylistUuid)
        return [self playlistWithUuid:bookmarkPlaylistUuid];
    return nil;
}

- (void)setBookmarkPlaylist:(PLPlaylist *)playlist
{
    [[PLDefaultsManager sharedManager] setBookmarkPlaylistUuid:playlist.uuid];
}

// todo: unify all finds vs. creates
- (PLPlaylist *)findPlaylistWithName:(NSString *)name
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [self setupQueryForPlaylistWithName:name fetchRequest:fetchRequest];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    return [result count] == 1 ? result[0] : nil;
}

- (PLPlaylist *)playlistWithUuid:(NSString *)uuid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [self setupQueryForPlaylistWithUuid:uuid fetchRequest:fetchRequest];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    return [result count] == 1 ? result[0] : nil;
}

- (PLTrack *)trackWithPersistentId:(NSNumber *)persistentId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [self setupQueryForTrackWithPersistentID:persistentId fetchRequest:fetchRequest];

    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if ([result count] == 1)
        return result[0];

    return [PLTrack trackWithPersistentId:persistentId inContext:self.context];
}

- (PLTrack *)trackWithFilePath:(NSString *)filePath
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [self setupQueryForTrackWithFilePath:filePath fetchRequest:fetchRequest];

    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if ([result count] == 1)
        return result[0];

    return [PLTrack trackWithFilePath:filePath inContext:self.context];
}

- (PLTrack *)trackWithDownloadURL:(NSString *)downloadURL
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [self setupQueryForTrackWithDownloadURL:downloadURL fetchRequest:fetchRequest];

    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if ([result count] == 1)
        return result[0];

    return [PLTrack trackWithDownloadURL:downloadURL inContext:self.context];
}

- (PLTrack *)trackWithObjectID:(NSString *)objectID
{
    NSURL *objectIDURL = [NSURL URLWithString:objectID];
    NSManagedObjectID *managedObjectID = [self.context.persistentStoreCoordinator managedObjectIDForURIRepresentation:objectIDURL];
    if (managedObjectID == nil)
        return nil;

    return (PLTrack *)[self.context existingObjectWithID:managedObjectID error:nil];
}

- (BOOL)existsTrackWithFilePath:(NSString *)filePath
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [self setupQueryForTrackWithFilePath:filePath fetchRequest:fetchRequest];
    
    NSUInteger count = [self.context countForFetchRequest:fetchRequest error:nil];
    return count > 0;
}

- (PLTrack *)nextTrackToMirror
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [self setupQueryForTrackToMirror:fetchRequest];

    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if ([result count] >= 1)
        return result[0];

    return nil;
}

- (PLBookmark *)addBookmarkAtPosition:(NSTimeInterval)position forTrack:(PLTrack *)track
{
    PLBookmark *bookmark = [NSEntityDescription insertNewObjectForEntityForName:@"PLBookmark" inManagedObjectContext:self.context];
    bookmark.position = [NSNumber numberWithDouble:position];
    bookmark.track = track;
    bookmark.timestamp = [NSDate date];
    return bookmark;
}

- (PLPlaylistSong *)songWithTrack:(PLTrack *)track onPlaylist:(PLPlaylist *)playlist
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [self setupQueryForSongWithTrack:track onPlaylist:playlist fetchRequest:fetchRequest];

    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if (error != nil || [result count] == 0)
        return nil;

    return [result lastObject];
}

- (NSFetchedResultsController *)fetchedResultsControllerForAllPlaylists {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [self setupQueryForAllPlaylists:fetchRequest];
    
	return [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
            managedObjectContext:self.context
            sectionNameKeyPath:nil
            cacheName:nil];
}

- (NSFetchedResultsController *)fetchedResultsControllerForAllBookmarks {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [self setupQueryForAllBookmarks:fetchRequest];
    
	return [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
            managedObjectContext:self.context
            sectionNameKeyPath:nil
            cacheName:nil];
}


- (NSFetchedResultsController *)fetchedResultsControllerForSongsOfPlaylist:(PLPlaylist *)playlist {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [self setupQueryForSongsOfPlaylist:playlist fetchRequest:fetchRequest];
    
	return [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
            managedObjectContext:self.context
            sectionNameKeyPath:nil
            cacheName:nil];
}

- (NSArray *)allEntities:(NSString *)entityName
{
    return [self allEntities:entityName sortedBy:nil];
}

- (NSArray *)allEntities:(NSString *)entityName sortedBy:(NSString *)key
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:self.context]];
    [fetchRequest setFetchBatchSize:50];
    
    if (key) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
    }
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [PLErrorManager logError:error];
        return nil;
    }
    
    return result;
}


- (void)setupQueryForAllPlaylists:(NSFetchRequest *)fetchRequest  {
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PLPlaylist" inManagedObjectContext:self.context]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
}

- (void)setupQueryForAllBookmarks:(NSFetchRequest *)fetchRequest  {
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PLBookmark" inManagedObjectContext:self.context]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
}


- (void)setupQueryForSongsOfPlaylist:(PLPlaylist *)playlist fetchRequest:(NSFetchRequest *)fetchRequest {
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PLPlaylistSong" inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playlist=%@", playlist];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
}

- (void)setupQueryForTrackWithPersistentID:(NSNumber *)persistentID fetchRequest:(NSFetchRequest *)fetchRequest
{
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PLTrack" inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"persistentId=%@", persistentID];
    [fetchRequest setPredicate:predicate];
}

- (void)setupQueryForTrackWithFilePath:(NSString *)filePath fetchRequest:(NSFetchRequest *)fetchRequest
{
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PLTrack" inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filePath=%@", filePath];
    [fetchRequest setPredicate:predicate];
}

- (void)setupQueryForTrackWithDownloadURL:(NSString *)downloadURL fetchRequest:(NSFetchRequest *)fetchRequest
{
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PLTrack" inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloadURL=%@", downloadURL];
    [fetchRequest setPredicate:predicate];
}

- (void)setupQueryForTrackToMirror:(NSFetchRequest *)fetchRequest
{
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PLTrack" inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"persistentId != 0 AND filePath = nil"];
    [fetchRequest setPredicate:predicate];
}

- (void)setupQueryForSongWithTrack:(PLTrack *)track onPlaylist:(PLPlaylist *)playlist fetchRequest:(NSFetchRequest *)fetchRequest
{
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PLPlaylistSong" inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"track=%@ AND playlist=%@", track, playlist];
    [fetchRequest setPredicate:predicate];
}

- (void)setupQueryForPlaylistWithName:(NSString *)name fetchRequest:(NSFetchRequest *)fetchRequest
{
    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLPlaylist entityName] inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", name];
    [fetchRequest setPredicate:predicate];
}

- (void)setupQueryForPlaylistWithUuid:(NSString *)uuid fetchRequest:(NSFetchRequest *)fetchRequest
{
    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLPlaylist entityName] inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
    [fetchRequest setPredicate:predicate];
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
