#import <Foundation/Foundation.h>
#import "PLActivity.h"

@class PLPlaylist;

@interface PLSelectFromMusicLibraryActivity : NSObject <PLActivity>

- (id)initWithPlaylist:(PLPlaylist *)playlist;

@end