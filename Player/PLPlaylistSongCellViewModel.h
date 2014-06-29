#import <Foundation/Foundation.h>
#import "PLTrack.h"

@class PLPlaylistSong, PLTrack, RACCommand;

@interface PLPlaylistSongCellViewModel : NSObject

@property (strong, nonatomic, readonly) UIImage *imageArtwork;
@property (strong, nonatomic, readonly) NSString *titleText;
@property (strong, nonatomic, readonly) NSString *artistText;
@property (strong, nonatomic, readonly) NSString *durationText;
@property (assign, nonatomic, readonly) UIColor *backgroundColor;
@property (assign, nonatomic, readonly) CGFloat alpha;
@property (assign, nonatomic, readonly) double playbackProgress;

@property (strong, nonatomic, readonly) UIImage *accessoryImage;
@property (strong, nonatomic, readonly) NSNumber *accessoryProgress;
@property (strong, nonatomic, readonly) RACCommand *accessoryCommand;

- (instancetype)initWithPlaylistSong:(PLPlaylistSong *)playlistSong;

@end