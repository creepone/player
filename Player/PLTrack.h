#import "PLEntity.h"

@class RACSignal;

typedef NS_ENUM(int16_t, PLTrackDownloadStatus) {
    PLTrackDownloadStatusIdle,
    PLTrackDownloadStatusDownloading,
    PLTrackDownloadStatusError,
    PLTrackDownloadStatusDone
};

@interface PLTrack : PLEntity

@property (nonatomic) int64_t persistentId;
@property (nonatomic) PLTrackDownloadStatus downloadStatus;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *downloadURL;
@property (nonatomic, retain) NSString *targetFileName;
@property (nonatomic) BOOL played;
@property (nonatomic, retain) NSSet *playlistSongs;

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *title;


+ (PLTrack *)trackWithPersistentId:(NSNumber *)persistentId inContext:(NSManagedObjectContext *)context;
+ (PLTrack *)trackWithFilePath:(NSString *)filePath inContext:(NSManagedObjectContext *)context;
+ (PLTrack *)trackWithDownloadURL:(NSString *)downloadURL inContext:(NSManagedObjectContext *)context;

- (void)remove;

/**
 Delivers the URL of the asset that this track represents. Can be used with the audio player to play the track.
 If the track is no longer available (e.g. if it was deleted), delivers nil.
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

- (void)loadMetadataFromMediaItem;
- (void)loadMetadataFromAsset;

@end
