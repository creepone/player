@interface NSArray (PLExtensions)

/**
 Returns a new array that is a result of filtering self by the given predicate.
 */
- (NSArray *)pl_filter:(BOOL (^)(id obj, NSUInteger idx))predicate;

/**
 Returns a new array that is a result of the given projection of the given array's elements.
 */
- (NSArray *)pl_map:(id (^)(id obj))projection;

@end