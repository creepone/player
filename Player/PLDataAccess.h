#import "PLPlaylist.h"
#import "PLPlaylistSong.h"
#import "PLBookmark.h"
#import "PLTrack.h"

extern NSString * const PLSelectedPlaylistChange;

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


/**
 Delivers a track with the given persistent id. If it already exists, it is simply returned, otherwise a new one is created.
 */
- (PLTrack *)trackWithPersistentId:(NSNumber *)persistentId;

/**
 Delivers a track with the given file path. If it already exists, it is simply returned, otherwise a new one is created.
 */
- (PLTrack *)trackWithFilePath:(NSString *)filePath;

/**
Delivers a track with the given download URL. If it already exists, it is simply returned, otherwise a new one is created.
*/
- (PLTrack *)trackWithDownloadURL:(NSString *)downloadURL;

/**
* Delivers a track with the given managed object ID, if any exists, nil otherwise.
*/
- (PLTrack *)trackWithObjectID:(NSString *)objectID;

/**
 Returns YES if there is a track with the given file path.
 */
- (BOOL)existsTrackWithFilePath:(NSString *)filePath;


/**
 Returns the first found track (or nil if none found) with a persistentId without a file URL (i.e. a track yet to be mirrored)
 */
- (PLTrack *)nextTrackToMirror;

/**
 Delivers a playlist song with the given track on the given playlist, if one exists. Otherwise, nil is returned.
 */
- (PLPlaylistSong *)songWithTrack:(PLTrack *)track onPlaylist:(PLPlaylist *)playlist;

/**
 Adds a new bookmark at the given position of the track.
 */
- (PLBookmark *)addBookmarkAtPosition:(NSTimeInterval)position forTrack:(PLTrack *)track;


- (BOOL)saveChanges:(NSError **)error;
- (RACSignal *)saveChangesSignal;
- (void)rollbackChanges;
- (void)processChanges;

/**
 Delivers a new playlist with the given name. Does not check whether a different playlist with this name exists.
 */
- (PLPlaylist *)playlistWithName:(NSString *)name;

- (PLPlaylist *)selectedPlaylist;
- (void)selectPlaylist:(PLPlaylist *)playlist;
- (PLPlaylist *)bookmarkPlaylist;
- (void)setBookmarkPlaylist:(PLPlaylist *)playlist;
- (PLPlaylist *)findPlaylistWithName:(NSString *)name;

- (NSFetchedResultsController *)fetchedResultsControllerForAllPlaylists;
- (NSFetchedResultsController *)fetchedResultsControllerForAllBookmarks;
- (NSFetchedResultsController *)fetchedResultsControllerForSongsOfPlaylist:(PLPlaylist *)playlist;

- (NSArray *)allEntities:(NSString *)entityName;
- (NSArray *)allEntities:(NSString *)entityName sortedBy:(NSString *)key;

@end
