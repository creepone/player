#import <Foundation/Foundation.h>

@protocol PLPodcastsManager <NSObject>

- (RACSignal *)searchForPodcasts:(NSString *)searchTerm;

@end

@interface PLPodcastsManager : NSObject <PLPodcastsManager>
@end
