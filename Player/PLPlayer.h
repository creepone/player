//
//  PLPlayer.h
//  Player
//
//  Created by Tomas Vana on 11/18/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLPlayer : NSObject

+ (PLPlayer *)sharedPlayer;

- (void)playPause;
- (void)stop;
- (void)play;
- (void)goBack;
- (void)setPlaybackRate:(double)rate;

@end
