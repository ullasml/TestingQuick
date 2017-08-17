#import "MinimalTimesheetDeserializer.h"
#import "Timesheet.h"
#import "TimesheetForDateRange.h"
#import "TimesheetPeriod.h"
#import "TimeSheetApprovalStatus.h"


@interface MinimalTimesheetDeserializer ()

@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation MinimalTimesheetDeserializer

- (instancetype)initWithCalendar:(NSCalendar *)calendar
                   dateFormatter:(NSDateFormatter *)dateFormatter
{
    self = [super init];
    if (self) {
        self.calendar = calendar;
        self.dateFormatter = dateFormatter;
    }
    return self;
}

- (id<Timesheet>)deserialize:(NSDictionary *)dictionary
{
    NSString *timesheetUri = dictionary[@"timesheetUri"];
    NSString *timesheetPeriod = dictionary[@"timesheetPeriod"];
    NSArray *timePeriodComponents = [timesheetPeriod componentsSeparatedByString:@" - "];
    NSString *startPeriodString = [timePeriodComponents firstObject];
    NSString *endPeriodString = [timePeriodComponents lastObject];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    //dateFormatter.locale = [NSLocale currentLocale];
    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
    NSDate *startDate = [dateFormatter dateFromString:startPeriodString];
    NSDate *endDate = [dateFormatter dateFromString:endPeriodString];

    TimesheetPeriod *period = [[TimesheetPeriod alloc] initWithStartDate:startDate endDate:endDate];

    TimeSheetApprovalStatus *approvalStatus = [[TimeSheetApprovalStatus alloc] initWithApprovalStatusUri:dictionary[@"approvalStatusUri"] approvalStatus:dictionary[@"approvalStatus"]];

    return [[TimesheetForDateRange alloc] initWithUri:timesheetUri period:period approvalStatus:approvalStatus];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
