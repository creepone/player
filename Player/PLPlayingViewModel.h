#import <Foundation/Foundation.h>

@interface PLPlayingViewModel : NSObject

@property (strong, nonatomic, readonly) UIImage *imageArtwork;
@property (strong, nonatomic, readonly) NSString *titleText;
@property (strong, nonatomic, readonly) NSString *artistText;
@property (strong, nonatomic, readonly) UIImage *imagePlayPause;

- (void)playPause;
- (void)goBack;
- (void)moveToPrevious;
- (void)moveToNext;
- (void)skipToStart;
- (void)makeBookmark;

@end
