#import <Foundation/Foundation.h>

@interface PLPodcastEpisode : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSURL *downloadURL;
@property (nonatomic, retain) NSString *guid;

@end
