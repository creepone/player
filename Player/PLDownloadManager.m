#import "PLDownloadManager.h"
#import "PLErrorManager.h"

@interface PLDownloadManager() <NSURLSessionDelegate, NSURLSessionDownloadDelegate> {
    NSURLSession *_session;
}
@end

NSString * const PLBackgroundSessionIdentifier = @"at.iosapps.Player.BackgroundSession";

@implementation PLDownloadManager

+ (PLDownloadManager *)sharedManager
{
    static dispatch_once_t once;
    static PLDownloadManager *sharedManager;
    dispatch_once(&once, ^ { sharedManager = [[self alloc] init]; });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:PLBackgroundSessionIdentifier];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    [PLErrorManager logError:error];
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    if (self.sessionCompletionHandler) {
        dispatch_block_t handler = self.sessionCompletionHandler;
        self.sessionCompletionHandler = nil;
        handler();
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    // todo: error might be nil
}

@end
