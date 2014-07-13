#import "PLServiceContainer+Registrations.h"
#import "PLDropboxManager.h"
#import "PLGDriveManager.h"
#import "PLOneDriveManager.h"

@implementation PLServiceContainer (Registrations)

- (void)registerAll
{
    [self addCreator:^{ return [PLDropboxManager sharedManager]; } underProtocol:@protocol(PLDownloadProvider)];
    [self addCreator:^{ return [PLGDriveManager sharedManager]; } underProtocol:@protocol(PLDownloadProvider)];
    [self addCreator:^{ return [PLOneDriveManager sharedManager]; } underProtocol:@protocol(PLDownloadProvider)];
}

@end
