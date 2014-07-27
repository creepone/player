#import "PLPodcastOldEpisode.h"
#import "PLPodcastEpisode.h"
#import "PLDataAccess.h"

@implementation PLPodcastOldEpisode

@dynamic title;
@dynamic subtitle;
@dynamic downloadURL;
@dynamic guid;
@dynamic podcastPin;
@dynamic order;

+ (instancetype)oldEpisodeFromEpisode:(PLPodcastEpisode *)episode inContext:(NSManagedObjectContext *)context
{
    PLPodcastOldEpisode *oldEpisode = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
    oldEpisode.title = episode.title;
    oldEpisode.subtitle = episode.subtitle;
    oldEpisode.downloadURL = [episode.downloadURL absoluteString];
    oldEpisode.guid  = episode.guid;
    return oldEpisode;
}

- (PLPodcastEpisode *)episode
{
    PLPodcastEpisode *episode = [PLPodcastEpisode new];
    episode.title = self.title;
    episode.subtitle = self.subtitle;
    episode.downloadURL = [NSURL URLWithString:self.downloadURL];
    episode.guid = self.guid;
    episode.podcastFeedURL = [NSURL URLWithString:self.podcastPin.feedURL];
    return episode;
}

- (void)remove
{
    [self.managedObjectContext deleteObject:self];
}

@end
