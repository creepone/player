#import <Foundation/Foundation.h>

@class RACSignal, PLPodcastOldEpisode;

extern NSString * const PLEpisodeMarkedAsOld;

@interface PLPodcastEpisode : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSURL *downloadURL;
@property (nonatomic, retain) NSString *guid;
@property (nonatomic, assign) NSDate *publishDate;

@property (nonatomic, retain) NSURL *podcastFeedURL;
@property (nonatomic, retain) NSString *artist;

- (RACSignal *)markAsOld;

@end
