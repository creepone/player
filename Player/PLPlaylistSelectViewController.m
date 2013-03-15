//
//  PLPlaylistSelectViewController.m
//  Player
//
//  Created by Tomas Vana on 2/16/13.
//  Copyright (c) 2013 Tomas Vana. All rights reserved.
//

#import "PLPlaylistSelectViewController.h"
#import "PLDataAccess.h"
#import "PLAlerts.h"

@interface PLPlaylistSelectViewController () {
    NSFetchedResultsController *_fetchedResultsController;
}

@end

@implementation PLPlaylistSelectViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Select playlist";
        
        _fetchedResultsController = [[PLDataAccess sharedDataAccess] fetchedResultsControllerForAllPlaylists];

        NSError *error;
        [_fetchedResultsController performFetch:&error];
        [PLAlerts checkForDataLoadError:error];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(clickedCancel)];
    [self.navigationItem setRightBarButtonItem:cancelButton];
}

- (void)clickedCancel {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    PLPlaylist *playlist = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = playlist.name;    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PLPlaylist *playlist = [_fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate didSelectPlaylist:playlist];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
