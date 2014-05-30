#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PLTrack : NSManagedObject

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
 Delivers the artwork image for this track. The size is a hint, i.e. the delivered image might have a different size
 depending on the track metadata format.
 */
- (UIImage *)artworkWithSize:(CGSize)size;

@end
