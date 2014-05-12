#import "PLMusicLibraryViewController.h"
#import "PLTrackGroupViewController.h"

@interface PLMusicLibraryViewController ()

- (IBAction)dismiss:(UIStoryboardSegue *)segue;

@end

@implementation PLMusicLibraryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selection = [NSMutableArray array];
}

- (IBAction)dismiss:(UIStoryboardSegue *)segue
{
    if (self.doneCallback) {
        self.doneCallback(self.selection);
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"audiobooks"]) {
        PLTrackGroupViewController *trackGroupVc = [segue destinationViewController];
        trackGroupVc.trackGroupType = PLTrackGroupTypeAudiobooks;
    }
    else if ([segue.identifier isEqualToString:@"albums"]) {
        PLTrackGroupViewController *trackGroupVc = [segue destinationViewController];
        trackGroupVc.trackGroupType = PLTrackGroupTypeAlbums;
    }
}

@end
