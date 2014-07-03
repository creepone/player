#import <Foundation/Foundation.h>

typedef void(^PLNotificationObserverHandler)(NSNotification *);

@interface PLNotificationObserver : NSObject

+ (instancetype)observer;

- (void)addNotification:(NSString *)notificationName handler:(PLNotificationObserverHandler)handler;

@end