#import <CoreData/CoreData.h>
#import "PLBookmarksViewModel.h"
#import "PLFetchedResultsControllerDelegate.h"
#import "PLDataAccess.h"
#import "PLErrorManager.h"
#import "PLBookmarkCellViewModel.h"
#import "PLBookmarkSong.h"
#import "PLPlayer.h"

@interface PLBookmarksViewModel() {
    NSFetchedResultsController *_fetchedResultsController;
    PLFetchedResultsControllerDelegate *_fetchedResultsControllerDelegate;
}

@end

@implementation PLBookmarksViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];
        _fetchedResultsController = [dataAccess fetchedResultsControllerForAllBookmarks];
        _fetchedResultsControllerDelegate = [[PLFetchedResultsControllerDelegate alloc] initWithFetchedResultsController:_fetchedResultsController];
        
        NSError *error;
        [_fetchedResultsController performFetch:&error];
        if (error)
            [PLErrorManager logError:error];
    }
    return self;
}

- (NSUInteger)bookmarksCount
{
    return [_fetchedResultsController.sections[0] numberOfObjects];
}

- (PLBookmarkCellViewModel *)bookmarkViewModelAt:(NSIndexPath *)indexPath
{
    PLBookmark *bookmark = [_fetchedResultsController objectAtIndexPath:indexPath];
    PLBookmarkSong *bookmarkSong = [PLBookmarkSong bookmarkSongWithBookmark:bookmark];
    return [[PLBookmarkCellViewModel alloc] initWithBookmarkSong:bookmarkSong];
}


- (RACSignal *)removeBookmarkAt:(NSIndexPath *)indexPath
{
    PLBookmark *bookmark = [_fetchedResultsController objectAtIndexPath:indexPath];
    PLPlayer *player = [PLPlayer sharedPlayer];
    
    if ([player.currentSong isKindOfClass:[PLBookmarkSong class]]) {
        PLBookmarkSong *selectedBookmarkSong = (PLBookmarkSong *)player.currentSong;
        if (selectedBookmarkSong.bookmark == bookmark) {
            player.currentSong = nil;
        }
    }
    
    [bookmark remove];
    return [[PLDataAccess sharedDataAccess] saveChangesSignal];
}

- (RACSignal *)updatesSignal
{
    return _fetchedResultsControllerDelegate.updatesSignal;
}


- (void)dismiss
{
    PLPlayer *player = [PLPlayer sharedPlayer];
    if ([player.currentSong isKindOfClass:[PLBookmarkSong class]])
        [player setCurrentSong:nil];
}

@end
