#import <Foundation/Foundation.h>

@class PLDropboxItemCellViewModel, RACSignal, PLPathAssetSet;

@interface PLDropboxItemsViewModel : NSObject

/**
 Delivers a set of all the selected assets.
 */
- (PLPathAssetSet *)selection;

@property (nonatomic, strong, readonly) NSString *title;

/**
 * Returns YES if the corresponding view has been dismissed, NO otherwise.
 */
@property (nonatomic, assign) BOOL dismissed;

/**
 Returns YES if the items are currently being loaded
 */
@property (nonatomic, assign) BOOL loading;

- (NSUInteger)cellsCount;
- (BOOL)useEmptyCell;
- (PLDropboxItemCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath;
- (void)toggleSelectAt:(NSIndexPath *)indexPath;

- (RACSignal *)navigationSignal;

@end
