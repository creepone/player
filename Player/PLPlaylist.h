#import "PLEntity.h"

@class PLPlaylistSong;
@class PLTrack;


@interface PLPlaylist : PLEntity

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSSet *songs;

/**
 Adds the given track to this playlist and delivers the corresponding playlist song entity.
 */
- (PLPlaylistSong *)addTrack:(PLTrack *)track;

@end

@interface PLPlaylist (CoreDataGeneratedAccessors)

- (void)addSongsObject:(NSManagedObject *)value;
- (void)removeSongsObject:(NSManagedObject *)value;
- (void)addSongs:(NSSet *)values;
- (void)removeSongs:(NSSet *)values;

- (void)removeSong:(PLPlaylistSong *)song;
- (void)renumberSongsOrder:(NSArray *)allSongs;
- (PLPlaylistSong *)currentSong;
- (void)moveToNextSong;
- (void)moveToPreviousSong;

@end
