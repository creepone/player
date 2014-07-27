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

@interface PLPodcastsViewModel() {
    NSFetchedResultsController *_fetchedResultsController;
    PLFetchedResultsControllerDelegate *_fetchedResultsControllerDelegate;
    PLPodcastsSearchViewModel *_searchViewModel;
}

@end

@implementation PLPodcastsViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _searchViewModel = [PLPodcastsSearchViewModel new];
        _fetchedResultsController = [[PLDataAccess sharedDataAccess] fetchedResultsControllerForAllPodcastPins];
        _fetchedResultsControllerDelegate = [[PLFetchedResultsControllerDelegate alloc] initWithFetchedResultsController:_fetchedResultsController];
        
        NSError *error;
        [_fetchedResultsController performFetch:&error];
        if (error)
            [PLErrorManager logError:error];
    }
    return self;
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
    return @"podcastCell";
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

- (void)selectAt:(NSIndexPath *)indexPath
{
    // todo: implement
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

@end
