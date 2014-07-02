#import "PLObservable.h"

@interface PLKVOObservable : PLObservable

- (instancetype)initWithSource:(NSObject *)source keyPath:(NSString *)keyPath;

@end
