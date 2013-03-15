//
//  PLPlaylistSelectViewController.h
//  Player
//
//  Created by Tomas Vana on 2/16/13.
//  Copyright (c) 2013 Tomas Vana. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLPlaylist;

@protocol PLPlaylistSelectViewControllerDelegate <NSObject>

- (void)didSelectPlaylist:(PLPlaylist *)playlist;

@end

@interface PLPlaylistSelectViewController : UITableViewController

@property (nonatomic, weak) id<PLPlaylistSelectViewControllerDelegate> delegate;

@end
