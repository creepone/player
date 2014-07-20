#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPodcastsManager.h"
#import "PLServiceContainer.h"
#import "PLNetworkManager.h"
#import "PLPodcast.h"

@implementation PLPodcastsManager

- (RACSignal *)searchForPodcasts:(NSString *)searchTerm
{
    NSString *escapedSearchTerm = [[searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *searchURLString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&media=podcast", escapedSearchTerm];

    return [[PLResolve(PLNetworkManager) getJSONFromURL:[NSURL URLWithString:searchURLString]] map:^id(id json) {
        NSMutableArray *podcasts = [NSMutableArray array];
        
        if ([json isKindOfClass:[NSDictionary class]]) {
            id results = json[@"results"];
            if ([results isKindOfClass:[NSArray class]]) {
                for (id podcastJson in (NSArray *)results) {
                    if (![podcastJson isKindOfClass:[NSDictionary class]])
                        continue;
                    
                    PLPodcast *podcast = [PLPodcast new];
                    podcast.title = podcastJson[@"collectionName"];
                    podcast.artist = podcastJson[@"artistName"];
                    podcast.feedURL = [NSURL URLWithString:podcastJson[@"feedUrl"]];
                    podcast.artworkURL = [NSURL URLWithString:podcastJson[@"artworkUrl100"]];
                    [podcasts addObject:podcast];
                }
            }
        }
        
        return podcasts;
    }];
}

@end
