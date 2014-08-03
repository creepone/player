#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPodcastEpisodesViewController.h"
#import "PLPodcastEpisodesViewModel.h"
#import "PLTableViewProgress.h"
#import "PLUtils.h"
#import "PLPodcastEpisodeCell.h"
#import "UITableView+PLExtensions.h"

@interface PLPodcastEpisodesViewController () {
    PLTableViewProgress *_tableViewProgress;
}

@end

@implementation PLPodcastEpisodesViewController

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
    [[[RACObserve(self.viewModel, ready) filter:[PLUtils isTruePredicate]] take:1] subscribeNext:^(id x) { @strongify(self);
        if (!self) return;
        
        self->_tableViewProgress = nil;
        [self.tableView reloadData];
    }];
    
    [self.viewModel.updatesSignal subscribeNext:^(NSArray *updates) { @strongify(self);
        [self.tableView pl_applyUpdates:updates];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.viewModel sectionsCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel cellsCountInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.viewModel sectionTitle:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self.viewModel cellIdentifier];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ([cell isKindOfClass:[PLPodcastEpisodeCell class]]) {
        PLPodcastEpisodeCell *episodeCell = (PLPodcastEpisodeCell *)cell;
        episodeCell.viewModel = [self.viewModel cellViewModelAt:indexPath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.viewModel toggleSelectAt:indexPath];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
