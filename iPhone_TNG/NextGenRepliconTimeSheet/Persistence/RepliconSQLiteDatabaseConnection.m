
#import "RepliconSQLiteDatabaseConnection.h"
#import "AppProperties.h"
#import <Blindside/Blindside.h>
#import "QueryStringBuilder.h"
#import "InsertQuery.h"
#import "ApplicationVersionValidator.h"
#import <repliconkit/repliconkit.h>
#import "InjectorKeys.h"
#import "AppDelegate.h"
#import "SQLiteDB.h"

static NSString *const newerVersion = @"1.0.73.0";
static NSString *const userdetailsTable = @"userDetails";
static NSString *const versionInfoTable = @"version_info";



@interface RepliconSQLiteDatabaseConnection ()

@property (nonatomic) FMDatabase *database;
@property (weak, nonatomic) id<BSInjector> injector;


@end

@implementation RepliconSQLiteDatabaseConnection

- (void)openOrCreateDatabase:(NSString *)databaseName
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *databaseNames = [NSString stringWithFormat:@"%@.sqlite", databaseName];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:databaseNames];
    BOOL isDatabasePresent = [[NSFileManager defaultManager] fileExistsAtPath:databasePath];
    [self checkAndEnableRememberMeOptionForFirstApplicationInstallIfDatabaseIsPresentAtPath:databasePath];

    NSArray *userDetailsBeforeMigration  = [self userDetailsBeforeMigrationFromDatabaseWithPath:databasePath];
    NSArray *versionDetailsBeforeMigration = [self versionDetailsBeforeMigrationFromDatabaseWithPath:databasePath];


    NSString *olderVersion = [self getVersionDetailsFromDatabaseWithPath:databasePath];
    BOOL needsMigration = [self checkWhetherDatabaseNeedsMigrationFromVersion:olderVersion
                                                                    toVersion:newerVersion];
    CLS_LOG(@"-------older version - %@---------",olderVersion);
    CLS_LOG(@"-------newer version - %@---------",newerVersion);
    
    if (needsMigration && isDatabasePresent) {
        CLS_LOG(@"-------database migration happening---------");
        NSUserDefaults *userDefaults = [self.injector getInstance:InjectorKeyStandardUserDefaults];
        BOOL isLoginSuccessfull=[userDefaults boolForKey:@"isSuccessLogin"];
        BOOL isSupportSAML = false;
        if (versionDetailsBeforeMigration.count > 0) {
            NSDictionary *versionInfo = [NSDictionary dictionaryWithDictionary:versionDetailsBeforeMigration.firstObject];
            if (versionInfo != nil && versionInfo != (id)[NSNull null]) {
                id samlValue = [versionInfo objectForKey:@"isSupportSAML"];
                if (samlValue != nil && samlValue != (id) [NSNull null])
                {
                    isSupportSAML = [[versionInfo objectForKey:@"isSupportSAML"] boolValue];
                }

            }
        }
        if(isLoginSuccessfull && isSupportSAML)
        {
            AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
            [appDelegate loadCookie];
        }

        [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
        isDatabasePresent = NO;
    }
    if (!isDatabasePresent)
    {
        [self migrateDatabaseInPath:databasePath withBundleWithName:@"LegacySQLiteMigrations"];
    }

    [self migrateDatabaseInPath:databasePath withBundleWithName:@"RepliconSQLiteMigrations"];

    ApplicationVersionValidator *versionValidator = [self.injector getInstance:[ApplicationVersionValidator class]];
    BOOL needsUpdate = [versionValidator needsUpdateForUserDetailsAndVersionUpdateFromOlderVersion:olderVersion];
    if (needsUpdate) {
        NSBundle *mainBundle = [self.injector getInstance:InjectorKeyMainBundle];
        NSString *version = [[mainBundle infoDictionary] objectForKey:@"CFBundleVersion"];
        [self updateVersionInfoAfterMigrationWithVersion:version
                                            olderDetails:versionDetailsBeforeMigration];
        [self updateUserDetailsAfterMigrationToEnableAutoLoginWithDetails:userDetailsBeforeMigration];

    }

    SQLiteDB *myDB = [SQLiteDB getInstance];
    [myDB closeDatabase:databaseNames];
    [myDB openDatabaseWithName:databaseNames atPath:databasePath];
    [myDB executeQuery:@"PRAGMA foreign_keys=ON"];

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

-(BOOL)checkWhetherDatabaseNeedsMigrationFromVersion:(NSString *)olderVersion toVersion:(NSString *)newVersion{
    ApplicationVersionValidator *versionValidator = [self.injector getInstance:[ApplicationVersionValidator class]];
    if (olderVersion == nil||[versionValidator isVersion:olderVersion olderThanVersion:newVersion])
    {
        return YES;
    }
    return NO;
}

#pragma mark - Older Database Query Methods

-(NSArray *)userDetailsBeforeMigrationFromDatabaseWithPath:(NSString *)databasePath{

    NSString *queryString = @"SELECT * FROM userDetails";
    FMDatabase *olderDatabase = [self openDatabaseInPath:databasePath];
    FMResultSet *resultSet = [olderDatabase executeQuery:queryString];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    while ([resultSet next]) {
        [results addObject:[resultSet resultDictionary]];
    }
    return results;
}

-(NSArray *)versionDetailsBeforeMigrationFromDatabaseWithPath:(NSString *)databasePath{

    NSString *queryString = @"SELECT * FROM version_info";
    FMDatabase *olderDatabase = [self openDatabaseInPath:databasePath];
    FMResultSet *resultSet = [olderDatabase executeQuery:queryString];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    while ([resultSet next]) {
        [results addObject:[resultSet resultDictionary]];
    }
    return results;
}

-(NSString *)getVersionDetailsFromDatabaseWithPath:(NSString *)databasePath{

    FMDatabase *olderDatabase = [self openDatabaseInPath:databasePath];
    NSString *query = @"SELECT * FROM version_info";
    FMResultSet *resultSet = [olderDatabase executeQuery:query];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    while ([resultSet next]) {
        [results addObject:[resultSet resultDictionary]];
    }
    NSString *version;
    if (results.count>0) {
        NSDictionary *dictionary = results.firstObject;
        version = (results.count > 0) ? [dictionary objectForKey:@"version_number"]:nil;
    }
    return version;
}

#pragma mark - Migration Database Update Methods

-(void)updateUserDetailsAfterMigrationToEnableAutoLoginWithDetails:(NSArray *)userDetails
{
    QueryStringBuilder *queryStringBuilder = [self.injector getInstance:[QueryStringBuilder class]];
    InsertQuery *query = [queryStringBuilder insertQueryForTable:userdetailsTable args:userDetails.firstObject];
    [self executeUpdate:[queryStringBuilder deleteStatementForTable:userdetailsTable]];
    [self executeUpdate:query.query args:query.valueArguments];
}

-(void)updateVersionInfoAfterMigrationWithVersion:(NSString *)newVersion olderDetails:(NSArray *)olderDetails
{
    NSMutableDictionary *versionInfoDictionary = [NSMutableDictionary dictionaryWithDictionary:olderDetails.firstObject];
    [versionInfoDictionary setObject:newVersion forKey:@"version_number"];
    QueryStringBuilder *queryStringBuilder = [self.injector getInstance:[QueryStringBuilder class]];
    InsertQuery *query = [queryStringBuilder insertQueryForTable:versionInfoTable args:versionInfoDictionary];

    [self executeUpdate:[queryStringBuilder deleteStatementForTable:versionInfoTable]];
    [self executeUpdate:query.query args:query.valueArguments];
}

-(FMDatabase *)openDatabaseInPath:(NSString *)databasePath
{
    FMDatabase *database = [[FMDatabase alloc] initWithPath:databasePath];
    [database open];
    if (_ENCRYPT_DB){
        NSString *databasePassword = [[AppProperties getInstance] getAppPropertyFor: @"databasePassword"];
        [database setKey:databasePassword];
    }
    [database executeQuery:@"PRAGMA foreign_keys=ON"];
    return database;

}

-(void)migrateDatabaseInPath:(NSString *)databasePath withBundleWithName:(NSString *)migrationBundleName
{
    self.database = [self openDatabaseInPath:databasePath];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:migrationBundleName ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSDictionary *attributes = @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication};
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] setAttributes:attributes
                                                    ofItemAtPath:databasePath
                                                           error:&error];
    NSString *fileProtectionAttributeErrorString = (!success) ? [NSString stringWithFormat:@"File protection failed for replicon.sqlite: %@", error] : [NSString stringWithFormat:@"File protection successful for replicon.sqlite"];
    [LogUtil logLoggingInfo:fileProtectionAttributeErrorString forLogLevel:LoggerCocoaLumberjack];
    
    FMDBMigrationManager *migrationManager = [FMDBMigrationManager managerWithDatabase:self.database migrationsBundle:bundle];
    if (migrationManager.pendingVersions.count > 0) {
        [migrationManager createMigrationsTable:nil];
        [migrationManager migrateDatabaseToVersion:UINT64_MAX progress:nil error:nil];
    }

}

-(void)checkAndEnableRememberMeOptionForFirstApplicationInstallIfDatabaseIsPresentAtPath:(NSString *)databasePath{

    NSUserDefaults *userDefaults = [self.injector getInstance:InjectorKeyStandardUserDefaults];
    BOOL isDatabasePresent = [[NSFileManager defaultManager] fileExistsAtPath:databasePath];
    if (!isDatabasePresent) {
        //For the Fresh install of the app, Remeber me option by default should be enabled
        [userDefaults setBool:YES forKey:@"RememberMe"];
        [userDefaults synchronize];
    }
}

@end
