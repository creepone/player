#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "PLPlayer.h"
#import "PLDataAccess.h"
#import "PLDefaultsManager.h"
#import "PLNotificationObserver.h"
#import "PLErrorManager.h"
#import "NSObject+PLExtensions.h"

@interface PLPlayer() <AVAudioPlayerDelegate> {
    AVAudioPlayer *_audioPlayer;
    PLNotificationObserver *_notificationObserver;
    RACDisposable *_savingPositionSubscription;
}

@end

NSString * const PLPlayerSavedPositionNotification = @"PLPlayerSavedPositionNotification";

@implementation PLPlayer

- (id)init
{
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

+ (PLPlayer *)sharedPlayer
{
    static dispatch_once_t once;
    static PLPlayer *sharedPlayer;
    dispatch_once(&once, ^ { sharedPlayer = [[self alloc] init]; });
    return sharedPlayer;
}

- (PLPlaylistSong *)currentPlaylistSong
{
    PLPlaylist *playlist = [[PLDataAccess sharedDataAccess] selectedPlaylist];
    return playlist.currentSong;
}

- (void)setCurrentSong:(id<PLTrackWithPosition>)song
{
    if (_currentSong == song)
        return;
    
    song.playlist.position = song.order;
    [self save];
    
    [self stop];
    _currentSong = song;
}

- (NSTimeInterval)currentPosition
{
    if (_audioPlayer != nil)
        return _audioPlayer.currentTime;
    
    return _currentSong == nil ? 0 : [_currentSong.position doubleValue];
}

- (void)setCurrentPosition:(NSTimeInterval)position
{
    if (_audioPlayer != nil) {
        _audioPlayer.currentTime = position;
    }
    
    if (_currentSong != nil) {
        _currentSong.position = @(position);
        [self save];
    }
}

- (float)playbackRate
{
    if (_audioPlayer != nil)
        return [_audioPlayer rate];
    
    if (_currentSong != nil) {
        float customRate = [_currentSong.playbackRate floatValue];
        if (customRate > 0.01)
            return customRate;
    }
    
    return [[PLDefaultsManager sharedManager] playbackRate];
}

- (void)setPlaybackRate:(float)rate
{
    if (_audioPlayer != nil) {
        [_audioPlayer setRate:rate];
    }
}

- (BOOL)isPlaying
{
    return [_audioPlayer isPlaying];
}


- (void)playPause
{
    if ([self isPlaying])
        [self pause];
    else
        [self play];
}

- (void)play
{
    if (_currentSong == nil)
        self.currentSong = self.currentPlaylistSong;

    if (_currentSong == nil)
        return;
    
    if (_audioPlayer == nil) {
        NSError *error;
        NSURL *assetURL = _currentSong.track.assetURL;
        
        if (assetURL == nil) {
            [self moveToNextAndPlay];
            return;
        }
        
        float playbackRate = self.playbackRate;
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:assetURL error:&error];
        _audioPlayer.enableRate = YES;
        _audioPlayer.rate = playbackRate;
        _audioPlayer.delegate = self;
    }

    _audioPlayer.currentTime = [_currentSong.position doubleValue];
    [_audioPlayer play];
    
    [self pl_notifyKvoForKey:@"isPlaying"];
    [self startSavingPosition];
}

- (void)stop
{
    if (_currentSong == nil)
        return;
    
    if (_audioPlayer != nil) {
        [self savePosition];
        
        [_audioPlayer stop];
        [_audioPlayer setDelegate:nil];
        _audioPlayer = nil;
        
        [self pl_notifyKvoForKey:@"isPlaying"];
        [self stopSavingPosition];
    }
}

- (void)pause
{
    if (_currentSong == nil)
        return;
    
    [self savePosition];
    [_audioPlayer pause];
    [self pl_notifyKvoForKey:@"isPlaying"];
    [self stopSavingPosition];
}

- (void)goBack
{
    if (_currentSong == nil)
        return;
    
    double delay = [[PLDefaultsManager sharedManager] goBackTime];
    
    double position = self.currentPosition;
    position -= delay;
    
    if (position >= 0) {
        self.currentPosition = position;
        return;
    }
    
    if (_currentSong.playlist == nil) {
        self.currentPosition = 0;
        return;
    }
    
    BOOL wasPlaying = [self isPlaying];
    [self stop];
    
    PLPlaylistSong *song = _currentSong;
    PLPlaylist *playlist = song.playlist;
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
    
    self.currentSong = playlist.currentSong;
    [self save];
    
    if (wasPlaying)
        [self play];
}

- (void)moveToNextAndPlay
{
    if (_currentSong == nil)
        return;
    
    if (_currentSong.playlist == nil) {
        self.currentSong = nil;
        return;
    }
    
    PLPlaylist *playlist = _currentSong.playlist;
    [playlist moveToNextSong];
    
    self.currentSong = playlist.currentSong;
    [self save];
    
    [_audioPlayer setDelegate:nil];
    _audioPlayer = nil;
    [self play];
}


- (void)save
{
    NSError *error;
    [[PLDataAccess sharedDataAccess] saveChanges:&error];
    if (error)
        [PLErrorManager logError:error];
}

- (void)savePosition
{
    if (_currentSong == nil || _audioPlayer == nil)
        return;
    
    _currentSong.position = @(_audioPlayer.currentTime);
    [self save];
}

- (void)startSavingPosition
{
    // already saving
    if (_savingPositionSubscription)
        return;
    
    _savingPositionSubscription = [[RACSignal interval:30.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id _) {
        [self savePosition];
        [[NSNotificationCenter defaultCenter] postNotificationName:PLPlayerSavedPositionNotification object:nil];
    }];
}

- (void)stopSavingPosition
{
    if (_savingPositionSubscription) {
        [_savingPositionSubscription dispose];
        _savingPositionSubscription = nil;
    }
}

- (void)makeBookmark
{
    id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];
    [dataAccess createBookmarkAtPosition:self.currentPosition forTrack:self.currentSong.track];
    [self save];
    
    SystemSoundID mBeep;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jbl_confirm" ofType:@"aiff"];
    NSURL* url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &mBeep);
    AudioServicesPlaySystemSound(mBeep);
    
    // Dispose of the sound
    // AudioServicesDisposeSystemSoundID(mBeep);
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    DDLogVerbose(@"finished playing");
    
    [player setDelegate:nil];
    
    PLPlaylistSong *song = self.currentSong;
    song.position = [NSNumber numberWithDouble:0.0];
    song.track.played = YES;
    
    [self moveToNextAndPlay];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    PLPlaylistSong *song = self.currentSong;
    song.position = [NSNumber numberWithDouble:_audioPlayer.currentTime];
    [self save];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    if(flags == AVAudioSessionInterruptionOptionShouldResume){
        [self play];
    }
}


- (void)dealloc
{
    [_audioPlayer setDelegate:nil];
}

@end
