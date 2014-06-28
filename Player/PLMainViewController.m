#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLMainViewController.h"
#import "PLMainUI.h"
#import "PLPlaylistSongsDelegate.h"
#import "PLActivityViewController.h"
#import "PLImportActivityViewController.h"

@interface PLMainViewController () {
    PLPlaylistSongsDelegate *_delegate;
    PLImportActivityViewController *_activityViewController;
}

- (IBAction)tappedSwitch:(id)sender;
- (IBAction)tappedAdd:(id)sender;

@end

@implementation PLMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _delegate = [[PLPlaylistSongsDelegate alloc] initWithTableView:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (IBAction)tappedSwitch:(id)sender
{
    [PLMainUI showLegacy];
}

- (IBAction)tappedAdd:(id)sender
{
    _activityViewController = [[PLImportActivityViewController alloc] init];
    [[_activityViewController presentFromRootViewController] subscribeCompleted:^{
        DDLogVerbose(@"Completed import activity.");
        _activityViewController = nil;
    }];
}

@end
