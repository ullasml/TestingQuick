#import "SQLiteDatabaseConnection.h"
#import <repliconkit/repliconkit.h>

@interface SQLiteDatabaseConnection ()

@property (nonatomic) FMDatabase *database;

@end

@implementation SQLiteDatabaseConnection

- (void)openOrCreateDatabase:(NSString *)databaseName
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *databaseNames = [NSString stringWithFormat:@"%@.sqlite", databaseName];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:databaseNames];
    self.database = [[FMDatabase alloc] initWithPath:databasePath];
    NSDictionary *attributes = @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication};
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] setAttributes:attributes
                                                    ofItemAtPath:databasePath
                                                           error:&error];
    NSString *fileProtectionAttributeErrorString = (!success) ? [NSString stringWithFormat:@"File protection failed for astro.sqlite: %@", error] : [NSString stringWithFormat:@"File protection successful for astro.sqlite"];
    [LogUtil logLoggingInfo:fileProtectionAttributeErrorString forLogLevel:LoggerCocoaLumberjack];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"AstroSQLiteMigrations" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    FMDBMigrationManager *migrationManager = [FMDBMigrationManager managerWithDatabaseAtPath:databasePath migrationsBundle:bundle];

    if (migrationManager.pendingVersions.count > 0) {
        [migrationManager createMigrationsTable:nil];
        [migrationManager migrateDatabaseToVersion:UINT64_MAX progress:nil error:nil];
    }


    [self.database open];
}

- (void)executeUpdate:(NSString *)updateQuery
{
    [self.database executeUpdate:updateQuery];
}

- (void)executeUpdate:(NSString *)updateQuery args:(NSArray *)args
{
    [self.database executeUpdate:updateQuery withArgumentsInArray:args];
}

- (NSArray *)executeQuery:(NSString *)updateQuery
{
    FMResultSet *resultSet = [self.database executeQuery:updateQuery];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    while ([resultSet next]) {
        [results addObject:[resultSet resultDictionary]];
    }

    return results;
}

@end
