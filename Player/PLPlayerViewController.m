//
//  PLPlayerViewController.m
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "PLPlayerViewController.h"
#import "PLDataAccess.h"
#import "PLPlayer.h"
#import "PLUtils.h"
#import "NSString+Extensions.h"


@interface PLPlayerViewController () {
    BOOL _isShown;
}

- (void)reloadData;
- (void)updateTimeline;

@end

@implementation PLPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Player";
        self.tabBarItem.image = [UIImage imageNamed:@"music"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.sliderTimeline.continuous = NO;
    self.btnPlayPause.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kPLPlayerSongChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kPLPlayerIsPlayingChange object:nil];
    
    _isShown = YES;
    [self reloadData];
    [self updateTimeline];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _isShown = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    PLPlayer *player = [PLPlayer sharedPlayer];
    PLPlaylistSong *currentSong = [player currentSong];
    
    if (currentSong == nil) {
        self.labelArtist.text = @"";
        self.labelTitle.text = @"";
        self.labelTotal.text = @"";
        self.labelCurrent.text = @"";
        self.sliderTimeline.hidden = YES;
        [self.btnPlayPause setTitle:@"Play" forState:UIControlStateNormal];
        
        self.imgArtwork.image = [UIImage imageNamed:@"default_artwork.jpg"];
    }
    else {
        MPMediaItem *mediaItem = currentSong.mediaItem;
        
        NSString *artist = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
        if ([artist pl_isEmptyOrWhitespace])
            artist = [mediaItem valueForProperty:MPMediaItemPropertyPodcastTitle];
        
        self.labelTitle.text = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
        self.labelArtist.text = artist;
        
        NSTimeInterval duration = [[mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
        self.labelTotal.text = [PLUtils formatDuration:duration];
        
        self.sliderTimeline.hidden = NO;
        
        MPMediaItemArtwork *itemArtwork = [mediaItem valueForProperty:MPMediaItemPropertyArtwork];
        UIImage *imageArtwork = [itemArtwork imageWithSize:CGSizeMake(self.imgArtwork.bounds.size.width, self.imgArtwork.bounds.size.height)];
    
        if (imageArtwork != nil) {
            self.imgArtwork.image = imageArtwork;
        }
        else {
            self.imgArtwork.image = [UIImage imageNamed:@"default_artwork.jpg"];
        }
        
        NSString *titleForButton = [player isPlaying] ? @"Pause" : @"Play";
        [self.btnPlayPause setTitle:titleForButton forState:UIControlStateNormal];
    }
}

- (void)updateTimeline {
    PLPlayer *player = [PLPlayer sharedPlayer];
    PLPlaylistSong *currentSong = [player currentSong];
    
    if (currentSong == nil || !_isShown) {
        return;
    }
    
    NSTimeInterval duration = [[currentSong.mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    NSTimeInterval currentPosition = [player currentPosition];
    
    self.labelCurrent.text = [PLUtils formatDuration:currentPosition];
    self.sliderTimeline.value = currentPosition / duration;
    
    // update again in a second
    [self performSelector:@selector(updateTimeline) withObject:self afterDelay:1.0];
}



- (IBAction)timelineChange:(id)sender {
    float value = self.sliderTimeline.value;
    
    PLPlayer *player = [PLPlayer sharedPlayer];
    PLPlaylistSong *currentSong = [player currentSong];
    
    if (currentSong == nil)
        return;
    
    NSTimeInterval duration = [[currentSong.mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    [player setCurrentPosition:duration * value];
}

- (IBAction)clickedPlayPause:(id)sender {
    [[PLPlayer sharedPlayer] playPause];
}

- (IBAction)clickedAddBookmark:(id)sender {
    [[PLPlayer sharedPlayer] makeBookmark];
}

- (IBAction)clickedGoBack:(id)sender {
    [[PLPlayer sharedPlayer] goBack];
}


@end
