#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPodcastEpisodesViewModel.h"
#import "PLDataAccess.h"
#import "PLServiceContainer.h"
#import "PLPodcastsManager.h"
#import "NSArray+PLExtensions.h"
#import "PLPodcastEpisode.h"
#import "PLFetchedResultsControllerDelegate.h"
#import "PLErrorManager.h"
#import "PLFetchedResultsUpdate.h"
#import "PLPodcastEpisodeCellViewModel.h"

@interface PLPodcastEpisodesViewModel() {
    PLPodcastPin *_podcastPin;
    NSFetchedResultsController *_fetchedResultsController;
    PLFetchedResultsControllerDelegate *_fetchedResultsControllerDelegate;
    
    RACSubject *_newEpisodesUpdatesSubject;
    NSArray *_allEpisodes;
    NSMutableArray *_newEpisodes;
    NSMutableDictionary *_selection;
}

@property (nonatomic, assign, readwrite) BOOL ready;

@end

@implementation PLPodcastEpisodesViewModel

- (instancetype)initWithPodcastPin:(PLPodcastPin *)podcastPin selection:(NSMutableDictionary *)selection
{
    self = [super init];
    if (self) {
        _podcastPin = podcastPin;
        _selection = selection;
        _fetchedResultsController = [[PLDataAccess sharedDataAccess] fetchedResultsControllerForEpisodesOfPodcast:podcastPin];
        _fetchedResultsControllerDelegate = [[PLFetchedResultsControllerDelegate alloc] initWithFetchedResultsController:_fetchedResultsController];
        _newEpisodesUpdatesSubject = [RACSubject subject];
        
        NSError *error;
        [_fetchedResultsController performFetch:&error];
        if (error)
            [PLErrorManager logError:error];
        
        [self loadEpisodes];
    }
    return self;
}

- (NSString *)title
{
    return _podcastPin.title;
}

- (void)loadEpisodes
{
    NSURL *feedURL = [NSURL URLWithString:_podcastPin.feedURL];
    
    @weakify(self);
    [[PLResolve(PLPodcastsManager) episodesInFeed:feedURL] subscribeNext:^(NSArray *episodes) { @strongify(self);
        if (!self) return;
        
        _allEpisodes = episodes;
        id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];
        _newEpisodes = [[episodes pl_filter:^BOOL(PLPodcastEpisode *episode, NSUInteger idx) {
            return ![dataAccess existsPodcastOldEpisodeWithGuid:episode.guid];
        }] mutableCopy];
        
        [self subscribeToUpdates];
        self.ready = YES;
    }];
}

- (void)subscribeToUpdates
{
    [_fetchedResultsControllerDelegate.updatesSignal subscribeNext:^(NSArray *updates) {
        for (PLFetchedResultsUpdate *update in updates) {
            if (update.changeType == NSFetchedResultsChangeDelete) {
                PLPodcastOldEpisode *removedOldEpisode = (PLPodcastOldEpisode *)update.object;
                PLPodcastEpisode *episode = [_allEpisodes pl_find:^BOOL(PLPodcastEpisode *episode) {
                    return [episode.guid isEqualToString:removedOldEpisode.guid];
                }];
                
                if (episode != nil) {
                    NSInteger index = [self indexToInsertEpisode:episode];
                    
                    PLFetchedResultsUpdate *update = [PLFetchedResultsUpdate new];
                    update.changeType = NSFetchedResultsChangeInsert;
                    update.object = episode;
                    update.targetIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    [_newEpisodes insertObject:episode atIndex:index];
                    [_newEpisodesUpdatesSubject sendNext:@[update]];
                }
            }
            else if (update.changeType == NSFetchedResultsChangeInsert) {
                PLPodcastOldEpisode *insertedOldEpisode = (PLPodcastOldEpisode *)update.object;
                NSInteger episodeIndex = [_newEpisodes indexOfObjectPassingTest:^BOOL(PLPodcastEpisode *episode, NSUInteger idx, BOOL *stop) {
                    return [episode.guid isEqualToString:insertedOldEpisode.guid];
                }];
                
                if (episodeIndex != NSNotFound) {
                    PLFetchedResultsUpdate *update = [PLFetchedResultsUpdate new];
                    update.changeType = NSFetchedResultsChangeDelete;
                    update.object = _newEpisodes[episodeIndex];
                    update.indexPath = [NSIndexPath indexPathForRow:episodeIndex inSection:0];
                    [_newEpisodes removeObjectAtIndex:episodeIndex];
                    [_newEpisodesUpdatesSubject sendNext:@[update]];
                }
            }
        }
    }];
}

- (NSInteger)indexToInsertEpisode:(PLPodcastEpisode *)episode
{
    NSInteger originalIndex = [_allEpisodes indexOfObject:episode];
    
    for (NSInteger index = 0; index < [_newEpisodes count]; index++) {
        PLPodcastEpisode *otherEpisode = _newEpisodes[index];
        NSInteger originalOtherIndex = [_allEpisodes indexOfObject:otherEpisode];
        
        if (originalIndex < originalOtherIndex)
            return index;
    }
    
    return [_newEpisodes count];
}

- (RACSignal *)updatesSignal
{
    RACSignal *oldEpisodesUpdates = [_fetchedResultsControllerDelegate.updatesSignal map:^id(NSArray *updates) {
        return [updates pl_map:^id(PLFetchedResultsUpdate *update) {
            PLFetchedResultsUpdate *mappedUpdate = [PLFetchedResultsUpdate new];
            mappedUpdate.changeType = update.changeType;
            mappedUpdate.object = update.object;
            mappedUpdate.indexPath = [self secondSectionPath:update.indexPath];
            mappedUpdate.targetIndexPath = [self secondSectionPath:update.targetIndexPath];
            return mappedUpdate;
        }];
    }];
    
    return [RACSignal merge:@[_newEpisodesUpdatesSubject, oldEpisodesUpdates]];
}

- (NSInteger)sectionsCount
{
    if (!self.ready)
        return 0;
    
    return 2;
}

- (NSInteger)cellsCountInSection:(NSInteger)section
{
    if (section == 0) {
        return [_newEpisodes count];
    }
    else {
        return [_fetchedResultsController.sections[0] numberOfObjects];
    }
}

- (NSString *)sectionTitle:(NSInteger)section
{
    if (section == 0) {
        return @"New episodes"; // todo: localize
    }
    else {
        return @"Old episodes"; // todo: localize
    }
}

- (NSString *)cellIdentifier
{
    return @"episodeCell";
}

- (PLPodcastEpisodeCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PLPodcastEpisode *episode = _newEpisodes[indexPath.row];
        return [[PLPodcastEpisodeCellViewModel alloc] initWithPodcastEpisode:episode selected:[self isSelected:episode.guid]];
    }
    else {
        PLPodcastOldEpisode *episode = [_fetchedResultsController objectAtIndexPath:[self firstSectionPath:indexPath]];
        return [[PLPodcastEpisodeCellViewModel alloc] initWithPodcastOldEpisode:episode selected:[self isSelected:episode.guid]];
    }
}

- (void)toggleSelectAt:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PLPodcastEpisode *episode = _newEpisodes[indexPath.row];
        if ([self isSelected:episode.guid]) {
            [_selection removeObjectForKey:episode.guid];
        }
        else {
            _selection[episode.guid] = episode;
        }
    }
    else {
        PLPodcastOldEpisode *episode = [_fetchedResultsController objectAtIndexPath:[self firstSectionPath:indexPath]];
        if ([self isSelected:episode.guid]) {
            [_selection removeObjectForKey:episode.guid];
        }
        else {
            _selection[episode.guid] = [episode episode];
        }
    }
}

- (BOOL)isSelected:(NSString *)guid
{
    return _selection[guid] != nil;
}

- (NSIndexPath *)firstSectionPath:(NSIndexPath *)indexPath
{
    return [NSIndexPath indexPathForRow:indexPath.row inSection:0];
}

- (NSIndexPath *)secondSectionPath:(NSIndexPath *)indexPath
{
    return [NSIndexPath indexPathForRow:indexPath.row inSection:1];
}

@end
