#import "PLEntity.h"

@class PLPlaylistSong;
@class PLTrack;

@interface PLPlaylist : PLEntity

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSSet *songs;

+ (PLPlaylist *)playlistWithName:(NSString *)name inContext:(NSManagedObjectContext *)context;

/**
 Adds the given track to this playlist and delivers the corresponding playlist song entity.
 */
- (PLPlaylistSong *)addTrack:(PLTrack *)track;

/**
* Removes this and all the related objects from the data store.
* Especially, it removes the associated tracks in situations where it's no longer necessary to keep it.
*/
- (void)remove;

/**
* Removes the given song from this playlist.
* Also removes all the related objects from the data store.
*/
- (void)removeSong:(PLPlaylistSong *)song;

@end

@interface PLPlaylist (CoreDataGeneratedAccessors)

- (void)addSongsObject:(NSManagedObject *)value;
- (void)removeSongsObject:(NSManagedObject *)value;
- (void)addSongs:(NSSet *)values;
- (void)removeSongs:(NSSet *)values;

- (void)renumberSongsOrder:(NSArray *)allSongs;
- (PLPlaylistSong *)currentSong;
- (void)moveToNextSong;
- (void)moveToPreviousSong;

@end
