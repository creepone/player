#import <Foundation/Foundation.h>
#import "PLMediaItemTrackGroup.h"

@class PLTrackGroupCellViewModel, PLTracksViewModel;

@interface PLTrackGroupsViewModel : NSObject

- (instancetype)initWithTrackGroupType:(PLTrackGroupType)trackGroupType selection:(NSMutableArray *)selection;

/**
* Returns YES if the view model has loaded the groups and is ready to use, NO otherwise.
*/
@property (nonatomic, assign, readonly) BOOL ready;

- (NSUInteger)groupsCount;
- (PLTrackGroupCellViewModel *)groupCellViewModelAt:(NSIndexPath *)indexPath;
- (PLTracksViewModel *)tracksViewModelAt:(NSIndexPath *)indexPath;

@property (nonatomic, strong, readonly) NSString *title;

@end