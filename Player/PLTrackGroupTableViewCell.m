#import "PLTrackGroupTableViewCell.h"

@interface PLTrackGroupTableViewCell() {
    UIImage *_imageArtwork;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewArtwork;

@end

@implementation PLTrackGroupTableViewCell

- (UIImage *)imageArtwork
{
    return _imageArtwork;
}

- (void)setImageArtwork:(UIImage *)imageArtwork
{
    _imageArtwork = imageArtwork;

    if (imageArtwork) {
        self.imageViewArtwork.image = imageArtwork;
    }
    else {
        self.imageViewArtwork.image = [UIImage imageNamed:@"DefaultArtwork"];
    }
}

@end
