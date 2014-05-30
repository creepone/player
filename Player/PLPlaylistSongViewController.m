//
//  PLPlaylistSongViewController.m
//  Player
//
//  Created by Tomas Vana on 3/24/13.
//  Copyright (c) 2013 Tomas Vana. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "PLPlaylistSongViewController.h"
#import "PLDefaultsManager.h"
#import "PLPlayer.h"
#import "PLDataAccess.h"
#import "PLAlerts.h"
#import "SliderCell.h"
#import "NSString+Extensions.h"

@interface PLPlaylistSongViewController () {
    PLPlaylistSong *_song;
    UISwitch *_switchPlaybackRate;
}

- (void)setupNavbarItems;

@end

@implementation PLPlaylistSongViewController

- (id)initWithPlaylistSong:(PLPlaylistSong *)song
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Details";
        _song = song;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.scrollEnabled = NO;
    [self setupNavbarItems];
    
    _switchPlaybackRate = [[UISwitch alloc] initWithFrame:CGRectZero];
    _switchPlaybackRate.onTintColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0];
    [_switchPlaybackRate addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)setupNavbarItems
{    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(tappedDone)];;
}

- (void)tappedDone
{
    NSError *error;
    [[PLDataAccess sharedDataAccess] saveChanges:&error];
    
    if ([PLAlerts checkForDataStoreError:error])
        [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)switchChanged:(id)sender
{
    PLPlayer *player = [PLPlayer sharedPlayer];
    
    if (_switchPlaybackRate.on) {
        if (player.currentSong == _song)
            [player setPlaybackRate:1.0];
        
        _song.playbackRate = [NSNumber numberWithDouble:1.0];
    }
    else {
        if (player.currentSong == _song)
            [player setPlaybackRate:[PLDefaultsManager playbackRate]];
        
        _song.playbackRate = [NSNumber numberWithDouble:0.0];;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_song.playbackRate doubleValue] > 0.01 ? 3 : 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
        return 60.0;
    else if (indexPath.row == 2)
        return 80.0;
    else
        return 45.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell1"];
        cell.textLabel.text = _song.title;
        cell.detailTextLabel.text = _song.artist;
        return cell;
    }
    else if (indexPath.row == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell2"];
        
        cell.textLabel.text = @"Custom playback rate";
        cell.accessoryView = _switchPlaybackRate;
        
        _switchPlaybackRate.on = [_song.playbackRate doubleValue] > 0.01;
        
        return cell;
    }
    if (indexPath.row == 2) {
        NSArray *loadedControls = [[NSBundle mainBundle] loadNibNamed:@"SliderCell" owner:nil options:nil];
        SliderCell *sliderCell = [loadedControls objectAtIndex:0];
        [sliderCell.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        double playbackRate = [[_song playbackRate] doubleValue];
        sliderCell.slider.value = playbackRate;
        sliderCell.labelValue.text = [NSString stringWithFormat:@"%.2f", playbackRate];
        
        return sliderCell;
    }
    
    return nil;
}

- (void)sliderValueChanged:(id)sender
{
    UISlider *slider = sender;
    
    SliderCell *sliderCell = (SliderCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    sliderCell.labelValue.text = [NSString stringWithFormat:@"%.2f", slider.value];
    
    _song.playbackRate = [NSNumber numberWithDouble:slider.value];
    
    PLPlayer *player = [PLPlayer sharedPlayer];
    if (player.currentSong == _song)
        [player setPlaybackRate:slider.value];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
