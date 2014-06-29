#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLBackgroundProcess.h"
#import "PLBackgroundProcess+Protected.h"
#import "PLErrorManager.h"

@interface PLBackgroundProcess() {
    BOOL _suspended;
}

@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, retain) RACSignal *progressSignal;

@end

@implementation PLBackgroundProcess

- (void)ensureRunning
{
    if (self.isRunning) {
        DDLogInfo(@"The process %@ already running", NSStringFromClass([self class]));
        return;
    }

    DDLogVerbose(@"Activating the process %@", NSStringFromClass([self class]));
    _suspended = NO;

    RACSignal *processSignal = [[self nextItem] flattenMap:^RACStream *(id item) {
        return [self processItem:item];
    }];

    self.isRunning = YES;
    
    self.progressSignal = [[[[processSignal repeatWhileBlock:^BOOL(NSUInteger count) {
        return count > 0 && !self->_suspended;
    }]
    doCompleted:^{
        self.isRunning = NO;
        DDLogVerbose(@"Completed the process %@", NSStringFromClass([self class]));
    }]
    doError:^(NSError *error){
        self.isRunning = NO;
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