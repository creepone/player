#import <Foundation/Foundation.h>

@class PLPlaylistSong;

@interface PLPlaylistSongCellModelView : NSObject

@property (strong, nonatomic) UIImage *imageArtwork;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *artistText;
@property (strong, nonatomic) NSString *durationText;
@property (assign, nonatomic) double progress;
@property (assign, nonatomic) UIColor *backgroundColor;

- (instancetype)initWithPlaylistSong:(PLPlaylistSong *)playlistSong;

@end