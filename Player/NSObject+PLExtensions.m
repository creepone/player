#import "NSObject+PLExtensions.h"

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

@end