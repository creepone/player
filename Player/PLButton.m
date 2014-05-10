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

- (void)tintColorDidChange
{
    [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    [super tintColorDidChange];
}

@end
