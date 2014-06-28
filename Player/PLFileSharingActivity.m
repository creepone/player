#import <ReactiveCocoa/ReactiveCocoa.h>
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

- (RACSignal *)performActivity
{
    return [RACSignal empty];
}

@end