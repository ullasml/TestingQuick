#import "TimesheetRequestBodyProvider.h"
#import "DateProvider.h"

@interface TimesheetRequestBodyProvider ()

@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSCalendar *calendar;

@end

@implementation TimesheetRequestBodyProvider

- (instancetype) initWithDateProvider:(DateProvider *)dateProvider calendar:(NSCalendar *)calendar
{
    self = [super init];
    if (self) {
        self.dateProvider = dateProvider;
        self.calendar =  calendar;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSDictionary *)requestBodyDictionaryForMostRecentTimesheetWithUserURI:(NSString *)userURI
{
    NSDate *currentDate = [self.dateProvider date];
    NSDateComponents *dateComponents = [self.calendar components:(NSCalendarUnitYear  | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:currentDate];

    NSDictionary *todayDateDictionary=@{@"day": [NSNumber numberWithInteger:dateComponents.day],
                                        @"month": [NSNumber numberWithInteger:dateComponents.month],
                                        @"year": [NSNumber numberWithInteger:dateComponents.year],
                                        };
    return @{
             @"columnUris": @[
                     @"urn:replicon:timesheet-list-column:timesheet-period",
                     @"urn:replicon:timesheet-list-column:regular-time-duration",
                     @"urn:replicon:timesheet-list-column:overtime-duration",
                     @"urn:replicon:timesheet-list-column:time-off-duration",
                     @"urn:replicon:timesheet-list-column:total-duration",
                     @"urn:replicon:timesheet-list-column:due-date",
                     @"urn:replicon:timesheet-list-column:meal-break-penalty-count",
                     @"urn:replicon:timesheet-list-column:approval-status",
                     @"urn:replicon:timesheet-list-column:timesheet",
                     @"urn:replicon:timesheet-list-column:total-payable-duration"
                     ],
             @"pageSize": @10,
             @"sort": @[
                     @{
                         @"isAscending": @"false",
                         @"columnUri": @"urn:replicon:timesheet-list-column:timesheet-period"
                         }
                     ],
             @"filterExpression": @{
                     @"leftExpression": @{
                             @"leftExpression": @{
                                     @"leftExpression": [NSNull null],
                                     @"value": [NSNull null],
                                     @"operatorUri": [NSNull null],
                                     @"filterDefinitionUri": @"urn:replicon:timesheet-list-filter:timesheet-owner",
                                     @"rightExpression": [NSNull null]
                                     },
                             @"value": [NSNull null],
                             @"operatorUri": @"urn:replicon:filter-operator:equal",
                             @"filterDefinitionUri": [NSNull null],
                             @"rightExpression": @{
                                     @"leftExpression": [NSNull null],
                                     @"value": @{
                                             @"text": [NSNull null],
                                             @"calendarDayDurationValue": [NSNull null],
                                             @"dateRange": [NSNull null],
                                             @"uris": [NSNull null],
                                             @"workdayDurationValue": [NSNull null],
                                             @"money": [NSNull null],
                                             @"date": [NSNull null],
                                             @"time": [NSNull null],
                                             @"bool": [NSNull null],
                                             @"uri": userURI,
                                             @"number": [NSNull null]
                                             },
                                     @"operatorUri": [NSNull null],
                                     @"filterDefinitionUri": [NSNull null],
                                     @"rightExpression": [NSNull null]
                                     }
                             },
                     @"value": [NSNull null],
                     @"operatorUri": @"urn:replicon:filter-operator:and",
                     @"filterDefinitionUri": [NSNull null],
                     @"rightExpression": @{
                             @"leftExpression": @{
                                     @"leftExpression": [NSNull null],
                                     @"value": [NSNull null],
                                     @"operatorUri": [NSNull null],
                                     @"filterDefinitionUri": @"urn:replicon:timesheet-list-filter:timesheet-period-date-range",
                                     @"rightExpression": [NSNull null]
                                     },
                             @"value": [NSNull null],
                             @"operatorUri": @"urn:replicon:filter-operator:in",
                             @"filterDefinitionUri": [NSNull null],
                             @"rightExpression": @{
                                     @"leftExpression": [NSNull null],
                                     @"value": @{
                                             @"text": [NSNull null],
                                             @"uri": [NSNull null],
                                             @"dateRange": @{
                                                     @"startDate": [NSNull null],
                                                     @"relativeDateRangeAsOfDate": [NSNull null],
                                                     @"relativeDateRangeUri": [NSNull null],
                                                     @"endDate": todayDateDictionary
                                                     },
                                             @"uris": [NSNull null],
                                             @"workdayDurationValue": [NSNull null],
                                             @"money": [NSNull null],
                                             @"date": [NSNull null],
                                             @"time": [NSNull null],
                                             @"bool": [NSNull null],
                                             @"calendarDayDurationValue": [NSNull null],
                                             @"number": [NSNull null]
                                             },
                                     @"operatorUri": [NSNull null],
                                     @"filterDefinitionUri": [NSNull null],
                                     @"rightExpression": [NSNull null]
                                     }
                             }
                     }
             };
}

- (NSDictionary *)requestBodyDictionaryTimesheetWithDate:(NSDate*)date
{
    NSDateComponents *dateComponents = [self.calendar components:(NSCalendarUnitYear  | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    
    NSDictionary *todayDateDictionary=@{@"day": [NSNumber numberWithInteger:dateComponents.day],
                                        @"month": [NSNumber numberWithInteger:dateComponents.month],
                                        @"year": [NSNumber numberWithInteger:dateComponents.year],
                                        };
    
    return @{ @"count":[NSNumber numberWithInt:1], @"asOf" : todayDateDictionary, @"timesheetUri" : [NSNull null]};
}

- (NSDictionary *)requestBodyDictionaryTimesheetWithTimesheetURI:(NSString *)uri
{
    return @{ @"count":[NSNumber numberWithInt:1], @"asOf" : [NSNull null], @"timesheetUri" : uri};
}


@end
