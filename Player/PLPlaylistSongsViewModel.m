#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPlaylistSongsViewModel.h"
#import "PLDataAccess.h"
#import "PLErrorManager.h"
#import "PLPlaylistSongCellViewModel.h"
#import "PLPlayer.h"
#import "PLFetchedResultsControllerDelegate.h"
#import "PLRouter.h"

@interface PLPlaylistSongsViewModel() {
    PLPlaylist *_playlist;
    NSFetchedResultsController *_fetchedResultsController;
    PLFetchedResultsControllerDelegate *_fetchedResultsControllerDelegate;
}
@end

@implementation PLPlaylistSongsViewModel

- (instancetype)initWithPlaylist:(PLPlaylist *)playlist
{
    self = [super init];
    if (self) {
        _playlist = playlist;
        _fetchedResultsController = [[PLDataAccess sharedDataAccess] fetchedResultsControllerForSongsOfPlaylist:playlist];
        _fetchedResultsControllerDelegate = [[PLFetchedResultsControllerDelegate alloc] initWithFetchedResultsController:_fetchedResultsController];

        NSError *error;
        [_fetchedResultsController performFetch:&error];
        if (error)
            [PLErrorManager logError:error];
    }
    return self;
}

- (NSString *)title
{
    return _playlist.name;
}

- (NSUInteger)songsCount
{
    return [_fetchedResultsController.sections[0] numberOfObjects];
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
    
    if (player.currentSong != playlistSong || !player.isPlaying) {
        [player setCurrentSong:playlistSong];
        [player play];
    }
    else {
        [player pause];
    }
}

- (RACSignal *)removeSongAt:(NSIndexPath *)indexPath
{
    PLPlaylistSong *song = [_fetchedResultsController objectAtIndexPath:indexPath];
    PLPlayer *player = [PLPlayer sharedPlayer];

    BOOL wasCurrentSong = NO;
    if (player.currentSong == song) {
        player.currentSong = nil;
        wasCurrentSong = YES;
    }

    PLPlaylist *playlist = song.playlist;
    [playlist removeSong:song];
    
    if (wasCurrentSong)
        player.currentSong = playlist.currentSong;
    
    return [[PLDataAccess sharedDataAccess] saveChangesSignal];
}

- (RACSignal *)clearPlaylist
{
    PLPlayer *player = [PLPlayer sharedPlayer];
    
    if (player.currentSong == _playlist.currentSong)
        player.currentSong = nil;
    
    for (PLPlaylistSong *song in [_playlist.songs copy])
        [_playlist removeSong:song];
    
    return [[PLDataAccess sharedDataAccess] saveChangesSignal];
}

- (RACSignal *)moveSongFrom:(NSIndexPath *)fromIndexPath to:(NSIndexPath *)toIndexPath
{    
    id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];
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