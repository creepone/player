#import "PLDownloadFromICloudActivity.h"
#import "PLPromise.h"

@implementation PLDownloadFromICloudActivity

- (NSString *)title
{
    // todo: localize this
    return @"iCloud";
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"ICloudIcon"];
}

- (PLPromise *)performActivity
{
    return [PLPromise promiseWithResult:nil];
}

@end