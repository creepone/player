#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPodcastsViewController.h"
#import "PLPodcastsViewModel.h"
#import "PLTableViewProgress.h"
#import "PLPodcastCell.h"
#import "UITableView+PLExtensions.h"
#import "PLUtils.h"
#import "PLPodcastsSearchViewModel.h"
#import "PLPodcastEpisodesViewController.h"
#import "UITableViewCell+PLExtensions.h"

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
    
    [self rac_liftSelector:@selector(setSearching:) withSignals:[RACObserve(self.viewModel.searchViewModel, isSearching) takeUntil:self.rac_willDeallocSignal], nil];
    [[self.viewModel.searchViewModel.dismissSignal takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id _) { @strongify(self); [self hideSearch]; }];
    
    [_viewModel.updatesSignal subscribeNext:^(NSArray *updates) { @strongify(self);
        if (self && self->_isVisible && !self.searchDisplayController.isActive)
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

- (IBAction)dismiss:(UIStoryboardSegue *)segue
{
    self.viewModel.dismissed = YES;
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"podcast"]) {
        PLPodcastEpisodesViewController *podcastsVc = [segue destinationViewController];
        UITableViewCell *cell = (UITableViewCell *)sender;
        UITableView *tableView = [cell pl_tableView];
        NSIndexPath *indexPath = [tableView indexPathForCell:sender];
        podcastsVc.viewModel = [[self tableViewModel:tableView] episodesViewModelAt:indexPath];
    }
}

#pragma mark -- Table view data source

- (id <PLPodcastsTableViewModel>)tableViewModel:(UITableView *)tableView
{
    if (tableView == self.tableView)
        return self.viewModel;
    else
        return self.viewModel.searchViewModel;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self tableViewModel:tableView] cellsCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self tableViewModel:tableView] cellHeight];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self tableViewModel:tableView] cellEditingStyle];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [[self tableViewModel:tableView] cellIdentifier];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ([cell isKindOfClass:[PLPodcastCell class]]) {
        PLPodcastCell *podcastCell = (PLPodcastCell *)cell;
        podcastCell.viewModel = [[self tableViewModel:tableView] cellViewModelAt:indexPath];
    }
        
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<PLPodcastsTableViewModel> tableViewModel = [self tableViewModel:tableView];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([tableViewModel isKindOfClass:[PLPodcastsViewModel class]]) {
            [(PLPodcastsViewModel *)tableViewModel removeAt:indexPath];
        }
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
    [self.viewModel.searchViewModel setSearchTermSignal:_searchTermSubject];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    NSString *lastSearchTerm = self.viewModel.searchViewModel.lastSearchTerm;
    if ([lastSearchTerm length] > 0)
        controller.searchBar.text = lastSearchTerm;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    _searchTermSubject = nil;
    [self.viewModel.searchViewModel setSearchTermSignal:nil];
    [self.tableView reloadData];
}

@end
