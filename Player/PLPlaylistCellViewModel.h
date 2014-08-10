#import <Foundation/Foundation.h>

@class PLPlaylist;

@interface PLPlaylistCellViewModel : NSObject

@property (nonatomic, strong, readonly) NSString *titleText;
@property (nonatomic, strong, readonly) NSString *subtitleText;
@property (nonatomic, strong, readonly) UIColor *backgroundColor;

- (instancetype)initWithPlaylist:(PLPlaylist *)playlist;
- (void)selectCell;

@end
