#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPodcastsViewController.h"
#import "PLPodcastsViewModel.h"
#import "PLTableViewProgress.h"
#import "PLPodcastCell.h"

@interface PLPodcastsViewController () <UISearchDisplayDelegate> {
    PLTableViewProgress *_searchingProgress;
    RACSubject *_searchTermSubject;
}

@end

@implementation PLPodcastsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // remove the extra separators under the table view
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self setupBindings];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)setupBindings
{
    [self rac_liftSelector:@selector(setSearching:) withSignals:[RACObserve(self.viewModel, isSearching) takeUntil:self.rac_willDeallocSignal], nil];
}

- (void)setSearching:(BOOL)searching
{
    UITableView *searchTableView = self.searchDisplayController.searchResultsTableView;
    
    _searchingProgress = searching ? [PLTableViewProgress showInTableView:searchTableView afterGraceTime:0.0] : nil;
    
    if (!searching)
        [searchTableView reloadData];
}

- (IBAction)tappedDone:(id)sender
{
    self.viewModel.dismissed = YES;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel cellsCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.viewModel cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.viewModel.cellIdentifier];
    
    if ([cell isKindOfClass:[PLPodcastCell class]]) {
        PLPodcastCell *podcastCell = (PLPodcastCell *)cell;
        podcastCell.viewModel = [self.viewModel cellViewModelAt:indexPath];
    }
        
    return cell;
}

#pragma mark -- Search display delegate 

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    // remove the extra separators under the table view
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    tableView.separatorInset = UIEdgeInsetsZero;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [_searchTermSubject sendNext:searchString];
    return NO;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    _searchTermSubject = [RACSubject subject];
    self.viewModel.isShowingSearch = YES;
    [self.viewModel setSearchTermSignal:_searchTermSubject];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    _searchTermSubject = nil;
    self.viewModel.isShowingSearch = NO;
}

@end
