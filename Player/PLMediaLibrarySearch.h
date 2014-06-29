#import <MediaPlayer/MediaPlayer.h>

@class RACSignal;

@interface PLMediaLibrarySearch : NSObject

/**
* Delivers an MPMediaItem with the given persistentId, if one can be found, nil otherwise.
*/
+ (MPMediaItem *)mediaItemWithPersistentId:(NSNumber *)persistentId;

/**
* Returns a signal that delivers an array of PLMediaItemTrack-s containing the results of the given media query.
*/
+ (RACSignal *)tracksForMediaQuery:(MPMediaQuery *)mediaQuery;

/**
* Returns a signal that delivers an array of PLMediaItemTrack-s containing the tracks from the given collection.
*/
+ (RACSignal *)tracksForCollection:(MPMediaItemCollection *)collection;

/**
* Returns a signal that delivers an array of PLMediaItemTrackGroup-s containing all the audiobooks found in the media library, then completes.
*/
+ (RACSignal *)allAudiobooks;

/**
* Returns a signal that delivers an array of PLMediaItemTrackGroup-s containing all the albums found in the media library, then completes.
 */
+ (RACSignal *)allAlbums;

/**
* Returns a signal that delivers an array of PLMediaItemTrackGroup-s containing all the playlists found in the media library, then completes.
 */
+ (RACSignal *)allPlaylists;

/**
* Returns a signal that delivers an array of PLMediaItemTrackGroup-s containing all the podcasts found in the media library, then completes.
*/
+ (RACSignal *)allPodcasts;

/**
* Returns a signal that delivers an array of PLMediaItemTrackGroup-s containing all the iTunes U albums found in the media library, then completes.
 */
+ (RACSignal *)allITunesU;

@end