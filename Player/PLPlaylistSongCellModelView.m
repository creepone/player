#import <ReactiveCocoa/ReactiveCocoa.h>
#import <RXPromise/RXPromise.h>
#import "PLPlaylistSongCellModelView.h"
#import "PLPlaylistSong.h"
#import "PLColors.h"
#import "PLPlaylist.h"
#import "PLUtils.h"
#import "PLPlayer.h"
#import "NSObject+PLExtensions.h"

@interface PLPlaylistSongCellModelView() {
    PLPlaylistSong *_playlistSong;
    RACDisposable *_progressTimerSubscription;
}
@end

@implementation PLPlaylistSongCellModelView

- (instancetype)initWithPlaylistSong:(PLPlaylistSong *)playlistSong
{
    self = [super init];
    if (self) {
        _playlistSong = playlistSong;

        self.artistText = playlistSong.artist;
        self.titleText = playlistSong.title;
        [self setupUpdatingProgress];

        @weakify(self);

        playlistSong.smallArtwork.then(^(UIImage *artworkImage) {
            @strongify(self);
            if (!self) return (id)nil;
            self.imageArtwork = artworkImage;
            return (id)nil;
        }, nil);

        RACSignal *songChangeSignal = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kPLPlayerSongChange object:nil] takeUntil:self.rac_willDeallocSignal];
        RACSignal *isPlayingChangeSignal = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kPLPlayerIsPlayingChange object:nil] takeUntil:self.rac_willDeallocSignal];
        RACSignal *willEnterForegroundSignal = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillEnterForegroundNotification object:nil] takeUntil:self.rac_willDeallocSignal];
        RACSignal *didEnterBackgroundSignal = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil] takeUntil:self.rac_willDeallocSignal];

        [songChangeSignal subscribeNext:^(id _){
            [self pl_notifyKvoForKey:@"backgroundColor"];
        }];

        [[RACSignal merge:@[ songChangeSignal, isPlayingChangeSignal, willEnterForegroundSignal ]] subscribeNext:^(id _) {
            [self setupUpdatingProgress];
        }];

        [didEnterBackgroundSignal subscribeNext:^(id _) {
            [self stopUpdatingProgress];
        }];
    }
    return self;
}

- (void)setupUpdatingProgress
{
    [self pl_notifyKvoForKeys:@[ @"progress", @"durationText" ]];

    if (![[PLPlayer sharedPlayer] isPlaying] || ![self isSongCurrent]) {
        [self stopUpdatingProgress];
        return;
    }

    // already checking
    if (_progressTimerSubscription)
        return;

    @weakify(self);
    _progressTimerSubscription = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id _) {
        [self pl_notifyKvoForKeys:@[ @"progress", @"durationText" ]];
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
    return _playlistSong.playlist.currentSong == _playlistSong;
}

- (NSTimeInterval)position
{
    return [self isSongCurrent] ? [[PLPlayer sharedPlayer] currentPosition] : [_playlistSong.position doubleValue];
}


- (UIColor *)backgroundColor
{
    return [self isSongCurrent] ? [PLColors shadeOfGrey:242] : [UIColor whiteColor];
}

- (double)progress
{
    NSTimeInterval position = [self position];
    NSTimeInterval duration = _playlistSong.duration;

    if (_playlistSong.played && position == 0)
        return 1.0;
    else if (duration > 0)
        return MAX(0.0, MIN(1.0, position / duration));

    return 0.0;
}

- (NSString *)durationText
{
    NSTimeInterval position = [self position];
    NSTimeInterval duration = _playlistSong.duration;

    NSString *positionText = [PLUtils formatDuration:position];
    NSString *durationText = [PLUtils formatDuration:duration];

    if (position == 0)
        return durationText;
    else
        return [NSString stringWithFormat:@"%@ / %@", positionText, durationText];
}


- (void)dealloc
{
    [self stopUpdatingProgress];
}

@end