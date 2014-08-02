#import "PLEntity.h"

@class PLPodcastEpisode, PLPodcastPin;

extern NSString * const PLEpisodeMarkedAsNew;

@interface PLPodcastOldEpisode : PLEntity

+ (instancetype)oldEpisodeFromEpisode:(PLPodcastEpisode *)episode inContext:(NSManagedObjectContext *)context;

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * downloadURL;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) PLPodcastPin *podcastPin;
@property (nonatomic, assign) NSDate * publishDate;

- (PLPodcastEpisode *)episode;

- (void)remove;

@end
