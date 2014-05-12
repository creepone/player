#import <RXPromise/RXPromise.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PLSelectFromMusicLibraryActivity.h"
#import "PLMediaLibrarySearch.h"
#import "PLMusicLibraryViewController.h"
#import "PLTrackGroup.h"
#import "PLDataAccess.h"
#import "PLErrorManager.h"

@interface PLSelectFromMusicLibraryActivity() {
    PLPlaylist *_playlist;
}
@end

@implementation PLSelectFromMusicLibraryActivity

- (id)initWithPlaylist:(PLPlaylist *)playlist
{
    self = [super init];
    if (self) {
        _playlist = playlist;
    }
    return self;
}

- (NSString *)title
{
    return NSLocalizedString(@"Activities.Music", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"MusicIcon"];
}

- (RXPromise *)performActivity
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MusicLibrary" bundle:nil];
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;

    RXPromise *promise = [[RXPromise alloc] init];
    UINavigationController *navigationController = storyboard.instantiateInitialViewController;
    
    PLMusicLibraryViewController *musicLibraryVc = navigationController.viewControllers[0];

    @weakify(self);
    musicLibraryVc.doneCallback = ^(NSArray *selection) {
        @strongify(self);
        
        // todo: show a progress with a grace period of a second or so while the import is running
        [promise bind:[self importSongs:selection]];
    };
    
    [rootViewController presentViewController:navigationController animated:YES completion:nil];
    return promise;
}

- (RXPromise *)importSongs:(NSArray *)persistentIds
{
    // todo: do this in the background and merge back into the main context, cause this could be a lot of songs ?
    
    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
    
    for (NSNumber *persistentId in persistentIds) {
        PLPlaylistSong *playlistSong = [dataAccess findSongWithPersistentID:persistentId onPlaylist:_playlist];
        MPMediaItem *item = [PLMediaLibrarySearch mediaItemWithPersistentId:persistentId];
        
        if (playlistSong == nil)
            [dataAccess addSong:item toPlaylist:_playlist];
    }
    
    NSError *error;
    [dataAccess saveChanges:&error];
    return [RXPromise promiseWithResult:error];
}

@end