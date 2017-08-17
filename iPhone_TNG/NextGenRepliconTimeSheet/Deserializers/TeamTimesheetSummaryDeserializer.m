#import "TeamTimesheetSummaryDeserializer.h"
#import "TeamTimesheetSummary.h"
#import "DateTimeComponentDeserializer.h"
#import "CurrencyValueDeserializer.h"
#import "TeamWorkHoursSummary.h"
#import "TeamTimesheetsForTimePeriod.h"
#import "TimesheetForUserWithWorkHours.h"
#import "TimesheetPeriod.h"
#import "Paycode.h"
#import "ActualsByPayCodeDeserializer.h"
#import "PayCodeHoursDeserializer.h"
#import "GrossHoursDeserializer.h"
#import "TimeSheetApprovalStatus.h"

@interface TeamTimesheetSummaryDeserializer ()

@property (nonatomic) DateTimeComponentDeserializer *dateTimeComponentsDeserializer;
@property (nonatomic) CurrencyValueDeserializer *currencyValueDeserializer;
@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) GrossHoursDeserializer *grossHoursDeserializer;
@property (nonatomic) ActualsByPayCodeDeserializer *actualsByPayCodeDeserializer;
@property (nonatomic) PayCodeHoursDeserializer *payCodeHoursDeserializer;

@property (nonatomic) NSNumberFormatter *numberFormatter;

@end


@implementation TeamTimesheetSummaryDeserializer

- (instancetype)initWithCurrencyValueDeserializer:(CurrencyValueDeserializer *)currencyValueDeserializer
                           grossHoursDeserializer:(GrossHoursDeserializer *)grossHoursDeserializer
                     actualsByPayCodeDeserializer:(ActualsByPayCodeDeserializer *)actualsByPayCodeDeserializer
                         payCodeHoursDeserializer:(PayCodeHoursDeserializer *)payCodeHoursDeserializer {
    self = [super init];
    if (self) {

        self.numberFormatter = [[NSNumberFormatter alloc] init];

        self.currencyValueDeserializer = currencyValueDeserializer;

        self.dateTimeComponentsDeserializer = [[DateTimeComponentDeserializer alloc] init];
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        self.calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        self.payCodeHoursDeserializer = payCodeHoursDeserializer;
        self.actualsByPayCodeDeserializer = actualsByPayCodeDeserializer;
        self.grossHoursDeserializer = grossHoursDeserializer;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (TeamTimesheetSummary *) deserialize:(NSDictionary *)jsonDictionary
{
    NSDictionary *dataDictionary = jsonDictionary[@"d"];
    NSDictionary *totalBreakHoursDictionary = dataDictionary[@"totalBreakHours"];
    NSDictionary *totalOvertimeHoursDictionary = dataDictionary[@"totalOvertimeHours"];
    NSDictionary *totalRegularHoursDictionary = dataDictionary[@"totalWorkingHours"];


    NSUInteger totalViolationsCount = [dataDictionary[@"totalValidationMessagesCount"] integerValue];
    NSDateComponents *totalBreakHoursComponents = [self.dateTimeComponentsDeserializer deserializeDateTime:totalBreakHoursDictionary];
    NSDateComponents *totalOvertimeHoursComponents = [self.dateTimeComponentsDeserializer deserializeDateTime:totalOvertimeHoursDictionary];
    NSDateComponents *totalRegularHoursComponents = [self.dateTimeComponentsDeserializer deserializeDateTime:totalRegularHoursDictionary];

    NSDictionary *previousPeriodDictionary = dataDictionary[@"previousPeriod"];
    NSDictionary *currentPeriodDictionary = dataDictionary[@"currentPeriod"];
    NSDictionary *nextPeriodDictionary = dataDictionary[@"nextPeriod"];

    TimesheetPeriod *previousPeriod = [self timesheetPeriodFromJSONDictionary:previousPeriodDictionary];
    TimesheetPeriod *currentPeriod = [self timesheetPeriodFromJSONDictionary:currentPeriodDictionary];
    TimesheetPeriod *nextPeriod = [self timesheetPeriodFromJSONDictionary:nextPeriodDictionary];

    NSDictionary *totalPayDictionary = dataDictionary[@"totalPayablePay"];
    CurrencyValue *totalPay = [self.currencyValueDeserializer deserializeForCurrencyValue:totalPayDictionary];

    NSArray *goldenTimeSheets = [self teamTimesheetUsersFromJSONArray:jsonDictionary[@"d"][@"goldenTimesheets"]];
    NSArray *nongoldenTimeSheets = [self teamTimesheetUsersFromJSONArray:jsonDictionary[@"d"][@"nongoldenTimesheets"]];

    TeamWorkHoursSummary *teamWorkHoursSummary = [[TeamWorkHoursSummary alloc] initWithOvertimeComponents:totalOvertimeHoursComponents
                                                                                    regularTimeComponents:totalRegularHoursComponents
                                                                                      breakTimeComponents:totalBreakHoursComponents
                                                                                        timeOffComponents:nil isScheduledDay:YES];

    BOOL payHoursDetailsPermission = NO;
    BOOL payAmountDetailsPermission = NO;
    id canViewPayableHoursDetails = dataDictionary[@"displayPayableHoursDetails"];
    id canViewPayablePayDetails = dataDictionary[@"displayPayableAmountDetails"];
    if (canViewPayableHoursDetails!=nil && canViewPayableHoursDetails != (id) [NSNull null]) {
        payHoursDetailsPermission= [canViewPayableHoursDetails boolValue];
    }
    if (canViewPayablePayDetails!=nil && canViewPayablePayDetails != (id) [NSNull null]) {
        payAmountDetailsPermission = [canViewPayablePayDetails boolValue];
    }
    
    NSArray *actualsByPayCodeArray = dataDictionary[@"actualsByPaycode"];

    NSMutableArray *actualsByPaycode = [[NSMutableArray alloc] init];
    NSMutableArray *actualsPayCodeDurationArray = [[NSMutableArray alloc] init];

    if(actualsByPayCodeArray!=nil && actualsByPayCodeArray!=(id)[NSNull null] && actualsByPayCodeArray.count>0)
    {
        for (NSDictionary *actualByPayCodeInfoDictionary in actualsByPayCodeArray)
        {
            Paycode *payCode= [self.actualsByPayCodeDeserializer deserializeForPayCodeDictionary:actualByPayCodeInfoDictionary];
            if (payCode!=nil && payCode!=(id)[NSNull null]) {

                [actualsByPaycode addObject:payCode];

                Paycode *payCodeDuration = [self.payCodeHoursDeserializer deserializeForHoursDictionary:actualByPayCodeInfoDictionary];
                if(payCodeDuration!=nil && payCodeDuration !=(id)[NSNull null])
                {
                    [actualsPayCodeDurationArray addObject:payCodeDuration];
                }
            }
        }
    }

    GrossHours *totalHours = [self.grossHoursDeserializer deserializeForHoursDictionary:dataDictionary[@"totalPayableHours"]];

    return [[TeamTimesheetSummary alloc] initWithTeamWorkHoursSummary:teamWorkHoursSummary
                                                 totalViolationsCount:totalViolationsCount
                                                  nongoldenTimesheets:nongoldenTimeSheets
                                                     goldenTimesheets:goldenTimeSheets
                                                       previousPeriod:previousPeriod
                                                        currentPeriod:currentPeriod
                                                           nextPeriod:nextPeriod
                                                             totalPay:totalPay
                                                           totalHours:totalHours
                                                     actualsByPayCode:actualsByPaycode
                                                 actualsByPayDuration:actualsPayCodeDurationArray
                                                  payAmountPermission:payAmountDetailsPermission
                                                   payHoursPermission:payHoursDetailsPermission];
}

#pragma mark - Private

- (TimesheetPeriod *)timesheetPeriodFromJSONDictionary:(NSDictionary *)jsonDictionary
{
    if(jsonDictionary != (id)[NSNull null])
    {
        NSDictionary *startDateDictionary = jsonDictionary[@"startDate"];
        NSDictionary *endDateDictionary = jsonDictionary[@"endDate"];
        
        NSDateComponents *startDateComponents = [self.dateTimeComponentsDeserializer deserializeDateTime:startDateDictionary];
        NSDateComponents *endDateComponents = [self.dateTimeComponentsDeserializer deserializeDateTime:endDateDictionary];
        
        NSDate *startDate = [self.calendar dateFromComponents:startDateComponents];
        NSDate *endDate = [self.calendar dateFromComponents:endDateComponents];
        
        return [[TimesheetPeriod alloc] initWithStartDate:startDate endDate:endDate];
    }
    return nil;
}

- (TimeSheetApprovalStatus *)timeSheetApprovalStatus:(NSDictionary *)approvalStatusDictionary {
    if(approvalStatusDictionary == (id)[NSNull null]) {
        return nil;
    }

    NSString *approvalStatusUri = approvalStatusDictionary[@"uri"];
    NSString *approvalStatus = approvalStatusDictionary[@"displayText"];
    TimeSheetApprovalStatus *approvalStatusObj = [[TimeSheetApprovalStatus alloc] initWithApprovalStatusUri:approvalStatusUri
                                                                                          approvalStatus:approvalStatus];
    return approvalStatusObj;
}

- (NSArray *)teamTimesheetUsersFromJSONArray:(NSArray *)jsonArray
{
    NSMutableArray *teamTimesheetsForTimePeriodArray = [[NSMutableArray alloc] init];

    for (NSDictionary *teamTimesheetsForTimePeriodDictionary in jsonArray) {
        NSDictionary  *startDateDictionary = teamTimesheetsForTimePeriodDictionary[@"timesheetPeriod"][@"startDate"];
        NSDictionary  *endDateDictionary = teamTimesheetsForTimePeriodDictionary[@"timesheetPeriod"][@"endDate"];

        NSDateComponents *startDateComponents = [self.dateTimeComponentsDeserializer deserializeDateTime:startDateDictionary];
        NSDateComponents *endDateComponents = [self.dateTimeComponentsDeserializer deserializeDateTime:endDateDictionary];

        NSDate *startDate = [self.calendar dateFromComponents:startDateComponents];
        NSDate *endDate = [self.calendar dateFromComponents:endDateComponents];

        NSArray *timesheetsForUsers = [self userTimesheetsFromJSONArray:teamTimesheetsForTimePeriodDictionary[@"timesheets"]];
        TeamTimesheetsForTimePeriod *teamTimesheetsForTimePeriod = [[TeamTimesheetsForTimePeriod alloc] initWithStartDate:startDate
                                                                                                                  endDate:endDate
                                                                                                               timesheets:timesheetsForUsers];
        [teamTimesheetsForTimePeriodArray addObject:teamTimesheetsForTimePeriod];
    }
    return teamTimesheetsForTimePeriodArray;
}

- (NSArray *)userTimesheetsFromJSONArray:(NSArray *)jsonArray
{
    NSMutableArray *usersTimesheets = [[NSMutableArray alloc] initWithCapacity:jsonArray.count];

    for (NSDictionary *timesheetDictionary in jsonArray) {
        NSString *timesheetURI = timesheetDictionary[@"timesheet"][@"uri"];
        NSString *userDisplayName = timesheetDictionary[@"owner"][@"displayText"];
        NSString *userURI = timesheetDictionary[@"owner"][@"uri"];
        NSNumber *validationCount = @([timesheetDictionary[@"totalValidationMessagesCount"] integerValue]);

        NSDateComponents *totalWorkingHours = [self.dateTimeComponentsDeserializer deserializeDateTime:timesheetDictionary[@"totalWorkingHours"]];
        NSDateComponents *totalBreakHours = [self.dateTimeComponentsDeserializer deserializeDateTime:timesheetDictionary[@"totalBreakHours"]];
        NSDateComponents *totalRegularHours = [self.dateTimeComponentsDeserializer deserializeDateTime:timesheetDictionary[@"totalRegularHours"]];
        NSDateComponents *totalOvertimeHours = [self.dateTimeComponentsDeserializer deserializeDateTime:timesheetDictionary[@"totalOvertimeHours"]];

        TimesheetPeriod *period = [self timesheetPeriodFromJSONDictionary:timesheetDictionary[@"timesheetPeriod"]];

        TimeSheetApprovalStatus *timeSheetApprovalStatus = [self timeSheetApprovalStatus:timesheetDictionary[@"timesheetStatus"]];

        TimesheetForUserWithWorkHours *timesheetUser = [[TimesheetForUserWithWorkHours alloc] initWithTotalOvertimeHours:totalOvertimeHours
                                                                                                       totalRegularHours:totalRegularHours
                                                                                                         totalBreakHours:totalBreakHours
                                                                                                          totalWorkHours:totalWorkingHours
                                                                                                         violationsCount:validationCount
                                                                                                                userName:userDisplayName
                                                                                                                 userURI:userURI
                                                                                                                  period:period
                                                                                                                     uri:timesheetURI
                                                                                                 timeSheetApprovalStatus:timeSheetApprovalStatus];
        [usersTimesheets addObject:timesheetUser];
    }

    return usersTimesheets;
}

@end
