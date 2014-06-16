#import <MediaPlayer/MediaPlayer.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@class RXPromise;

typedef NS_ENUM(NSInteger, PLTrackGroupType) {
    PLTrackGroupTypeAudiobooks,
    PLTrackGroupTypeAlbums,
    PLTrackGroupTypePlaylists,
    PLTrackGroupTypeITunesU,
    PLTrackGroupTypePodcasts
};

@interface PLMediaItemTrackGroup : NSObject

- (instancetype)initWithType:(PLTrackGroupType)type collection:(MPMediaItemCollection *)collection;

@property (nonatomic, readonly) NSString *artist;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSUInteger trackCount;
@property (nonatomic, readonly) NSTimeInterval duration;

/**
* Delivers a UIImage with the artwork for this group, then completes.
*/
- (RACSignal *)artwork;

/**
* Resolves to an NSArray of the tracks (instances of PLMediaItemTrack) from this group.
*/
- (RXPromise *)tracks;

@end