#import <Cedar/Cedar.h>
#import "SupervisorDashboardSummary.h"
#import "PunchUser.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(SupervisorDashboardSummarySpec)

describe(@"SupervisorDashboardSummary", ^{
    __block SupervisorDashboardSummary *subject;

    describe(NSStringFromSelector(@selector(initWithTimesheetsNeedingApprovalCount:expensesNeedingApprovalCount:timeOffRequestsNeedingApprovalCount:clockedInUsersCount:notInUsersCount:onBreakUsersCount:usersWithOvertimeHoursCount:usersWithViolationsCount:overtimeUsersArray:employeesWithViolationsArray:)), ^{
        it(@"should set the properties up correctly", ^{

            NSArray *expectedOvertimeUsersArray = [NSArray arrayWithObject:@"userA"];
            subject = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:2
                                                                    expensesNeedingApprovalCount:3
                                                             timeOffRequestsNeedingApprovalCount:4
                                                                             clockedInUsersCount:5
                                                                                 notInUsersCount:6
                                                                               onBreakUsersCount:7
                                                                     usersWithOvertimeHoursCount:8
                                                                        usersWithViolationsCount:9
                                                                              overtimeUsersArray:expectedOvertimeUsersArray
                                                                    employeesWithViolationsArray:nil];

            subject.timesheetsNeedingApprovalCount should equal(2);
            subject.expensesNeedingApprovalCount should equal(3);
            subject.timeOffRequestsNeedingApprovalCount should equal(4);
            subject.clockedInUsersCount should equal(5);
            subject.notInUsersCount should equal(6);
            subject.onBreakUsersCount should equal(7);
            subject.usersWithOvertimeHoursCount should equal(8);
            subject.usersWithViolationsCount should equal(9);
            subject.overtimeUsersArray should equal(expectedOvertimeUsersArray);
        });
    });

    describe(NSStringFromSelector(@selector(isEqual:)), ^{
        __block SupervisorDashboardSummary *dashboardSummaryA;
        __block SupervisorDashboardSummary *dashboardSummaryB;
        __block PunchUser *punchUserA;
        __block PunchUser *punchUserB;

        beforeEach(^{
            punchUserA = [[PunchUser alloc] initWithNameString:@"ullas"
                                                      imageURL:nil
                                                 addressString:nil
                                         regularDateComponents:nil
                                        overtimeDateComponents:nil
                                                 bookedTimeOff:nil];
            punchUserB = [[PunchUser alloc] initWithNameString:@"ullas"
                                                      imageURL:nil
                                                 addressString:nil
                                         regularDateComponents:nil
                                        overtimeDateComponents:nil
                                                 bookedTimeOff:nil];
        });

        it(@"should not be equal when comparing a different type of object", ^{
            dashboardSummaryA = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:2
                                                                              expensesNeedingApprovalCount:2
                                                                       timeOffRequestsNeedingApprovalCount:2
                                                                                       clockedInUsersCount:4
                                                                                           notInUsersCount:5
                                                                                         onBreakUsersCount:6
                                                                               usersWithOvertimeHoursCount:2
                                                                                  usersWithViolationsCount:9
                                                                                        overtimeUsersArray:@[punchUserA]
                                                                              employeesWithViolationsArray:nil];
            dashboardSummaryA should_not equal((SupervisorDashboardSummary *)[NSDate date]);
        });

        it(@"should not be equal when one of the members are not equal", ^{
            dashboardSummaryA = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:2
                                                                              expensesNeedingApprovalCount:2
                                                                       timeOffRequestsNeedingApprovalCount:2
                                                                                       clockedInUsersCount:2
                                                                                           notInUsersCount:2
                                                                                         onBreakUsersCount:2
                                                                               usersWithOvertimeHoursCount:2
                                                                                  usersWithViolationsCount:2
                                                                                        overtimeUsersArray:@[punchUserA]
                                                                              employeesWithViolationsArray:nil];

            dashboardSummaryB = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:0
                                                                              expensesNeedingApprovalCount:2
                                                                       timeOffRequestsNeedingApprovalCount:2
                                                                                       clockedInUsersCount:2
                                                                                           notInUsersCount:2
                                                                                         onBreakUsersCount:2
                                                                               usersWithOvertimeHoursCount:2
                                                                                  usersWithViolationsCount:2
                                                                                        overtimeUsersArray:@[punchUserB]
                                                                              employeesWithViolationsArray:nil];
            dashboardSummaryA should_not equal(dashboardSummaryB);

            dashboardSummaryB = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:2
                                                                              expensesNeedingApprovalCount:0
                                                                       timeOffRequestsNeedingApprovalCount:2
                                                                                       clockedInUsersCount:2
                                                                                           notInUsersCount:2
                                                                                         onBreakUsersCount:2
                                                                               usersWithOvertimeHoursCount:2
                                                                                  usersWithViolationsCount:2
                                                                                        overtimeUsersArray:@[punchUserB]
                                                                              employeesWithViolationsArray:nil];
            dashboardSummaryA should_not equal(dashboardSummaryB);

            dashboardSummaryB = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:2
                                                                              expensesNeedingApprovalCount:2
                                                                       timeOffRequestsNeedingApprovalCount:0
                                                                                       clockedInUsersCount:2
                                                                                           notInUsersCount:2
                                                                                         onBreakUsersCount:2
                                                                               usersWithOvertimeHoursCount:2
                                                                                  usersWithViolationsCount:2
                                                                                        overtimeUsersArray:@[punchUserB]
                                                                              employeesWithViolationsArray:nil];
            dashboardSummaryA should_not equal(dashboardSummaryB);

            dashboardSummaryB = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:2
                                                                              expensesNeedingApprovalCount:2
                                                                       timeOffRequestsNeedingApprovalCount:2
                                                                                       clockedInUsersCount:0
                                                                                           notInUsersCount:2
                                                                                         onBreakUsersCount:2
                                                                               usersWithOvertimeHoursCount:2
                                                                                  usersWithViolationsCount:2
                                                                                        overtimeUsersArray:@[punchUserB]
                                                                              employeesWithViolationsArray:nil];
            dashboardSummaryA should_not equal(dashboardSummaryB);

            dashboardSummaryB = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:2
                                                                              expensesNeedingApprovalCount:2
                                                                       timeOffRequestsNeedingApprovalCount:2
                                                                                       clockedInUsersCount:2
                                                                                           notInUsersCount:0
                                                                                         onBreakUsersCount:2
                                                                               usersWithOvertimeHoursCount:2
                                                                                  usersWithViolationsCount:2
                                                                                        overtimeUsersArray:@[punchUserB]
                                                                              employeesWithViolationsArray:nil];
            dashboardSummaryA should_not equal(dashboardSummaryB);

            dashboardSummaryB = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:2
                                                                              expensesNeedingApprovalCount:2
                                                                       timeOffRequestsNeedingApprovalCount:2
                                                                                       clockedInUsersCount:2
                                                                                           notInUsersCount:2
                                                                                         onBreakUsersCount:0
                                                                               usersWithOvertimeHoursCount:2
                                                                                  usersWithViolationsCount:2
                                                                                        overtimeUsersArray:@[punchUserB]
                                                                              employeesWithViolationsArray:nil];
            dashboardSummaryA should_not equal(dashboardSummaryB);

            dashboardSummaryB = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:2
                                                                              expensesNeedingApprovalCount:2
                                                                       timeOffRequestsNeedingApprovalCount:2
                                                                                       clockedInUsersCount:2
                                                                                           notInUsersCount:2
                                                                                         onBreakUsersCount:2
                                                                               usersWithOvertimeHoursCount:0
                                                                                  usersWithViolationsCount:2
                                                                                        overtimeUsersArray:@[punchUserB]
                                                                              employeesWithViolationsArray:nil];
            dashboardSummaryA should_not equal(dashboardSummaryB);

            dashboardSummaryB = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:2
                                                                              expensesNeedingApprovalCount:2
                                                                       timeOffRequestsNeedingApprovalCount:2
                                                                                       clockedInUsersCount:2
                                                                                           notInUsersCount:2
                                                                                         onBreakUsersCount:2
                                                                               usersWithOvertimeHoursCount:2
                                                                                  usersWithViolationsCount:0
                                                                                        overtimeUsersArray:@[punchUserB]
                                                                              employeesWithViolationsArray:nil];
            dashboardSummaryA should_not equal(dashboardSummaryB);


            punchUserB = [[PunchUser alloc] initWithNameString:@"Some new user"
                                                      imageURL:nil
                                                 addressString:nil
                                         regularDateComponents:nil
                                        overtimeDateComponents:nil
                                                 bookedTimeOff:nil];

            dashboardSummaryB = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:2
                                                                              expensesNeedingApprovalCount:2
                                                                       timeOffRequestsNeedingApprovalCount:2
                                                                                       clockedInUsersCount:2
                                                                                           notInUsersCount:2
                                                                                         onBreakUsersCount:2
                                                                               usersWithOvertimeHoursCount:2
                                                                                  usersWithViolationsCount:2
                                                                                        overtimeUsersArray:@[punchUserB]
                                                                              employeesWithViolationsArray:nil];
            dashboardSummaryA should_not equal(dashboardSummaryB);
        });

        it(@"should be equal when all of the members are equal", ^{
            dashboardSummaryA = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:2
                                                                              expensesNeedingApprovalCount:2
                                                                       timeOffRequestsNeedingApprovalCount:2
                                                                                       clockedInUsersCount:2
                                                                                           notInUsersCount:2
                                                                                         onBreakUsersCount:2
                                                                               usersWithOvertimeHoursCount:2
                                                                                  usersWithViolationsCount:0
                                                                                        overtimeUsersArray:@[punchUserA]
                                                                              employeesWithViolationsArray:nil];
            dashboardSummaryB = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:2
                                                                              expensesNeedingApprovalCount:2
                                                                       timeOffRequestsNeedingApprovalCount:2
                                                                                       clockedInUsersCount:2
                                                                                           notInUsersCount:2
                                                                                         onBreakUsersCount:2
                                                                               usersWithOvertimeHoursCount:2
                                                                                  usersWithViolationsCount:0
                                                                                        overtimeUsersArray:@[punchUserB]
                                                                              employeesWithViolationsArray:nil];
            dashboardSummaryA should equal(dashboardSummaryB);
        });
    });
});

SPEC_END
