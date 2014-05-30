#import "PLMediaItemTrack.h"

@implementation PLMediaItemTrack

- (instancetype)initWithMediaItem:(MPMediaItem *)mediaItem
{
    self = [super init];
    if (self) {
        _persistentId = [mediaItem valueForProperty:MPMediaItemPropertyPersistentID];
        _title = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
        _duration = [[mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    }
    return self;
}

@end