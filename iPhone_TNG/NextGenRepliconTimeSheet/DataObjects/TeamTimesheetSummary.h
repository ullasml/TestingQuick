#import <Foundation/Foundation.h>
#import "TeamWorkHoursSummary.h"
#import "GrossSummary.h"

@class CurrencyValue;
@class TimesheetPeriod;
@class GrossHours;

@interface TeamTimesheetSummary : NSObject<GrossSummary>

@property (nonatomic, readonly) TeamWorkHoursSummary *teamWorkHoursSummary;
@property (nonatomic, readonly) NSUInteger totalViolationsCount;
@property (nonatomic, readonly) NSArray *goldenTimesheets;
@property (nonatomic, readonly) NSArray *nongoldenTimesheets;
@property (nonatomic, readonly) CurrencyValue *totalPay;

@property (nonatomic, readonly) TimesheetPeriod *previousPeriod;
@property (nonatomic, readonly) TimesheetPeriod *currentPeriod;
@property (nonatomic, readonly) TimesheetPeriod *nextPeriod;

@property (nonatomic, copy, readonly) NSArray *actualsByPayCode;
@property (nonatomic, copy, readonly) NSArray *actualsByPayDuration;
@property (nonatomic, readonly) GrossHours *totalHours;
@property (nonatomic, readonly) BOOL payAmountDetailsPermission;
@property (nonatomic, readonly) BOOL payHoursDetailsPermission;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTeamWorkHoursSummary:(TeamWorkHoursSummary *)teamWorkHoursSummary
                        totalViolationsCount:(NSUInteger)totalViolationsCount
                         nongoldenTimesheets:(NSArray *)nongoldenTimesheets
                            goldenTimesheets:(NSArray *)goldenTimesheets
                              previousPeriod:(TimesheetPeriod *)previousPeriod
                               currentPeriod:(TimesheetPeriod *)currentPeriod
                                  nextPeriod:(TimesheetPeriod *)nextPeriod
                                    totalPay:(CurrencyValue *)totalPay
                                  totalHours:(GrossHours *)totalHours
                            actualsByPayCode:(NSArray *)actualsByPayCode
                        actualsByPayDuration:(NSArray *)actualsByPayDuration
                         payAmountPermission:(BOOL)payAmountPermission
                          payHoursPermission:(BOOL)payHoursPermission NS_DESIGNATED_INITIALIZER;

@end
