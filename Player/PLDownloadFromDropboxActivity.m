#import <RXPromise/RXPromise.h>
#import "PLDownloadFromDropboxActivity.h"

@implementation PLDownloadFromDropboxActivity

- (NSString *)title
{
    return NSLocalizedString(@"Activities.Dropbox", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"DropboxIcon"];
}

- (RXPromise *)performActivity
{
    return [RXPromise promiseWithResult:nil];
}

@end