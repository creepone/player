#import "PLBookmarkSong.h"
#import "PLDataAccess.h"

@implementation PLBookmarkSong

- (instancetype)initWithBookmark:(PLBookmark *)bookmark
{
    self = [super init];
    if (self) {
        self.bookmark = bookmark;
    }
    return self;
}

+ (instancetype)bookmarkSongWithBookmark:(PLBookmark *)bookmark
{
    return [[self alloc] initWithBookmark:bookmark];
}

- (PLTrack *)track
{
    return self.bookmark.track;
}

- (NSNumber *)playbackRate
{
    return @0;
}

- (PLPlaylist *)playlist
{
    return nil;
}

- (NSNumber *)order
{
    return @0;
}

- (NSNumber *)position
{
    return self.bookmark.position;
}

- (void)setPosition:(NSNumber *)position
{
    // ignore, as we do not ever want to change the position
}

@end
