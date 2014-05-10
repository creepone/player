#import "PLDownloadPodcastActivity.h"
#import "PLPromise.h"

@implementation PLDownloadPodcastActivity

- (NSString *)title
{
    // todo: localize this
    return @"Podcasts";
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"PodcastsIcon"];
}

- (UIImage *)highlightedImage
{
    return [UIImage imageNamed:@"PodcastsIconHighlighted"];
}

- (PLPromise *)performActivity
{
    return [PLPromise promiseWithResult:nil];
}

@end