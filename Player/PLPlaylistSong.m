#import <RXPromise/RXPromise.h>
#import "PLPlaylistSong.h"
#import "PLTrack.h"
#import "PLDefaultsManager.h"

@interface PLPlaylistSong()
@end

@implementation PLPlaylistSong

@dynamic order;
@dynamic position;
@dynamic playlist;
@dynamic playbackRate;
@dynamic track;

- (void)remove
{
    BOOL shouldRemoveTrack = NO;

    // is this a track exclusively owned by this playlist song ?
    if ([self.track.playlistSongs count] == 1) {

        if ([PLDefaultsManager shouldRemoveUnusedTracks])
            shouldRemoveTrack = YES;

        // is this a track that we share with the iTunes Library without mirroring it ?
        if (![PLDefaultsManager mirrorTracks] && self.track.persistentId && !self.track.fileURL)
            shouldRemoveTrack = YES;
    }

    if (shouldRemoveTrack) {
        [self.track remove];
    }

    [self.managedObjectContext deleteObject:self];
}

#pragma mark -- Derived properties

- (BOOL)played
{
    return self.track.played;
}

- (void)setPlayed:(BOOL)played
{
    self.track.played = played;
}

- (NSURL *)assetURL
{
    return self.track.assetURL;
}

- (NSTimeInterval)duration
{
    return self.track.duration;
}

- (NSString *)artist
{
    return self.track.artist;
}

- (NSString *)title
{
    return self.track.title;
}

- (RXPromise *)smallArtwork
{
    return self.track.smallArtwork;
}

- (RXPromise *)largeArtwork
{
    return self.track.largeArtwork;
}

@end
