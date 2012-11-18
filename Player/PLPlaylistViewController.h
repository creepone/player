//
//  PLPlaylistViewController.h
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLPlaylistViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)switchMode:(id)sender;
- (IBAction)addObject:(id)sender;

@end
