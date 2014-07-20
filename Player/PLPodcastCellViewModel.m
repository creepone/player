#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPodcastCellViewModel.h"
#import "PLServiceContainer.h"
#import "PLNetworkManager.h"
#import "PLPodcast.h"

@interface PLPodcastCellViewModel() {
    PLPodcast *_podcast;
}

@property (strong, nonatomic, readwrite) UIImage *imageArtwork;
@property (strong, nonatomic, readwrite) NSString *titleText;
@property (strong, nonatomic, readwrite) NSString *artistText;
@property (strong, nonatomic, readwrite) NSAttributedString *infoText;

@end

@implementation PLPodcastCellViewModel

- (instancetype)initWithPodcast:(PLPodcast *)podcast
{
    self = [super init];
    if (self) {
        _podcast = podcast;
        
        self.artistText = podcast.artist;
        self.titleText = podcast.title;
        RAC(self, imageArtwork) = [PLResolve(PLNetworkManager) getImageFromURL:podcast.artworkURL];
    }
    return self;
}

- (NSAttributedString *)infoText
{
    return [[NSAttributedString alloc] initWithString:@""];
}

@end
