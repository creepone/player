#import <Foundation/Foundation.h>

@class PLMediaItemTrackGroup, PLTrackGroupCellViewModel, PLTrackCellViewModel;

@interface PLTracksViewModel : NSObject

- (instancetype)initWithTrackGroup:(PLMediaItemTrackGroup *)trackGroup selection:(NSMutableArray *)selection;

/**
* Returns YES if the view model has loaded the tracks and is ready to use, NO otherwise.
*/
@property (nonatomic, assign, readonly) BOOL ready;

@property (nonatomic, strong, readonly) NSString *title;

- (NSUInteger)tracksCount;
- (PLTrackGroupCellViewModel *)groupCellViewModel;
- (PLTrackCellViewModel *)trackCellViewModelAtIndex:(NSUInteger)index;

- (void)toggleSelectionGroup;
- (void)toggleSelectionTrackAtIndex:(NSUInteger)index;

@end