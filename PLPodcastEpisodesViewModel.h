#import <Foundation/Foundation.h>

@class PLPodcastPin, PLPodcastEpisodeCellViewModel;

@interface PLPodcastEpisodesViewModel : NSObject

- (instancetype)initWithPodcastPin:(PLPodcastPin *)podcastPin selection:(NSMutableDictionary *)selection;

/**
 * Returns YES if the view model has loaded the episodes and is ready to use, NO otherwise.
 */
@property (nonatomic, assign, readonly) BOOL ready;

@property (nonatomic, readonly) NSString *title;

- (NSInteger)sectionsCount;
- (NSInteger)cellsCountInSection:(NSInteger)section;
- (NSString *)cellIdentifier;
- (NSString *)sectionTitle:(NSInteger)section;
- (PLPodcastEpisodeCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath;
- (void)toggleSelectAt:(NSIndexPath *)indexPath;

- (RACSignal *)updatesSignal;

@end
