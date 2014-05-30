#import <MediaPlayer/MediaPlayer.h>

@interface PLMediaItemTrack : NSObject

- (instancetype)initWithMediaItem:(MPMediaItem *)mediaItem;

@property (nonatomic, readonly) NSNumber *persistentId;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSTimeInterval duration;

@end