#import "PLBookmark.h"
#import "PLTrack.h"

@implementation PLBookmark

@dynamic timestamp;
@dynamic position;
@dynamic track;

- (void)remove
{
    [self.managedObjectContext deleteObject:self];
}

@end
