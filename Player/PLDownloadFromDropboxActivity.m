#import <ReactiveCocoa/ReactiveCocoa.h>
#import <DropboxSDK/DropboxSDK.h>
#import "PLDownloadFromDropboxActivity.h"
#import "PLDataAccess.h"
#import "PLDownloadManager.h"
#import "PLDropboxManager.h"
#import "PLDropboxItemsViewController.h"
#import "PLDropboxItemsViewModel.h"
#import "PLUtils.h"

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
    PLDropboxManager *dropboxManager = [PLDropboxManager sharedManager];
    
    if (![dropboxManager ensureLinked])
        return [RACSignal empty];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Dropbox" bundle:nil];
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    UINavigationController *navigationController = storyboard.instantiateInitialViewController;
    
    PLDropboxItemsViewModel *viewModel = [PLDropboxItemsViewModel new];
    PLDropboxItemsViewController *dropboxItemsVc = navigationController.viewControllers[0];
    dropboxItemsVc.viewModel = viewModel;
    
    [rootViewController presentViewController:navigationController animated:YES completion:nil];
        
    return [[[RACObserve(viewModel, dismissed) filter:[PLUtils isTruePredicate]] take:1] then:^RACSignal *{
        
        // todo: import selection
        
        return [RACSignal empty];
    }];
    
    /*NSString *testPath = @"/Audio/Sheila%20Heen%2C%20Douglas%20Stone%20-%20Thanks%20for%20the%20Feedback/Sheila%20Heen%2C%20Douglas%20Stone%20-%20Thanks%20for%20the%20Feedback%20-%20Part%202.m4b";
    NSURL *downloadURL = [[PLDropboxManager sharedManager] downloadURLForPath:testPath];
    
    DDLogVerbose(@"downloadURL = %@", downloadURL);
    
    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
    PLDownloadManager *downloadManager = [PLDownloadManager sharedManager];
    
    PLTrack *track = [dataAccess trackWithDownloadURL:[downloadURL absoluteString]];
    BOOL wasTrackInserted = [track isInserted];
    
    PLPlaylist *playlist = [dataAccess selectedPlaylist];
    if (playlist)
        [playlist addTrack:track];
    
    return [[dataAccess saveChangesSignal] then:^RACSignal *{
        // do not enqueue the download if the track already existed
        return wasTrackInserted ? [downloadManager enqueueDownloadOfTrack:track] : nil;
    }];
     
     */
}

@end