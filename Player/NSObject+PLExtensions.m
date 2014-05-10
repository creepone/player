#import "NSObject+PLExtensions.h"

@implementation NSObject (PLExtensions)

- (NSMutableDictionary*)pl_userInfo
{
    static const char* kObjectUserInfoKey = "MGUserInfo";
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

@end