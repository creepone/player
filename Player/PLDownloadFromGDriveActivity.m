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
    PLGDriveManager *driveManager = [PLGDriveManager sharedManager];
    
    if (!driveManager.isLinked) {
        return [[driveManager link] flattenMap:^RACStream *(NSNumber *isLinked) {
            return [isLinked boolValue] ? [self performActivity] : nil;
        }];
    }
    
    return [[driveManager listFolder:@"root"] flattenMap:^RACStream *(GTLDriveChildList* fileList) {
        DDLogVerbose(@"files = %@", fileList);
        return nil;
    }];
}

@end