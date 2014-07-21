#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPodcastsViewController.h"
#import "PLPodcastsViewModel.h"
#import "PLTableViewProgress.h"
#import "PLPodcastCell.h"
#import "UITableView+PLExtensions.h"
#import "PLUtils.h"

@interface PLPodcastsViewController () <UISearchDisplayDelegate> {
    PLTableViewProgress *_searchingProgress;
    RACSubject *_searchTermSubject;
    BOOL _isVisible;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    _isVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _isVisible = NO;
}

- (void)setupBindings
{
    @weakify(self);
    
    [self rac_liftSelector:@selector(setSearching:) withSignals:[[RACObserve(self.viewModel, isSearching) distinctUntilChanged] takeUntil:self.rac_willDeallocSignal], nil];
    [[[RACObserve(self.viewModel, isShowingSearch) filter:[PLUtils isFalsePredicate]] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id _) { @strongify(self); [self hideSearch]; }];
    
    [_viewModel.updatesSignal subscribeNext:^(NSArray *updates) { @strongify(self);
        if (self && self->_isVisible && !self.viewModel.isShowingSearch)
            [self.tableView pl_applyUpdates:updates];
    }];
}

- (void)setSearching:(BOOL)searching
{
    UITableView *searchTableView = self.searchDisplayController.searchResultsTableView;
    
    _searchingProgress = searching ? [PLTableViewProgress showInTableView:searchTableView afterGraceTime:0.0] : nil;
    
    if (!searching)
        [searchTableView reloadData];
}

- (void)hideSearch
{
    if ([self.searchDisplayController isActive])
        [self.searchDisplayController setActive:NO animated:YES];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.viewModel selectAt:indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.viewModel cellEditingStyle];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.viewModel removeAt:indexPath];
    }
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

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    _searchTermSubject = nil;
    self.viewModel.isShowingSearch = NO;
    [self.tableView reloadData];
}

@end
