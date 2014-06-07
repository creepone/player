#import "PLEntity.h"

@class RXPromise;

@interface PLTrack : PLEntity

@property (nonatomic) int64_t persistentId;
@property (nonatomic, retain) NSString *fileURL;
@property (nonatomic, retain) NSString *downloadURL;
@property (nonatomic) BOOL played;
@property (nonatomic, retain) NSSet *playlistSongs;

/**
 Delivers the URL of the asset that this track represents. Can be used with the audio player to play the track.
 */
- (NSURL *)assetURL;

/**
 Delivers the total duration (in seconds) of the track.
 */
- (NSTimeInterval)duration;

/**
 Delivers the name of the artist for this track (if available).
 */
- (NSString *)artist;

/**
 Delivers the title of this track (if available).
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
