#import <OCMock/OCMock.h>
#import "PLTestCase.h"
#import "PLServiceContainer.h"

@interface PLTestCase() {
    id _serviceContainerMock;
}

@property (nonatomic, strong, readwrite) PLServiceContainer *serviceContainer;

@end

@implementation PLTestCase

- (void)setUp
{
    self.serviceContainer = [PLServiceContainer new];
    _serviceContainerMock = OCMClassMock([PLServiceContainer class]);
    OCMStub([_serviceContainerMock sharedContainer]).andReturn(self.serviceContainer);
}

- (PLTestCaseErrorHandler)onError
{
    return ^(NSError *error)
    {
        NSLog(@"Error occured: %@", error);
        [self notify:kXCTUnitWaitStatusFailure];
    };
}

@end
