#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPlaylistSongsViewController.h"
#import "PLPlaylistSongsViewModel.h"
#import "PLPlaylistSongCell.h"
#import "PLFetchedResultsUpdate.h"

@interface PLPlaylistSongsViewController () {
    PLPlaylistSongsViewModel *_viewModel;
}

- (IBAction)tappedSwitch:(id)sender;
- (IBAction)tappedAdd:(id)sender;

@end

@implementation PLPlaylistSongsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBindings:[PLPlaylistSongsViewModel new]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}


- (void)setupBindings:(PLPlaylistSongsViewModel *)viewModel
{
    _viewModel = viewModel;
    [self rac_liftSelector:@selector(applyUpdates:) withSignals:[_viewModel.updatesSignal takeUntil:self.rac_willDeallocSignal], nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_viewModel songsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * const kPlaylistSongCell = @"PlaylistSongCell";
    PLPlaylistSongCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlaylistSongCell forIndexPath:indexPath];

    PLPlaylistSongCellViewModel *viewModel = [_viewModel songViewModelAt:indexPath];
    [cell setupBindings:viewModel];
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_viewModel selectSongAt:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_viewModel removeSongAt:indexPath];
    }
}

- (void)applyUpdates:(NSArray *)updates
{
    // todo: maybe extract this to a reusable helper method ?

    [self.tableView beginUpdates];

    for (PLFetchedResultsUpdate *update in updates)
    {
        switch(update.changeType)
        {
            case NSFetchedResultsChangeInsert:
            {
                [self.tableView insertRowsAtIndexPaths:@[update.targetIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
            case NSFetchedResultsChangeDelete:
            {
                [self.tableView deleteRowsAtIndexPaths:@[update.indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
        }
    }

    [self.tableView endUpdates];
}


- (IBAction)tappedSwitch:(id)sender
{
    [_viewModel.switchCommand execute:nil];
}

- (IBAction)tappedAdd:(id)sender
{
    [_viewModel.addCommand execute:nil];
}

@end
