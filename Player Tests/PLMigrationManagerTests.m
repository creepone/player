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
    for (NSString *storePath in [PLMigrationManager dataStorePathsVersion:PLCurrentDataStoreVersion])
        [PLTestUtils removeFileAtPath:storePath];
}

- (void)tearDown
{
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
        XCTAssertEqualObjects(playlist.name, @"Default");
        XCTAssertEqualObjects(playlist.position, @(0));
        
        [self notify:kXCTUnitWaitStatusSuccess];

    } error:self.onError];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:10];
}

- (void)testMigrationFromVersion1
{
    [self prepare];
    [self setupDataForVersion1];
    
    [[PLDefaultsManager sharedManager] setDataStoreVersion:1];
    
    [[PLMigrationManager coreDataStack] subscribeNext:^(PLCoreDataStack *dataStack) {
       
        NSManagedObjectContext *context = dataStack.managedObjectContext;
        PLDataAccess *dataAccess = [[PLDataAccess alloc] initWithContext:context];

        NSArray *tracks = [dataAccess allEntities:[PLTrack entityName]];
        XCTAssertEqual([tracks count], 1);
        
        PLTrack *track = tracks[0];
        XCTAssertEqualObjects(track.artist, @"testArtist");
        XCTAssertEqual(track.downloadStatus, 2);
        XCTAssertEqualObjects(track.downloadURL, @"testDownloadURL");
        XCTAssertEqual(track.duration, 123);
        XCTAssertEqualObjects(track.filePath, @"/testFileURL");
        XCTAssertEqual(track.persistentId, 567);
        XCTAssertEqual(track.played, YES);
        XCTAssertEqualObjects(track.title, @"testTitle");
        
        NSArray *playlists = [dataAccess allEntities:[PLPlaylist entityName] sortedBy:@"name"]; // todo: use constant for column name
        XCTAssertEqual([playlists count], 2);
        
        PLPlaylist *playlist1 = playlists[0];
        XCTAssert([playlist1.uuid length] > 0);
        XCTAssertEqualObjects(playlist1.name, @"playlist1");
        XCTAssertEqualObjects(playlist1.position, @(20));
        XCTAssertEqualObjects([dataAccess bookmarkPlaylist], playlist1);
        
        PLPlaylist *playlist2 = playlists[1];
        XCTAssert([playlist2.uuid length] > 0);
        XCTAssertEqualObjects(playlist2.name, @"playlist2");
        XCTAssertEqualObjects(playlist2.position, @(11));
        XCTAssertEqualObjects([dataAccess selectedPlaylist], playlist2);
        
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
        
        NSArray *tracks = [dataAccess allEntities:[PLTrack entityName]];
        XCTAssertEqual([tracks count], 1);
        
        PLTrack *track = tracks[0];
        XCTAssertEqualObjects(track.artist, @"testArtist");
        XCTAssertEqual(track.downloadStatus, 2);
        XCTAssertEqualObjects(track.downloadURL, @"testDownloadURL");
        XCTAssertEqual(track.duration, 123);
        XCTAssertEqualObjects(track.filePath, @"/testFilePath");
        XCTAssertEqual(track.persistentId, 567);
        XCTAssertEqual(track.played, YES);
        XCTAssertEqualObjects(track.title, @"testTitle");
        
        NSArray *playlists = [dataAccess allEntities:[PLPlaylist entityName] sortedBy:@"name"]; // todo: use constant for column name
        XCTAssertEqual([playlists count], 2);
        
        PLPlaylist *playlist1 = playlists[0];
        XCTAssert([playlist1.uuid length] > 0);
        XCTAssertEqualObjects(playlist1.name, @"playlist1");
        XCTAssertEqualObjects(playlist1.position, @(20));
        XCTAssertEqualObjects([dataAccess bookmarkPlaylist], playlist1);
        
        PLPlaylist *playlist2 = playlists[1];
        XCTAssert([playlist2.uuid length] > 0);
        XCTAssertEqualObjects(playlist2.name, @"playlist2");
        XCTAssertEqualObjects(playlist2.position, @(11));
        XCTAssertEqualObjects([dataAccess selectedPlaylist], playlist2);
        
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

#pragma mark -- Version Data Setups

- (void)setupDataForVersion1
{
    NSManagedObjectContext *context = [self setupContextVersion:1];
    
    NSError *error = nil;
    
    NSManagedObject *track = [NSEntityDescription insertNewObjectForEntityForName:@"PLTrack" inManagedObjectContext:context];
    [track setValue:@"testArtist" forKey:@"artist"];
    [track setValue:@(2) forKey:@"downloadStatus"];
    [track setValue:@"testDownloadURL" forKey:@"downloadURL"];
    [track setValue:@(123) forKey:@"duration"];
    [track setValue:@"/testFileURL" forKey:@"fileURL"];
    [track setValue:@(567) forKey:@"persistentId"];
    [track setValue:@(YES) forKey:@"played"];
    [track setValue:@"testTitle" forKey:@"title"];
    
    NSManagedObject *playlist1 = [NSEntityDescription insertNewObjectForEntityForName:@"PLPlaylist" inManagedObjectContext:context];
    [playlist1 setValue:@"playlist1" forKey:@"name"];
    [playlist1 setValue:@(20) forKey:@"position"];

    NSManagedObject *playlist2 = [NSEntityDescription insertNewObjectForEntityForName:@"PLPlaylist" inManagedObjectContext:context];
    [playlist2 setValue:@"playlist2" forKey:@"name"];
    [playlist2 setValue:@(11) forKey:@"position"];
    
    [context save:&error];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // set as bookmarks playlist
    [userDefaults setURL:[[playlist1 objectID] URIRepresentation] forKey:@"BookmarkPlaylist"];
    
    // set as selected playlist
    [userDefaults setURL:[[playlist2 objectID] URIRepresentation] forKey:@"SelectedPlaylist"];

    [userDefaults synchronize];
    
    XCTAssertNil(error, @"Changes done in the context could not be saved");
}

- (void)setupDataForVersion2
{
    NSManagedObjectContext *context = [self setupContextVersion:2];
    
    NSError *error = nil;
    
    NSManagedObject *track = [NSEntityDescription insertNewObjectForEntityForName:@"PLTrack" inManagedObjectContext:context];
    [track setValue:@"testArtist" forKey:@"artist"];
    [track setValue:@(2) forKey:@"downloadStatus"];
    [track setValue:@"testDownloadURL" forKey:@"downloadURL"];
    [track setValue:@(123) forKey:@"duration"];
    [track setValue:@"/testFilePath" forKey:@"filePath"];
    [track setValue:@(567) forKey:@"persistentId"];
    [track setValue:@(YES) forKey:@"played"];
    [track setValue:@"testTitle" forKey:@"title"];
    
    NSManagedObject *playlist1 = [NSEntityDescription insertNewObjectForEntityForName:@"PLPlaylist" inManagedObjectContext:context];
    [playlist1 setValue:@"playlist1" forKey:@"name"];
    [playlist1 setValue:@(20) forKey:@"position"];
    
    NSManagedObject *playlist2 = [NSEntityDescription insertNewObjectForEntityForName:@"PLPlaylist" inManagedObjectContext:context];
    [playlist2 setValue:@"playlist2" forKey:@"name"];
    [playlist2 setValue:@(11) forKey:@"position"];
    
    [context save:&error];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // set as bookmarks playlist
    [userDefaults setURL:[[playlist1 objectID] URIRepresentation] forKey:@"BookmarkPlaylist"];
    
    // set as selected playlist
    [userDefaults setURL:[[playlist2 objectID] URIRepresentation] forKey:@"SelectedPlaylist"];
    
    [userDefaults synchronize];
    
    XCTAssertNil(error, @"Changes done in the context could not be saved");
}

@end
