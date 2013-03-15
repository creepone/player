//
//  DataAccess.m
//  EnergyTracker
//
//  Created by Tomas Vana on 3/17/12.
//  Copyright (c) 2012 iOS Apps Austria. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "PLDataAccess.h"
#import "PLCoreDataStack.h"
#import "PLAppDelegate.h"
#import "PLDefaultsManager.h"

#import "NSString+Extensions.h"

@interface PLDataAccess() {
    NSManagedObjectContext *_context;
}

- (void)setupQueryForAllPlaylists:(NSFetchRequest *)fetchRequest;
- (void)setupQueryForAllBookmarks:(NSFetchRequest *)fetchRequest;
- (void)setupQueryForSongsOfPlaylist:(PLPlaylist *)playlist fetchRequest:(NSFetchRequest *)fetchRequest;
- (void)setupQueryForBookmarkSongOfSong:(MPMediaItem *)song fetchRequest:(NSFetchRequest *)fetchRequest;
- (void)setupQueryForSongWithPersistentID:(NSNumber *)persistentID onPlaylist:(PLPlaylist *)playlist fetchRequest:(NSFetchRequest *)fetchRequest;

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

- (PLBookmarkSong *)bookmarkSongForSong:(MPMediaItem *)song error:(NSError **)error {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [self setupQueryForBookmarkSongOfSong:song fetchRequest:fetchRequest];
    
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:error];
    if (*error != nil)
        return nil;
    
    if ([result count] > 0)
        return [result lastObject];
    
    
    PLBookmarkSong *bookmarkSong = [NSEntityDescription insertNewObjectForEntityForName:@"PLBookmarkSong" inManagedObjectContext:self.context];
    bookmarkSong.persistentId = [song valueForProperty:MPMediaItemPropertyPersistentID];
    bookmarkSong.title = [song valueForProperty:MPMediaItemPropertyTitle];
    
    NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
    
    if ([artist pl_isEmptyOrWhitespace])
        artist = [song valueForProperty:MPMediaItemPropertyPodcastTitle];
    
    bookmarkSong.artist = artist;
    
    return bookmarkSong;
}

- (void)addBookmarkAtPosition:(NSTimeInterval)position forSong:(PLBookmarkSong *)song {
    PLBookmark *bookmark = [NSEntityDescription insertNewObjectForEntityForName:@"PLBookmark" inManagedObjectContext:self.context];
    bookmark.position = [NSNumber numberWithDouble:position];
    bookmark.song = song;
    bookmark.timestamp = [NSDate date];
}

- (PLPlaylistSong *)findSongWithPersistentID:(NSNumber *)persistentID onPlaylist:(PLPlaylist *)playlist {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    [self setupQueryForSongWithPersistentID:persistentID onPlaylist:playlist fetchRequest:fetchRequest];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    if (error != nil || [result count] == 0)
        return nil;
    
    return [result lastObject];
}


- (PLPlaylistSong *)addSong:(MPMediaItem *)song toPlaylist:(PLPlaylist *)playlist {
    PLPlaylistSong *playlistSong = [NSEntityDescription insertNewObjectForEntityForName:@"PLPlaylistSong" inManagedObjectContext:self.context];
    playlistSong.position = [NSNumber numberWithDouble:0.0];
    playlistSong.persistentId = [song valueForProperty:MPMediaItemPropertyPersistentID];
    
    [playlist addNewSong:playlistSong];
    return playlistSong;
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

- (void)setupQueryForBookmarkSongOfSong:(MPMediaItem *)song fetchRequest:(NSFetchRequest *)fetchRequest {
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PLBookmarkSong" inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"persistentId=%@", [song valueForProperty:MPMediaItemPropertyPersistentID]];
    [fetchRequest setPredicate:predicate];
}

- (void)setupQueryForSongWithPersistentID:(NSNumber *)persistentID onPlaylist:(PLPlaylist *)playlist fetchRequest:(NSFetchRequest *)fetchRequest {
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PLPlaylistSong" inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"persistentId=%@ AND playlist=%@", persistentID, playlist];
    [fetchRequest setPredicate:predicate];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
