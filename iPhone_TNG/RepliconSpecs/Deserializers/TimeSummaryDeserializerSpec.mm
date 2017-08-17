#import <Cedar/Cedar.h>
#import "TimeSummaryDeserializer.h"
#import "Util.h"
#import "RepliconSpecHelper.h"
#import "TimesheetForDateRange.h"
#import "TimePeriodSummary.h"
#import "DayTimeSummary.h"
#import "CurrencyValue.h"
#import "CurrencyValueDeserializer.h"
#import "GrossHoursDeserializer.h"
#import "ActualsByPayCodeDeserializer.h"
#import "PayCodeHoursDeserializer.h"
#import "Paycode.h"
#import "GrossHours.h"
#import "TimeSheetPermittedActions.h"
#import "InjectorProvider.h"
#import <Blindside/BlindSide.h>
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimeSummaryDeserializerSpec)

describe(@"TimeSummaryDeserializer", ^{
    __block TimeSummaryDeserializer *subject;
    __block CurrencyValueDeserializer *currencyValueDeserializer;
    __block GrossHoursDeserializer *grossHoursDeserializer;
    __block ActualsByPayCodeDeserializer *actualsByPayCodeDeserializer;
    __block PayCodeHoursDeserializer *payCodeHoursDeserializer;
    __block NSDateFormatter *dateFormatterShortDate;
    __block NSDateFormatter *dateFormatterShortTime;
    __block id <BSInjector,BSBinder> injector;
    __block NSDictionary *timesheetDictionary;
    __block NSDictionary *payCodeDictionary;
    __block NSDictionary *timesheetWithActulasNullDictionary;

    beforeEach(^{
        
        injector = [InjectorProvider injector];
        
        currencyValueDeserializer = nice_fake_for([CurrencyValueDeserializer class]);
        [injector bind:[CurrencyValueDeserializer class] toInstance:currencyValueDeserializer];
        
        grossHoursDeserializer = nice_fake_for([GrossHoursDeserializer class]);
        [injector bind:[GrossHoursDeserializer class] toInstance:grossHoursDeserializer];
        
        actualsByPayCodeDeserializer = nice_fake_for([ActualsByPayCodeDeserializer class]);
        [injector bind:[ActualsByPayCodeDeserializer class] toInstance:actualsByPayCodeDeserializer];
        
        payCodeHoursDeserializer = nice_fake_for([PayCodeHoursDeserializer class]);
        [injector bind:[PayCodeHoursDeserializer class] toInstance:payCodeHoursDeserializer];

        dateFormatterShortDate = [injector getInstance:InjectorKeyShortDateWithWeekdayInLocalTimeZoneFormatter];
        [injector bind:InjectorKeyShortDateWithWeekdayInLocalTimeZoneFormatter toInstance:dateFormatterShortDate];

        dateFormatterShortTime = [injector getInstance:InjectorKeyShortTimeWithAMPMInLocalTimeZoneFormatter];
        [injector bind:InjectorKeyShortTimeWithAMPMInLocalTimeZoneFormatter toInstance:dateFormatterShortTime];

        timesheetDictionary = [RepliconSpecHelper jsonWithFixture:@"time_summary"];
        payCodeDictionary = [RepliconSpecHelper jsonWithFixture:@"timesheet_payCode"];
    });

    describe(@"deserialize:forDate:", ^{

        __block DayTimeSummary *deserializedTimeSummary;
        __block NSDateComponents *expectedRegularTimeComponents;
        __block NSDateComponents *expectedBreakTimeComponents;
        __block NSDateComponents *expectedDateComponents;
        __block NSArray *actualsByPayCode;
        
        beforeEach(^{
            actualsByPayCode = payCodeDictionary[@"d"][@"actualsByPaycode"];
            subject = [injector getInstance:[TimeSummaryDeserializer class]];
            timesheetDictionary = [RepliconSpecHelper jsonWithFixture:@"time_summary_regression"];
            expectedRegularTimeComponents = [[NSDateComponents alloc] init];
            expectedRegularTimeComponents.hour = 0;
            expectedRegularTimeComponents.minute = 1;
            expectedRegularTimeComponents.second = 15;
            
            expectedBreakTimeComponents = [[NSDateComponents alloc] init];
            expectedBreakTimeComponents.hour = 0;
            expectedBreakTimeComponents.minute = 0;
            expectedBreakTimeComponents.second = 0;
            
            expectedDateComponents = [[NSDateComponents alloc] init];
            expectedDateComponents.day = 9;
            expectedDateComponents.month = 12;
            expectedDateComponents.year = 2015;
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:1449727251];
            deserializedTimeSummary = [subject deserialize:timesheetDictionary forDate:date];
            
            
        });
        
        it(@"should have pay hours", ^{
            actualsByPayCode should_not be_nil;
        });
        
        it(@"should have no of elements", ^{
            actualsByPayCode.count should equal(6);
        });
        
        it(@"should return the correct deserialized day time summary", ^{
            deserializedTimeSummary.regularTimeComponents should equal(expectedRegularTimeComponents);
            deserializedTimeSummary.breakTimeComponents should equal(expectedBreakTimeComponents);
            deserializedTimeSummary.dateComponents should equal(expectedDateComponents);
            deserializedTimeSummary.isScheduledDay should be_truthy;
        });
        
    });

    describe(@"deserializeForTimesheet:", ^{
        __block NSArray *actualsByPayCode;
        __block Paycode *payCode;
        __block NSDictionary *actualsByPaycodeDict;
        __block TimeSheetPermittedActions *expectedTimeSheetPermittedActions;
        beforeEach(^{

            expectedTimeSheetPermittedActions =  [[TimeSheetPermittedActions alloc] initWithCanSubmitOnDueDate:NO
                                                                                                     canReopen:NO
                                                                                          canReSubmitTimeSheet:YES];
            payCode = nice_fake_for([Paycode class]);
            actualsByPayCode = @[payCode,payCode,payCode,payCode,payCode,payCode];


            actualsByPaycodeDict = @{
                @"payCodeMultiplier": @1,
                @"totalTimeDuration": @{
                    @"hours": @24,
                    @"minutes": @0,
                    @"seconds": @0
                },
                @"payCode": @{
                    @"name": @"Regular Time",
                    @"uri": @"urn:replicon-tenant:repliconiphone-2:pay-code:4",
                    @"displayText": @"Regular Time"
                },
                @"moneyValue": @{
                    @"baseCurrencyValueAsOfDate": @{
                        @"day": @1,
                        @"month": @9,
                        @"year": @2016
                    },
                    @"multiCurrencyValue": @[
                                           @{
                                               @"amount": @0,
                                               @"currency": @{
                                                   @"symbol": @"$",
                                                   @"displayText": @"$",
                                                   @"name": @"US Dollar",
                                                   @"uri": @"urn:replicon-tenant:repliconiphone-2:currency:1"
                                               }
                                           }
                                           ],
                    @"baseCurrencyValue": @{
                        @"amount": @0,
                        @"currency": @{
                            @"symbol": @"CAD$",
                            @"displayText": @"CAD$",
                            @"name": @"Canadian Dollar",
                            @"uri": @"urn:replicon-tenant:repliconiphone-2:currency:2"
                        }
                    }
                }
            };
            
            actualsByPayCodeDeserializer stub_method(@selector(deserializeForPayCodeDictionary:))
            .with(actualsByPaycodeDict)
            .and_return(payCode);
        });
        
        context(@"deserializeForTimesheet: with actualsByDate null", ^{
            __block TimePeriodSummary *deserializedTimeSummary;
            beforeEach(^{
                timesheetWithActulasNullDictionary = [RepliconSpecHelper jsonWithFixture:@"time_summary_regression_actuals_null"];
                subject = [injector getInstance:[TimeSummaryDeserializer class]];
                
            });
            it(@"TimePeriodSummary actualsByDate array should have 0 elements", ^{
                deserializedTimeSummary = [subject deserializeForTimesheet:timesheetWithActulasNullDictionary];
                deserializedTimeSummary.dayTimeSummaries.count should equal(0);
            });
        });


        context(@"deserialize timesheet for TimesheetPermittedActions", ^{
            __block TimePeriodSummary *timePeriodSummary;
            beforeEach(^{
                subject = [injector getInstance:[TimeSummaryDeserializer class]];
                timePeriodSummary = [subject deserializeForTimesheet:timesheetDictionary];
            });

            it(@"should parse the TimesheetPermittedActions correctly", ^{
                timePeriodSummary.timesheetPermittedActions should equal(expectedTimeSheetPermittedActions);
            });
        });
    

        it(@"should parse the regular/break/overtime totals", ^{
            NSDateComponents *regularTimeComponents = [[NSDateComponents alloc] init];
            regularTimeComponents.hour = 0;
            regularTimeComponents.minute = 13;
            regularTimeComponents.second = 5;

            NSDateComponents *breakTimeComponents = [[NSDateComponents alloc] init];
            breakTimeComponents.hour = 1;
            breakTimeComponents.minute = 2;
            breakTimeComponents.second = 3;

            NSDateComponents *overTimeComponents = [[NSDateComponents alloc] init];
            overTimeComponents.hour = 4;
            overTimeComponents.minute = 5;
            overTimeComponents.second = 6;

            subject = [injector getInstance:[TimeSummaryDeserializer class]];
            TimePeriodSummary *deserializedTimeSummary = [subject deserializeForTimesheet:timesheetDictionary];

            deserializedTimeSummary.regularTimeComponents should equal(regularTimeComponents);
            deserializedTimeSummary.breakTimeComponents should equal(breakTimeComponents);
            deserializedTimeSummary.overtimeComponents should equal(overTimeComponents);
            deserializedTimeSummary.payDetailsPermission should be_truthy;
            deserializedTimeSummary.isScheduledDay should be_truthy;
        });

        it(@"should parse the per day summaries", ^{
            subject = [injector getInstance:[TimeSummaryDeserializer class]];
            TimePeriodSummary *deserializedTimeSummary = [subject deserializeForTimesheet:timesheetDictionary];

            deserializedTimeSummary.dayTimeSummaries.count should equal(7);

            DayTimeSummary *day1 = deserializedTimeSummary.dayTimeSummaries[0];
            day1.dateComponents.year should equal(2015);
            day1.dateComponents.month should equal(4);
            day1.dateComponents.day should equal(6);

            day1.breakTimeComponents.hour should equal(2);
            day1.breakTimeComponents.minute should equal(15);
            day1.breakTimeComponents.second should equal(3);

            day1.regularTimeComponents.hour should equal(3);
            day1.regularTimeComponents.minute should equal(4);
            day1.regularTimeComponents.second should equal(5);

            DayTimeSummary *day2 = deserializedTimeSummary.dayTimeSummaries[1];
            day2.dateComponents.year should equal(2015);
            day2.dateComponents.month should equal(4);
            day2.dateComponents.day should equal(7);

            day2.breakTimeComponents.hour should equal(1);
            day2.breakTimeComponents.minute should equal(15);
            day2.breakTimeComponents.second should equal(3);

            day2.regularTimeComponents.hour should equal(6);
            day2.regularTimeComponents.minute should equal(7);
            day2.regularTimeComponents.second should equal(8);
        });
        
        it(@"should parse the per day summaries scheduled day correctly", ^{
            subject = [injector getInstance:[TimeSummaryDeserializer class]];
            TimePeriodSummary *deserializedTimeSummary = [subject deserializeForTimesheet:timesheetDictionary];
            
            deserializedTimeSummary.dayTimeSummaries.count should equal(7);
            
            DayTimeSummary *day1 = deserializedTimeSummary.dayTimeSummaries[0];
            day1.isScheduledDay should be_truthy;
            
            DayTimeSummary *day2 = deserializedTimeSummary.dayTimeSummaries[1];
            day2.isScheduledDay should be_truthy;
            
            DayTimeSummary *day3 = deserializedTimeSummary.dayTimeSummaries[2];
            day3.isScheduledDay should be_truthy;
            
            DayTimeSummary *day4 = deserializedTimeSummary.dayTimeSummaries[3];
            day4.isScheduledDay should be_truthy;
            
            DayTimeSummary *day5 = deserializedTimeSummary.dayTimeSummaries[4];
            day5.isScheduledDay should be_truthy;
            
            DayTimeSummary *day6 = deserializedTimeSummary.dayTimeSummaries[5];
            day6.isScheduledDay should be_falsy;
            
            DayTimeSummary *day7 = deserializedTimeSummary.dayTimeSummaries[6];
            day7.isScheduledDay should be_falsy;
        });

        it(@"should parse the gross pay", ^{
            CurrencyValue *currencyValue = fake_for([CurrencyValue class]);

            currencyValueDeserializer stub_method(@selector(deserializeForCurrencyValue:))
                .with(timesheetDictionary[@"d"][@"totalPayablePay"])
                .and_return(currencyValue);

            subject = [injector getInstance:[TimeSummaryDeserializer class]];
            TimePeriodSummary *deserializedTimeSummary = [subject deserializeForTimesheet:timesheetDictionary];
            deserializedTimeSummary.totalPay should be_same_instance_as(currencyValue);
            deserializedTimeSummary.payDetailsPermission should be_truthy;

        });
        
        it(@"should parse the gross hours", ^{
            GrossHours *grossHours = fake_for([GrossHours class]);
            grossHoursDeserializer stub_method(@selector(deserializeForHoursDictionary:))
            .with(timesheetDictionary[@"d"][@"totalPayableTimeDuration"])
            .and_return(grossHours);
            subject = [injector getInstance:[TimeSummaryDeserializer class]];
            TimePeriodSummary *deserializedTimeSummary = [subject deserializeForTimesheet:timesheetDictionary];
            deserializedTimeSummary.totalHours should be_same_instance_as(grossHours);
            deserializedTimeSummary.payDetailsPermission should be_truthy;

        });

        it(@"should parse the actualsByPaycode", ^{

            subject = [injector getInstance:[TimeSummaryDeserializer class]];
            TimePeriodSummary *deserializedTimeSummary = [subject deserializeForTimesheet:payCodeDictionary];
            deserializedTimeSummary.actualsByPayCode[0] should be_same_instance_as(actualsByPayCode[0]);
            deserializedTimeSummary.actualsByPayCode[1] should be_same_instance_as(actualsByPayCode[1]);
            deserializedTimeSummary.actualsByPayCode[2] should be_same_instance_as(actualsByPayCode[2]);
            deserializedTimeSummary.actualsByPayCode[3] should be_same_instance_as(actualsByPayCode[3]);
            deserializedTimeSummary.actualsByPayCode[4] should be_same_instance_as(actualsByPayCode[4]);
            deserializedTimeSummary.actualsByPayCode[5] should be_same_instance_as(actualsByPayCode[5]);

            
        });

        it(@"should parse the actualsPayCodeDurationArray", ^{
            payCodeHoursDeserializer stub_method(@selector(deserializeForHoursDictionary:))
            .with(actualsByPaycodeDict)
            .and_return(payCode);
            subject = [injector getInstance:[TimeSummaryDeserializer class]];
            TimePeriodSummary *deserializedTimeSummary = [subject deserializeForTimesheet:payCodeDictionary];

            deserializedTimeSummary.actualsByPayDuration[0] should be_same_instance_as(actualsByPayCode[0]);
            deserializedTimeSummary.actualsByPayDuration[1] should be_same_instance_as(actualsByPayCode[1]);
            deserializedTimeSummary.actualsByPayDuration[2] should be_same_instance_as(actualsByPayCode[2]);
            deserializedTimeSummary.actualsByPayDuration[3] should be_same_instance_as(actualsByPayCode[3]);
            deserializedTimeSummary.actualsByPayDuration[4] should be_same_instance_as(actualsByPayCode[4]);
            deserializedTimeSummary.actualsByPayDuration[5] should be_same_instance_as(actualsByPayCode[5]);
            
        });

        it(@"payAmountDetailsPermission should be truthy", ^{
            subject = [injector getInstance:[TimeSummaryDeserializer class]];
            TimePeriodSummary *deserializedTimeSummary = [subject deserializeForTimesheet:payCodeDictionary];
            deserializedTimeSummary.payAmountDetailsPermission should be_truthy;
        });

        it(@"payAmountDetailsPermission should be falsy", ^{
            subject = [injector getInstance:[TimeSummaryDeserializer class]];
            TimePeriodSummary *deserializedTimeSummary = [subject deserializeForTimesheet:timesheetDictionary];
            deserializedTimeSummary.payAmountDetailsPermission should be_falsy;
        });

        it(@"should parse the null regular/break/overtime totals", ^{

            timesheetDictionary = [RepliconSpecHelper jsonWithFixture:@"time_summary_null_regression"];

            NSDateComponents *regularTimeComponents = [[NSDateComponents alloc] init];
            regularTimeComponents.hour = 0;
            regularTimeComponents.minute = 0;
            regularTimeComponents.second = 0;

            NSDateComponents *breakTimeComponents = [[NSDateComponents alloc] init];
            breakTimeComponents.hour = 0;
            breakTimeComponents.minute = 0;
            breakTimeComponents.second = 0;

            NSDateComponents *overTimeComponents = [[NSDateComponents alloc] init];
            overTimeComponents.hour = 0;
            overTimeComponents.minute = 0;
            overTimeComponents.second = 0;

            subject = [injector getInstance:[TimeSummaryDeserializer class]];
            TimePeriodSummary *deserializedTimeSummary = [subject deserializeForTimesheet:timesheetDictionary];

            deserializedTimeSummary.regularTimeComponents should equal(regularTimeComponents);
            deserializedTimeSummary.breakTimeComponents should equal(breakTimeComponents);
            deserializedTimeSummary.overtimeComponents should equal(overTimeComponents);
            deserializedTimeSummary.payDetailsPermission should be_truthy;
            deserializedTimeSummary.isScheduledDay should be_truthy;
        });
        
        context(@"should parse the script caluculation date", ^{

            context(@"For PST timeZone", ^{
                __block TimePeriodSummary *deserializedTimeSummary;
                beforeEach(^{
                    
                    dateFormatterShortDate.timeZone = [NSTimeZone timeZoneWithName:@"PST"];
                    dateFormatterShortTime.timeZone = [NSTimeZone timeZoneWithName:@"PST"];

                    subject = [injector getInstance:[TimeSummaryDeserializer class]];
                    deserializedTimeSummary = [subject deserializeForTimesheet:timesheetDictionary];

                });
                it(@"script calculation data should be equal", ^{
                    deserializedTimeSummary.scriptCalculationDate should equal(@"Data as of Mon, Apr 13 at 12:08 AM");
                });

            });

            context(@"For IST timeZone", ^{
                __block TimePeriodSummary *deserializedTimeSummary;
                beforeEach(^{

                    dateFormatterShortDate.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Kolkata"];
                    dateFormatterShortTime.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Kolkata"];

                    subject = [injector getInstance:[TimeSummaryDeserializer class]];
                    
                    deserializedTimeSummary = [subject deserializeForTimesheet:timesheetDictionary];

                });
                
                it(@"script calculation data should be equal", ^{
                    deserializedTimeSummary.scriptCalculationDate should equal(@"Data as of Mon, Apr 13 at 12:38 PM");
                });
                
            });

            context(@"when script calculation is not available", ^{
                __block TimePeriodSummary *deserializedTimeSummary;
                beforeEach(^{
                    NSDictionary *teamTimesheetOverviewSummaryDictionary = [RepliconSpecHelper jsonWithFixture:@"team_timsheet_overview_summary"];
                    deserializedTimeSummary = [subject deserializeForTimesheet:teamTimesheetOverviewSummaryDictionary];

                });
                
                it(@"script calculation date should be nil", ^{
                    deserializedTimeSummary.scriptCalculationDate should be_nil;
                });
            });

        });
    });
});

SPEC_END
