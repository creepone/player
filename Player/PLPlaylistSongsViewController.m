#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPlaylistSongsViewController.h"
#import "PLPlaylistSongsViewModel.h"
#import "PLPlaylistSongCell.h"
#import "PLErrorManager.h"
#import "UITableView+PLExtensions.h"

@interface PLPlaylistSongsViewController () {
    PLPlaylistSongsViewModel *_viewModel;
    BOOL _ignoreUpdates;
}

- (IBAction)tappedSwitch:(id)sender;
- (IBAction)tappedAdd:(id)sender;

@end

@implementation PLPlaylistSongsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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

    @weakify(self);
    [_viewModel.updatesSignal subscribeNext:^(NSArray *updates) {
        @strongify(self);
        if (self && !self->_ignoreUpdates)
            [self.tableView pl_applyUpdates:updates];
    }];
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
    cell.viewModel = viewModel;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView isEditing] ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    _ignoreUpdates = YES;
    
    @weakify(self);
    [[[_viewModel moveSongFrom:fromIndexPath to:toIndexPath] finally:^{
        @strongify(self);
        if (self)
            self->_ignoreUpdates = NO;
    }]
    subscribeError:^(NSError *error) {
        [PLErrorManager logError:error];
        // todo: show a TSMessage and reload the table view so that the operation gets undone in the view
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_viewModel selectSongAt:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[_viewModel removeSongAt:indexPath] subscribeError:[PLErrorManager logErrorVoidBlock]];
    }
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
