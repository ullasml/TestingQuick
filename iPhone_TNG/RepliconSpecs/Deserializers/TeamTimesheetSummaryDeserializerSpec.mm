#import <Cedar/Cedar.h>
#import "TeamTimesheetSummaryDeserializer.h"
#import "TeamTimesheetSummary.h"
#import "RepliconSpecHelper.h"
#import "CurrencyValue.h"
#import "CurrencyValueDeserializer.h"
#import "TeamTimesheetsForTimePeriod.h"
#import "TimesheetForUserWithWorkHours.h"
#import "TimesheetPeriod.h"
#import "GrossHoursDeserializer.h"
#import "ActualsByPayCodeDeserializer.h"
#import "PayCodeHoursDeserializer.h"
#import "Paycode.h"
#import "GrossHours.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TeamTimesheetSummaryDeserializerSpec)

describe(@"TeamTimesheetSummaryDeserializer", ^{
    __block TeamTimesheetSummaryDeserializer *subject;
    __block CurrencyValueDeserializer *currencyValueDeserializer;
    __block TeamTimesheetSummary *teamTimesheetSummary;
    __block GrossHoursDeserializer *grossHoursDeserializer;
    __block ActualsByPayCodeDeserializer *actualsByPayCodeDeserializer;
    __block PayCodeHoursDeserializer *payCodeHoursDeserializer;

    beforeEach(^{
        currencyValueDeserializer = nice_fake_for([CurrencyValueDeserializer class]);
        grossHoursDeserializer = nice_fake_for([GrossHoursDeserializer class]);
        actualsByPayCodeDeserializer = nice_fake_for([ActualsByPayCodeDeserializer class]);
        payCodeHoursDeserializer = nice_fake_for([PayCodeHoursDeserializer class]);

        subject = [[TeamTimesheetSummaryDeserializer alloc] initWithCurrencyValueDeserializer:currencyValueDeserializer
                                                                       grossHoursDeserializer:grossHoursDeserializer
                                                                 actualsByPayCodeDeserializer:actualsByPayCodeDeserializer
                                                                     payCodeHoursDeserializer:payCodeHoursDeserializer];
    });



    describe(@"-deserialize", ^{
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        calendar.timeZone = timeZone;
        __block NSDictionary *teamTimesheetSummaryDictionary;
        __block NSArray *actualsByPayCode;
        __block Paycode *payCode;
        __block NSDictionary *actualsByPaycodeDict;

        context(@"-deserialize with fixture", ^{

            beforeEach(^{
                teamTimesheetSummaryDictionary = [RepliconSpecHelper jsonWithFixture:@"team_timesheet_summary"];
                payCode = nice_fake_for([Paycode class]);
                actualsByPayCode = @[payCode,payCode,payCode,payCode,payCode,payCode];
                actualsByPaycodeDict = @{
                                         @"moneyValue": @{
                                             @"baseCurrencyValue": @{
                                                 @"amount": @0.00000000,
                                                 @"currency": @{
                                                     @"displayText": @"USD$",
                                                     @"name": @"US Dollar",
                                                     @"symbol": @"USD$",
                                                     @"uri": @"urn:replicon-tenant:test:currency:1"
                                                 }
                                             },
                                             @"baseCurrencyValueAsOfDate": @{
                                                 @"day": @6,
                                                 @"month": @9,
                                                 @"year": @2016
                                             },
                                             @"multiCurrencyValue": @[
                                                                    @{
                                                                        @"amount": @0,
                                                                        @"currency": @{
                                                                            @"displayText": @"USD$",
                                                                            @"name": @"US Dollar",
                                                                            @"symbol": @"USD$",
                                                                            @"uri": @"urn:replicon-tenant:test:currency:1"
                                                                        }
                                                                    }
                                                                    ]
                                         },
                                         @"payCode": @{
                                             @"displayText": @"Meal Penalty",
                                             @"name": [NSNull null],
                                             @"uri": @"urn:replicon-tenant:test:timesheet-user-payroll-details-list-pay-code-hours-column:8"
                                         },
                                         @"payCodeMultiplier": @0,
                                         @"totalTimeDuration": @{
                                             @"hours": @0,
                                             @"minutes": @0,
                                             @"seconds": @0
                                         }
                                         };

                actualsByPayCodeDeserializer stub_method(@selector(deserializeForPayCodeDictionary:))
                .with(actualsByPaycodeDict)
                .and_return(payCode);

                teamTimesheetSummary = [subject deserialize:teamTimesheetSummaryDictionary];
            });

            it(@"should have a total violations count", ^{
                teamTimesheetSummary.totalViolationsCount should equal(3);
            });
            
            it(@"should have view pay permission", ^{
                teamTimesheetSummary.payAmountDetailsPermission should be_truthy;
            });

            it(@"should have view hours permission", ^{
                teamTimesheetSummary.payHoursDetailsPermission should be_falsy;
            });
            
            it(@"should have the correct total worked time", ^{
                NSDateComponents *regularTimeComponents = [[NSDateComponents alloc] init];
                regularTimeComponents.hour = 180;
                regularTimeComponents.minute = 0;
                regularTimeComponents.second = 0;
                teamTimesheetSummary.teamWorkHoursSummary.regularTimeComponents should equal(regularTimeComponents);
            });

            it(@"should have the correct break time", ^{
                NSDateComponents *breakTimeComponents = [[NSDateComponents alloc] init];
                breakTimeComponents.hour = 0;
                breakTimeComponents.minute = 0;
                breakTimeComponents.second = 0;
                teamTimesheetSummary.teamWorkHoursSummary.breakTimeComponents should equal(breakTimeComponents);
            });

            it(@"should have the correct overtime hours", ^{
                NSDateComponents *overtimeComponents = [[NSDateComponents alloc] init];
                overtimeComponents.hour = 80;
                overtimeComponents.minute = 0;
                overtimeComponents.second = 0;
                teamTimesheetSummary.teamWorkHoursSummary.overtimeComponents should equal(overtimeComponents);
            });

            it(@"should have the correct number of golden timesheets", ^{
                teamTimesheetSummary.goldenTimesheets.count should equal(1);
                NSArray *userArr = [teamTimesheetSummary.goldenTimesheets[0] timesheets];
                TimeSheetApprovalStatus *approvalStatus = (TimeSheetApprovalStatus *)[userArr[0] approvalStatus];
                approvalStatus.approvalStatusUri should equal(@"urn:replicon:timesheet-status:open");
                approvalStatus.approvalStatus should equal(@"Not Submitted");
            });

            it(@"should have the correct number of nongolden timesheets", ^{
                teamTimesheetSummary.nongoldenTimesheets.count should equal(1);
            });

            it(@"should include the gross pay for the entire team", ^{
                CurrencyValue *currencyValue = fake_for([CurrencyValue class]);

                currencyValueDeserializer stub_method(@selector(deserializeForCurrencyValue:))
                .with(teamTimesheetSummaryDictionary[@"d"][@"totalPayablePay"])
                .and_return(currencyValue);

                teamTimesheetSummary = [subject deserialize:teamTimesheetSummaryDictionary];
                teamTimesheetSummary.totalPay should be_same_instance_as(currencyValue);
            });

            it(@"should include the gross hours for the entire team", ^{
                GrossHours *grossHours = fake_for([GrossHours class]);
                grossHoursDeserializer stub_method(@selector(deserializeForHoursDictionary:))
                .with(teamTimesheetSummaryDictionary[@"d"][@"totalPayableHours"])
                .and_return(grossHours);

                teamTimesheetSummary = [subject deserialize:teamTimesheetSummaryDictionary];
                teamTimesheetSummary.totalHours should be_same_instance_as(grossHours);

            });

            it(@"should parse the actualsByPaycode for the entire team", ^{


                teamTimesheetSummary = [subject deserialize:teamTimesheetSummaryDictionary];

                teamTimesheetSummary.actualsByPayCode[0] should be_same_instance_as(actualsByPayCode[0]);
                teamTimesheetSummary.actualsByPayCode[1] should be_same_instance_as(actualsByPayCode[1]);
                teamTimesheetSummary.actualsByPayCode[2] should be_same_instance_as(actualsByPayCode[2]);
                teamTimesheetSummary.actualsByPayCode[3] should be_same_instance_as(actualsByPayCode[3]);
                teamTimesheetSummary.actualsByPayCode[4] should be_same_instance_as(actualsByPayCode[4]);
                teamTimesheetSummary.actualsByPayCode[5] should be_same_instance_as(actualsByPayCode[5]);


            });

            it(@"should parse the actualsPayCodeDurationArray for the entire team", ^{


                payCodeHoursDeserializer stub_method(@selector(deserializeForHoursDictionary:))
                .with(actualsByPaycodeDict)
                .and_return(payCode);

                teamTimesheetSummary = [subject deserialize:teamTimesheetSummaryDictionary];

                teamTimesheetSummary.actualsByPayDuration[0] should be_same_instance_as(actualsByPayCode[0]);
                teamTimesheetSummary.actualsByPayDuration[1] should be_same_instance_as(actualsByPayCode[1]);
                teamTimesheetSummary.actualsByPayDuration[2] should be_same_instance_as(actualsByPayCode[2]);
                teamTimesheetSummary.actualsByPayDuration[3] should be_same_instance_as(actualsByPayCode[3]);
                teamTimesheetSummary.actualsByPayDuration[4] should be_same_instance_as(actualsByPayCode[4]);
                teamTimesheetSummary.actualsByPayDuration[5] should be_same_instance_as(actualsByPayCode[5]);
                
                
            });

            it(@"payAmountDetailsPermission should be truthy", ^{
                teamTimesheetSummary = [subject deserialize:@{}];
                teamTimesheetSummary.payAmountDetailsPermission should be_falsy;
            });




            it(@"should have the current period", ^{
                NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
                startDateComponents.day = 1;
                startDateComponents.month = 6;
                startDateComponents.year = 2015;

                NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
                endDateComponents.day = 7;
                endDateComponents.month = 6;
                endDateComponents.year = 2015;

                NSDate *expectedStartDate = [calendar dateFromComponents:startDateComponents];
                NSDate *expectedEndDate = [calendar dateFromComponents:endDateComponents];

                teamTimesheetSummary.currentPeriod.startDate should equal(expectedStartDate);
                teamTimesheetSummary.currentPeriod.endDate should equal(expectedEndDate);
            });

            it(@"should have the previous period", ^{
                NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
                startDateComponents.day = 25;
                startDateComponents.month = 5;
                startDateComponents.year = 2015;

                NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
                endDateComponents.day = 31;
                endDateComponents.month = 5;
                endDateComponents.year = 2015;

                NSDate *expectedStartDate = [calendar dateFromComponents:startDateComponents];
                NSDate *expectedEndDate = [calendar dateFromComponents:endDateComponents];

                teamTimesheetSummary.previousPeriod.startDate should equal(expectedStartDate);
                teamTimesheetSummary.previousPeriod.endDate should equal(expectedEndDate);
            });

            it(@"should have the next period", ^{
                NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
                startDateComponents.day = 8;
                startDateComponents.month = 6;
                startDateComponents.year = 2015;

                NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
                endDateComponents.day = 14;
                endDateComponents.month = 6;
                endDateComponents.year = 2015;

                NSDate *expectedStartDate = [calendar dateFromComponents:startDateComponents];
                NSDate *expectedEndDate = [calendar dateFromComponents:endDateComponents];

                teamTimesheetSummary.nextPeriod.startDate should equal(expectedStartDate);
                teamTimesheetSummary.nextPeriod.endDate should equal(expectedEndDate);
            });

            
        });

        context(@"-deserialize for null periods", ^{
            beforeEach(^{
                teamTimesheetSummaryDictionary = [RepliconSpecHelper jsonWithFixture:@"teamtimesheetsummary_period_null"];
                teamTimesheetSummary = [subject deserialize:teamTimesheetSummaryDictionary];
            });

            it(@"should have the previous period been null", ^{
                teamTimesheetSummary.previousPeriod should be_nil;

            });
        });

        context(@"the timesheets for a team", ^{
            __block TeamTimesheetsForTimePeriod *timesheets;
            __block TimesheetForUserWithWorkHours *expectedTimesheetUser;

            NSDateComponents*(^dateComponentsWithHourMinuteSecond)(NSUInteger, NSUInteger, NSUInteger) = ^NSDateComponents*(NSUInteger hour, NSUInteger minute, NSUInteger second) {
                NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                dateComponents.hour = hour;
                dateComponents.minute = minute;
                dateComponents.second = second;
                return dateComponents;
            };

            NSDateComponents*(^dateComponentsWithDayMonthYear)(NSUInteger, NSUInteger, NSUInteger) = ^NSDateComponents*(NSUInteger day, NSUInteger month, NSUInteger year) {
                NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                dateComponents.day = day;
                dateComponents.month = month;
                dateComponents.year = year;
                return dateComponents;
            };

            beforeEach(^{
                teamTimesheetSummaryDictionary = [RepliconSpecHelper jsonWithFixture:@"team_timesheet_summary"];
                teamTimesheetSummary = [subject deserialize:teamTimesheetSummaryDictionary];
                NSDate *startDate = [calendar dateFromComponents:dateComponentsWithDayMonthYear(1, 6, 2015)];
                NSDate *endDate = [calendar dateFromComponents:dateComponentsWithDayMonthYear(7, 6, 2015)];

                TimesheetPeriod *expectedPeriod = [[TimesheetPeriod alloc] initWithStartDate:startDate endDate:endDate];

                expectedTimesheetUser = [[TimesheetForUserWithWorkHours alloc] initWithTotalOvertimeHours:dateComponentsWithHourMinuteSecond(17, 23, 29)
                                                                                        totalRegularHours:dateComponentsWithHourMinuteSecond(2, 3, 5)
                                                                                          totalBreakHours:dateComponentsWithHourMinuteSecond(7, 11, 13)
                                                                                           totalWorkHours:dateComponentsWithHourMinuteSecond(19, 26, 34)
                                                                                          violationsCount:@55
                                                                                                 userName:@"Stansfield, Thomas"
                                                                                                  userURI:@"urn:replicon-tenant:wts:user:62"
                                                                                                   period:expectedPeriod
                                                                                                      uri:@"urn:replicon-tenant:wts:timesheet:d09cecb1-da00-48f9-bb1f-2a1480a0a2a0" timeSheetApprovalStatus:nil];
                
                ;


                timesheets = teamTimesheetSummary.nongoldenTimesheets.firstObject;
            });

            it(@"should have the correct start and end date", ^{
                NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
                startDateComponents.day = 1;
                startDateComponents.month = 6;
                startDateComponents.year = 2015;

                NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
                endDateComponents.day = 7;
                endDateComponents.month = 6;
                endDateComponents.year = 2015;

                NSDate *expectedStartDate = [calendar dateFromComponents:startDateComponents];
                NSDate *expectedEndDate = [calendar dateFromComponents:endDateComponents];

                TeamTimesheetsForTimePeriod *expectedTeamTimesheets = [[TeamTimesheetsForTimePeriod alloc] initWithStartDate:expectedStartDate
                                                                                                                     endDate:expectedEndDate
                                                                                                                  timesheets:@[expectedTimesheetUser]];
                timesheets.startDate should equal(expectedTeamTimesheets.startDate);
                timesheets.endDate should equal(expectedTeamTimesheets.endDate);
            });

            describe(@"the timesheet for a team member", ^{
                __block TimesheetForUserWithWorkHours *actualTimesheetUser;

                beforeEach(^{
                    actualTimesheetUser = timesheets.timesheets.firstObject;
                });

                it(@"should include the work hours for the team members in the time period", ^{
                    actualTimesheetUser.totalWorkHours should equal(expectedTimesheetUser.totalWorkHours);
                    actualTimesheetUser.totalRegularHours should equal(expectedTimesheetUser.totalRegularHours);
                    actualTimesheetUser.totalBreakHours should equal(expectedTimesheetUser.totalBreakHours);
                    actualTimesheetUser.totalOvertimeHours should equal(expectedTimesheetUser.totalOvertimeHours);
                });

                it(@"should include the count of violations", ^{
                    actualTimesheetUser.violationsCount should equal(expectedTimesheetUser.violationsCount);
                });

                it(@"should include the team member's user URI", ^{
                    actualTimesheetUser.userURI should equal(expectedTimesheetUser.userURI);
                });

                it(@"should include the team member's name", ^{
                    actualTimesheetUser.userName should equal(expectedTimesheetUser.userName);
                });

                it(@"should include the timesheet URI", ^{
                    actualTimesheetUser.uri should equal(expectedTimesheetUser.uri);
                });

                it(@"should include the starting and ending dates for the timesheet period", ^{
                    actualTimesheetUser.period.startDate should equal(expectedTimesheetUser.period.startDate);
                    actualTimesheetUser.period.endDate should equal(expectedTimesheetUser.period.endDate);
                });
            });
        });

        context(@"-deserialize for null hours", ^{
            beforeEach(^{
                teamTimesheetSummaryDictionary = [RepliconSpecHelper jsonWithFixture:@"team_timesheet_summary_with_null_hours"];
                teamTimesheetSummary = [subject deserialize:teamTimesheetSummaryDictionary];
            });

            it(@"should have a total violations count", ^{
                teamTimesheetSummary.totalViolationsCount should equal(0);
            });

            it(@"should have the correct total worked time", ^{
                TeamWorkHoursSummary *expectedTeamWorkHours= [[TeamWorkHoursSummary alloc] initWithOvertimeComponents:nil
                                                                                                regularTimeComponents:nil
                                                                                                  breakTimeComponents:nil
                                                                                                    timeOffComponents:nil
                                                                                                       isScheduledDay:YES];

                teamTimesheetSummary.teamWorkHoursSummary should equal(expectedTeamWorkHours);
            });

            it(@"should have the correct number of golden timesheets", ^{
                teamTimesheetSummary.goldenTimesheets.count should equal(3);
                teamTimesheetSummary.goldenTimesheets should_not be_nil;
            });

            it(@"should have the correct number of nongolden timesheets", ^{
                teamTimesheetSummary.nongoldenTimesheets.count should equal(0);
            });

            it(@"should include the gross pay for the entire team", ^{
                CurrencyValue *currencyValue = fake_for([CurrencyValue class]);

                currencyValueDeserializer stub_method(@selector(deserializeForCurrencyValue:))
                .with(teamTimesheetSummaryDictionary[@"d"][@"totalPayablePay"])
                .and_return(currencyValue);

                teamTimesheetSummary = [subject deserialize:teamTimesheetSummaryDictionary];
                teamTimesheetSummary.totalPay should be_same_instance_as(currencyValue);
            });

            it(@"should have the current period", ^{
                NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
                startDateComponents.day = 7;
                startDateComponents.month = 9;
                startDateComponents.year = 2015;

                NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
                endDateComponents.day = 13;
                endDateComponents.month = 9;
                endDateComponents.year = 2015;

                NSDate *expectedStartDate = [calendar dateFromComponents:startDateComponents];
                NSDate *expectedEndDate = [calendar dateFromComponents:endDateComponents];

                teamTimesheetSummary.currentPeriod.startDate should equal(expectedStartDate);
                teamTimesheetSummary.currentPeriod.endDate should equal(expectedEndDate);
            });

            it(@"should have the previous period", ^{
                NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
                startDateComponents.day = 31;
                startDateComponents.month = 8;
                startDateComponents.year = 2015;

                NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
                endDateComponents.day = 6;
                endDateComponents.month = 9;
                endDateComponents.year = 2015;

                NSDate *expectedStartDate = [calendar dateFromComponents:startDateComponents];
                NSDate *expectedEndDate = [calendar dateFromComponents:endDateComponents];

                teamTimesheetSummary.previousPeriod.startDate should equal(expectedStartDate);
                teamTimesheetSummary.previousPeriod.endDate should equal(expectedEndDate);
            });

            it(@"should have the next period", ^{
                NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
                startDateComponents.day = 14;
                startDateComponents.month = 9;
                startDateComponents.year = 2015;

                NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
                endDateComponents.day = 20;
                endDateComponents.month = 9;
                endDateComponents.year = 2015;

                NSDate *expectedStartDate = [calendar dateFromComponents:startDateComponents];
                NSDate *expectedEndDate = [calendar dateFromComponents:endDateComponents];
                
                teamTimesheetSummary.nextPeriod.startDate should equal(expectedStartDate);
                teamTimesheetSummary.nextPeriod.endDate should equal(expectedEndDate);
            });

        });
    });
});

SPEC_END
