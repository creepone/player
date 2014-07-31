#import <Foundation/Foundation.h>

@class PLPlaylistSong;

@interface PLPlayer : NSObject

+ (PLPlayer *)sharedPlayer;

@property (nonatomic, strong) PLPlaylistSong *currentSong;
@property (nonatomic, assign) NSTimeInterval currentPosition;
@property (nonatomic, assign) float playbackRate;
@property (nonatomic, assign, readonly) BOOL isPlaying;

- (void)playPause;
- (void)stop;
- (void)play;
- (void)goBack;
- (void)makeBookmark;

@end
