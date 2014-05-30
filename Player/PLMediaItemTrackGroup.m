#import <RXPromise/RXPromise.h>
#import "PLMediaItemTrackGroup.h"
#import "PLImageCache.h"
#import "PLMediaLibrarySearch.h"

@interface PLMediaItemTrackGroup () {
    NSNumber *_persistentId;
    NSNumber *_parentPersistentId;
    PLTrackGroupType _trackGroupType;
}
@end


@implementation PLMediaItemTrackGroup

- (instancetype)initWithType:(PLTrackGroupType)type collection:(MPMediaItemCollection *)collection
{
    self = [super init];
    if (self) {
        MPMediaItem *representativeItem = [collection representativeItem];

        _trackGroupType = type;
        _persistentId = [representativeItem valueForProperty:MPMediaItemPropertyPersistentID];
        _trackCount = [collection  count];
        _duration = [self calculateDuration:collection];

        _parentPersistentId = [representativeItem valueForProperty:MPMediaItemPropertyAlbumPersistentID];

        switch (type)
        {
            case PLTrackGroupTypeAlbums:
            case PLTrackGroupTypeAudiobooks:
            {
                _artist = [representativeItem valueForProperty:MPMediaItemPropertyAlbumArtist];
                _title = [representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle];
                break;
            }
            case PLTrackGroupTypePlaylists:
            {
                _title = [collection valueForProperty:MPMediaPlaylistPropertyName];
                _parentPersistentId = [collection valueForProperty:MPMediaPlaylistPropertyPersistentID];
                break;
            }
            case PLTrackGroupTypeITunesU:
            {
                _title = [representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle];
                break;
            }
            case PLTrackGroupTypePodcasts:
            {
                _title = [representativeItem valueForProperty:MPMediaItemPropertyPodcastTitle];
                _parentPersistentId = [representativeItem valueForProperty:MPMediaItemPropertyPodcastPersistentID];
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
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:_parentPersistentId forProperty:MPMediaItemPropertyAlbumPersistentID];
        [query addFilterPredicate:predicate];
        return [PLMediaLibrarySearch tracksForMediaQuery:query];
    }
    else if (_trackGroupType == PLTrackGroupTypeAlbums) {
        MPMediaQuery *query = [MPMediaQuery albumsQuery];
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:_parentPersistentId forProperty:MPMediaItemPropertyAlbumPersistentID];
        [query addFilterPredicate:predicate];
        return [PLMediaLibrarySearch tracksForMediaQuery:query];
    }
    else if (_trackGroupType == PLTrackGroupTypePlaylists) {
        MPMediaQuery *query = [MPMediaQuery playlistsQuery];
        for (MPMediaPlaylist *playlist in query.collections) {
            if ([[playlist valueForProperty:MPMediaPlaylistPropertyPersistentID] isEqual:_parentPersistentId])
                return [PLMediaLibrarySearch tracksForCollection:playlist];
        }
    }
    else if (_trackGroupType == PLTrackGroupTypePodcasts) {
        MPMediaQuery *query = [MPMediaQuery podcastsQuery];
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:_parentPersistentId forProperty:MPMediaItemPropertyPodcastPersistentID];
        [query addFilterPredicate:predicate];
        return [PLMediaLibrarySearch tracksForMediaQuery:query];
    }
    else if (_trackGroupType == PLTrackGroupTypeITunesU) {
        MPMediaQuery *query = [[MPMediaQuery alloc] init];
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:_parentPersistentId forProperty:MPMediaItemPropertyAlbumPersistentID];
        [query addFilterPredicate:predicate];
        return [PLMediaLibrarySearch tracksForMediaQuery:query];
    }

    return [RXPromise promiseWithResult:[NSArray array]];
}

@end