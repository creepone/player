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

/**
* Sets the value of this object at the given key path to the value of the promise as soon as it gets resolved.
*/
- (void)pl_setValueForKeyPath:(NSString *)keyPath fromPromise:(RXPromise *)promise;

/**
* Removes all the previously registered promises so that they no longer cause values for key paths to be set (if not resolved yet).
*/
- (void)pl_removeAllPromises;

@end