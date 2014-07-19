#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLFileSharingViewController.h"
#import "PLFileSharingViewModel.h"
#import "PLTableViewProgress.h"
#import "PLFileSharingCell.h"

@interface PLFileSharingViewController () {
    PLTableViewProgress *_tableViewProgress;
}

- (IBAction)tappedDone:(id)sender;

@end

static NSString * const kCellIdentifier = @"fileSharingCell";
static NSString * const kEmptyCellIdentifier = @"emptyCell";

@implementation PLFileSharingViewController

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
    [self rac_liftSelector:@selector(setLoading:) withSignals:[RACObserve(self.viewModel, loading) takeUntil:self.rac_willDeallocSignal], nil];
}

- (IBAction)tappedDone:(id)sender
{
    self.viewModel.dismissed = YES;
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
    return [self.viewModel cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.viewModel.cellIdentifier forIndexPath:indexPath];

    if ([cell isKindOfClass:[PLFileSharingCell class]]) {
        PLFileSharingCell *fileSharingCell = (PLFileSharingCell *)cell;
        fileSharingCell.viewModel = [self.viewModel cellViewModelAt:indexPath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.viewModel toggleSelectAt:indexPath];
    [tableView reloadData];
}

@end
