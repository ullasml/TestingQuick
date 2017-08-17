#import <Cedar/Cedar.h>
#import "SupervisorTrendChartPresenter.h"
#import "EmployeeClockInTrendSummaryDataPoint.h"
#import "EmployeeClockInTrendSummary.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SupervisorTrendChartPresenterSpec)

describe(@"SupervisorTrendChartPresenter", ^{
    __block SupervisorTrendChartPresenter *subject;
    
    beforeEach(^{
        NSDateFormatter *hoursDateFormatter = [[NSDateFormatter alloc] init];
        hoursDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        hoursDateFormatter.dateFormat = @"h a";
        hoursDateFormatter.AMSymbol = @"AM";
        hoursDateFormatter.PMSymbol = @"PM";
        subject = [[SupervisorTrendChartPresenter alloc] initWithDateFormatter:hoursDateFormatter];
    });

    describe(@"-valuesForEmployeeClockInTrendSummary:", ^{
        it(@"should return the values from the data points, with additional zero values for the remainder of the current hour and the next hour", ^{
            NSDate *startDateA = [NSDate dateWithTimeIntervalSince1970:1434537060];
            EmployeeClockInTrendSummaryDataPoint *dataPointA = [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:42 startDate:startDateA];
            NSDate *startDateB = [NSDate dateWithTimeIntervalSince1970:1434537660];
            EmployeeClockInTrendSummaryDataPoint *dataPointB = [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:666 startDate:startDateB];
            NSArray *dataPoints = @[dataPointA, dataPointB];

            EmployeeClockInTrendSummary *employeeClockInTrendSummary = [[EmployeeClockInTrendSummary alloc] initWithDataPoints:dataPoints samplingIntervalSeconds:600];

            NSArray *values = [subject valuesForEmployeeClockInTrendSummary:employeeClockInTrendSummary];

            values should equal(@[
                                  @42, @666, @0, // current hour
                                  @0, @0, @0, @0, @0, @0 // next hour
                                ]);
        });
        it(@"should not return the values for null employee clockin trend summary", ^{
            NSArray *values = [subject valuesForEmployeeClockInTrendSummary:nil];
            values should be_nil;
        });
        
    });

    describe(@"-maximumValueForDataPoints:", ^{
        it(@"should return the next even number after the maximum value", ^{
            EmployeeClockInTrendSummaryDataPoint *dataPointA = [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:42 startDate:nil];
            EmployeeClockInTrendSummaryDataPoint *dataPointB = [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:53 startDate:nil];

            NSArray *dataPoints = @[dataPointA, dataPointB];
            NSInteger maximum = [subject maximumValueForDataPoints:dataPoints];

            maximum should equal(54);

            dataPoints = @[dataPointA];
            maximum = [subject maximumValueForDataPoints:dataPoints];

            maximum should equal(42);
        });
    });

    describe(@"-xLabelsForDataPoints:", ^{

        context(@"12hrs format", ^{
            it(@"should return the correctly ordered and formatted x labels, up to the next two hours", ^{
                NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:3600];
                NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:3620];
                NSDate *date3 = [NSDate dateWithTimeIntervalSince1970:7200];
                NSDate *date4 = [NSDate dateWithTimeIntervalSince1970:3600 + 86400];

                NSArray *dataPoints = @[
                                        [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:1 startDate:date1],
                                        [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:2 startDate:date2],
                                        [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:3 startDate:date3],
                                        [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:4 startDate:date4]
                                        ];

                [subject xLabelsForDataPoints:dataPoints] should equal(@[@"1 AM", @"2 AM", @"1 AM", @"2 AM", @"3 AM"]);
            });

            it(@"should return the nil", ^{
                NSArray *values = [subject xLabelsForDataPoints:nil];
                values should be_nil;
            });
        });

        context(@"24hrs format", ^{
            beforeEach(^{
                NSDateFormatter *hoursDateFormatter = [[NSDateFormatter alloc] init];
                hoursDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
                hoursDateFormatter.dateFormat = @"h";

                subject = [[SupervisorTrendChartPresenter alloc] initWithDateFormatter:hoursDateFormatter];
            });

            it(@"should return the correctly ordered and formatted x labels, up to the next two hours 24hrs format", ^{
                NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:3600];
                NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:3620];
                NSDate *date3 = [NSDate dateWithTimeIntervalSince1970:7200];
                NSDate *date4 = [NSDate dateWithTimeIntervalSince1970:3600 + 86400];

                NSArray *dataPoints = @[
                                        [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:1 startDate:date1],
                                        [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:2 startDate:date2],
                                        [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:3 startDate:date3],
                                        [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:4 startDate:date4]
                                        ];

                [subject xLabelsForDataPoints:dataPoints] should equal(@[@"1:00", @"2:00", @"1:00", @"2:00", @"3:00"]);
            });

            it(@"should return the nil", ^{
                NSArray *values = [subject xLabelsForDataPoints:nil];
                values should be_nil;
            });
        });


    });


});

SPEC_END
