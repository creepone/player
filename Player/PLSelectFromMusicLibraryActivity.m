#import <RXPromise/RXPromise.h>
#import "PLSelectFromMusicLibraryActivity.h"

@implementation PLSelectFromMusicLibraryActivity

- (NSString *)title
{
    return NSLocalizedString(@"Activities.Music", nil);
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"MusicIcon"];
}

- (RXPromise *)performActivity
{
    return [RXPromise promiseWithResult:nil];
}

@end