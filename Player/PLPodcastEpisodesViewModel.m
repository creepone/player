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
#import "PLNotificationObserver.h"

@interface PLPodcastEpisodesViewModel() {
    PLPodcastPin *_podcastPin;
    NSFetchedResultsController *_fetchedResultsController;
    PLFetchedResultsControllerDelegate *_fetchedResultsControllerDelegate;
    PLNotificationObserver *_notificationObserver;
    
    RACSubject *_newEpisodesUpdatesSubject;
    NSArray *_allEpisodes;
    NSMutableArray *_newEpisodes;
    NSMutableArray *_selection;
    
    NSInteger _markedOldCount;
    BOOL _askedToMarkAll;
}

@property (nonatomic, assign, readwrite) BOOL ready;

@end

@implementation PLPodcastEpisodesViewModel

- (instancetype)initWithPodcastPin:(PLPodcastPin *)podcastPin selection:(NSMutableArray *)selection
{
    self = [super init];
    if (self) {
        _podcastPin = podcastPin;
        _selection = selection;
        _fetchedResultsController = [[PLDataAccess sharedDataAccess] fetchedResultsControllerForEpisodesOfPodcast:podcastPin];
        _fetchedResultsControllerDelegate = [[PLFetchedResultsControllerDelegate alloc] initWithFetchedResultsController:_fetchedResultsController];
        _notificationObserver = [PLNotificationObserver observer];
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
    @weakify(self);
    [[PLResolve(PLPodcastsManager) episodesForPodcast:_podcastPin] subscribeNext:^(NSArray *episodes) { @strongify(self);
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
    @weakify(self);
    
    [_notificationObserver addNotification:PLEpisodeMarkedAsNew handler:^(NSNotification *notification) { @strongify(self);
        if (!self) return;
        
        NSString *episodeGuid = notification.userInfo[@"guid"];
        PLPodcastEpisode *episode = [self->_allEpisodes pl_find:^BOOL(PLPodcastEpisode *episode) {
            return [episode.guid isEqualToString:episodeGuid];
        }];
        
        if (episode != nil) {
            NSInteger index = [self indexToInsertEpisode:episode];
            
            PLFetchedResultsUpdate *update = [PLFetchedResultsUpdate new];
            update.changeType = NSFetchedResultsChangeInsert;
            update.object = episode;
            update.targetIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self->_newEpisodes insertObject:episode atIndex:index];
            [self->_newEpisodesUpdatesSubject sendNext:@[update]];
            
            self->_podcastPin.countNewEpisodes = [self->_newEpisodes count];
            [[[PLDataAccess sharedDataAccess] saveChangesSignal] subscribeError:[PLErrorManager logErrorVoidBlock]];
        }
    }];
    
    [_notificationObserver addNotification:PLEpisodeMarkedAsOld handler:^(NSNotification *notification) { @strongify(self);
        if (!self) return;
    
        PLPodcastOldEpisode *insertedOldEpisode = (PLPodcastOldEpisode *)notification.userInfo[@"episode"];;
        NSInteger episodeIndex = [self->_newEpisodes indexOfObjectPassingTest:^BOOL(PLPodcastEpisode *episode, NSUInteger idx, BOOL *stop) {
            return [episode.guid isEqualToString:insertedOldEpisode.guid];
        }];
        
        if (episodeIndex != NSNotFound) {
            PLFetchedResultsUpdate *update = [PLFetchedResultsUpdate new];
            update.changeType = NSFetchedResultsChangeDelete;
            update.object = self->_newEpisodes[episodeIndex];
            update.indexPath = [NSIndexPath indexPathForRow:episodeIndex inSection:0];
            [self->_newEpisodes removeObjectAtIndex:episodeIndex];
            [self->_newEpisodesUpdatesSubject sendNext:@[update]];
            
            self->_markedOldCount++;
            
            self->_podcastPin.countNewEpisodes = [self->_newEpisodes count];
            [[[PLDataAccess sharedDataAccess] saveChangesSignal] subscribeError:[PLErrorManager logErrorVoidBlock]];
            [self checkMarkAll];
        }
        
    }];
}

- (void)checkMarkAll
{
    if (_askedToMarkAll || _markedOldCount <= 2 || [_newEpisodes count] < 2)
        return;
    
    _askedToMarkAll = YES;
        
    // todo: localize
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mark all as old" message:@"Do you want to mark all episodes as old?" delegate:nil cancelButtonTitle:NSLocalizedString(@"Common.Cancel", nil) otherButtonTitles:NSLocalizedString(@"Common.OK", nil), nil];
    [alertView show];
    
    [[[alertView rac_buttonClickedSignal] take:1] subscribeNext:^(NSNumber *buttonIndex) {
        if ([buttonIndex intValue] == alertView.cancelButtonIndex)
            return;
        
        for (PLPodcastEpisode *episode in [_newEpisodes copy])
            [episode markAsOld];

        [[[PLDataAccess sharedDataAccess] saveChangesSignal] subscribeError:[PLErrorManager logErrorVoidBlock]];
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
    @weakify(self);
    RACSignal *oldEpisodesUpdates = [_fetchedResultsControllerDelegate.updatesSignal map:^id(NSArray *updates) { @strongify(self);
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
        BOOL isInFeed = [_allEpisodes pl_any:^BOOL(PLPodcastEpisode *newEpisode) { return [newEpisode.guid isEqualToString:episode.guid]; }];
        return [[PLPodcastEpisodeCellViewModel alloc] initWithPodcastOldEpisode:episode selected:[self isSelected:episode.guid] isInFeed:isInFeed];
    }
}

- (void)toggleSelectAt:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PLPodcastEpisode *episode = _newEpisodes[indexPath.row];
        PLPodcastEpisode *selectedEpisode = [self findSelected:episode.guid];
        if (selectedEpisode != nil) {
            [_selection removeObject:selectedEpisode];
        }
        else {
            [_selection addObject:episode];
        }
    }
    else {
        PLPodcastOldEpisode *episode = [_fetchedResultsController objectAtIndexPath:[self firstSectionPath:indexPath]];
        PLPodcastEpisode *selectedEpisode = [self findSelected:episode.guid];
        if (selectedEpisode != nil) {
            [_selection removeObject:selectedEpisode];
        }
        else {
            [_selection addObject:[episode episode]];
        }
    }
}

- (BOOL)isSelected:(NSString *)guid
{
    return [_selection pl_any:^BOOL(PLPodcastEpisode *episode) { return [episode.guid isEqualToString:guid]; }];
}

- (PLPodcastEpisode *)findSelected:(NSString *)guid
{
    return [_selection pl_find:^BOOL(PLPodcastEpisode *episode) { return [episode.guid isEqualToString:guid]; }];
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
