#import "UITableView+PLExtensions.h"
#import "PLFetchedResultsUpdate.h"

@implementation UITableView (PLExtensions)

- (void)pl_applyUpdates:(NSArray *)updates
{
    [self beginUpdates];

    for (PLFetchedResultsUpdate *update in updates)
    {
        switch(update.changeType)
        {
            case NSFetchedResultsChangeUpdate:
            {
                [self reloadRowsAtIndexPaths:@[update.indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
            case NSFetchedResultsChangeInsert:
            {
                [self insertRowsAtIndexPaths:@[update.targetIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
            case NSFetchedResultsChangeMove:
            {
                [self moveRowAtIndexPath:update.indexPath toIndexPath:update.targetIndexPath];
                break;
            }
            case NSFetchedResultsChangeDelete:
            {
                [self deleteRowsAtIndexPaths:@[update.indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
        }
    }

    [self endUpdates];
}

@end