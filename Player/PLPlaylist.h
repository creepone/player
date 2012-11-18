//
//  PLPlaylist.h
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PLPlaylistSong;


@interface PLPlaylist : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSSet *songs;
@end

@interface PLPlaylist (CoreDataGeneratedAccessors)

- (void)addSongsObject:(NSManagedObject *)value;
- (void)removeSongsObject:(NSManagedObject *)value;
- (void)addSongs:(NSSet *)values;
- (void)removeSongs:(NSSet *)values;

- (void)addNewSong:(PLPlaylistSong *)song;
- (void)removeSong:(PLPlaylistSong *)song;
- (void)renumberSongsOrder:(NSArray *)allSongs;
- (PLPlaylistSong *)currentSong;
- (void)moveToNextSong;

@end
