#import "PLTestCase.h"

@implementation PLTestCase

- (PLTestCaseErrorHandler)onError
{
    return ^(NSError *error)
    {
        NSLog(@"Error occured: %@", error);
        [self notify:kXCTUnitWaitStatusFailure];
    };
}

@end
