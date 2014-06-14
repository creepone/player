#import "PLImportActivityViewController.h"
#import "PLDownloadPodcastActivity.h"
#import "PLFileSharingActivity.h"
#import "PLDownloadURLActivity.h"
#import "PLSelectFromMusicLibraryActivity.h"
#import "PLPlaylist.h"
#import "PLDownloadFromDropboxActivity.h"
#import "PLDownloadFromGDriveActivity.h"
#import "PLDownloadFromICloudActivity.h"
#import "PLPlaylist.h"
#import "PLDataAccess.h"

@implementation PLImportActivityViewController

- (instancetype)init
{
    PLPlaylist *playlist = [[PLDataAccess sharedDataAccess] selectedPlaylist];

    return [super initWithActivities:@[[PLDownloadURLActivity new], [PLFileSharingActivity new], [PLDownloadPodcastActivity new]]
appActivities:@[[[PLSelectFromMusicLibraryActivity alloc] initWithPlaylist:playlist], [PLDownloadFromDropboxActivity new], [PLDownloadFromGDriveActivity new], [PLDownloadFromICloudActivity new]]];
}

@end