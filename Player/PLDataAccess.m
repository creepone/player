#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLDataAccess.h"
#import "PLCoreDataStack.h"
#import "PLAppDelegate.h"
#import "PLDefaultsManager.h"
#import "PLErrorManager.h"
#import "PLServiceContainer.h"

#define instanceKey(OBJECT, PATH) (keypath(((OBJECT *)nil), PATH))

@interface PLDataAccess() {
    NSManagedObjectContext *_context;
}
@end

NSString * const PLSelectedPlaylistChange = @"PLSelectedPlaylistChange";

@implementation PLDataAccess

- (id)init
{
    return [self initWithNewContext:NO];
}

- (id)initWithNewContext:(BOOL)useNewContext
{
    PLAppDelegate *appDelegate = (PLAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = useNewContext ? [appDelegate.coreDataStack newContext] : nil;
    return [self initWithContext:context];
}

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesIntoContext:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}


+ (id<PLDataAccess>)sharedDataAccess
{
    return PLResolve(PLDataAccess);
}

- (NSManagedObjectContext *)context
{
    if(_context == nil) {
        PLAppDelegate *appDelegate = (PLAppDelegate *)[[UIApplication sharedApplication] delegate];
        return appDelegate.coreDataStack.managedObjectContext;
    }
    else 
        return _context;
}

- (void)mergeChangesIntoContext:(NSNotification *)notification
{
    if (notification.object != self.context) {
        [self.context mergeChangesFromContextDidSaveNotification:notification];
    }
}

- (BOOL)saveChanges:(NSError **)error
{
	return [self.context save:error];
}

- (RACSignal *)saveChangesSignal
{
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        NSError *error;
        [self saveChanges:&error];

        if (error)
            [subscriber sendError:error];
        else
            [subscriber sendCompleted];

        return nil;
    }] subscribeOn:[RACScheduler immediateScheduler]];
}

- (void)rollbackChanges
{
    [self.context rollback];
}

- (void)processChanges
{
    [self.context processPendingChanges];
}


- (PLPlaylist *)createPlaylistWithName:(NSString *)name
{
    return [PLPlaylist playlistWithName:name inContext:self.context];
}

- (PLBookmark *)createBookmarkAtPosition:(NSTimeInterval)position forTrack:(PLTrack *)track
{
    PLBookmark *bookmark = [NSEntityDescription insertNewObjectForEntityForName:[PLBookmark entityName] inManagedObjectContext:self.context];
    bookmark.position = [NSNumber numberWithDouble:position];
    bookmark.track = track;
    bookmark.timestamp = [NSDate date];
    return bookmark;
}

- (PLPodcastPin *)createPodcastPin:(PLPodcast *)podcast
{
    return [PLPodcastPin podcastPinFromPodcast:podcast inContext:self.context];
}

- (PLPlaylist *)findPlaylistWithUuid:(NSString *)uuid
{
    NSFetchRequest *fetchRequest = [self queryForPlaylistWithUuid:uuid];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    return [result count] == 1 ? result[0] : nil;
}

- (PLPlaylist *)findPlaylistWithName:(NSString *)name
{
    NSFetchRequest *fetchRequest = [self queryForPlaylistWithName:name];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    return result[0];
}

- (PLTrack *)findOrCreateTrackWithPersistentId:(NSNumber *)persistentId
{
    NSFetchRequest *fetchRequest = [self queryForTrackWithPersistentID:persistentId];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if ([result count] == 1)
        return result[0];
    
    return [PLTrack trackWithPersistentId:persistentId inContext:self.context];
}

- (PLTrack *)findOrCreateTrackWithFilePath:(NSString *)filePath
{
    NSFetchRequest *fetchRequest = [self queryForTrackWithFilePath:filePath];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if ([result count] == 1)
        return result[0];
    
    return [PLTrack trackWithFilePath:filePath inContext:self.context];
}

- (PLTrack *)findOrCreateTrackWithDownloadURL:(NSString *)downloadURL
{
    NSFetchRequest *fetchRequest = [self queryForTrackWithDownloadURL:downloadURL];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if ([result count] == 1)
        return result[0];
    
    return [PLTrack trackWithDownloadURL:downloadURL inContext:self.context];
}

- (PLTrack *)findTrackWithObjectID:(NSString *)objectID
{
    NSURL *objectIDURL = [NSURL URLWithString:objectID];
    NSManagedObjectID *managedObjectID = [self.context.persistentStoreCoordinator managedObjectIDForURIRepresentation:objectIDURL];
    if (managedObjectID == nil)
        return nil;
    
    return (PLTrack *)[self.context existingObjectWithID:managedObjectID error:nil];
}

- (PLTrack *)findNextTrackToMirror
{
    NSFetchRequest *fetchRequest = [self queryForNextTrackToMirror];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if ([result count] >= 1)
        return result[0];
    
    return nil;
}

- (PLPlaylistSong *)findSongWithTrack:(PLTrack *)track onPlaylist:(PLPlaylist *)playlist
{
    NSFetchRequest *fetchRequest = [self queryForSongWithTrack:track onPlaylist:playlist];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if (error != nil || [result count] == 0)
        return nil;
    
    return [result lastObject];
}

- (PLPodcastPin *)findPodcastPinWithFeedURL:(NSString *)feedURL
{
    NSFetchRequest *fetchRequest = [self queryForPodcastPinWithFeedURL:feedURL];

    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if (error != nil || [result count] == 0)
        return nil;
    
    return [result lastObject];
}

- (BOOL)existsTrackWithFilePath:(NSString *)filePath
{
    NSFetchRequest *fetchRequest = [self queryForTrackWithFilePath:filePath];
    return [self.context countForFetchRequest:fetchRequest error:nil] > 0;
}

- (BOOL)existsPodcastPinWithFeedURL:(NSString *)feedURL
{
    NSFetchRequest *fetchRequest = [self queryForPodcastPinWithFeedURL:feedURL];
    return [self.context countForFetchRequest:fetchRequest error:nil] > 0;
}

- (NSNumber *)findHighestPodcastPinOrder
{
    NSFetchRequest *fetchRequest = [self queryForHighestPodcastPinOrder];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        [PLErrorManager logError:error];
        return nil;
    }
    
    if ([result count] == 0) {
        return @(0);
    }
    else {
        return [result[0] valueForKey:@instanceKey(PLPodcastPin, order)];
    }
}


- (NSFetchedResultsController *)fetchedResultsControllerForAllPlaylists
{
	return [[NSFetchedResultsController alloc]
            initWithFetchRequest:[self queryForAllPlaylists]
            managedObjectContext:self.context
            sectionNameKeyPath:nil
            cacheName:nil];
}

- (NSFetchedResultsController *)fetchedResultsControllerForAllBookmarks
{
	return [[NSFetchedResultsController alloc]
            initWithFetchRequest:[self queryForAllBookmarks]
            managedObjectContext:self.context
            sectionNameKeyPath:nil
            cacheName:nil];
}

- (NSFetchedResultsController *)fetchedResultsControllerForSongsOfPlaylist:(PLPlaylist *)playlist
{
	return [[NSFetchedResultsController alloc]
            initWithFetchRequest:[self queryForSongsOfPlaylist:playlist]
            managedObjectContext:self.context
            sectionNameKeyPath:nil
            cacheName:nil];
}

- (NSFetchedResultsController *)fetchedResultsControllerForAllPodcastPins
{
	return [[NSFetchedResultsController alloc]
            initWithFetchRequest:[self queryForAllPodcastPins]
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


- (PLPlaylist *)selectedPlaylist
{
    NSString *selectedPlaylistUuid = [[PLDefaultsManager sharedManager] selectedPlaylistUuid];
    if (selectedPlaylistUuid)
        return [self findPlaylistWithUuid:selectedPlaylistUuid];
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
        return [self findPlaylistWithUuid:bookmarkPlaylistUuid];
    return nil;
}

- (void)setBookmarkPlaylist:(PLPlaylist *)playlist
{
    [[PLDefaultsManager sharedManager] setBookmarkPlaylistUuid:playlist.uuid];
}


#pragma mark -- Setup for queries

- (NSFetchRequest *)queryForAllPlaylists
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLPlaylist entityName] inManagedObjectContext:self.context]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@instanceKey(PLPlaylist, name) ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    return fetchRequest;
}

- (NSFetchRequest *)queryForAllBookmarks
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLBookmark entityName] inManagedObjectContext:self.context]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@instanceKey(PLBookmark, timestamp) ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    return fetchRequest;
}

- (NSFetchRequest *)queryForSongsOfPlaylist:(PLPlaylist *)playlist
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLPlaylistSong entityName] inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", @instanceKey(PLPlaylistSong, playlist), playlist];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@instanceKey(PLPlaylistSong, order) ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    return fetchRequest;
}

- (NSFetchRequest *)queryForAllPodcastPins
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLPodcastPin entityName] inManagedObjectContext:self.context]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@instanceKey(PLPodcastPin, order) ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    return fetchRequest;
}

- (NSFetchRequest *)queryForTrackWithPersistentID:(NSNumber *)persistentID
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLTrack entityName] inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", @instanceKey(PLTrack, persistentId), persistentID];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (NSFetchRequest *)queryForPodcastPinWithFeedURL:(NSString *)feedURL
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLPodcastPin entityName] inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", @instanceKey(PLPodcastPin, feedURL), feedURL];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (NSFetchRequest *)queryForTrackWithFilePath:(NSString *)filePath
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];

    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLTrack entityName] inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", @instanceKey(PLTrack, filePath), filePath];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (NSFetchRequest *)queryForTrackWithDownloadURL:(NSString *)downloadURL
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLTrack entityName] inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", @instanceKey(PLTrack, downloadURL), downloadURL];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (NSFetchRequest *)queryForNextTrackToMirror
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];

    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLTrack entityName] inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != 0 AND %K = nil", @instanceKey(PLTrack, persistentId), @instanceKey(PLTrack, filePath)];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (NSFetchRequest *)queryForSongWithTrack:(PLTrack *)track onPlaylist:(PLPlaylist *)playlist
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];

    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLPlaylistSong entityName] inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@ AND %K = %@", @instanceKey(PLPlaylistSong, track), track, @instanceKey(PLPlaylistSong, playlist), playlist];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (NSFetchRequest *)queryForPlaylistWithName:(NSString *)name
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];

    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLPlaylist entityName] inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", @instanceKey(PLPlaylist, name), name];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (NSFetchRequest *)queryForPlaylistWithUuid:(NSString *)uuid
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];

    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLPlaylist entityName] inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", @instanceKey(PLPlaylist, uuid), uuid];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (NSFetchRequest *)queryForHighestPodcastPinOrder
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:[PLPodcastPin entityName] inManagedObjectContext:self.context]];
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@instanceKey(PLPodcastPin, order)];
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:@[keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@instanceKey(PLPodcastPin, order)];
    [expressionDescription setExpression:maxExpression];
    [expressionDescription setExpressionResultType:NSInteger64AttributeType];
    
    [fetchRequest setPropertiesToFetch:@[expressionDescription]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    return fetchRequest;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
