#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLPlaylistCell.h"
#import "PLPlaylistCellViewModel.h"
#import "PLKVOObserver.h"

@interface PLPlaylistCell() {
    PLKVOObserver *_viewModelObserver;
}

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelSubtitle;

@end

@implementation PLPlaylistCell

- (void)setViewModel:(PLPlaylistCellViewModel *)viewModel
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
    [observer addKeyPath:@keypath(_viewModel.subtitleText) handler:^(id value) { @strongify(self); self.labelSubtitle.text = value; }];
    [observer addKeyPath:@keypath(_viewModel.backgroundColor) handler:^(id value) { @strongify(self); self.backgroundColor = value; }];
    
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
