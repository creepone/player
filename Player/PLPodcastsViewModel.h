#import <Foundation/Foundation.h>

@class RACSignal, PLPodcastCellViewModel, PLPodcastsSearchViewModel;

@protocol PLPodcastsTableViewModel

- (NSUInteger)cellsCount;
- (NSString *)cellIdentifier;
- (CGFloat)cellHeight;
- (UITableViewCellEditingStyle)cellEditingStyle;
- (PLPodcastCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath;
- (void)selectAt:(NSIndexPath *)indexPath;
- (void)removeAt:(NSIndexPath *)indexPath;

@end

@interface PLPodcastsViewModel : NSObject <PLPodcastsTableViewModel>

/**
 * Returns YES if the corresponding view has been dismissed, NO otherwise.
 */
@property (nonatomic, assign) BOOL dismissed;

- (PLPodcastsSearchViewModel *)searchViewModel;
- (RACSignal *)updatesSignal;

@end
