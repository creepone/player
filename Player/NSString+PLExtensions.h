@interface NSString (PLExtensions)

+ (id)pl_stringWithFormat:(NSString *)format array:(NSArray*)arguments;

- (BOOL)pl_isEmptyOrWhitespace;

- (NSString *)pl_stringBySanitizingFileName;

@end