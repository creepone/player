#import "PLKVOObservable.h"
#import "NSObject+PLExtensions.h"

@interface PLKVOObservable() {
    __weak NSObject *_source;
    NSString *_keyPath;
}
@end

@implementation PLKVOObservable

- (instancetype)initWithSource:(NSObject *)source keyPath:(NSString *)keyPath
{
    self = [super init];
    if (self) {
        _source = source;
        _keyPath = keyPath;
        
        PLKVOObservable * __weak weakSelf = self;
        [source pl_attachDeallocBlock:^{
            PLKVOObservable *strongSelf = weakSelf;
            [strongSelf stop];
        }];
        
        [source addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self emit:change[NSKeyValueChangeNewKey]];
}

- (void)dealloc
{
    NSObject *source = _source;
    if (source != nil)
        [source removeObserver:self forKeyPath:_keyPath];
}


@end
