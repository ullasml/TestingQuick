#import "TimesheetInfoDeserializer.h"
#import "TimePeriodSummary.h"
#import "DayTimeSummary.h"
#import "CurrencyValue.h"
#import "CurrencyValueDeserializer.h"
#import "GrossHoursDeserializer.h"
#import "GrossHours.h"
#import "ActualsByPayCodeDeserializer.h"
#import "Paycode.h"
#import "PayCodeDuration.h"
#import "PayCodeHoursDeserializer.h"
#import "TimeSheetApprovalStatus.h"
#import "TimeSheetPermittedActions.h"
#import "TimesheetInfo.h"
#import "DateTimeComponentDeserializer.h"
#import "Period.h"
#import "TimesheetDaySummary.h"
#import "RemotePunch.h"
#import "RemotePunchDeserializer.h"
#import "TimesheetPeriod.h"

@interface TimesheetInfoDeserializer ()

@property (nonatomic) CurrencyValueDeserializer *currencyValueDeserializer;
@property (nonatomic) GrossHoursDeserializer *grossHoursDeserializer;
@property (nonatomic) ActualsByPayCodeDeserializer *actualsByPayCodeDeserializer;
@property (nonatomic) PayCodeHoursDeserializer *payCodeHoursDeserializer;
@property (nonatomic) RemotePunchDeserializer *remotePunchDeserializer;
@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) NSNumberFormatter *numberFormatter;
@property (nonatomic) NSDateFormatter *dateFormatterShortDate;
@property (nonatomic) NSDateFormatter *dateFormatterShortTime;


@end


@implementation TimesheetInfoDeserializer

- (instancetype)initWithCurrencyValueDeserializer:(CurrencyValueDeserializer *)currencyValueDeserializer
                     actualsByPayCodeDesirializer:(ActualsByPayCodeDeserializer *)actualsByPayCodeDeserializer
                         payCodeHoursDeserializer:(PayCodeHoursDeserializer *)payCodeHoursDeserializer
                          remotePunchDeserializer:(RemotePunchDeserializer *)remotePunchDeserializer
                             grossHoursSerializer:(GrossHoursDeserializer *)grossHoursDeserializer
                           dateFormatterShortDate:(NSDateFormatter *)dateFormatterShortDate
                           dateFormatterShortTime:(NSDateFormatter *)dateFormatterShortTime
                                         calendar:(NSCalendar *)calendar {
    self = [super init];
    if (self)
    {
        self.numberFormatter = [[NSNumberFormatter alloc] init];
        self.grossHoursDeserializer = grossHoursDeserializer;
        self.currencyValueDeserializer = currencyValueDeserializer;
        self.calendar = calendar;
        self.actualsByPayCodeDeserializer = actualsByPayCodeDeserializer;
        self.payCodeHoursDeserializer = payCodeHoursDeserializer;
        self.dateFormatterShortDate = dateFormatterShortDate;
        self.dateFormatterShortTime = dateFormatterShortTime;
        self.remotePunchDeserializer = remotePunchDeserializer;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}



- (TimesheetInfo *)deserializeTimesheetInfo:(NSArray *)responseInfoArray
{
    if (responseInfoArray.count == 0) {
        return nil;
    }
    NSMutableArray *timesheets = [NSMutableArray array];
    for (NSDictionary *timesheetInfo in responseInfoArray) {
        NSString *timsheetUri = timesheetInfo[@"timesheetUri"];
        NSDictionary *dateRange = timesheetInfo[@"timesheetPeriod"][@"dateRangeValue"];
        
        TimeSheetApprovalStatus *status = nil;
        NSDictionary *timesheetStatus = timesheetInfo[@"approvalStatus"];
        if (timesheetStatus != nil && timesheetStatus != (id)[NSNull null])
        {
            NSString *timesheetStatusUri = timesheetStatus[@"uri"];
            NSString *timesheetStatusText = timesheetStatus[@"displayText"];
            
            status = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:timesheetStatusUri
                                                                approvalStatus:timesheetStatusText];
        }
        TimesheetPeriod *period = [self timsheetPeriodFromDateRange:dateRange];
        NSInteger totalIssuesCount = 0;
        NSInteger nonActionedValidationsCount = 0;
        
        NSDictionary *timesheetPeriodViolations = timesheetInfo[@"timesheetPeriodViolations"];
        if (timesheetPeriodViolations != nil && timesheetPeriodViolations != (id)[NSNull null])
        {
            totalIssuesCount = [timesheetPeriodViolations[@"totalTimesheetPeriodViolationMessagesCount"] integerValue];
            nonActionedValidationsCount = [timesheetPeriodViolations[@"totalNonActionedValidationsCount"] integerValue];
        }
        
        TimePeriodSummary *timePeriodSummary = [self deserializeForTimesheetInfo:timesheetInfo];
        
        TimesheetInfo *timesheetInfo = [[TimesheetInfo alloc] initWithTimeSheetApprovalStatus:status
                                                                  nonActionedValidationsCount:nonActionedValidationsCount
                                                                            timePeriodSummary:timePeriodSummary
                                                                                  issuesCount:totalIssuesCount
                                                                                       period:period
                                                                                          uri:timsheetUri];
        [timesheets addObject:timesheetInfo];
    }
    return timesheets.firstObject;
}

- (TimesheetInfo *)deserializeTimesheetInfoForWidget:(NSDictionary *)timesheetInfo
{
    
    NSString *timsheetUri = timesheetInfo[@"timesheetUri"];
    NSDictionary *dateRange = timesheetInfo[@"timesheetPeriod"][@"dateRangeValue"];
    
    TimeSheetApprovalStatus *status = nil;
    NSDictionary *timesheetStatus = timesheetInfo[@"approvalStatus"];
    if (timesheetStatus != nil && timesheetStatus != (id)[NSNull null])
    {
        NSString *timesheetStatusUri = timesheetStatus[@"uri"];
        NSString *timesheetStatusText = timesheetStatus[@"displayText"];
        
        status = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:timesheetStatusUri
                                                            approvalStatus:timesheetStatusText];
    }
    TimesheetPeriod *period = [self timsheetPeriodFromDateRange:dateRange];
    NSInteger totalIssuesCount = 0;
    NSInteger nonActionedValidationsCount = 0;
    
    NSDictionary *timesheetPeriodViolations = timesheetInfo[@"timesheetPeriodViolations"];
    if (timesheetPeriodViolations != nil && timesheetPeriodViolations != (id)[NSNull null])
    {
        totalIssuesCount = [timesheetPeriodViolations[@"totalTimesheetPeriodViolationMessagesCount"] integerValue];
        nonActionedValidationsCount = [timesheetPeriodViolations[@"totalNonActionedValidationsCount"] integerValue];
    }
    
    TimePeriodSummary *timePeriodSummary = [self deserializeForTimesheetInfo:timesheetInfo];
    
    TimesheetInfo *timesheetInfoValue = [[TimesheetInfo alloc] initWithTimeSheetApprovalStatus:status
                                                                   nonActionedValidationsCount:nonActionedValidationsCount
                                                                             timePeriodSummary:timePeriodSummary
                                                                                   issuesCount:totalIssuesCount
                                                                                        period:period
                                                                                           uri:timsheetUri];
    return  timesheetInfoValue;
}

#pragma mark - Private

- (TimePeriodSummary *)deserializeForTimesheetInfo:(NSDictionary *)timeSummaryDictionary
{
    NSDictionary *regularTimeDictionary = timeSummaryDictionary[@"totalWorkDuration"];
    NSDictionary *breakTimeDictionary = timeSummaryDictionary[@"totalBreakDuration"];
    NSDictionary *timeoffDictionary = timeSummaryDictionary[@"totalTimeOffDuration"];

    NSDateComponents *regularTimeComponents = [self timeComponentsFromDictionary:regularTimeDictionary];
    NSDateComponents *breakTimeComponents = [self timeComponentsFromDictionary:breakTimeDictionary];
    NSDateComponents *timeOffComponents = [self timeComponentsFromDictionary:timeoffDictionary];
    
    NSArray *actualsByDateArray = timeSummaryDictionary[@"timeline"];
    NSArray *actualsByPayCodeArray = timeSummaryDictionary[@"actualsByPaycode"];
    NSMutableArray *dayTimeSummaries = [[NSMutableArray alloc] init];
    NSMutableArray *actualsByPaycode = [[NSMutableArray alloc] init];
    NSMutableArray *actualsPayCodeDurationArray = [[NSMutableArray alloc] init];
    for (NSDictionary *actualByDateInfoDictionary in actualsByDateArray)
    {
        TimesheetDaySummary *timesheetDaySummary = [self timesheetDaySummaryFromDictionary:actualByDateInfoDictionary];
        [dayTimeSummaries addObject:timesheetDaySummary];
    }
    
    if (actualsByPayCodeArray != nil && actualsByPayCodeArray != (id)[NSNull null]) {
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
    
    NSMutableArray *actualsByPaycodeInfo = actualsByPaycode.count > 0 ? actualsByPaycode : nil;
    NSMutableArray *actualsPayDurationInfo = actualsPayCodeDurationArray.count > 0 ? actualsPayCodeDurationArray : nil;
    
    CurrencyValue *totalPay = [self.currencyValueDeserializer deserializeForCurrencyValue:timeSummaryDictionary[@"totalPayablePay"]];
    GrossHours *totalHours = [self.grossHoursDeserializer deserializeForHoursDictionary:timeSummaryDictionary[@"totalPayableTimeDuration"]];
    return [[TimePeriodSummary alloc] initWithRegularTimeComponents:regularTimeComponents
                                                breakTimeComponents:breakTimeComponents
                                          timesheetPermittedActions:nil
                                                 overtimeComponents:nil
                                               payDetailsPermission:false
                                                   dayTimeSummaries:dayTimeSummaries
                                                           totalPay:totalPay
                                                         totalHours:totalHours
                                                   actualsByPayCode:actualsByPaycodeInfo
                                               actualsByPayDuration:actualsPayDurationInfo
                                                payAmountPermission:false
                                              scriptCalculationDate:nil
                                                  timeOffComponents:timeOffComponents
                                                     isScheduledDay:YES];
}

- (NSDateComponents *)dateComponentsFromDictionary:(NSDictionary *)dictionary
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = [dictionary[@"day"] integerValue];
    dateComponents.month = [dictionary[@"month"] integerValue];
    dateComponents.year = [dictionary[@"year"] integerValue];
    return dateComponents;
}

- (NSDateComponents *)timeComponentsFromDictionary:(NSDictionary *)dictionary
{
    if (dictionary == nil || dictionary == (id)[NSNull null]){
        return nil;
    }

    NSDateComponents *timeComponents = [[NSDateComponents alloc] init];
    NSInteger hour = 0; NSInteger minute = 0; NSInteger second = 0 ;
    if (dictionary != nil && dictionary != (id)[NSNull null])
    {
        hour = [dictionary[@"hours"] integerValue];
        minute = [dictionary[@"minutes"] integerValue];
        second = [dictionary[@"seconds"] integerValue];
    }
    timeComponents.hour = hour;
    timeComponents.minute = minute;
    timeComponents.second = second;
    return timeComponents;
}

- (TimeSheetApprovalStatus *)timeSheetApprovalStatusFromJsonDict:(NSDictionary *)jsonDict {
    TimeSheetApprovalStatus *approvalStatus = nil;
    NSString *approvalStatusUri = [jsonDict objectForKey:@"uri"];
    NSString *approvalStatusText = [jsonDict objectForKey:@"displayText"];
    
    approvalStatus = [[TimeSheetApprovalStatus alloc] initWithApprovalStatusUri:approvalStatusUri approvalStatus:approvalStatusText];
    return approvalStatus;
}

-(TimesheetPeriod*)timsheetPeriodFromDateRange :(NSDictionary*)responseDictinary
{
    NSDictionary *startDateDictionary = responseDictinary[@"startDate"];
    NSDictionary *endDateDictionary = responseDictinary[@"endDate"];
    DateTimeComponentDeserializer *dateTimeComponentsDeserializer = [[DateTimeComponentDeserializer alloc] init];
    NSDateComponents *startDateComponents = [dateTimeComponentsDeserializer deserializeDateTime:startDateDictionary];
    NSDateComponents *endDateComponents = [dateTimeComponentsDeserializer deserializeDateTime:endDateDictionary];
    NSDate *startDate = [self.calendar dateFromComponents:startDateComponents];
    NSDate *endDate = [self.calendar dateFromComponents:endDateComponents];
    TimesheetPeriod *period = [[TimesheetPeriod alloc]initWithStartDate:startDate endDate:endDate];
    return period;
}

-(TimesheetDaySummary *)timesheetDaySummaryFromDictionary:(NSDictionary *)actualByDateInfoDictionary
{
    NSDateComponents *dateComponents = [self dateComponentsFromDictionary:actualByDateInfoDictionary[@"day"]];
    NSDateComponents *dayBreakTimeComponents = [self timeComponentsFromDictionary:actualByDateInfoDictionary[@"totalBreakDuration"]];
    NSDateComponents *regularWorkTimeComponents = [self timeComponentsFromDictionary:actualByDateInfoDictionary[@"totalWorkDuration"]];
    NSDateComponents *dayTimeOffComponents = [self timeComponentsFromDictionary:actualByDateInfoDictionary[@"totalTimeOffDuration"]];
    NSInteger totalViolationMessageCount = [actualByDateInfoDictionary[@"violations"][@"totalViolationMessagesCount"] integerValue];
    NSMutableArray *punches = actualByDateInfoDictionary[@"timePunches"];
    NSMutableArray *punchesForDay = [NSMutableArray array];
    BOOL isScheduledDay = actualByDateInfoDictionary[@"isScheduledDay"] == nil ? YES : [actualByDateInfoDictionary[@"isScheduledDay"]boolValue];
    
    for (NSDictionary *punchInfo in punches) {
        if (punchInfo[@"uri"]) {
            RemotePunch *punch =  [self.remotePunchDeserializer deserialize:punchInfo];
            [punchesForDay addObject:punch];
        }
    }

    NSArray *punchesForTimesheetDay = punchesForDay.count > 0 ? punchesForDay : nil;
    TimesheetDaySummary *timesheetDaySummary = [[TimesheetDaySummary alloc] initWithRegularTimeOffsetComponents:nil
                                                                                      breakTimeOffsetComponents:nil
                                                                                          regularTimeComponents:regularWorkTimeComponents
                                                                                     totalViolationMessageCount:totalViolationMessageCount
                                                                                            breakTimeComponents:dayBreakTimeComponents
                                                                                              timeOffComponents:dayTimeOffComponents
                                                                                                 dateComponents:dateComponents
                                                                                                  punchesForDay:punchesForTimesheetDay
                                                                                                 isScheduledDay:isScheduledDay];
    
    return timesheetDaySummary;
}

@end
