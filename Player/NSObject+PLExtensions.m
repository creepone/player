#import <objc/runtime.h>
#import "NSObject+PLExtensions.h"

@interface PLDeallocNotifier : NSObject

@property (nonatomic, copy) void (^deallocBlock)();

@end

@implementation PLDeallocNotifier

- (void)dealloc
{
    if (self.deallocBlock)
        self.deallocBlock();
}

@end

@implementation NSObject (PLExtensions)

- (NSMutableDictionary*)pl_userInfo
{
    static const char* kObjectUserInfoKey = "PLUserInfo";
    NSMutableDictionary* objectUserInfo = objc_getAssociatedObject(self, kObjectUserInfoKey);

    if (objectUserInfo == nil) {
        objectUserInfo = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, kObjectUserInfoKey, objectUserInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return objectUserInfo;
}

- (instancetype)pl_deepCopy
{
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
}

- (void)pl_notifyKvoForKey:(NSString *)key
{
    [self willChangeValueForKey:key];
    [self didChangeValueForKey:key];
}

- (void)pl_notifyKvoForKeys:(NSArray *)keys
{
    for (NSString *key in keys) {
        [self pl_notifyKvoForKey:key];
    }
}

- (void)pl_attachDeallocBlock:(dispatch_block_t)deallocBlock
{
    PLDeallocNotifier *notifier = [PLDeallocNotifier new];
    notifier.deallocBlock = deallocBlock;
    objc_setAssociatedObject(self, (__bridge void *)notifier, notifier, OBJC_ASSOCIATION_RETAIN);
}

@end