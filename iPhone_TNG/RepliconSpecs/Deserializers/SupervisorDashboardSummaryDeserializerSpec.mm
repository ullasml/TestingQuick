#import <Cedar/Cedar.h>
#import "SupervisorDashboardSummaryDeserializer.h"
#import "RepliconSpecHelper.h"
#import "SupervisorDashboardSummary.h"
#import "PunchUserDeserializer.h"
#import "PunchUser.h"
#import "ViolationEmployee.h"
#import "Violation.h"
#import "Waiver.h"
#import "WaiverOption.h"
#import "Constants.h"
#import "BadgesDelegate.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(SupervisorDashboardSummaryDeserializerSpec)

describe(@"SupervisorDashboardSummaryDeserializer", ^{
    __block SupervisorDashboardSummaryDeserializer *subject;
    __block PunchUserDeserializer *punchUserDeserializer;
    __block NSArray *expectedOvertimeUsersArray;
    __block NSUserDefaults *testDefaults;
    __block id<BadgesDelegate> badgesDelegate;
    __block id<BSInjector, BSBinder> injector;
    __block NSNotificationCenter *notificationCenter;

    beforeEach(^{

        PunchUser *punchUser = [[PunchUser alloc] initWithNameString:@"punch"
                                                            imageURL:nil
                                                       addressString:nil
                                               regularDateComponents:nil
                                              overtimeDateComponents:nil
                                                       bookedTimeOff:nil];

        testDefaults = nice_fake_for([NSUserDefaults class]);


        expectedOvertimeUsersArray = [NSArray arrayWithObjects:punchUser, nil];
        punchUserDeserializer = nice_fake_for([PunchUserDeserializer class]);
        punchUserDeserializer stub_method(@selector(deserialize:)).and_return(punchUser);

        injector = [InjectorProvider injector];
        badgesDelegate = nice_fake_for(@protocol(BadgesDelegate));
        [injector bind:@protocol(BadgesDelegate) toInstance:badgesDelegate];

        notificationCenter = [[NSNotificationCenter alloc] init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];

        subject = [[SupervisorDashboardSummaryDeserializer alloc] initWithPunchUserDeserializer:punchUserDeserializer userdefaults:testDefaults badgesDelegate:badgesDelegate notificationCenter:nil];
    });

    describe(NSStringFromSelector(@selector(deserialize:)), ^{
        describe(@"deserializing a dictionary of JSON", ^{
            it(@"should return a correctly configured value object", ^{
                SupervisorDashboardSummary *expectedSummary = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:10
                                                                                                            expensesNeedingApprovalCount:1
                                                                                                     timeOffRequestsNeedingApprovalCount:3
                                                                                                                     clockedInUsersCount:2
                                                                                                                         notInUsersCount:5
                                                                                                                       onBreakUsersCount:4
                                                                                                             usersWithOvertimeHoursCount:8
                                                                                                                usersWithViolationsCount:9
                                                                                                                      overtimeUsersArray:expectedOvertimeUsersArray
                                                                                                            employeesWithViolationsArray:@[]];

                NSDictionary *summaryJSONDictionary = [RepliconSpecHelper jsonWithFixture:@"team_time_punch_overview_summary_response"];

                SupervisorDashboardSummary *summary = [subject deserialize:summaryJSONDictionary];

                summary should equal(expectedSummary);
            });

            it(@"should correctly deserializer employees with violations", ^{
                NSDictionary *summaryJSONDictionary = [RepliconSpecHelper jsonWithFixture:@"supervisor_dashboard_summary_response_with_violations"];
                SupervisorDashboardSummary *summary = [subject deserialize:summaryJSONDictionary];

                summary.employeesWithViolationsArray.count should equal(2);

                ViolationEmployee *roopesh = [summary.employeesWithViolationsArray firstObject];
                ViolationEmployee *wiley = [summary.employeesWithViolationsArray lastObject];

                roopesh.name should equal(@"Manjunatha, Roopesh");
                wiley.name should equal(@"Testing, Wiley");
            });

            it(@"should deserialize each employees violations", ^{
                NSDictionary *summaryJSONDictionary = [RepliconSpecHelper jsonWithFixture:@"supervisor_dashboard_summary_response_with_violations"];
                SupervisorDashboardSummary *summary = [subject deserialize:summaryJSONDictionary];

                summary.employeesWithViolationsArray.count should equal(2);

                ViolationEmployee *roopesh = [summary.employeesWithViolationsArray firstObject];
                NSArray *violations = [roopesh violations];

                [violations count] should equal(2);

                Violation *shoesViolation = [violations firstObject];
                [shoesViolation title] should equal(@"Silly shoes violation");
                [shoesViolation severity] should equal(ViolationSeverityError);
                [shoesViolation waiver] should be_nil;

                Violation *hatViolation = [violations lastObject];
                [hatViolation title] should equal(@"Silly hat violation");
                [hatViolation severity] should equal(ViolationSeverityInfo);
                Waiver *hatWaiver = [hatViolation waiver];
                hatWaiver.displayText should equal(@"To waive this violation, click the button below. Employees waives violation pay for this day.");

                ViolationEmployee *wiley = [summary.employeesWithViolationsArray lastObject];
                violations = [wiley violations];

                [violations count] should equal(2);

                Violation *beardViolation = [violations firstObject];
                [beardViolation title] should equal(@"Silly beard violation");
                [beardViolation severity] should equal(ViolationSeverityError);
                [beardViolation waiver] should be_nil;

                Violation *hairViolation = [violations lastObject];
                [hairViolation title] should equal(@"Silly hair violation");
                [hairViolation severity] should equal(ViolationSeverityWarning);
                
                Waiver *hairWaiver = [hairViolation waiver];
                hairWaiver.URI should equal(@"hair-uri");
                hairWaiver.displayText should equal(@"To waive this violation, click the button below. A barber will be dispatched immminently.");
                hairWaiver.selectedOption.displayText should equal(@"Waive Hair Penalty");
                hairWaiver.selectedOption.value should equal(@"accept");

                WaiverOption *option1 = [hairWaiver.options firstObject];
                option1.displayText should equal(@"Waive Hair Penalty");
                option1.value should equal(@"accept");

                WaiverOption *option2 = [hairWaiver.options lastObject];
                option2.displayText should equal(@"Do not Waive");
                option2.value should equal(@"reject");
            });

            it(@"should return a correct badge value for app icon", ^{

                subject.userdefaults stub_method(@selector(objectForKey:)).with(REJECTED_EXPENSE_SHEETS_COUNT_KEY).and_return([NSNumber numberWithInt:1]);
                subject.userdefaults stub_method(@selector(objectForKey:)).with(REJECTED_TIMEOFF_BOOKING_COUNT_KEY).and_return([NSNumber numberWithInt:2]);
                subject.userdefaults stub_method(@selector(objectForKey:)).with(REJECTED_TIMESHEET_COUNT_KEY).and_return([NSNumber numberWithInt:3]);
                subject.userdefaults stub_method(@selector(objectForKey:)).with(TIMESHEET_PAST_DUE_COUNT_KEY).and_return([NSNumber numberWithInt:4]);
                subject.userdefaults stub_method(@selector(objectForKey:)).with(PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY).and_return([NSNumber numberWithInt:5]);
                subject.userdefaults stub_method(@selector(objectForKey:)).with(PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY).and_return([NSNumber numberWithInt:6]);
                subject.userdefaults stub_method(@selector(objectForKey:)).with(PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY).and_return([NSNumber numberWithInt:7]);


                NSDictionary *summaryJSONDictionary = [RepliconSpecHelper jsonWithFixture:@"team_time_punch_overview_summary_response"];
                [subject deserialize:summaryJSONDictionary];
                badgesDelegate should have_received(@selector(updateBadgeValue:));
            });
        });
    });
});

SPEC_END
