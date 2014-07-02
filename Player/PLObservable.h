#import <Foundation/Foundation.h>

typedef void(^PLObserverCallback)(id, id);

@interface PLObservable : NSObject

+ (instancetype)observableFromSource:(NSObject *)source keyPath:(NSString *)keyPath;
+ (instancetype)observableFromNotification:(NSString *)notificationName;

- (instancetype)addObserver:(NSObject *)observer selector:(SEL)selector;
- (instancetype)addObserver:(NSObject *)observer callback:(PLObserverCallback)callback;
- (instancetype)removeObserver:(NSObject *)observer;

- (void)emit:(id)value;
- (void)stop;

@end
