#import <Foundation/Foundation.h>
#import "PLTrackWithPosition.h"

@class PLBookmark;

@interface PLBookmarkSong : NSObject <PLTrackWithPosition>

- (instancetype)initWithBookmark:(PLBookmark *)bookmark;
+ (instancetype)bookmarkSongWithBookmark:(PLBookmark *)bookmark;

@property (nonatomic, strong) PLBookmark *bookmark;

@end
