#import <Foundation/Foundation.h>

// Identifier of the background NSURLSession used by the app (managed by the PLDownloadManager)
extern NSString * const PLBackgroundSessionIdentifier;

@interface PLDownloadManager : NSObject

+ (PLDownloadManager *)sharedManager;

/**
 The handler to be called in the URLSessionDidFinishEventsForBackgroundURLSession delegate method. Typically
 set by the application delegate when the app was started to handle session events.
 */
@property (nonatomic, copy) dispatch_block_t sessionCompletionHandler;

@end
