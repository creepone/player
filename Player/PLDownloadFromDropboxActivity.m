#import <ReactiveCocoa/ReactiveCocoa.h>
#import <DropboxSDK/DropboxSDK.h>
#import "PLDownloadFromDropboxActivity.h"
#import "PLDataAccess.h"
#import "PLDownloadManager.h"
#import "PLDropboxManager.h"
#import "PLDropboxItemsViewController.h"
#import "PLDropboxItemsViewModel.h"
#import "PLUtils.h"
#import "PLDropboxPathAsset.h"

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
        
        NSArray *assets = [viewModel.selection allAssets];

        RACSignal *pathsToDownload = [[assets.rac_sequence signalWithScheduler:[RACScheduler mainThreadScheduler]]
            flattenMap:^RACStream *(PLDropboxPathAsset *asset) {
                if (asset.metadata.isDirectory) {
                    return [self listDirectoryRecursive:asset.metadata.path];
                }
                else {
                    return [RACSignal return:asset.metadata.path];
                }
            }];
        
        return [pathsToDownload flattenMap:^RACStream *(NSString *path) {
            return [self downloadPath:path];
        }];
    }];
}

- (RACSignal *)downloadPath:(NSString *)path
{
    NSString *downloadURL = [NSString stringWithFormat:@"dropbox://%@", [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    DDLogVerbose(@"downloadURL = %@", downloadURL);
    
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
}

- (RACSignal *)listDirectoryRecursive:(NSString *)path
{
    return [[[PLDropboxManager sharedManager] listFolder:path] flattenMap:^RACStream *(NSArray *items) {
        return [[items.rac_sequence signalWithScheduler:[RACScheduler mainThreadScheduler]]
            flattenMap:^RACStream *(DBMetadata *metadata) {
                if (metadata.isDirectory) {
                    return [self listDirectoryRecursive:metadata.path];
                }
                else {
                    return [RACSignal return:metadata.path];
                }
            }];
    }];
}

@end