#import <Foundation/Foundation.h>

@class PLPlaylistCellViewModel, RACSignal;

@interface PLPlaylistsViewModel : NSObject

- (BOOL)allowDelete;
- (NSUInteger)playlistsCount;
- (PLPlaylistCellViewModel *)playlistViewModelAt:(NSIndexPath *)indexPath;
- (RACSignal *)movePlaylistFrom:(NSIndexPath *)fromIndexPath to:(NSIndexPath *)toIndexPath;
- (RACSignal *)removePlaylistAt:(NSIndexPath *)indexPath;
- (RACSignal *)updatesSignal;

- (void)addPlaylist;

@end
