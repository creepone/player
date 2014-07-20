#import <Foundation/Foundation.h>

@class PLPodcast;

@interface PLPodcastCellViewModel : NSObject

@property (strong, nonatomic, readonly) UIImage *imageArtwork;
@property (strong, nonatomic, readonly) NSString *titleText;
@property (strong, nonatomic, readonly) NSString *artistText;
@property (strong, nonatomic, readonly) NSAttributedString *infoText;

- (instancetype)initWithPodcast:(PLPodcast *)podcast;

@end
