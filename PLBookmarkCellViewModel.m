#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLBookmarkCellViewModel.h"
#import "PLDataAccess.h"
#import "PLUtils.h"
#import "NSObject+PLExtensions.h"
#import "PLPlayer.h"
#import "PLBookmarkSong.h"
#import "PLKVOObserver.h"
#import "PLNotificationObserver.h"
#import "PLColors.h"

@interface PLBookmarkCellViewModel() {
    PLBookmarkSong *_bookmarkSong;
    RACDisposable *_imageArtworkSubscription;
    RACDisposable *_progressTimerSubscription;
    PLKVOObserver *_playerObserver;
    PLNotificationObserver *_notificationObserver;
}

@property (strong, nonatomic, readwrite) UIImage *imageArtwork;
@property (strong, nonatomic, readwrite) NSString *titleText;
@property (strong, nonatomic, readwrite) NSString *artistText;
@property (assign, nonatomic, readwrite) CGFloat alpha;

@end

@implementation PLBookmarkCellViewModel

- (instancetype)initWithBookmarkSong:(PLBookmarkSong *)bookmarkSong
{
    self = [super init];
    if (self) {
        _bookmarkSong = bookmarkSong;
        
        [self updateTrackMetadata];
        [self setupUpdatingProgress];
        
        _notificationObserver = [PLNotificationObserver observer];
        _playerObserver = [PLKVOObserver observerWithTarget:[PLPlayer sharedPlayer]];
        
        @weakify(self);
        [_playerObserver addKeyPath:@instanceKey(PLPlayer, currentSong) handler:^(id _) { @strongify(self);
            [self pl_notifyKvoForKey:@"backgroundColor"];
            [self setupUpdatingProgress];
        }];
        
        [_playerObserver addKeyPath:@instanceKey(PLPlayer, isPlaying) handler:^(id _) { @strongify(self);
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

- (void)updateTrackMetadata
{
    self.artistText = _bookmarkSong.track.artist;
    self.titleText = _bookmarkSong.track.title;
    self.alpha = _bookmarkSong.track.assetURL ? 1.f : 0.5f;
    [self pl_notifyKvoForKey:@"durationText"];
    
    [_imageArtworkSubscription dispose];
    @weakify(self);
    _imageArtworkSubscription = [_bookmarkSong.track.smallArtwork subscribeNext:^(UIImage *image) { @strongify(self);
        self.imageArtwork = image;
    }];
}

- (void)setupUpdatingProgress
{
    [self pl_notifyKvoForKeys:@[ @"playbackProgress", @"durationText" ]];
    
    PLPlayer *player = [PLPlayer sharedPlayer];
    BOOL isPlayingThisSong = NO;
    
    if (player.isPlaying && [player.currentSong isKindOfClass:[PLBookmarkSong class]]) {
        PLBookmarkSong *currentBookmarkSong = (PLBookmarkSong *)player.currentSong;
        isPlayingThisSong = currentBookmarkSong.bookmark == _bookmarkSong.bookmark;
    }
    
    if (!isPlayingThisSong) {
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


- (BOOL)isSongCurrent
{
    PLPlayer *player = [PLPlayer sharedPlayer];
    if (![player.currentSong isKindOfClass:[PLBookmarkSong class]])
        return NO;
    
    PLBookmarkSong *currentBookmarkSong = (PLBookmarkSong *)player.currentSong;
    return currentBookmarkSong.bookmark == _bookmarkSong.bookmark;
}

- (NSTimeInterval)position
{
    PLPlayer *player = [PLPlayer sharedPlayer];
    return [self isSongCurrent] ? player.currentPosition : [_bookmarkSong.position doubleValue];
}


- (UIColor *)backgroundColor
{
    return [self isSongCurrent] ? [PLColors shadeOfGrey:242] : [UIColor whiteColor];
}

- (double)playbackProgress
{
    NSTimeInterval position = [self position];
    NSTimeInterval duration = _bookmarkSong.track.duration;
    
    if (duration > 0)
        return MAX(0.0, MIN(1.0, position / duration));
    
    return 0.0;
}

- (double)bookmarkPosition
{
    NSTimeInterval position = [_bookmarkSong.bookmark.position doubleValue];
    NSTimeInterval duration = _bookmarkSong.track.duration;
    
    if (duration > 0)
        return MAX(0.0, MIN(1.0, position / duration));
    
    return 0.0;
}

- (NSString *)durationText
{
    NSTimeInterval position = [self position];
    NSTimeInterval duration = _bookmarkSong.track.duration;
    
    NSString *positionText = [PLUtils formatDuration:position];
    NSString *durationText = [PLUtils formatDuration:duration];
    
    if (duration == 0)
        return @"";
    else if (position == 0)
        return durationText;
    else
        return [NSString stringWithFormat:@"%@ / %@", positionText, durationText];
}

- (void)selectCell
{
    PLPlayer *player = [PLPlayer sharedPlayer];
    [player setCurrentSong:_bookmarkSong];
    [player play];
}


- (void)dealloc
{
    _playerObserver = nil;
    [self stopUpdatingProgress];
}

@end
