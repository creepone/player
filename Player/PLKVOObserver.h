#import <Foundation/Foundation.h>

typedef void(^PLKVOObserverHandler)(id);

@interface PLKVOObserver : NSObject

- (instancetype)initWithTarget:(NSObject *)target;
+ (instancetype)observerWithTarget:(NSObject *)target;

- (void)addKeyPath:(NSString *)keyPath handler:(PLKVOObserverHandler)handler;

@end
