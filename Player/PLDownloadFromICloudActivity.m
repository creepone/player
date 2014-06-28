#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLDownloadFromICloudActivity.h"

@implementation PLDownloadFromICloudActivity

- (NSString *)title
{
    return NSLocalizedString(@"Activities.ICloud", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"ICloudIcon"];
}

- (RACSignal *)performActivity
{
    return [RACSignal empty];
}

@end