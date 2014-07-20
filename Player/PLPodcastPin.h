#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PLPodcastOldEpisode;

@interface PLPodcastPin : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * artworkURL;
@property (nonatomic, retain) NSString * feedURL;
@property (nonatomic, retain) NSSet *oldEpisodes;
@end

@interface PLPodcastPin (CoreDataGeneratedAccessors)

- (void)addOldEpisodesObject:(PLPodcastOldEpisode *)value;
- (void)removeOldEpisodesObject:(PLPodcastOldEpisode *)value;
- (void)addOldEpisodes:(NSSet *)values;
- (void)removeOldEpisodes:(NSSet *)values;

@end
