#import <Foundation/Foundation.h>

@class RACSignal, PLPodcastCellViewModel;

@interface PLPodcastsViewModel : NSObject

/**
 * Returns YES if the corresponding view has been dismissed, NO otherwise.
 */
@property (nonatomic, assign) BOOL dismissed;

/**
 * Returns YES if the search (i.e. loading the search results) is currently in progress, NO otherwise.
 */
@property (nonatomic, assign) BOOL isSearching;

/**
 * Returns YES if the search view is currently active (whether or not we're actually searching), NO otherwise.
 */
@property (nonatomic, assign) BOOL isShowingSearch;

- (NSUInteger)cellsCount;
- (NSString *)cellIdentifier;
- (CGFloat)cellHeight;
- (PLPodcastCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath;;

- (void)setSearchTermSignal:(RACSignal *)searchTermSignal;

@end
