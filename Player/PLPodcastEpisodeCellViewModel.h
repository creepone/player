#import <Foundation/Foundation.h>

@class PLPodcastEpisode, PLPodcastOldEpisode;

@interface PLPodcastEpisodeCellViewModel : NSObject

- (instancetype)initWithPodcastEpisode:(PLPodcastEpisode *)episode selected:(BOOL)selected;
- (instancetype)initWithPodcastOldEpisode:(PLPodcastOldEpisode *)episode selected:(BOOL)selected isInFeed:(BOOL)isInFeed;

@property (nonatomic, strong, readonly) NSString *titleText;
@property (nonatomic, strong, readonly) NSString *subtitleText;
@property (nonatomic, strong, readonly) UIImage *imageAddState;
@property (nonatomic, assign, readonly) CGFloat alpha;

@property (nonatomic, strong, readonly) NSString *rightButtonText;
@property (nonatomic, strong, readonly) UIColor *rightButtonTextColor;
@property (nonatomic, strong, readonly) UIColor *rightButtonBackgroundColor;

- (void)pressedButtonAt:(NSInteger)index;

@end
