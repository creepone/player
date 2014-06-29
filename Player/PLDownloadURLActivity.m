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

- (RACSignal *)performActivity
{
    // todo: localize
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Download" message:@"Enter the URL to download" delegate:nil cancelButtonTitle:NSLocalizedString(@"Common.Cancel", nil) otherButtonTitles:NSLocalizedString(@"Common.OK", nil), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];

    return [[[alertView rac_buttonClickedSignal] take:1] flattenMap:^RACSignal *(NSNumber *buttonIndex) {

        if ([buttonIndex intValue] == alertView.cancelButtonIndex)
            return nil;

        NSString *downloadURL = [[alertView textFieldAtIndex:0] text];

        PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
        PLDownloadManager *downloadManager = [PLDownloadManager sharedManager];

        PLTrack *track = [dataAccess trackWithDownloadURL:downloadURL];
        BOOL wasTrackInserted = [track isInserted];
        
        PLPlaylist *playlist = [dataAccess selectedPlaylist];
        if (playlist)
            [playlist addTrack:track];

        return [[dataAccess saveChangesSignal] then:^RACSignal *{
            // do not enqueue the download if the track already existed
            return wasTrackInserted ? [downloadManager enqueueDownloadOfTrack:track] : nil;
        }];
    }];
}

@end