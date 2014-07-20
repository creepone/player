#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPodcastsViewModel.h"
#import "PLServiceContainer.h"
#import "PLPodcastsManager.h"
#import "PLErrorManager.h"
#import "PLPodcast.h"
#import "PLPodcastCellViewModel.h"

@interface PLPodcastsViewModel() {
    RACDisposable *_searchDisposable;
}

@property (nonatomic, strong) NSArray *foundPodcasts;

@end

@implementation PLPodcastsViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
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
    _searchDisposable = [[[[[searchTermSignal doNext:^(id _) {
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
    if (self.isShowingSearch && !self.isSearching)
        return [self.foundPodcasts count];
    
    return 0;
}

- (NSString *)cellIdentifier
{
    return @"podcastCell";
}

- (CGFloat)cellHeight
{
    return 96.f;
}

- (PLPodcastCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath
{
    if (self.isShowingSearch) {
        PLPodcast *podcast = self.foundPodcasts[indexPath.row];
        return [[PLPodcastCellViewModel alloc] initWithPodcast:podcast];
    }
    
    return nil;
}

@end
