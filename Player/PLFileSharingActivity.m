#import <RXPromise/RXPromise.h>
#import "PLFileSharingActivity.h"

@implementation PLFileSharingActivity

- (NSString *)title
{
    return NSLocalizedString(@"Activities.FileSharing", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"FileSharingIcon"];
}

- (UIImage *)highlightedImage
{
    return [UIImage imageNamed:@"FileSharingIconHighlighted"];
}

- (RXPromise *)performActivity
{
    return [RXPromise promiseWithResult:nil];
}

@end