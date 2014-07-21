#import "PLEntity.h"

@interface PLPodcastOldEpisode : PLEntity

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * downloadURL;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSManagedObject *podcastPin;
@property (nonatomic, assign) int64_t order;

@end
