@class RXPromise;

extern NSString * const PLImageFormatNameSmallArtwork;

@interface PLImageCache : NSObject

+ (PLImageCache *)sharedCache;

/**
 Delivers a promise that will be resolved with an UIImage instance containing the media item's artwork
 with the given persistent id.
 */
- (RXPromise *)mediaItemArtworkWithPersistentId:(NSNumber *)persistentId;

/**
 Stores the given (source) image as the artwork under the given persistent id.
 */
- (void)storeMediaItemArtwork:(UIImage *)image forPersistentId:(NSNumber *)persistentId;

/**
* Returns the image size for the format with the given name.
*/
- (CGSize)sizeForImageFormat:(NSString *)imageFormat;

@end