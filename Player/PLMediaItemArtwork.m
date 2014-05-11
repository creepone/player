#import <RXPromise/RXPromise.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FICEntity.h"
#import "PLMediaItemArtwork.h"
#import "FICUtilities.h"
#import "PLMediaLibrarySearch.h"
#import "PLImageCache.h"

@interface PLMediaItemArtwork () {
    NSNumber *_persistentId;
    NSString *_uuid;
}
@end

@implementation PLMediaItemArtwork

- (id)initWithPersistentId:(NSNumber *)persistentId
{
    self = [super init];
    if (self) {
        _persistentId = persistentId;
        CFUUIDBytes bytes = FICUUIDBytesFromMD5HashOfString([persistentId stringValue]);
        _uuid = FICStringWithUUIDBytes(bytes);
    }
    return self;
}

- (NSString *)UUID
{
    return _uuid;
}

- (NSString *)sourceImageUUID
{
    return _uuid;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName
{
    NSString *urlString = [NSString stringWithFormat:@"artwork://%@", _persistentId];
    return [NSURL URLWithString:urlString];
}

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName
{
    FICEntityImageDrawingBlock drawingBlock = ^(CGContextRef context, CGSize contextSize) {
        CGRect contextBounds = CGRectZero;
        contextBounds.size = contextSize;

        UIGraphicsPushContext(context);
        [image drawInRect:contextBounds];
        UIGraphicsPopContext();
    };

    return drawingBlock;
}

+ (UIImage *)imageForURL:(NSURL *)imageURL
{
    NSNumber *persistentId = [NSNumber numberWithInt:[imageURL.host intValue]];
    MPMediaItem *mediaItem = [PLMediaLibrarySearch mediaItemWithPersistentId:persistentId];

    MPMediaItemArtwork *artwork = [mediaItem valueForProperty:MPMediaItemPropertyArtwork];
    return [artwork imageWithSize:[[PLImageCache sharedCache] sizeForImageFormat:PLImageFormatNameSmallArtwork]];
}

@end