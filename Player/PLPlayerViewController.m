#import <MediaPlayer/MediaPlayer.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "PLPlayerViewController.h"
#import "PLDataAccess.h"
#import "PLPlayer.h"
#import "PLUtils.h"
#import "NSObject+PLExtensions.h"
#import "PLKVOObserver.h"


@interface PLPlayerViewController () {
    BOOL _isShown;
    PLKVOObserver *_playerObserver;
}

- (void)reloadData;
- (void)updateTimeline;

@end

@implementation PLPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Player";
        self.tabBarItem.image = [UIImage imageNamed:@"music"];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.sliderTimeline.continuous = NO;
    self.btnPlayPause.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _playerObserver = [PLKVOObserver observerWithTarget:[PLPlayer sharedPlayer]];
    
    @weakify(self);
    [_playerObserver addKeyPath:@instanceKey(PLPlayer, currentSong) handler:^(id _) { @strongify(self); [self reloadData]; }];
    [_playerObserver addKeyPath:@instanceKey(PLPlayer, isPlaying) handler:^(id _) { @strongify(self); [self reloadData]; }];
    
    _isShown = YES;
    [self reloadData];
    [self updateTimeline];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _playerObserver = nil;
    _isShown = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    PLPlayer *player = [PLPlayer sharedPlayer];
    PLPlaylistSong *currentSong = [player currentSong];

    self.artworkImage = [UIImage imageNamed:@"DefaultArtwork"];

    if (currentSong == nil) {
        self.labelArtist.text = @"";
        self.labelTitle.text = @"";
        self.labelTotal.text = @"";
        self.labelCurrent.text = @"";
        self.labelTrackNumber.text = @"";
        self.sliderTimeline.hidden = YES;
        [self.btnPlayPause setTitle:@"Play" forState:UIControlStateNormal];
    }
    else {
        self.labelTitle.text = currentSong.title;
        self.labelArtist.text = currentSong.artist;
        
        NSTimeInterval duration = currentSong.duration;
        self.labelTotal.text = [PLUtils formatDuration:duration];
        
        self.sliderTimeline.hidden = NO;

        RAC(self, artworkImage) = currentSong.largeArtwork;

        NSString *titleForButton = [player isPlaying] ? @"Pause" : @"Play";
        [self.btnPlayPause setTitle:titleForButton forState:UIControlStateNormal];

        // note: we will have to solve this in a different way, e.g. by showing the position within the playlist
        
        self.labelTrackNumber.text = nil;

        /*NSUInteger trackNo = [[mediaItem valueForProperty:MPMediaItemPropertyAlbumTrackNumber] integerValue];
        NSUInteger trackCount = [[mediaItem valueForProperty:MPMediaItemPropertyAlbumTrackCount] integerValue];
        NSString *trackString = @"";
        
        if (trackCount > 0 && trackNo > 0)
            trackString = [NSString stringWithFormat:@"%ld/%ld", trackNo, trackCount];
        else if (trackNo > 0)
            trackString = [NSString stringWithFormat:@"#%ld", trackNo];
        
        self.labelTrackNumber.text = trackString;*/
    }
}

- (void)updateTimeline {
    PLPlayer *player = [PLPlayer sharedPlayer];
    PLPlaylistSong *currentSong = [player currentSong];
    
    if (currentSong == nil || !_isShown) {
        return;
    }
    
    NSTimeInterval duration = currentSong.duration;
    NSTimeInterval currentPosition = [player currentPosition];
    
    self.labelCurrent.text = [PLUtils formatDuration:currentPosition];
    self.sliderTimeline.value = currentPosition / duration;
    
    // update again in a second
    [self performSelector:@selector(updateTimeline) withObject:self afterDelay:1.0];
}

- (UIImage *)artworkImage
{
    return self.imgArtwork.image;
}

- (void)setArtworkImage:(UIImage *)image
{
    if (image) {
        self.imgArtwork.image = image;
    }
}



- (IBAction)timelineChange:(id)sender {
    float value = self.sliderTimeline.value;
    
    PLPlayer *player = [PLPlayer sharedPlayer];
    PLPlaylistSong *currentSong = [player currentSong];
    
    if (currentSong == nil)
        return;
    
    NSTimeInterval duration = currentSong.duration;
    double updatedPosition = duration * value;
    if (updatedPosition > duration - 1.0)
        updatedPosition = duration - 1.0;
    [player setCurrentPosition:updatedPosition];
}

- (IBAction)clickedPlayPause:(id)sender {
    [[PLPlayer sharedPlayer] playPause];
}

- (IBAction)clickedAddBookmark:(id)sender {
    [[PLPlayer sharedPlayer] makeBookmark];
}

- (IBAction)clickedGoBack:(id)sender {
    [[PLPlayer sharedPlayer] goBack];
}


@end
