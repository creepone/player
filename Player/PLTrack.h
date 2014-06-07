#import "PLEntity.h"

@class RXPromise;

@interface PLTrack : PLEntity

@property (nonatomic) int64_t persistentId;
@property (nonatomic, retain) NSString *fileURL;
@property (nonatomic, retain) NSString *downloadURL;
@property (nonatomic) BOOL played;
@property (nonatomic, retain) NSSet *playlistSongs;

@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSString *artist;
@property (nonatomic, readonly) NSString *title;

+ (PLTrack *)trackWithPersistentId:(NSNumber *)persistentId inContext:(NSManagedObjectContext *)context;
+ (PLTrack *)trackWithFileURL:(NSString *)fileURL inContext:(NSManagedObjectContext *)context;

/**
 Delivers the URL of the asset that this track represents. Can be used with the audio player to play the track.
 */
- (NSURL *)assetURL;

/**
* If available, resolves to a UIImage containing the track's small artwork.
*/
- (RXPromise *)smallArtwork;

/**
* If available, resolves to a UIImage containing the track's large artwork.
*/
- (RXPromise *)largeArtwork;

@end
