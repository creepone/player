#import <MediaPlayer/MediaPlayer.h>

@class RACSignal;

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
* Returns a signal that delivers a UIImage with the artwork for this group, then completes.
*/
- (RACSignal *)artwork;

/**
* Returns a signal that delivers an array of all the PLMediaItemTrack-s from this group, then completes.
*/
- (RACSignal *)tracks;

@end