#import <RXPromise/RXPromise.h>
#import "PLTracksViewController.h"
#import "PLMusicLibraryViewController.h"
#import "PLTrackGroupCell.h"
#import "PLTrackCell.h"
#import "PLMediaItemTrackGroup.h"
#import "PLMediaItemTrack.h"
#import "NSArray+PLExtensions.h"
#import "PLTableViewProgress.h"
#import "PLTrackGroupCellModelView.h"
#import "PLTrackCellModelView.h"

@interface PLTracksViewController () {
    NSMutableSet *_selection;
    NSMutableArray *_globalSelection;
    NSArray *_tracks;
    PLTableViewProgress *_tableViewProgress;
}

@end

@implementation PLTracksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // remove the extra separators under the table view
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.title = self.trackGroup.title;
    
    PLMusicLibraryViewController *musicLibraryVC = self.navigationController.viewControllers[0];
    _globalSelection = musicLibraryVC.selection;
    _selection = [NSMutableSet set];
    
    _tableViewProgress = [PLTableViewProgress showInTableView:self.tableView];

    @weakify(self);
    self.trackGroup.tracks.thenOnMain(^id(NSArray *tracks) {
        @strongify(self);
        if (!self)
            return nil;
        
        self->_tableViewProgress = nil;
        
        self->_tracks = tracks;
        [self initializeSelection];
        [self.tableView reloadData];
        return nil;
    }, nil);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_tracks)
        return 0;
    
    return section == 0 ? 1 : _tracks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return 96.f;
    else
        return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PLTrackGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackGroupHeaderCell" forIndexPath:indexPath];

        PLTrackGroupCellModelView *modelView = [[PLTrackGroupCellModelView alloc] initWithTrackGroup:self.trackGroup selected:[self isAllSelected]];
        [cell setupBindings:modelView];

        return cell;
    }
    else if (indexPath.section == 1) {
        PLTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell" forIndexPath:indexPath];
        PLMediaItemTrack *track = _tracks[indexPath.row];

        PLTrackCellModelView *modelView = [[PLTrackCellModelView alloc] initWithTrack:track selected:[self isTrackSelected:track]];
        [cell setupBindings:modelView];

        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
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
    else if (indexPath.section == 1) {
        PLMediaItemTrack *track = _tracks[indexPath.row];
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
    [self.tableView reloadData];
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

@end
