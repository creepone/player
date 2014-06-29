#import <Foundation/Foundation.h>

@interface UITableView (PLExtensions)

/**
* Applies the given array of PLFetchedResultsUpdate-s to this table view.
*/
- (void)pl_applyUpdates:(NSArray *)updates;

@end