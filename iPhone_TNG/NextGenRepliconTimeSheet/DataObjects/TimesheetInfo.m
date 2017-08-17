#import "TimesheetInfo.h"
#import "TimesheetPeriod.h"
#import "TimePeriodSummary.h"
#import "TimePeriodSummary.h"
#import "Timesheet.h"
#import "TimeSheetApprovalStatus.h"

@interface TimesheetInfo ()

@property (nonatomic) TimePeriodSummary *timePeriodSummary;
@property (nonatomic) TimesheetPeriod *period;
@property (nonatomic) NSString *uri;
@property (nonatomic, assign) NSInteger issuesCount;
@property (nonatomic, assign) NSInteger nonActionedValidationsCount;
@property (nonatomic) TimeSheetApprovalStatus *approvalStatus;


@end


@implementation TimesheetInfo

- (instancetype)initWithTimeSheetApprovalStatus:(TimeSheetApprovalStatus *)approvalStatus
                    nonActionedValidationsCount:(NSInteger)nonActionedValidationsCount
                              timePeriodSummary:(TimePeriodSummary *)timePeriodSummary
                                    issuesCount:(NSInteger)issuesCount
                                         period:(TimesheetPeriod *)period
                                            uri:(NSString *)uri {
    self = [super init];
    if (self)
    {
        self.nonActionedValidationsCount = nonActionedValidationsCount;
        self.approvalStatus = approvalStatus;
        self.timePeriodSummary = timePeriodSummary;
        self.issuesCount = issuesCount;
        self.period = period;
        self.uri = uri;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[TimesheetInfo alloc] initWithTimeSheetApprovalStatus:[self.approvalStatus copy]
                                      nonActionedValidationsCount:self.nonActionedValidationsCount
                                                timePeriodSummary:[self.timePeriodSummary copy]
                                                      issuesCount:self.issuesCount
                                                           period:[self.period copy]
                                                              uri:[self.uri copy]];
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@>:\n period: %@ \n  timePeriodSummary: %@ \n  uri: %@ \n  issuesCount: %ld \n nonActionedValidationsCount: %ld approvalStatus:%@", NSStringFromClass([self class]),
            self.period,
            self.timePeriodSummary,
            self.uri,
            self.issuesCount,
            self.nonActionedValidationsCount,
            self.approvalStatus];
}


#pragma mark - <Timesheet>

- (TimesheetAstroUserType)astroUserType
{
    return TimesheetAstroUserTypeUnknown;
}


@end
