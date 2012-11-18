//
//  NSString+Extensions.m
//  EnergyTracker
//
//  Created by Tomas Vana on 3/26/12.
//  Copyright (c) 2012 iOS Apps Austria. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

- (BOOL)pl_isEmptyOrWhitespace {
	// A nil or NULL string is not the same as an empty string
	return 0 == self.length ||
	![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

- (NSString *)pl_stringBySanitizingFileName {
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    return [[self componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
}

@end
