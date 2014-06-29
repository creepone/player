#import "PLMusicLibraryViewModel.h"
#import "PLTrackGroupsViewModel.h"

@interface PLMusicLibraryViewModel() {
    NSMutableArray *_selection;
}
@end

@implementation PLMusicLibraryViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _selection = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)selection
{
    return _selection;
}

- (PLTrackGroupsViewModel *)viewModelForTrackGroupType:(PLTrackGroupType)trackGroupType
{
    return [[PLTrackGroupsViewModel alloc] initWithTrackGroupType:trackGroupType selection:_selection];
}

@end