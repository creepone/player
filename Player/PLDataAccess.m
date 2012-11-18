//
//  DataAccess.m
//  EnergyTracker
//
//  Created by Tomas Vana on 3/17/12.
//  Copyright (c) 2012 iOS Apps Austria. All rights reserved.
//

#import "PLDataAccess.h"
#import "PLCoreDataStack.h"
#import "PLAppDelegate.h"

@interface PLDataAccess() {
    NSManagedObjectContext *_context;
}
@end

@implementation PLDataAccess

- (id)init {
    return [self initWithNewContext:NO];
}

- (id)initWithNewContext:(BOOL)useNewContext {
    PLAppDelegate *appDelegate = (PLAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = useNewContext ? [appDelegate.coreDataStack newContext] : nil;
    return [self initWithContext:context];
}

- (id)initWithContext:(NSManagedObjectContext *)context {
    self = [super init];
    if (self) {
        _context = context;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesIntoContext:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}


+ (PLDataAccess *)sharedDataAccess {
    static dispatch_once_t once;
    static PLDataAccess *sharedDataAccess;
    dispatch_once(&once, ^ { sharedDataAccess = [[self alloc] init]; });
    return sharedDataAccess;
}

- (NSManagedObjectContext *)context {
    if(_context == nil) {
        PLAppDelegate *appDelegate = (PLAppDelegate *)[[UIApplication sharedApplication] delegate];
        return appDelegate.coreDataStack.managedObjectContext;
    }
    else 
        return _context;
}

- (void)mergeChangesIntoContext:(NSNotification *)notification {
    if (notification.object != self.context) {
        [self.context mergeChangesFromContextDidSaveNotification:notification];
    }
}


- (void)deleteObject:(NSManagedObject *)object {
    [self.context deleteObject:object];
}

- (BOOL)deleteObject:(NSManagedObject *)object error:(NSError **)error {
    [self.context deleteObject:object];
    return [self saveChanges:error];
}

- (BOOL)saveChanges:(NSError **)error {
	return [self.context save:error];
}

- (void)rollbackChanges {
    [self.context rollback];
}

- (void)processChanges {
    [self.context processPendingChanges];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
