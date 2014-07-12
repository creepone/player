#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Google-API-Client/GTLDrive.h>
#import "PLDownloadFromGDriveActivity.h"
#import "PLGDriveManager.h"

@implementation PLDownloadFromGDriveActivity

- (NSString *)title
{
    return NSLocalizedString(@"Activities.GDrive", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"GDriveIcon"];
}

- (RACSignal *)performActivity
{
    __block PLCloudImport *cloudImport = [[PLCloudImport alloc] initWithManager:[PLGDriveManager sharedManager]];
    return [[cloudImport selectAndImport] finally:^{
        cloudImport = nil;
    }];
}

@end