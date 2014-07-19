#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLFileImport.h"
#import "PLDataAccess.h"
#import "PLUtils.h"
#import "PLPlayer.h"

@implementation PLFileImport

+ (RACSignal *)importFile:(NSURL *)fileURL
{
    return [[self moveToDocumentsFolder:fileURL] flattenMap:^RACStream *(NSURL *targetFileURL) {
        PLDataAccess *dataAccess = [PLDataAccess sharedDataAccess];
        PLTrack *track = [dataAccess trackWithFilePath:[PLUtils pathFromDocuments:targetFileURL]];
        PLPlaylistSong *playlistSong = [[dataAccess selectedPlaylist] addTrack:track];
        [[PLPlayer sharedPlayer] setCurrentSong:playlistSong];
        
        return [dataAccess saveChangesSignal];
    }];
}

+ (RACSignal *)moveToDocumentsFolder:(NSURL *)fileURL
{
    NSString *originalFileName = [[fileURL path] lastPathComponent];
    return [self moveToDocumentsFolder:fileURL underFileName:originalFileName];
}

+ (RACSignal *)moveToDocumentsFolder:(NSURL *)fileURL underFileName:(NSString *)fileName
{
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *newFileName = fileName;
        NSString *documentsPath = [PLUtils documentDirectoryPath];
        NSString *targetFilePath = [NSString pathWithComponents:@[documentsPath, newFileName]];
        
        int suffix = 1;
        while ([fileManager fileExistsAtPath:targetFilePath]) {
            newFileName = [NSString stringWithFormat:@"%@_%d.%@", [fileName stringByDeletingPathExtension], suffix, [fileName pathExtension]];
            targetFilePath = [NSString pathWithComponents:@[documentsPath, newFileName]];
            suffix++;
        }
        
        NSURL *targetFileURL = [NSURL fileURLWithPath:targetFilePath];
        
        NSError *error;
        [fileManager moveItemAtURL:fileURL toURL:targetFileURL error:&error];
        
        if (error)
            [subscriber sendError:error];
        else {
            [subscriber sendNext:targetFileURL];
            [subscriber sendCompleted];
        }

        return nil;
    }];
}

@end
