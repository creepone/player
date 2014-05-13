#import <RXPromise/RXPromise.h>
#import "PLMediaLibrarySearch.h"
#import "PLTrack.h"
#import "NSArray+PLExtensions.h"
#import "RXPromise+PLExtensions.h"
#import "PLTrackGroup.h"

@implementation PLMediaLibrarySearch

+ (MPMediaItem *)mediaItemWithPersistentId:(NSNumber *)persistentId
{
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:persistentId forProperty:MPMediaItemPropertyPersistentID];

    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    [query addFilterPredicate:predicate];
    return [query.items firstObject];
}

+ (RXPromise *)tracksForMediaQuery:(MPMediaQuery *)mediaQuery
{
    return [RXPromise pl_runInBackground:^{
        return [mediaQuery.items pl_map:^(MPMediaItem *mediaItem) {
            return [[PLTrack alloc] initWithMediaItem:mediaItem];
        }];
    }];
}

+ (RXPromise *)allAudiobooks
{
    return [RXPromise pl_runInBackground:^{
        MPMediaQuery *query = [MPMediaQuery audiobooksQuery];

        return [query.collections pl_map:^(MPMediaItemCollection *audiobook) {
            return [[PLTrackGroup alloc] initWithType:PLTrackGroupTypeAudiobooks collection:audiobook];
        }];
    }];
}

+ (RXPromise *)allAlbums
{
    return [RXPromise pl_runInBackground:^{
        MPMediaQuery *query = [MPMediaQuery albumsQuery];

        return [query.collections pl_map:^(MPMediaItemCollection *album) {
            return [[PLTrackGroup alloc] initWithType:PLTrackGroupTypeAlbums collection:album];
        }];
    }];
}

+ (RXPromise *)allPlaylists
{
    return [RXPromise pl_runInBackground:^{
        MPMediaQuery *query = [MPMediaQuery playlistsQuery];

        return [query.collections pl_map:^(MPMediaItemCollection *album) {
            return [[PLTrackGroup alloc] initWithType:PLTrackGroupTypePlaylists collection:album];
        }];
    }];
}

+ (RXPromise *)allPodcasts
{
    return [RXPromise pl_runInBackground:^{
        MPMediaQuery *query = [MPMediaQuery podcastsQuery];

        return [query.collections pl_map:^(MPMediaItemCollection *podcast) {
            return [[PLTrackGroup alloc] initWithType:PLTrackGroupTypePodcasts collection:podcast];
        }];
    }];
}

+ (RXPromise *)allITunesU
{
    return [RXPromise pl_runInBackground:^{
        MPMediaQuery *query = [[MPMediaQuery alloc] init];
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:@(MPMediaTypeAudioITunesU) forProperty:MPMediaItemPropertyMediaType];
        [query addFilterPredicate:predicate];
        query.groupingType = MPMediaGroupingAlbum;

        return [query.collections pl_map:^(MPMediaItemCollection *itunesu) {
            return [[PLTrackGroup alloc] initWithType:PLTrackGroupTypeITunesU collection:itunesu];
        }];
    }];
}

@end