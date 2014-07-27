#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPodcastEpisode.h"
#import "PLDataAccess.h"

@implementation PLPodcastEpisode

- (RACSignal *)markAsOld
{
    id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];
    
    PLPodcastOldEpisode *oldEpisode = [dataAccess findOrCreatePodcastOldEpisodeByEpisode:self];
    oldEpisode.order = [[dataAccess findHighestOldEpisodeOrder] longLongValue] + 1;
    oldEpisode.podcastPin = [dataAccess findPodcastPinWithFeedURL:[self.podcastFeedURL absoluteString]];
    
    return [dataAccess saveChangesSignal];
}

@end
