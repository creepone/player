//
//  PLBookmarkSong.h
//  Player
//
//  Created by Tomas Vana on 11/16/12.
//  Copyright (c) 2012 Tomas Vana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PLBookmark;

@interface PLBookmarkSong : NSManagedObject

@property (nonatomic, retain) NSNumber * persistentId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSSet *bookmarks;
@end

@interface PLBookmarkSong (CoreDataGeneratedAccessors)

- (void)addBookmarksObject:(PLBookmark *)value;
- (void)removeBookmarksObject:(PLBookmark *)value;
- (void)addBookmarks:(NSSet *)values;
- (void)removeBookmarks:(NSSet *)values;

@end
