#import <CoreData/CoreData.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPlaylistsViewModel.h"
#import "PLFetchedResultsControllerDelegate.h"
#import "PLDataAccess.h"
#import "PLErrorManager.h"
#import "PLPlaylistCellViewModel.h"
#import "PLPlayer.h"
#import "PLDataAccess.h"

@interface PLPlaylistsViewModel() {
    NSFetchedResultsController *_fetchedResultsController;
    PLFetchedResultsControllerDelegate *_fetchedResultsControllerDelegate;
}
@end

@implementation PLPlaylistsViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];
        _fetchedResultsController = [dataAccess fetchedResultsControllerForAllPlaylists];
        _fetchedResultsControllerDelegate = [[PLFetchedResultsControllerDelegate alloc] initWithFetchedResultsController:_fetchedResultsController];
        
        NSError *error;
        [_fetchedResultsController performFetch:&error];
        if (error)
            [PLErrorManager logError:error];
    }
    return self;
}

- (NSUInteger)playlistsCount
{
    return [_fetchedResultsController.sections[0] numberOfObjects];
}

- (PLPlaylistCellViewModel *)playlistViewModelAt:(NSIndexPath *)indexPath
{
    PLPlaylist *playlist = [_fetchedResultsController objectAtIndexPath:indexPath];
    return [[PLPlaylistCellViewModel alloc] initWithPlaylist:playlist];
}

- (RACSignal *)removePlaylistAt:(NSIndexPath *)indexPath
{
    PLPlaylist *playlist = [_fetchedResultsController objectAtIndexPath:indexPath];
    PLPlayer *player = [PLPlayer sharedPlayer];
    
    if (player.currentSong.playlist == playlist) {
        player.currentSong = nil;
    }
    
    [playlist remove];
    return [[PLDataAccess sharedDataAccess] saveChangesSignal];
}

- (RACSignal *)updatesSignal
{
    return _fetchedResultsControllerDelegate.updatesSignal;
}

@end
