#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLServiceContainer.h"
#import "PLPodcastsSearchViewModel.h"
#import "PLErrorManager.h"
#import "PLPodcastsManager.h"
#import "PLPodcastCellViewModel.h"
#import "PLPodcast.h"
#import "PLDataAccess.h"

@interface PLPodcastsSearchViewModel() {
    RACDisposable *_searchDisposable;
    RACSubject *_dismissSubject;
}

@property (nonatomic, strong) NSArray *foundPodcasts;

@end

@implementation PLPodcastsSearchViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dismissSubject = [RACSubject subject];
    }
    return self;
}


- (void)setSearchTermSignal:(RACSignal *)searchTermSignal
{
    [_searchDisposable dispose];
    
    if (searchTermSignal == nil) {
        _searchDisposable = nil;
        self.isSearching = NO;
        return;
    }
    
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
    return [self.foundPodcasts count];
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
    return UITableViewCellEditingStyleNone;
}

- (PLPodcastCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath
{
    PLPodcast *podcast = self.foundPodcasts[indexPath.row];
    return [[PLPodcastCellViewModel alloc] initWithPodcast:podcast];
}

- (void)selectAt:(NSIndexPath *)indexPath
{
    id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];
    PLPodcast *podcast = self.foundPodcasts[indexPath.row];
    PLPodcastPin *pin = podcast.pinned ? [dataAccess findPodcastPinWithFeedURL:[podcast.feedURL absoluteString]] : [dataAccess createPodcastPin:podcast];
    pin.order = [[dataAccess findHighestPodcastPinOrder] intValue] + 1;
    [[dataAccess saveChangesSignal] subscribeError:[PLErrorManager logErrorVoidBlock]];
    
    [_dismissSubject sendNext:@(YES)];
}

- (void)removeAt:(NSIndexPath *)indexPath
{
    // noop
}

- (RACSignal *)dismissSignal
{
    return _dismissSubject;
}

@end
