#import "PLPlaylist.h"
#import "PLPlaylistSong.h"
#import "PLBookmark.h"
#import "PLTrack.h"
#import "PLPodcastPin.h"
#import "PLPodcastOldEpisode.h"

@class PLPodcastEpisode;

extern NSString * const PLSelectedPlaylistChange;

@protocol PLDataAccess <NSObject>

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
+ (id<PLDataAccess>)sharedDataAccess;

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
 Creates and delivers a podcast pin created from the given podcast.
 */
- (PLPodcastPin *)createPodcastPin:(PLPodcast *)podcast;

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
 The given title is used only in case the track does not exists as the new track's (temporary) title.
 */
- (PLTrack *)findOrCreateTrackWithDownloadURL:(NSString *)downloadURL title:(NSString *)title;

/**
 Delivers a track with the given managed object ID, if any exists, nil otherwise.
 */
- (PLTrack *)findTrackWithObjectID:(NSString *)objectID;

/**
 Delivers an old podcast episode for the given episode. If it already exists, it is simply returned, otherwise a new one is created.
 */
- (PLPodcastOldEpisode *)findOrCreatePodcastOldEpisodeByEpisode:(PLPodcastEpisode *)episode;

/**
 Delivers a podcast pin with the given feed URL, if any exists, nil otherwise.
 */
- (PLPodcastPin *)findPodcastPinWithFeedURL:(NSString *)feedURL;

/**
 Returns YES if there is a track with the given file path.
 */
- (BOOL)existsTrackWithFilePath:(NSString *)filePath;

/**
 Returns YES if there is a podcast pin with the given feed URL.
 */
- (BOOL)existsPodcastPinWithFeedURL:(NSString *)feedURL;

/**
 Returns YES if there is an old podcast episode with the given GUID.
 */
- (BOOL)existsPodcastOldEpisodeWithGuid:(NSString *)guid;

/**
 Returns the highest value of the order property amongst existing podcast pins
 */
- (NSNumber *)findHighestPodcastPinOrder;

/**
 Delivers the first found track (or nil if none found) with a persistentId without a file URL (i.e. a track yet to be mirrored)
 */
- (PLTrack *)findNextTrackToMirror;

/**
 Delivers a playlist song with the given track on the given playlist, if one exists. Otherwise, nil is returned.
 */
- (PLPlaylistSong *)findSongWithTrack:(PLTrack *)track onPlaylist:(PLPlaylist *)playlist;

/**
 Executes the given block for each podcast pin in the data store.
 */
- (void)executeForEachPodcastPin:(void(^)(PLPodcastPin *))block;

- (NSFetchedResultsController *)fetchedResultsControllerForAllPlaylists;
- (NSFetchedResultsController *)fetchedResultsControllerForAllBookmarks;
- (NSFetchedResultsController *)fetchedResultsControllerForSongsOfPlaylist:(PLPlaylist *)playlist;
- (NSFetchedResultsController *)fetchedResultsControllerForAllPodcastPins;
- (NSFetchedResultsController *)fetchedResultsControllerForEpisodesOfPodcast:(PLPodcastPin *)podcast;

- (NSArray *)allEntities:(NSString *)entityName;
- (NSArray *)allEntities:(NSString *)entityName sortedBy:(NSString *)key;

- (PLPlaylist *)selectedPlaylist;
- (void)selectPlaylist:(PLPlaylist *)playlist;
- (PLPlaylist *)bookmarkPlaylist;
- (void)setBookmarkPlaylist:(PLPlaylist *)playlist;

@end

@interface PLDataAccess : NSObject <PLDataAccess>
@end
