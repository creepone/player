#import <Foundation/Foundation.h>

@protocol PLCloudManager;
@class PLCloudItemCellViewModel, RACSignal, PLPathAssetSet;

@interface PLCloudItemsViewModel : NSObject

- (instancetype)initWithCloudManager:(id <PLCloudManager>)cloudManager;

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
- (NSString *)cellIdentifier;
- (PLCloudItemCellViewModel *)cellViewModelAt:(NSIndexPath *)indexPath;
- (void)toggleSelectAt:(NSIndexPath *)indexPath;

- (RACSignal *)navigationSignal;

@end
