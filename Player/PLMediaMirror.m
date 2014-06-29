@import AVFoundation;
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLMediaMirror.h"
#import "PLTrack.h"
#import "PLDataAccess.h"
#import "PLUtils.h"
#import "PLErrorManager.h"
#import "PLDefaultsManager.h"
#import "PLBackgroundProcessProgress.h"

@implementation PLMediaMirror

- (instancetype)init
{
    self = [super init];
    if (self) {
        PLDefaultsManager *defaultsManager = [PLDefaultsManager sharedManager];
        
        @weakify(self);
        [[RACObserve(defaultsManager, mirrorTracks) skip:1] subscribeNext:^(NSNumber *mirrorTracks) {
            @strongify(self);
            
            if ([mirrorTracks boolValue]) {
                [self ensureRunning];
            }
            else {
                [self suspend];
            }
        }];
        
    }
    return self;
}

+ (PLMediaMirror *)sharedInstance
{
    static dispatch_once_t once;
    static PLMediaMirror *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (void)ensureRunning
{
    if (![[PLDefaultsManager sharedManager] mirrorTracks])
        return;
    
    [super ensureRunning];
}

- (RACSignal *)nextItem
{
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
        PLTrack *track = [dataAccess nextTrackToMirror];

        if (track)
            [subscriber sendNext:track];

        [subscriber sendCompleted];

        return nil;
    }];
}

- (RACSignal *)processItem:(id)item
{
    PLTrack *track = (PLTrack *)item;

    PLBackgroundProcessProgress *progress = [[PLBackgroundProcessProgress alloc] initWithItem:item progressSignal:nil];
    DDLogVerbose(@"Mirroring the track %@", track.assetURL);

    RACSignal *exportSignal = [[[[track largeArtwork] flattenMap:^RACStream *(UIImage *artworkImage) {
        NSData *artworkData;
        if (artworkImage)
            artworkData = UIImagePNGRepresentation(artworkImage);

        return [self exportTrack:track withArtwork:artworkData];
    }]
    flattenMap:^RACStream *(NSURL *fileURL) {

        if (!track.managedObjectContext)
            return nil;

        track.fileURL = [fileURL absoluteString];

        NSError *error;
        if (![[PLDataAccess sharedDataAccess] saveChanges:&error])
            [PLErrorManager logError:error];

        return nil;
    }]
    deliverOn:[RACScheduler mainThreadScheduler]];

    return [[RACSignal return:progress] concat:exportSignal];
}

- (RACSignal *)exportTrack:(PLTrack *)track withArtwork:(NSData *)artwork
{
    NSString *fileName = [NSString stringWithFormat:@"%lld.m4a", track.persistentId];
    NSString *targetFilePath = [NSString pathWithComponents:@[[PLUtils documentDirectoryPath], fileName]];
    NSURL *targetFileURL = [NSURL fileURLWithPath:targetFilePath];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [targetFileURL path];

    if([fileManager fileExistsAtPath:filePath])
        [fileManager removeItemAtURL:targetFileURL error:nil];

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:track.assetURL options:nil];

    AVMutableMetadataItem *titleMetadataItem = [[AVMutableMetadataItem alloc] init];
    titleMetadataItem.keySpace = AVMetadataKeySpaceCommon;
    titleMetadataItem.key = AVMetadataCommonKeyTitle;
    titleMetadataItem.value = track.title;

    AVMutableMetadataItem *artistMetadataItem = [[AVMutableMetadataItem alloc] init];
    artistMetadataItem.keySpace = AVMetadataKeySpaceCommon;
    artistMetadataItem.key = AVMetadataCommonKeyArtist;
    artistMetadataItem.value = track.artist;

    AVMutableMetadataItem *artworkMetadataItem = [[AVMutableMetadataItem alloc] init];
    artworkMetadataItem.keySpace = AVMetadataKeySpaceiTunes;
    artworkMetadataItem.key = AVMetadataiTunesMetadataKeyCoverArt;
    artworkMetadataItem.value = artwork;

    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
    exportSession.outputURL = targetFileURL;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.metadata = @[titleMetadataItem, artistMetadataItem, artworkMetadataItem];

    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
        {
            if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                [subscriber sendNext:targetFileURL];
                [subscriber sendCompleted];
            }
            else
                [subscriber sendError:exportSession.error];
        }];
        return nil;
    }];
}

@end