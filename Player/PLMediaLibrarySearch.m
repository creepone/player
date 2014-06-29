#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLMediaLibrarySearch.h"
#import "PLMediaItemTrack.h"
#import "PLMediaItemTrackGroup.h"
#import "NSArray+PLExtensions.h"

@implementation PLMediaLibrarySearch

+ (MPMediaItem *)mediaItemWithPersistentId:(NSNumber *)persistentId
{
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:persistentId forProperty:MPMediaItemPropertyPersistentID];

    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    [query addFilterPredicate:predicate];
    return [query.items firstObject];
}

+ (RACSignal *)tracksForMediaQuery:(MPMediaQuery *)mediaQuery
{    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        return [[RACScheduler scheduler] schedule:^{
            NSArray *result = [mediaQuery.items pl_map:^id(MPMediaItem *mediaItem) {
                return [[PLMediaItemTrack alloc] initWithMediaItem:mediaItem];
            }];

            [subscriber sendNext:result];
            [subscriber sendCompleted];
        }];

    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

+ (RACSignal *)tracksForCollection:(MPMediaItemCollection *)collection
{
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        return [[RACScheduler scheduler] schedule:^{
            NSArray *result = [collection.items pl_map:^id(MPMediaItem *mediaItem) {
                return [[PLMediaItemTrack alloc] initWithMediaItem:mediaItem];
            }];

            [subscriber sendNext:result];
            [subscriber sendCompleted];
        }];

    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

+ (RACSignal *)allAudiobooks
{
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        return [[RACScheduler scheduler] schedule:^{
            MPMediaQuery *query = [MPMediaQuery audiobooksQuery];

            NSArray *result = [query.collections pl_map:^id(MPMediaItemCollection *audiobook) {
                return [[PLMediaItemTrackGroup alloc] initWithType:PLTrackGroupTypeAudiobooks collection:audiobook];
            }];

            [subscriber sendNext:result];
            [subscriber sendCompleted];
        }];

    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

+ (RACSignal *)allAlbums
{
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        return [[RACScheduler scheduler] schedule:^{
            MPMediaQuery *query = [MPMediaQuery albumsQuery];

            NSArray *result = [query.collections pl_map:^id(MPMediaItemCollection *album) {
                return [[PLMediaItemTrackGroup alloc] initWithType:PLTrackGroupTypeAlbums collection:album];
            }];

            [subscriber sendNext:result];
            [subscriber sendCompleted];
        }];

    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

+ (RACSignal *)allPlaylists
{
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        return [[RACScheduler scheduler] schedule:^{
            MPMediaQuery *query = [MPMediaQuery playlistsQuery];

            NSArray *result = [query.collections pl_map:^id(MPMediaItemCollection *playlist) {
                return [[PLMediaItemTrackGroup alloc] initWithType:PLTrackGroupTypePlaylists collection:playlist];
            }];

            [subscriber sendNext:result];
            [subscriber sendCompleted];
        }];

    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

+ (RACSignal *)allPodcasts
{
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        return [[RACScheduler scheduler] schedule:^{
            MPMediaQuery *query = [MPMediaQuery podcastsQuery];

            NSArray *result = [query.collections pl_map:^id(MPMediaItemCollection *podcast) {
                return [[PLMediaItemTrackGroup alloc] initWithType:PLTrackGroupTypePodcasts collection:podcast];
            }];

            [subscriber sendNext:result];
            [subscriber sendCompleted];
        }];

    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

+ (RACSignal *)allITunesU
{
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        return [[RACScheduler scheduler] schedule:^{
            MPMediaQuery *query = [[MPMediaQuery alloc] init];
            MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:@(MPMediaTypeAudioITunesU) forProperty:MPMediaItemPropertyMediaType];
            [query addFilterPredicate:predicate];
            query.groupingType = MPMediaGroupingAlbum;

            NSArray *result = [query.collections pl_map:^id(MPMediaItemCollection *itunesu) {
                return [[PLMediaItemTrackGroup alloc] initWithType:PLTrackGroupTypeITunesU collection:itunesu];
            }];

            [subscriber sendNext:result];
            [subscriber sendCompleted];
        }];

    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

@end