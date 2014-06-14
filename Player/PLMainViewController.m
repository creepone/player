#import "PLMainViewController.h"
#import "PLMainUI.h"
#import "PLPlaylistSongsDelegate.h"

@interface PLMainViewController () {
    PLPlaylistSongsDelegate *_dataSource;
}

- (IBAction)clickedSwitch:(id)sender;

@end

@implementation PLMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _dataSource = [[PLPlaylistSongsDelegate alloc] initWithTableView:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DDLogVerbose(@"view will disappear");
}

- (IBAction)clickedSwitch:(id)sender
{
    [PLMainUI showLegacy];
}

@end
