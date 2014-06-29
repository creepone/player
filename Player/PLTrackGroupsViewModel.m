#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLTrackGroupsViewModel.h"
#import "PLMediaLibrarySearch.h"
#import "PLTrackGroupCellViewModel.h"
#import "PLTracksViewModel.h"

@interface PLTrackGroupsViewModel() {
    NSArray *_trackGroups;

    NSMutableArray *_selection;
}

@property (nonatomic, assign, readwrite) BOOL ready;
@property (nonatomic, strong, readwrite) NSString *title;

@end

@implementation PLTrackGroupsViewModel

- (instancetype)initWithTrackGroupType:(PLTrackGroupType)trackGroupType selection:(NSMutableArray *)selection
{
    self = [super init];
    if (self) {
        _selection = selection;

        RACSignal *tracksSignal;

        switch (trackGroupType) {
            case PLTrackGroupTypeAudiobooks:
            {
                self.title = @"Audiobooks"; // todo: localize
                tracksSignal = [PLMediaLibrarySearch allAudiobooks];
                break;
            }
            case PLTrackGroupTypeAlbums:
            {
                self.title = @"Albums"; // todo: localize
                tracksSignal = [PLMediaLibrarySearch allAlbums];
                break;
            }
            case PLTrackGroupTypePlaylists:
            {
                self.title = @"Playlists"; // todo: localize
                tracksSignal = [PLMediaLibrarySearch allPlaylists];
                break;
            }
            case PLTrackGroupTypePodcasts:
            {
                self.title = @"Podcasts"; // todo: localize
                tracksSignal = [PLMediaLibrarySearch allPodcasts];
                break;
            }
            case PLTrackGroupTypeITunesU:
            {
                self.title = @"iTunes U"; // todo: localize
                tracksSignal = [PLMediaLibrarySearch allITunesU];
                break;
            }
        }

        @weakify(self);
        [tracksSignal subscribeNext:^(NSArray *groups) {
            @strongify(self);
            if (!self) return;

            self->_trackGroups = groups;
            self.ready = YES;
        }];
    }
    return self;
}

- (NSUInteger)groupsCount
{
    return [_trackGroups count];
}

- (PLTrackGroupCellViewModel *)groupCellViewModelAt:(NSIndexPath *)indexPath
{
    PLMediaItemTrackGroup *trackGroup = _trackGroups[indexPath.row];
    return [[PLTrackGroupCellViewModel alloc] initWithTrackGroup:trackGroup selected:NO];
}

- (PLTracksViewModel *)tracksViewModelAt:(NSIndexPath *)indexPath
{
    PLMediaItemTrackGroup *trackGroup = _trackGroups[indexPath.row];
    return [[PLTracksViewModel alloc] initWithTrackGroup:trackGroup selection:_selection];
}

@end