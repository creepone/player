#import <ReactiveCocoa/ReactiveCocoa.h>
#import <RaptureXML/RXMLElement.h>
#import "PLPodcastsManager.h"
#import "PLServiceContainer.h"
#import "PLNetworkManager.h"
#import "PLPodcast.h"
#import "PLPodcastEpisode.h"
#import "PLDataAccess.h"

@implementation PLPodcastsManager

- (RACSignal *)searchForPodcasts:(NSString *)searchTerm
{
    NSString *escapedSearchTerm = [[searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *searchURLString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&media=podcast", escapedSearchTerm];

    id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];
    
    return [[[PLResolve(PLNetworkManager) getDataFromURL:[NSURL URLWithString:searchURLString]] deliverOn:[RACScheduler mainThreadScheduler]]
        flattenMap:^RACStream *(NSData *data) {
            NSError *error;
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error)
                return [RACSignal error:error];
            
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
                        podcast.pinned = [dataAccess existsPodcastPinWithFeedURL:podcastJson[@"feedUrl"]];
                        [podcasts addObject:podcast];
                    }
                }
            }
            
            return [RACSignal return:podcasts];
        }];
}

- (RACSignal *)episodesInFeed:(NSURL *)feedURL
{    
    return [[[PLResolve(PLNetworkManager) getDataFromURL:feedURL] flattenMap:^RACStream *(NSData *data) {
        RXMLElement *rootElement = [RXMLElement elementFromXMLData:data];
        
        NSMutableArray * episodes = [NSMutableArray array];
        
        [rootElement iterate:@"channel.item" usingBlock:^(RXMLElement *itemElement) {
            
            PLPodcastEpisode *episode = [PLPodcastEpisode new];
            episode.podcastFeedURL = feedURL;
        
            RXMLElement *titleElement = [itemElement child:@"title"];
            episode.title = titleElement.text;
            
            RXMLElement *subtitleElement = [itemElement child:@"subtitle"];
            episode.subtitle = subtitleElement.text;
            
            if (episode.subtitle == nil) {
                RXMLElement *summaryElement = [itemElement child:@"summary"];
                episode.subtitle = summaryElement.text;
            }
            
            RXMLElement *guidElement = [itemElement child:@"guid"];
            episode.guid = guidElement.text;
            
            RXMLElement *enclosureElement = [itemElement child:@"enclosure"];
            NSString *downloadURL = [enclosureElement attribute:@"url"];
            episode.downloadURL = [NSURL URLWithString:downloadURL];
            
            
            [episodes addObject:episode];
        }];
        
        return [RACSignal return:episodes];
        
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

@end
