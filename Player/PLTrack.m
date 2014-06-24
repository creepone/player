@import AVFoundation;
#import <RXPromise/RXPromise.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLTrack.h"
#import "PLMediaLibrarySearch.h"
#import "NSString+Extensions.h"
#import "PLImageCache.h"
#import "PLErrorManager.h"

@interface PLTrack()

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *title;

@end

@implementation PLTrack

@dynamic persistentId;
@dynamic fileURL;
@dynamic downloadURL;
@dynamic played;
@dynamic playlistSongs;
@dynamic duration;
@dynamic artist;
@dynamic title;

+ (PLTrack *)trackWithPersistentId:(NSNumber *)persistentId inContext:(NSManagedObjectContext *)context
{
    PLTrack *track = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
    track.persistentId = [persistentId longLongValue];
    [track setMetadataFromMediaItem];
    return track;
}

+ (PLTrack *)trackWithFileURL:(NSString *)fileURL inContext:(NSManagedObjectContext *)context
{
    PLTrack *track = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
    track.fileURL = fileURL;
    [track setMetadataFromAsset];
    return track;
}

- (void)remove
{
    if (self.fileURL) {
        NSURL *fileURL = [NSURL URLWithString:self.fileURL];

        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
        if (error)
            [PLErrorManager logError:error];
    }

    [self.managedObjectContext deleteObject:self];
}


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

    NSURL *fileURL = [NSURL URLWithString:self.fileURL];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileURL.path])
        return nil;

    return [AVURLAsset assetWithURL:fileURL];
}

- (NSURL *)assetURL
{
    MPMediaItem *mediaItem = self.mediaItem;
    if (mediaItem)
        return [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    
    if (self.fileURL) {
        NSURL *fileURL = [NSURL URLWithString:self.fileURL];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileURL.path])
            return nil;
        
        return fileURL;
    }
    
    return nil;
}


- (void)setMetadataFromMediaItem
{
    MPMediaItem *mediaItem = self.mediaItem;

    if (mediaItem) {
        self.duration = [[mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
        self.title = [mediaItem valueForProperty:MPMediaItemPropertyTitle];

        NSString *artist = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
        if ([artist pl_isEmptyOrWhitespace])
            artist = [mediaItem valueForProperty:MPMediaItemPropertyPodcastTitle];
        self.artist = artist;
    }
}

- (void)setMetadataFromAsset
{
    AVURLAsset *asset = self.asset;

    if (asset) {
        CMTime duration = asset.duration;
        if (duration.timescale > 0)
            self.duration = duration.value / duration.timescale;

        NSArray *artists = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyArtist keySpace:AVMetadataKeySpaceCommon];
        if ([artists count] > 0) {
            AVMetadataItem *artistItem = artists[0];
            self.artist = artistItem.stringValue;
        }

        NSArray *titles = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon];
        if ([titles count] > 0) {
            AVMetadataItem *titleItem = titles[0];
            self.title = titleItem.stringValue;
        }
        
        if (!self.title) {
            NSURL *fileURL = [NSURL URLWithString:self.fileURL];
            self.title = [[fileURL.path lastPathComponent] stringByDeletingPathExtension];
        }
    }
}


- (RACSignal *)smallArtwork
{
    if (self.persistentId)
        return [[PLImageCache sharedCache] smallArtworkForMediaItemWithPersistentId:@(self.persistentId)];

    if (self.fileURL)
        return [[PLImageCache sharedCache] smallArtworkForFileWithURL:[NSURL URLWithString:self.fileURL]];

    return [RACSignal empty];
}

- (RACSignal *)largeArtwork
{
    if (self.persistentId)
        return [[PLImageCache sharedCache] largeArtworkForMediaItemWithPersistentId:@(self.persistentId)];

    if (self.fileURL)
        return [[PLImageCache sharedCache] largeArtworkForFileWithURL:[NSURL URLWithString:self.fileURL]];

    return [RACSignal empty];
}

@end