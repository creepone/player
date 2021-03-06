#import "PLPlayingViewController.h"
#import "PLPlayingViewModel.h"
#import "PLKVOObserver.h"

@interface PLPlayingViewController () {
    PLKVOObserver *_viewModelObserver;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelArtist;
@property (strong, nonatomic) IBOutlet UILabel *labelDuration;
@property (strong, nonatomic) IBOutlet UISlider *sliderPosition;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewArtwork;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonItemPlayPause;

@end

@implementation PLPlayingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBindings];
}

- (void)viewDidLayoutSubviews
{
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)setupBindings
{
    @weakify(self);
    
    PLKVOObserver *observer = [PLKVOObserver observerWithTarget:_viewModel];
    [observer addKeyPath:@keypath(_viewModel.titleText) handler:^(id value) { @strongify(self); self.labelTitle.text = value; }];
    [observer addKeyPath:@keypath(_viewModel.artistText) handler:^(id value) { @strongify(self); self.labelArtist.text = value; }];
    
    [observer addKeyPath:@keypath(_viewModel.imageArtwork) handler:^(id value) { @strongify(self);
        self.imageViewArtwork.image = value ? : [UIImage imageNamed:@"DefaultArtwork"];
    }];
    
    [observer addKeyPath:@keypath(_viewModel.imagePlayPause) handler:^(id value) { @strongify(self);
        self.buttonItemPlayPause.image = value;
    }];
    
    [observer addKeyPath:@keypath(_viewModel.durationText) handler:^(id value) { @strongify(self);
        self.labelDuration.text = value;
    }];
    
    [observer addKeyPath:@keypath(_viewModel.playbackProgress) handler:^(id value) { @strongify(self);
        self.sliderPosition.value = [value floatValue];
    }];
    
    [observer addKeyPath:@keypath(_viewModel.hasTrack) handler:^(id value) {
        self.sliderPosition.hidden = ![value boolValue];
    }];
    
    _viewModelObserver = observer;
}

- (IBAction)sliderValueChanged:(id)sender
{
    _viewModel.playbackProgress = self.sliderPosition.value;
}

- (IBAction)tappedPlay:(id)sender
{
    [self.viewModel playPause];
}

- (IBAction)tappedSkipToStart:(id)sender
{
    [self.viewModel skipToStart];
}

- (IBAction)tappedPrevious:(id)sender
{
    [self.viewModel moveToPrevious];
}

- (IBAction)tappedNext:(id)sender
{
    [self.viewModel moveToNext];
}

- (IBAction)tappedGoBack:(id)sender
{
    [self.viewModel goBack];
}

- (IBAction)tappedBookmark:(id)sender
{
    [self.viewModel makeBookmark];
}

- (IBAction)tappedDone:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    _viewModelObserver = nil;
    self.viewModel = nil;
}

@end
