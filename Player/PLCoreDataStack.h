#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PLCoreDataStack : NSObject

/**
 Using the given persistent store URL and model creates a new core data stack ready to be used by the application.
 */
+ (PLCoreDataStack *)coreDataStackWithStoreURL:(NSURL *)storeURL andModel:(NSManagedObjectModel *)model error:(NSError **)error;

/**
 Returns the managed object context for the application.
 */
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/**
 Returns the managed object model for the application.
 */
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;

/**
 Returns the persistent store coordinator for the application.
 */
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


/**
 Returns a new managed object context based on the same model and coordinator as this core data stack.
 */
- (NSManagedObjectContext *)newContext;

@end
