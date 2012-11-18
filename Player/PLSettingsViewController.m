//
//  PLSettingsViewController.m
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import "PLSettingsViewController.h"
#import "PLDefaultsManager.h"
#import "PLPlayer.h"
#import "SliderCell.h"

@interface PLSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation PLSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Settings";
        self.tabBarItem.image = [UIImage imageNamed:@"settings"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        NSArray *loadedControls = [[NSBundle mainBundle] loadNibNamed:@"SliderCell" owner:nil options:nil];
        SliderCell *sliderCell = [loadedControls objectAtIndex:0];
        [sliderCell.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        double playbackRate = [PLDefaultsManager playbackRate];
        sliderCell.slider.value = playbackRate;
        sliderCell.labelValue.text = [NSString stringWithFormat:@"%.2f", playbackRate];
        
        return sliderCell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 0)
        return 80.0;
    else
        return 45.0;
}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = sender;
    
    SliderCell *sliderCell = (SliderCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    sliderCell.labelValue.text = [NSString stringWithFormat:@"%.2f", slider.value];

    [PLDefaultsManager setPlaybackRate:slider.value];
    [[PLPlayer sharedPlayer] setPlaybackRate:slider.value];
}

@end
