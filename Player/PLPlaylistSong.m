//
//  PLPlaylistSong.m
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "PLPlaylistSong.h"
#import "PLPlaylist.h"

@interface PLPlaylistSong() {
    MPMediaItem *_mediaItem;
}
@end


@implementation PLPlaylistSong

@dynamic persistentId;
@dynamic order;
@dynamic position;
@dynamic playlist;

#pragma mark -- Derived properties

- (MPMediaItem *)mediaItem {
    if (_mediaItem == nil) {
        MPMediaQuery *songQuery = [MPMediaQuery songsQuery];
        [songQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:self.persistentId forProperty:MPMediaItemPropertyPersistentID]];
        
        NSArray *songs = [songQuery items];
        if ([songs count] > 0) {
            _mediaItem = [songs objectAtIndex:0];
            return _mediaItem;
        }
        
        MPMediaQuery *podcastQuery = [MPMediaQuery podcastsQuery];
        [podcastQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:self.persistentId forProperty:MPMediaItemPropertyPersistentID]];
        
        NSArray *podcasts = [podcastQuery items];
        if ([podcasts count] > 0) {
            _mediaItem = [podcasts objectAtIndex:0];
            return _mediaItem;
        }
    }
    return _mediaItem;
}

@end
