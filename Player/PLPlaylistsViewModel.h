#import <Foundation/Foundation.h>

@class PLPlaylistCellViewModel, RACSignal;

@interface PLPlaylistsViewModel : NSObject

- (NSUInteger)playlistsCount;
- (PLPlaylistCellViewModel *)playlistViewModelAt:(NSIndexPath *)indexPath;
- (RACSignal *)removePlaylistAt:(NSIndexPath *)indexPath;
- (RACSignal *)updatesSignal;

@end
