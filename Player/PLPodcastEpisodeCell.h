#import <UIKit/UIKit.h>
#import <SWTableViewCell/SWTableViewCell.h>

@class PLPodcastEpisodeCellViewModel;

@interface PLPodcastEpisodeCell : SWTableViewCell

@property (nonatomic, strong) PLPodcastEpisodeCellViewModel *viewModel;

@end
