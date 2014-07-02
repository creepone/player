#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPlaylistSongCellViewModel.h"
#import "PLPlaylistSong.h"
#import "PLColors.h"
#import "PLPlaylist.h"
#import "PLUtils.h"
#import "PLPlayer.h"
#import "NSObject+PLExtensions.h"
#import "PLDownloadManager.h"

@interface PLPlaylistSongCellViewModel () {
    PLPlaylistSong *_playlistSong;
    RACDisposable *_progressTimerSubscription;
}

@property (strong, nonatomic, readwrite) UIImage *imageArtwork;
@property (strong, nonatomic, readwrite) NSString *titleText;
@property (strong, nonatomic, readwrite) NSString *artistText;
@property (assign, nonatomic, readwrite) CGFloat alpha;

@property (strong, nonatomic, readwrite) UIImage *accessoryImage;
@property (strong, nonatomic, readwrite) NSNumber *accessoryProgress;
@property (strong, nonatomic, readwrite) RACCommand *accessoryCommand;

@end

@implementation PLPlaylistSongCellViewModel

- (instancetype)initWithPlaylistSong:(PLPlaylistSong *)playlistSong
{
    self = [super init];
    if (self) {
        _playlistSong = playlistSong;

        [self updateTrackMetadata];
        [self setupUpdatingProgress];
        if (_playlistSong.track.downloadURL)
            [self setupObservingDownload];
        
        RACSignal *songChangeSignal = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kPLPlayerSongChange object:nil] takeUntil:self.rac_willDeallocSignal];
        RACSignal *isPlayingChangeSignal = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kPLPlayerIsPlayingChange object:nil] takeUntil:self.rac_willDeallocSignal];
        RACSignal *willEnterForegroundSignal = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillEnterForegroundNotification object:nil] takeUntil:self.rac_willDeallocSignal];
        RACSignal *didEnterBackgroundSignal = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil] takeUntil:self.rac_willDeallocSignal];
       
        @weakify(self);
        
        [songChangeSignal subscribeNext:^(id _){
            @strongify(self);
            [self pl_notifyKvoForKey:@"backgroundColor"];
        }];

        [[RACSignal merge:@[ songChangeSignal, isPlayingChangeSignal, willEnterForegroundSignal ]] subscribeNext:^(id _) {
            @strongify(self);
            [self setupUpdatingProgress];
        }];

        [didEnterBackgroundSignal subscribeNext:^(id _) {
            @strongify(self);
            [self stopUpdatingProgress];
        }];
    }
    return self;
}

- (void)updateTrackMetadata
{
    self.artistText = _playlistSong.artist;
    self.titleText = _playlistSong.title;
    self.alpha = _playlistSong.assetURL ? 1.f : 0.5f;
    [self pl_notifyKvoForKey:@"durationText"];

    RACSignal *nextUpdateSignal = [self rac_signalForSelector:@selector(updateTrackMetadata)];
    RAC(self, imageArtwork) = [_playlistSong.smallArtwork takeUntil:nextUpdateSignal];
}

- (void)setupObservingDownload
{    
    PLTrack *track = _playlistSong.track;
    if (track.downloadStatus == PLTrackDownloadStatusDone)
        return;
    
    RACSignal *trackWillFaultSignal = [track rac_signalForSelector:@selector(willTurnIntoFault)];
    RACSignal *downloadStatusSignal = [RACObserve(track, downloadStatus) takeUntil:[RACSignal merge:@[self.rac_willDeallocSignal, trackWillFaultSignal]]];
    
    [downloadStatusSignal subscribeNext:^(NSNumber *value) {
        PLTrackDownloadStatus downloadStatus = (PLTrackDownloadStatus)[value shortValue];
        
        switch (downloadStatus)
        {
            case PLTrackDownloadStatusDownloading:
            {
                RAC(self, accessoryProgress) = [[[RACSignal return:@(0.001)] concat:[[PLDownloadManager sharedManager] progressSignalForTrack:track]] takeUntil:[downloadStatusSignal skip:1]];
                self.accessoryImage = nil;
                self.accessoryCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
                    return [[PLDownloadManager sharedManager] cancelDownloadOfTrack:track];
                }];
                break;
            }
            case PLTrackDownloadStatusError:
            {
                self.accessoryProgress = nil;
                self.accessoryImage = [UIImage imageNamed:@"ErrorCircleIcon"];
                self.accessoryCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
                    return [[PLDownloadManager sharedManager] enqueueDownloadOfTrack:track];
                }];
                break;
            }
            case PLTrackDownloadStatusIdle:
            {
                self.accessoryProgress = nil;
                self.accessoryImage = [UIImage imageNamed:@"DownloadPlainIcon"];
                self.accessoryCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
                    return [[PLDownloadManager sharedManager] enqueueDownloadOfTrack:track];
                }];
                break;
            }
            case PLTrackDownloadStatusDone:
            {
                self.accessoryProgress = nil;
                self.accessoryImage = nil;
                self.accessoryCommand = nil;
                [self updateTrackMetadata];
                break;
            }
        }
    }];
}

- (void)setupUpdatingProgress
{
    [self pl_notifyKvoForKeys:@[ @"playbackProgress", @"durationText" ]];

    if (![[PLPlayer sharedPlayer] isPlaying] || ![self isSongCurrent]) {
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

- (double)playbackProgress
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

    if (duration == 0)
        return @"";
    else if (position == 0)
        return durationText;
    else
        return [NSString stringWithFormat:@"%@ / %@", positionText, durationText];
}


- (void)dealloc
{
    [self stopUpdatingProgress];
}

@end