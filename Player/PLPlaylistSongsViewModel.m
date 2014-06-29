#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPlaylistSongsViewModel.h"
#import "PLDataAccess.h"
#import "PLErrorManager.h"
#import "PLPlaylistSongCellViewModel.h"
#import "PLPlayer.h"
#import "PLFetchedResultsControllerDelegate.h"
#import "PLRouter.h"

@interface PLPlaylistSongsViewModel() <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
    PLFetchedResultsControllerDelegate *_fetchedResultsControllerDelegate;
}
@end

@implementation PLPlaylistSongsViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
        PLPlaylist *selectedPlaylist = [dataAccess selectedPlaylist];
        _fetchedResultsController = [dataAccess fetchedResultsControllerForSongsOfPlaylist:selectedPlaylist];
        _fetchedResultsControllerDelegate = [[PLFetchedResultsControllerDelegate alloc] initWithFetchedResultsController:_fetchedResultsController];

        NSError *error;
        [_fetchedResultsController performFetch:&error];
        if (error)
            [PLErrorManager logError:error];
    }
    return self;
}

- (NSUInteger)songsCount
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (PLPlaylistSongCellViewModel *)songViewModelAt:(NSIndexPath *)indexPath
{
    PLPlaylistSong *playlistSong = [_fetchedResultsController objectAtIndexPath:indexPath];
    return [[PLPlaylistSongCellViewModel alloc] initWithPlaylistSong:playlistSong];
}

- (void)selectSongAt:(NSIndexPath *)indexPath
{
    PLPlaylistSong *playlistSong = [_fetchedResultsController objectAtIndexPath:indexPath];
    PLPlayer *player = [PLPlayer sharedPlayer];

    player.currentSong = playlistSong;

    if (!player.isPlaying)
        [player play];
}

- (RACSignal *)removeSongAt:(NSIndexPath *)indexPath
{
    PLPlaylistSong *song = [_fetchedResultsController objectAtIndexPath:indexPath];
    PLPlayer *player = [PLPlayer sharedPlayer];

    if ([player isPlaying] && player.currentSong == song)
        [player stop];

    [song.playlist removeSong:song];
    
    return [[PLDataAccess sharedDataAccess] saveChangesSignal];
}

- (RACSignal *)moveSongFrom:(NSIndexPath *)fromIndexPath to:(NSIndexPath *)toIndexPath
{    
    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
    PLPlaylist *selectedPlaylist = [dataAccess selectedPlaylist];
    
    NSInteger indexFrom = [fromIndexPath row];
    NSInteger indexTo = [toIndexPath row];
    
    if(indexFrom != indexTo) {
        NSMutableArray *allSongs = [[_fetchedResultsController fetchedObjects] mutableCopy];
        
        PLPlaylistSong *songToMove = [allSongs objectAtIndex:indexFrom];
        [allSongs removeObjectAtIndex:indexFrom];
        [allSongs insertObject:songToMove atIndex:indexTo];
        
        [selectedPlaylist renumberSongsOrder:allSongs];
        
        return [dataAccess saveChangesSignal];
    }
    
    return [RACSignal empty];
}

- (RACSignal *)updatesSignal
{
    return _fetchedResultsControllerDelegate.updatesSignal;
}

- (RACCommand *)switchCommand
{
    return [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [PLRouter showLegacy];
        return [RACSignal empty];
    }];
}

- (RACCommand *)addCommand
{
    return [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [PLRouter showTrackImport];
    }];
}

@end