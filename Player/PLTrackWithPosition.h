#import <Foundation/Foundation.h>

@class PLTrack, PLPlaylist;

@protocol PLTrackWithPosition <NSObject>

@property (nonatomic, readonly) PLTrack *track;
@property (nonatomic, readonly) NSNumber *playbackRate;
@property (nonatomic, readonly) PLPlaylist *playlist;
@property (nonatomic, readonly) NSNumber *order;

@property (nonatomic, strong) NSNumber *position;

@end
