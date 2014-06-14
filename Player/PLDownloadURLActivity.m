#import <RXPromise/RXPromise.h>
#import "PLDownloadURLActivity.h"
#import "NSObject+RACSelectorSignal.h"
#import "RACSignal.h"
#import "UIAlertView+PLExtensions.h"

@interface PLDownloadURLActivity() <UIAlertViewDelegate>
@end

@implementation PLDownloadURLActivity

- (NSString *)title
{
    return NSLocalizedString(@"Activities.Download", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"DownloadIcon"];
}

- (UIImage *)highlightedImage
{
    return [UIImage imageNamed:@"DownloadIconHighlighted"];
}

- (RXPromise *)performActivity
{
    // todo: localize
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Download" message:@"Enter the URL to download" delegate:self cancelButtonTitle:NSLocalizedString(@"Common.Cancel", nil) otherButtonTitles:NSLocalizedString(@"Common.OK", nil), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;

    return [alertView pl_show].thenOnMain(^(NSNumber *buttonIndex) {
        if ([buttonIndex intValue] == alertView.cancelButtonIndex)
            return (id)nil;

        NSString *url = [[alertView textFieldAtIndex:0] text];

        // todo: add the track with the download url onto the current playlist, trigger the download queue

        DDLogVerbose(@"result = %@", url);
        return (id) nil;
    }, nil);
}

@end