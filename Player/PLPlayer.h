#import <Foundation/Foundation.h>

static NSString *kPLPlayerSongChange = @"PLPlayerSongChange";
static NSString *kPLPlayerIsPlayingChange = @"PLPlayerIsPlayingChange";

@class PLPlaylistSong;

@interface PLPlayer : NSObject

+ (PLPlayer *)sharedPlayer;

@property (nonatomic) PLPlaylistSong *currentSong;
@property (nonatomic) NSTimeInterval currentPosition;
@property (nonatomic) float playbackRate;

- (BOOL)isPlaying;
- (void)playPause;
- (void)stop;
- (void)play;
- (void)goBack;
- (void)makeBookmark;

@end
