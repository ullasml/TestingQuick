#import <Cedar/Cedar.h>
#import "TimesheetRequestBodyProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "DateProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetRequestBodyProviderSpec)

describe(@"TimesheetRequestBodyProvider", ^{
    __block id<BSInjector, BSBinder> injector;
    __block NSDate *date;
    beforeEach(^{
        injector = [InjectorProvider injector];
    });

    beforeEach(^{
        date = [NSDate dateWithTimeIntervalSince1970:0];
        DateProvider *dateProvider = fake_for([DateProvider class]);
        dateProvider stub_method(@selector(date)).and_return(date);

        [injector bind:[DateProvider class] toInstance:dateProvider];
    });

    __block TimesheetRequestBodyProvider *subject;
    beforeEach(^{
        subject = [injector getInstance:[TimesheetRequestBodyProvider class]];
    });

    
    describe(@"should provide the correct request body", ^{
        it(@"requestBodyDictionaryForMostRecentTimesheetWithUserURI", ^{
            NSDictionary *requestBodyDictionary = [subject requestBodyDictionaryForMostRecentTimesheetWithUserURI:@"some:user:uri"];
            
            requestBodyDictionary should equal(@{
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
                                                                                 @"uri": @"some:user:uri",
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
                                                                                         @"endDate": @{
                                                                                                 @"day": @1,
                                                                                                 @"month": @1,
                                                                                                 @"year": @1970
                                                                                                 }
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
                                                 });
            
        });

    });

    
});

SPEC_END
