@protocol FICEntity;
@class RACSignal;

@interface PLCachedArtwork : NSObject <FICEntity>

/**
* Initializes this entity with the given MPMediaItem's persistentId.
* The media item with this ID will be re-queried to get this artwork if it gets purged from the cache.
* This entity is not meant to reliably persist the artworks, it is only meant for temporary views (like music library selectors)
* that reflect the current state of the media library.
*/
- (instancetype)initWithPersistentId:(NSNumber *)persistentId;


/**
* Initializes this entity with the given URL. This can either be a URL of a file containing an asset with an embedded artwork,
* or a download URL for the actual artwork image. Depending on which is the case, either the metadata of the file with this URL will be re-queried 
* or the image will be re-downloaded from the URL to get this artwork if it gets purged from the cache.
*/
- (instancetype)initWithURL:(NSURL *)fileURL;

/**
* Retrieves the UIImage for the given URL, delivers it and completes.
* in the form "media://{persistentId}" from the media library (if present).
* in the form of a file URL from the data of a physical file (if exists).
* in the form of a downlad URL to download the image from the internet.
* @param size is a hint for the image generation. the actual returned image might have a different size.
*/
+ (RACSignal *)imageForURL:(NSURL *)imageURL size:(CGSize)size;

@end