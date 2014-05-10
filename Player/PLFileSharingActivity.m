#import "PLFileSharingActivity.h"
#import "PLPromise.h"

@implementation PLFileSharingActivity

- (NSString *)title
{
    // todo: localize this
    return @"iTunes File\nSharing";
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"FileSharingIcon"];
}

- (UIImage *)highlightedImage
{
    return [UIImage imageNamed:@"FileSharingIconHighlighted"];
}

- (PLPromise *)performActivity
{
    return [PLPromise promiseWithResult:nil];
}

@end