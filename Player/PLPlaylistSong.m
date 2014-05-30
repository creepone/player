#import "PLPlaylistSong.h"
#import "PLTrack.h"

@interface PLPlaylistSong()
@end

@implementation PLPlaylistSong

@dynamic order;
@dynamic position;
@dynamic playlist;
@dynamic playbackRate;
@dynamic track;

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

- (UIImage *)artworkWithSize:(CGSize)size
{
    return [self.track artworkWithSize:size];
}

@end
