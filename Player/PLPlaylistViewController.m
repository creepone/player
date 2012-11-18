//
//  PLPlaylistViewController.m
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "PLPlaylistViewController.h"
#import "PLDataAccess.h"
#import "PLAlerts.h"
#import "PLPlayer.h"
#import "NSString+Extensions.h"

#define kSongRowHeight 65.0

@interface PLPlaylistViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, MPMediaPickerControllerDelegate> {
    BOOL _singleMode;   // YES = single playlist, NO = all playlists
    NSFetchedResultsController *_songsFetchedResultsController;
    NSFetchedResultsController *_playlistsFetchedResultsController;
    PLPlaylist *_selectedPlaylist;
    
    BOOL _inReorderingOperation;
}

- (void)reloadData;
- (NSInteger)countOfPlaylists;
- (void)deleteAtIndexPath:(NSIndexPath *)indexPath;
- (void)selectPlaylist:(PLPlaylist *)playlist;

@end

@implementation PLPlaylistViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Playlists";
        self.tabBarItem.image = [UIImage imageNamed:@"list"];
        
        _singleMode = YES;
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

- (IBAction)switchMode:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    if (segmentedControl.selectedSegmentIndex == 0 && !_singleMode) {
        _singleMode = YES;
        [self reloadData];
    }
    else if (segmentedControl.selectedSegmentIndex == 1 && _singleMode) {
        _singleMode = NO;
        [self reloadData];
    }
}

- (IBAction)addObject:(id)sender {
    if (_singleMode) {
        MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
        [picker setDelegate: self];
        [picker setAllowsPickingMultipleItems:YES];
        picker.prompt = @"Add songs to playlist";
        
        [self presentViewController:picker animated:YES completion:nil];        
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New playlist" message:@"Enter a name for the new playlist" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    
}

- (void)reloadData {
    NSError *error;
    _selectedPlaylist = [[PLDataAccess sharedDataAccess] selectedPlaylist];
    
    if (_singleMode) {        
        _songsFetchedResultsController = [[PLDataAccess sharedDataAccess] fetchedResultsControllerForSongsOfPlaylist:_selectedPlaylist];
        [_songsFetchedResultsController performFetch:&error];
        [PLAlerts checkForDataLoadError:error];
        
        [_songsFetchedResultsController setDelegate:self];
        
        self.tableView.rowHeight = kSongRowHeight;
    }
    else {
        if (_playlistsFetchedResultsController == nil) {
            _playlistsFetchedResultsController = [[PLDataAccess sharedDataAccess] fetchedResultsControllerForAllPlaylists];
            [_playlistsFetchedResultsController performFetch:&error];
            [PLAlerts checkForDataLoadError:error];
        }
        
        [_songsFetchedResultsController setDelegate:nil];
        [_playlistsFetchedResultsController setDelegate:self];
        self.tableView.rowHeight = 45.0;
    }
    
    [self.tableView reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSString *name = [[alertView textFieldAtIndex:0] text];
        if ([name pl_isEmptyOrWhitespace])
            return;
        
        PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
        [dataAccess createPlaylist:name];
        
        NSError *error;
        [dataAccess saveChanges:&error];
        [PLAlerts checkForDataStoreError:error];
    }
}

- (void)deleteAtIndexPath:(NSIndexPath *)indexPath {
    NSError *error;
    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
    
    if (_singleMode) {
        PLPlaylistSong *song = [_songsFetchedResultsController objectAtIndexPath:indexPath];
        [song.playlist removeSong:song];
        
        [dataAccess saveChanges:&error];
        [PLAlerts checkForDataStoreError:error];
    }
    else {
        BOOL selectFirst = NO;
        
        PLPlaylist *playlist = [_playlistsFetchedResultsController objectAtIndexPath:indexPath];
        if (playlist == _selectedPlaylist)
            selectFirst = YES;
        
        [dataAccess deleteObject:playlist error:&error];
        [PLAlerts checkForDataStoreError:error];
        
        if (selectFirst) {
            PLPlaylist *firstPlaylist = [_playlistsFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [self selectPlaylist:firstPlaylist];
        }
    }
}

- (void)selectPlaylist:(PLPlaylist *)playlist {
    PLPlayer *player = [PLPlayer sharedPlayer];
    [player stop];
    
    _selectedPlaylist = playlist;
    [[PLDataAccess sharedDataAccess] selectPlaylist:playlist];

    [player play];
}


#pragma mark - Table view data source

- (NSInteger)countOfPlaylists {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_playlistsFetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (NSInteger)countOfSongs {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_songsFetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _singleMode ? [self countOfSongs] : [self countOfPlaylists];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *kSongCellIdentifier = @"SongCell";
    static NSString *kPlaylistCellIdentifier = @"PlaylistCell";
    
    NSString *cellIndentifier = _singleMode ? kSongCellIdentifier : kPlaylistCellIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil) {
        cell =  _singleMode ?
        [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kSongCellIdentifier]
        : [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPlaylistCellIdentifier];
    }
    
    if (_singleMode) {
        PLPlaylistSong *song = [_songsFetchedResultsController objectAtIndexPath:indexPath];
        MPMediaItem *mediaItem = song.mediaItem;
        
        cell.textLabel.text = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
        NSString *artist = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
        
        if ([artist pl_isEmptyOrWhitespace])
            artist = [mediaItem valueForProperty:MPMediaItemPropertyPodcastTitle];
        
        NSTimeInterval duration = [[mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
        
        long min = (long)duration / 60;
        long sec = (long)duration % 60;
        NSString *durationString = [[NSString alloc] initWithFormat:@"%02ld:%02ld", min, sec];
        
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", artist, durationString];
        
        MPMediaItemArtwork *itemArtwork = [mediaItem valueForProperty:MPMediaItemPropertyArtwork];
        UIImage *imageArtwork = [itemArtwork imageWithSize:CGSizeMake(kSongRowHeight, kSongRowHeight)];
        if (imageArtwork != nil) {
            cell.imageView.image = imageArtwork;
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"default_artwork.jpg"];
        }
        
        if ([_selectedPlaylist.position intValue] == [song.order intValue]) {
            cell.textLabel.textColor = [UIColor orangeColor];
        }
        else {
            cell.textLabel.textColor = [UIColor blackColor];
        }
        
    }
    else {
        PLPlaylist *playlist = [_playlistsFetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = playlist.name;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (playlist == _selectedPlaylist)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_singleMode && [self countOfPlaylists] <= 1)
        return UITableViewCellEditingStyleNone;
    else
        return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return _singleMode;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSInteger indexFrom = [fromIndexPath row];
    NSInteger indexTo = [toIndexPath row];
    
    if(indexFrom != indexTo) {
        _inReorderingOperation = YES;
        
        NSMutableArray *allSongs = [[_songsFetchedResultsController fetchedObjects] mutableCopy];
        
        PLPlaylistSong *songToMove = [allSongs objectAtIndex:indexFrom];
        [allSongs removeObjectAtIndex:indexFrom];
        [allSongs insertObject:songToMove atIndex:indexTo];
        
        [_selectedPlaylist renumberSongsOrder:allSongs];
        
        NSError *error;        
        [[PLDataAccess sharedDataAccess] saveChanges:&error];
        [PLAlerts checkForDataStoreError:error];
        
        _inReorderingOperation = NO;
    }
    
    if(fromIndexPath.row != toIndexPath.row)
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.02];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_singleMode) {
        PLPlayer *player = [PLPlayer sharedPlayer];
        [player stop];
        
        PLPlaylistSong *song = [_songsFetchedResultsController objectAtIndexPath:indexPath];
        _selectedPlaylist.position = song.order;
        
        NSError *error;
        [[PLDataAccess sharedDataAccess] saveChanges:&error];
        [PLAlerts checkForDataStoreError:error];
        
        [player play];
        
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }
    else {
        PLPlaylist *playlist = [_playlistsFetchedResultsController objectAtIndexPath:indexPath];
        [self selectPlaylist:playlist];
        [self.tableView reloadData];
        
        self.segmentedControl.selectedSegmentIndex = 0;
        [self switchMode:self.segmentedControl];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteAtIndexPath:indexPath];
    }
}


#pragma mark - Fetched result controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if(_inReorderingOperation)
        return;
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
    if(_inReorderingOperation)
        return;
        
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
    if(_inReorderingOperation)
        return;
    
    [self.tableView endUpdates];
}


#pragma mark - Media picker controller delegate

- (void) mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)collection {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
        
    for (MPMediaItem *item in [collection items]) {
        [dataAccess addSong:item toPlaylist:_selectedPlaylist];
    }
    
    NSError *error;
    [dataAccess saveChanges:&error];
    [PLAlerts checkForDataStoreError:error];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)dealloc {
    [_playlistsFetchedResultsController setDelegate:nil];
}


@end