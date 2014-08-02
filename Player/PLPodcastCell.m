#import "PLPodcastCell.h"
#import "PLKVOObserver.h"
#import "PLPodcastCellViewModel.h"

@interface PLPodcastCell() {
    PLKVOObserver *_viewModelObserver;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewArtwork;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelArtist;
@property (strong, nonatomic) IBOutlet UILabel *labelInfo;

@end

@implementation PLPodcastCell

- (void)setViewModel:(PLPodcastCellViewModel *)viewModel
{
    _viewModel = viewModel;
    if (viewModel != nil) {
        [self setupBindings];
    }
}

- (void)setupBindings
{
    @weakify(self);
    
    PLKVOObserver *observer = [PLKVOObserver observerWithTarget:_viewModel];
    
    [observer addKeyPath:@keypath(_viewModel.titleText) handler:^(id value) { @strongify(self); self.labelTitle.text = value; }];
    [observer addKeyPath:@keypath(_viewModel.artistText) handler:^(id value) { @strongify(self); self.labelArtist.text = value; }];
    [observer addKeyPath:@keypath(_viewModel.infoText) handler:^(id value) { @strongify(self); self.labelInfo.text = value; }];
    [observer addKeyPath:@keypath(_viewModel.imageArtwork) handler:^(id value) { @strongify(self); self.imageViewArtwork.image = value; }];
    
    [observer addKeyPath:@keypath(_viewModel.alpha) handler:^(id value) { @strongify(self);
        CGFloat alpha = [value floatValue];
        self.labelTitle.alpha = alpha;
        self.labelArtist.alpha = alpha;
        self.labelInfo.alpha = alpha;
        self.imageViewArtwork.alpha = alpha;
    }];
    
    _viewModelObserver = observer;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _viewModelObserver = nil;
    self.viewModel = nil;
}

- (void)dealloc
{
    _viewModelObserver = nil;
    self.viewModel = nil;
}

@end
