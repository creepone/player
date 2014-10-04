#import <Foundation/Foundation.h>

@class PLPlaylistSong;
@protocol PLTrackWithPosition;

extern NSString * const PLPlayerSavedPositionNotification;

@interface PLPlayer : NSObject

+ (PLPlayer *)sharedPlayer;

@property (nonatomic, strong) id<PLTrackWithPosition> currentSong;
@property (nonatomic, assign) NSTimeInterval currentPosition;
@property (nonatomic, assign) float playbackRate;
@property (nonatomic, assign, readonly) BOOL isPlaying;

- (void)playPause;
- (void)pause;
- (void)stop;
- (void)play;
- (void)goBack;
- (void)makeBookmark;
- (void)moveToNext;
- (void)moveToPrevious;

@end
