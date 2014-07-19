#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLFileSharingManager.h"
#import "PLFileSharingItem.h"
#import "PLUtils.h"
#import "PLDataAccess.h"

@implementation PLFileSharingManager

- (RACSignal *)allImportableItems
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return [[RACScheduler scheduler] schedule:^{
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *documentsPath = [PLUtils documentDirectoryPath];
            
            NSError *error;
            NSArray *allFiles = [fileManager contentsOfDirectoryAtPath:documentsPath error:&error];
            
            if (error) {
                [subscriber sendError:error];
                return;
            }
            
            PLDataAccess *dataAccess = [[PLDataAccess alloc] initWithNewContext:YES];
            
            NSMutableArray *result = [NSMutableArray array];
            
            for (NSString *fileName in allFiles) {
                if ([fileName hasPrefix:@"."])
                    continue;
                
                NSString *fullPath = [documentsPath stringByAppendingPathComponent:fileName];
                NSString *relativePath = [PLUtils pathFromDocuments:[NSURL fileURLWithPath:fullPath]];
                
                NSDictionary *attributes = [fileManager attributesOfItemAtPath:fullPath error:nil];
                if (attributes == nil || ![attributes.fileType isEqualToString:NSFileTypeRegular])
                    continue;
                
                if ([dataAccess existsTrackWithFilePath:relativePath])
                    continue;
                
                PLFileSharingItem *item = [PLFileSharingItem new];
                item.title = fileName;
                item.path = relativePath;
                [result addObject:item];
            }
            
            [subscriber sendNext:result];
            [subscriber sendCompleted];
            
        }];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)importItems:(NSArray *)items
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return [[RACScheduler scheduler] schedule:^{
            
            PLDataAccess *dataAccess = [[PLDataAccess alloc] initWithNewContext:YES];
            PLPlaylist *playlist = [dataAccess selectedPlaylist];

            for (PLFileSharingItem *item in items) {
                PLTrack *track = [dataAccess findOrCreateTrackWithFilePath:item.path];
                if (!track.isInserted)
                    continue;
                
                [playlist addTrack:track];
            }
            
            [[dataAccess saveChangesSignal] subscribe:subscriber];
        }];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

@end
