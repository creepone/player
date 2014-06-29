#import <CoreData/CoreData.h>

@interface PLFetchedResultsUpdate : NSObject

@property (nonatomic, assign) NSFetchedResultsChangeType changeType;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSIndexPath *targetIndexPath;

@end