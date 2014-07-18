#import <Foundation/Foundation.h>

@protocol PLNowPlayingManager <NSObject>

- (void)startUpdating;

@end

@interface PLNowPlayingManager : NSObject  <PLNowPlayingManager>

@end
