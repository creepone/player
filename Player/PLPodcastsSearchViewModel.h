#import <Foundation/Foundation.h>
#import "PLPodcastsViewModel.h"

@class RACSignal;

@interface PLPodcastsSearchViewModel : NSObject <PLPodcastsTableViewModel>

/**
 * Returns YES if the search (i.e. loading the search results) is currently in progress, NO otherwise.
 */
@property (nonatomic, assign) BOOL isSearching;

- (RACSignal *)dismissSignal;
- (void)setSearchTermSignal:(RACSignal *)searchTermSignal;

@end