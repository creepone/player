#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PLPlaylist, PLTrack, MPMediaItem;

@interface PLPlaylistSong : NSManagedObject

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * playbackRate;

@property (nonatomic, retain) PLPlaylist *playlist;
@property (nonatomic, retain) PLTrack *track;


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
 Delivers the artwork image for this song. The size is a hint, i.e. the delivered image might have a different size
 depending on the track metadata format.
*/
- (UIImage *)artworkWithSize:(CGSize)size;

@end
