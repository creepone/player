#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLCloudItemsViewController.h"
#import "PLCloudItemsViewModel.h"
#import "PLCloudItemCell.h"
#import "PLTableViewProgress.h"

@interface PLCloudItemsViewController () {
    PLTableViewProgress *_tableViewProgress;
}

- (IBAction)tappedDone:(id)sender;

@end

static NSString * const kCellIdentifier = @"cloudItemCell";

@implementation PLCloudItemsViewController

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
    RAC(self, title) = [RACObserve(self.viewModel, title) takeUntil:self.rac_willDeallocSignal];
    [self rac_liftSelector:@selector(setLoading:) withSignals:[RACObserve(self.viewModel, loading) takeUntil:self.rac_willDeallocSignal], nil];
    [self rac_liftSelector:@selector(navigateTo:) withSignals:[self.viewModel.navigationSignal takeUntil:self.rac_willDeallocSignal], nil];
}

- (IBAction)tappedDone:(id)sender
{
    PLCloudItemsViewController *rootController = self.navigationController.viewControllers[0];
    rootController.viewModel.dismissed = YES;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setLoading:(BOOL)loading
{
    _tableViewProgress = loading ? [PLTableViewProgress showInTableView:self.tableView] : nil;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

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
    return [self.viewModel.cellIdentifier isEqualToString:kCellIdentifier] ? 44.f : 94.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.viewModel.cellIdentifier isEqualToString:kCellIdentifier])
        return [tableView dequeueReusableCellWithIdentifier:self.viewModel.cellIdentifier forIndexPath:indexPath];
    
    PLCloudItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.viewModel = [self.viewModel cellViewModelAt:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.viewModel toggleSelectAt:indexPath];
    [tableView reloadData];
}
     
- (void)navigateTo:(PLCloudItemsViewModel *)viewModel
{
    PLCloudItemsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"cloudItems"];
    controller.viewModel = viewModel;
    [self.navigationController pushViewController:controller animated:YES];
}
     
@end
