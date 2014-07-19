#import <MediaPlayer/MediaPlayer.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLNowPlayingManager.h"
#import "PLPlayer.h"
#import "PLNotificationObserver.h"
#import "PLDataAccess.h"

@interface PLNowPlayingManager() {
    PLNotificationObserver *_observer;
    RACDisposable *_artworkSubscription;
}
@end

@implementation PLNowPlayingManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _observer = [PLNotificationObserver new];
    }
    return self;
}

- (void)startUpdating
{
    @weakify(self);
    [_observer addNotification:kPLPlayerSongChange handler:^(NSNotification *notification) { @strongify(self);
        [self updateInfo];
    }];
    
    [_observer addNotification:PLSelectedPlaylistChange handler:^(NSNotification *notification) { @strongify(self);
        [self updateInfo];
    }];
    
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
