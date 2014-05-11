#import <RXPromise/RXPromise.h>
#import "PLSelectFromMusicLibraryActivity.h"
#import "PLMediaLibrarySearch.h"
#import "PLMusicLibraryViewController.h"
#import "PLTrackGroup.h"

@implementation PLSelectFromMusicLibraryActivity

- (NSString *)title
{
    return NSLocalizedString(@"Activities.Music", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"MusicIcon"];
}

- (RXPromise *)performActivity
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MusicLibrary" bundle:nil];
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;

    RXPromise *promise = [[RXPromise alloc] init];
    UINavigationController *navigationController = storyboard.instantiateInitialViewController;
    
    PLMusicLibraryViewController *musicLibraryVc = navigationController.viewControllers[0];
    musicLibraryVc.doneCallback = ^(NSArray *selection) {
        DDLogInfo(@"selection = %@", selection);
        
        // todo: initiate import of the selected tracks
        
        [promise resolveWithResult:nil];
    };
    
    [rootViewController presentViewController:navigationController animated:YES completion:nil];
    return promise;
}

@end