//
//  PLButton.m
//  Player
//
//  Created by Tomas Vana on 07/05/14.
//  Copyright (c) 2014 Tomas Vana. All rights reserved.
//

#import "PLButton.h"

@interface PLButton() {
    UIColor *_originalBackgroundColor;
}

@end

@implementation PLButton

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (!self.highlightedBackgroundColor)
        return;
    
    if (highlighted) {
        _originalBackgroundColor = self.backgroundColor ?: [UIColor clearColor];
        self.backgroundColor = self.highlightedBackgroundColor;
    }
    else {
        self.backgroundColor = _originalBackgroundColor;
    }
}

@end
