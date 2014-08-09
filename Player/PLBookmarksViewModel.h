#import <Foundation/Foundation.h>

@class PLBookmarkCellViewModel, RACSignal;

@interface PLBookmarksViewModel : NSObject

- (NSUInteger)bookmarksCount;
- (PLBookmarkCellViewModel *)bookmarkViewModelAt:(NSIndexPath *)indexPath;
- (RACSignal *)removeBookmarkAt:(NSIndexPath *)indexPath;
- (RACSignal *)updatesSignal;

- (void)dismiss;

@end
