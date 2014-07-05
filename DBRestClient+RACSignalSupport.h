#import <DropboxSDK/DropboxSDK.h>

@interface DBRestClient (RACSignalSupport)

- (RACSignal *)rac_loadMetadataSignal:(NSString *)path;

@end
