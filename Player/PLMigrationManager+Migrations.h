#import "PLMigrationManager.h"

@interface PLMigrationManager (Migrations)

+ (void)preMigrateWithInfo:(NSMutableDictionary *)migrationInfo;
+ (void)postMigrateWithInfo:(NSDictionary *)migrationInfo;

@end
