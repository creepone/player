#import "NSArray+PLExtensions.h"

@implementation NSArray (PLExtensions)

- (NSArray *)pl_filter:(BOOL (^)(id obj, NSUInteger idx))predicate
{
    return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        return predicate(obj, idx);
    }]];
}

- (NSArray *)pl_map:(id (^)(id obj))projection
{
    NSMutableArray *result = [NSMutableArray array];
    for (id obj in self) {
        [result addObject:projection(obj)];
    }
    return result;
}

- (NSArray *)pl_allButLast
{
    if ([self count] == 0)
        return self;
    
    NSRange range = { .location = 0, .length = [self count] - 1 };
    return [self subarrayWithRange:range];
}

@end