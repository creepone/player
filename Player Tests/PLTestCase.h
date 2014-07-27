#import "XCTAsyncTestCase.h"

typedef void (^PLTestCaseErrorHandler)(NSError *);

@class PLServiceContainer;

@interface PLTestCase : XCTAsyncTestCase

- (PLTestCaseErrorHandler)onError;

@property (nonatomic, strong, readonly) PLServiceContainer *serviceContainer;

@end
