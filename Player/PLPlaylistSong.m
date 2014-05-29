#import <MediaPlayer/MediaPlayer.h>

#import "PLPlaylistSong.h"
#import "PLMediaLibrarySearch.h"

@interface PLPlaylistSong() {
    MPMediaItem *_mediaItem;
}
@end


@implementation PLPlaylistSong

@dynamic persistentId;
@dynamic order;
@dynamic position;
@dynamic playlist;
@dynamic playbackRate;
@dynamic played;
@dynamic downloadURL;
@dynamic fileURL;

#pragma mark -- Derived properties

- (MPMediaItem *)mediaItem {
    if (_mediaItem == nil)
        _mediaItem = [PLMediaLibrarySearch mediaItemWithPersistentId:self.persistentId];
    return _mediaItem;
}

@end
