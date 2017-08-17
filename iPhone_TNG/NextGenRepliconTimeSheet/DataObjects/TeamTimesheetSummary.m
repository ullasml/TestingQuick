#import "TeamTimesheetSummary.h"
#import "CurrencyValue.h"
#import "TimesheetPeriod.h"


@interface TeamTimesheetSummary ()

@property (nonatomic) TeamWorkHoursSummary *teamWorkHoursSummary;
@property (nonatomic) NSUInteger totalViolationsCount;
@property (nonatomic) CurrencyValue *totalPay;
@property (nonatomic) NSArray *goldenTimesheets;
@property (nonatomic) NSArray *nongoldenTimesheets;

@property (nonatomic) TimesheetPeriod *previousPeriod;
@property (nonatomic) TimesheetPeriod *nextPeriod;
@property (nonatomic) TimesheetPeriod *currentPeriod;
@property (nonatomic) BOOL payAmountDetailsPermission;
@property (nonatomic) BOOL payHoursDetailsPermission;
@property (nonatomic) GrossHours *totalHours;
@property (nonatomic) NSArray *actualsByPayCode;
@property (nonatomic) NSArray *actualsByPayDuration;

@end


@implementation TeamTimesheetSummary

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
                          payHoursPermission:(BOOL)payHoursPermission {
    self = [super init];
    if (self) {
        self.totalViolationsCount = totalViolationsCount;
        self.teamWorkHoursSummary = teamWorkHoursSummary;
        self.goldenTimesheets = goldenTimesheets;
        self.nongoldenTimesheets = nongoldenTimesheets;
        self.totalPay = totalPay;
        self.previousPeriod = previousPeriod;
        self.nextPeriod = nextPeriod;
        self.currentPeriod = currentPeriod;
        self.totalHours = totalHours;
        self.actualsByPayCode = actualsByPayCode;
        self.actualsByPayDuration = actualsByPayDuration;
        self.payAmountDetailsPermission = payAmountPermission;
        self.payHoursDetailsPermission = payHoursPermission;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)scriptCalculationDate
{
    return nil;
}


@end
