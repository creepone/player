#import <Foundation/Foundation.h>
#import "PLPlaylist.h"
#import "PLPlaylistSong.h"
#import "PLBookmark.h"
#import "PLBookmarkSong.h"

@interface PLDataAccess : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *context;

/**
 Initializes a new instance of the data access. If "useNewContext" flag is set, a new managed object context will be 
 created and used for all the queries operations etc. If the flag is not set, the global context for the application
 will be reused.
 */
- (id)initWithNewContext:(BOOL)useNewContext;

/**
 Initializes a new instance of the data access using the given managed object context.
 */
- (id)initWithContext:(NSManagedObjectContext *)context;

/**
 Shared data access instance that uses the global managed object context for its operations.
 */
+ (PLDataAccess *)sharedDataAccess;


- (void)deleteObject:(NSManagedObject *)object;
- (BOOL)deleteObject:(NSManagedObject *)object error:(NSError **)error;
- (BOOL)saveChanges:(NSError **)error;
- (void)rollbackChanges;
- (void)processChanges;

- (PLPlaylist *)createPlaylist:(NSString *)name;
- (PLPlaylist *)selectedPlaylist;
- (void)selectPlaylist:(PLPlaylist *)playlist;
- (PLPlaylist *)bookmarkPlaylist;
- (void)setBookmarkPlaylist:(PLPlaylist *)playlist;
- (PLPlaylistSong *)addSong:(MPMediaItem *)song toPlaylist:(PLPlaylist *)playlist;
- (PLPlaylistSong *)findSongWithPersistentID:(NSNumber *)persistentID onPlaylist:(PLPlaylist *)playlist;

- (PLBookmarkSong *)bookmarkSongForSong:(MPMediaItem *)song error:(NSError **)error;
- (void)addBookmarkAtPosition:(NSTimeInterval)position forSong:(PLBookmarkSong *)song;

- (NSFetchedResultsController *)fetchedResultsControllerForAllPlaylists;
- (NSFetchedResultsController *)fetchedResultsControllerForAllBookmarks;
- (NSFetchedResultsController *)fetchedResultsControllerForSongsOfPlaylist:(PLPlaylist *)playlist;

@end
