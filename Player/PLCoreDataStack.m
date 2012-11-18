#import "PLCoreDataStack.h"

@interface PLCoreDataStack() {
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

- (id)initWithContext:(NSManagedObjectContext *)context;

@end

@implementation PLCoreDataStack

- (id)initWithContext:(NSManagedObjectContext *)context {
    self = [super init];
    if(self) {
        _managedObjectContext = context;
        _persistentStoreCoordinator = [context persistentStoreCoordinator];
        _managedObjectModel = [_persistentStoreCoordinator managedObjectModel];
    }
    return self;
}

+ (PLCoreDataStack *)coreDataStackWithStoreURL:(NSURL *)storeURL andModel:(NSManagedObjectModel *)model error:(NSError **)error {
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:error]) {
        return nil;
    }
        
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coordinator];
            
    return [[PLCoreDataStack alloc] initWithContext:context];
}


- (NSManagedObjectContext *)managedObjectContext {
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)newContext {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:_persistentStoreCoordinator];
    return context;
}

@end
