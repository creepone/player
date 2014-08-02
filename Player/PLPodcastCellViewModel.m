#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPodcastCellViewModel.h"
#import "PLServiceContainer.h"
#import "PLNetworkManager.h"
#import "PLPodcast.h"
#import "PLPodcastPin.h"
#import "PLImageCache.h"

@interface PLPodcastCellViewModel()

@property (strong, nonatomic, readwrite) UIImage *imageArtwork;
@property (strong, nonatomic, readwrite) NSString *titleText;
@property (strong, nonatomic, readwrite) NSString *artistText;
@property (strong, nonatomic, readwrite) NSString *infoText;
@property (assign, nonatomic, readwrite) CGFloat alpha;

@end

@implementation PLPodcastCellViewModel

- (instancetype)initWithPodcast:(PLPodcast *)podcast
{
    self = [super init];
    if (self) {
        self.artistText = podcast.artist;
        self.titleText = podcast.title;
        RAC(self, imageArtwork) = [[PLImageCache sharedCache] smallArtworkForDownloadURL:podcast.artworkURL];
        self.alpha = podcast.pinned ? 0.5 : 1.0;
    }
    return self;
}

- (instancetype)initWithPodcastPin:(PLPodcastPin *)podcastPin
{
    self = [super init];
    if (self) {
        self.artistText = podcastPin.artist;
        self.titleText = podcastPin.title;
        self.infoText = [NSString stringWithFormat:@"%d episode(s)", podcastPin.countNewEpisodes]; // todo: localize + plural definition
        RAC(self, imageArtwork) = [[PLImageCache sharedCache] smallArtworkForDownloadURL:[NSURL URLWithString:podcastPin.artworkURL]];
        self.alpha = 1.0;
    }
    return self;
}

@end
