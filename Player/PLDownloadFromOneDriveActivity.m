#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLDownloadFromOneDriveActivity.h"
#import "PLOneDriveManager.h"

@implementation PLDownloadFromOneDriveActivity

- (NSString *)title
{
    return NSLocalizedString(@"Activities.OneDrive", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"OneDriveIcon"];
}

- (RACSignal *)performActivity
{
    __block PLCloudImport *cloudImport = [[PLCloudImport alloc] initWithManager:[PLOneDriveManager sharedManager]];
    return [[cloudImport selectAndImport] finally:^{
        cloudImport = nil;
    }];
}

@end
