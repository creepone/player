#import "PLLegacySongTableViewCell.h"

@implementation PLLegacySongTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (UIImage *)artworkImage
{
    return self.imageView.image;
}

- (void)setArtworkImage:(UIImage *)image
{
    if (image) {
        self.imageView.image = image;
    }
}

@end