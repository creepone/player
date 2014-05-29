#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PLPlaylist, MPMediaItem;

@interface PLPlaylistSong : NSManagedObject

@property (nonatomic, retain) NSNumber * persistentId;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) PLPlaylist *playlist;
@property (nonatomic, retain) NSNumber * playbackRate;
@property (nonatomic, retain) NSNumber * downloadURL;
@property (nonatomic, retain) NSNumber * fileURL;
@property (nonatomic) BOOL played;

@property (nonatomic, readonly) MPMediaItem *mediaItem;

@end
