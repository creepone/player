#import "PLServiceContainer+Registrations.h"
#import "PLDropboxManager.h"
#import "PLGDriveManager.h"
#import "PLOneDriveManager.h"
#import "PLNowPlayingManager.h"
#import "PLFileSharingManager.h"
#import "PLNetworkManager.h"
#import "PLPodcastsManager.h"
#import "PLDataAccess.h"

@implementation PLServiceContainer (Registrations)

- (void)registerAll
{
    [self addCreator:^{ return [PLDropboxManager sharedManager]; } underProtocol:@protocol(PLDownloadProvider)];
    [self addCreator:^{ return [PLGDriveManager sharedManager]; } underProtocol:@protocol(PLDownloadProvider)];
    [self addCreator:^{ return [PLOneDriveManager sharedManager]; } underProtocol:@protocol(PLDownloadProvider)];
    
    [self registerInstance:[PLNowPlayingManager new] underProtocol:@protocol(PLNowPlayingManager)];
    [self registerInstance:[PLFileSharingManager new] underProtocol:@protocol(PLFileSharingManager)];
    [self registerInstance:[PLNetworkManager new] underProtocol:@protocol(PLNetworkManager)];
    [self registerInstance:[PLPodcastsManager new] underProtocol:@protocol(PLPodcastsManager)];
    [self registerInstance:[PLDataAccess new] underProtocol:@protocol(PLDataAccess)];
}

@end
