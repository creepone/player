#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLUtils.h"
#import "PLTrackWithPosition.h"
#import "PLTrack.h"
#import "PLPlayingViewModel.h"
#import "PLKVOObserver.h"
#import "PLPlayer.h"

@interface PLPlayingViewModel() {
    PLKVOObserver *_playerObserver;
    RACDisposable *_imageArtworkSubscription;
}

@property (strong, nonatomic, readwrite) UIImage *imageArtwork;
@property (strong, nonatomic, readwrite) NSString *titleText;
@property (strong, nonatomic, readwrite) NSString *artistText;
@property (strong, nonatomic, readwrite) UIImage *imagePlayPause;

@end

@implementation PLPlayingViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self updateTrackMetadata];
        [self updateControls];
        
        _playerObserver = [PLKVOObserver observerWithTarget:[PLPlayer sharedPlayer]];
        
        @weakify(self);
        [_playerObserver addKeyPath:@instanceKey(PLPlayer, currentSong) handler:^(id _) { @strongify(self);
            [self updateTrackMetadata];
        }];
        
        [_playerObserver addKeyPath:@instanceKey(PLPlayer, isPlaying) handler:^(id _) { @strongify(self);
            [self updateControls];
        }];
    }
    return self;
}

- (void)updateTrackMetadata
{
    id<PLTrackWithPosition> song = [[PLPlayer sharedPlayer] currentSong];
    
    self.artistText = song.track.artist;
    self.titleText = song.track.title;
    
    if (song == nil)
    {
        self.imageArtwork = nil;
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
}

- (void)makeBookmark
{
    [[PLPlayer sharedPlayer] makeBookmark];
}

@end
