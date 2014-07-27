#import <Foundation/Foundation.h>

@class RACSignal, PLPodcastCellViewModel, PLPodcastsSearchViewModel, PLPodcastEpisodesViewModel;

@protocol PLPodcastsTableViewModel <NSObject>

- (NSUInteger)cellsCount;
- (NSString *)cellIdentifier;
- (CGFloat)cellHeight;
- (UITableViewCellEditingStyle)cellEditingStyle;
- (PLPodcastCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath;
- (PLPodcastEpisodesViewModel *)episodesViewModelAt:(NSIndexPath *)indexPath;

@end

@interface PLPodcastsViewModel : NSObject <PLPodcastsTableViewModel>

- (NSArray *)selection;

/**
 * Returns YES if the corresponding view has been dismissed, NO otherwise.
 */
@property (nonatomic, assign) BOOL dismissed;

- (PLPodcastsSearchViewModel *)searchViewModel;
- (RACSignal *)updatesSignal;
- (void)removeAt:(NSIndexPath *)indexPath;

@end
