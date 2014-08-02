#import "PLPodcastOldEpisode.h"
#import "PLPodcastEpisode.h"
#import "PLDataAccess.h"

NSString * const PLEpisodeMarkedAsNew = @"PLEpisodeMarkedAsNew";

@implementation PLPodcastOldEpisode

@dynamic title;
@dynamic subtitle;
@dynamic downloadURL;
@dynamic guid;
@dynamic podcastPin;
@dynamic publishDate;

+ (instancetype)oldEpisodeFromEpisode:(PLPodcastEpisode *)episode inContext:(NSManagedObjectContext *)context
{
    PLPodcastOldEpisode *oldEpisode = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
    oldEpisode.title = episode.title;
    oldEpisode.subtitle = episode.subtitle;
    oldEpisode.downloadURL = [episode.downloadURL absoluteString];
    oldEpisode.guid  = episode.guid;
    oldEpisode.publishDate = episode.publishDate;
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
    episode.artist = self.podcastPin.artist;
    episode.publishDate = self.publishDate;
    return episode;
}

- (void)remove
{
    NSNotification *notification = [NSNotification notificationWithName:PLEpisodeMarkedAsNew object:nil userInfo:@{ @"guid": self.guid }];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    [self.managedObjectContext deleteObject:self];
}

@end
