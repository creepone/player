//
//  PLBookmarkSong.m
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "PLBookmarkSong.h"
#import "PLBookmark.h"
#import "PLUtils.h"

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
        _mediaItem = [PLUtils mediaItemForPersistentID:self.persistentId];
    }
    return _mediaItem;
}

@end
