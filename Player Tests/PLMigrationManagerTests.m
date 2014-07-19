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
    NSString *storePath = [PLMigrationManager dataStorePathVersion:PLCurrentDataStoreVersion];
    [PLTestUtils removeFileAtPath:storePath];
}

- (void)tearDown
{
    for(int version = 1; version <= PLCurrentDataStoreVersion; version++) {
        NSString *storePath = [PLMigrationManager dataStorePathVersion:version];
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
        XCTAssert([playlist.name isEqualToString:@"Default"]);
        XCTAssert([playlist.position isEqualToNumber:@(0)]);
        
        [self notify:kXCTUnitWaitStatusSuccess];

    } error:self.onError];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:10];
}

@end
