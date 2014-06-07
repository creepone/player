#import <Foundation/Foundation.h>

@interface PLLegacySongTableViewCell : UITableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (UIImage *)artworkImage;
- (void)setArtworkImage:(UIImage *)image;

@end