#import "PLDownloadURLActivity.h"
#import "PLPromise.h"

@implementation PLDownloadURLActivity

- (NSString *)title
{
    // todo: localize this
    return @"Download\nURL";
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"DownloadIcon"];
}

- (UIImage *)highlightedImage
{
    return [UIImage imageNamed:@"DownloadIconHighlighted"];
}

- (PLPromise *)performActivity
{
    return [PLPromise promiseWithResult:nil];
}

@end