#import <FICImageCache.h>
#import <RXPromise/RXPromise.h>
#import "PLImageCache.h"
#import "PLMediaItemArtwork.h"

NSString * const PLImageFormatNameSmallArtwork = @"PLImageFormatNameSmallArtwork";

@interface PLImageCache() <FICImageCacheDelegate> {

}
@end

@implementation PLImageCache

+ (PLImageCache *)sharedCache
{
    static dispatch_once_t once;
    static PLImageCache *sharedCache;
    dispatch_once(&once, ^ { sharedCache = [[self alloc] init]; });
    return sharedCache;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setupCache];
    }
    return self;
}

- (void)setupCache
{
    FICImageFormat *smallArtworkFormat = [[FICImageFormat alloc] init];
    smallArtworkFormat.name = PLImageFormatNameSmallArtwork;
    smallArtworkFormat.style = FICImageFormatStyle32BitBGRA;
    smallArtworkFormat.imageSize = CGSizeMake(60.f, 60.f);
    smallArtworkFormat.maximumCount = 250;
    smallArtworkFormat.devices = FICImageFormatDevicePhone;
    smallArtworkFormat.protectionMode = FICImageFormatProtectionModeNone;

    FICImageCache *cache = [FICImageCache sharedImageCache];
    cache.delegate = self;
    cache.formats = @[smallArtworkFormat];
}

- (RXPromise *)mediaItemArtworkWithPersistentId:(NSNumber *)persistentId
{
    FICImageCache *cache = [FICImageCache sharedImageCache];
    PLMediaItemArtwork *entity = [[PLMediaItemArtwork alloc] initWithPersistentId:persistentId];

    RXPromise *promise = [[RXPromise alloc] init];

    RXPromise * __weak weakPromise = promise;
    [cache retrieveImageForEntity:entity withFormatName:PLImageFormatNameSmallArtwork completionBlock:^(id <FICEntity> entity, NSString *formatName, UIImage *image) {
        [weakPromise resolveWithResult:image];
    }];

    return promise;
}

- (void)storeMediaItemArtwork:(UIImage *)image forPersistentId:(NSNumber *)persistentId
{
    FICImageCache *cache = [FICImageCache sharedImageCache];
    PLMediaItemArtwork *entity = [[PLMediaItemArtwork alloc] initWithPersistentId:persistentId];
    [cache setImage:image forEntity:entity withFormatName:PLImageFormatNameSmallArtwork completionBlock:nil];
}

- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id <FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock
{
    NSURL *imageURL = [entity sourceImageURLWithFormatName:formatName];

    if ([imageURL.scheme isEqualToString:@"artwork"]) {
        UIImage *image = [PLMediaItemArtwork imageForURL:imageURL];
        completionBlock(image);
    }
}

- (void)imageCache:(FICImageCache *)imageCache cancelImageLoadingForEntity:(id <FICEntity>)entity withFormatName:(NSString *)formatName
{
}

- (void)imageCache:(FICImageCache *)imageCache errorDidOccurWithMessage:(NSString *)errorMessage
{
    DDLogError(@"Image Cache Error:\n%@", errorMessage);
}

- (CGSize)sizeForImageFormat:(NSString *)imageFormat
{
    FICImageCache *cache = [FICImageCache sharedImageCache];
    FICImageFormat *format = [cache formatWithName:imageFormat];
    return format.imageSize;
}

@end