#import <RXPromise/RXPromise.h>
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

- (RXPromise *)performActivity
{
    return [RXPromise promiseWithResult:nil];
}

@end