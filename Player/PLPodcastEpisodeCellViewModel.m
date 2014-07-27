#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPodcastEpisodeCellViewModel.h"
#import "PLPodcastEpisode.h"
#import "PLDataAccess.h"
#import "PLErrorManager.h"
#import "PLColors.h"

@interface PLPodcastEpisodeCellViewModel() {
    PLPodcastEpisode *_episode;
    PLPodcastOldEpisode *_oldEpisode;
}

@property (nonatomic, strong, readwrite) NSString *titleText;
@property (nonatomic, strong, readwrite) NSString *subtitleText;
@property (nonatomic, strong, readwrite) UIImage *imageAddState;
@property (nonatomic, assign, readwrite) CGFloat alpha;

@property (nonatomic, strong, readwrite) NSString *rightButtonText;
@property (nonatomic, strong, readwrite) UIColor *rightButtonTextColor;
@property (nonatomic, strong, readwrite) UIColor *rightButtonBackgroundColor;

@end

@implementation PLPodcastEpisodeCellViewModel

- (instancetype)initWithPodcastEpisode:(PLPodcastEpisode *)episode selected:(BOOL)selected
{
    self = [super init];
    if (self) {
        _episode = episode;
        self.titleText = episode.title;
        self.subtitleText = episode.subtitle;
        
        self.rightButtonText = @"Mark old"; // todo: localize
        self.rightButtonBackgroundColor = [UIColor orangeColor];
        self.rightButtonTextColor = [UIColor whiteColor];
        
        if (selected) {
            self.alpha = 0.5;
            self.imageAddState = [UIImage imageNamed:@"ButtonRemove"];
        }
        else {
            self.alpha = 1.0;
            self.imageAddState = [UIImage imageNamed:@"ButtonAdd"];
        }
    }
    return self;
}

- (instancetype)initWithPodcastOldEpisode:(PLPodcastOldEpisode *)episode selected:(BOOL)selected
{
    self = [super init];
    if (self) {
        _oldEpisode = episode;
        self.titleText = episode.title;
        self.subtitleText = episode.subtitle;
        
        self.rightButtonText = @"Mark new"; // todo: localize
        self.rightButtonBackgroundColor = [PLColors colorWithRed:4 green:192 blue:0];
        self.rightButtonTextColor = [UIColor whiteColor];
        
        if (selected) {
            self.alpha = 0.5;
            self.imageAddState = [UIImage imageNamed:@"ButtonRemove"];
        }
        else {
            self.alpha = 1.0;
            self.imageAddState = [UIImage imageNamed:@"ButtonAdd"];
        }
    }
    return self;
}

- (void)pressedButtonAt:(NSInteger)index
{
    if (_episode != nil && index == 0) {
        [[_episode markAsOld] subscribeError:[PLErrorManager logErrorVoidBlock]];
    }
    else if (_oldEpisode != nil && index == 0) {
        [_oldEpisode remove];
        [[[PLDataAccess sharedDataAccess] saveChangesSignal] subscribeError:[PLErrorManager logErrorVoidBlock]];
    }
}

@end
