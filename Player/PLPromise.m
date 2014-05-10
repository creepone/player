#import "PLPromise.h"

@interface PLPromise() {
    PLPromise *_boundPromise;
    NSMutableArray *_progressHandlers;
}

@property (assign, nonatomic) float fractionCompleted;

@end

NSString * const kProgressKeyPath = @"progress";
NSString * const kFractionCompletedKeyPath = @"fractionCompleted";

@implementation PLPromise

- (instancetype)init
{
    self = [super init];
    if (self) {
        _progressHandlers = [NSMutableArray array];
        [self addObserver:self forKeyPath:kProgressKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (instancetype)initWithResult:(id)result
{
    self = [super initWithResult:result];
    if (self) {
        _progressHandlers = [NSMutableArray array];
        [self addObserver:self forKeyPath:kProgressKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (PLPromiseProgressOnBlock)progressOn
{
    return ^(dispatch_queue_t queue, PLPromiseProgressHandlerBlock progressHandler) {
        [_progressHandlers addObject:[^(float progress) {
            dispatch_async(queue, ^{ progressHandler(progress); });
        } copy]];
        return self;
    };
}

- (PLPromiseProgressOnMainBlock)progressOnMain
{
    return ^(PLPromiseProgressHandlerBlock progressHandler) {
        [_progressHandlers addObject:[^(float progress) {
            dispatch_async(dispatch_get_main_queue(), ^{ progressHandler(progress); });
        } copy]];
        return self;
    };
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kProgressKeyPath] && object == self) {
        NSProgress *oldProgress = change[NSKeyValueChangeOldKey];
        if (![[NSNull null] isEqual:oldProgress])
            [oldProgress removeObserver:self forKeyPath:kFractionCompletedKeyPath];
        [self.progress addObserver:self forKeyPath:kFractionCompletedKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    else if ([keyPath isEqualToString:kProgressKeyPath]) {
        PLPromise *other = (PLPromise *)object;
        self.progress = other.progress;
    }
    else  if ([keyPath isEqualToString:kFractionCompletedKeyPath] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        self.fractionCompleted = (float)progress.fractionCompleted;

        [_progressHandlers enumerateObjectsUsingBlock:^(PLPromiseProgressHandlerBlock handler, NSUInteger index, BOOL *stop) {
            handler(self.fractionCompleted);
        }];
    }
}

- (void)bind:(PLPromise *)other
{
    [super bind:other];

    if (other != self) {
        [_boundPromise removeObserver:self forKeyPath:kProgressKeyPath];
        [other addObserver:self forKeyPath:kProgressKeyPath options:NSKeyValueObservingOptionNew context:nil];
        _boundPromise = other;
    }
}

- (void)dealloc
{
    [_boundPromise removeObserver:self forKeyPath:kProgressKeyPath];
    [self.progress removeObserver:self forKeyPath:kFractionCompletedKeyPath];
    [self removeObserver:self forKeyPath:kProgressKeyPath];
}

@end
