@class PLPromise;
@class PLRequestOptions;
@class RXPromise;

@interface PLRequestManager : NSObject

+ (PLRequestManager *)sharedManager;

/**
 Sends the request with the specified options.
 */
- (RXPromise *)sendRequestWithOptions:(PLRequestOptions *)options;

/**
 Initiates a file download with the specified options.
 */
- (PLPromise *)downloadWithOptions:(PLRequestOptions *)options;

@end