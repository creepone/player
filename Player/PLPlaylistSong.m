#import <ReactiveCocoa/ReactiveCocoa.h>
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
    // is this a track exclusively owned by this playlist song ?
    if ([self.track.playlistSongs count] == 1)
        [self.track remove];

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

- (RACSignal *)smallArtwork
{
    return self.track.smallArtwork;
}

- (RACSignal *)largeArtwork
{
    return self.track.largeArtwork;
}

@end
