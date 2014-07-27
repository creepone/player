#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLFetchedResultsControllerDelegate.h"
#import "PLFetchedResultsUpdate.h"

@interface PLFetchedResultsControllerDelegate() {
    RACSubject *_updatesSubject;
    NSMutableArray *_updates;
}
@end

@implementation PLFetchedResultsControllerDelegate

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    self = [super init];
    if (self) {
        _updatesSubject = [RACSubject subject];
        fetchedResultsController.delegate = self;
    }
    return self;
}

- (RACSignal *)updatesSignal
{
    return _updatesSubject;
}

#pragma mark -- NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    _updates = [NSMutableArray array];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    PLFetchedResultsUpdate *update = [PLFetchedResultsUpdate new];
    update.changeType = type;
    update.indexPath = indexPath;
    update.targetIndexPath = newIndexPath;
    update.object = anObject;
    [_updates addObject:update];

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [_updatesSubject sendNext:_updates];
    _updates = nil;
}

@end