@import AVFoundation;
#import <RXPromise/RXPromise.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLMediaMirror.h"
#import "PLDataAccess.h"
#import "PLDefaultsManager.h"
#import "PLErrorManager.h"
#import "PLUtils.h"

NSString * const PLMediaMirrorFinishedTrackNotification = @"PLMediaMirrorFinishedTrackNotification";

@interface PLMediaMirror() {
    BOOL _active, _suspended;
}
@end

@implementation PLMediaMirror

+ (PLMediaMirror *)sharedInstance
{
    static dispatch_once_t once;
    static PLMediaMirror *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        PLDefaultsManager *defaultsManager = [PLDefaultsManager sharedManager];

        @weakify(self);
        [[RACObserve(defaultsManager, mirrorTracks) skip:1] subscribeNext:^(NSNumber *mirrorTracks) {
            @strongify(self);
            
            if ([mirrorTracks boolValue]) {
                [self ensureActive];
            }
            else {
                [self suspend];
            }
        }];

    }
    return self;
}


- (BOOL)isActive
{
    return _active;
}

- (void)ensureActive
{
    if (![[PLDefaultsManager sharedManager] mirrorTracks])
        return;
    
    DDLogVerbose(@"Activating the mirror process");
    _suspended = NO;
    
    // make sure we're always peeking from the main queue
    dispatch_async(dispatch_get_main_queue(), ^{ [self peek]; });
}

- (void)suspend
{
    DDLogVerbose(@"Suspending the mirror process");
    _suspended = YES;
}


- (void)peek
{
    if (_active || _suspended)
        return;
    
    _active = YES;

    @weakify(self);
    [self mirrorNext].then(^(NSNumber *result){
        @strongify(self);
        if (!self)
            return @(NO);
    
        self->_active = NO;
        return result;
        
    }, ^(NSError *error) {
        @strongify(self);
        if (!self)
            return error;
        
        [PLErrorManager logError:error];
        
        self->_active = NO;
        return error;
        
    }).thenOnMain(^(NSNumber *result){
        @strongify(self);
        if (!self)
            return (id)nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PLMediaMirrorFinishedTrackNotification object:self];

        if ([result boolValue])
            [self peek];

        return (id)nil;
        
    }, nil);
}

- (RXPromise *)mirrorNext
{
    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
    
    PLTrack *track = [dataAccess nextTrackToMirror];
    if (!track)
        return [RXPromise promiseWithResult:@(NO)];
    
    DDLogVerbose(@"Mirroring the track %@", track.assetURL);

    return track.largeArtwork.then(^(UIImage *artworkImage) {

        NSData *artworkData;
        if (artworkImage)
            artworkData = UIImagePNGRepresentation(artworkImage);

        return [self exportTrack:track withArtwork:artworkData].thenOnMain(^(NSURL *fileURL){

            if (!track.managedObjectContext)
                return @(YES);

            track.fileURL = [fileURL absoluteString];

            NSError *error;
            if (![dataAccess saveChanges:&error])
                [PLErrorManager logError:error];

            return @(YES);

        }, nil);
    }, nil);
}

- (RXPromise *)exportTrack:(PLTrack *)track withArtwork:(NSData *)artwork
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

    RXPromise *promise = [[RXPromise alloc] init];
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
    {
        if (exportSession.status == AVAssetExportSessionStatusCompleted)
            [promise fulfillWithValue:targetFileURL];
        else
            [promise rejectWithReason:exportSession.error];
    }];
    
    return promise;
}

@end
