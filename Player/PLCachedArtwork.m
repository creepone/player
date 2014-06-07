@import AVFoundation;
#import <MediaPlayer/MediaPlayer.h>
#import "FICEntity.h"
#import "PLCachedArtwork.h"
#import "FICUtilities.h"
#import "PLMediaLibrarySearch.h"
#import "PLImageCache.h"

@interface PLCachedArtwork () {
    NSNumber *_persistentId;
    NSURL *_fileURL;
    NSString *_uuid;
}
@end

@implementation PLCachedArtwork

- (instancetype)initWithPersistentId:(NSNumber *)persistentId
{
    self = [super init];
    if (self) {
        _persistentId = persistentId;
        CFUUIDBytes bytes = FICUUIDBytesFromMD5HashOfString([persistentId stringValue]);
        _uuid = FICStringWithUUIDBytes(bytes);
    }
    return self;
}

- (instancetype)initWithFileURL:(NSURL *)fileURL
{
    self = [super init];
    if (self) {
        _fileURL = fileURL;
        CFUUIDBytes bytes = FICUUIDBytesFromMD5HashOfString([fileURL absoluteString]);
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
    if (_fileURL)
        return _fileURL;

    NSString *urlString = [NSString stringWithFormat:@"media://%@", _persistentId];
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

+ (UIImage *)imageForURL:(NSURL *)imageURL size:(CGSize)size
{
    if ([imageURL.scheme isEqualToString:@"media"]) {
        NSNumber *persistentId = [NSNumber numberWithLongLong:[imageURL.host longLongValue]];
        MPMediaItem *mediaItem = [PLMediaLibrarySearch mediaItemWithPersistentId:persistentId];
        
        MPMediaItemArtwork *artwork = [mediaItem valueForProperty:MPMediaItemPropertyArtwork];
        return [artwork imageWithSize:size];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageURL.path])
        return nil;

    AVURLAsset *asset = [AVURLAsset assetWithURL:imageURL];
    NSArray *artworks = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyArtwork keySpace:AVMetadataKeySpaceCommon];
    for (AVMetadataItem *artworkItem in artworks) {
        if ([artworkItem.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
            NSDictionary *itemMap = (NSDictionary *)[artworkItem.value copyWithZone:nil];
            return [UIImage imageWithData:itemMap[@"data"]];
        } else if ([artworkItem.keySpace isEqualToString:AVMetadataKeySpaceiTunes]) {
            NSData *itemData = (NSData *)[artworkItem.value copyWithZone:nil];
            return [UIImage imageWithData:itemData];
        }
    }

    return nil;
}

@end