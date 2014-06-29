#import <Foundation/Foundation.h>
#import "PLMediaItemTrackGroup.h"

@class PLTrackGroupsViewModel;

@interface PLMusicLibraryViewModel : NSObject

/**
* Returns YES if the corresponding view has been dismissed, NO otherwise.
*/
@property (nonatomic, assign) BOOL dismissed;

- (NSArray *)selection;
- (PLTrackGroupsViewModel *)viewModelForTrackGroupType:(PLTrackGroupType)trackGroupType;

@end