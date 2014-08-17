#import "PLPlaylistCellViewModel.h"
#import "PLDataAccess.h"
#import "PLUtils.h"
#import "PLColors.h"

@interface PLPlaylistCellViewModel() {
    PLPlaylist *_playlist;
}

@property (nonatomic, strong, readwrite) NSString *titleText;

@end

@implementation PLPlaylistCellViewModel

- (instancetype)initWithPlaylist:(PLPlaylist *)playlist
{
    self = [super init];
    if (self) {
        _playlist = playlist;
        _titleText = playlist.name;
    }
    return self;
}

- (void)selectCell
{
    [[PLDataAccess sharedDataAccess] selectPlaylist:_playlist];
}

- (NSString *)subtitleText
{
    NSTimeInterval totalDuration = 0.;
    for (PLPlaylistSong *song in _playlist.songs) {
        totalDuration += song.duration;
    }
    
    NSUInteger tracksCount = [_playlist.songs count];
    if (tracksCount > 0)
        return [NSString stringWithFormat:@"%lu tracks, %@", (unsigned long)tracksCount, [PLUtils formatDuration:totalDuration]]; // todo: localize
    
    return @"0 tracks"; // todo: localize
}

- (UIColor *)backgroundColor
{
    PLPlaylist *selectedPlaylist = [[PLDataAccess sharedDataAccess] selectedPlaylist];
    return selectedPlaylist == _playlist ? [PLColors shadeOfGrey:242] : [UIColor whiteColor];
}

@end
