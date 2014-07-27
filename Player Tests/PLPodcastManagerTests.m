#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLTestUtils.h"
#import "PLTestCase.h"

#import "PLServiceContainer.h"
#import "PLPodcastsManager.h"
#import "PLNetworkManager.h"
#import "PLDataAccess.h"
#import "PLPodcast.h"
#import "PLPodcastEpisode.h"

@interface PLPodcastManagerTests : PLTestCase
@end

@implementation PLPodcastManagerTests

- (void)setUp
{
    [super setUp];
    [self prepare];
}


- (void)testSearchForPodcasts
{
    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"podcastSearch" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    XCTAssertNotNil(jsonData);
    
    id networkManagerMock = OCMProtocolMock(@protocol(PLNetworkManager));
    OCMStub([networkManagerMock getDataFromURL:OCMOCK_ANY]).andReturn([RACSignal return:jsonData]);
    [self.serviceContainer registerInstance:networkManagerMock underProtocol:@protocol(PLNetworkManager)];
    
    id dataAccessMock = OCMProtocolMock(@protocol(PLDataAccess));
    OCMStub([dataAccessMock existsPodcastPinWithFeedURL:OCMOCK_ANY]).andReturn(NO);
    [self.serviceContainer registerInstance:dataAccessMock underProtocol:@protocol(PLDataAccess)];
    
    PLPodcastsManager *podcastManager = [PLPodcastsManager new];
    [[podcastManager searchForPodcasts:@"debug"] subscribeNext:^(NSArray *podcasts) {
        
        XCTAssertEqual([podcasts count], 6);
        
        PLPodcast *podcast1 = podcasts[0];
        XCTAssertEqualObjects(podcast1.artist, @"Guy English, Rene Ritchie");
        XCTAssertEqualObjects(podcast1.title, @"Debug");
        XCTAssertEqualObjects(podcast1.feedURL, [NSURL URLWithString:@"http://feeds.feedburner.com/debugshow"]);
        XCTAssertEqualObjects(podcast1.artworkURL, [NSURL URLWithString:@"http://a4.mzstatic.com/us/r30/Podcasts/v4/d4/b8/0d/d4b80d10-cb1a-c10a-76d1-49e65e936e96/mza_4768929869289618154.100x100-75.jpg"]);
        XCTAssertEqual(podcast1.pinned, NO);
        
        PLPodcast *podcast2 = podcasts[1];
        XCTAssertEqualObjects(podcast2.artist, @"Michael James Munger");
        XCTAssertEqualObjects(podcast2.title, @"I.T. Marketing Secrets from Debug Your Business");
        XCTAssertEqualObjects(podcast2.feedURL, [NSURL URLWithString:@"http://www.debugyourbusiness.com/rss/debugyourbusiness.xml"]);
        XCTAssertEqualObjects(podcast2.artworkURL, [NSURL URLWithString:@"http://a3.mzstatic.com/us/r30/Podcasts/v4/f9/b5/99/f9b59921-a976-24ff-c2cf-b30f7fca5602/mza_3050272679656225323.100x100-75.jpg"]);
        XCTAssertEqual(podcast2.pinned, NO);
        
        [self notify:kXCTUnitWaitStatusSuccess];

    } error:self.onError];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:10];
}

- (void)testEpisodesInFeed
{
    NSString *feedPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"podcastFeed" ofType:@"xml"];
    NSData *feedData = [NSData dataWithContentsOfFile:feedPath];
    XCTAssertNotNil(feedData);

    NSURL *feedURL = [NSURL URLWithString:@"http://dummy.feed.url"];
    
    id networkManagerMock = OCMProtocolMock(@protocol(PLNetworkManager));
    OCMStub([networkManagerMock getDataFromURL:feedURL]).andReturn([RACSignal return:feedData]);
    [self.serviceContainer registerInstance:networkManagerMock underProtocol:@protocol(PLNetworkManager)];
    
    PLPodcastsManager *podcastManager = [PLPodcastsManager new];
    [[podcastManager episodesInFeed:feedURL] subscribeNext:^(NSArray *episodes) {
        
        XCTAssertEqual([episodes count], 48);

        PLPodcastEpisode *episode1 = episodes[0];
        XCTAssertEqualObjects(episode1.title, @"Debug 42: Swift roundtable");
        XCTAssertEqualObjects(episode1.downloadURL, [NSURL URLWithString:@"http://traffic.libsyn.com/zenandtech/debug42.mp3"]);
        XCTAssertEqualObjects(episode1.guid, @"8514B3FA-5BB5-4DFC-B3AA-A9A09385F960");

        PLPodcastEpisode *episode2 = episodes[1];
        XCTAssertEqualObjects(episode2.title, @"Debug 41: Nitin Ganatra episode III: iPhone to iPad");
        XCTAssertEqualObjects(episode2.downloadURL, [NSURL URLWithString:@"http://traffic.libsyn.com/zenandtech/debug41.mp3"]);
        XCTAssertEqualObjects(episode2.guid, @"D7DA0492-C966-4BCA-B5F0-3C875119899C");

        [self notify:kXCTUnitWaitStatusSuccess];

    } error:self.onError];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:10];
}

@end