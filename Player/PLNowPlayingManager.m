#import <MediaPlayer/MediaPlayer.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLNowPlayingManager.h"
#import "PLUtils.h"
#import "PLPlayer.h"
#import "PLKVOObserver.h"
#import "PLDataAccess.h"

@interface PLNowPlayingManager() {
    PLKVOObserver *_playerObserver;
    RACDisposable *_artworkSubscription;
}
@end

@implementation PLNowPlayingManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _playerObserver = [PLKVOObserver observerWithTarget:[PLPlayer sharedPlayer]];
    }
    return self;
}

- (void)startUpdating
{
    @weakify(self);
    [_playerObserver addKeyPath:@instanceKey(PLPlayer, currentSong) handler:^(id _) { @strongify(self); [self updateInfo]; }];
    [_playerObserver addKeyPath:@instanceKey(PLPlayer, isPlaying) handler:^(id _) { @strongify(self); [self updateInfo]; }];
    [_playerObserver addKeyPath:@instanceKey(PLPlayer, currentPosition) handler:^(id _) { @strongify(self); [self updateInfo]; }];
    [_playerObserver addKeyPath:@instanceKey(PLPlayer, playbackRate) handler:^(id _) { @strongify(self); [self updateInfo]; }];
    
    [self updateInfo];
}

- (void)updateInfo
{
    [_artworkSubscription dispose];
    
    PLPlayer *player = [PLPlayer sharedPlayer];
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    PLTrack *track = [[player currentSong] track];
    
    if (track == nil) {
        infoCenter.nowPlayingInfo = nil;
        return;
    }
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:@{
        MPMediaItemPropertyTitle: track.title ? : @"",
        MPMediaItemPropertyArtist: track.artist ? : @"",
        MPMediaItemPropertyPlaybackDuration: @(track.duration),
        MPNowPlayingInfoPropertyElapsedPlaybackTime: @(player.currentPosition),
        MPNowPlayingInfoPropertyPlaybackRate: @(player.playbackRate)
    }];
    
    infoCenter.nowPlayingInfo = info;
    
    _artworkSubscription = [track.largeArtwork subscribeNext:^(UIImage *artwork) {
        if (artwork != nil) {
            info[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:artwork];
            infoCenter.nowPlayingInfo = info;
        }
    }];
}

@end
