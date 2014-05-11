#import <MediaPlayer/MediaPlayer.h>

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

@end