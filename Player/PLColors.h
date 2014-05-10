#import <Foundation/Foundation.h>


@interface PLColors : NSObject

/**
 A color with alpha = 1.0 and red, green, blue channels all set to the given shade (0..255)
 */
+ (UIColor *)shadeOfGrey:(NSUInteger)shade;

/**
 A color with alpha = 1.0 and the given red, green, blue channels
 */
+ (UIColor *)colorWithRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue;

/**
 A theme color used as a tint all over the application
 */
+ (UIColor *)themeColor;

@end