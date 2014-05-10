#import <RXPromise/RXPromise.h>
#import "PLDownloadFromGDriveActivity.h"

@implementation PLDownloadFromGDriveActivity

- (NSString *)title
{
    return NSLocalizedString(@"Activities.GDrive", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"GDriveIcon"];
}

- (RXPromise *)performActivity
{
    return [RXPromise promiseWithResult:nil];
}

@end