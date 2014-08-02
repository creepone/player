#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLDownloadURLActivity.h"
#import "PLTrack.h"
#import "PLDataAccess.h"
#import "PLDownloadManager.h"
#import "PLUtils.h"

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

- (RACSignal *)performActivity
{
    // todo: localize
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Download" message:@"Enter the URL to download" delegate:nil cancelButtonTitle:NSLocalizedString(@"Common.Cancel", nil) otherButtonTitles:NSLocalizedString(@"Common.OK", nil), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];

    return [[[alertView rac_buttonClickedSignal] take:1] flattenMap:^RACSignal *(NSNumber *buttonIndex) {

        if ([buttonIndex intValue] == alertView.cancelButtonIndex)
            return nil;

        NSURL *downloadURL = [NSURL URLWithString:[[alertView textFieldAtIndex:0] text]];
        NSString *title = [PLUtils fileNameFromURL:downloadURL];
        return [[PLDownloadManager sharedManager] addTrackToDownload:downloadURL withTitle:title artist:nil targetFileName:nil];
    }];
}

@end