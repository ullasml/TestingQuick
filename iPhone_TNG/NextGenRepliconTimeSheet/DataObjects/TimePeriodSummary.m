#import "TimePeriodSummary.h"
#import "CurrencyValue.h"
#import "GrossHours.h"
#import "TimeSheetApprovalStatus.h"
#import "TimeSheetPermittedActions.h"

@interface TimePeriodSummary ()

@property (nonatomic) NSDateComponents *regularTimeComponents;
@property (nonatomic) NSDateComponents *breakTimeComponents;
@property (nonatomic) NSDateComponents *overtimeComponents;
@property (nonatomic) NSDateComponents *timeOffComponents;
@property (nonatomic, copy) NSArray *dayTimeSummaries;
@property (nonatomic) CurrencyValue *totalPay;
@property (nonatomic) BOOL payDetailsPermission;
@property (nonatomic) BOOL payAmountDetailsPermission;
@property (nonatomic) GrossHours *totalHours;
@property (nonatomic, copy) NSArray *actualsByPayCode;
@property (nonatomic, copy) NSArray *actualsByPayDuration;
@property (nonatomic, copy) NSString *scriptCalculationDate;
@property (nonatomic) TimeSheetPermittedActions *timesheetPermittedActions;
@property (nonatomic) BOOL isScheduledDay;
@end


@implementation TimePeriodSummary


- (instancetype)initWithRegularTimeComponents:(NSDateComponents *)regularTimeComponents
                          breakTimeComponents:(NSDateComponents *)breakTimeComponents
                    timesheetPermittedActions:(TimeSheetPermittedActions *)timesheetPermittedActions
                           overtimeComponents:(NSDateComponents *)overtimeComponents
                         payDetailsPermission:(BOOL)payDetailsPermission
                             dayTimeSummaries:(NSArray *)dayTimeSummaries
                                     totalPay:(CurrencyValue *)totalPay
                                   totalHours:(GrossHours *)totalHours
                             actualsByPayCode:(NSArray *)actualsByPayCode
                         actualsByPayDuration:(NSArray *)actualsByPayDuration
                          payAmountPermission:(BOOL)payAmountDetailsPermission
                        scriptCalculationDate:(NSString *)scriptCalculationDate
                            timeOffComponents:(NSDateComponents *)timeOffComponents
                               isScheduledDay:(BOOL)isScheduledDay{

    self = [super init];
    if (self) {
        self.regularTimeComponents      = regularTimeComponents;
        self.breakTimeComponents        = breakTimeComponents;
        self.overtimeComponents         = overtimeComponents;
        self.dayTimeSummaries           = dayTimeSummaries;
        self.payDetailsPermission       = payDetailsPermission;
        self.totalPay                   = totalPay;
        self.totalHours                 = totalHours;
        self.actualsByPayCode           = actualsByPayCode;
        self.payAmountDetailsPermission = payAmountDetailsPermission;
        self.actualsByPayDuration       = actualsByPayDuration;
        self.scriptCalculationDate      = scriptCalculationDate;
        self.timesheetPermittedActions  = timesheetPermittedActions;
        self.timeOffComponents          = timeOffComponents;
        self.isScheduledDay = isScheduledDay;
    }
    return self;

}

#pragma mark - NSObject

- (BOOL)isEqual:(TimePeriodSummary *)otherTimePeriodSummary
{
    BOOL typesAreEqual = [self isKindOfClass:[otherTimePeriodSummary class]];
    if (!typesAreEqual) {
        return NO;
    }
    
    BOOL regularTimeComponentsEqualOrBothNil = (!self.regularTimeComponents && !otherTimePeriodSummary.regularTimeComponents) || ([self.regularTimeComponents isEqual:otherTimePeriodSummary.regularTimeComponents]);
    BOOL breakTimeComponentsEqualOrBothNil = (!self.breakTimeComponents && !otherTimePeriodSummary.breakTimeComponents) || ([self.breakTimeComponents isEqual:otherTimePeriodSummary.breakTimeComponents]);
    BOOL overtimeComponentsEqualOrBothNil = (!self.overtimeComponents && !otherTimePeriodSummary.overtimeComponents) || ([self.overtimeComponents isEqual:otherTimePeriodSummary.overtimeComponents]);
    BOOL payAmountDetailsPermissionEqual = self.payAmountDetailsPermission == otherTimePeriodSummary.payAmountDetailsPermission;
    BOOL payDetailsPermissionEqual = self.payDetailsPermission == otherTimePeriodSummary.payDetailsPermission;
    BOOL timesheetPermittedActionsEqualOrBothNil = (!self.timesheetPermittedActions && !otherTimePeriodSummary.timesheetPermittedActions) || ([self.timesheetPermittedActions isEqual:otherTimePeriodSummary.timesheetPermittedActions]);
    BOOL dayTimeSummariesEqualOrBothNil = (!self.dayTimeSummaries && !otherTimePeriodSummary.dayTimeSummaries) || ([self.dayTimeSummaries isEqual:otherTimePeriodSummary.dayTimeSummaries]);
    BOOL totalPayEqualOrBothNil = (!self.totalPay && !otherTimePeriodSummary.totalPay) || ([self.totalPay isEqual:otherTimePeriodSummary.totalPay]);
    BOOL totalHoursEqualOrBothNil = (!self.totalHours && !otherTimePeriodSummary.totalHours) || ([self.totalHours isEqual:otherTimePeriodSummary.totalHours]);
    BOOL actualsByPayCodeEqualOrBothNil = (!self.actualsByPayCode && !otherTimePeriodSummary.actualsByPayCode) || ([self.actualsByPayCode isEqual:otherTimePeriodSummary.actualsByPayCode]);
    BOOL actualsByPayDurationEqualOrBothNil = (!self.actualsByPayDuration && !otherTimePeriodSummary.actualsByPayDuration) || ([self.actualsByPayDuration isEqual:otherTimePeriodSummary.actualsByPayDuration]);
    BOOL scriptCalculationDateEqualOrBothNil = (!self.scriptCalculationDate && !otherTimePeriodSummary.scriptCalculationDate) || ([self.scriptCalculationDate isEqual:otherTimePeriodSummary.scriptCalculationDate]);
    BOOL isScheduledDayEqual = (self.isScheduledDay == otherTimePeriodSummary.isScheduledDay);
    
    return (regularTimeComponentsEqualOrBothNil &&
            breakTimeComponentsEqualOrBothNil &&
            overtimeComponentsEqualOrBothNil &&
            payAmountDetailsPermissionEqual &&
            payDetailsPermissionEqual &&
            timesheetPermittedActionsEqualOrBothNil &&
            dayTimeSummariesEqualOrBothNil&&
            totalPayEqualOrBothNil&&
            totalHoursEqualOrBothNil&&
            actualsByPayCodeEqualOrBothNil&&
            actualsByPayDurationEqualOrBothNil&&
            scriptCalculationDateEqualOrBothNil &&
            isScheduledDayEqual);
}

-(BOOL)payHoursDetailsPermission
{
    return TRUE;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> \r regularTimeComponents: %@ \r breakTimeComponents: %@ \r overtimeComponents: %@ \r dayTimeSummaries: %@ \r payDetailsPermission: %d \r totalPay: %@ \r totalHours: %@ \r actualsByPayCode: %@ \r payAmountDetailsPermission: %d \r actualsByPayDuration: %@ \r scriptCalculationDate: %@ \r timesheetPermittedActions: %@ \r self.timeOffComponents: %@ \r isScheduledDay: %d \r", NSStringFromClass([self class]),
            self.regularTimeComponents,
            self.breakTimeComponents,
            self.overtimeComponents,
            self.dayTimeSummaries,
            self.payDetailsPermission,
            self.totalPay,
            self.totalHours,
            self.actualsByPayCode,
            self.payAmountDetailsPermission,
            self.actualsByPayDuration,
            self.scriptCalculationDate,
            self.timesheetPermittedActions,
            self.timeOffComponents,
            self.isScheduledDay];
    
    
}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[TimePeriodSummary alloc] initWithRegularTimeComponents:[self.regularTimeComponents copy]
                                                breakTimeComponents:[self.breakTimeComponents copy]
                                          timesheetPermittedActions:[self.timesheetPermittedActions copy]
                                                 overtimeComponents:[self.overtimeComponents copy]
                                               payDetailsPermission:self.payDetailsPermission
                                                   dayTimeSummaries:[self.dayTimeSummaries copy]
                                                           totalPay:[self.totalPay copy]
                                                         totalHours:[self.totalHours copy]
                                                   actualsByPayCode:[self.actualsByPayCode copy]
                                               actualsByPayDuration:[self.actualsByPayDuration copy]
                                                payAmountPermission:self.payAmountDetailsPermission
                                              scriptCalculationDate:[self.scriptCalculationDate copy]
                                                  timeOffComponents:[self.timeOffComponents copy]
                                                     isScheduledDay:self.isScheduledDay];
    
}

@end
