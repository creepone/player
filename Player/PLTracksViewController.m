#import <RXPromise/RXPromise.h>
#import "PLTracksViewController.h"
#import "PLMusicLibraryViewController.h"
#import "PLTrackGroupTableViewCell.h"
#import "PLTrackGroupTableViewCellController.h"
#import "PLTrackTableViewCell.h"
#import "PLTrackTableViewCellController.h"
#import "PLMediaItemTrackGroup.h"
#import "PLMediaItemTrack.h"
#import "NSArray+PLExtensions.h"

@interface PLTracksViewController () {
    NSMutableSet *_selection;
    NSMutableArray *_globalSelection;
    NSArray *_tracks;
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

    @weakify(self);
    self.trackGroup.tracks.thenOnMain(^id(NSArray *tracks) {
        @strongify(self);
        if (!self)
            return nil;
        
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
    return section == 0 ? 1 : _tracks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return 96.;
    else
        return self.tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PLTrackGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackGroupHeaderCell" forIndexPath:indexPath];
        [PLTrackGroupTableViewCellController configureCell:cell withTrackGroup:self.trackGroup selected:[self isAllSelected]];
        return cell;
    }
    else if (indexPath.section == 1) {
        PLTrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell" forIndexPath:indexPath];
        PLMediaItemTrack *track = _tracks[indexPath.row];
        [PLTrackTableViewCellController configureCell:cell withTrack:track selected:[self isTrackSelected:track]];
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
