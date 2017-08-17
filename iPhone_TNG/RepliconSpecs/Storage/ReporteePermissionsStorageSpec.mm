#import <Cedar/Cedar.h>
#import "ReporteePermissionsStorage.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "SQLiteTableStore.h"
#import "QueryStringBuilder.h"
#import "UserSession.h"
#import "SQLiteDatabaseConnection.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ReporteePermissionsStorageSpec)

describe(@"ReporteePermissionsStorage", ^{
    __block ReporteePermissionsStorage *subject;
    __block SQLiteTableStore *sqliteManager;

    beforeEach(^{
        id<UserSession> userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");

        sqliteManager = [[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                      databaseName:@"Test"
                                                                         tableName:@"reportee_permissions"];
        spy_on(sqliteManager);

        subject = [[ReporteePermissionsStorage alloc] initWithSQLiteStore:sqliteManager
                                                              userSession:userSession];
    });

    describe(@"-persistCanAccessProject:canAccessClient:canAccessActivity:projectTaskSelectionRequired:activitySelectionRequired:isPunchIntoProjectUser:userUri::canAccessBreak:", ^{

        context(@"Punch into Project User", ^{
            
            context(@"when the user doesn't exist", ^{
                beforeEach(^{
                    sqliteManager stub_method(@selector(readLastRowWithArgs:)).and_return(nil);
                    [subject persistCanAccessProject:@YES
                                     canAccessClient:@YES
                                   canAccessActivity:@NO
                        projectTaskSelectionRequired:@YES
                           activitySelectionRequired:@NO
                              isPunchIntoProjectUser:@YES
                                             userUri:@"user-uri"
                                        canAccessBreak:@YES];
                    
                    sqliteManager should have_received(@selector(readLastRowWithArgs:));
                });
                
                it(@"should have called insertRow", ^{
                    sqliteManager should have_received(@selector(insertRow:)).with(@{
                                                                                     @"user_uri": @"user-uri",
                                                                                     @"project_access":@YES,
                                                                                     @"client_access":@YES,
                                                                                     @"project_task_selection_required":@YES,
                                                                                     @"activity_selection_required":@NO,
                                                                                     @"activity_access":@NO,
                                                                                     @"isPunchIntoProjectsUser":@YES,
                                                                                     @"break_access":@YES
                                                                                     });
                });
                
                it(@"should return empty resultSet for readLastRow", ^{
                    NSDictionary *resultSet = [subject.sqliteStore readLastRowWithArgs:@{@"user_uri": @"user-uri"}];
                    resultSet should be_nil;
                });
                
                
                it(@"should allow reading the punch rules but /*returns nothing as we are stubbing */", ^{
                    [subject canAccessProjectUserWithUri:@"user-uri"] should be_falsy;
                    [subject canAccessClientUserWithUri:@"user-uri"] should be_falsy;
                    [subject canAccessActivityUserWithUri:@"user-uri"] should be_falsy;
                    [subject isReporteePunchIntoProjectsUserWithUri:@"user-uri"] should be_falsy;
                    [subject isReporteeActivitySelectionRequired:@"user-uri"] should be_falsy;
                });
            });
            
            context(@"when the user already exist", ^{
                __block NSDictionary *expectedResultSet;
                beforeEach(^{
                    expectedResultSet = @{
                                          @"project_access" :@1,
                                          @"client_access" :@1,
                                          @"activity_access" :@0,
                                          @"project_task_selection_required":@1,
                                          @"activity_selection_required":@0,
                                          @"isPunchIntoProjectsUser":@1,
                                          @"user_uri" : @"user-uri",
                                           @"break_access" :@1
                                          };
                    
                    sqliteManager stub_method(@selector(readLastRowWithArgs:))
                    .with(@{@"user_uri" : @"user-uri"})
                    .and_return(expectedResultSet);
                    
                    [subject persistCanAccessProject:@YES
                                     canAccessClient:@YES
                                   canAccessActivity:@NO
                        projectTaskSelectionRequired:@YES
                           activitySelectionRequired:@NO
                              isPunchIntoProjectUser:@YES
                                             userUri:@"user-uri"
                     canAccessBreak:@YES];
                    
                    sqliteManager should have_received(@selector(readLastRowWithArgs:));
                });
                
                it(@"should have called updateRow", ^{
                    sqliteManager should have_received(@selector(updateRow:whereClause:)).with(expectedResultSet,@{@"user_uri": @"user-uri"});
                });
                
                it(@"should not return empty resultSet for readLastRow", ^{
                    NSDictionary *resultSet = [subject.sqliteStore readLastRowWithArgs:@{@"user_uri" : @"user-uri"}];
                    resultSet should equal(expectedResultSet);
                });
                
                it(@"should allow reading the punch rules", ^{
                    [subject canAccessProjectUserWithUri:@"user-uri"] should be_truthy;
                    [subject canAccessClientUserWithUri:@"user-uri"] should be_truthy;
                    [subject canAccessActivityUserWithUri:@"user-uri"] should be_falsy;
                    [subject isReporteeProjectTaskSelectionRequired:@"user-uri"] should be_truthy;
                    [subject isReporteeActivitySelectionRequired:@"user-uri"] should be_falsy;
                    [subject isReporteePunchIntoProjectsUserWithUri:@"user-uri"] should be_truthy;
                    [subject canAccessProjectUserWithUri:@"other-user-uri"] should be_falsy;
                    [subject canAccessClientUserWithUri:@"other-user-uri"] should be_falsy;
                    [subject isReporteePunchIntoProjectsUserWithUri:@"other-user-uri"] should be_falsy;
                    [subject isReporteeActivitySelectionRequired:@"other-user-uri"] should be_falsy;
                    [subject canAccessBreaksUserWithUri:@"user-uri"] should be_truthy;
                });
                
            });
        });
        
        
        context(@"Punch into Activity User", ^{
            
            context(@"when the user doesn't exist", ^{
                beforeEach(^{
                    sqliteManager stub_method(@selector(readLastRowWithArgs:)).and_return(nil);
                    [subject persistCanAccessProject:@NO
                                     canAccessClient:@NO
                                   canAccessActivity:@YES
                        projectTaskSelectionRequired:@NO
                           activitySelectionRequired:@YES
                              isPunchIntoProjectUser:@NO
                                             userUri:@"user-uri"
                                      canAccessBreak:@YES];
                    
                    sqliteManager should have_received(@selector(readLastRowWithArgs:));
                });
                
                it(@"should have called insertRow", ^{
                    sqliteManager should have_received(@selector(insertRow:)).with(@{
                                                                                     @"user_uri": @"user-uri",
                                                                                     @"project_access":@NO,
                                                                                     @"client_access":@NO,
                                                                                     @"project_task_selection_required":@NO,
                                                                                     @"activity_selection_required":@YES,
                                                                                     @"activity_access":@YES,
                                                                                     @"isPunchIntoProjectsUser":@NO,
                                                                                     @"break_access":@YES
                                                                                     });
                });
                
                it(@"should return empty resultSet for readLastRow", ^{
                    NSDictionary *resultSet = [subject.sqliteStore readLastRowWithArgs:@{@"user_uri": @"user-uri"}];
                    resultSet should be_nil;
                });
                
                
                it(@"should allow reading the punch rules but /*returns nothing as we are stubbing */", ^{
                    [subject canAccessProjectUserWithUri:@"user-uri"] should be_falsy;
                    [subject canAccessClientUserWithUri:@"user-uri"] should be_falsy;
                    [subject canAccessActivityUserWithUri:@"user-uri"] should be_falsy;
                    [subject isReporteePunchIntoProjectsUserWithUri:@"user-uri"] should be_falsy;
                    [subject isReporteeActivitySelectionRequired:@"user-uri"] should be_falsy;
                });
            });
            
            context(@"when the user already exist", ^{
                __block NSDictionary *expectedResultSet;
                beforeEach(^{
                    expectedResultSet = @{
                                          @"project_access" :@0,
                                          @"client_access" :@0,
                                          @"activity_access" :@1,
                                          @"project_task_selection_required":@0,
                                          @"activity_selection_required":@1,
                                          @"isPunchIntoProjectsUser":@0,
                                          @"user_uri" : @"user-uri",
                                           @"break_access" :@1
                                          };
                    
                    sqliteManager stub_method(@selector(readLastRowWithArgs:))
                    .with(@{@"user_uri" : @"user-uri"})
                    .and_return(expectedResultSet);
                    
                    [subject persistCanAccessProject:@NO
                                     canAccessClient:@NO
                                   canAccessActivity:@YES
                        projectTaskSelectionRequired:@NO
                           activitySelectionRequired:@YES
                              isPunchIntoProjectUser:@NO
                                             userUri:@"user-uri"
                     canAccessBreak:@YES];
                    
                    sqliteManager should have_received(@selector(readLastRowWithArgs:));
                });
                
                it(@"should have called updateRow", ^{
                    sqliteManager should have_received(@selector(updateRow:whereClause:)).with(expectedResultSet,@{@"user_uri": @"user-uri"});
                });
                
                it(@"should not return empty resultSet for readLastRow", ^{
                    NSDictionary *resultSet = [subject.sqliteStore readLastRowWithArgs:@{@"user_uri" : @"user-uri"}];
                    resultSet should equal(expectedResultSet);
                });
                
                it(@"should allow reading the punch rules", ^{
                    [subject canAccessProjectUserWithUri:@"user-uri"] should be_falsy;
                    [subject canAccessClientUserWithUri:@"user-uri"] should be_falsy;
                    [subject canAccessActivityUserWithUri:@"user-uri"] should be_truthy;
                    [subject isReporteeProjectTaskSelectionRequired:@"user-uri"] should be_falsy;
                    [subject isReporteePunchIntoProjectsUserWithUri:@"user-uri"] should be_falsy;
                    [subject isReporteeActivitySelectionRequired:@"user-uri"] should be_truthy;
                    [subject canAccessProjectUserWithUri:@"other-user-uri"] should be_falsy;
                    [subject canAccessClientUserWithUri:@"other-user-uri"] should be_falsy;
                    [subject canAccessActivityUserWithUri:@"other-user-uri"] should be_falsy;
                    [subject isReporteePunchIntoProjectsUserWithUri:@"other-user-uri"] should be_falsy;
                    [subject isReporteeActivitySelectionRequired:@"other-user-uri"] should be_falsy;
                    [subject canAccessBreaksUserWithUri:@"user-uri"] should be_truthy;
                    
                });
            });
        });

    });
});

SPEC_END
