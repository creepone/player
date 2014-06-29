#import "PLTracksViewModel.h"
#import "PLMediaItemTrackGroup.h"
#import "PLMediaItemTrack.h"
#import "NSArray+PLExtensions.h"
#import "PLTrackGroupCellViewModel.h"
#import "PLTrackCellViewModel.h"

@interface PLTracksViewModel() {
    PLMediaItemTrackGroup *_trackGroup;

    NSMutableSet *_selection;
    NSMutableArray *_globalSelection;
    NSArray *_tracks;
}

@property (nonatomic, assign, readwrite) BOOL ready;
@property (nonatomic, strong, readwrite) NSString *title;

@end

@implementation PLTracksViewModel

- (instancetype)initWithTrackGroup:(PLMediaItemTrackGroup *)trackGroup selection:(NSMutableArray *)selection
{
    self = [super init];
    if (self) {
        _trackGroup = trackGroup;

        self.title = trackGroup.title;

        _globalSelection = selection;
        _selection = [NSMutableSet set];

        @weakify(self);
        [trackGroup.tracks subscribeNext:^(NSArray *tracks) {
            @strongify(self);
            if (!self) return;

            self->_tracks = tracks;
            [self initializeSelection];
            self.ready = YES;
        }];
    }
    return self;
}


- (BOOL)isAllSelected
{
    return [_tracks count] > 0 && [_selection count] == [_tracks count];
}

- (BOOL)isTrackSelected:(PLMediaItemTrack *)track
{
    return [_selection containsObject:track.persistentId];
}

- (void)initializeSelection
{
    for (NSNumber *persistentId in self.trackPersistentIds) {
        if ([_globalSelection containsObject:persistentId])
            [_selection addObject:persistentId];
    }
}

- (NSArray *)trackPersistentIds
{
    return [_tracks pl_map:^(PLMediaItemTrack *track) { return track.persistentId; }];
}


- (NSUInteger)tracksCount
{
    return [_tracks count];
}

- (PLTrackGroupCellViewModel *)groupCellViewModel
{
    return [[PLTrackGroupCellViewModel alloc] initWithTrackGroup:_trackGroup selected:[self isAllSelected]];
}

- (PLTrackCellViewModel *)trackCellViewModelAtIndex:(NSUInteger)index
{
    PLMediaItemTrack *track = _tracks[index];
    return [[PLTrackCellViewModel alloc] initWithTrack:track selected:[self isTrackSelected:track]];
}

- (void)toggleSelectionGroup
{
    if ([self isAllSelected]) {
        [_globalSelection removeObjectsInArray:[_selection allObjects]];
        [_selection removeAllObjects];
    }
    else {
        [_globalSelection removeObjectsInArray:[_selection allObjects]];
        [_selection removeAllObjects];
        [_globalSelection addObjectsFromArray:self.trackPersistentIds];
        [_selection addObjectsFromArray:self.trackPersistentIds];
    }
}

- (void)toggleSelectionTrackAtIndex:(NSUInteger)index
{
    PLMediaItemTrack *track = _tracks[index];
    NSNumber *persistentId = track.persistentId;

    if ([self isTrackSelected:track]) {
        [_globalSelection removeObject:persistentId];
        [_selection removeObject:persistentId];
    }
    else {
        [_globalSelection addObject:persistentId];
        [_selection addObject:persistentId];
    }
}


@end