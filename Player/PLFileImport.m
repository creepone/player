#import <RXPromise.h>
#import "PLFileImport.h"
#import "PLDataAccess.h"
#import "PLUtils.h"

@implementation PLFileImport

+ (RXPromise *)importFile:(NSURL *)fileURL
{
    NSString *fileName = [[fileURL path] lastPathComponent];

    NSString *targetFilePath = [NSString pathWithComponents:@[[PLUtils documentDirectoryPath], fileName]];
    NSURL *targetFileURL = [NSURL fileURLWithPath:targetFilePath];

    NSError *error;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager copyItemAtURL:fileURL toURL:targetFileURL error:&error];

    if (error)
        return [RXPromise promiseWithResult:error];

    // todo: handle edge cases: file already exists at this location

    PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
    PLTrack *track = [dataAccess trackWithFileURL:[targetFileURL absoluteString]];

    // todo: show ui to select the playlist(s) where the track should be inserted

    PLPlaylist *playlist = [dataAccess selectedPlaylist];
    if (playlist)
        [playlist addTrack:track];

    [dataAccess saveChanges:&error];
    return [RXPromise promiseWithResult:error];
}

@end
