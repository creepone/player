//
//  PLPlaylistSong.m
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

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

#pragma mark -- Derived properties

- (MPMediaItem *)mediaItem {
    if (_mediaItem == nil)
        _mediaItem = [PLMediaLibrarySearch mediaItemWithPersistentId:self.persistentId];
    return _mediaItem;
}

@end
