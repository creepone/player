#import "PLTracksViewController.h"
#import "PLTrackGroupCell.h"
#import "PLTracksViewModel.h"
#import "PLTrackCell.h"
#import "PLMediaItemTrackGroup.h"
#import "PLTableViewProgress.h"
#import "PLTrackGroupCellViewModel.h"
#import "PLTrackCellViewModel.h"
#import "PLUtils.h"

@interface PLTracksViewController () {
    PLTableViewProgress *_tableViewProgress;
}

@end

@implementation PLTracksViewController

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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.viewModel.ready)
        return 0;

    return section == 0 ? 1 : [self.viewModel tracksCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? 96.f : 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PLTrackGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackGroupHeaderCell" forIndexPath:indexPath];

        PLTrackGroupCellViewModel *viewModel = [self.viewModel groupCellViewModel];
        [cell setupBindings:viewModel];

        return cell;
    }
    else if (indexPath.section == 1) {
        PLTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell" forIndexPath:indexPath];

        PLTrackCellViewModel *viewModel = [self.viewModel trackCellViewModelAtIndex:indexPath.row];
        [cell setupBindings:viewModel];

        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.viewModel toggleSelectionGroup];
    }
    else if (indexPath.section == 1) {
        [self.viewModel toggleSelectionTrackAtIndex:indexPath.row];
    }
    [self.tableView reloadData];
}

@end
