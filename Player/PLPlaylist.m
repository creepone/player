#import "PLPlaylist.h"
#import "PLPlaylistSong.h"
#import "PLDataAccess.h"
#import "PLTrack.h"

@interface PLPlaylist()

- (PLPlaylistSong *)findNextSong;

@end

@implementation PLPlaylist

@dynamic name;
@dynamic position;
@dynamic songs;

- (void)remove
{
    // iterating like this makes sure we also remove associated objects (e.g. tracks)
    for (PLPlaylistSong *song in self.songs) {
        [song remove];
        [self removeSongsObject:song];
    }

    [self.managedObjectContext deleteObject:self];
}

- (void)removeSong:(PLPlaylistSong *)song
{
    NSInteger order = [song.order intValue];

    [song remove];
    [self removeSongsObject:song];

    // if the song we deleted was the current one, reset the current order
    if (order == [self.position intValue])
        self.position = @(0);
}


- (NSInteger)indexForNewSong
{
    NSInteger index = 0;
    for (PLPlaylistSong *oldSong in self.songs) {
        NSInteger songIndex = [oldSong.order intValue];
        if (songIndex >= index) {
            index = songIndex;
        }
    }

    index++;
    return index;
}

- (PLPlaylistSong *)addTrack:(PLTrack *)track
{
    PLPlaylistSong *playlistSong = [NSEntityDescription insertNewObjectForEntityForName:@"PLPlaylistSong" inManagedObjectContext:self.managedObjectContext];
    playlistSong.position = [NSNumber numberWithDouble:0.0];
    playlistSong.track = track;
    playlistSong.playlist = self;
    playlistSong.order = @(self.indexForNewSong);

    return playlistSong;
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

- (void)moveToPreviousSong {
    PLPlaylistSong *previousSong = [self findPreviousSong];
    if (previousSong != nil)
        self.position = previousSong.order;
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
    
    NSLog(@"Current index = %ld", (long)currentIndex);
    
    for (PLPlaylistSong *song in self.songs) {
        NSInteger songIndex = [song.order intValue];

        if (songIndex > currentIndex && songIndex < minIndex) {
            result = song;
            minIndex = songIndex;
        }
    }
    
    return result;
}

- (PLPlaylistSong *)findPreviousSong {
    NSInteger currentIndex = [self.position intValue];
    NSInteger maxIndex = INT16_MIN;
    PLPlaylistSong *result = nil;
    
    NSLog(@"Current index = %ld", (long)currentIndex);
    
    for (PLPlaylistSong *song in self.songs) {
        NSInteger songIndex = [song.order intValue];
        
        if (songIndex < currentIndex && songIndex > maxIndex) {
            result = song;
            maxIndex = songIndex;
        }
    }
    
    return result;
}

@end
