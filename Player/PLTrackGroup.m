#import <RXPromise/RXPromise.h>
#import "PLTrackGroup.h"
#import "PLImageCache.h"
#import "PLMediaLibrarySearch.h"

@interface PLTrackGroup() {
    NSNumber *_persistentId;
    NSNumber *_albumPersistentId;
    NSNumber *_podcastPersistentId;
    PLTrackGroupType _trackGroupType;
}
@end


@implementation PLTrackGroup

- (instancetype)initWithType:(PLTrackGroupType)type collection:(MPMediaItemCollection *)collection
{
    self = [super init];
    if (self) {
        MPMediaItem *representativeItem = [collection representativeItem];

        _trackGroupType = type;
        _persistentId = [representativeItem valueForProperty:MPMediaItemPropertyPersistentID];
        _trackCount = [collection  count];
        _duration = [self calculateDuration:collection];

        _albumPersistentId = [representativeItem valueForProperty:MPMediaItemPropertyAlbumPersistentID];

        switch (type)
        {
            case PLTrackGroupTypeAlbums:
            case PLTrackGroupTypeAudiobooks:
            case PLTrackGroupTypeITunesU:
            {
                _artist = [representativeItem valueForProperty:MPMediaItemPropertyAlbumArtist];
                _title = [representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle];
                break;
            }
            case PLTrackGroupTypePlaylists:
            {
                _title = [collection valueForProperty:MPMediaPlaylistPropertyName];
                break;
            }
            case PLTrackGroupTypePodcasts:
            {
                _title = [representativeItem valueForProperty:MPMediaItemPropertyPodcastTitle];
                _podcastPersistentId = [representativeItem valueForProperty:MPMediaItemPropertyPodcastPersistentID];
                break;
            }
        }

        [self cacheArtwork:[representativeItem valueForProperty:MPMediaItemPropertyArtwork]];
    }
    return self;
}

- (NSTimeInterval)calculateDuration:(MPMediaItemCollection *)collection
{
    NSTimeInterval result = 0;
    for (MPMediaItem *mediaItem in collection.items) {
        result += [[mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    }
    return result;
}

- (void)cacheArtwork:(MPMediaItemArtwork *)artwork
{
    if (artwork) {
        UIImage *artworkImage = [artwork imageWithSize:[[PLImageCache sharedCache] sizeForImageFormat:PLImageFormatNameSmallArtwork]];
        [[PLImageCache sharedCache] storeMediaItemArtwork:artworkImage forPersistentId:_persistentId];
    }
}

- (RXPromise *)artwork
{
    return [[PLImageCache sharedCache] mediaItemArtworkWithPersistentId:_persistentId];
}

- (RXPromise *)tracks
{
    if (_trackGroupType == PLTrackGroupTypeAudiobooks) {
        MPMediaQuery *query = [MPMediaQuery audiobooksQuery];
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:_albumPersistentId forProperty:MPMediaItemPropertyAlbumPersistentID];
        [query addFilterPredicate:predicate];
        return [PLMediaLibrarySearch tracksForMediaQuery:query];
    }
    else if (_trackGroupType == PLTrackGroupTypeAlbums) {
        MPMediaQuery *query = [MPMediaQuery albumsQuery];
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:_albumPersistentId forProperty:MPMediaItemPropertyAlbumPersistentID];
        [query addFilterPredicate:predicate];
        return [PLMediaLibrarySearch tracksForMediaQuery:query];
    }
    else if (_trackGroupType == PLTrackGroupTypePlaylists) {
        MPMediaQuery *query = [MPMediaQuery playlistsQuery];
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:_albumPersistentId forProperty:MPMediaItemPropertyAlbumPersistentID];
        [query addFilterPredicate:predicate];
        return [PLMediaLibrarySearch tracksForMediaQuery:query];
    }
    else if (_trackGroupType == PLTrackGroupTypePodcasts) {
        MPMediaQuery *query = [MPMediaQuery podcastsQuery];
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:_podcastPersistentId forProperty:MPMediaItemPropertyPodcastPersistentID];
        [query addFilterPredicate:predicate];
        return [PLMediaLibrarySearch tracksForMediaQuery:query];
    }
    else if (_trackGroupType == PLTrackGroupTypeITunesU) {
        MPMediaQuery *query = [[MPMediaQuery alloc] init];
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:_albumPersistentId forProperty:MPMediaItemPropertyAlbumPersistentID];
        [query addFilterPredicate:predicate];
        return [PLMediaLibrarySearch tracksForMediaQuery:query];
    }

    return [RXPromise promiseWithResult:[NSArray array]];
}

@end