#import <MediaPlayer/MediaPlayer.h>

@class RXPromise;

@interface PLTrackGroup : NSObject

- (instancetype)initWithType:(MPMediaType)type collection:(MPMediaItemCollection *)collection;

@property (nonatomic, readonly) NSString *artist;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSUInteger trackCount;
@property (nonatomic, readonly) NSTimeInterval duration;

/**
* Resolves to a UIImage with the artwork for this group.
*/
- (RXPromise *)artwork;

/**
* Resolves to an NSArray of the tracks (instances of PLTrack) from this group.
*/
- (RXPromise *)tracks;

@end