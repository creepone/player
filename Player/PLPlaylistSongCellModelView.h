#import <Foundation/Foundation.h>

@class PLPlaylistSong;

@interface PLPlaylistSongCellModelView : NSObject

@property (strong, nonatomic, readonly) UIImage *imageArtwork;
@property (strong, nonatomic, readonly) NSString *titleText;
@property (strong, nonatomic, readonly) NSString *artistText;
@property (strong, nonatomic, readonly) NSString *durationText;
@property (assign, nonatomic, readonly) double progress;
@property (assign, nonatomic, readonly) UIColor *backgroundColor;

- (instancetype)initWithPlaylistSong:(PLPlaylistSong *)playlistSong;

@end