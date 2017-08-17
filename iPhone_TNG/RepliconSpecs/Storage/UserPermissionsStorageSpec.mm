#import <MacTypes.h>
#import <Cedar/Cedar.h>
#import "UserPermissionsStorage.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "SQLiteTableStore.h"
#import "QueryStringBuilder.h"
#import "UserSession.h"
#import "SQLiteDatabaseConnection.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(UserPermissionsStorageSpec)

describe(@"UserPermissionsStorage", ^{
    __block UserPermissionsStorage *subject;
    __block SQLiteTableStore *sqliteManager;

    beforeEach(^{
        id<UserSession> userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");

        sqliteManager = [[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                      databaseName:@"Test"
                                                                         tableName:@"user_permissions"];
        spy_on(sqliteManager);

        subject = [[UserPermissionsStorage alloc] initWithSQLiteStore:sqliteManager
                                                          userSession:userSession];
    });

    describe(@"-persistGeolocationRequired:breaksRequired:selfieRequired:canEditTimePunch:isAstroPunchUser:canApproveTimesheets:canApproveExpenses:canApproveTimeoffs:isExpensesProjectMandatory:hasTimePunchAccess:", ^{

        context(@"when the user doesn't exist", ^{
            beforeEach(^{
                sqliteManager stub_method(@selector(readLastRowWithArgs:)).and_return(nil);
                [subject persistIsExpensesProjectMandatory:@YES
                                 isWidgetPlatformSupported:@YES
                                      canApproveTimesheets:@YES
                                      canEditNonTimeFields:@YES
                                       geolocationRequired:@YES
                                        canApproveExpenses:@YES
                                        canApproveTimeoffs:@YES
                                       isActivityMandatory:@YES
                                        isProjectMandatory:@YES
                                        hasTimesheetAccess:@YES
                                         hasActivityAccess:@YES
                                          hasProjectAccess:@YES
                                           hasClientAccess:@YES
                                          canEditTimePunch:@YES
                                          isAstroPunchUser:@YES
                                         canViewPayDetails:@YES
                                          canViewTeamPunch:@YES
                                            breaksRequired:@YES
                                            selfieRequired:@YES
                                        hasTimePunchAccess:@YES
                                      canViewTeamTimesheet:@YES
                                          canEditTimesheet:@YES
                                      canEditTeamTimePunch:@YES 
                                       isSimpleInOutWidget:@YES
                                  hasManualTimePunchAccess:@YES];

                sqliteManager should have_received(@selector(readLastRowWithArgs:));
            });

            it(@"should have called insertRow", ^{
                sqliteManager should have_received(@selector(insertRow:)).with(@{@"geolocation_required": @YES,
                                                                                 @"can_edit_time_punch": @YES,
                                                                                 @"is_astro_punch_user": @YES,
                                                                                 @"breaks_required": @YES,
                                                                                 @"selfie_required": @YES,
                                                                                 @"can_view_pay_details": @YES,
                                                                                 @"has_Timesheet_Access": @YES,
                                                                                 @"can_approve_timesheets": @YES,
                                                                                 @"can_approve_expenses": @YES,
                                                                                 @"can_approve_timeoffs": @YES,
                                                                                 @"can_view_team_punch":@YES,
                                                                                 @"user_uri": @"user:uri",
                                                                                 @"project_access":@YES,
                                                                                 @"client_access":@YES,
                                                                                 @"activity_access":@YES,
                                                                                 @"project_task_selection_required":@YES,
                                                                                 @"canEditNonTimeFields":@YES,
                                                                                 @"isExpensesProjectMandatory":@YES,
                                                                                 @"activity_selection_required":@YES,
                                                                                 @"hasTimePunchAccess":@YES,
                                                                                 @"canViewTeamTimesheet":@YES,
                                                                                 @"can_edit_timesheet":@YES,
                                                                                 @"can_edit_team_time_punch":@YES,
                                                                                 @"isSimpleInOutWidget":@YES,
                                                                                 @"isWidgetPlatformSupported":@YES,
                                                                                 @"hasManualTimePunchAccess":@YES
                                                                                 });
            });

            it(@"should return empty resultSet for readLastRow", ^{
                NSDictionary *resultSet = [subject.sqliteStore readLastRowWithArgs:@{@"user_uri": @"user:uri"}];
                resultSet should be_nil;
            });

            it(@"should persist the punch rules through its sqlite manager", ^{
                id<UserSession> userSession = nice_fake_for(@protocol(UserSession));
                userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
                UserPermissionsStorage *otherStorage = [[UserPermissionsStorage alloc] initWithSQLiteStore:sqliteManager
                                                                                               userSession:userSession];
                otherStorage.geolocationRequired should be_falsy;
                sqliteManager should have_received(@selector(readLastRowWithArgs:)).with(@{@"user_uri": @"user:uri"});
            });

            it(@"should allow reading the punch rules but /*returns nothing as we are stubbing */", ^{
                subject.geolocationRequired should be_falsy;
                subject.breaksRequired should be_falsy;
                subject.selfieRequired should be_falsy;
                subject.canEditTimePunch should be_falsy;
                subject.isAstroPunchUser should be_falsy;
                subject.canViewPayDetails should be_falsy;
                subject.hasTimesheetAccess should be_falsy;
                subject.canApproveTimeoffs should be_falsy;
                subject.canApproveExpenses should be_falsy;
                subject.canApproveTimesheets should be_falsy;
                subject.canViewTeamPunch should be_falsy;
                subject.hasProjectAccess should be_falsy;
                subject.hasClientAccess should be_falsy;
                subject.hasActivityAccess should be_falsy;
                subject.isProjectTaskSelectionRequired should be_falsy;
                subject.canEditNonTimeFields should be_falsy;
                subject.isActivitySelectionRequired should be_falsy;
                subject.hasTimePunchAccess should be_falsy;
                subject.canEditTimesheet should be_falsy;
                subject.canEditTeamTimePunch should be_falsy;
                subject.isSimpleInOutWidget should be_falsy;
                subject.isWidgetPlatformSupported should be_falsy;
            });
        });

        context(@"when the user already exist", ^{
            __block NSDictionary *expectedResultSet;
            beforeEach(^{
                expectedResultSet = @{
                                      @"geolocation_required"           :@1,
                                      @"breaks_required"                :@1,
                                      @"selfie_required"                :@1,
                                      @"can_edit_time_punch"            :@1,
                                      @"is_astro_punch_user"            :@1,
                                      @"can_view_pay_details"           :@1,
                                      @"has_Timesheet_Access"           :@1,
                                      @"can_approve_timesheets"         :@1,
                                      @"can_approve_expenses"           :@1,
                                      @"can_approve_timeoffs"           :@1,
                                      @"can_view_team_punch"            :@1,
                                      @"project_access"                 :@1,
                                      @"client_access"                  :@1,
                                      @"activity_access"                :@1,
                                      @"project_task_selection_required":@1,
                                      @"user_uri"                       :@"user:uri",
                                      @"canEditNonTimeFields"           :@1,
                                      @"isExpensesProjectMandatory"     :@1,
                                      @"activity_selection_required"    :@1,
                                      @"hasTimePunchAccess"             :@1,
                                      @"canViewTeamTimesheet"           :@1,
                                      @"can_edit_timesheet"             :@1,
                                      @"can_edit_team_time_punch"       :@1,
                                      @"isSimpleInOutWidget"            :@1,
                                      @"isWidgetPlatformSupported"      :@1,
                                      @"hasManualTimePunchAccess"       :@1
                                    };

                sqliteManager stub_method(@selector(readLastRowWithArgs:))
                .with(@{@"user_uri" : @"user:uri"})
                .and_return(expectedResultSet);

                [subject persistIsExpensesProjectMandatory:@YES
                                 isWidgetPlatformSupported:@YES
                                      canApproveTimesheets:@YES
                                      canEditNonTimeFields:@YES
                                       geolocationRequired:@YES
                                        canApproveExpenses:@YES
                                        canApproveTimeoffs:@YES
                                       isActivityMandatory:@YES
                                        isProjectMandatory:@YES
                                        hasTimesheetAccess:@YES
                                         hasActivityAccess:@YES
                                          hasProjectAccess:@YES
                                           hasClientAccess:@YES
                                          canEditTimePunch:@YES
                                          isAstroPunchUser:@YES
                                         canViewPayDetails:@YES
                                          canViewTeamPunch:@YES
                                            breaksRequired:@YES
                                            selfieRequired:@YES
                                        hasTimePunchAccess:@YES
                                      canViewTeamTimesheet:@YES
                                          canEditTimesheet:@YES
                                      canEditTeamTimePunch:@YES 
                                       isSimpleInOutWidget:@YES
                                  hasManualTimePunchAccess:@YES];

                sqliteManager should have_received(@selector(readLastRowWithArgs:));
            });

            it(@"should have called updateRow", ^{
                sqliteManager should have_received(@selector(updateRow:whereClause:)).with(expectedResultSet,nil);
            });

            it(@"should not return empty resultSet for readLastRow", ^{
                NSDictionary *resultSet = [subject.sqliteStore readLastRowWithArgs:@{@"user_uri" : @"user:uri"}];
                resultSet should_not be_nil;
            });

            it(@"should persist the punch rules through its sqlite manager", ^{
                id<UserSession> userSession = nice_fake_for(@protocol(UserSession));
                userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
                UserPermissionsStorage *otherStorage = [[UserPermissionsStorage alloc] initWithSQLiteStore:sqliteManager userSession:userSession];
                otherStorage.geolocationRequired should be_truthy;
                sqliteManager should have_received(@selector(readLastRowWithArgs:)).with(@{@"user_uri" : @"user:uri"});
            });

            it(@"should allow reading the punch rules", ^{
                subject.geolocationRequired should be_truthy;
                subject.breaksRequired should be_truthy;
                subject.selfieRequired should be_truthy;
                subject.canEditTimePunch should be_truthy;
                subject.isAstroPunchUser should be_truthy;
                subject.canViewPayDetails should be_truthy;
                subject.hasTimesheetAccess should be_truthy;
                subject.canApproveTimeoffs should be_truthy;
                subject.canApproveExpenses should be_truthy;
                subject.canApproveTimesheets should be_truthy;
                subject.canViewTeamPunch should be_truthy;
                subject.hasProjectAccess should be_truthy;
                subject.hasClientAccess should be_truthy;
                subject.hasActivityAccess should be_truthy;
                subject.isProjectTaskSelectionRequired should be_truthy;
                subject.canEditNonTimeFields should be_truthy;
                subject.isActivitySelectionRequired should be_truthy;
                subject.hasTimePunchAccess should be_truthy;
                subject.canViewTeamTimesheet should be_truthy;
                subject.canEditTimesheet should be_truthy;
                subject.canEditTeamTimePunch should be_truthy;
                subject.isSimpleInOutWidget should be_truthy;
                subject.isWidgetPlatformSupported should be_truthy;
            });
            
        });
        
        context(@"when sql migration happens, added new permission(field) in permission storage. when new permission is not updated with server response and DB stored value is <null>, app should always return false for that permission ", ^{
            __block NSDictionary *expectedResultSet;
            beforeEach(^{
                expectedResultSet = @{
                                      @"geolocation_required"           :@1,
                                      @"breaks_required"                :@1,
                                      @"selfie_required"                :@1,
                                      @"can_edit_time_punch"            :@1,
                                      @"is_astro_punch_user"            :@1,
                                      @"can_view_pay_details"           :@1,
                                      @"has_Timesheet_Access"           :@1,
                                      @"can_approve_timesheets"         :@1,
                                      @"can_approve_expenses"           :@1,
                                      @"can_approve_timeoffs"           :@1,
                                      @"can_view_team_punch"            :@1,
                                      @"project_access"                 :@1,
                                      @"client_access"                  :@1,
                                      @"activity_access"                :@1,
                                      @"project_task_selection_required":@1,
                                      @"user_uri"                       :@"user:uri",
                                      @"canEditNonTimeFields"           :@1,
                                      @"isExpensesProjectMandatory"     :@1,
                                      @"activity_selection_required"    :@1,
                                      @"hasTimePunchAccess"             :@1,
                                      @"canViewTeamTimesheet"           :@1,
                                      @"can_edit_timesheet"             :@1,
                                      @"can_edit_team_time_punch"       :@1,
                                      @"isSimpleInOutWidget"            :(id)[NSNull null],
                                      @"isWidgetPlatformSupported"      :@1,
                                      @"hasManualTimePunchAccess"       :@1
                                      };
                
                sqliteManager stub_method(@selector(readLastRowWithArgs:))
                .with(@{@"user_uri" : @"user:uri"})
                .and_return(expectedResultSet);

                [subject persistIsExpensesProjectMandatory:@YES
                                 isWidgetPlatformSupported:@YES
                                      canApproveTimesheets:@YES
                                      canEditNonTimeFields:@YES
                                       geolocationRequired:@YES
                                        canApproveExpenses:@YES
                                        canApproveTimeoffs:@YES
                                       isActivityMandatory:@YES
                                        isProjectMandatory:@YES
                                        hasTimesheetAccess:@YES
                                         hasActivityAccess:@YES
                                          hasProjectAccess:@YES
                                           hasClientAccess:@YES
                                          canEditTimePunch:@YES
                                          isAstroPunchUser:@YES
                                         canViewPayDetails:@YES
                                          canViewTeamPunch:@YES
                                            breaksRequired:@YES
                                            selfieRequired:@YES
                                        hasTimePunchAccess:@YES
                                      canViewTeamTimesheet:@YES
                                          canEditTimesheet:@YES
                                      canEditTeamTimePunch:@YES
                                       isSimpleInOutWidget:(id)[NSNull null]
                                  hasManualTimePunchAccess:@YES];
                
                sqliteManager should have_received(@selector(readLastRowWithArgs:));
            });
            
            it(@"should have called updateRow", ^{
                sqliteManager should have_received(@selector(updateRow:whereClause:)).with(expectedResultSet,nil);
            });
            
            it(@"should not return empty resultSet for readLastRow", ^{
                NSDictionary *resultSet = [subject.sqliteStore readLastRowWithArgs:@{@"user_uri" : @"user:uri"}];
                resultSet should_not be_nil;
            });
            
            it(@"should persist the punch rules through its sqlite manager", ^{
                id<UserSession> userSession = nice_fake_for(@protocol(UserSession));
                userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
                UserPermissionsStorage *otherStorage = [[UserPermissionsStorage alloc] initWithSQLiteStore:sqliteManager userSession:userSession];
                otherStorage.geolocationRequired should be_truthy;
                sqliteManager should have_received(@selector(readLastRowWithArgs:)).with(@{@"user_uri" : @"user:uri"});
            });
            
            it(@"should allow reading the punch rules", ^{
                subject.geolocationRequired should be_truthy;
                subject.breaksRequired should be_truthy;
                subject.selfieRequired should be_truthy;
                subject.canEditTimePunch should be_truthy;
                subject.isAstroPunchUser should be_truthy;
                subject.canViewPayDetails should be_truthy;
                subject.hasTimesheetAccess should be_truthy;
                subject.canApproveTimeoffs should be_truthy;
                subject.canApproveExpenses should be_truthy;
                subject.canApproveTimesheets should be_truthy;
                subject.canViewTeamPunch should be_truthy;
                subject.hasProjectAccess should be_truthy;
                subject.hasClientAccess should be_truthy;
                subject.hasActivityAccess should be_truthy;
                subject.isProjectTaskSelectionRequired should be_truthy;
                subject.canEditNonTimeFields should be_truthy;
                subject.isActivitySelectionRequired should be_truthy;
                subject.hasTimePunchAccess should be_truthy;
                subject.canViewTeamTimesheet should be_truthy;
                subject.canEditTimesheet should be_truthy;
                subject.canEditTeamTimePunch should be_truthy;
                subject.isSimpleInOutWidget should be_falsy;
                subject.isWidgetPlatformSupported should be_truthy;
            });
            
        });
    });
});

SPEC_END
