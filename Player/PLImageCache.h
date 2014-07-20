@class RACSignal;

extern NSString * const PLImageFormatNameSmallArtwork;

@interface PLImageCache : NSObject

+ (PLImageCache *)sharedCache;

/**
 Delivers a single UIImage instance containing the small artwork of a media item with the given persistent id, then completes.
 */
- (RACSignal *)smallArtworkForMediaItemWithPersistentId:(NSNumber *)persistentId;

/**
 Delivers a single UIImage instance containing the small artwork of a file stored at the given URL, then completes.
*/
- (RACSignal *)smallArtworkForFileWithURL:(NSURL *)fileURL;

/**
 Delivers a single UIImage instance containing the small artwork downloaded from the given URL, then completes.
 */
- (RACSignal *)smallArtworkForDownloadURL:(NSURL *)downloadURL;

/**
 Delivers a single UIImage instance containing the large artwork of a media item with the given persistent id, then completes.
*/
- (RACSignal *)largeArtworkForMediaItemWithPersistentId:(NSNumber *)persistentId;

/**
 Delivers a single UIImage instance containing the large artwork of a file stored at the given URL, then completes.
*/
- (RACSignal *)largeArtworkForFileWithURL:(NSURL *)fileURL;

@end