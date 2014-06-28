#import <ReactiveCocoa/ReactiveCocoa.h>
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

- (RACSignal *)performActivity
{
    return [RACSignal empty];
}

@end