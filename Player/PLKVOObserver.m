#import "PLKVOObserver.h"

@interface PLKVOObserver () {
    NSObject *_target;
    NSMutableDictionary *_handlers;
}
@end

@implementation PLKVOObserver

- (instancetype)initWithTarget:(NSObject *)target
{
    self = [super init];
    if (self) {
        _target = target;
        _handlers = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)observerWithTarget:(NSObject *)target
{
    return [[self alloc] initWithTarget:target];
}

- (void)addKeyPath:(NSString *)keyPath handler:(PLKVOObserverHandler)handler
{
    _handlers[keyPath] = handler;
    [_target addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    id value = change[NSKeyValueChangeNewKey];
    if ([[NSNull null] isEqual:value])
        value = nil;

    PLKVOObserverHandler handler = _handlers[keyPath];
    handler(value);
}

- (void)dealloc
{
    for (NSString *keyPath in [_handlers allKeys])
        [_target removeObserver:self forKeyPath:keyPath];
}

@end
