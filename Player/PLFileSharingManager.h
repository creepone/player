#import <Foundation/Foundation.h>

@class RACSignal;

@protocol PLFileSharingManager <NSObject>

/**
 Resolves to an array of PLFileSharingItem-s that can be imported at the moment.
 */
- (RACSignal *)allImportableItems;

/**
 Imports the given set of PLFileSharingItem-s, then completes.
 */
- (RACSignal *)importItems:(NSArray *)items;

@end

@interface PLFileSharingManager : NSObject <PLFileSharingManager>
@end
