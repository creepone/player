#import <Foundation/Foundation.h>

@interface PLDefaultsManager : NSObject

+ (PLDefaultsManager *)sharedManager;

/**
 Version of the data store used to ensure that it is compatible with the model and was
 initialized with a default set of objects
 */
@property (nonatomic) NSInteger dataStoreVersion;

@property (nonatomic) NSURL *selectedPlaylist;
@property (nonatomic) NSURL *bookmarkPlaylist;
@property (nonatomic) double playbackRate;
@property (nonatomic) double goBackTime;
@property (nonatomic) BOOL mirrorTracks;
@property (nonatomic) BOOL removeUnusedTracks;

/**
 Registers default values for all the settings. To be called on application startup.
 */
+ (void)registerDefaults;

@end
