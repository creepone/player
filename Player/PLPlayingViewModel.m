#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLUtils.h"
#import "PLTrackWithPosition.h"
#import "PLTrack.h"
#import "PLPlayingViewModel.h"
#import "PLKVOObserver.h"
#import "PLPlayer.h"
#import "PLNotificationObserver.h"
#import "NSObject+PLExtensions.h"

@interface PLPlayingViewModel() {
    PLKVOObserver *_playerObserver;
    PLNotificationObserver *_notificationObserver;
    RACDisposable *_imageArtworkSubscription;
    RACDisposable *_progressTimerSubscription;
}

@property (strong, nonatomic, readwrite) UIImage *imageArtwork;
@property (strong, nonatomic, readwrite) NSString *titleText;
@property (strong, nonatomic, readwrite) NSString *artistText;
@property (strong, nonatomic, readwrite) UIImage *imagePlayPause;
@property (assign, nonatomic, readwrite) BOOL hasTrack;

@end

@implementation PLPlayingViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setupUpdatingProgress];
        [self updateTrackMetadata];
        [self updateControls];
        
        _playerObserver = [PLKVOObserver observerWithTarget:[PLPlayer sharedPlayer]];
        _notificationObserver = [PLNotificationObserver observer];
        
        @weakify(self);
        [_playerObserver addKeyPath:@instanceKey(PLPlayer, currentSong) handler:^(id _) { @strongify(self);
            [self updateTrackMetadata];
            [self setupUpdatingProgress];
        }];
        
        [_playerObserver addKeyPath:@instanceKey(PLPlayer, isPlaying) handler:^(id _) { @strongify(self);
            [self updateControls];
            [self setupUpdatingProgress];
        }];
        
        [_notificationObserver addNotification:UIApplicationWillEnterForegroundNotification handler:^(id _) { @strongify(self);
            [self setupUpdatingProgress];
        }];
        
        [_notificationObserver addNotification:UIApplicationDidEnterBackgroundNotification handler:^(id _) { @strongify(self);
            [self stopUpdatingProgress];
        }];
        
    }
    return self;
}

- (void)setupUpdatingProgress
{
    [self pl_notifyKvoForKeys:@[ @"playbackProgress", @"durationText" ]];
    
    PLPlayer *player = [PLPlayer sharedPlayer];
    if (!player.isPlaying) {
        [self stopUpdatingProgress];
        return;
    }
    
    // already checking
    if (_progressTimerSubscription)
        return;
    
    _progressTimerSubscription = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id _) {
        [self pl_notifyKvoForKeys:@[ @"playbackProgress", @"durationText" ]];
    }];
}

- (void)stopUpdatingProgress
{
    if (_progressTimerSubscription) {
        [_progressTimerSubscription dispose];
        _progressTimerSubscription = nil;
    }
}

- (void)updateTrackMetadata
{
    id<PLTrackWithPosition> song = [[PLPlayer sharedPlayer] currentSong];
    
    self.artistText = song.track.artist;
    self.titleText = song.track.title;
    
    if (song == nil)
    {
        self.imageArtwork = nil;
        self.hasTrack = NO;
    }
    else
    {
        self.hasTrack = YES;
    }
    
    [_imageArtworkSubscription dispose];
    @weakify(self);
    _imageArtworkSubscription = [song.track.largeArtwork subscribeNext:^(UIImage *image) { @strongify(self);
        self.imageArtwork = image;
    }];
}

- (void)updateControls
{
    if ([[PLPlayer sharedPlayer] isPlaying]) {
        self.imagePlayPause = [UIImage imageNamed:@"Pause"];
    }
    else {
        self.imagePlayPause = [UIImage imageNamed:@"Play-1"];
    }
}

- (void)playPause
{
    [[PLPlayer sharedPlayer] playPause];
}

- (void)goBack
{
    [[PLPlayer sharedPlayer] goBack];
    [self pl_notifyKvoForKeys:@[ @"playbackProgress", @"durationText" ]];
}

- (void)moveToPrevious
{
    [[PLPlayer sharedPlayer] moveToPrevious];
}

- (void)moveToNext
{
    [[PLPlayer sharedPlayer] moveToNext];
}

- (void)skipToStart
{
    [[PLPlayer sharedPlayer] setCurrentPosition:0];
    [self pl_notifyKvoForKeys:@[ @"playbackProgress", @"durationText" ]];
}

- (void)makeBookmark
{
    [[PLPlayer sharedPlayer] makeBookmark];
}


- (double)playbackProgress
{
    PLPlayer *player = [PLPlayer sharedPlayer];
    
    NSTimeInterval position = player.currentPosition;
    NSTimeInterval duration = player.currentSong.track.duration;
    
    if (duration > 0)
        return MAX(0.0, MIN(1.0, position / duration));
    
    return 0.0;
}

- (void)setPlaybackProgress:(double)playbackProgress
{
    PLPlayer *player = [PLPlayer sharedPlayer];
    if (player.currentSong == nil)
        return;
    
    NSTimeInterval duration = player.currentSong.track.duration;
    double updatedPosition = duration * playbackProgress;
    if (updatedPosition > duration - 1.0)
        updatedPosition = duration - 1.0;
    
    [player setCurrentPosition:updatedPosition];
    [self pl_notifyKvoForKey:@"durationText"];
}

- (NSString *)durationText
{
    PLPlayer *player = [PLPlayer sharedPlayer];
    
    NSTimeInterval position = player.currentPosition;
    NSTimeInterval duration = player.currentSong.track.duration;
    
    NSString *positionText = [PLUtils formatDuration:position];
    NSString *durationText = [PLUtils formatDuration:duration];
    
    if (duration == 0)
        return @"";
    else
        return [NSString stringWithFormat:@"%@ / %@", positionText, durationText];
}


- (void)dealloc
{
    _playerObserver = nil;
    [self stopUpdatingProgress];
}

@end
