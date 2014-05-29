#import "PLColors.h"

@implementation PLColors

+ (UIColor *)shadeOfGrey:(NSUInteger)shade
{
    return [UIColor colorWithRed:shade/255.0 green:shade/255.0 blue:shade/255.0 alpha:1.0];
}

+ (UIColor *)colorWithRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue
{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

+ (UIColor *)themeColor
{
    return [self colorWithRed:53 green:87 blue:122];
}

@end