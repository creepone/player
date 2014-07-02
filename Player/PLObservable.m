#import "PLObservable.h"
#import "PLKVOObservable.h"
#import "PLNotificationCenterObservable.h"
#import "NSObject+PLExtensions.h"


@interface PLObserverEntry : NSObject 

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) PLObserverCallback callback;

@end

@implementation PLObserverEntry @end


@interface PLObservable() {
    NSMutableArray *_observers;

    // used to intentionaly create a retain cycle between self and self to avoid getting dealloced
    id _selfCycle;
    
    // set to NO once we are no longer emitting any values. at this point we should only wait to be dealloced
    BOOL _emitting;
}
@end

@implementation PLObservable

- (instancetype)init
{
    self = [super init];
    if (self) {
        _emitting = YES;
        _observers = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)observableFromSource:(NSObject *)source keyPath:(NSString *)keyPath
{
    return [[PLKVOObservable alloc] initWithSource:source keyPath:keyPath];
}

+ (instancetype)observableFromNotification:(NSString *)notificationName
{
    return [[PLNotificationCenterObservable alloc] initWithNotificationName:notificationName];
}

- (void)emit:(id)value
{
    NSArray *observers;
    @synchronized(self) {
        observers = [_observers copy];
    }
    
    for (PLObserverEntry *observerEntry in observers) {
        NSObject *observer = observerEntry.observer;
        if (observer != nil)
            observerEntry.callback(observer, value);
    }
}

- (void)stop
{
    @synchronized(self) {
        _emitting = NO;
        [_observers removeAllObjects];
        _selfCycle = nil;
    }
}

- (instancetype)addObserver:(NSObject *)observer selector:(SEL)selector
{
    PLObserverCallback callback = ^(id observer, id value) {
        [observer performSelector:selector withObject:value];
    };
    
    [self addObserver:observer callback:callback];
    
    return self;
}

- (instancetype)addObserver:(NSObject *)observer callback:(PLObserverCallback)callback
{
    @synchronized(self) {
        if (!_emitting)
            return nil;
        
        PLObserverEntry *observerEntry = [PLObserverEntry new];
        observerEntry.observer = observer;
        observerEntry.callback = callback;
        [_observers addObject:observerEntry];
        
        _selfCycle = self;
    }
    
    PLObservable * __weak weakSelf = self;
    NSObject * __weak weakObserver = observer;
    [observer pl_attachDeallocBlock:^{
        PLObservable *strongSelf = weakSelf;
        NSObject *strongObserver = weakObserver;
        [strongSelf removeObserver:strongObserver];
    }];
    
    return self;
}

- (instancetype)removeObserver:(NSObject *)observer
{
    @synchronized(self) {
        if (!_emitting)
            return nil;
        
        [_observers removeObjectsAtIndexes:[_observers indexesOfObjectsPassingTest:^BOOL(PLObserverEntry *observerEntry, NSUInteger idx, BOOL *stop) {
            return observerEntry.observer == observer;
        }]];
        
        _selfCycle = [_observers count] > 0 ? self : nil;
    }
    
    return self;
}

@end
