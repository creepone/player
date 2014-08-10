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

@end
