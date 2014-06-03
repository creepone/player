#import "PLDataAccess.h"
#import "PLCoreDataStack.h"
#import "PLAppDelegate.h"
#import "PLDefaultsManager.h"

@interface PLDataAccess() {
    NSManagedObjectContext *_context;
}
@end

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


- (void)deleteObject:(NSManagedObject *)object {
    [self.context deleteObject:object];
}

- (BOOL)deleteObject:(NSManagedObject *)object error:(NSError **)error {
    [self.context deleteObject:object];
    return [self saveChanges:error];
}

- (BOOL)saveChanges:(NSError **)error {
	return [self.context save:error];
}

- (void)rollbackChanges {
    [self.context rollback];
}

- (void)processChanges {
    [self.context processPendingChanges];
}


- (PLPlaylist *)createPlaylist:(NSString *)name {
    PLPlaylist *playlist = [NSEntityDescription insertNewObjectForEntityForName:@"PLPlaylist" inManagedObjectContext:self.context];
    playlist.name = name;
    return playlist;
}

- (PLPlaylist *)selectedPlaylist {
    NSManagedObjectID *objectID = [self.context.persistentStoreCoordinator managedObjectIDForURIRepresentation:[PLDefaultsManager selectedPlaylist]];
    return (PLPlaylist *)[self.context objectWithID:objectID];
}

- (void)selectPlaylist:(PLPlaylist *)playlist {
    NSManagedObjectID *objectID = [playlist objectID];
    [PLDefaultsManager setSelectedPlaylist:[objectID URIRepresentation]];
}

- (PLPlaylist *)bookmarkPlaylist {
    NSURL *playlistUrl = [PLDefaultsManager bookmarkPlaylist];
    if (playlistUrl == nil)
        return nil;
    
    NSManagedObjectID *objectID = [self.context.persistentStoreCoordinator managedObjectIDForURIRepresentation:playlistUrl];
    return (PLPlaylist *)[self.context objectWithID:objectID];
}

- (void)setBookmarkPlaylist:(PLPlaylist *)playlist {
    NSManagedObjectID *objectID = [playlist objectID];
    [PLDefaultsManager setBookmarkPlaylist:[objectID URIRepresentation]];
}

- (PLTrack *)trackWithPersistentId:(NSNumber *)persistentId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [self setupQueryForTrackWithPersistentID:persistentId fetchRequest:fetchRequest];

    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if ([result count] == 1)
        return result[0];

    PLTrack *track = [NSEntityDescription insertNewObjectForEntityForName:@"PLTrack" inManagedObjectContext:self.context];
    track.persistentId = [persistentId longLongValue];
    return track;
}

- (PLTrack *)trackWithFileURL:(NSString *)fileURL
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [self setupQueryForTrackWithFileURL:fileURL fetchRequest:fetchRequest];

    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if ([result count] == 1)
        return result[0];

    PLTrack *track = [NSEntityDescription insertNewObjectForEntityForName:@"PLTrack" inManagedObjectContext:self.context];
    track.fileURL = fileURL;
    return track;
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

- (void)setupQueryForTrackWithFileURL:(NSString *)fileURL fetchRequest:(NSFetchRequest *)fetchRequest
{
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PLTrack" inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileURL=%@", fileURL];
    [fetchRequest setPredicate:predicate];
}

- (void)setupQueryForSongWithTrack:(PLTrack *)track onPlaylist:(PLPlaylist *)playlist fetchRequest:(NSFetchRequest *)fetchRequest
{
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PLPlaylistSong" inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"track=%@ AND playlist=%@", track, playlist];
    [fetchRequest setPredicate:predicate];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
