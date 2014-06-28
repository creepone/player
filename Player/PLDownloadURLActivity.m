#import <RXPromise/RXPromise.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLDownloadURLActivity.h"
#import "PLTrack.h"
#import "PLDataAccess.h"
#import "PLDownloadManager.h"

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

        NSString *downloadURL = [[alertView textFieldAtIndex:0] text];

        PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
        PLDownloadManager *downloadManager = [PLDownloadManager sharedManager];

        PLTrack *track = [dataAccess trackWithDownloadURL:downloadURL];
        BOOL wasTrackInserted = [track isInserted];
        
        PLPlaylist *playlist = [dataAccess selectedPlaylist];
        if (playlist)
            [playlist addTrack:track];

        [[[dataAccess saveChangesSignal] then:^RACSignal *{
            // do not enqueue the download if the track already existed
            return wasTrackInserted ? [downloadManager enqueueDownloadOfTrack:track] : nil;
        }]
        subscribeCompleted:^{
            [promise resolveWithResult:nil];
        }];
    }];

    [alertView show];

    return promise;
}

@end