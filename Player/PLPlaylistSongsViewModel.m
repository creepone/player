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
    
    BOOL _askedToRemoveAll;
    NSInteger _removedCount;
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
    
    _removedCount++;
    
    return [[[PLDataAccess sharedDataAccess] saveChangesSignal] doCompleted:^{
        [self checkRemoveAll];
    }];
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

- (void)checkRemoveAll
{
    if (_askedToRemoveAll || _removedCount <= 2)
        return;
    
    _askedToRemoveAll = YES;
    
    // todo: localize
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Clear playlist" message:@"Do you want to clear the playlist?" delegate:nil cancelButtonTitle:NSLocalizedString(@"Common.Cancel", nil) otherButtonTitles:NSLocalizedString(@"Common.OK", nil), nil];
    [alertView show];
    
    [[[alertView rac_buttonClickedSignal] take:1] subscribeNext:^(NSNumber *buttonIndex) {
        if ([buttonIndex intValue] == alertView.cancelButtonIndex)
            return;
        
        _askedToRemoveAll = NO;
        [self clearPlaylist];
    }];
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