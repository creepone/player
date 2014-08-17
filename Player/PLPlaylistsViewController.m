#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPlaylistsViewController.h"
#import "PLPlaylistsViewModel.h"
#import "UITableView+PLExtensions.h"
#import "PLPlaylistCell.h"
#import "PLPlaylistCellViewModel.h"
#import "PLErrorManager.h"

@interface PLPlaylistsViewController () {
    BOOL _ignoreUpdates;
}

- (IBAction)tappedAdd:(id)sender;

@end

@implementation PLPlaylistsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // remove the extra separators under the table view
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self setupBindings];
}

- (void)setupBindings
{
    @weakify(self);
    [self.viewModel.updatesSignal subscribeNext:^(NSArray *updates) { @strongify(self);
        if (self && !self->_ignoreUpdates)
            [self.tableView pl_applyUpdates:updates];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel playlistsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLPlaylistCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistCell"];
    PLPlaylistCellViewModel *viewModel = [self.viewModel playlistViewModelAt:indexPath];
    cell.viewModel = viewModel;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing || !self.viewModel.allowDelete)
        return UITableViewCellEditingStyleNone;
    
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[self.viewModel removePlaylistAt:indexPath] subscribeError:[PLErrorManager logErrorVoidBlock]
              completed:^{
                  [self.tableView reloadData];
              }];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    _ignoreUpdates = YES;
    
    @weakify(self);
    [[[self.viewModel movePlaylistFrom:fromIndexPath to:toIndexPath] finally:^{
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
    PLPlaylistCell *cell = (PLPlaylistCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.viewModel selectCell];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tappedAdd:(id)sender
{
    [self.viewModel addPlaylist];
}

@end
