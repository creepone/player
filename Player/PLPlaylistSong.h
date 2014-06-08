#import "PLEntity.h"

@class PLPlaylist, PLTrack, MPMediaItem;
@class RXPromise;

@interface PLPlaylistSong : PLEntity

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * playbackRate;

@property (nonatomic, retain) PLPlaylist *playlist;
@property (nonatomic, retain) PLTrack *track;


/**
* Removes this and all the related objects from the data store.
* Especially, it removes the associated track in situations where it's no longer necessary to keep it.
*/
- (void)remove;

#pragma mark -- Derived properties

@property (nonatomic, assign) BOOL played;

/**
 Delivers the URL of the asset that this song represents. Can be used with the audio player to play the song.
 */
- (NSURL *)assetURL;

/**
 Delivers the total duration (in seconds) of the song.
 */
- (NSTimeInterval)duration;

/**
 Delivers the name of the artist for this song (if available).
 */
- (NSString *)artist;

/**
 Delivers the title of this song (if available).
 */
- (NSString *)title;

/**
* If available, resolves to a UIImage containing the track's small artwork.
*/
- (RXPromise *)smallArtwork;

/**
* If available, resolves to a UIImage containing the track's large artwork.
*/
- (RXPromise *)largeArtwork;

@end
