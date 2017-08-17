#import "TimeSummaryDeserializer.h"
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
#import "Constants.h"

@interface TimeSummaryDeserializer ()

@property (nonatomic) CurrencyValueDeserializer *currencyValueDeserializer;
@property (nonatomic) GrossHoursDeserializer *grossHoursDeserializer;
@property (nonatomic) ActualsByPayCodeDeserializer *actualsByPayCodeDeserializer;
@property (nonatomic) PayCodeHoursDeserializer *payCodeHoursDeserializer;
@property (nonatomic) NSCalendar *localTimezoneCalendar;
@property (nonatomic) NSNumberFormatter *numberFormatter;
@property (nonatomic) NSDateFormatter *dateFormatterShortDate;
@property (nonatomic) NSDateFormatter *dateFormatterShortTime;
@property (nonatomic) NSCalendar *utcTimeZoneCalendar;


@end


@implementation TimeSummaryDeserializer

- (instancetype)initWithCurrencyValueDeserializer:(CurrencyValueDeserializer *)currencyValueDeserializer
                            localTimezoneCalendar:(NSCalendar *)localTimezoneCalendar
                             grossHoursSerializer:(GrossHoursDeserializer *)grossHoursDeserializer
                     actualsByPayCodeDesirializer:(ActualsByPayCodeDeserializer *)actualsByPayCodeDeserializer
                         payCodeHoursDeserializer:(PayCodeHoursDeserializer *)payCodeHoursDeserializer
                           dateFormatterShortDate:(NSDateFormatter *)dateFormatterShortDate
                           dateFormatterShortTime:(NSDateFormatter *)dateFormatterShortTime
                              utcTimeZoneCalendar:(NSCalendar *)utcTimeZoneCalendar {
    self = [super init];
    if (self)
    {
        self.numberFormatter = [[NSNumberFormatter alloc] init];
        self.grossHoursDeserializer = grossHoursDeserializer;
        self.currencyValueDeserializer = currencyValueDeserializer;
        self.localTimezoneCalendar = localTimezoneCalendar;
        self.actualsByPayCodeDeserializer = actualsByPayCodeDeserializer;
        self.payCodeHoursDeserializer = payCodeHoursDeserializer;
        self.dateFormatterShortDate = dateFormatterShortDate;
        self.dateFormatterShortTime = dateFormatterShortTime;
        self.utcTimeZoneCalendar = utcTimeZoneCalendar;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (DayTimeSummary *)deserialize:(NSDictionary *)timeSummaryDictionary
                        forDate:(NSDate *)date
{

    NSDictionary *responseDictionary = timeSummaryDictionary[@"d"];
    if ([responseDictionary isEqual:[NSNull null]] || date == nil)
    {
        return nil;
    }
    //The dates in the timesummary is always in user's scheduled timezone set in the web.
    //If we have to deserialize correct break hours/ work hours then the requirement is that the device timezone should match the user's scheduled timezone on web.
    //Otherwise expect a mismatch i.e wrong data in work and break duration

    NSUInteger unitFlags = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    NSDateComponents *localTimeZoneDateComponents = [self.localTimezoneCalendar components:unitFlags fromDate:date];

    TimePeriodSummary *timePeriodSummary = [self deserializeForTimesheet:timeSummaryDictionary];

    for (DayTimeSummary *dayTimeSummary in timePeriodSummary.dayTimeSummaries)
    {
        if ([dayTimeSummary.dateComponents isEqual:localTimeZoneDateComponents])
        {
            return dayTimeSummary;
        }
    }

    return nil;
}

- (TimePeriodSummary *)deserializeForTimesheet:(NSDictionary *)timeSummaryDictionary
{
    NSDictionary *dataDictionary = timeSummaryDictionary[@"d"];
    NSDictionary *regularTimeDictionary = dataDictionary[@"workingTimeDuration"];
    NSDictionary *breakTimeDictionary = dataDictionary[@"breakDuration"];
    NSDictionary *overTimeDictionary = dataDictionary[@"overtimeDuration"];
    
    BOOL payDetailsPermission= NO;
    BOOL payAmountDetailsPermission = NO;
    id canViewPayrollSummary = dataDictionary[@"canOwnerViewPayrollSummary"];
    id canDisplayPayAmount = dataDictionary[@"displayPayAmount"];
    if (canViewPayrollSummary!=nil && canViewPayrollSummary != (id) [NSNull null]) {
        payDetailsPermission= [canViewPayrollSummary boolValue];
    }
    if (canDisplayPayAmount!=nil && canDisplayPayAmount != (id) [NSNull null]) {
        payAmountDetailsPermission = [canDisplayPayAmount boolValue];
    }
    
    NSDateComponents *regularTimeComponents = [self timeComponentsFromDictionary:regularTimeDictionary];
    NSDateComponents *breakTimeComponents = [self timeComponentsFromDictionary:breakTimeDictionary];
    NSDateComponents *overTimeComponents = [self timeComponentsFromDictionary:overTimeDictionary];

    NSArray *actualsByDateArray = dataDictionary[@"actualsByDate"];
    NSArray *actualsByPayCodeArray = dataDictionary[@"actualsByPaycode"];
    NSMutableArray *dayTimeSummaries = [[NSMutableArray alloc] init];
    NSMutableArray *actualsByPaycode = [[NSMutableArray alloc] init];
    NSMutableArray *actualsPayCodeDurationArray = [[NSMutableArray alloc] init];
    NSArray *nonScheduledDaysArray = dataDictionary[@"timesheetDaysOff"][@"nonScheduledDays"];
    if(actualsByDateArray!=nil && actualsByDateArray!=(id)[NSNull null])
    {
        for (NSDictionary *actualByDateInfoDictionary in actualsByDateArray)
        {
            NSDateComponents *dateComponents = [self dateComponentsFromDictionary:actualByDateInfoDictionary[@"date"]];
            NSDateComponents *dayBreakTimeComponents = [self timeComponentsFromDictionary:actualByDateInfoDictionary[@"breakDuration"]];
            NSDateComponents *regularWorkTimeComponents = [self timeComponentsFromDictionary:actualByDateInfoDictionary[@"workingTimeDuration"]];
            BOOL isScheduledDay = YES;
            if ([nonScheduledDaysArray containsObject:actualByDateInfoDictionary[@"date"]])
            {
                isScheduledDay = NO;
            }

            DayTimeSummary *dayTimeSummary = [[DayTimeSummary alloc] initWithRegularTimeOffsetComponents:nil
                                                                               breakTimeOffsetComponents:nil
                                                                                   regularTimeComponents:regularWorkTimeComponents
                                                                                     breakTimeComponents:dayBreakTimeComponents
                                                                                       timeOffComponents:nil
                                                                                          dateComponents:dateComponents
                                                                                          isScheduledDay:isScheduledDay];

            [dayTimeSummaries addObject:dayTimeSummary];
        }
    }

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
    CurrencyValue *totalPay = [self.currencyValueDeserializer deserializeForCurrencyValue:dataDictionary[@"totalPayablePay"]];
    GrossHours *totalHours = [self.grossHoursDeserializer deserializeForHoursDictionary:dataDictionary[@"totalPayableTimeDuration"]];
    NSString *scriptCalculationDate = [self scriptCalculationStatusDateFromDictionary:dataDictionary];

    TimeSheetPermittedActions *timesheetPermittedActions = [self permittedActionsOnTimeSheet:dataDictionary];
    return [[TimePeriodSummary alloc] initWithRegularTimeComponents:regularTimeComponents
                                                breakTimeComponents:breakTimeComponents
                                          timesheetPermittedActions:timesheetPermittedActions
                                                 overtimeComponents:overTimeComponents
                                               payDetailsPermission:payDetailsPermission
                                                   dayTimeSummaries:dayTimeSummaries
                                                           totalPay:totalPay
                                                         totalHours:totalHours
                                                   actualsByPayCode:actualsByPaycode
                                               actualsByPayDuration:actualsPayCodeDurationArray
                                                payAmountPermission:payAmountDetailsPermission
                                              scriptCalculationDate:scriptCalculationDate
                                                  timeOffComponents:nil
                                                     isScheduledDay:YES];
    
}

#pragma mark - Private

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
    NSDateComponents *timeComponents = [[NSDateComponents alloc] init];
    timeComponents.hour = 0;
    timeComponents.minute = 0;
    timeComponents.second = 0;
    if (dictionary != nil && dictionary != (id)[NSNull null]) {
        timeComponents.hour = [dictionary[@"hours"] integerValue];
        timeComponents.minute = [dictionary[@"minutes"] integerValue];
        timeComponents.second = [dictionary[@"seconds"] integerValue];
    }

    return timeComponents;
}

- (NSString *)scriptCalculationStatusDateFromDictionary:(NSDictionary *)dataDictionary
{
    NSDictionary *scriptCalculationStatusDictionary = dataDictionary[@"scriptCalculationStatus"][@"lastSuccessfulAttempt"];
    if (scriptCalculationStatusDictionary!=nil && scriptCalculationStatusDictionary != (id) [NSNull null])
    {
        NSDictionary *scriptCalculationValueInUTCDictionary = scriptCalculationStatusDictionary[@"valueInUtc"];
        DateTimeComponentDeserializer *dateTimeComponentsDeserializer = [[DateTimeComponentDeserializer alloc] init];
        NSDateComponents *components = [dateTimeComponentsDeserializer deserializeDateTime:scriptCalculationValueInUTCDictionary];
        NSDate *date = [self.utcTimeZoneCalendar dateFromComponents:components];
        NSString *dateWithWeekday = [self.dateFormatterShortDate stringFromDate:date];
        NSString *timeInAMPM = [self.dateFormatterShortTime stringFromDate:date];
        NSString *dateText = [NSString stringWithFormat:@"%@ %@ at %@",RPLocalizedString(@"Data as of", @""),dateWithWeekday,timeInAMPM];
        return dateText;
    }
    return nil;
}

-(Period *)timsheetPeriodFromDateRange :(NSDictionary*)responseDictinary
{
    NSDictionary *startDateDictionary = responseDictinary[@"startDate"];
    NSDictionary *endDateDictionary = responseDictinary[@"endDate"];
    DateTimeComponentDeserializer *dateTimeComponentsDeserializer = [[DateTimeComponentDeserializer alloc] init];
    NSDateComponents *startDateComponents = [dateTimeComponentsDeserializer deserializeDateTime:startDateDictionary];
    NSDateComponents *endDateComponents = [dateTimeComponentsDeserializer deserializeDateTime:endDateDictionary];
    NSDate *startDate = [self.utcTimeZoneCalendar dateFromComponents:startDateComponents];
    NSDate *endDate = [self.utcTimeZoneCalendar dateFromComponents:endDateComponents];
    Period *period = [[Period alloc]initWithStartDate:startDate
                                              endDate:endDate];

    return period;
}

- (TimeSheetPermittedActions *)permittedActionsOnTimeSheet:(NSDictionary *)jsonDict {
    NSNumber *canAutoSubmitOnDueDateFlag = [jsonDict objectForKey:@"canAutoSubmitOnDueDate"];
    BOOL isAutoSubmitEnabled = [canAutoSubmitOnDueDateFlag boolValue];
    
    NSDictionary *permittedActionsDict = [jsonDict objectForKey:@"permittedApprovalActions"];
    NSNumber *canSubmitFlag = [permittedActionsDict objectForKey:@"canSubmit"];
    NSNumber *canReopenFlag = [permittedActionsDict objectForKey:@"canReopen"];
    NSNumber *canUnSubmitFlag = [permittedActionsDict objectForKey:@"canUnsubmit"];
    
    NSNumber *canResubmitFlag = [jsonDict objectForKey:@"displayResubmit"];
    
    BOOL canSubmit = [canSubmitFlag boolValue];
    BOOL canReopen = [canReopenFlag boolValue];
    BOOL canUnsubmit = [canUnSubmitFlag boolValue];
    BOOL canReSubmit = [canResubmitFlag boolValue];
    
    BOOL shouldShowSubmit = (!isAutoSubmitEnabled && canSubmit && !canReSubmit);
    BOOL shouldShowReopen = (canReopen || canUnsubmit);
    BOOL shouldShowReSubmit = (canSubmit && canReSubmit);
    
    TimeSheetPermittedActions *permittedActionsOnTimeSheet = [[TimeSheetPermittedActions alloc] initWithCanSubmitOnDueDate:shouldShowSubmit canReopen:shouldShowReopen canReSubmitTimeSheet:shouldShowReSubmit];
    
    return permittedActionsOnTimeSheet;
}


@end
