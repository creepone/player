#import <FICImageCache.h>
#import <RXPromise/RXPromise.h>
#import "PLImageCache.h"
#import "PLCachedArtwork.h"

NSString * const PLImageFormatNameSmallArtwork = @"PLImageFormatNameSmallArtwork";
NSString * const PLImageFormatNameLargeArtwork = @"PLImageFormatNameLargeArtwork";


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
    
    FICImageFormat *largeArtworkFormat = [[FICImageFormat alloc] init];
    largeArtworkFormat.name = PLImageFormatNameLargeArtwork;
    largeArtworkFormat.style = FICImageFormatStyle32BitBGRA;
    largeArtworkFormat.imageSize = CGSizeMake(200.f, 200.f);
    largeArtworkFormat.maximumCount = 100;
    largeArtworkFormat.devices = FICImageFormatDevicePhone;
    largeArtworkFormat.protectionMode = FICImageFormatProtectionModeNone;

    FICImageCache *cache = [FICImageCache sharedImageCache];
    cache.delegate = self;
    cache.formats = @[smallArtworkFormat, largeArtworkFormat];
}

- (RXPromise *)smallArtworkForMediaItemWithPersistentId:(NSNumber *)persistentId
{
    FICImageCache *cache = [FICImageCache sharedImageCache];
    PLCachedArtwork *entity = [[PLCachedArtwork alloc] initWithPersistentId:persistentId];

    RXPromise *promise = [[RXPromise alloc] init];

    RXPromise * __weak weakPromise = promise;
    [cache retrieveImageForEntity:entity withFormatName:PLImageFormatNameSmallArtwork completionBlock:^(id <FICEntity> entity, NSString *formatName, UIImage *image) {
        [weakPromise resolveWithResult:image];
    }];

    return promise;
}

- (RXPromise *)smallArtworkForFileWithURL:(NSURL *)fileURL
{
    FICImageCache *cache = [FICImageCache sharedImageCache];
    PLCachedArtwork *entity = [[PLCachedArtwork alloc] initWithFileURL:fileURL];

    RXPromise *promise = [[RXPromise alloc] init];

    RXPromise * __weak weakPromise = promise;
    [cache retrieveImageForEntity:entity withFormatName:PLImageFormatNameSmallArtwork completionBlock:^(id <FICEntity> entity, NSString *formatName, UIImage *image) {
        [weakPromise resolveWithResult:image];
    }];

    return promise;
}

- (RXPromise *)largeArtworkForMediaItemWithPersistentId:(NSNumber *)persistentId
{
    FICImageCache *cache = [FICImageCache sharedImageCache];
    PLCachedArtwork *entity = [[PLCachedArtwork alloc] initWithPersistentId:persistentId];

    RXPromise *promise = [[RXPromise alloc] init];

    RXPromise * __weak weakPromise = promise;
    [cache retrieveImageForEntity:entity withFormatName:PLImageFormatNameLargeArtwork completionBlock:^(id <FICEntity> entity, NSString *formatName, UIImage *image) {
        [weakPromise resolveWithResult:image];
    }];

    return promise;
}

- (RXPromise *)largeArtworkForFileWithURL:(NSURL *)fileURL
{
    FICImageCache *cache = [FICImageCache sharedImageCache];
    PLCachedArtwork *entity = [[PLCachedArtwork alloc] initWithFileURL:fileURL];

    RXPromise *promise = [[RXPromise alloc] init];

    RXPromise * __weak weakPromise = promise;
    [cache retrieveImageForEntity:entity withFormatName:PLImageFormatNameLargeArtwork completionBlock:^(id <FICEntity> entity, NSString *formatName, UIImage *image) {
        [weakPromise resolveWithResult:image];
    }];

    return promise;
}

- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id <FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock
{
    NSURL *imageURL = [entity sourceImageURLWithFormatName:formatName];
    CGSize size = [self sizeForImageFormat:formatName];

    if ([entity isKindOfClass:[PLCachedArtwork class]]) {
        UIImage *image = [PLCachedArtwork imageForURL:imageURL size:size];
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