#import "PLFileSharingCell.h"
#import "PLKVOObserver.h"
#import "PLFileSharingCellViewModel.h"

@interface PLFileSharingCell() {
    PLKVOObserver *_viewModelObserver;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewAddState;

@end

@implementation PLFileSharingCell

- (void)setViewModel:(PLFileSharingCellViewModel *)viewModel
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
    
    [observer addKeyPath:@keypath(_viewModel.name) handler:^(id value) { @strongify(self); self.labelName.text = value; }];
    [observer addKeyPath:@keypath(_viewModel.imageIcon) handler:^(id value) { @strongify(self); self.imageViewIcon.image = value; }];
    [observer addKeyPath:@keypath(_viewModel.imageAddState) handler:^(id value) { @strongify(self); self.imageViewAddState.image = value; }];
    
    [observer addKeyPath:@keypath(_viewModel.alpha) handler:^(id value) { @strongify(self);
        self.labelName.alpha = self.imageViewIcon.alpha = [value floatValue];
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
