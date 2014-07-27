#import <Foundation/Foundation.h>

@protocol PLNetworkManager <NSObject>

/**
 Returns a signal that delivers the UIImage populated with the data downloaded from the given URL and completes.
 The signal is delivered on the main thread.
 */
- (RACSignal *)imageFromURL:(NSURL *)imageURL;

/**
 Returns a signal that delivers the NSData downloaded from the given URL and completes.
 */
- (RACSignal *)getDataFromURL:(NSURL *)url;

@end

@interface PLNetworkManager : NSObject <PLNetworkManager>
@end
