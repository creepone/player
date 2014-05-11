#import <RXPromise/RXPromise.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PLMediaLibrarySearch.h"
#import "PLTrack.h"
#import "NSArray+PLExtensions.h"
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
    RXPromise *promise = [[RXPromise alloc] init];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSArray *results = [mediaQuery.items pl_map:^(MPMediaItem *mediaItem) {
            return [[PLTrack alloc] initWithMediaItem:mediaItem];
        }];

        [promise fulfillWithValue:results];
    });

    return promise;
}

+ (RXPromise *)allAudiobooks
{
    RXPromise *promise = [[RXPromise alloc] init];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        MPMediaQuery *query = [MPMediaQuery audiobooksQuery];

        NSArray *results = [query.collections pl_map:^(MPMediaItemCollection *audiobook) {
            return [[PLTrackGroup alloc] initWithType:MPMediaTypeAudioBook collection:audiobook];
        }];

        [promise fulfillWithValue:results];
    });

    return promise;
}

@end