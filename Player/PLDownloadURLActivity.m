#import <RXPromise/RXPromise.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLDownloadURLActivity.h"

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

    RXPromise *promise = [[RXPromise alloc] init];

    [[alertView rac_buttonClickedSignal] subscribeNext:^(NSNumber *buttonIndex) {

        if ([buttonIndex intValue] == alertView.cancelButtonIndex)
            return;

        NSString *url = [[alertView textFieldAtIndex:0] text];

        // todo: add the track with the download url onto the current playlist, trigger the download queue

        DDLogVerbose(@"result = %@", url);

        [promise resolveWithResult:nil];
    }];

    [alertView show];

    return promise;
}

@end