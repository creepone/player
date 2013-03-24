//
//  PLPlaylistSong.h
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PLPlaylist, MPMediaItem;

@interface PLPlaylistSong : NSManagedObject

@property (nonatomic, retain) NSNumber * persistentId;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) PLPlaylist *playlist;
@property (nonatomic, retain) NSNumber * playbackRate;

@property (nonatomic, readonly) MPMediaItem *mediaItem;

@end
