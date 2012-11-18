//
//  PLPlayer.m
//  Player
//
//  Created by Tomas Vana on 11/18/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "PLPlayer.h"
#import "PLDataAccess.h"
#import "PLDefaultsManager.h"
#import "PLAlerts.h"

@interface PLPlayer() <AVAudioPlayerDelegate> {
    AVAudioPlayer *_audioPlayer;
}

- (PLPlaylistSong *)currentSong;
- (void)pause;

@end

@implementation PLPlayer

void audioRouteChangeListenerCallback (void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueSize, const void *inPropertyValue ) {
    // ensure that this callback was invoked for a route change
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    {
        // Determines the reason for the route change, to ensure that it is not
        //      because of a category change.
        CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inPropertyValue;
        
        CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue (routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_Reason) );
        SInt32 routeChangeReason;
        CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
        
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            //Handle Headset Unplugged
            
            PLPlayer *this = (__bridge PLPlayer *)inUserData;
            [this pause];
            
        } else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {
            //Handle Headset plugged in
        }
        
    }
}

- (id)init {
    self = [super init];
    if (self) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, (__bridge void *)(self));
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

- (void)playPause {
    if ([_audioPlayer isPlaying])
        [self pause];
    else
        [self play];
}

- (void)play {
    if (_audioPlayer == nil) {
        NSError *error;
        PLPlaylistSong *song = self.currentSong;
        
        if (song == nil)
            return;
        
        NSURL *songURL = [song.mediaItem valueForProperty:MPMediaItemPropertyAssetURL];        
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:songURL error:&error];
        _audioPlayer.enableRate = YES;
        _audioPlayer.rate = [PLDefaultsManager playbackRate];
        _audioPlayer.currentTime = [song.position doubleValue];
        
        [_audioPlayer setDelegate:self];
    }
    
    [_audioPlayer play];
}

- (void)stop {
    if (_audioPlayer != nil) {
        PLPlaylistSong *song = self.currentSong;
        song.position = [NSNumber numberWithDouble:_audioPlayer.currentTime];
        
        [_audioPlayer stop];
        [_audioPlayer setDelegate:nil];
        _audioPlayer = nil;
        
        NSError *error;
        [[PLDataAccess sharedDataAccess] saveChanges:&error];
        [PLAlerts checkForDataStoreError:error];
    }
}

- (void)pause {
    PLPlaylistSong *song = self.currentSong;
    song.position = [NSNumber numberWithDouble:_audioPlayer.currentTime];

    [_audioPlayer pause];

    NSError *error;
    [[PLDataAccess sharedDataAccess] saveChanges:&error];
    [PLAlerts checkForDataStoreError:error];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [player setDelegate:nil];
    
    PLPlaylistSong *song = self.currentSong;
    song.position = [NSNumber numberWithDouble:0.0];
    
    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
    PLPlaylist *playlist = [dataAccess selectedPlaylist];
    [playlist moveToNextSong];
    
    NSError *error;
    [dataAccess saveChanges:&error];
    [PLAlerts checkForDataStoreError:error];
    
    [_audioPlayer setDelegate:nil];
    _audioPlayer = nil;

    [self play];
}

- (void)setPlaybackRate:(double)rate {
    if (_audioPlayer != nil) {
        [_audioPlayer setRate:rate];
    }
}

- (void)goBack {
    double delay = [PLDefaultsManager goBackTime];
    
    if (_audioPlayer != nil) {
        double position = _audioPlayer.currentTime;        
        position = MAX(position - delay, 0.0);        
        _audioPlayer.currentTime = position;
    }
}


- (void)dealloc {
    [_audioPlayer setDelegate:nil];
}

@end
