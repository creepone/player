#import <XCTest/XCTest.h>
#import "PLTestUtils.h"

@implementation PLTestUtils

+ (void)removeFileAtPath:(NSString *)filePath
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if([fileManager fileExistsAtPath:filePath])
        [fileManager removeItemAtPath:filePath error:nil];
}

@end
