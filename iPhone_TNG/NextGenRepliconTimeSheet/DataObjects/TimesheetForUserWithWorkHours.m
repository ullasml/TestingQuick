#import "TimesheetForUserWithWorkHours.h"
#import "TimePeriodSummary.h"
#import "TimesheetPeriod.h"

@interface TimesheetForUserWithWorkHours ()

@property (nonatomic) NSDateComponents *totalOvertimeHours;
@property (nonatomic) NSDateComponents *totalRegularHours;
@property (nonatomic) NSDateComponents *totalBreakHours;
@property (nonatomic) NSDateComponents *totalWorkHours;
@property (nonatomic) NSNumber *violationsCount;
@property (nonatomic) TimesheetPeriod *period;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userURI;
@property (nonatomic, copy) NSString *uri;
@property (nonatomic) TimeSheetApprovalStatus *approvalStatus;

@end

@implementation TimesheetForUserWithWorkHours

- (instancetype)initWithTotalOvertimeHours:(NSDateComponents *)totalOvertimeHours
                         totalRegularHours:(NSDateComponents *)totalRegularHours
                           totalBreakHours:(NSDateComponents *)totalBreakHours
                            totalWorkHours:(NSDateComponents *)totalWorkHours
                           violationsCount:(NSNumber *)violationsCount
                                  userName:(NSString *)userName
                                   userURI:(NSString *)userURI
                                    period:(TimesheetPeriod *)period
                                       uri:(NSString *)uri
                   timeSheetApprovalStatus:(TimeSheetApprovalStatus *)timeSheetApprovalStatus
{
    self = [super init];
    if (self) {
        self.totalOvertimeHours = totalOvertimeHours;
        self.totalRegularHours = totalRegularHours;
        self.totalBreakHours = totalBreakHours;
        self.violationsCount = violationsCount;
        self.totalWorkHours = totalWorkHours;
        self.userURI = userURI;
        self.period = period;
        self.userName = userName;
        self.uri = uri;
        self.approvalStatus = timeSheetApprovalStatus;
    }
    return self;
}

#pragma mark - <Timesheet>

- (TimesheetAstroUserType)astroUserType
{
    return TimesheetAstroUserTypeUnknown;
}

-(TimePeriodSummary *)timePeriodSummary
{
    return nil;
}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[TimesheetForUserWithWorkHours alloc] initWithTotalOvertimeHours:[self.totalOvertimeHours copy]
                                                           totalRegularHours:[self.totalRegularHours copy]
                                                             totalBreakHours:[self.totalBreakHours copy]
                                                              totalWorkHours:[self.totalWorkHours copy]
                                                             violationsCount:self.violationsCount
                                                                    userName:[self.userName copy]
                                                                     userURI:[self.userURI copy]
                                                                      period:[self.period copy]
                                                                         uri:[self.uri copy]
                                                     timeSheetApprovalStatus:[self.approvalStatus copy]];
    
}

@end
