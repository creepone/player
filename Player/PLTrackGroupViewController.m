#import <RXPromise/RXPromise.h>
#import "PLTrackGroupViewController.h"
#import "PLTracksViewController.h"
#import "PLMediaLibrarySearch.h"
#import "PLTrackGroupCell.h"
#import "PLTableViewProgress.h"
#import "PLTrackGroupCellViewModel.h"

@interface PLTrackGroupViewController () {
    NSArray *_groups;
    PLTableViewProgress *_tableViewProgress;
}

@end

@implementation PLTrackGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // remove the extra separators under the table view
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    RXPromise *promise;
    
    switch (self.trackGroupType) {
        case PLTrackGroupTypeAudiobooks:
        {
            self.title = @"Audiobooks"; // todo: localize
            promise = [PLMediaLibrarySearch allAudiobooks];
            break;
        }
        case PLTrackGroupTypeAlbums:
        {
            self.title = @"Albums"; // todo: localize
            promise = [PLMediaLibrarySearch allAlbums];
            break;
        }
        case PLTrackGroupTypePlaylists:
        {
            self.title = @"Playlists"; // todo: localize
            promise = [PLMediaLibrarySearch allPlaylists];
            break;
        }
        case PLTrackGroupTypePodcasts:
        {
            self.title = @"Podcasts"; // todo: localize
            promise = [PLMediaLibrarySearch allPodcasts];
            break;
        }
        case PLTrackGroupTypeITunesU:
        {
            self.title = @"iTunes U"; // todo: localize
            promise = [PLMediaLibrarySearch allITunesU];
            break;
        }
        default:
        {
            self.title = nil;
            return;
        }
    }

    _tableViewProgress = [PLTableViewProgress showInTableView:self.tableView];
    
    @weakify(self);
    promise.thenOnMain(^id(NSArray *groups) {
        @strongify(self);
        if (!self)
            return nil;

        self->_tableViewProgress = nil;

        self->_groups = groups;
        [self.tableView reloadData];
        return nil;
    }, nil);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLTrackGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackGroupCell" forIndexPath:indexPath];
    PLMediaItemTrackGroup *trackGroup = [_groups objectAtIndex:indexPath.row];

    PLTrackGroupCellViewModel *modelView = [[PLTrackGroupCellViewModel alloc] initWithTrackGroup:trackGroup selected:NO];
    [cell setupBindings:modelView];

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"trackGroup"]) {
        PLTracksViewController *tracksVc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        tracksVc.trackGroup = _groups[indexPath.row];
    }
}

@end
