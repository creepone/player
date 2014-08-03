#import <ReactiveCocoa/ReactiveCocoa.h>
#import <RaptureXML/RXMLElement.h>
#import "PLPodcastsManager.h"
#import "PLServiceContainer.h"
#import "PLNetworkManager.h"
#import "PLPodcast.h"
#import "PLPodcastEpisode.h"
#import "PLDataAccess.h"

@interface PLPodcastsManager() {
    NSDateFormatter *_pubDateFormatter;
}

@end

@implementation PLPodcastsManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pubDateFormatter = [NSDateFormatter new];
        [_pubDateFormatter setDateFormat:@"EEE, dd MMMM yyyy HH:mm:ss Z"];
    }
    return self;
}


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

- (RACSignal *)episodesForPodcast:(id<PLPodcastPin>)podcastPin
{
    NSURL *feedURL = [NSURL URLWithString:podcastPin.feedURL];
    NSString *artist = podcastPin.artist;
    
    return [[[PLResolve(PLNetworkManager) getDataFromURL:feedURL useEphemeral:YES] flattenMap:^RACStream *(NSData *data) {
        RXMLElement *rootElement = [RXMLElement elementFromXMLData:data];
        
        NSMutableArray * episodes = [NSMutableArray array];
        
        [rootElement iterate:@"channel.item" usingBlock:^(RXMLElement *itemElement) {
            
            PLPodcastEpisode *episode = [PLPodcastEpisode new];
            episode.podcastFeedURL = feedURL;
            episode.artist = artist;
        
            RXMLElement *titleElement = [itemElement child:@"title"];
            episode.title = titleElement.text;
            
            RXMLElement *subtitleElement = [itemElement child:@"subtitle"];
            episode.subtitle = subtitleElement.text;
            
            if (episode.subtitle == nil) {
                RXMLElement *summaryElement = [itemElement child:@"summary"];
                episode.subtitle = summaryElement.text;
            }
            
            if (episode.subtitle == nil) {
                RXMLElement *podcastSummaryElement = [rootElement child:@"channel.summary"];
                episode.subtitle = podcastSummaryElement.text;
            }
            
            if (episode.subtitle == nil) {
                RXMLElement *podcastDescriptionElement = [rootElement child:@"channel.description"];
                episode.subtitle = podcastDescriptionElement.text;
            }
            
            if (episode.subtitle == nil) {
                RXMLElement *podcastTitleElement = [rootElement child:@"channel.title"];
                episode.subtitle = podcastTitleElement.text;
            }
            
            RXMLElement *guidElement = [itemElement child:@"guid"];
            episode.guid = guidElement.text;
            
            RXMLElement *enclosureElement = [itemElement child:@"enclosure"];
            NSString *downloadURL = [enclosureElement attribute:@"url"];
            episode.downloadURL = [NSURL URLWithString:downloadURL];
            
            RXMLElement *pubDateElement = [itemElement child:@"pubDate"];
            episode.publishDate = pubDateElement != nil ? [_pubDateFormatter dateFromString:pubDateElement.text] : nil;

            [episodes addObject:episode];
        }];
        
        return [RACSignal return:episodes];
        
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)episodeGuidsForPodcast:(id<PLPodcastPin>)podcastPin
{
    NSURL *feedURL = [NSURL URLWithString:podcastPin.feedURL];
    
    return [[PLResolve(PLNetworkManager) getDataFromURL:feedURL useEphemeral:YES] flattenMap:^RACStream *(NSData *data) {
        RXMLElement *rootElement = [RXMLElement elementFromXMLData:data];
        
        NSMutableArray *guids = [NSMutableArray array];
        
        [rootElement iterate:@"channel.item" usingBlock:^(RXMLElement *itemElement) {
            RXMLElement *guidElement = [itemElement child:@"guid"];
            NSString *guid = guidElement.text;
            
            if (guid != nil)
                [guids addObject:guid];
        }];
        
        return [RACSignal return:guids];
    }];
}

- (void)updateCounts
{
    [[RACScheduler scheduler] schedule:^{
        PLDataAccess *dataAccess = [[PLDataAccess alloc] initWithNewContext:YES];
        [dataAccess executeForEachPodcastPin:^(PLPodcastPin *podcastPin) {
            [[self episodeGuidsForPodcast:podcastPin] subscribeNext:^(NSArray *episodeGuids) {
            
                int16_t countNewEpisodes = 0;
                
                for (NSString *episodeGuid in episodeGuids) {
                    if (![dataAccess existsPodcastOldEpisodeWithGuid:episodeGuid])
                        countNewEpisodes++;
                }
                
                podcastPin.countNewEpisodes = countNewEpisodes;
                [dataAccess saveChanges:nil];
            }];
        }];
    }];
}

@end
