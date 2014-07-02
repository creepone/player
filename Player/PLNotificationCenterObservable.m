#import "PLNotificationCenterObservable.h"

@implementation PLNotificationCenterObservable

- (instancetype)initWithNotificationName:(NSString *)notificationName
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:notificationName object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)notification
{
    [self emit:notification];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
