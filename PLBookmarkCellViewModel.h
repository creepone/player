#import <Foundation/Foundation.h>

@class PLBookmarkSong;

@interface PLBookmarkCellViewModel : NSObject

@property (strong, nonatomic, readonly) UIImage *imageArtwork;
@property (strong, nonatomic, readonly) NSString *titleText;
@property (strong, nonatomic, readonly) NSString *artistText;
@property (strong, nonatomic, readonly) NSString *durationText;
@property (assign, nonatomic, readonly) UIColor *backgroundColor;
@property (assign, nonatomic, readonly) CGFloat alpha;
@property (assign, nonatomic, readonly) double playbackProgress;
@property (assign, nonatomic, readonly) double bookmarkPosition;


- (instancetype)initWithBookmarkSong:(PLBookmarkSong *)bookmarkSong;

- (void)selectCell;

@end
