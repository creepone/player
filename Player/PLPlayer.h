//
//  PLPlayer.h
//  Player
//
//  Created by Tomas Vana on 11/18/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kPLPlayerSongChange = @"PLPlayerSongChange";
static NSString *kPLPlayerIsPlayingChange = @"PLPlayerIsPlayingChange";

@class PLPlaylistSong;

@interface PLPlayer : NSObject

+ (PLPlayer *)sharedPlayer;
- (PLPlaylistSong *)currentSong;

@property (nonatomic) NSTimeInterval currentPosition;

- (BOOL)isPlaying;
- (void)playPause;
- (void)stop;
- (void)play;
- (void)goBack;
- (void)setPlaybackRate:(double)rate;
- (void)makeBookmark;

@end
