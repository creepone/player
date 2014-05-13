#import <MediaPlayer/MediaPlayer.h>

@class RXPromise;

@interface PLMediaLibrarySearch : NSObject

/**
* Delivers an MPMediaItem with the given persistentId, if one can be found, nil otherwise.
*/
+ (MPMediaItem *)mediaItemWithPersistentId:(NSNumber *)persistentId;

/**
* Resolves to an array of PLTracks that are the result of the given media query.
*/
+ (RXPromise *)tracksForMediaQuery:(MPMediaQuery *)mediaQuery;

/**
* Resolves to an array of PLTrackGroups corresponding to each audiobook found in the media library.
*/
+ (RXPromise *)allAudiobooks;

/**
 * Resolves to an array of PLTrackGroups corresponding to each album found in the media library.
 */
+ (RXPromise *)allAlbums;

/**
 * Resolves to an array of PLTrackGroups corresponding to each playlist found in the media library.
 */
+ (RXPromise *)allPlaylists;

/**
 * Resolves to an array of PLTrackGroups corresponding to each podcast found in the media library.
 */
+ (RXPromise *)allPodcasts;

/**
 * Resolves to an array of PLTrackGroups corresponding to each iTunes U album found in the media library.
 */
+ (RXPromise *)allITunesU;

@end