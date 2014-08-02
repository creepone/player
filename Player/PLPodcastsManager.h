#import <Foundation/Foundation.h>

@protocol PLPodcastPin;

@protocol PLPodcastsManager <NSObject>

/**
 Returns a signal that delivers an NSArray of PLPodcast-s matching the given search term and completes.
 */
- (RACSignal *)searchForPodcasts:(NSString *)searchTerm;

/**
 Returns a signal that delivers an NSArray of PLPodcastEpisode-s in the given feed and completes.
 */
- (RACSignal *)episodesForPodcast:(id<PLPodcastPin>)podcastPin;

/**
 Returns a signal that delivers an NSArray of guids of all the episodes in the given feed and completes.
 */
- (RACSignal *)episodeGuidsForPodcast:(id<PLPodcastPin>)podcastPin;

/**
 Updates the new episodes count for each podcast in the background.
 */
- (void)updateCounts;

@end

@interface PLPodcastsManager : NSObject <PLPodcastsManager>
@end
