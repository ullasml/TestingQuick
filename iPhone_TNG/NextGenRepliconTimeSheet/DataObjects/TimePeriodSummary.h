#import <Foundation/Foundation.h>
#import "WorkHours.h"
#import "GrossSummary.h"


@class CurrencyValue;
@class GrossHours;
@class TimeSheetApprovalStatus;
@class TimeSheetPermittedActions;

@interface TimePeriodSummary : NSObject <WorkHours,GrossSummary,NSCopying>

@property (nonatomic, copy, readonly) NSArray *dayTimeSummaries;
@property (nonatomic, copy, readonly) NSArray *actualsByPayCode;
@property (nonatomic, copy, readonly) NSArray *actualsByPayDuration;
@property (nonatomic, readonly) CurrencyValue *totalPay;
@property (nonatomic, readonly) GrossHours *totalHours;
@property (nonatomic, readonly) BOOL payDetailsPermission;
@property (nonatomic, readonly) BOOL payAmountDetailsPermission;
@property (nonatomic, readonly, copy) NSString *scriptCalculationDate;
@property (nonatomic, readonly) TimeSheetPermittedActions *timesheetPermittedActions;
@property (nonatomic, readonly) BOOL isScheduledDay;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

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
                               isScheduledDay:(BOOL)isScheduledDay NS_DESIGNATED_INITIALIZER;

@end
