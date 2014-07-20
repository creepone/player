#import "PLPlaylist.h"
#import "PLPlaylistSong.h"
#import "PLBookmark.h"
#import "PLTrack.h"
#import "PLPodcastPin.h"
#import "PLPodcastOldEpisode.h"

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

- (BOOL)saveChanges:(NSError **)error;
- (RACSignal *)saveChangesSignal;
- (void)rollbackChanges;
- (void)processChanges;

/**
 Creates and delivers a new playlist with the given name. Does not check whether a different playlist with this name exists.
 */
- (PLPlaylist *)createPlaylistWithName:(NSString *)name;

/**
 Creates and delivers a new bookmark at the given position of the track.
 */
- (PLBookmark *)createBookmarkAtPosition:(NSTimeInterval)position forTrack:(PLTrack *)track;

/**
 Delivers the first playlist with the given name, if one exists. Otherwise, nil is returned.
 */
- (PLPlaylist *)findPlaylistWithName:(NSString *)name;

/**
 Delivers a track with the given persistent id. If it already exists, it is simply returned, otherwise a new one is created.
 */
- (PLTrack *)findOrCreateTrackWithPersistentId:(NSNumber *)persistentId;

/**
 Delivers a track with the given file path. If it already exists, it is simply returned, otherwise a new one is created.
 */
- (PLTrack *)findOrCreateTrackWithFilePath:(NSString *)filePath;

/**
 Delivers a track with the given download URL. If it already exists, it is simply returned, otherwise a new one is created.
 */
- (PLTrack *)findOrCreateTrackWithDownloadURL:(NSString *)downloadURL;

/**
 Delivers a track with the given managed object ID, if any exists, nil otherwise.
 */
- (PLTrack *)findTrackWithObjectID:(NSString *)objectID;

/**
 Returns YES if there is a track with the given file path.
 */
- (BOOL)existsTrackWithFilePath:(NSString *)filePath;

/**
 Delivers the first found track (or nil if none found) with a persistentId without a file URL (i.e. a track yet to be mirrored)
 */
- (PLTrack *)findNextTrackToMirror;

/**
 Delivers a playlist song with the given track on the given playlist, if one exists. Otherwise, nil is returned.
 */
- (PLPlaylistSong *)findSongWithTrack:(PLTrack *)track onPlaylist:(PLPlaylist *)playlist;

- (NSFetchedResultsController *)fetchedResultsControllerForAllPlaylists;
- (NSFetchedResultsController *)fetchedResultsControllerForAllBookmarks;
- (NSFetchedResultsController *)fetchedResultsControllerForSongsOfPlaylist:(PLPlaylist *)playlist;

- (NSArray *)allEntities:(NSString *)entityName;
- (NSArray *)allEntities:(NSString *)entityName sortedBy:(NSString *)key;

- (PLPlaylist *)selectedPlaylist;
- (void)selectPlaylist:(PLPlaylist *)playlist;
- (PLPlaylist *)bookmarkPlaylist;
- (void)setBookmarkPlaylist:(PLPlaylist *)playlist;

@end
