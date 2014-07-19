#import "XCTAsyncTestCase.h"

typedef void (^PLTestCaseErrorHandler)(NSError *);

@interface PLTestCase : XCTAsyncTestCase

- (PLTestCaseErrorHandler)onError;

@end
