#import <Foundation/Foundation.h>

@class PLPlaylistSongCellViewModel, PLPlaylist;

@interface PLPlaylistSongsViewModel : NSObject

- (instancetype)initWithPlaylist:(PLPlaylist *)playlist;

- (NSString *)title;
- (NSUInteger)songsCount;
- (PLPlaylistSongCellViewModel *)songViewModelAt:(NSIndexPath *)indexPath;
- (void)selectSongAt:(NSIndexPath *)indexPath;
- (RACSignal *)moveSongFrom:(NSIndexPath *)fromIndexPath to:(NSIndexPath *)toIndexPath;
- (RACSignal *)removeSongAt:(NSIndexPath *)indexPath;

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