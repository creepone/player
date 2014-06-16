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

    self.progressSignal = [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self doProcess:subscriber];
        return nil;
    }]
    doCompleted:^{
        self.progressSignal = nil;
        DDLogVerbose(@"Completed the process %@", NSStringFromClass([self class]));
    }]
    doError:PLErrorManager.logErrorVoidBlock]
    replayLast];
}

- (void)suspend
{
    DDLogVerbose(@"Suspending the process %@", NSStringFromClass([self class]));
    _suspended = YES;
}

- (void)doProcess:(id<RACSubscriber>)subscriber
{
    @weakify(self);

    RACSignal *processSignal = [[self nextItem] flattenMap:^RACStream *(id item) {
        return [self processItem:item];
    }];

    __block BOOL wasEmpty = YES;
    [processSignal subscribeNext:^(id value) {
        [subscriber sendNext:value];
        wasEmpty = NO;
    }
    error:^(NSError *error) {
        [subscriber sendError:error];
    }
    completed:^{
        @strongify(self);

        if (!self || wasEmpty || self->_suspended)
            [subscriber sendCompleted];
        else
            [self doProcess:subscriber];
    }];
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