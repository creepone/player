#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLFetchedResultsControllerDelegate.h"
#import "PLPodcastsViewModel.h"
#import "PLServiceContainer.h"
#import "PLPodcastsManager.h"
#import "PLErrorManager.h"
#import "PLPodcast.h"
#import "PLDataAccess.h"
#import "PLPodcastCellViewModel.h"
#import "PLPodcastsSearchViewModel.h"
#import "PLPodcastEpisodesViewModel.h"

@interface PLPodcastsViewModel() {
    NSFetchedResultsController *_fetchedResultsController;
    PLFetchedResultsControllerDelegate *_fetchedResultsControllerDelegate;
    PLPodcastsSearchViewModel *_searchViewModel;
    NSMutableArray *_selection;
}

@end

@implementation PLPodcastsViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _selection = [NSMutableArray array];
        _searchViewModel = [[PLPodcastsSearchViewModel alloc] initWithSelection:_selection];
        _fetchedResultsController = [[PLDataAccess sharedDataAccess] fetchedResultsControllerForAllPodcastPins];
        _fetchedResultsControllerDelegate = [[PLFetchedResultsControllerDelegate alloc] initWithFetchedResultsController:_fetchedResultsController];
        
        NSError *error;
        [_fetchedResultsController performFetch:&error];
        if (error)
            [PLErrorManager logError:error];
        
        [PLResolve(PLPodcastsManager) updateCounts];
    }
    return self;
}

- (NSArray *)selection
{
    return _selection;
}

- (PLPodcastsSearchViewModel *)searchViewModel
{
    return _searchViewModel;
}

- (NSUInteger)cellsCount
{
    return [_fetchedResultsController.sections[0] numberOfObjects];
}

- (NSString *)cellIdentifier
{
    return @"podcastMainCell";
}

- (CGFloat)cellHeight
{
    return 60.f;
}

- (UITableViewCellEditingStyle)cellEditingStyle
{
    return UITableViewCellEditingStyleDelete;
}

- (PLPodcastCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath
{
    PLPodcastPin *podcastPin = [_fetchedResultsController objectAtIndexPath:indexPath];
    return [[PLPodcastCellViewModel alloc] initWithPodcastPin:podcastPin];
}

- (void)removeAt:(NSIndexPath *)indexPath
{
    id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];
    PLPodcastPin *podcastPin = [_fetchedResultsController objectAtIndexPath:indexPath];
    [podcastPin remove];
    [[dataAccess saveChangesSignal] subscribeError:[PLErrorManager logErrorVoidBlock]];
}

- (RACSignal *)updatesSignal
{
    return _fetchedResultsControllerDelegate.updatesSignal;
}

- (PLPodcastEpisodesViewModel *)episodesViewModelAt:(NSIndexPath *)indexPath
{
    PLPodcastPin *podcastPin = [_fetchedResultsController objectAtIndexPath:indexPath];
    return [[PLPodcastEpisodesViewModel alloc] initWithPodcastPin:podcastPin selection:_selection];
}

@end
