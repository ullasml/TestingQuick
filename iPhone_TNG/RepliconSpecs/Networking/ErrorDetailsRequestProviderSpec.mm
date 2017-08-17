#import <Cedar/Cedar.h>
#import "ErrorDetailsRequestProvider.h"
#import "InjectorProvider.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "URLStringProvider.h"
#import "DateProvider.h"
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ErrorDetailsRequestProviderSpec)

describe(@"ErrorDetailsRequestProvider", ^{
    __block ErrorDetailsRequestProvider *subject;
    __block URLStringProvider *urlStringProvider;
    __block id<BSInjector, BSBinder> injector;
    __block DateProvider *dateProvider;
    __block NSUserDefaults *userDefaults;
    
    beforeEach(^{
        injector = [InjectorProvider injector];

        urlStringProvider = nice_fake_for([URLStringProvider class]);
        [injector bind:[URLStringProvider class] toInstance:urlStringProvider];

        dateProvider = nice_fake_for([DateProvider class]);
        [injector bind:[DateProvider class] toInstance:dateProvider];
        NSDateComponents* components = [[NSDateComponents alloc]init];
        components.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [components setYear:1970];
        [components setMonth:1];
        [components setDay:1];
        [components setHour:12];
        [components setMinute:0];
        [components setSecond:0];
        NSDate *date = [NSDate dateWithDateComponents:components];
        dateProvider stub_method(@selector(date)).and_return(date);

        userDefaults = nice_fake_for([NSUserDefaults class]);
        [injector bind:InjectorKeyStandardUserDefaults toInstance:userDefaults];


        subject = [injector getInstance:[ErrorDetailsRequestProvider class]];

    });

    context(@"requestForValidationErrorsWithURI:", ^{
        __block NSURLRequest *request;

        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"ErrorDetails_Validation").and_return(@"http://expected.endpoint/name");
            request = [subject requestForValidationErrorsWithURI:@[@"uri-1",@"uri-2"]];
        });

        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"http://expected.endpoint/name");

            NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                     options:0
                                                                       error:nil];

            NSDictionary *expectedRequestBody = @{
                                                  @"uri":@[@"uri-1",@"uri-2"]

                                                  };

            httpBody should equal(expectedRequestBody);
        });


    });

    context(@"requestForTimeSheetUpdateDataForUserUri:", ^{
        __block NSURLRequest *request;

        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"GetTimesheetUpdateData").and_return(@"http://expected.endpoint/name");

            userDefaults stub_method(@selector(objectForKey:)).with(@"ErrorTimeSheetLastModifiedTime").and_return(@"Fri, 02 Jun 2016 02:58:56 GMT");

            request = [subject requestForTimeSheetUpdateDataForUserUri:@"my-custom-user-uri"];
        });

        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"http://expected.endpoint/name");

            NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                     options:0
                                                                       error:nil];

            NSDictionary *expectedRequestBody = @{
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
                                @"uri": @"my-custom-user-uri",
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
                },
                @"lastUpdatedDateTime": @{
                    @"month": @6,
                    @"second": @56,
                    @"day": @2,
                    @"year": @2016,
                    @"hour": @2,
                    @"minute": @58,
                    @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                }
            };
            
            httpBody should equal(expectedRequestBody);
        });
        
        
    });

});


SPEC_END
