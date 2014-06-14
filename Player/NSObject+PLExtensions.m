#import <RXPromise/RXPromise.h>
#import "NSObject+PLExtensions.h"

static const char* kPromisesKey = "PLPromises";

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


- (NSMutableArray *)pl_promises
{
    NSMutableArray* promises = objc_getAssociatedObject(self, kPromisesKey);

    if (promises == nil) {
        promises = [NSMutableArray array];
        objc_setAssociatedObject(self, kPromisesKey, promises, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return promises;
}

- (void)pl_setValueForKeyPath:(NSString *)keyPath fromPromise:(RXPromise *)promise
{
    [self.pl_promises addObject:promise];

    @weakify(self);
    RXPromise * __weak weakPromise = promise;

    promise.thenOnMain(^id(id value) {
        @strongify(self);
        RXPromise *promise = weakPromise;

        if (!self || !promise)
            return nil;

        if ([self.pl_promises containsObject:promise]) {
            [self setValue:value forKeyPath:keyPath];
            [self.pl_promises removeObject:promise];
        }

        return nil;
    }, nil);
}

- (void)pl_removeAllPromises
{
    objc_setAssociatedObject(self, kPromisesKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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