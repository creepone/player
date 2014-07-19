#import <Foundation/Foundation.h>

@class PLFileSharingCellViewModel;

@interface PLFileSharingViewModel : NSObject

/**
 Delivers an array of all the selected PLFileSharingItem-s.
 */
- (NSArray *)selection;

/**
 * Returns YES if the corresponding view has been dismissed, NO otherwise.
 */
@property (nonatomic, assign) BOOL dismissed;

/**
 Returns YES if the items are currently being loaded
 */
@property (nonatomic, assign) BOOL loading;

- (NSUInteger)cellsCount;
- (NSString *)cellIdentifier;
- (CGFloat)cellHeight;
- (PLFileSharingCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath;
- (void)toggleSelectAt:(NSIndexPath *)indexPath;

@end
