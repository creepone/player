//
//  PLPlayerViewController.h
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLPlayerViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *imgArtwork;
@property (strong, nonatomic) IBOutlet UILabel *labelTotal;
@property (strong, nonatomic) IBOutlet UILabel *labelCurrent;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelArtist;
@property (strong, nonatomic) IBOutlet UISlider *sliderTimeline;

- (IBAction)timelineChange:(id)sender;
- (IBAction)clickedPlayPause:(id)sender;
- (IBAction)clickedAddBookmark:(id)sender;
- (IBAction)clickedGoBack:(id)sender;

@end
