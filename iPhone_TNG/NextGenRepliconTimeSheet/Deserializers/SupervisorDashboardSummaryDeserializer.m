#import "SupervisorDashboardSummaryDeserializer.h"
#import "SupervisorDashboardSummary.h"
#import "PunchUserDeserializer.h"
#import "ViolationEmployee.h"
#import "Violation.h"
#import "Constants.h"
#import "Waiver.h"
#import "WaiverOption.h"
#import "AppDelegate.h"
#import "BadgesDelegate.h"


@interface SupervisorDashboardSummaryDeserializer ()

@property (nonatomic) PunchUserDeserializer *punchUserDeserializer;
@property (nonatomic) NSUserDefaults *userdefaults;
@property (nonatomic, weak) id<BadgesDelegate> badgesDelegate;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@end


@implementation SupervisorDashboardSummaryDeserializer

- (instancetype)initWithPunchUserDeserializer:(PunchUserDeserializer *)punchUserDeserializer userdefaults:(NSUserDefaults *)userdefaults badgesDelegate:(id<BadgesDelegate>)badgesDelegate notificationCenter:(NSNotificationCenter *)notificationCenter {
    self = [super init];
    if (self) {
        self.punchUserDeserializer = punchUserDeserializer;
        self.userdefaults = userdefaults;
        self.badgesDelegate = badgesDelegate;
        self.notificationCenter = notificationCenter;
    }
    return self;
}

- (SupervisorDashboardSummary *)deserialize:(NSDictionary *)summaryDictionary
{
    NSDictionary *dataDictionary = [summaryDictionary objectForKey:@"d"];
    NSDictionary *approvalsPendingDictionary = [dataDictionary objectForKey:@"approvalsPending"];
    NSInteger timesheetsNeedingApprovalCount = [[approvalsPendingDictionary objectForKey:@"pendingTimesheetApprovalCount"] integerValue];
    NSInteger expensesNeedingApprovalCount = [[approvalsPendingDictionary objectForKey:@"pendingExpenseSheetApprovalCount"] integerValue];
    NSInteger timeOffRequestsNeedingApprovalCount = [[approvalsPendingDictionary objectForKey:@"pendingTimeOffApprovalCount"] integerValue];
    

    [self.userdefaults setObject:[NSNumber numberWithInteger:timesheetsNeedingApprovalCount] forKey:PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY];
    [self.userdefaults setObject:[NSNumber numberWithInteger:expensesNeedingApprovalCount] forKey:PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY];
    [self.userdefaults setObject:[NSNumber numberWithInteger:timeOffRequestsNeedingApprovalCount] forKey:PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY];
    [self.userdefaults synchronize];

    
    [self.badgesDelegate updateBadgeValue:nil];


    NSInteger clockedInUsersCount = [[dataDictionary objectForKey:@"totalClockedInUsersCount"] integerValue];
    NSInteger notInUsersCount = [[dataDictionary objectForKey:@"totalNotInUsersCount"] integerValue];
    NSInteger onBreakUsersCount = [[dataDictionary objectForKey:@"totalOnBreakUsersCount"] integerValue];
    NSInteger usersWithOvertimeHoursCount = [[dataDictionary objectForKey:@"totalUsersWithOvertimeHoursCount"] integerValue];
    NSInteger usersWithViolationsCount = [[dataDictionary objectForKey:@"totalTimePunchAndTimesheetViolationsCount"] integerValue];


    NSArray *overtimeUsersArray = [dataDictionary objectForKey:@"overtimeUsersDetails"];

    NSArray *employeesWithTimesheetViolations = dataDictionary[@"timesheetValidationSummary"];
    NSArray *employeesWithPunchViolations = dataDictionary[@"timePunchValidationSummary"];

    NSArray *allEmployeesWithAllViolations = [employeesWithTimesheetViolations arrayByAddingObjectsFromArray:employeesWithPunchViolations];

    NSMutableArray *employeesWithViolations = [NSMutableArray arrayWithCapacity:employeesWithTimesheetViolations.count + employeesWithPunchViolations.count];

    NSMutableDictionary *allEmployeeViolationsTempStorage = [NSMutableDictionary dictionary];

    for (NSDictionary *employeeAndValidationResultDictionary in allEmployeesWithAllViolations) {

        NSDictionary *employeeDictionary = employeeAndValidationResultDictionary[@"user"];
        NSString *employeeURI = employeeDictionary[@"uri"];
        if (!allEmployeeViolationsTempStorage[employeeURI]) {
            allEmployeeViolationsTempStorage[employeeURI] = [NSMutableDictionary dictionary];
            allEmployeeViolationsTempStorage[employeeURI][@"violations"] = [NSMutableArray array];
        }

        NSMutableDictionary *mutableEmployeeInfo = allEmployeeViolationsTempStorage[employeeURI];
        mutableEmployeeInfo[@"name"] = employeeDictionary[@"displayText"];

        NSDictionary *violationsDictionary = employeeAndValidationResultDictionary[@"validationResult"];
        NSArray *violationMessages = violationsDictionary[@"validationMessages"];
        NSMutableArray *violations = mutableEmployeeInfo[@"violations"];
        for (NSDictionary *violationMessageDictionary in violationMessages) {
            NSString *violationTitle = violationMessageDictionary[@"displayText"];
            NSString *severityURI = violationMessageDictionary[@"severity"];

            ViolationSeverity severity = ViolationSeverityUnknown;
            if ([severityURI isEqualToString:GEN4_TIMESHEET_ERROR_URI]) {
                severity = ViolationSeverityError;
            } else if ([severityURI isEqualToString:GEN4_TIMESHEET_WARNING_URI]) {
                severity = ViolationSeverityWarning;
            } else if ([severityURI isEqualToString:GEN4_TIMESHEET_INFORMATION_URI]) {
                severity = ViolationSeverityInfo;
            }


            NSDictionary *waiverDictionary = violationMessageDictionary[@"waiver"];
            Waiver *waiver = nil;
            if (waiverDictionary != (id)[NSNull null])
            {
                NSString *displayText = waiverDictionary[@"displayText"];

                NSMutableArray *mutableOptions = [NSMutableArray array];
                for (NSDictionary *waiverOptionsDictionary in waiverDictionary[@"options"]) {
                    NSString *waiverOptionDisplayText = waiverOptionsDictionary[@"displayText"];
                    NSString *waiverOptionValue = waiverOptionsDictionary[@"value"];
                    WaiverOption *waiverOption = [[WaiverOption alloc] initWithDisplayText:waiverOptionDisplayText value:waiverOptionValue];
                    [mutableOptions addObject:waiverOption];
                }

                WaiverOption *selectedOption = nil;
                NSDictionary *selectedOptionDictionary = waiverDictionary[@"selectedOption"];
                if (selectedOptionDictionary != (id)[NSNull null]) {
                    NSString *selectedOptionValue = selectedOptionDictionary[@"optionValue"];
                    for (WaiverOption *waiverOption in mutableOptions) {
                        if ([waiverOption.value isEqualToString:selectedOptionValue]) {
                            selectedOption = waiverOption;
                        }
                    }
                }

                waiver = [[Waiver alloc] initWithURI:waiverDictionary[@"uri"]
                                         displayText:displayText
                                             options:[mutableOptions copy]
                                      selectedOption:selectedOption];
            }

            Violation *violation = [[Violation alloc] initWithSeverity:severity
                                                                waiver:waiver
                                                                 title:violationTitle];

            [violations addObject:violation];
        }
    }

    for (NSString *uri in allEmployeeViolationsTempStorage) {
        NSDictionary *employeeDictionary = allEmployeeViolationsTempStorage[uri];
        NSString *name = employeeDictionary[@"name"];
        NSArray *violations = employeeDictionary[@"violations"];

        violations = [violations sortedArrayUsingSelector:@selector(severity)];

        ViolationEmployee *violationEmployee = [[ViolationEmployee alloc] initWithName:name uri:uri violations:violations];
        [employeesWithViolations addObject:violationEmployee];
    }


    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [employeesWithViolations sortUsingDescriptors:@[sortDescriptor]];

    NSMutableArray *usersOnOvertimeArray = [NSMutableArray arrayWithCapacity:[overtimeUsersArray count]];
    for (NSDictionary *overtimeUserDictionary in overtimeUsersArray)
    {
        PunchUser *punchUser = [self.punchUserDeserializer deserialize:overtimeUserDictionary];
        [usersOnOvertimeArray addObject:punchUser];
    }


    return [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:timesheetsNeedingApprovalCount
                                                         expensesNeedingApprovalCount:expensesNeedingApprovalCount
                                                  timeOffRequestsNeedingApprovalCount:timeOffRequestsNeedingApprovalCount
                                                                  clockedInUsersCount:clockedInUsersCount
                                                                      notInUsersCount:notInUsersCount
                                                                    onBreakUsersCount:onBreakUsersCount
                                                          usersWithOvertimeHoursCount:usersWithOvertimeHoursCount
                                                             usersWithViolationsCount:usersWithViolationsCount
                                                                   overtimeUsersArray:usersOnOvertimeArray
                                                         employeesWithViolationsArray:employeesWithViolations];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
