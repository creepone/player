#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLTrackGroupsViewController.h"
#import "PLTracksViewController.h"
#import "PLTrackGroupCell.h"
#import "PLTrackGroupsViewModel.h"
#import "PLTableViewProgress.h"
#import "PLTrackGroupCellViewModel.h"
#import "PLUtils.h"

@interface PLTrackGroupsViewController () {
    PLTableViewProgress *_tableViewProgress;
}

@end

@implementation PLTrackGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // remove the extra separators under the table view
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    _tableViewProgress = [PLTableViewProgress showInTableView:self.tableView];

    [self setupBindings];
}

- (void)setupBindings
{
    self.title = self.viewModel.title;

    @weakify(self);
    [[[RACObserve(self.viewModel, ready) filter:[PLUtils isTruePredicate]] take:1] subscribeNext:^(id x) {
        @strongify(self);
        if (!self) return;
        
        self->_tableViewProgress = nil;
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel groupsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLTrackGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackGroupCell" forIndexPath:indexPath];

    PLTrackGroupCellViewModel *modelView = [self.viewModel groupCellViewModelAt:indexPath];
    [cell setupBindings:modelView];

    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"trackGroup"]) {
        PLTracksViewController *tracksVc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        tracksVc.viewModel = [self.viewModel tracksViewModelAt:indexPath];
    }
}

@end
