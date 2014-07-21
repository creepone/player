#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLFetchedResultsControllerDelegate.h"
#import "PLPodcastsViewModel.h"
#import "PLServiceContainer.h"
#import "PLPodcastsManager.h"
#import "PLErrorManager.h"
#import "PLPodcast.h"
#import "PLDataAccess.h"
#import "PLPodcastCellViewModel.h"

@interface PLPodcastsViewModel() {
    RACDisposable *_searchDisposable;
    NSFetchedResultsController *_fetchedResultsController;
    PLFetchedResultsControllerDelegate *_fetchedResultsControllerDelegate;
}

@property (nonatomic, strong) NSArray *foundPodcasts;

@end

@implementation PLPodcastsViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fetchedResultsController = [[PLDataAccess sharedDataAccess] fetchedResultsControllerForAllPodcastPins];
        _fetchedResultsControllerDelegate = [[PLFetchedResultsControllerDelegate alloc] initWithFetchedResultsController:_fetchedResultsController];
        
        NSError *error;
        [_fetchedResultsController performFetch:&error];
        if (error)
            [PLErrorManager logError:error];
    }
    return self;
}

- (void)setIsShowingSearch:(BOOL)isShowingSearch
{
    _isShowingSearch = isShowingSearch;
    
    if (!isShowingSearch) {
        [_searchDisposable dispose];
        _searchDisposable = nil;
        self.isSearching = NO;
    }
}

- (void)setSearchTermSignal:(RACSignal *)searchTermSignal
{
    [_searchDisposable dispose];
    
    @weakify(self);
    _searchDisposable = [[[[[searchTermSignal doNext:^(id _) { @strongify(self);
        self.isSearching = YES;
    }]
    throttle:0.5]
    map:^id(NSString *searchTerm) {
        if ([searchTerm length] == 0)
            return [RACSignal return:[NSArray array]];
        
        return [[PLResolve(PLPodcastsManager) searchForPodcasts:searchTerm] catch:^RACSignal *(NSError *error) {
            [PLErrorManager logError:error];
            return [RACSignal return:[NSArray array]];
        }];
    }] switchToLatest]
    subscribeNext:^(NSArray *podcasts) { @strongify(self);
        self.foundPodcasts = podcasts;
        self.isSearching = NO;
    }];
}



- (NSUInteger)cellsCount
{
    if (self.isShowingSearch)
        return [self.foundPodcasts count];
    
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
    return self.isShowingSearch ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (PLPodcastCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath
{
    if (self.isShowingSearch) {
        PLPodcast *podcast = self.foundPodcasts[indexPath.row];
        return [[PLPodcastCellViewModel alloc] initWithPodcast:podcast];
    }
    
    PLPodcastPin *podcastPin = [_fetchedResultsController objectAtIndexPath:indexPath];
    return [[PLPodcastCellViewModel alloc] initWithPodcastPin:podcastPin];
}

- (void)selectAt:(NSIndexPath *)indexPath
{
    if (self.isShowingSearch) {
        PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
        PLPodcast *podcast = self.foundPodcasts[indexPath.row];
        PLPodcastPin *pin = podcast.pinned ? [dataAccess findPodcastPinWithFeedURL:[podcast.feedURL absoluteString]] : [dataAccess createPodcastPin:podcast];
        pin.order = [[dataAccess findHighestPodcastPinOrder] intValue] + 1;
        [[dataAccess saveChangesSignal] subscribeError:[PLErrorManager logErrorVoidBlock]];
        self.isShowingSearch = NO;
    }
}

- (void)removeAt:(NSIndexPath *)indexPath
{
    if (self.isShowingSearch)
        return;
    
    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
    PLPodcastPin *podcastPin = [_fetchedResultsController objectAtIndexPath:indexPath];
    [podcastPin remove];
    [[dataAccess saveChangesSignal] subscribeError:[PLErrorManager logErrorVoidBlock]];
}

- (RACSignal *)updatesSignal
{
    return _fetchedResultsControllerDelegate.updatesSignal;
}

@end
