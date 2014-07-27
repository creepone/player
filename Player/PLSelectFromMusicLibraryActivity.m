#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLSelectFromMusicLibraryActivity.h"
#import "PLMusicLibraryViewController.h"
#import "PLDataAccess.h"
#import "PLMediaMirror.h"
#import "PLMusicLibraryViewModel.h"
#import "PLUtils.h"

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
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];

    UINavigationController *navigationController = storyboard.instantiateInitialViewController;

    PLMusicLibraryViewModel *viewModel = [PLMusicLibraryViewModel new];
    PLMusicLibraryViewController *musicLibraryVc = navigationController.viewControllers[0];
    musicLibraryVc.viewModel = viewModel;

    [rootViewController presentViewController:navigationController animated:YES completion:nil];

    return [[[RACObserve(viewModel, dismissed) filter:[PLUtils isTruePredicate]] take:1] then:^RACSignal *{
        return [self importSongs:viewModel.selection];
    }];
}

- (RACSignal *)importSongs:(NSArray *)persistentIds
{
    id<PLDataAccess> dataAccess = [PLDataAccess sharedDataAccess];

    for (NSNumber *persistentId in persistentIds) {
        PLTrack *track = [dataAccess findOrCreateTrackWithPersistentId:persistentId];
        PLPlaylistSong *playlistSong = [dataAccess findSongWithTrack:track onPlaylist:_playlist];
        
        if (!playlistSong)
            [_playlist addTrack:track];
    }

    return [[dataAccess saveChangesSignal] then:^RACSignal *{
        [[PLMediaMirror sharedInstance] ensureRunning];
        return [RACSignal empty];
    }];
}

@end