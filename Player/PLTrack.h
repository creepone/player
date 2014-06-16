#import "PLEntity.h"

@class RACSignal;

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

- (void)remove;

/**
 Delivers the URL of the asset that this track represents. Can be used with the audio player to play the track.
 */
- (NSURL *)assetURL;

/**
* If available, delivers a UIImage containing the track's small artwork, then completes.
*/
- (RACSignal *)smallArtwork;

/**
* If available, delivers a UIImage containing the track's large artwork, then completes.
*/
- (RACSignal *)largeArtwork;

@end
