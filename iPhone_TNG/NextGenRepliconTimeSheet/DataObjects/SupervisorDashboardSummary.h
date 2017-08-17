#import <Foundation/Foundation.h>


@interface SupervisorDashboardSummary : NSObject

@property (nonatomic, readonly) NSInteger timesheetsNeedingApprovalCount;
@property (nonatomic, readonly) NSInteger expensesNeedingApprovalCount;
@property (nonatomic, readonly) NSInteger timeOffRequestsNeedingApprovalCount;
@property (nonatomic, readonly) NSInteger clockedInUsersCount;
@property (nonatomic, readonly) NSInteger notInUsersCount;
@property (nonatomic, readonly) NSInteger onBreakUsersCount;
@property (nonatomic, readonly) NSInteger usersWithOvertimeHoursCount;
@property (nonatomic, readonly) NSInteger usersWithViolationsCount;
@property (nonatomic, readonly) NSArray *overtimeUsersArray;
@property (nonatomic, readonly) NSArray *employeesWithViolationsArray;




+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTimesheetsNeedingApprovalCount:(NSInteger)timesheetsNeedingApprovalCount
                          expensesNeedingApprovalCount:(NSInteger)expensesNeedingApprovalCount
                   timeOffRequestsNeedingApprovalCount:(NSInteger)timeOffRequestsNeedingApprovalCount
                                   clockedInUsersCount:(NSInteger)clockedInUsersCount
                                       notInUsersCount:(NSInteger)notInUsersCount
                                     onBreakUsersCount:(NSInteger)onBreakUsersCount
                           usersWithOvertimeHoursCount:(NSInteger)usersWithOvertimeHoursCount
                              usersWithViolationsCount:(NSInteger)usersWithViolationsCount
                                    overtimeUsersArray:(NSArray *)overtimeUsersArray
                          employeesWithViolationsArray:(NSArray *)employeesWithViolationsArray;

@end
