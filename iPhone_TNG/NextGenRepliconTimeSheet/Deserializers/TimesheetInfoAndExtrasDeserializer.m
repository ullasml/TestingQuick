
#import "TimesheetInfoAndExtrasDeserializer.h"
#import "ViolationsForTimesheetPeriodDeserializer.h"
#import "TimesheetAdditionalInfo.h"
#import "AllViolationSections.h"
#import "TimeSheetPermittedActions.h"
#import "TimeSheetPermittedActionsDeserializer.h"


@interface TimesheetInfoAndExtrasDeserializer ()

@property (nonatomic) ViolationsForTimesheetPeriodDeserializer *violationsForTimesheetPeriodDeserializer;
@property (nonatomic) TimeSheetPermittedActionsDeserializer *timeSheetPermittedActionsDeserializer;
@property (nonatomic) NSDateFormatter *dateFormatterShortDate;
@property (nonatomic) NSDateFormatter *dateFormatterShortTime;
@property (nonatomic) NSCalendar *calendar;


@end


@implementation TimesheetInfoAndExtrasDeserializer

- (instancetype)initWithViolationsForTimesheetPeriodDeserializer:(ViolationsForTimesheetPeriodDeserializer *)violationsForTimesheetPeriodDeserializer
                           timeSheetPermittedActionsDeserializer:(TimeSheetPermittedActionsDeserializer *)timeSheetPermittedActionsDeserializer
                                          dateFormatterShortDate:(NSDateFormatter *)dateFormatterShortDate
                                          dateFormatterShortTime:(NSDateFormatter *)dateFormatterShortTime
                                                        calendar:(NSCalendar *)calendar{
    self = [super init];
    if (self)
    {
        self.violationsForTimesheetPeriodDeserializer = violationsForTimesheetPeriodDeserializer;
        self.timeSheetPermittedActionsDeserializer = timeSheetPermittedActionsDeserializer;
        self.dateFormatterShortDate = dateFormatterShortDate;
        self.dateFormatterShortTime = dateFormatterShortTime;
        self.calendar = calendar;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (TimesheetAdditionalInfo *)deserialize:(NSDictionary *)jsonDictionary
{
    AllViolationSections *allViolationSections =  [self.violationsForTimesheetPeriodDeserializer deserialize:jsonDictionary timesheetType:AstroTimesheetType];
    TimeSheetPermittedActions *timeSheetPermittedActions =  [self.timeSheetPermittedActionsDeserializer deserialize:jsonDictionary];
    NSString *scriptCalculationDate = [self scriptCalculationStatusDateStringFromDictionary:jsonDictionary];
    
    NSDictionary *permittedActions = jsonDictionary[@"permittedActions"];
    BOOL payAmountDetailsPermission = [permittedActions[@"displayPayAmount"] boolValue];
    BOOL payDetailsPermission = [permittedActions[@"canOwnerViewPayrollSummary"] boolValue];
    TimesheetAdditionalInfo *timesheetAdditionalInfo = [[TimesheetAdditionalInfo alloc] initWithTimesheetPermittedActions:timeSheetPermittedActions
                                                                                                     allViolationSections:allViolationSections
                                                                                               scriptCalculationDateValue: scriptCalculationDate
                                                                                               payAmountDetailsPermission:payAmountDetailsPermission
                                                                                                     payDetailsPermission:payDetailsPermission];
    return timesheetAdditionalInfo;
}

#pragma mark - Private


- (NSString *)scriptCalculationStatusDateStringFromDictionary:(NSDictionary *)jsonDictionary
{
    NSDictionary *scriptCalculationStatusDictionary = jsonDictionary[@"scriptCalculationStatus"][@"lastSuccessfulAttempt"];
    if (scriptCalculationStatusDictionary!= nil && scriptCalculationStatusDictionary != (id) [NSNull null])
    {
        NSDictionary *scriptCalculationValueInUTCDictionary = scriptCalculationStatusDictionary[@"valueInUtc"];
        NSInteger day = [scriptCalculationValueInUTCDictionary[@"day"] intValue];
        NSInteger month = [scriptCalculationValueInUTCDictionary[@"month"] intValue];
        NSInteger year = [scriptCalculationValueInUTCDictionary[@"year"] intValue];
        NSInteger hour = [scriptCalculationValueInUTCDictionary[@"hour"] intValue];
        NSInteger minute = [scriptCalculationValueInUTCDictionary[@"minute"] intValue];
        NSInteger second = [scriptCalculationValueInUTCDictionary[@"second"] intValue];
        
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setHour:hour];
        [components setMinute:minute];
        [components setSecond:second];
        [components setDay:day];
        [components setMonth:month];
        [components setYear:year];
        NSDate *dateInLocalTimeZone = [self.calendar dateFromComponents:components];
        NSString *dateWithWeekday = [self.dateFormatterShortDate stringFromDate:dateInLocalTimeZone];
        NSString *timeInAMPM = [self.dateFormatterShortTime stringFromDate:dateInLocalTimeZone];
        NSString *dateText = [NSString stringWithFormat:@"%@ %@ at %@",RPLocalizedString(@"Data as of", @""),dateWithWeekday,timeInAMPM];
        return dateText;
    }
    
    return nil;
}

- (TimeSheetPermittedActions *)permittedActionsOnTimeSheet:(NSDictionary *)jsonDict
{
    NSDictionary *permittedActions = jsonDict[@"permittedActions"];
    NSNumber *canAutoSubmitOnDueDateFlag = [permittedActions objectForKey:@"canAutoSubmitOnDueDate"];
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
    
    TimeSheetPermittedActions *permittedActionsOnTimeSheet = [[TimeSheetPermittedActions alloc] initWithCanSubmitOnDueDate:shouldShowSubmit
                                                                                                                 canReopen:shouldShowReopen
                                                                                                      canReSubmitTimeSheet:shouldShowReSubmit];
    
    return permittedActionsOnTimeSheet;
}


@end
