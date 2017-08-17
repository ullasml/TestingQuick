#import "TimesheetForDateRange.h"
#import "TimesheetPeriod.h"
#import "TimeSheetApprovalStatus.h"
#import "TimePeriodSummary.h"

@interface TimesheetForDateRange ()

@property (nonatomic, copy) NSString *uri;
@property (nonatomic) TimesheetPeriod *period;
@property (nonatomic) TimeSheetApprovalStatus *approvalStatus;

@end


@implementation TimesheetForDateRange

- (instancetype)initWithUri:(NSString *)uri
                     period:(TimesheetPeriod *)period
             approvalStatus:(TimeSheetApprovalStatus *)approvalStatus {

    self = [super init];
    if (self) {
        self.uri = uri;
        self.period = period;
        self.approvalStatus = approvalStatus;
    }
    return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(TimesheetForDateRange *)otherTimesheet
{
    if(![otherTimesheet isKindOfClass:[self class]]) {
        return NO;
    }

    BOOL userURINil = !otherTimesheet.uri && !self.uri;
    BOOL userURIEqual = userURINil || [otherTimesheet.uri isEqualToString:self.uri];

    BOOL startDateComponentsNil = !otherTimesheet.period.startDate && !self.period.startDate;
    BOOL endDateComponentsNil = !otherTimesheet.period.endDate && !self.period.endDate;

    BOOL startDateComponentsEqual = startDateComponentsNil || [otherTimesheet.period.startDate isEqualToDate:self.period.startDate];
    BOOL endDateComponentsEqual = endDateComponentsNil || [otherTimesheet.period.endDate isEqualToDate:self.period.endDate];

    BOOL approvalStatusURINil = !otherTimesheet.approvalStatus.approvalStatusUri  && !self.approvalStatus.approvalStatusUri;
    BOOL approvalStatusURIEqual = approvalStatusURINil || [otherTimesheet.approvalStatus.approvalStatusUri isEqualToString:self.approvalStatus.approvalStatusUri];

    BOOL approvalStatusNil = !otherTimesheet.approvalStatus.approvalStatus  && !self.approvalStatus.approvalStatus;
    BOOL approvalStatusEqual = approvalStatusNil || [otherTimesheet.approvalStatus.approvalStatus isEqualToString:self.approvalStatus.approvalStatus];

    return userURIEqual && startDateComponentsEqual && endDateComponentsEqual && approvalStatusEqual && approvalStatusURIEqual;
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"<%@>: "
            @"<%@>: ",
            NSStringFromClass([self class]),
            self.uri];
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
    return [[TimesheetForDateRange alloc] initWithUri:[self.uri copy]
                                               period:[self.period copy]
                                       approvalStatus:[self.approvalStatus copy]];
    
}

@end
