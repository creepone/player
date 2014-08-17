#import <XCTest/XCTest.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLTestUtils.h"
#import "PLTestCase.h"

#import "PLMigrationManager.h"
#import "PLCoreDataStack.h"
#import "PLDefaultsManager.h"
#import "PLDataAccess.h"

@interface PLMigrationManagerTests : PLTestCase

@end

@implementation PLMigrationManagerTests

- (void)setUp
{
    [super setUp];
    
    for (NSString *storePath in [PLMigrationManager dataStorePathsVersion:PLCurrentDataStoreVersion])
        [PLTestUtils removeFileAtPath:storePath];
}

- (void)tearDown
{
    [super tearDown];
    
    for(int version = 1; version <= PLCurrentDataStoreVersion; version++) {
        for (NSString *storePath in [PLMigrationManager dataStorePathsVersion:version])
            [PLTestUtils removeFileAtPath:storePath];
    }
}


- (void)testNewStoreCreation
{
    [self prepare];
    
    [[PLDefaultsManager sharedManager] setDataStoreVersion:0];
    
    [[PLMigrationManager coreDataStack] subscribeNext:^(PLCoreDataStack *dataStack) {
        XCTAssertNotNil(dataStack);
        
        NSManagedObjectContext *context = dataStack.managedObjectContext;
        PLDataAccess *dataAccess = [[PLDataAccess alloc] initWithContext:context];
        
        PLPlaylist *playlist = [dataAccess selectedPlaylist];
        XCTAssertEqualObjects(playlist.name, @"Baladeur");
        XCTAssertEqualObjects(playlist.position, @(0));
        
        [self notify:kXCTUnitWaitStatusSuccess];

    } error:self.onError];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:10];
}

- (void)testMigrationFromVersion2
{
    [self prepare];
    [self setupDataForVersion2];
    
    [[PLDefaultsManager sharedManager] setDataStoreVersion:2];
    
    [[PLMigrationManager coreDataStack] subscribeNext:^(PLCoreDataStack *dataStack) {
        
        NSManagedObjectContext *context = dataStack.managedObjectContext;
        PLDataAccess *dataAccess = [[PLDataAccess alloc] initWithContext:context];
        
        NSArray *playlists = [dataAccess allEntities:[PLPlaylist entityName]];
        XCTAssertEqual([playlists count], 3);
        
        playlists = [playlists sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
        
        PLPlaylist *playlistA = playlists[0];
        XCTAssertEqualObjects(@"A playlist", playlistA.name);
        XCTAssertEqualObjects(@(21), playlistA.position);
        
        PLPlaylist *playlistB = playlists[1];
        XCTAssertEqualObjects(@"B playlist", playlistB.name);
        XCTAssertEqualObjects(@(13), playlistB.position);
        
        PLPlaylist *playlistC = playlists[2];
        XCTAssertEqualObjects(@"C playlist", playlistC.name);
        XCTAssertEqualObjects(@(42), playlistC.position);
        
        [self notify:kXCTUnitWaitStatusSuccess];
        
    } error:self.onError];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:10];
}

#pragma mark -- Helper methods

- (NSManagedObjectContext *)setupContextVersion:(int)version
{
    NSError *error = nil;
    
    NSManagedObjectModel *model = [PLMigrationManager modelVersion:version];
    NSString *storePath = [PLMigrationManager dataStorePathVersion:version];
    
    [PLTestUtils removeFileAtPath:storePath];
    
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    
    XCTAssertNil(error, @"Persistent coordinator could not be created");
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coordinator];
    
    return context;
}

- (void)setupDataForVersion2
{
    NSManagedObjectContext *context = [self setupContextVersion:2];
    
    NSError *error = nil;
    
    NSManagedObject *playlistB = [NSEntityDescription insertNewObjectForEntityForName:@"PLPlaylist" inManagedObjectContext:context];
    [playlistB setValue:@"B playlist" forKey:@"name"];
    [playlistB setValue:@(13) forKey:@"position"];
    
    NSManagedObject *playlistA = [NSEntityDescription insertNewObjectForEntityForName:@"PLPlaylist" inManagedObjectContext:context];
    [playlistA setValue:@"A playlist" forKey:@"name"];
    [playlistA setValue:@(21) forKey:@"position"];
    
    NSManagedObject *playlistC = [NSEntityDescription insertNewObjectForEntityForName:@"PLPlaylist" inManagedObjectContext:context];
    [playlistC setValue:@"C playlist" forKey:@"name"];
    [playlistC setValue:@(42) forKey:@"position"];
    
    [context save:&error];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // set B as the selected playlist
    [userDefaults setURL:[[playlistB objectID] URIRepresentation] forKey:@"SelectedPlaylist"];
    
    [userDefaults synchronize];
    
    XCTAssertNil(error, @"Changes done in the context could not be saved");
}

@end
