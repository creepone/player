#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLSelectFromMusicLibraryActivity.h"
#import "PLMusicLibraryViewController.h"
#import "PLDataAccess.h"
#import "PLMediaMirror.h"

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

- (RACSignal *)performActivity
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MusicLibrary" bundle:nil];
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;

    UINavigationController *navigationController = storyboard.instantiateInitialViewController;
    [rootViewController presentViewController:navigationController animated:YES completion:nil];

    PLMusicLibraryViewController *musicLibraryVc = navigationController.viewControllers[0];

    return [musicLibraryVc.doneSignal flattenMap:^RACStream *(NSArray *selection) {
        return [self importSongs:selection];
    }];
}

- (RACSignal *)importSongs:(NSArray *)persistentIds
{
    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];

    for (NSNumber *persistentId in persistentIds) {
        PLTrack *track = [dataAccess trackWithPersistentId:persistentId];
        PLPlaylistSong *playlistSong = [dataAccess songWithTrack:track onPlaylist:_playlist];

        if (!playlistSong)
            [_playlist addTrack:track];
    }

    return [[dataAccess saveChangesSignal] then:^RACSignal *{
        [[PLMediaMirror sharedInstance] ensureRunning];
        return [RACSignal empty];
    }];
}

@end