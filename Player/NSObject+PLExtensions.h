#import <Foundation/Foundation.h>

@interface NSObject (PLExtensions)

/**
 Provides access to a dictionary associated with the object under question. This allows to freely store additional data
 that is not part of the class definition for framework objects.
 */
- (NSMutableDictionary*)pl_userInfo;

/**
 Delivers a deep copy of this object.
 */
- (instancetype)pl_deepCopy;

@end