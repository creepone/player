@import AVFoundation;
@import MobileCoreServices;
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLMediaMirror.h"
#import "PLTrack.h"
#import "PLDataAccess.h"
#import "PLUtils.h"
#import "PLErrorManager.h"
#import "PLDefaultsManager.h"
#import "PLBackgroundProcessProgress.h"
#import "PLFileImport.h"

static NSString * const kOutputExtension = @"outputExtension";
static NSString * const kFinalExtension = @"finalExtension";
static NSString * const kOutputFileType = @"outputFileType";
static NSString * const kExportPresetName = @"exportPresetName";

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
        PLTrack *track = [dataAccess findNextTrackToMirror];

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

    RACSignal *exportSignal = [[[[[track largeArtwork] flattenMap:^RACStream *(UIImage *artworkImage) {
        NSData *artworkData;
        if (artworkImage)
            artworkData = UIImagePNGRepresentation(artworkImage);

        return [self exportTrack:track withArtwork:artworkData];
    }]
    flattenMap:^RACStream *(NSURL *fileURL) {
        return [PLFileImport moveToDocumentsFolder:fileURL];
    }]
    flattenMap:^RACStream *(NSURL *fileURL) {

        if (!track.managedObjectContext) {
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
            if (error)
                [PLErrorManager logError:error];
            return nil;
        }

        track.filePath = [PLUtils pathFromDocuments:fileURL];

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
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:track.assetURL options:nil];
    NSString *extension = [[[[asset.URL absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0] pathExtension];
    NSDictionary *settings = [self settingsForExtension:extension];
    
    NSString *fileName = [NSString stringWithFormat:@"%lld.%@", track.persistentId, settings[kOutputExtension]];
    NSString *targetFilePath = [NSString pathWithComponents:@[NSTemporaryDirectory(), fileName]];
    NSURL *targetFileURL = [NSURL fileURLWithPath:targetFilePath];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [targetFileURL path];

    if([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        [fileManager removeItemAtURL:targetFileURL error:&error];
        if (error)
            return [RACSignal error:error];
    }

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

    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:settings[kExportPresetName]];
    exportSession.outputURL = targetFileURL;
    exportSession.metadata = @[titleMetadataItem, artistMetadataItem, artworkMetadataItem];
    exportSession.outputFileType = settings[kOutputFileType];
    
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
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
    }]
    flattenMap:^RACStream *(NSURL *targetFileURL) {
        if ([settings[kFinalExtension] isEqualToString:settings[kOutputExtension]])
            return [RACSignal return:targetFileURL];
        
        NSError *error;
        
        NSString *pathWithOriginalExtension = [[targetFileURL.path stringByDeletingPathExtension] stringByAppendingPathExtension:settings[kFinalExtension]];
        if ([fileManager fileExistsAtPath:pathWithOriginalExtension]) {
            [fileManager removeItemAtPath:pathWithOriginalExtension error:&error];
            if (error)
                return [RACSignal error:error];
        }
        
        [fileManager moveItemAtPath:targetFileURL.path toPath:pathWithOriginalExtension error:&error];
        if (error)
            return [RACSignal error:error];
        
        return [RACSignal return:[NSURL fileURLWithPath:pathWithOriginalExtension]];
    }];
}

- (NSDictionary *)settingsForExtension:(NSString *)extension
{
    if ([extension isEqualToString:@"mp3"]) {
        return @{
            kOutputExtension: @"mov",
            kFinalExtension:extension,
            kOutputFileType: AVFileTypeQuickTimeMovie,
            kExportPresetName: AVAssetExportPresetPassthrough
        };
    }
    
    if ([extension isEqualToString:@"m4a"] || [extension isEqualToString:@"m4b"]) {
        return @{
            kOutputExtension: @"m4a",
            kFinalExtension: extension,
            kOutputFileType: AVFileTypeAppleM4A,
            kExportPresetName: AVAssetExportPresetPassthrough
        };
    }
    
    return @{
        kOutputExtension: @"m4a",
        kFinalExtension: @"m4a",
        kOutputFileType: AVFileTypeAppleM4A,
        kExportPresetName: AVAssetExportPresetAppleM4A
    };
}


@end