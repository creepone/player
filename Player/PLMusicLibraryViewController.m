#import "PLMusicLibraryViewController.h"
#import "PLTrackGroupsViewController.h"
#import "PLMusicLibraryViewModel.h"
#import "PLTrackGroupsViewModel.h"

@interface PLMusicLibraryViewController ()

- (IBAction)dismiss:(UIStoryboardSegue *)segue;

@end

@implementation PLMusicLibraryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)dismiss:(UIStoryboardSegue *)segue
{
    self.viewModel.dismissed = YES;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"audiobooks"]) {
        PLTrackGroupsViewController *trackGroupVc = [segue destinationViewController];
        trackGroupVc.viewModel = [self.viewModel viewModelForTrackGroupType:PLTrackGroupTypeAudiobooks];
    }
    else if ([segue.identifier isEqualToString:@"albums"]) {
        PLTrackGroupsViewController *trackGroupVc = [segue destinationViewController];
        trackGroupVc.viewModel = [self.viewModel viewModelForTrackGroupType:PLTrackGroupTypeAlbums];
    }
    else if ([segue.identifier isEqualToString:@"playlists"]) {
        PLTrackGroupsViewController *trackGroupVc = [segue destinationViewController];
        trackGroupVc.viewModel = [self.viewModel viewModelForTrackGroupType:PLTrackGroupTypePlaylists];
    }
    else if ([segue.identifier isEqualToString:@"itunesu"]) {
        PLTrackGroupsViewController *trackGroupVc = [segue destinationViewController];
        trackGroupVc.viewModel = [self.viewModel viewModelForTrackGroupType:PLTrackGroupTypeITunesU];
    }
    else if ([segue.identifier isEqualToString:@"podcasts"]) {
        PLTrackGroupsViewController *trackGroupVc = [segue destinationViewController];
        trackGroupVc.viewModel = [self.viewModel viewModelForTrackGroupType:PLTrackGroupTypePodcasts];
    }
}

@end
