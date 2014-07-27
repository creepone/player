#import <Foundation/Foundation.h>

@protocol PLPodcastsManager <NSObject>

/**
 Returns a signal that delivers an NSArray of PLPodcast-s matching the given search term and completes.
 */
- (RACSignal *)searchForPodcasts:(NSString *)searchTerm;

/**
 Returns a signal that delivers an NSArray of PLPodcastEpisode-s in the given feed and completes.
 */
- (RACSignal *)episodesInFeed:(NSURL *)feedURL;

@end

@interface PLPodcastsManager : NSObject <PLPodcastsManager>
@end
