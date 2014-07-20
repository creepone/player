#import <Foundation/Foundation.h>

@protocol PLNetworkManager <NSObject>

/**
 Returns a signal that delivers parsed JSON (as a NSDictionary/NSArray) downloaded from the given URL and completes.
 */
- (RACSignal *)getJSONFromURL:(NSURL *)url;

/**
 Returns a signal that delivers parsed XML (as an RXMLElement) downloaded from the given URL and completes.
 */
- (RACSignal *)getXMLFromURL:(NSURL *)url;

/**
 Returns a signal that delivers a UIImage downloaded from the given URL and completes.
 */
- (RACSignal *)getImageFromURL:(NSURL *)url;

@end

@interface PLNetworkManager : NSObject <PLNetworkManager>
@end
