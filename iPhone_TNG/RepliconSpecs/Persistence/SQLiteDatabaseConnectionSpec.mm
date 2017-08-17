#import <Cedar/Cedar.h>
#import "SQLiteDatabaseConnection.h"
#import <repliconkit/repliconkit.h>
#import "AppDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SQLiteDatabaseConnectionSpec)

describe(@"SQLiteDatabaseConnection", ^{
    __block SQLiteDatabaseConnection *subject;

    beforeEach(^{
        subject = [[SQLiteDatabaseConnection alloc] init];
    });

    describe(@"-openOrCreateDatabase:", ^{
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"test-db.sqlite"];

        beforeEach(^{
            [subject openOrCreateDatabase:@"test-db"];
        });

        it(@"should create a database", ^{
            [[NSFileManager defaultManager] fileExistsAtPath:databasePath] should be_truthy;
        });

        it(@"should connect to the specified database", ^{
            [subject.database databasePath] should equal(databasePath);
        });

        it(@"should set the attributes to database", ^{
            NSDictionary *attributes = @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication};
            NSError *error;
            [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:databasePath error:&error] should be_truthy;
        });

        describe(@"the migrations it will run", ^{
            __block FMDBMigrationManager *migrationManager;

            beforeEach(^{
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"AstroSQLiteMigrations" ofType:@"bundle"];
                NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                migrationManager = [FMDBMigrationManager managerWithDatabaseAtPath:databasePath migrationsBundle:bundle];
            });

            it(@"should have created a migrations table", ^{
                migrationManager.hasMigrationsTable should be_truthy;
            });

            it(@"should have at least one migration to run", ^{
                [[migrationManager migrations] count] should be_greater_than(0);
            });

            it(@"should run all of the migrations", ^{
                [migrationManager currentVersion] should be_greater_than_or_equal_to(1435597358);
            });
        });

        describe(@"executing CREATE, INSERT and SELECT statements", ^{
            NSString *createTableStatement = @"CREATE TABLE \"my_test_table\" (\"column_name\" VARCHAR)";
            NSString *insertStatement = @"INSERT INTO \"my_test_table\" (\"column_name\") VALUES ('test')";

            beforeEach(^{
                [subject executeUpdate:createTableStatement];
                [subject executeUpdate:insertStatement];
            });

            it(@"should execute the statement provided", ^{
                [subject executeQuery:@"select * from \"my_test_table\""] should equal(@[@{@"column_name": @"test"}]);
            });
        });

    });

    describe(@"migration scenario to merge data from outbox,failed", ^{
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *databaseName = @"test-db";
        NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",databaseName]];

        beforeEach(^{

            [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
            [[NSFileManager defaultManager] createFileAtPath:databasePath contents:nil attributes:nil];
            FMDatabase *database = [[FMDatabase alloc] initWithPath:databasePath];
            [database open];



            NSString *createFailedStatement = @"CREATE TABLE failed_punches (\"date\" DATE NOT NULL,\"break_type_name\" VARCHAR,\"break_type_uri\" VARCHAR,\"action_type\" VARCHAR NOT NULL,\"location_latitude\" FLOAT,\"location_longitude\" FLOAT,\"location_horizontal_accuracy\" FLOAT,\"address\" VARCHAR,\"user_uri\" VARCHAR NOT NULL,\"image_url\" VARCHAR,\"image\" BLOB,\"offline\" BOOL, \"activity_name\" VARCHAR, \"activity_uri\" VARCHAR, \"client_name\" VARCHAR, \"client_uri\" VARCHAR, \"project_name\" VARCHAR, \"project_uri\" VARCHAR, \"task_name\" VARCHAR, \"task_uri\" VARCHAR)";

            NSString *insertFailedStatement = @"INSERT INTO failed_punches VALUES ('24191016', null, null, 'urn:replicon:time-punch-action:in', '-33', '151', '5', null, 'urn:replicon-tenant:repliconiphone-2:user:603', null,null,1,  null,null, 'Advantage Technologies', 'urn:replicon-tenant:repliconiphone-2:client:2', 'Automated Reporting & Dashboards', 'urn:replicon-tenant:repliconiphone-2:project:21', 'Design', 'urn:replicon-tenant:repliconiphone-2:task:108')";

            NSString *createOutboxStatement = @"CREATE TABLE \"local_user_punches_outbox\" (\"date\" DATE NOT NULL,\"break_type_name\" VARCHAR,\"break_type_uri\" VARCHAR,\"action_type\" VARCHAR NOT NULL,\"location_latitude\" FLOAT,\"location_longitude\" FLOAT,\"location_horizontal_accuracy\" FLOAT,\"address\" VARCHAR,\"user_uri\" VARCHAR NOT NULL,\"image_url\" VARCHAR,\"image\" BLOB, \"request_id\" VARCHAR, \"offline\" BOOL, \"client_name\" VARCHAR, \"client_uri\" VARCHAR, \"project_name\" VARCHAR, \"project_uri\" VARCHAR, \"task_name\" VARCHAR, \"task_uri\" VARCHAR, \"activity_name\" VARCHAR, \"activity_uri\" VARCHAR)";

            NSString *insertOutboxStatement = @"INSERT INTO \"local_user_punches_outbox\" VALUES ('23191016', null, null, 'urn:replicon:time-punch-action:out', '22', '114', '5', null, 'urn:replicon-tenant:repliconiphone-2:user:603', null,null, '46212106-8046-42DF-BABF-EB62F86C9074', 1, null, null, null, null, null, null, null, null);";

            [database executeUpdate:createFailedStatement];
            [database executeUpdate:insertFailedStatement];
            [database executeUpdate:createOutboxStatement];
            [database executeUpdate:insertOutboxStatement];


            [subject openOrCreateDatabase:databaseName];
        });

        it(@"should create a database", ^{
            [[NSFileManager defaultManager] fileExistsAtPath:databasePath] should be_truthy;
        });

        it(@"should connect to the specified database", ^{
            [subject.database databasePath] should equal(databasePath);
        });

        describe(@"should handle newer migrations successfully", ^{
            __block FMDBMigrationManager *migrationManager;

            beforeEach(^{
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"AstroSQLiteMigrations" ofType:@"bundle"];

                NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                migrationManager = [FMDBMigrationManager managerWithDatabaseAtPath:databasePath migrationsBundle:bundle];
                [migrationManager createMigrationsTable:nil];
                [migrationManager migrateDatabaseToVersion:UINT64_MAX progress:nil error:nil];
            });

            it(@"should have created a migrations table", ^{
                migrationManager.hasMigrationsTable should be_truthy;

            });


            it(@"should execute the statement provided and return empty for failed punches table", ^{
                
                NSArray *storedFailedPunchesDetails = [subject executeQuery:@"select * from \"failed_punches\""];
                storedFailedPunchesDetails should be_empty;
            });

            it(@"should execute the statement provided and return empty for outbox punches table", ^{

                NSArray *storedOutboxPunchesDetails = [subject executeQuery:@"select * from \"local_user_punches_outbox\""];
                storedOutboxPunchesDetails should be_empty;
            });

        it(@"should execute the statement provided and return values for time punch table", ^{


            NSArray *requestIDDetails = [subject executeQuery:@"select request_id from \"time_punch\" where client_uri='urn:replicon-tenant:repliconiphone-2:client:2'"];
            NSString *request_id = requestIDDetails[0][@"request_id"];

            NSDictionary *firstRow = @{
                                              @"action_type" : @"urn:replicon:time-punch-action:out",
                                              @"activity_name" : [NSNull null],
                                              @"activity_uri" : [NSNull null],
                                              @"address" : [NSNull null],
                                              @"break_type_name" : [NSNull null],
                                              @"break_type_uri" : [NSNull null],
                                              @"client_name" : [NSNull null],
                                              @"client_uri" : [NSNull null],
                                              @"date" : @23191016,
                                              @"image" : [NSNull null],
                                              @"image_url" : [NSNull null],
                                              @"lastSyncTime" : [NSNull null],
                                              @"location_horizontal_accuracy" : @5,
                                              @"location_latitude" : @22,
                                              @"location_longitude" : @114,
                                              @"offline" : @1,
                                              @"project_name" : [NSNull null],
                                              @"project_uri" : [NSNull null],
                                              @"punchSyncStatus" : @0,
                                              @"request_id" : @"46212106-8046-42DF-BABF-EB62F86C9074",
                                              @"task_name" : [NSNull null],
                                              @"task_uri" : [NSNull null],
                                              @"uri" : [NSNull null],
                                              @"user_uri" : @"urn:replicon-tenant:repliconiphone-2:user:603",
                                              @"sync_with_server" : @0,
                                              @"is_time_entry_available" :@1,
                                              @"duration" : [NSNull null],
                                              @"nextPunchPairStatus" : [NSNull null],
                                              @"previousPunchPairStatus" : [NSNull null],
                                              @"nonActionedValidationsCount" : [NSNull null],
                                              @"sourceOfPunch" : [NSNull null],
                                              @"previousPunchActionType" : [NSNull null]
                                              };

            NSDictionary *secondRow = @{
                                        @"action_type" : @"urn:replicon:time-punch-action:in",
                                        @"activity_name" : [NSNull null],
                                        @"activity_uri" : [NSNull null],
                                        @"address" : [NSNull null],
                                        @"break_type_name" : [NSNull null],
                                        @"break_type_uri" : [NSNull null],
                                        @"client_name" : @"Advantage Technologies",
                                        @"client_uri" : @"urn:replicon-tenant:repliconiphone-2:client:2",
                                        @"date" : @24191016,
                                        @"image" : [NSNull null],
                                        @"image_url" : [NSNull null],
                                        @"lastSyncTime" : [NSNull null],
                                        @"location_horizontal_accuracy" : @5,
                                        @"location_latitude" : @-33,
                                        @"location_longitude" : @151,
                                        @"offline" : @1,
                                        @"project_name" : @"Automated Reporting & Dashboards",
                                        @"project_uri" : @"urn:replicon-tenant:repliconiphone-2:project:21",
                                        @"punchSyncStatus" : @0,
                                        @"request_id" : request_id,
                                        @"task_name" : @"Design",
                                        @"task_uri" : @"urn:replicon-tenant:repliconiphone-2:task:108",
                                        @"uri" : [NSNull null],
                                        @"user_uri" : @"urn:replicon-tenant:repliconiphone-2:user:603",
                                        @"sync_with_server" : @0,
                                        @"is_time_entry_available" :@1,
                                        @"duration" : [NSNull null],
                                        @"nextPunchPairStatus" : [NSNull null],
                                        @"previousPunchPairStatus" : [NSNull null],
                                        @"nonActionedValidationsCount" : [NSNull null],
                                        @"sourceOfPunch" : [NSNull null],
                                        @"previousPunchActionType" : [NSNull null]
                                        };

                NSArray *storedTimePunchesDetails = [subject executeQuery:@"select * from \"time_punch\""];
                storedTimePunchesDetails.count  should equal(2);
               storedTimePunchesDetails should equal(@[firstRow,secondRow]);

            });

            
        });

    });

    describe(@"triggers should be executed successfully", ^{
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *databaseName = @"test-db";
        NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",databaseName]];
       __block FMDBMigrationManager *migrationManager;
        beforeEach(^{

            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"AstroSQLiteMigrations" ofType:@"bundle"];

            NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
            migrationManager = [FMDBMigrationManager managerWithDatabaseAtPath:databasePath migrationsBundle:bundle];
            [migrationManager createMigrationsTable:nil];
            [migrationManager migrateDatabaseToVersion:UINT64_MAX progress:nil error:nil];

            FMDatabase *database = [[FMDatabase alloc] initWithPath:databasePath];
            [database open];


            NSString *insertTimePunchStatement = @"INSERT INTO \"time_punch\" VALUES ('234234', 'urn:replicon:time-punch-action:out', 'urn:replicon-tenant:repliconiphone-2:user:743', 'urn:replicon-tenant:repliconiphone-2:time-punch:bc32fc54-c824-4a3f-84ef-33f0fb3623cd', null, null, null, null, null, null, null, null, '35.7021', '139.7753', '5.0', 'Japan, 〒110-0006 Tōkyō-to, Taitō-ku, Akihabara, 1−8, ＳＴビル', 'https://na7.replicon.com/repliconiphone/services/BinaryObjectHandler.ashx?id=d0e8c3b4af514c8487cb36502ffd99e6', null, null, null, null, X'33', X'3c6e756c6c3e', '2ffcfe0d-f5e6-4554-9ced-def746629c6e',0, 1,  null, null, null, null, null, null);";


            NSString *insertUserPunchStatement = @"INSERT INTO \"user_punches\" VALUES ('12345', 'urn:replicon:time-punch-action:in', 'urn:replicon-tenant:repliconiphone-2:user:743', 'urn:replicon-tenant:repliconiphone-2:time-punch:247216c6-226b-4a03-b72d-a548eef12ed7', null, null, '-26.2041', '28.0473', '5.0', '107 Albertina Sisulu Rd, Johannesburg, 2000, South Africa', 'https://na7.replicon.com/repliconiphone/services/BinaryObjectHandler.ashx?id=d98f1574e6114449bc16057b2d36ffc5', null, null, null, null, null, null, null, null, X'33', X'3c6e756c6c3e', 'aad4a15e-48e2-41ad-b36f-22630cc71aa2', 'General Admin', 'urn:replicon-tenant:repliconiphone-2:activity:1');";

            NSString *insertTimePunchOEFStatement1 = @"INSERT INTO \"time_punch_oef_value\" VALUES ('2ffcfe0d-f5e6-4554-9ced-def746629c6e', 'urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f', 'urn:replicon:object-extension-definition-type:object-extension-type-numeric', 'dipta number', '34', '<null>', '<null>', '<null>', 'PunchIn', X'30',0);";

            NSString *insertTimePunchOEFStatement2 = @"INSERT INTO \"time_punch_oef_value\" VALUES ('aad4a15e-48e2-41ad-b36f-22630cc71aa2', 'urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f', 'urn:replicon:object-extension-definition-type:object-extension-type-numeric', 'dipta number', '34', '<null>', '<null>', '<null>', 'PunchIn', X'30',0);";

             NSString *insertTimePunchOEFStatement3 = @"INSERT INTO \"time_punch_oef_value\" VALUES ('some-dummy-uri', 'urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f', 'urn:replicon:object-extension-definition-type:object-extension-type-numeric', 'dipta number', '34', '<null>', '<null>', '<null>', 'PunchIn', X'30',1);";

            [database executeUpdate:insertTimePunchStatement];
            [database executeUpdate:insertUserPunchStatement];
            [database executeUpdate:insertTimePunchOEFStatement1];
            [database executeUpdate:insertTimePunchOEFStatement2];
            [database executeUpdate:insertTimePunchOEFStatement3];

            NSString *deleteTimePunch = @"DELETE FROM \"time_punch\" WHERE request_id='2ffcfe0d-f5e6-4554-9ced-def746629c6e'";
            NSString *deleteUserPunch = @"DELETE FROM \"user_punches\" WHERE request_id='aad4a15e-48e2-41ad-b36f-22630cc71aa2'";
            [database executeUpdate:deleteTimePunch];
            [database executeUpdate:deleteUserPunch];


            [subject openOrCreateDatabase:databaseName];
        });

        it(@"should create a database", ^{
            [[NSFileManager defaultManager] fileExistsAtPath:databasePath] should be_truthy;
        });

        it(@"should connect to the specified database", ^{
            [subject.database databasePath] should equal(databasePath);
        });

        it(@"should have created a migrations table", ^{
            migrationManager.hasMigrationsTable should be_truthy;

        });


        it(@"should execute the statement provided and return correct punch association OEFs", ^{

            NSArray *storedPunchesOEFDetails = [subject executeQuery:@"select * from \"time_punch_oef_value\""];
            storedPunchesOEFDetails.count should equal(1);
        });
        
    });
});

SPEC_END
