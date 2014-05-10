#import "PLSelectFromMusicLibraryActivity.h"
#import "PLPromise.h"

@implementation PLSelectFromMusicLibraryActivity

- (NSString *)title
{
    // todo: localize this
    return @"Music";
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"MusicIcon"];
}

- (PLPromise *)performActivity
{
    return [PLPromise promiseWithResult:nil];
}

@end