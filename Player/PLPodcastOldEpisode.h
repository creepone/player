#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PLPodcastOldEpisode : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * downloadURL;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSManagedObject *podcastPin;

@end
