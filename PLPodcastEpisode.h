#import <Foundation/Foundation.h>

@class RACSignal;

@interface PLPodcastEpisode : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSURL *downloadURL;
@property (nonatomic, retain) NSString *guid;

@property (nonatomic, retain) NSURL *podcastFeedURL;

- (RACSignal *)markAsOld;

@end
