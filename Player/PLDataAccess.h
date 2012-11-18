//
//  DataAccess.h
//  EnergyTracker
//
//  Created by Tomas Vana on 3/17/12.
//  Copyright (c) 2012 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLPlaylist.h"
#import "PLPlaylistSong.h"
#import "PLBookmark.h"
#import "PLBookmarkSong.h"

@interface PLDataAccess : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *context;

/**
 Initializes a new instance of the data access. If "useNewContext" flag is set, a new managed object context will be 
 created and used for all the queries operations etc. If the flag is not set, the global context for the application
 will be reused.
 */
- (id)initWithNewContext:(BOOL)useNewContext;

/**
 Initializes a new instance of the data access using the given managed object context.
 */
- (id)initWithContext:(NSManagedObjectContext *)context;

/**
 Shared data access instance that uses the global managed object context for its operations.
 */
+ (PLDataAccess *)sharedDataAccess;


- (void)deleteObject:(NSManagedObject *)object;
- (BOOL)deleteObject:(NSManagedObject *)object error:(NSError **)error;
- (BOOL)saveChanges:(NSError **)error;
- (void)rollbackChanges;
- (void)processChanges;

- (PLPlaylist *)createPlaylist:(NSString *)name;
- (PLPlaylist *)selectedPlaylist;
- (void)selectPlaylist:(PLPlaylist *)playlist;
- (PLPlaylistSong *)addSong:(MPMediaItem *)song toPlaylist:(PLPlaylist *)playlist;

- (NSFetchedResultsController *)fetchedResultsControllerForAllPlaylists;
- (NSFetchedResultsController *)fetchedResultsControllerForSongsOfPlaylist:(PLPlaylist *)playlist;

@end
