#import <CoreData/CoreData.h>

@interface PLFetchedResultsControllerDelegate : NSObject <NSFetchedResultsControllerDelegate>

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

/**
* Returns a signal that delivers an NSArray of PLFetchedResultsUpdate objects each time
* the underlying collection of fetched results has been modified.
*/
- (RACSignal *)updatesSignal;

@end