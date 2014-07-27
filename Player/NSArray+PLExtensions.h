@interface NSArray (PLExtensions)

/**
 Returns a new array that is a result of filtering self by the given predicate.
 */
- (NSArray *)pl_filter:(BOOL (^)(id obj, NSUInteger idx))predicate;

/**
 Returns an element of this array that satisfies the given predicate, or nil if none is found.
 */
- (id)pl_find:(BOOL (^)(id obj))predicate;

/**
 Returns a new array that is a result of the given projection of the given array's elements.
 */
- (NSArray *)pl_map:(id (^)(id obj))projection;

/**
 Returns a new array containing the same elements as this one except for the last one.
 */
- (NSArray *)pl_allButLast;

@end