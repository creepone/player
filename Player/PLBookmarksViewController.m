//
//  PLBookmarksViewController.m
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "PLBookmarksViewController.h"
#import "PLDataAccess.h"
#import "PLAlerts.h"
#import "PLUtils.h"
#import "PLPlayer.h"

#import "NSString+Extensions.h"
#import "PLTrack.h"

@interface PLBookmarksViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
}

- (void)reloadData;
- (NSInteger)countOfBookmarks;

@end

@implementation PLBookmarksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Bookmarks";
        self.tabBarItem.image = [UIImage imageNamed:@"bookmark"];
        
        _fetchedResultsController = [[PLDataAccess sharedDataAccess] fetchedResultsControllerForAllBookmarks];
        [_fetchedResultsController setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self.navigationBar.items objectAtIndex:0] setRightBarButtonItem:self.editButtonItem];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    NSError *error;

    [_fetchedResultsController performFetch:&error];
    [PLAlerts checkForDataLoadError:error];
        
    self.tableView.rowHeight = 65.0;
    [self.tableView reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}


#pragma mark - Table view data source

- (NSInteger)countOfBookmarks {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self countOfBookmarks];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *kCellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
    }
    
    PLBookmark *bookmark = [_fetchedResultsController objectAtIndexPath:indexPath];
        
    cell.textLabel.text = bookmark.track.title;
    NSTimeInterval position = [bookmark.position doubleValue];
        
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", bookmark.track.artist, [PLUtils formatDuration:position]];
        
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PLPlayer *player = [PLPlayer sharedPlayer];
    [player stop];
    
    id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];
    PLPlaylist *bookmarkPlaylist = [dataAccess bookmarkPlaylist];
    
    PLBookmark *bookmark = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    // nothing to play
    if (bookmarkPlaylist == nil || bookmark.track == nil)
        return;
    
    // add the song to the playlist if it's not there
    PLPlaylistSong *playlistSong = [dataAccess findSongWithTrack:bookmark.track onPlaylist:bookmarkPlaylist];
    if (!playlistSong)
        playlistSong = [bookmarkPlaylist addTrack:bookmark.track];

    // select it and advance to the right position
    playlistSong.position = bookmark.position;
    bookmarkPlaylist.position = playlistSong.order;
    
    // select the playlist
    [dataAccess selectPlaylist:bookmarkPlaylist];
    
    // save all the modifications and play
    NSError *error;
    [dataAccess saveChanges:&error];
    if (![PLAlerts checkForDataStoreError:error])
        return;
    
    [player play];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteAtIndexPath:indexPath];
    }
}

- (void)deleteAtIndexPath:(NSIndexPath *)indexPath {
    NSError *error;
    id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];
    
    PLBookmark *bookmark = [_fetchedResultsController objectAtIndexPath:indexPath];
    [bookmark remove];

    [dataAccess saveChanges:&error];
    [PLAlerts checkForDataStoreError:error];
}


#pragma mark - Fetched result controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
        {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
    
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
