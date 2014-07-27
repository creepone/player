#import "PLEntity.h"

@class PLPodcastOldEpisode, PLPodcast;

@interface PLPodcastPin : PLEntity

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * artworkURL;
@property (nonatomic, retain) NSString * feedURL;
@property (nonatomic, retain) NSSet *oldEpisodes;
@property (nonatomic, assign) int16_t countNewEpisodes;
@property (nonatomic, assign) int64_t order;

+ (instancetype)podcastPinFromPodcast:(PLPodcast *)podcast inContext:(NSManagedObjectContext *)context;

- (void)remove;

@end

@interface PLPodcastPin (CoreDataGeneratedAccessors)

- (void)addOldEpisodesObject:(PLPodcastOldEpisode *)value;
- (void)removeOldEpisodesObject:(PLPodcastOldEpisode *)value;
- (void)addOldEpisodes:(NSSet *)values;
- (void)removeOldEpisodes:(NSSet *)values;

@end
