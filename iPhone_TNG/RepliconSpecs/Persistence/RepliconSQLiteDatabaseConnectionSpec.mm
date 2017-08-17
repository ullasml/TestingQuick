
#import <Cedar/Cedar.h>
#import "RepliconSQLiteDatabaseConnection.h"
#import <repliconkit/repliconkit.h>
#import "AppDelegate.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "ApplicationVersionValidator.h"
#import "InjectorKeys.h"
#import "SQLiteDB.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(RepliconSQLiteDatabaseConnectionSpec)

describe(@"RepliconSQLiteDatabaseConnection", ^{
    __block RepliconSQLiteDatabaseConnection *subject;
    __block id <BSBinder,BSInjector> injector;
    __block ApplicationVersionValidator *applicationVersionValidator;
    __block NSBundle *mainBundle;
    __block NSUserDefaults *userDefaults;

    beforeEach(^{
        injector = [InjectorProvider injector];
        applicationVersionValidator = nice_fake_for([ApplicationVersionValidator class]);
        [injector bind:[ApplicationVersionValidator class] toInstance:applicationVersionValidator];

        mainBundle = nice_fake_for([NSBundle class]);
        [injector bind:InjectorKeyMainBundle toInstance:mainBundle];

        userDefaults = nice_fake_for([NSUserDefaults class]);
        [injector bind:InjectorKeyStandardUserDefaults toInstance:userDefaults];

        mainBundle stub_method(@selector(infoDictionary)).and_return(@{@"CFBundleVersion":@"some-version"});

        subject = [injector getInstance:[RepliconSQLiteDatabaseConnection class]];
    });

    describe(@"fresh install scenario", ^{
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"test-db.sqlite"];

        beforeEach(^{
            [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
            applicationVersionValidator stub_method(@selector(needsUpdateForUserDetailsAndVersionUpdateFromOlderVersion:)).with(nil).and_return(YES);
            applicationVersionValidator stub_method(@selector(isVersion:olderThanVersion:)).and_return(NO);
            [subject openOrCreateDatabase:@"test-db"];
        });

        it(@"should set the attributes to database", ^{
            NSDictionary *attributes = @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication};
            NSError *error;
            [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:databasePath error:&error] should be_truthy;
        });

        it(@"should set the remember me option for the first time install ", ^{
            userDefaults should have_received(@selector(setBool:forKey:)).with(YES,@"RememberMe");
            userDefaults should have_received(@selector(synchronize));
        });

        it(@"should create a database", ^{
            [[NSFileManager defaultManager] fileExistsAtPath:databasePath] should be_truthy;
        });

        it(@"should connect to the specified database", ^{
            [subject.database databasePath] should equal(databasePath);
        });

        it(@"should not update the version details and user detsils for the first time install, since the data will not be present at all", ^{
            applicationVersionValidator should have_received(@selector(needsUpdateForUserDetailsAndVersionUpdateFromOlderVersion:)).with(nil);
        });

        describe(@"the migrations it will run", ^{
            __block FMDBMigrationManager *migrationManager;

            beforeEach(^{
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"LegacySQLiteMigrations" ofType:@"bundle"];
                NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                migrationManager = [FMDBMigrationManager managerWithDatabaseAtPath:databasePath migrationsBundle:bundle];
            });


            it(@"should have created a migrations table", ^{
                migrationManager.hasMigrationsTable should be_truthy;
            });

            it(@"should have applied migrations ie both LegacySQLiteMigrations and RepliconSQLiteMigrations", ^{
                migrationManager.appliedVersions.firstObject should equal(@(20160626123131727));
            });

            it(@"should have at least one migration to run", ^{
                [[migrationManager migrations] count] should be_greater_than(0);
            });

            it(@"should run all of the migrations", ^{
                [migrationManager currentVersion] should be_greater_than_or_equal_to(1435597358);
            });

            it(@"should execute the statement provided and return version info migration data", ^{
                [subject executeQuery:@"select * from \"version_info\""] should equal(@[@{@"version_number": @"some-version",@"isSupportSAML": [NSNull null]}]);
            });

            it(@"should execute the statement provided and return userdetails migration data", ^{
                NSArray *storedUserDetails = [subject executeQuery:@"select * from \"userDetails\""];
                storedUserDetails should equal(@[]);
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

    describe(@"fresh install scenario with foriegn keys", ^{
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"test-db.sqlite"];

        beforeEach(^{
            [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
            applicationVersionValidator stub_method(@selector(needsUpdateForUserDetailsAndVersionUpdateFromOlderVersion:)).with(nil).and_return(YES);
            applicationVersionValidator stub_method(@selector(isVersion:olderThanVersion:)).and_return(NO);
            [subject openOrCreateDatabase:@"test-db"];
        });

        describe(@"executing foreign key statements with FMDatabase", ^{

            NSString *insertStatement = @"INSERT INTO \"a_parent_table\" (\"name\",\"uri\") VALUES ('ullas','test-uri')";
            NSString *insertChildStatement = @"INSERT INTO \"a_child_table\" (\"name\",\"uri\") VALUES ('vijay','test-uri')";

            beforeEach(^{
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ForiegnKeyMigrations" ofType:@"bundle"];
                NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                FMDBMigrationManager *migrationManager = [FMDBMigrationManager managerWithDatabaseAtPath:databasePath migrationsBundle:bundle];
                [migrationManager createMigrationsTable:nil];
                [migrationManager migrateDatabaseToVersion:UINT64_MAX progress:nil error:nil];

                [subject executeUpdate:insertStatement];
                [subject executeUpdate:insertChildStatement];
                [subject executeUpdate:@"DELETE FROM \"a_parent_table\" WHERE uri = 'test-uri'"];
            });
            
            it(@"should execute the statement provided", ^{
                [subject executeQuery:@"select * from \"a_child_table\""] should equal(@[]);
            });
            
        });

        describe(@"executing foreign key statements with SQLiteDB", ^{

            NSString *insertStatement = @"INSERT INTO \"a_parent_table\" (\"name\",\"uri\") VALUES ('ullas','test-uri')";
            NSString *insertChildStatement = @"INSERT INTO \"a_child_table\" (\"name\",\"uri\") VALUES ('vijay','test-uri')";

            beforeEach(^{
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ForiegnKeyMigrations" ofType:@"bundle"];
                NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                FMDBMigrationManager *migrationManager = [FMDBMigrationManager managerWithDatabaseAtPath:databasePath migrationsBundle:bundle];
                [migrationManager createMigrationsTable:nil];
                [migrationManager migrateDatabaseToVersion:UINT64_MAX progress:nil error:nil];

                [subject executeUpdate:insertStatement];
                [subject executeUpdate:insertChildStatement];
                [[SQLiteDB getInstance] deleteFromTable:@"a_parent_table" where:@"uri='test-uri'" inDatabase:@""];

                [subject executeUpdate:@"DELETE FROM \"a_parent_table\" WHERE uri = 'test-uri'"];
            });

            it(@"should execute the statement provided", ^{
                [subject executeQuery:@"select * from \"a_child_table\""] should equal(@[]);
            });
            
        });
        
        
    });

    describe(@"migration scenario from any application version less than 1.0.71.1", ^{
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *databaseName = @"test-db";
        NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",databaseName]];

        beforeEach(^{
            applicationVersionValidator stub_method(@selector(needsUpdateForUserDetailsAndVersionUpdateFromOlderVersion:)).with(@"1.0.60.18").and_return(YES);
            [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
            [[NSFileManager defaultManager] createFileAtPath:databasePath contents:nil attributes:nil];
            FMDatabase *database = [[FMDatabase alloc] initWithPath:databasePath];
            [database open];

            NSString *createVersionTableStatement = @"CREATE TABLE \"version_info\" (\"version_number\" VARCHAR,\"isSupportSAML\" VARCHAR)";
            NSString *insertVersionStatement = @"INSERT INTO \"version_info\" (\"version_number\",\"isSupportSAML\") VALUES ('1.0.60.18','1')";
            [database executeUpdate:createVersionTableStatement];
            [database executeUpdate:insertVersionStatement];

            NSString *createUserDetailsTableStatement = @"CREATE TABLE \"userDetails\" (\"areTimeSheetRejectCommentsRequired\" NUMERIC,\"isTimesheetApprover\" NUMERIC,\"hasExpenseBillClient\" NUMERIC,\"hasExpenseAccess\" NUMERIC,\"hasExpensePaymentMethod\" NUMERIC,\"hasExpenseReimbursements\" NUMERIC,\"hasTimeoffBookingAccess\" NUMERIC,\"isStartAndEndTimeRequiredForBooking\" NUMERIC,\"timeoffBookingMinimumSizeUri\" TEXT,\"timeoffDisplayFormat\" TEXT,\"hasTimesheetBillingAccess\" NUMERIC,\"hasTimesheetProjectAccess\" NUMERIC,\"hasTimesheetAccess\" NUMERIC,\"hasTimesheetTimeoffAccess\" NUMERIC,\"hasTimesheetActivityAccess\" NUMERIC,\"timesheetFormat\" TEXT,\"timesheetHourFormat\" TEXT,\"displayText\" TEXT,\"slug\" TEXT,\"uri\" TEXT,\"isTimeOffApprover\" NUMERIC,\"areTimeOffRejectCommentsRequired\" NUMERIC,\"language_cultureCode\" TEXT,\"language_displayText\" TEXT,\"language_code\" TEXT,\"language_uri\" TEXT,\"disclaimerTimesheetNoticePolicyUri\" VARCHAR,\"isExpenseApprover\" NUMERIC,\"areExpenseRejectCommentsRequired\" NUMERIC,\"expenseEntryAgainstProjectsAllowed\" NUMERIC,\"expenseEntryAgainstProjectsRequired\" NUMERIC,\"hasTimeOffDeletetAcess\" NUMERIC,\"hasTimeOffEditAcess\" NUMERIC,\"hasExpenseReceiptView\" NUMERIC,\"timesheetActivitySelectionRequired\" NUMERIC,\"timesheetProjectTaskSelectionRequired\" NUMERIC,\"baseCurrencyName\" VARCHAR,\"baseCurrencyUri\" VARCHAR,\"hasTimesheetBreakAccess\" NUMERIC,\"hasTimesheetClientAccess\" NUMERIC,\"hasExpensesClientAccess\" NUMERIC,\"disclaimerExpensesheetNoticePolicyUri\" VARCHAR,\"hasPunchInOutAccess\" NUMERIC,\"canViewShifts\" NUMERIC,\"workWeekStartDayUri\" VARCHAR,\"canEditTimePunch\" NUMERIC,\"timepunchActivitySelectionRequired\" NUMERIC,\"hasTimepunchBillingAccess\" NUMERIC,\"hasTimepunchActivityAccess\" NUMERIC,\"hasTimepunchBreakAccess\" NUMERIC,\"hasTimepunchClientAccess\" NUMERIC,\"hasTimepunchProjectAccess\" NUMERIC,\"timepunchProjectTaskSelectionRequired\" NUMERIC,\"timepunchGeolocationRequired\" NUMERIC,\"timepunchAuditImageRequired\" NUMERIC,\"canViewTeamTimePunch\" NUMERIC,\"canViewTimePunch\" NUMERIC,\"canTransferTimePunchToTimesheet\" NUMERIC,\"hasTimesheetProgramAccess\" NUMERIC,\"canEditTask\" NUMERIC,\"canViewTeamTimesheet\" NUMERIC,\"canEditTeamTimePunch\" NUMERIC NOT NULL DEFAULT 0)";

            NSString *insertUserDetailsStatement = @"INSERT INTO userDetails (hasTimepunchProjectAccess, timesheetFormat, canViewTeamTimesheet, hasTimesheetProjectAccess, hasExpenseAccess, uri, hasTimeOffEditAcess, hasPunchInOutAccess, hasExpensesClientAccess, canTransferTimePunchToTimesheet, hasTimeoffBookingAccess, isTimesheetApprover, canViewTimePunch, timepunchAuditImageRequired, hasTimesheetActivityAccess, slug, expenseEntryAgainstProjectsAllowed, hasTimesheetTimeoffAccess, timesheetProjectTaskSelectionRequired, timepunchProjectTaskSelectionRequired, hasTimeOffDeletetAcess, canViewShifts, hasTimesheetAccess, hasExpenseBillClient, baseCurrencyUri, hasTimepunchBreakAccess, areTimeSheetRejectCommentsRequired, canEditTimePunch, hasTimepunchClientAccess, baseCurrencyName, timesheetHourFormat, hasTimepunchBillingAccess, language_cultureCode, areTimeOffRejectCommentsRequired, hasTimepunchActivityAccess, timeoffDisplayFormat, hasExpenseReceiptView, isTimeOffApprover, workWeekStartDayUri, hasTimesheetBillingAccess, disclaimerExpensesheetNoticePolicyUri, canViewTeamTimePunch, timesheetActivitySelectionRequired, canEditTeamTimePunch, displayText, hasTimesheetBreakAccess, hasExpensePaymentMethod, disclaimerTimesheetNoticePolicyUri, timepunchGeolocationRequired, hasTimesheetProgramAccess, hasExpenseReimbursements, language_code, language_displayText, language_uri, isExpenseApprover, timepunchActivitySelectionRequired, hasTimesheetClientAccess, expenseEntryAgainstProjectsRequired, areExpenseRejectCommentsRequired, canEditTask,isStartAndEndTimeRequiredForBooking,timeoffBookingMinimumSizeUri) values (0, 'urn:replicon:policy:timesheet:timesheet-format:gen4-timesheet', 1, 0, 1, 'urn:replicon-tenant:repliconiphone-2:user:2', 1, 1, 1, 1, 1, 1, 1, 1, 0, 'admin', 1, 0, 0, 0, 1, 1, 1, 1, 'urn:replicon-tenant:repliconiphone-2:currency:1', 1, 0, 1, 0, '$', 'urn:replicon:clock-format:24-hour', 0, 'en', 1, 1, 'urn:replicon:time-off-measurement-unit:work-days', 1, 1, 'urn:replicon:day-of-week:monday', 0, 'urn:replicon:policy:expense:expense-notice-acceptance:expense-notice-acceptance-not-required', 1, 0, 1, 'Epari, Tilak (admin)', 1, 1, 'urn:replicon:policy:timesheet:explicit-notice-acceptance:not-required', 1, 0, 1, 'en-US', 'English (United States)', 'urn:replicon:language:en-US', 1, 1, 0, 0, 0, 1,1,'timeoff')";
            [database executeUpdate:createUserDetailsTableStatement];
            [database executeUpdate:insertUserDetailsStatement];

            applicationVersionValidator stub_method(@selector(isVersion:olderThanVersion:)).and_return(YES);

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
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TestSQLiteMigrations" ofType:@"bundle"];
                NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                migrationManager = [FMDBMigrationManager managerWithDatabaseAtPath:databasePath migrationsBundle:bundle];
                [migrationManager createMigrationsTable:nil];
                [migrationManager migrateDatabaseToVersion:UINT64_MAX progress:nil error:nil];
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

            it(@"should have applied migrations", ^{
                migrationManager.appliedVersions.firstObject should equal(@(20160626123131727));

            });

            it(@"should execute the statement provided and return version info migration data", ^{
                [subject executeQuery:@"select * from \"version_info\""] should equal(@[@{@"version_number": @"some-version",@"isSupportSAML": @"1"}]);
            });

            it(@"should execute the statement provided and return userdetails migration data", ^{
                NSArray *expectedUserDetails = @[@{
                                                     @"areExpenseRejectCommentsRequired"        : @0,
                                                     @"areTimeOffRejectCommentsRequired"        : @1,
                                                     @"areTimeSheetRejectCommentsRequired"      : @0,
                                                     @"canEditTask" 							: @1,
                                                     @"canEditTeamTimePunch"                    : @1,
                                                     @"canEditTimePunch"                        : @1,
                                                     @"canTransferTimePunchToTimesheet" 		: @1,
                                                     @"canViewShifts"                           : @1,
                                                     @"canViewTeamTimePunch"                    : @1,
                                                     @"canViewTeamTimesheet"                    : @1,
                                                     @"canViewTimePunch"                        : @1,
                                                     @"expenseEntryAgainstProjectsAllowed"      : @1,
                                                     @"expenseEntryAgainstProjectsRequired" 	: @0,
                                                     @"hasExpenseAccess"                        : @1,
                                                     @"hasExpenseBillClient"                    : @1,
                                                     @"hasExpensePaymentMethod" 				: @1,
                                                     @"hasExpenseReceiptView"                   : @1,
                                                     @"hasExpenseReimbursements"                : @1,
                                                     @"hasExpensesClientAccess" 				: @1,
                                                     @"hasPunchInOutAccess" 					: @1,
                                                     @"hasTimeOffDeletetAcess"                  : @1,
                                                     @"hasTimeOffEditAcess" 					: @1,
                                                     @"hasTimeoffBookingAccess" 				: @1,
                                                     @"hasTimepunchActivityAccess"              : @1,
                                                     @"hasTimepunchBillingAccess"               : @0,
                                                     @"hasTimepunchBreakAccess" 				: @1,
                                                     @"hasTimepunchClientAccess"                : @0,
                                                     @"hasTimepunchProjectAccess"               : @0,
                                                     @"hasTimesheetAccess"                      : @1,
                                                     @"hasTimesheetActivityAccess"              : @0,
                                                     @"hasTimesheetBillingAccess"               : @0,
                                                     @"hasTimesheetBreakAccess" 				: @1,
                                                     @"hasTimesheetClientAccess"                : @0,
                                                     @"hasTimesheetProgramAccess"               : @0,
                                                     @"hasTimesheetProjectAccess"               : @0,
                                                     @"hasTimesheetTimeoffAccess"               : @0,
                                                     @"isExpenseApprover"                       : @1,
                                                     @"isTimeOffApprover"                       : @1,
                                                     @"isTimesheetApprover" 					: @1,
                                                     @"timepunchActivitySelectionRequired"      : @1,
                                                     @"timepunchAuditImageRequired" 			: @1,
                                                     @"timepunchGeolocationRequired"            : @1,
                                                     @"timepunchProjectTaskSelectionRequired"   : @0,
                                                     @"timesheetActivitySelectionRequired"      : @0,
                                                     @"timesheetProjectTaskSelectionRequired"   : @0,
                                                     @"baseCurrencyName"                        : @"$",
                                                     @"language_cultureCode"                    : @"en",
                                                     @"language_code"                           : @"en-US",
                                                     @"slug"                                    : @"admin",
                                                     @"timesheetFormat" 						: @"urn:replicon:policy:timesheet:timesheet-format:gen4-timesheet",
                                                     @"timesheetHourFormat" 					: @"urn:replicon:clock-format:24-hour",
                                                     @"uri" 									: @"urn:replicon-tenant:repliconiphone-2:user:2",
                                                     @"workWeekStartDayUri" 					: @"urn:replicon:day-of-week:monday",
                                                     @"baseCurrencyUri" 						: @"urn:replicon-tenant:repliconiphone-2:currency:1",
                                                     @"disclaimerExpensesheetNoticePolicyUri"   : @"urn:replicon:policy:expense:expense-notice-acceptance:expense-notice-acceptance-not-required",
                                                     @"disclaimerTimesheetNoticePolicyUri"      : @"urn:replicon:policy:timesheet:explicit-notice-acceptance:not-required",
                                                     @"displayText" 							: @"Epari, Tilak (admin)",
                                                     @"language_displayText"                    : @"English (United States)",
                                                     @"language_uri"                            : @"urn:replicon:language:en-US",
                                                     @"timeoffDisplayFormat"                    : @"urn:replicon:time-off-measurement-unit:work-days",
                                                     @"timeoffBookingMinimumSizeUri"            : @"timeoff",
                                                     @"isStartAndEndTimeRequiredForBooking"     : @1,
                                                     @"canViewTeamPayDetails"                   : [NSNull null],
                                                     @"isMultiDayTimeOffOptionAvailable"        : [NSNull null]

                                                     }
                                                 ];

                NSArray *storedUserDetails = [subject executeQuery:@"select * from \"userDetails\""];
                storedUserDetails should equal(expectedUserDetails);
            });

        });
    });

    describe(@"migration scenario from any application version equal to 1.0.71.1", ^{
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *databaseName = @"test-db";
        NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",databaseName]];

        beforeEach(^{
            applicationVersionValidator stub_method(@selector(needsUpdateForUserDetailsAndVersionUpdateFromOlderVersion:)).with(@"1.0.71.1").and_return(NO);
            mainBundle stub_method(@selector(infoDictionary)).again().and_return(@{@"CFBundleVersion":@"1.0.71.1"});

            [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
            [[NSFileManager defaultManager] createFileAtPath:databasePath contents:nil attributes:nil];
            FMDatabase *database = [[FMDatabase alloc] initWithPath:databasePath];
            [database open];

            NSString *createVersionTableStatement = @"CREATE TABLE \"version_info\" (\"version_number\" VARCHAR,\"isSupportSAML\" VARCHAR)";
            NSString *insertVersionStatement = @"INSERT INTO \"version_info\" (\"version_number\",\"isSupportSAML\") VALUES ('1.0.71.1','1')";
            [database executeUpdate:createVersionTableStatement];
            [database executeUpdate:insertVersionStatement];

            NSString *createUserDetailsTableStatement = @"CREATE TABLE \"userDetails\" (\"areTimeSheetRejectCommentsRequired\" NUMERIC,\"isTimesheetApprover\" NUMERIC,\"hasExpenseBillClient\" NUMERIC,\"hasExpenseAccess\" NUMERIC,\"hasExpensePaymentMethod\" NUMERIC,\"hasExpenseReimbursements\" NUMERIC,\"hasTimeoffBookingAccess\" NUMERIC,\"isStartAndEndTimeRequiredForBooking\" NUMERIC,\"timeoffBookingMinimumSizeUri\" TEXT,\"timeoffDisplayFormat\" TEXT,\"hasTimesheetBillingAccess\" NUMERIC,\"hasTimesheetProjectAccess\" NUMERIC,\"hasTimesheetAccess\" NUMERIC,\"hasTimesheetTimeoffAccess\" NUMERIC,\"hasTimesheetActivityAccess\" NUMERIC,\"timesheetFormat\" TEXT,\"timesheetHourFormat\" TEXT,\"displayText\" TEXT,\"slug\" TEXT,\"uri\" TEXT,\"isTimeOffApprover\" NUMERIC,\"areTimeOffRejectCommentsRequired\" NUMERIC,\"language_cultureCode\" TEXT,\"language_displayText\" TEXT,\"language_code\" TEXT,\"language_uri\" TEXT,\"disclaimerTimesheetNoticePolicyUri\" VARCHAR,\"isExpenseApprover\" NUMERIC,\"areExpenseRejectCommentsRequired\" NUMERIC,\"expenseEntryAgainstProjectsAllowed\" NUMERIC,\"expenseEntryAgainstProjectsRequired\" NUMERIC,\"hasTimeOffDeletetAcess\" NUMERIC,\"hasTimeOffEditAcess\" NUMERIC,\"hasExpenseReceiptView\" NUMERIC,\"timesheetActivitySelectionRequired\" NUMERIC,\"timesheetProjectTaskSelectionRequired\" NUMERIC,\"baseCurrencyName\" VARCHAR,\"baseCurrencyUri\" VARCHAR,\"hasTimesheetBreakAccess\" NUMERIC,\"hasTimesheetClientAccess\" NUMERIC,\"hasExpensesClientAccess\" NUMERIC,\"disclaimerExpensesheetNoticePolicyUri\" VARCHAR,\"hasPunchInOutAccess\" NUMERIC,\"canViewShifts\" NUMERIC,\"workWeekStartDayUri\" VARCHAR,\"canEditTimePunch\" NUMERIC,\"timepunchActivitySelectionRequired\" NUMERIC,\"hasTimepunchBillingAccess\" NUMERIC,\"hasTimepunchActivityAccess\" NUMERIC,\"hasTimepunchBreakAccess\" NUMERIC,\"hasTimepunchClientAccess\" NUMERIC,\"hasTimepunchProjectAccess\" NUMERIC,\"timepunchProjectTaskSelectionRequired\" NUMERIC,\"timepunchGeolocationRequired\" NUMERIC,\"timepunchAuditImageRequired\" NUMERIC,\"canViewTeamTimePunch\" NUMERIC,\"canViewTimePunch\" NUMERIC,\"canTransferTimePunchToTimesheet\" NUMERIC,\"hasTimesheetProgramAccess\" NUMERIC,\"canEditTask\" NUMERIC,\"canViewTeamTimesheet\" NUMERIC,\"canEditTeamTimePunch\" NUMERIC NOT NULL DEFAULT 0)";

            NSString *insertUserDetailsStatement = @"INSERT INTO userDetails (hasTimepunchProjectAccess, timesheetFormat, canViewTeamTimesheet, hasTimesheetProjectAccess, hasExpenseAccess, uri, hasTimeOffEditAcess, hasPunchInOutAccess, hasExpensesClientAccess, canTransferTimePunchToTimesheet, hasTimeoffBookingAccess, isTimesheetApprover, canViewTimePunch, timepunchAuditImageRequired, hasTimesheetActivityAccess, slug, expenseEntryAgainstProjectsAllowed, hasTimesheetTimeoffAccess, timesheetProjectTaskSelectionRequired, timepunchProjectTaskSelectionRequired, hasTimeOffDeletetAcess, canViewShifts, hasTimesheetAccess, hasExpenseBillClient, baseCurrencyUri, hasTimepunchBreakAccess, areTimeSheetRejectCommentsRequired, canEditTimePunch, hasTimepunchClientAccess, baseCurrencyName, timesheetHourFormat, hasTimepunchBillingAccess, language_cultureCode, areTimeOffRejectCommentsRequired, hasTimepunchActivityAccess, timeoffDisplayFormat, hasExpenseReceiptView, isTimeOffApprover, workWeekStartDayUri, hasTimesheetBillingAccess, disclaimerExpensesheetNoticePolicyUri, canViewTeamTimePunch, timesheetActivitySelectionRequired, canEditTeamTimePunch, displayText, hasTimesheetBreakAccess, hasExpensePaymentMethod, disclaimerTimesheetNoticePolicyUri, timepunchGeolocationRequired, hasTimesheetProgramAccess, hasExpenseReimbursements, language_code, language_displayText, language_uri, isExpenseApprover, timepunchActivitySelectionRequired, hasTimesheetClientAccess, expenseEntryAgainstProjectsRequired, areExpenseRejectCommentsRequired, canEditTask,isStartAndEndTimeRequiredForBooking,timeoffBookingMinimumSizeUri) values (0, 'urn:replicon:policy:timesheet:timesheet-format:gen4-timesheet', 1, 0, 1, 'urn:replicon-tenant:repliconiphone-2:user:2', 1, 1, 1, 1, 1, 1, 1, 1, 0, 'admin', 1, 0, 0, 0, 1, 1, 1, 1, 'urn:replicon-tenant:repliconiphone-2:currency:1', 1, 0, 1, 0, '$', 'urn:replicon:clock-format:24-hour', 0, 'en', 1, 1, 'urn:replicon:time-off-measurement-unit:work-days', 1, 1, 'urn:replicon:day-of-week:monday', 0, 'urn:replicon:policy:expense:expense-notice-acceptance:expense-notice-acceptance-not-required', 1, 0, 1, 'Epari, Tilak (admin)', 1, 1, 'urn:replicon:policy:timesheet:explicit-notice-acceptance:not-required', 1, 0, 1, 'en-US', 'English (United States)', 'urn:replicon:language:en-US', 1, 1, 0, 0, 0, 1,1,'timeoff')";
            [database executeUpdate:createUserDetailsTableStatement];
            [database executeUpdate:insertUserDetailsStatement];

            applicationVersionValidator stub_method(@selector(isVersion:olderThanVersion:)).and_return(NO);

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
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TestSQLiteMigrations" ofType:@"bundle"];
                NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                migrationManager = [FMDBMigrationManager managerWithDatabaseAtPath:databasePath migrationsBundle:bundle];
                [migrationManager createMigrationsTable:nil];
                [migrationManager migrateDatabaseToVersion:UINT64_MAX progress:nil error:nil];
            });

            it(@"should have created a migrations table", ^{
                migrationManager.hasMigrationsTable should be_truthy;
            });

            it(@"should have at least one migration to run", ^{
                [[migrationManager migrations] count] should be_greater_than(0);
            });

            it(@"should have applied migrations", ^{
                migrationManager.appliedVersions.count should equal(0);

            });

            it(@"should execute the statement provided and return version info migration data", ^{
                [subject executeQuery:@"select * from \"version_info\""] should equal(@[@{@"version_number": @"1.0.71.1",@"isSupportSAML": @"1"}]);
            });

            it(@"should execute the statement provided and return userdetails migration data", ^{
                NSArray *expectedUserDetails = @[@{
                                                     @"areExpenseRejectCommentsRequired"        : @0,
                                                     @"areTimeOffRejectCommentsRequired"        : @1,
                                                     @"areTimeSheetRejectCommentsRequired"      : @0,
                                                     @"canEditTask" 							: @1,
                                                     @"canEditTeamTimePunch"                    : @1,
                                                     @"canEditTimePunch"                        : @1,
                                                     @"canTransferTimePunchToTimesheet" 		: @1,
                                                     @"canViewShifts"                           : @1,
                                                     @"canViewTeamTimePunch"                    : @1,
                                                     @"canViewTeamTimesheet"                    : @1,
                                                     @"canViewTimePunch"                        : @1,
                                                     @"expenseEntryAgainstProjectsAllowed"      : @1,
                                                     @"expenseEntryAgainstProjectsRequired" 	: @0,
                                                     @"hasExpenseAccess"                        : @1,
                                                     @"hasExpenseBillClient"                    : @1,
                                                     @"hasExpensePaymentMethod" 				: @1,
                                                     @"hasExpenseReceiptView"                   : @1,
                                                     @"hasExpenseReimbursements"                : @1,
                                                     @"hasExpensesClientAccess" 				: @1,
                                                     @"hasPunchInOutAccess" 					: @1,
                                                     @"hasTimeOffDeletetAcess"                  : @1,
                                                     @"hasTimeOffEditAcess" 					: @1,
                                                     @"hasTimeoffBookingAccess" 				: @1,
                                                     @"hasTimepunchActivityAccess"              : @1,
                                                     @"hasTimepunchBillingAccess"               : @0,
                                                     @"hasTimepunchBreakAccess" 				: @1,
                                                     @"hasTimepunchClientAccess"                : @0,
                                                     @"hasTimepunchProjectAccess"               : @0,
                                                     @"hasTimesheetAccess"                      : @1,
                                                     @"hasTimesheetActivityAccess"              : @0,
                                                     @"hasTimesheetBillingAccess"               : @0,
                                                     @"hasTimesheetBreakAccess" 				: @1,
                                                     @"hasTimesheetClientAccess"                : @0,
                                                     @"hasTimesheetProgramAccess"               : @0,
                                                     @"hasTimesheetProjectAccess"               : @0,
                                                     @"hasTimesheetTimeoffAccess"               : @0,
                                                     @"isExpenseApprover"                       : @1,
                                                     @"isTimeOffApprover"                       : @1,
                                                     @"isTimesheetApprover" 					: @1,
                                                     @"timepunchActivitySelectionRequired"      : @1,
                                                     @"timepunchAuditImageRequired" 			: @1,
                                                     @"timepunchGeolocationRequired"            : @1,
                                                     @"timepunchProjectTaskSelectionRequired"   : @0,
                                                     @"timesheetActivitySelectionRequired"      : @0,
                                                     @"timesheetProjectTaskSelectionRequired"   : @0,
                                                     @"baseCurrencyName"                        : @"$",
                                                     @"language_cultureCode"                    : @"en",
                                                     @"language_code"                           : @"en-US",
                                                     @"slug"                                    : @"admin",
                                                     @"timesheetFormat" 						: @"urn:replicon:policy:timesheet:timesheet-format:gen4-timesheet",
                                                     @"timesheetHourFormat" 					: @"urn:replicon:clock-format:24-hour",
                                                     @"uri" 									: @"urn:replicon-tenant:repliconiphone-2:user:2",
                                                     @"workWeekStartDayUri" 					: @"urn:replicon:day-of-week:monday",
                                                     @"baseCurrencyUri" 						: @"urn:replicon-tenant:repliconiphone-2:currency:1",
                                                     @"disclaimerExpensesheetNoticePolicyUri"   : @"urn:replicon:policy:expense:expense-notice-acceptance:expense-notice-acceptance-not-required",
                                                     @"disclaimerTimesheetNoticePolicyUri"      : @"urn:replicon:policy:timesheet:explicit-notice-acceptance:not-required",
                                                     @"displayText" 							: @"Epari, Tilak (admin)",
                                                     @"language_displayText"                    : @"English (United States)",
                                                     @"language_uri"                            : @"urn:replicon:language:en-US",
                                                     @"timeoffDisplayFormat"                    : @"urn:replicon:time-off-measurement-unit:work-days",
                                                     @"timeoffBookingMinimumSizeUri"            : @"timeoff",
                                                     @"isStartAndEndTimeRequiredForBooking"     : @1,

                                                     }
                                                 ];
                
                NSArray *storedUserDetails = [subject executeQuery:@"select * from \"userDetails\""];
                storedUserDetails should equal(expectedUserDetails);
            });
            
        });
    });

    describe(@"migration scenario from any application version greater than 1.0.71.1", ^{
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *databaseName = @"test-db";
        NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",databaseName]];

        beforeEach(^{
            applicationVersionValidator stub_method(@selector(needsUpdateForUserDetailsAndVersionUpdateFromOlderVersion:)).with(@"1.0.71.1").and_return(YES);
            mainBundle stub_method(@selector(infoDictionary)).again().and_return(@{@"CFBundleVersion":@"1.0.71.0"});

            [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
            [[NSFileManager defaultManager] createFileAtPath:databasePath contents:nil attributes:nil];
            FMDatabase *database = [[FMDatabase alloc] initWithPath:databasePath];
            [database open];

            NSString *createVersionTableStatement = @"CREATE TABLE \"version_info\" (\"version_number\" VARCHAR,\"isSupportSAML\" VARCHAR)";
            NSString *insertVersionStatement = @"INSERT INTO \"version_info\" (\"version_number\",\"isSupportSAML\") VALUES ('1.0.71.1','1')";
            [database executeUpdate:createVersionTableStatement];
            [database executeUpdate:insertVersionStatement];

            NSString *createUserDetailsTableStatement = @"CREATE TABLE \"userDetails\" (\"areTimeSheetRejectCommentsRequired\" NUMERIC,\"isTimesheetApprover\" NUMERIC,\"hasExpenseBillClient\" NUMERIC,\"hasExpenseAccess\" NUMERIC,\"hasExpensePaymentMethod\" NUMERIC,\"hasExpenseReimbursements\" NUMERIC,\"hasTimeoffBookingAccess\" NUMERIC,\"isStartAndEndTimeRequiredForBooking\" NUMERIC,\"timeoffBookingMinimumSizeUri\" TEXT,\"timeoffDisplayFormat\" TEXT,\"hasTimesheetBillingAccess\" NUMERIC,\"hasTimesheetProjectAccess\" NUMERIC,\"hasTimesheetAccess\" NUMERIC,\"hasTimesheetTimeoffAccess\" NUMERIC,\"hasTimesheetActivityAccess\" NUMERIC,\"timesheetFormat\" TEXT,\"timesheetHourFormat\" TEXT,\"displayText\" TEXT,\"slug\" TEXT,\"uri\" TEXT,\"isTimeOffApprover\" NUMERIC,\"areTimeOffRejectCommentsRequired\" NUMERIC,\"language_cultureCode\" TEXT,\"language_displayText\" TEXT,\"language_code\" TEXT,\"language_uri\" TEXT,\"disclaimerTimesheetNoticePolicyUri\" VARCHAR,\"isExpenseApprover\" NUMERIC,\"areExpenseRejectCommentsRequired\" NUMERIC,\"expenseEntryAgainstProjectsAllowed\" NUMERIC,\"expenseEntryAgainstProjectsRequired\" NUMERIC,\"hasTimeOffDeletetAcess\" NUMERIC,\"hasTimeOffEditAcess\" NUMERIC,\"hasExpenseReceiptView\" NUMERIC,\"timesheetActivitySelectionRequired\" NUMERIC,\"timesheetProjectTaskSelectionRequired\" NUMERIC,\"baseCurrencyName\" VARCHAR,\"baseCurrencyUri\" VARCHAR,\"hasTimesheetBreakAccess\" NUMERIC,\"hasTimesheetClientAccess\" NUMERIC,\"hasExpensesClientAccess\" NUMERIC,\"disclaimerExpensesheetNoticePolicyUri\" VARCHAR,\"hasPunchInOutAccess\" NUMERIC,\"canViewShifts\" NUMERIC,\"workWeekStartDayUri\" VARCHAR,\"canEditTimePunch\" NUMERIC,\"timepunchActivitySelectionRequired\" NUMERIC,\"hasTimepunchBillingAccess\" NUMERIC,\"hasTimepunchActivityAccess\" NUMERIC,\"hasTimepunchBreakAccess\" NUMERIC,\"hasTimepunchClientAccess\" NUMERIC,\"hasTimepunchProjectAccess\" NUMERIC,\"timepunchProjectTaskSelectionRequired\" NUMERIC,\"timepunchGeolocationRequired\" NUMERIC,\"timepunchAuditImageRequired\" NUMERIC,\"canViewTeamTimePunch\" NUMERIC,\"canViewTimePunch\" NUMERIC,\"canTransferTimePunchToTimesheet\" NUMERIC,\"hasTimesheetProgramAccess\" NUMERIC,\"canEditTask\" NUMERIC,\"canViewTeamTimesheet\" NUMERIC,\"canEditTeamTimePunch\" NUMERIC NOT NULL DEFAULT 0)";

            NSString *insertUserDetailsStatement = @"INSERT INTO userDetails (hasTimepunchProjectAccess, timesheetFormat, canViewTeamTimesheet, hasTimesheetProjectAccess, hasExpenseAccess, uri, hasTimeOffEditAcess, hasPunchInOutAccess, hasExpensesClientAccess, canTransferTimePunchToTimesheet, hasTimeoffBookingAccess, isTimesheetApprover, canViewTimePunch, timepunchAuditImageRequired, hasTimesheetActivityAccess, slug, expenseEntryAgainstProjectsAllowed, hasTimesheetTimeoffAccess, timesheetProjectTaskSelectionRequired, timepunchProjectTaskSelectionRequired, hasTimeOffDeletetAcess, canViewShifts, hasTimesheetAccess, hasExpenseBillClient, baseCurrencyUri, hasTimepunchBreakAccess, areTimeSheetRejectCommentsRequired, canEditTimePunch, hasTimepunchClientAccess, baseCurrencyName, timesheetHourFormat, hasTimepunchBillingAccess, language_cultureCode, areTimeOffRejectCommentsRequired, hasTimepunchActivityAccess, timeoffDisplayFormat, hasExpenseReceiptView, isTimeOffApprover, workWeekStartDayUri, hasTimesheetBillingAccess, disclaimerExpensesheetNoticePolicyUri, canViewTeamTimePunch, timesheetActivitySelectionRequired, canEditTeamTimePunch, displayText, hasTimesheetBreakAccess, hasExpensePaymentMethod, disclaimerTimesheetNoticePolicyUri, timepunchGeolocationRequired, hasTimesheetProgramAccess, hasExpenseReimbursements, language_code, language_displayText, language_uri, isExpenseApprover, timepunchActivitySelectionRequired, hasTimesheetClientAccess, expenseEntryAgainstProjectsRequired, areExpenseRejectCommentsRequired, canEditTask,isStartAndEndTimeRequiredForBooking,timeoffBookingMinimumSizeUri) values (0, 'urn:replicon:policy:timesheet:timesheet-format:gen4-timesheet', 1, 0, 1, 'urn:replicon-tenant:repliconiphone-2:user:2', 1, 1, 1, 1, 1, 1, 1, 1, 0, 'admin', 1, 0, 0, 0, 1, 1, 1, 1, 'urn:replicon-tenant:repliconiphone-2:currency:1', 1, 0, 1, 0, '$', 'urn:replicon:clock-format:24-hour', 0, 'en', 1, 1, 'urn:replicon:time-off-measurement-unit:work-days', 1, 1, 'urn:replicon:day-of-week:monday', 0, 'urn:replicon:policy:expense:expense-notice-acceptance:expense-notice-acceptance-not-required', 1, 0, 1, 'Epari, Tilak (admin)', 1, 1, 'urn:replicon:policy:timesheet:explicit-notice-acceptance:not-required', 1, 0, 1, 'en-US', 'English (United States)', 'urn:replicon:language:en-US', 1, 1, 0, 0, 0, 1,1,'timeoff')";
            [database executeUpdate:createUserDetailsTableStatement];
            [database executeUpdate:insertUserDetailsStatement];

            applicationVersionValidator stub_method(@selector(isVersion:olderThanVersion:)).and_return(NO);

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
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TestSQLiteMigrations" ofType:@"bundle"];
                NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                migrationManager = [FMDBMigrationManager managerWithDatabaseAtPath:databasePath migrationsBundle:bundle];
                [migrationManager createMigrationsTable:nil];
                [migrationManager migrateDatabaseToVersion:UINT64_MAX progress:nil error:nil];
            });

            it(@"should have created a migrations table", ^{
                migrationManager.hasMigrationsTable should be_truthy;
            });

            it(@"should have at least one migration to run", ^{
                [[migrationManager migrations] count] should be_greater_than(0);
            });



            it(@"should have applied migrations", ^{
                migrationManager.appliedVersions.count should equal(0);
            });

            it(@"should execute the statement provided and return version info migration data", ^{
                [subject executeQuery:@"select * from \"version_info\""] should equal(@[@{@"version_number": @"1.0.71.0",@"isSupportSAML": @"1"}]);
            });

            it(@"should execute the statement provided and return userdetails migration data", ^{
                NSArray *expectedUserDetails = @[@{
                                                     @"areExpenseRejectCommentsRequired"        : @0,
                                                     @"areTimeOffRejectCommentsRequired"        : @1,
                                                     @"areTimeSheetRejectCommentsRequired"      : @0,
                                                     @"canEditTask" 							: @1,
                                                     @"canEditTeamTimePunch"                    : @1,
                                                     @"canEditTimePunch"                        : @1,
                                                     @"canTransferTimePunchToTimesheet" 		: @1,
                                                     @"canViewShifts"                           : @1,
                                                     @"canViewTeamTimePunch"                    : @1,
                                                     @"canViewTeamTimesheet"                    : @1,
                                                     @"canViewTimePunch"                        : @1,
                                                     @"expenseEntryAgainstProjectsAllowed"      : @1,
                                                     @"expenseEntryAgainstProjectsRequired" 	: @0,
                                                     @"hasExpenseAccess"                        : @1,
                                                     @"hasExpenseBillClient"                    : @1,
                                                     @"hasExpensePaymentMethod" 				: @1,
                                                     @"hasExpenseReceiptView"                   : @1,
                                                     @"hasExpenseReimbursements"                : @1,
                                                     @"hasExpensesClientAccess" 				: @1,
                                                     @"hasPunchInOutAccess" 					: @1,
                                                     @"hasTimeOffDeletetAcess"                  : @1,
                                                     @"hasTimeOffEditAcess" 					: @1,
                                                     @"hasTimeoffBookingAccess" 				: @1,
                                                     @"hasTimepunchActivityAccess"              : @1,
                                                     @"hasTimepunchBillingAccess"               : @0,
                                                     @"hasTimepunchBreakAccess" 				: @1,
                                                     @"hasTimepunchClientAccess"                : @0,
                                                     @"hasTimepunchProjectAccess"               : @0,
                                                     @"hasTimesheetAccess"                      : @1,
                                                     @"hasTimesheetActivityAccess"              : @0,
                                                     @"hasTimesheetBillingAccess"               : @0,
                                                     @"hasTimesheetBreakAccess" 				: @1,
                                                     @"hasTimesheetClientAccess"                : @0,
                                                     @"hasTimesheetProgramAccess"               : @0,
                                                     @"hasTimesheetProjectAccess"               : @0,
                                                     @"hasTimesheetTimeoffAccess"               : @0,
                                                     @"isExpenseApprover"                       : @1,
                                                     @"isTimeOffApprover"                       : @1,
                                                     @"isTimesheetApprover" 					: @1,
                                                     @"timepunchActivitySelectionRequired"      : @1,
                                                     @"timepunchAuditImageRequired" 			: @1,
                                                     @"timepunchGeolocationRequired"            : @1,
                                                     @"timepunchProjectTaskSelectionRequired"   : @0,
                                                     @"timesheetActivitySelectionRequired"      : @0,
                                                     @"timesheetProjectTaskSelectionRequired"   : @0,
                                                     @"baseCurrencyName"                        : @"$",
                                                     @"language_cultureCode"                    : @"en",
                                                     @"language_code"                           : @"en-US",
                                                     @"slug"                                    : @"admin",
                                                     @"timesheetFormat" 						: @"urn:replicon:policy:timesheet:timesheet-format:gen4-timesheet",
                                                     @"timesheetHourFormat" 					: @"urn:replicon:clock-format:24-hour",
                                                     @"uri" 									: @"urn:replicon-tenant:repliconiphone-2:user:2",
                                                     @"workWeekStartDayUri" 					: @"urn:replicon:day-of-week:monday",
                                                     @"baseCurrencyUri" 						: @"urn:replicon-tenant:repliconiphone-2:currency:1",
                                                     @"disclaimerExpensesheetNoticePolicyUri"   : @"urn:replicon:policy:expense:expense-notice-acceptance:expense-notice-acceptance-not-required",
                                                     @"disclaimerTimesheetNoticePolicyUri"      : @"urn:replicon:policy:timesheet:explicit-notice-acceptance:not-required",
                                                     @"displayText" 							: @"Epari, Tilak (admin)",
                                                     @"language_displayText"                    : @"English (United States)",
                                                     @"language_uri"                            : @"urn:replicon:language:en-US",
                                                     @"timeoffDisplayFormat"                    : @"urn:replicon:time-off-measurement-unit:work-days",
                                                     @"timeoffBookingMinimumSizeUri"            : @"timeoff",
                                                     @"isStartAndEndTimeRequiredForBooking"     : @1,

                                                     }
                                                 ];
                
                NSArray *storedUserDetails = [subject executeQuery:@"select * from \"userDetails\""];
                storedUserDetails should equal(expectedUserDetails);
            });
            
        });
    });

});

SPEC_END

