#import <MediaPlayer/MediaPlayer.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLNowPlayingManager.h"
#import "PLUtils.h"
#import "PLPlayer.h"
#import "PLKVOObserver.h"
#import "PLNotificationObserver.h"
#import "PLDataAccess.h"

@interface PLNowPlayingManager() {
    PLKVOObserver *_playerObserver;
    PLNotificationObserver *_notificationObserver;
    RACDisposable *_artworkSubscription;
    
    PLTrack *_currentTrack;
    MPMediaItemArtwork *_currentArtwork;
}
@end

@implementation PLNowPlayingManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _playerObserver = [PLKVOObserver observerWithTarget:[PLPlayer sharedPlayer]];
        _notificationObserver = [PLNotificationObserver observer];
    }
    return self;
}

- (void)startUpdating
{
    @weakify(self);
    [_playerObserver addKeyPath:@instanceKey(PLPlayer, currentSong) handler:^(id _) { @strongify(self); [self updateInfo:@"currentSong"]; }];
    [_playerObserver addKeyPath:@instanceKey(PLPlayer, isPlaying) handler:^(id _) { @strongify(self); [self updateInfo:@"isPlaying"]; }];
    [_playerObserver addKeyPath:@instanceKey(PLPlayer, currentPosition) handler:^(id _) { @strongify(self); [self updateInfo:@"currentPosition"]; }];
    [_playerObserver addKeyPath:@instanceKey(PLPlayer, playbackRate) handler:^(id _) { @strongify(self); [self updateInfo:@"playbackRate"]; }];
    
    [_notificationObserver addNotification:PLPlayerSavedPositionNotification handler:^(id _) { @strongify(self); [self updateInfo:@"savedPosition"]; }];
    
    [self updateInfo:@"start"];
}

- (void)updateInfo:(NSString *)reason
{
    PLPlayer *player = [PLPlayer sharedPlayer];
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    PLTrack *track = [[player currentSong] track];
    
    if (track == nil) {
        _currentTrack = nil;
        _currentArtwork = nil;
        [_artworkSubscription dispose];
        
        DDLogInfo(@"Updated now playing (%@) to nil", reason);
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
    
    if (track == _currentTrack) {
        if (_currentArtwork)
            info[MPMediaItemPropertyArtwork] = _currentArtwork;
    }
    else {
        _currentTrack = track;
        _currentArtwork = nil;
        
        [_artworkSubscription dispose];
        _artworkSubscription = [track.largeArtwork subscribeNext:^(UIImage *artwork) {
            _currentArtwork = artwork ? [[MPMediaItemArtwork alloc] initWithImage:artwork] : nil;
            
            if (_currentArtwork != nil && track == _currentTrack) {
                info[MPMediaItemPropertyArtwork] = _currentArtwork;
                infoCenter.nowPlayingInfo = info;
            }
        }];
    }
    
    infoCenter.nowPlayingInfo = info;
    DDLogInfo(@"Updated now playing (%@) = %@", reason, info);
}

@end
