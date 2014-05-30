@import AVFoundation;
#import "PLTrack.h"
#import "PLMediaLibrarySearch.h"
#import "NSString+Extensions.h"

@implementation PLTrack

@dynamic persistentId;
@dynamic fileURL;
@dynamic downloadURL;
@dynamic played;
@dynamic playlistSongs;


- (MPMediaItem *)mediaItem
{
    if (!self.persistentId)
        return nil;

    return [PLMediaLibrarySearch mediaItemWithPersistentId:@(self.persistentId)];
}

- (AVURLAsset *)asset
{
    if (!self.fileURL)
        return nil;

    return [AVURLAsset assetWithURL:[NSURL URLWithString:self.fileURL]];
}


- (NSURL *)assetURL
{
    MPMediaItem *mediaItem = self.mediaItem;
    if (mediaItem)
        return [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    
    if (self.fileURL)
        return [NSURL URLWithString:self.fileURL];
    
    return nil;
}

- (NSTimeInterval)duration
{
    MPMediaItem *mediaItem = self.mediaItem;
    if (mediaItem)
        return [[mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];

    AVURLAsset *asset = self.asset;
    if (asset) {
        CMTime duration = asset.duration;
        if (duration.timescale > 0)
            return duration.value / duration.timescale;
    }

    return 0;
}

- (NSString *)artist
{
    MPMediaItem *mediaItem = self.mediaItem;
    if (mediaItem) {
        NSString *artist = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
        if ([artist pl_isEmptyOrWhitespace])
            artist = [mediaItem valueForProperty:MPMediaItemPropertyPodcastTitle];
        return artist;
    }

    AVURLAsset *asset = self.asset;
    if (asset) {
        NSArray *artists = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyArtist keySpace:AVMetadataKeySpaceCommon];
        if ([artists count] > 0) {
            AVMetadataItem *artistItem = artists[0];
            return artistItem.stringValue;
        }
    }

    return nil;
}

- (NSString *)title
{
    MPMediaItem *mediaItem = self.mediaItem;
    if (mediaItem) {
        return [mediaItem valueForProperty:MPMediaItemPropertyTitle];
    }

    AVURLAsset *asset = self.asset;
    if (asset) {
        NSArray *titles = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon];
        if ([titles count] > 0) {
            AVMetadataItem *titleItem = titles[0];
            return titleItem.stringValue;
        }
    }

    return nil;
}

- (UIImage *)artworkWithSize:(CGSize)size
{
    MPMediaItem *mediaItem = self.mediaItem;
    if (mediaItem) {
        MPMediaItemArtwork *itemArtwork = [mediaItem valueForProperty:MPMediaItemPropertyArtwork];
        UIImage *imageArtwork = [itemArtwork imageWithSize:size];
        if (imageArtwork)
            return imageArtwork;
    }

    AVURLAsset *asset = self.asset;
    if (asset) {
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
    }

    return [UIImage imageNamed:@"default_artwork.jpg"];
}

@end