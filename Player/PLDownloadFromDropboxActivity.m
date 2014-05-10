#import "PLDownloadFromDropboxActivity.h"
#import "PLPromise.h"

@implementation PLDownloadFromDropboxActivity

- (NSString *)title
{
    // todo: localize this
    return @"Dropbox";
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"DropboxIcon"];
}

- (PLPromise *)performActivity
{
    return [PLPromise promiseWithResult:nil];
}

@end