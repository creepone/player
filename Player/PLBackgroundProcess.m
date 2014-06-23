#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLBackgroundProcess.h"
#import "PLBackgroundProcess+Protected.h"
#import "PLErrorManager.h"

@interface PLBackgroundProcess() {
    BOOL _suspended;
}

@property (nonatomic, retain) RACSignal *progressSignal;

@end

@implementation PLBackgroundProcess

- (void)ensureRunning
{
    // if already running, nothing to do
    if (self.progressSignal)
        return;

    DDLogVerbose(@"Activating the process %@", NSStringFromClass([self class]));
    _suspended = NO;

    RACSignal *processSignal = [[self nextItem] flattenMap:^RACStream *(id item) {
        return [self processItem:item];
    }];

    self.progressSignal = [[[[processSignal repeatWhileBlock:^BOOL(NSUInteger count) {
        return count > 0 && !self->_suspended;
    }]
    doCompleted:^{
        self.progressSignal = nil;
        DDLogVerbose(@"Completed the process %@", NSStringFromClass([self class]));
    }]
    doError:^(NSError *error){
        self.progressSignal = nil;
        [PLErrorManager logError:error];
    }]
    replayLast];
}

- (void)suspend
{
    DDLogVerbose(@"Suspending the process %@", NSStringFromClass([self class]));
    _suspended = YES;
}

#pragma mark -- Abstract methods

- (RACSignal *)nextItem
{
    return [RACSignal empty];
}

- (RACSignal *)processItem:(id)item
{
    return [RACSignal empty];
}

@end