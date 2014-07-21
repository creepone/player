#import <Foundation/Foundation.h>

@class PLPodcast, PLPodcastPin;

@interface PLPodcastCellViewModel : NSObject

@property (strong, nonatomic, readonly) UIImage *imageArtwork;
@property (strong, nonatomic, readonly) NSString *titleText;
@property (strong, nonatomic, readonly) NSString *artistText;
@property (assign, nonatomic, readonly) CGFloat alpha;

- (instancetype)initWithPodcast:(PLPodcast *)podcast;
- (instancetype)initWithPodcastPin:(PLPodcastPin *)podcastPin;

@end
