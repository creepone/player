#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "PLPlayer.h"
#import "PLDataAccess.h"
#import "PLDefaultsManager.h"
#import "PLAlerts.h"
#import "PLNotificationObserver.h"

@interface PLPlayer() <AVAudioPlayerDelegate> {
    AVAudioPlayer *_audioPlayer;
    PLNotificationObserver *_notificationObserver;
}

- (void)pause;
- (void)save;

@end

@implementation PLPlayer

- (id)init {
    self = [super init];
    if (self) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        _notificationObserver = [PLNotificationObserver observer];
        @weakify(self);
        [_notificationObserver addNotification:AVAudioSessionRouteChangeNotification handler:^(NSNotification *notification) { @strongify(self);
            NSInteger routeChangeReason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
            if (routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
                [self pause];
            }
        }];
    }
    return self;
}

+ (PLPlayer *)sharedPlayer {
    static dispatch_once_t once;
    static PLPlayer *sharedPlayer;
    dispatch_once(&once, ^ { sharedPlayer = [[self alloc] init]; });
    return sharedPlayer;
}

- (PLPlaylistSong *)currentSong {
    PLPlaylist *playlist = [[PLDataAccess sharedDataAccess] selectedPlaylist];
    return playlist.currentSong;
}

- (void)setCurrentSong:(PLPlaylistSong *)song
{
    // todo: this only works if the song's playlist is currently selected. that is probably ok but later we have to deal with cases like there is no playlist etc.
    if (song.playlist.currentSong == song)
        return;

    [self stop];

    song.playlist.position = song.order;

    [self save];

    [[NSNotificationCenter defaultCenter] postNotificationName:kPLPlayerSongChange object:nil];

    [self play];
}

- (NSTimeInterval)currentPosition {
    if (_audioPlayer != nil)
        return _audioPlayer.currentTime;
    else {
        PLPlaylistSong *song = self.currentSong;
        if (song == nil)
            return 0;
        return [song.position doubleValue];
    }
}

- (void)setCurrentPosition:(NSTimeInterval)position {
    if (_audioPlayer != nil) {
        _audioPlayer.currentTime = position;
    }
}


- (BOOL)isPlaying {
    return [_audioPlayer isPlaying];
}

- (void)playPause {
    if ([_audioPlayer isPlaying])
        [self pause];
    else
        [self play];
}

- (void)play {
    PLPlaylistSong *song = self.currentSong;
    if (song == nil)
        return;
    
    if (_audioPlayer == nil) {
        NSError *error;
        NSURL *assetURL = song.assetURL;
        
        if (assetURL == nil) {
            [self moveToNextAndPlay];
            return;
        }

        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:assetURL error:&error];
        _audioPlayer.enableRate = YES;
        
        double customRate = [song.playbackRate doubleValue];
        if (customRate > 0.01) {
            _audioPlayer.rate = customRate;
        }
        else {
            _audioPlayer.rate = [[PLDefaultsManager sharedManager] playbackRate];
        }

        [_audioPlayer setDelegate:self];
    }
    
    _audioPlayer.currentTime = [song.position doubleValue];
    [_audioPlayer play];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPLPlayerIsPlayingChange object:nil];
}

- (void)stop {
    if (_audioPlayer != nil) {
        PLPlaylistSong *song = self.currentSong;
        song.position = [NSNumber numberWithDouble:_audioPlayer.currentTime];
        
        [_audioPlayer stop];
        [_audioPlayer setDelegate:nil];
        _audioPlayer = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPLPlayerIsPlayingChange object:nil];
        
        [self save];
    }
}

- (void)pause {
    PLPlaylistSong *song = self.currentSong;
    song.position = [NSNumber numberWithDouble:_audioPlayer.currentTime];

    [_audioPlayer pause];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPLPlayerIsPlayingChange object:nil];

    [self save];
}

- (void)setPlaybackRate:(double)rate {
    if (_audioPlayer != nil) {
        [_audioPlayer setRate:rate];
    }
}

- (void)goBack {
    double delay = [[PLDefaultsManager sharedManager] goBackTime];
    
    if (_audioPlayer != nil) {
        double position = _audioPlayer.currentTime;        
        position = position - delay;
        
        if (position >= 0) {
            _audioPlayer.currentTime = position;
            return;
        }
        
        [self stop];
        
        PLPlaylist *playlist = [[PLDataAccess sharedDataAccess] selectedPlaylist];
        
        PLPlaylistSong *song = playlist.currentSong;
        song.position = @0;
        [playlist moveToPreviousSong];

        while (playlist.currentSong != song) {
            NSTimeInterval duration = playlist.currentSong.duration;
            position += duration;
            
            if (position >= 0) {
                playlist.currentSong.position = @(position);
                break;
            }
            
            song = playlist.currentSong;
            song.position = @0;
            [playlist moveToPreviousSong];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPLPlayerSongChange object:nil];
        [self save];
        
        [self play];
    }
}

- (void)makeBookmark {
    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
    [dataAccess addBookmarkAtPosition:self.currentPosition forTrack:self.currentSong.track];
    [self save];

    // ivar
    SystemSoundID mBeep;
    
    // Create the sound ID
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jbl_confirm" ofType:@"aiff"];
    NSURL* url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &mBeep);
    
    // Play the sound
    AudioServicesPlaySystemSound(mBeep);
    
    
    // Dispose of the sound
    //AudioServicesDisposeSystemSoundID(mBeep);
}

- (void)save {
    NSError *error;
    [[PLDataAccess sharedDataAccess] saveChanges:&error];
    [PLAlerts checkForDataStoreError:error];
}

- (void)moveToNextAndPlay
{
    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
    PLPlaylist *playlist = [dataAccess selectedPlaylist];
    [playlist moveToNextSong];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPLPlayerSongChange object:nil];
    
    [self save];
    
    [_audioPlayer setDelegate:nil];
    _audioPlayer = nil;
    [self play];
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [player setDelegate:nil];
    
    PLPlaylistSong *song = self.currentSong;
    song.position = [NSNumber numberWithDouble:0.0];
    song.played = YES;
    
    [self moveToNextAndPlay];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    PLPlaylistSong *song = self.currentSong;
    song.position = [NSNumber numberWithDouble:_audioPlayer.currentTime];
    [self save];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    if(flags == AVAudioSessionInterruptionOptionShouldResume){
        [self play];
    }
}



- (void)dealloc {
    [_audioPlayer setDelegate:nil];
}

@end
