#import "PLNotificationObserver.h"

@interface PLNotificationObserver() {
    NSMutableArray *_observers;
}

@end

@implementation PLNotificationObserver

- (instancetype)init
{
    self = [super init];
    if (self) {
        _observers = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)observer
{
    return [[self alloc] init];
}

- (void)addNotification:(NSString *)notificationName handler:(PLNotificationObserverHandler)handler
{
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:notificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:handler];
    [_observers addObject:observer];
}

- (void)dealloc
{
    for (id observer in _observers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
}

@end