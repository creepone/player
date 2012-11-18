//
//  NSString+Extensions.h
//  EnergyTracker
//
//  Created by Tomas Vana on 3/26/12.
//  Copyright (c) 2012 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)

- (BOOL)pl_isEmptyOrWhitespace;

- (NSString *)pl_stringBySanitizingFileName;

@end
