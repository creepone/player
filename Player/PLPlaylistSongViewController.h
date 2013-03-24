//
//  PLPlaylistSongViewController.h
//  Player
//
//  Created by Tomas Vana on 3/24/13.
//  Copyright (c) 2013 Tomas Vana. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLPlaylistSong;

@interface PLPlaylistSongViewController : UITableViewController

- (id)initWithPlaylistSong:(PLPlaylistSong *)song;

@end
