#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPodcastEpisode.h"
#import "PLDataAccess.h"

NSString * const PLEpisodeMarkedAsOld = @"PLEpisodeMarkedAsOld";

@implementation PLPodcastEpisode

- (RACSignal *)markAsOld
{
    id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];
    PLPodcastOldEpisode *oldEpisode = [dataAccess findOrCreatePodcastOldEpisodeByEpisode:self];
    oldEpisode.podcastPin = [dataAccess findPodcastPinWithFeedURL:[self.podcastFeedURL absoluteString]];
    
    NSNotification *notification = [NSNotification notificationWithName:PLEpisodeMarkedAsOld object:nil userInfo:@{ @"episode": oldEpisode }];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    return [[PLDataAccess sharedDataAccess] saveChangesSignal];
}

@end
