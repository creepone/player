#import <RXPromise/RXPromise.h>
#import "PLDownloadPodcastActivity.h"

@implementation PLDownloadPodcastActivity

- (NSString *)title
{
    return NSLocalizedString(@"Activities.Podcasts", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"PodcastsIcon"];
}

- (UIImage *)highlightedImage
{
    return [UIImage imageNamed:@"PodcastsIconHighlighted"];
}

- (RXPromise *)performActivity
{
    return [RXPromise promiseWithResult:nil];
}

@end