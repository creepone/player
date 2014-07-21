#import <Foundation/Foundation.h>

@interface PLPodcast : NSObject

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *feedURL;
@property (nonatomic, strong) NSURL *artworkURL;
@property (nonatomic, assign) BOOL pinned;

@end
