#import <RXPromise/RXPromise.h>
#import "PLMainViewController.h"
#import "PLMainUI.h"
#import "PLPlaylistSongsDelegate.h"
#import "PLActivityViewController.h"
#import "PLImportActivityViewController.h"

@interface PLMainViewController () {
    PLPlaylistSongsDelegate *_dataSource;
    PLImportActivityViewController *_activityViewController;
}

- (IBAction)tappedSwitch:(id)sender;
- (IBAction)tappedAdd:(id)sender;

@end

@implementation PLMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _dataSource = [[PLPlaylistSongsDelegate alloc] initWithTableView:self.tableView];
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
    [_activityViewController presentFromRootViewController].then(^(id result) {
        DDLogVerbose(@"completed activity");
        return (id)nil;
    }, nil);
}

@end
