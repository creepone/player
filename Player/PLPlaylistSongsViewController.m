#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPlaylistSongsViewController.h"
#import "PLPlaylistSongsViewModel.h"
#import "PLPlaylistSongCell.h"
#import "PLErrorManager.h"
#import "UITableView+PLExtensions.h"
#import "PLBookmarksViewController.h"
#import "PLBookmarksViewModel.h"
#import "PLPlaylistsViewController.h"
#import "PLPlaylistsViewModel.h"
#import "PLNotificationObserver.h"
#import "PLDataAccess.h"

@interface PLPlaylistSongsViewController () {
    BOOL _ignoreUpdates, _isVisible;
    PLNotificationObserver *_notificationObserver;
}

- (IBAction)tappedAdd:(id)sender;
- (IBAction)tappedSettings:(id)sender;
- (IBAction)tappedBookmarks:(id)sender;
- (IBAction)tappedPlaylists:(id)sender;

@end

@implementation PLPlaylistSongsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    @weakify(self);
    _notificationObserver = [[PLNotificationObserver alloc] init];
    [_notificationObserver addNotification:PLSelectedPlaylistChange handler:^(id _){ @strongify(self);
        [self updateViewModel];
        [self.tableView reloadData];
    }];
    
    [self updateViewModel];
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


- (void)updateViewModel
{
    [self setViewModel:[[PLPlaylistSongsViewModel alloc] initWithPlaylist:[[PLDataAccess sharedDataAccess] selectedPlaylist]]];
}

- (void)setViewModel:(PLPlaylistSongsViewModel *)viewModel
{
    _viewModel = viewModel;
    [self setupBindings];
}

- (void)setupBindings
{
    self.title = _viewModel.title;
    
    @weakify(self);
    [_viewModel.updatesSignal subscribeNext:^(NSArray *updates) { @strongify(self);
        if (self && self->_isVisible && !self->_ignoreUpdates)
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
        [[_viewModel removeSongAt:indexPath] subscribeError:[PLErrorManager logErrorVoidBlock]
        completed:^{
            [self.tableView reloadData];
        }];
    }
}

- (IBAction)tappedAdd:(id)sender
{
    [_viewModel.addCommand execute:nil];
}

- (IBAction)tappedSettings:(id)sender
{
    [_viewModel.switchCommand execute:nil];
}

- (IBAction)tappedBookmarks:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Bookmarks" bundle:nil];
    UINavigationController *navigationController = [storyboard instantiateInitialViewController];
    
    PLBookmarksViewController *bookmarksVc = navigationController.viewControllers[0];
    bookmarksVc.viewModel = [PLBookmarksViewModel new];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)tappedPlaylists:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Playlists" bundle:nil];
    UINavigationController *navigationController = [storyboard instantiateInitialViewController];
    
    PLPlaylistsViewController *bookmarksVc = navigationController.viewControllers[0];
    bookmarksVc.viewModel = [PLPlaylistsViewModel new];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
