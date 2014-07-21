#import "PLPodcastPin.h"
#import "PLPodcastOldEpisode.h"
#import "PLPodcast.h"

@implementation PLPodcastPin

@dynamic title;
@dynamic artist;
@dynamic artworkURL;
@dynamic feedURL;
@dynamic oldEpisodes;
@dynamic order;

+ (instancetype)podcastPinFromPodcast:(PLPodcast *)podcast inContext:(NSManagedObjectContext *)context
{
    PLPodcastPin *pin = [NSEntityDescription insertNewObjectForEntityForName:[PLPodcastPin entityName] inManagedObjectContext:context];
    pin.title = podcast.title;
    pin.artist = podcast.artist;
    pin.artworkURL = [podcast.artworkURL absoluteString];
    pin.feedURL = [podcast.feedURL absoluteString];
    return pin;
}

- (void)remove
{
    // todo: remove episodes
    [self.managedObjectContext deleteObject:self];
}

@end
