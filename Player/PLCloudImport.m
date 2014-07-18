#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SVProgressHUD.h>
#import "PLPathAssetSet.h"
#import "PLCloudImport.h"
#import "PLCloudItemsViewModel.h"
#import "PLCloudItemsViewController.h"
#import "PLUtils.h"
#import "PLDataAccess.h"
#import "PLDownloadManager.h"
#import "PLProgressHUD.h"

@interface PLCloudImport() {
    id<PLCloudManager> _manager;
}

@end

@implementation PLCloudImport

- (instancetype)initWithManager:(id<PLCloudManager>)manager
{
    self = [super init];
    if (self) {
        _manager = manager;
    }
    return self;
}

- (RACSignal *)selectAndImport
{
    if (!_manager.isLinked) {
        return [[_manager link] flattenMap:^RACStream *(NSNumber *isLinked) {
            return [isLinked boolValue] ? [self selectAndImport] : nil;
        }];
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CloudImport" bundle:nil];
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    UINavigationController *navigationController = storyboard.instantiateInitialViewController;
    
    PLCloudItemsViewModel *viewModel = [[PLCloudItemsViewModel alloc] initWithCloudManager:_manager];
    PLCloudItemsViewController *itemsVc = navigationController.viewControllers[0];
    itemsVc.viewModel = viewModel;
    
    [rootViewController presentViewController:navigationController animated:YES completion:nil];
    
    __block RACDisposable *progress;
    
    return [[[[RACObserve(viewModel, dismissed) filter:[PLUtils isTruePredicate]] take:1] then:^RACSignal *{
        
        progress = [PLProgressHUD showWithStatus:@"Adding tracks"]; // todo: localize
        NSArray *assets = [viewModel.selection allAssets];
        
        RACSignal *assetsToDownload = [[assets.rac_sequence signalWithScheduler:[RACScheduler mainThreadScheduler]]
          flattenMap:^RACStream *(id<PLPathAsset> asset) {
              if (asset.isDirectory) {
                  return [self loadChildrenRecursive:asset];
              }
              else {
                  return [RACSignal return:asset];
              }
          }];
        
        return [assetsToDownload flattenMap:^RACStream *(id <PLPathAsset> asset) {
            return [self downloadAsset:asset];
        }];
    }]
    finally:^{
        [progress dispose];
    }];
}

- (RACSignal *)downloadAsset:(id<PLPathAsset>)asset
{
    NSURL *downloadURL = [_manager downloadURLForAsset:asset];
    if (downloadURL == nil)
        return [RACSignal empty];
    
    return [[PLDownloadManager sharedManager] addTrackToDownload:downloadURL withTitle:asset.title];
}

- (RACSignal *)loadChildrenRecursive:(id<PLPathAsset>)asset
{
    return [[_manager loadChildren:asset] flattenMap:^RACStream *(NSArray *children) {
        return [[children.rac_sequence signalWithScheduler:[RACScheduler mainThreadScheduler]]
            flattenMap:^RACStream *(id<PLPathAsset> child) {
                if (child.isDirectory)
                    return [self loadChildrenRecursive:child];
                else
                    return [RACSignal return:child];
            }];
    }];
}

@end
