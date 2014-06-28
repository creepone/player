#import <ReactiveCocoa/ReactiveCocoa.h>
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

- (RACSignal *)performActivity
{
    return [RACSignal empty];
}

@end