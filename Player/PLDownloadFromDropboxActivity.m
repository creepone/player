#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLDownloadFromDropboxActivity.h"
#import "PLCloudImport.h"
#import "PLDropboxManager.h"

@implementation PLDownloadFromDropboxActivity

- (NSString *)title
{
    return NSLocalizedString(@"Activities.Dropbox", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"DropboxIcon"];
}

- (RACSignal *)performActivity
{
    __block PLCloudImport *cloudImport = [[PLCloudImport alloc] initWithManager:[PLDropboxManager sharedManager]];
    return [[cloudImport selectAndImport] finally:^{
        cloudImport = nil;
    }];
}

@end