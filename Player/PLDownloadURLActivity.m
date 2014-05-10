#import <RXPromise/RXPromise.h>
#import "PLDownloadURLActivity.h"

@implementation PLDownloadURLActivity

- (NSString *)title
{
    return NSLocalizedString(@"Activities.Download", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"DownloadIcon"];
}

- (UIImage *)highlightedImage
{
    return [UIImage imageNamed:@"DownloadIconHighlighted"];
}

- (RXPromise *)performActivity
{
    return [RXPromise promiseWithResult:nil];
}

@end