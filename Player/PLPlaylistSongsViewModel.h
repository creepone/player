#import <Foundation/Foundation.h>

@class PLPlaylistSongCellViewModel;

@interface PLPlaylistSongsViewModel : NSObject

- (NSUInteger)songsCount;
- (PLPlaylistSongCellViewModel *)songViewModelAt:(NSIndexPath *)indexPath;
- (void)selectSongAt:(NSIndexPath *)indexPath;
- (void)removeSongAt:(NSIndexPath *)indexPath;

/**
* Returns a signal that delivers an NSArray of PLFetchedResultsUpdate objects each time
* the songs collection has been modified.
*/
- (RACSignal *)updatesSignal;

/**
* Temporary command that switches back to the legacy mode.
*/
- (RACCommand *)switchCommand;

/**
* Command that displays the UI where user can select tracks to be imported.
*/
- (RACCommand *)addCommand;

@end