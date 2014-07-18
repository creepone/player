#import "PLServiceContainer+Registrations.h"
#import "PLDropboxManager.h"
#import "PLGDriveManager.h"
#import "PLOneDriveManager.h"
#import "PLNowPlayingManager.h"

@implementation PLServiceContainer (Registrations)

- (void)registerAll
{
    [self addCreator:^{ return [PLDropboxManager sharedManager]; } underProtocol:@protocol(PLDownloadProvider)];
    [self addCreator:^{ return [PLGDriveManager sharedManager]; } underProtocol:@protocol(PLDownloadProvider)];
    [self addCreator:^{ return [PLOneDriveManager sharedManager]; } underProtocol:@protocol(PLDownloadProvider)];
    
    [self registerInstance:[PLNowPlayingManager new] underProtocol:@protocol(PLNowPlayingManager)];
}

@end
