@protocol FICEntity;

@interface PLMediaItemArtwork : NSObject <FICEntity>

/**
* Initializes this entity with the given MPMediaItem's persistentId.
* The media item with this ID will be re-queried to get this artwork if it gets purged from the cache.
* This entity is not meant to reliably persist the artworks, it is only meant for temporary views (like music library selectors)
* that reflect the current state of the media library.
*/
- (id)initWithPersistentId:(NSNumber *)persistentId;

/**
* Retrieves the UIImage for the given URL (in the form artwork://{persistentId}) from the media library (if still present).
*/
+ (UIImage *)imageForURL:(NSURL *)imageURL;

@end