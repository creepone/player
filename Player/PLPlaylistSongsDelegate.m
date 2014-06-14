#import "PLPlaylistSongsDelegate.h"
#import "PLDataAccess.h"
#import "PLErrorManager.h"
#import "PLPlaylistSongCell.h"
#import "PLPlaylistSongCellModelView.h"

@interface PLPlaylistSongsDelegate () <NSFetchedResultsControllerDelegate> {
    UITableView * _tableView;
    NSFetchedResultsController *_fetchedResultsController;
}

@end

@implementation PLPlaylistSongsDelegate

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
        PLPlaylist *selectedPlaylist = [dataAccess selectedPlaylist];
        _fetchedResultsController = [dataAccess fetchedResultsControllerForSongsOfPlaylist:selectedPlaylist];
        _fetchedResultsController.delegate = self;

        NSError *error;
        [_fetchedResultsController performFetch:&error];
        if (error)
            [PLErrorManager logError:error];

        _tableView = tableView;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * const kPlaylistSongCell = @"PlaylistSongCell";
    PLPlaylistSongCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlaylistSongCell forIndexPath:indexPath];

    PLPlaylistSong *playlistSong = [_fetchedResultsController objectAtIndexPath:indexPath];
    PLPlaylistSongCellModelView *modelView = [[PLPlaylistSongCellModelView alloc] initWithPlaylistSong:playlistSong];
    [cell setupBindings:modelView];

    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLPlaylistSongCell *playlistSongCell = (PLPlaylistSongCell *)cell;
    [playlistSongCell removeBindings];
}


// todo: there used to be a "is _inReorderingOperation" check here, do we maybe still need something like that ?

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [_tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [_tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [_tableView endUpdates];
}

@end