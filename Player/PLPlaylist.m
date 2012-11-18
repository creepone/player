//
//  PLPlaylist.m
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import "PLPlaylist.h"
#import "PLPlaylistSong.h"
#import "PLDataAccess.h"

@interface PLPlaylist()

- (PLPlaylistSong *)findNextSong;

@end

@implementation PLPlaylist

@dynamic name;
@dynamic position;
@dynamic songs;


- (void)addNewSong:(PLPlaylistSong *)song {
    NSInteger index = 0;
    for (PLPlaylistSong *oldSong in self.songs) {
        NSInteger songIndex = [oldSong.order intValue];
        if (songIndex >= index) {
            index = songIndex;
        }
    }
    
    index++;
    [song setOrder:[NSNumber numberWithInt:index]];
    [song setPlaylist:self];
}

- (void)removeSong:(PLPlaylistSong *)song {
    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
    NSInteger order = [song.order intValue];
    [dataAccess deleteObject:song];
    [self removeSongsObject:song];
    
    // if the song we deleted was the current one, reset the current order
    if (order == [self.position intValue])
        self.position = 0;
}

- (void)renumberSongsOrder:(NSArray *)allSongs {
    
    BOOL fixedPosition = NO;
    
    for (int i=0; i<[allSongs count]; i++) {
        PLPlaylistSong *songToChange = [allSongs objectAtIndex:i];
        NSNumber *newOrder = [NSNumber numberWithInt:i + 1];
        
        if (!fixedPosition && [songToChange.order intValue] == [self.position intValue]) {
            self.position = newOrder;
            fixedPosition = YES;
        }
        
        songToChange.order = newOrder;
    }
}

- (void)moveToNextSong {
    NSLog(@"looking for the next song...");
    
    PLPlaylistSong *nextSong = [self findNextSong];
    if (nextSong != nil)
        self.position = nextSong.order;
    else
        self.position = [NSNumber numberWithInt:0];
    
    NSLog(@"found the next song %d", [self.position intValue]);
}

- (PLPlaylistSong *)currentSong {
    NSInteger position = [self.position intValue];
    
    for (PLPlaylistSong *song in self.songs) {
        NSInteger songIndex = [song.order intValue];
        if (songIndex == position)
            return song;
    }
    return nil;
}



- (PLPlaylistSong *)findFirstSong {
    NSInteger minIndex = INT16_MAX;
    PLPlaylistSong *result = nil;
    
    for (PLPlaylistSong *song in self.songs) {
        NSInteger songIndex = [song.order intValue];
        
        if (songIndex < minIndex) {
            result = song;
            minIndex = songIndex;
        }
    }
    
    return result;
}

- (PLPlaylistSong *)findNextSong {
    NSInteger currentIndex = [self.position intValue];
    NSInteger minIndex = INT16_MAX;
    PLPlaylistSong *result = nil;
    
    NSLog(@"Current index = %d", currentIndex);
    
    for (PLPlaylistSong *song in self.songs) {
        NSInteger songIndex = [song.order intValue];

        if (songIndex > currentIndex && songIndex < minIndex) {
            result = song;
            minIndex = songIndex;
        }
    }
    
    return result;
}

@end
