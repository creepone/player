#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLDownloadPodcastActivity.h"
#import "PLPodcastsViewModel.h"
#import "PLPodcastsViewController.h"
#import "PLUtils.h"
#import "PLProgressHUD.h"
#import "PLPodcastEpisode.h"
#import "PLDownloadManager.h"
#import "PLDataAccess.h"

@implementation PLDownloadPodcastActivity

- (NSString *)title
{
    return NSLocalizedString(@"Activities.Podcasts", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"PodcastsIcon"];
}

- (UIImage *)highlightedImage
{
    return [UIImage imageNamed:@"PodcastsIconHighlighted"];
}

- (RACSignal *)performActivity
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Podcasts" bundle:nil];
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    UINavigationController *navigationController = storyboard.instantiateInitialViewController;
    
    PLPodcastsViewModel *viewModel = [PLPodcastsViewModel new];
    PLPodcastsViewController *rootVc = navigationController.viewControllers[0];
    rootVc.viewModel = viewModel;
    
    [rootViewController presentViewController:navigationController animated:YES completion:nil];
    
    __block RACDisposable *progress;
    
    return [[[[RACObserve(viewModel, dismissed) filter:[PLUtils isTruePredicate]] take:1] then:^RACSignal *{
    
        progress = [PLProgressHUD showWithStatus:@"Adding episodes"]; // todo: localize
        
        return [[viewModel.selection.rac_sequence signalWithScheduler:[RACScheduler mainThreadScheduler]] flattenMap:^RACStream *(PLPodcastEpisode *episode) {
            return [[[PLDownloadManager sharedManager] addTrackToDownload:episode.downloadURL withTitle:nil] then:^RACSignal *{
                return [episode markAsOld];
            }];
        }];
    }]
    finally:^{
        [progress dispose];
    }];
}

@end