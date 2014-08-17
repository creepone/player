#import <CoreData/CoreData.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPlaylistsViewModel.h"
#import "PLFetchedResultsControllerDelegate.h"
#import "PLDataAccess.h"
#import "PLErrorManager.h"
#import "PLPlaylistCellViewModel.h"
#import "PLPlayer.h"
#import "PLDataAccess.h"
#import "NSString+PLExtensions.h"

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

- (BOOL)allowDelete
{
    return [self playlistsCount] > 1;
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

- (RACSignal *)movePlaylistFrom:(NSIndexPath *)fromIndexPath to:(NSIndexPath *)toIndexPath
{
    id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];
    
    NSInteger indexFrom = [fromIndexPath row];
    NSInteger indexTo = [toIndexPath row];
    
    if(indexFrom != indexTo) {
        NSMutableArray *allPlaylists = [[_fetchedResultsController fetchedObjects] mutableCopy];
        
        PLPlaylist *playlistToMove = [allPlaylists objectAtIndex:indexFrom];
        [allPlaylists removeObjectAtIndex:indexFrom];
        [allPlaylists insertObject:playlistToMove atIndex:indexTo];
        
        int orderIndex = 0;
        for (PLPlaylist *playlist in allPlaylists) {
            orderIndex++;
            playlist.order = @(orderIndex);
        }
        
        return [dataAccess saveChangesSignal];
    }
    
    return [RACSignal empty];
}

- (RACSignal *)updatesSignal
{
    return _fetchedResultsControllerDelegate.updatesSignal;
}

- (void)addPlaylist
{
    // todo: replace with inline editing of the name in the table view cell
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New playlist" message:@"Enter a name for the new playlist" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [[[alert rac_buttonClickedSignal] take:1] subscribeNext:^(NSNumber *buttonIndex) {
        NSString *name = [[alert textFieldAtIndex:0] text];
        if ([name pl_isEmptyOrWhitespace])
            return;
        
        id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];
        [dataAccess createPlaylistWithName:name];
        
        [[dataAccess saveChangesSignal] subscribeError:[PLErrorManager logErrorVoidBlock]];
    }];
    [alert show];
}

@end
