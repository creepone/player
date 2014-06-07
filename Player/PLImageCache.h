@class RXPromise;

extern NSString * const PLImageFormatNameSmallArtwork;

@interface PLImageCache : NSObject

+ (PLImageCache *)sharedCache;

/**
 Delivers a promise that will be resolved with an UIImage instance containing the small artwork of a media item
 with the given persistent id.
 */
- (RXPromise *)smallArtworkForMediaItemWithPersistentId:(NSNumber *)persistentId;

/**
 Delivers a promise that will be resolved with an UIImage instance containing the small artwork of a file stored
 at the given URL.
*/
- (RXPromise *)smallArtworkForFileWithURL:(NSURL *)fileURL;

/**
Delivers a promise that will be resolved with an UIImage instance containing the large artwork of a media item
with the given persistent id.
*/
- (RXPromise *)largeArtworkForMediaItemWithPersistentId:(NSNumber *)persistentId;

/**
Delivers a promise that will be resolved with an UIImage instance containing the large artwork of a file stored
at the given URL.
*/
- (RXPromise *)largeArtworkForFileWithURL:(NSURL *)fileURL;

@end