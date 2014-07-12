#import "PLServiceContainer+Registrations.h"
#import "PLDropboxManager.h"

@implementation PLServiceContainer (Registrations)

- (void)registerAll
{
    [self addCreator:^{ return [PLDropboxManager sharedManager]; } underProtocol:@protocol(PLDownloadProvider)];
}

@end
