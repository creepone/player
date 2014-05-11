#import <RXPromise/RXPromise.h>
#import "PLTrackGroupViewController.h"
#import "PLTracksViewController.h"
#import "PLMediaLibrarySearch.h"
#import "PLTrackGroupTableViewCell.h"
#import "PLTrackGroupTableViewCellController.h"
#import "PLTrackGroup.h"
#import "NSObject+PLExtensions.h"

@interface PLTrackGroupViewController () {
    NSArray *_groups;
}

@end

@implementation PLTrackGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // remove the extra separators under the table view
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    RXPromise *promise;
    
    switch (self.mediaType) {
        case MPMediaTypeAudioBook:
        {
            self.title = @"Audiobooks"; // todo: localize
            promise = [PLMediaLibrarySearch allAudiobooks];
            break;
        }
        default:
        {
            self.title = nil;
            return;
        }
    }
    
    @weakify(self);
    promise.thenOnMain(^id(NSArray *groups) {
        @strongify(self);
        if (!self)
            return nil;
        
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
    PLTrackGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackGroupCell" forIndexPath:indexPath];
    PLTrackGroup *trackGroup = [_groups objectAtIndex:indexPath.row];
    [PLTrackGroupTableViewCellController configureCell:cell withTrackGroup:trackGroup];
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell pl_removeAllPromises];
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
