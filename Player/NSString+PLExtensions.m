#import "NSString+PLExtensions.h"

@implementation NSString (PLExtensions)

+ (id)pl_stringWithFormat:(NSString *)format array:(NSArray*)arguments
{
    NSRange range = NSMakeRange(0, [arguments count]);
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(id) * [arguments count]];
    [arguments getObjects:(__unsafe_unretained id *)data.mutableBytes range:range];
    NSString* result = [[NSString alloc] initWithFormat:format arguments:data.mutableBytes];
    return result;
}

- (BOOL)pl_isEmptyOrWhitespace
{
	// A nil or NULL string is not the same as an empty string
	return 0 == self.length ||
	![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

- (NSString *)pl_stringBySanitizingFileName
{
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    return [[self componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
}

@end