#import "PLDownloadFromGDriveActivity.h"
#import "PLPromise.h"

@implementation PLDownloadFromGDriveActivity

- (NSString *)title
{
    // todo: localize this
    return @"Google Drive";
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"GDriveIcon"];
}

- (PLPromise *)performActivity
{
    return [PLPromise promiseWithResult:nil];
}

@end