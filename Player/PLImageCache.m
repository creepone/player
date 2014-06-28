#import <FICImageCache.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
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

- (RACSignal *)imageForEntity:(id <FICEntity>) entity formatName:(NSString *)formatName
{
    FICImageCache *cache = [FICImageCache sharedImageCache];

    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        [cache retrieveImageForEntity:entity withFormatName:formatName completionBlock:^(id <FICEntity> entity, NSString *formatName, UIImage *image) {
            [subscriber sendNext:image];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (RACSignal *)smallArtworkForMediaItemWithPersistentId:(NSNumber *)persistentId
{
    PLCachedArtwork *entity = [[PLCachedArtwork alloc] initWithPersistentId:persistentId];
    return [self imageForEntity:entity formatName:PLImageFormatNameSmallArtwork];
}

- (RACSignal *)smallArtworkForFileWithURL:(NSURL *)fileURL
{
    PLCachedArtwork *entity = [[PLCachedArtwork alloc] initWithFileURL:fileURL];
    return [self imageForEntity:entity formatName:PLImageFormatNameSmallArtwork];
}

- (RACSignal *)largeArtworkForMediaItemWithPersistentId:(NSNumber *)persistentId
{
    PLCachedArtwork *entity = [[PLCachedArtwork alloc] initWithPersistentId:persistentId];
    return [self imageForEntity:entity formatName:PLImageFormatNameLargeArtwork];
}

- (RACSignal *)largeArtworkForFileWithURL:(NSURL *)fileURL
{
    PLCachedArtwork *entity = [[PLCachedArtwork alloc] initWithFileURL:fileURL];
    return [self imageForEntity:entity formatName:PLImageFormatNameLargeArtwork];
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