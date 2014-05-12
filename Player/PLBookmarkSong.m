//
//  PLBookmarkSong.m
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "PLMediaLibrarySearch.h"
#import "PLBookmarkSong.h"

@interface PLBookmarkSong() {
    MPMediaItem *_mediaItem;
}

@end


@implementation PLBookmarkSong

@dynamic persistentId;
@dynamic title;
@dynamic artist;
@dynamic bookmarks;

- (MPMediaItem *)mediaItem {
    if (_mediaItem == nil) {
        _mediaItem = [PLMediaLibrarySearch mediaItemWithPersistentId:self.persistentId];
    }
    return _mediaItem;
}

@end
