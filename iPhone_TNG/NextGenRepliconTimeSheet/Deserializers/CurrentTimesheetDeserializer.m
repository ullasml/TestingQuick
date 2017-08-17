
#import "CurrentTimesheetDeserializer.h"
#import "TimesheetForDateRange.h"
#import "TimesheetPeriod.h"
#import "AppProperties.h"
#import "IndexCursor.h"
#import "DateProvider.h"
#import "TimeSheetApprovalStatus.h"

#define URI                 @"uri"
#define OBJECT_TYPE         @"ObjectType"
#define TEXT_VALUE          @"textValue"
#define APPROVAL_STATUS_KEY @"Approval Status"

@interface CurrentTimesheetDeserializer ()

@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSCalendar *calendar;

@end


@implementation CurrentTimesheetDeserializer

-(instancetype)initWithDateProvider:(DateProvider *)dateProvider calendar:(NSCalendar *)calendar

{
    self = [super init];
    if (self) {
        self.dateProvider = dateProvider;
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

#pragma mark - Private

-(NSArray *)getTimesheetsFromDictionary:(NSDictionary *)timesheetDictionary
{
    NSDictionary *responseDictionary = timesheetDictionary[@"d"];
    if ([responseDictionary isEqual:[NSNull null]]) {
        return nil;
    }

    NSArray *headerArray = responseDictionary[@"header"];
    NSArray *rowsArray = responseDictionary[@"rows"];

    NSMutableArray *timesheets = [NSMutableArray arrayWithCapacity:rowsArray.count];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];

    for (NSDictionary *row in rowsArray) {
        NSString *timesheetURI;
        NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
        NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
        TimeSheetApprovalStatus *approvalStatus = nil;

        NSArray *cellsArray = row[@"cells"];

        for (int cellIndex = 0; cellIndex < [cellsArray count]; cellIndex++) {
            NSString *referenceHeaderUri = headerArray[cellIndex][@"uri"];
            NSArray *columnUriArray = [[AppProperties getInstance] getTimesheetColumnURIFromPlist];
            NSString *referenceHeader = nil;

            for (NSDictionary *columnDict in columnUriArray) {
                NSString *uri = columnDict[@"uri"];
                if ([referenceHeaderUri isEqualToString:uri]) {
                    referenceHeader = columnDict[@"name"];
                    break;
                }
            }

            NSMutableDictionary *responseDict = cellsArray[cellIndex];
            if ([referenceHeader isEqualToString:@"Timesheet"]) {
                timesheetURI = responseDict[@"uri"];

            }
            else if ([responseDict[@"dataType"] isEqualToString:@"urn:replicon:list-type:date-range"]) {
                NSDictionary *dateRangeValue = responseDict[@"dateRangeValue"];
                startDateComponents.day = [dateRangeValue[@"startDate"][@"day"] integerValue];
                startDateComponents.month = [dateRangeValue[@"startDate"][@"month"] integerValue];
                startDateComponents.year = [dateRangeValue[@"startDate"][@"year"] integerValue];

                endDateComponents.day = [dateRangeValue[@"endDate"][@"day"] integerValue];
                endDateComponents.month = [dateRangeValue[@"endDate"][@"month"] integerValue];
                endDateComponents.year = [dateRangeValue[@"endDate"][@"year"] integerValue];
            }

            else if([responseDict[@"objectType"] isEqualToString:@"urn:replicon:object-type:approval-status"]) {
                approvalStatus = [self timeSheetApprovalStatus:responseDict];
            }

        }

        NSDate *startDate = [calendar dateFromComponents:startDateComponents];
        NSDate *endDate = [calendar dateFromComponents:endDateComponents];

        TimesheetPeriod *period = [[TimesheetPeriod alloc] initWithStartDate:startDate endDate:endDate];

        TimesheetForDateRange *dateRange = [[TimesheetForDateRange alloc] initWithUri:timesheetURI
                                                                               period:period approvalStatus:approvalStatus];

        [timesheets addObject:dateRange];
    }

    return timesheets;
}

- (BOOL)isCurrentDateBetweenFirstDate:(NSDate *)startDate lastDate:(NSDate *)endDate {

    NSCalendarUnit unitFlags = NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitDay |NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:self.dateProvider.date];
    components.second = 0;
    components.minute = 0;
    components.hour = 0;

    NSDate *date = [self.calendar dateFromComponents:components];
    NSComparisonResult startDateResult = [date compare:startDate];
    NSComparisonResult endDateResult = [date compare:endDate];

    BOOL isCurrentDateEqualOrGreaterThanStartDate = (startDateResult == NSOrderedDescending || startDateResult== NSOrderedSame);
    BOOL isCurrentDateEqualOrLesserThanEndDate = (endDateResult == NSOrderedAscending || endDateResult == NSOrderedSame);
    return isCurrentDateEqualOrGreaterThanStartDate && isCurrentDateEqualOrLesserThanEndDate;
}

#pragma mark - Internal Objects Construction Helpers

- (TimeSheetApprovalStatus *)timeSheetApprovalStatus:(NSDictionary *)responseDict {
    NSString *approvalStatusUri = nil;
    NSString *approvalStatus = nil;

    approvalStatusUri = responseDict[@"uri"];
    approvalStatus = responseDict[@"textValue"];

    TimeSheetApprovalStatus *timeSheetApprovalStatus = [[TimeSheetApprovalStatus alloc] initWithApprovalStatusUri:approvalStatusUri
                                                                                          approvalStatus:approvalStatus];
    return timeSheetApprovalStatus;
}

@end
