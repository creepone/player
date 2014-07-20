#import "PLPodcast.h"

@implementation PLPodcast

- (NSString *)description
{
    return [NSString stringWithFormat:@"artist = %@\ntitle = %@\nfeedURL = %@\nartworkURL = %@", self.artist, self.title, self.feedURL, self.artworkURL];
}

@end
