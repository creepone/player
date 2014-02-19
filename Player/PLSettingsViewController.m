//
//  PLSettingsViewController.m
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import "PLSettingsViewController.h"
#import "PLDefaultsManager.h"
#import "PLPlaylistSelectViewController.h"
#import "PLPlayer.h"
#import "PLDataAccess.h"
#import "PLAlerts.h"
#import "SliderCell.h"
#import "NSString+Extensions.h"

#define GoBackAlert 22

@interface PLSettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, PLPlaylistSelectViewControllerDelegate>

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
    return 3;
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
    else {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        if (indexPath.row == 1) {
            cell.textLabel.text = @"Bookmark playlist";
            
            PLPlaylist *bookmarkPlaylist = [[PLDataAccess sharedDataAccess] bookmarkPlaylist];
            if (bookmarkPlaylist != nil)
                cell.detailTextLabel.text = [bookmarkPlaylist name];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = @"Go back time";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", [PLDefaultsManager goBackTime]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 0)
        return 80.0;
    else
        return 45.0;
}
    
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 290, 23)];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textAlignment = NSTextAlignmentCenter;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleVersion"];
    label.text = [NSString stringWithFormat:@"Build %@", version];
    
    [footerView addSubview:label];
    return footerView;
}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = sender;
    
    SliderCell *sliderCell = (SliderCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    sliderCell.labelValue.text = [NSString stringWithFormat:@"%.2f", slider.value];

    [PLDefaultsManager setPlaybackRate:slider.value];
    
    PLPlayer *player = [PLPlayer sharedPlayer];
    if ([player.currentSong.playbackRate doubleValue] < 0.01)
        [player setPlaybackRate:slider.value];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        PLPlaylistSelectViewController *psvc = [[PLPlaylistSelectViewController alloc] init];
        [psvc setDelegate:self];
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:psvc];
        [self presentViewController:nc animated:YES completion:NULL];
    }
    else if (indexPath.row == 2) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Go back time" message:@"Enter the new go back time" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = GoBackAlert;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == GoBackAlert && buttonIndex == 0) {
        NSString *goBackTimeString = [[alertView textFieldAtIndex:0] text];
        double goBackTime = [goBackTimeString doubleValue];
        
        // ignore absurd values
        if (goBackTime > 0 && goBackTime < 120) {
            [PLDefaultsManager setGoBackTime:goBackTime];
            [self.tableView reloadData];
        }
    }
}

- (void)didSelectPlaylist:(PLPlaylist *)playlist {
    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
    [dataAccess setBookmarkPlaylist:playlist];
    
    NSError *error;
    [dataAccess saveChanges:&error];
    [PLAlerts checkForDataStoreError:error];
    
    [self.tableView reloadData];
}

@end
