#import "SupervisorDashboardSummary.h"


@interface SupervisorDashboardSummary ()

@property (nonatomic) NSInteger timesheetsNeedingApprovalCount;
@property (nonatomic) NSInteger expensesNeedingApprovalCount;
@property (nonatomic) NSInteger timeOffRequestsNeedingApprovalCount;
@property (nonatomic) NSInteger clockedInUsersCount;
@property (nonatomic) NSInteger notInUsersCount;
@property (nonatomic) NSInteger onBreakUsersCount;
@property (nonatomic) NSInteger usersWithOvertimeHoursCount;
@property (nonatomic) NSInteger usersWithViolationsCount;
@property (nonatomic) NSArray *overtimeUsersArray;
@property (nonatomic) NSArray *employeesWithViolationsArray;

@end

@implementation SupervisorDashboardSummary

- (instancetype)initWithTimesheetsNeedingApprovalCount:(NSInteger)timesheetsNeedingApprovalCount
                          expensesNeedingApprovalCount:(NSInteger)expensesNeedingApprovalCount
                   timeOffRequestsNeedingApprovalCount:(NSInteger)timeOffRequestsNeedingApprovalCount
                                   clockedInUsersCount:(NSInteger)clockedInUsersCount
                                       notInUsersCount:(NSInteger)notInUsersCount
                                     onBreakUsersCount:(NSInteger)onBreakUsersCount
                           usersWithOvertimeHoursCount:(NSInteger)usersWithOvertimeHoursCount
                              usersWithViolationsCount:(NSInteger)usersWithViolationsCount
                                    overtimeUsersArray:(NSArray *)overtimeUsersArray
                          employeesWithViolationsArray:(NSArray *)employeesWithViolationsArray
{
    self = [super init];

    if (self) {
        self.timesheetsNeedingApprovalCount = timesheetsNeedingApprovalCount;
        self.expensesNeedingApprovalCount = expensesNeedingApprovalCount;
        self.timeOffRequestsNeedingApprovalCount = timeOffRequestsNeedingApprovalCount;
        self.clockedInUsersCount = clockedInUsersCount;
        self.notInUsersCount = notInUsersCount;
        self.onBreakUsersCount = onBreakUsersCount;
        self.usersWithOvertimeHoursCount = usersWithOvertimeHoursCount;
        self.usersWithViolationsCount = usersWithViolationsCount;
        self.overtimeUsersArray = overtimeUsersArray;
        self.employeesWithViolationsArray = employeesWithViolationsArray;
    }
    
    return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(SupervisorDashboardSummary *)otherDashboardSummary
{
    if(![otherDashboardSummary isKindOfClass:[self class]]) {
        return NO;
    }

    BOOL timesheetsNeedingApprovalCountEqual = (otherDashboardSummary.timesheetsNeedingApprovalCount == self.timesheetsNeedingApprovalCount);
    BOOL expensesNeedingApprovalCountEqual = (otherDashboardSummary.expensesNeedingApprovalCount == self.expensesNeedingApprovalCount);
    BOOL timeOffRequestsNeedingApprovalCountEqual = (otherDashboardSummary.timeOffRequestsNeedingApprovalCount == self.timeOffRequestsNeedingApprovalCount);
    BOOL clockedInUsersCountEqual = (otherDashboardSummary.clockedInUsersCount == self.clockedInUsersCount);
    BOOL notInUsersCountEqual = (otherDashboardSummary.notInUsersCount == self.notInUsersCount);
    BOOL onBreakUsersCountEqual = (otherDashboardSummary.onBreakUsersCount == self.onBreakUsersCount);
    BOOL usersWithOvertimeHoursCountEqual = (otherDashboardSummary.usersWithOvertimeHoursCount == self.usersWithOvertimeHoursCount);
    BOOL usersWithViolationsCountEqual = (otherDashboardSummary.usersWithViolationsCount == self.usersWithViolationsCount);
    BOOL overtimeUsersArraysEqual = ((!self.overtimeUsersArray && !otherDashboardSummary.overtimeUsersArray) || [self.overtimeUsersArray isEqualToArray:otherDashboardSummary.overtimeUsersArray]);
    BOOL employeesWithViolationsArraysEqual = ((!self.employeesWithViolationsArray && !otherDashboardSummary.employeesWithViolationsArray) || [self.employeesWithViolationsArray isEqualToArray:otherDashboardSummary.employeesWithViolationsArray]);


    return timesheetsNeedingApprovalCountEqual
        && expensesNeedingApprovalCountEqual
        && timeOffRequestsNeedingApprovalCountEqual
        && clockedInUsersCountEqual
        && notInUsersCountEqual
        && onBreakUsersCountEqual
        && usersWithOvertimeHoursCountEqual
        && usersWithViolationsCountEqual
        && overtimeUsersArraysEqual
        && employeesWithViolationsArraysEqual;
}

@end
