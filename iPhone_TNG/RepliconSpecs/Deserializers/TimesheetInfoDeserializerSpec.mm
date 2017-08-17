#import <Cedar/Cedar.h>
#import "TimesheetInfoDeserializer.h"
#import "RepliconSpecHelper.h"
#import "TimesheetInfo.h"
#import "InjectorProvider.h"
#import <Blindside/BlindSide.h>
#import "InjectorKeys.h"
#import "TimesheetPeriod.h"
#import "TimeSheetApprovalStatus.h"
#import "TimesheetDaySummary.h"
#import "TimePeriodSummary.h"
#import "RemotePunch.h"
#import "Activity.h"
#import "TaskType.h"
#import "ProjectType.h"
#import "RemotePunchDeserializer.h"
#import "CurrencyValueDeserializer.h"
#import "GrossHoursDeserializer.h"
#import "ActualsByPayCodeDeserializer.h"
#import "PayCodeHoursDeserializer.h"
#import "CurrencyValue.h"
#import "GrossHours.h"
#import "Paycode.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetInfoDeserializerSpec)

describe(@"TimesheetInfoDeserializer", ^{
    __block TimesheetInfoDeserializer *subject;
    __block TimesheetInfo *expectedTimesheetInfo;
    __block id <BSInjector,BSBinder> injector;
    __block NSMutableDictionary *infoDictionary;
    __block NSCalendar *calendar;
    __block NSDate *startDate;
    __block NSDate *endDate;
    __block TimesheetPeriod *expectedTimesheetPeriod;
    __block TimeSheetApprovalStatus *expectedTimeSheetApprovalStatus;
    __block RemotePunchDeserializer *remotePunchDeserializer;
    __block CurrencyValueDeserializer *currencyValueDeserializer;
    __block GrossHoursDeserializer *grossHoursDeserializer;
    __block ActualsByPayCodeDeserializer *actualsByPayCodeDeserializer;
    __block PayCodeHoursDeserializer *payCodeHoursDeserializer;
    
    NSDateComponents *(^timeComponents)(NSInteger ,NSInteger,NSInteger) = ^(NSInteger hours, NSInteger minutes ,NSInteger seconds){
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.hour = hours;
        dateComponents.minute = minutes;
        dateComponents.second = seconds;
        return dateComponents;
    };
    
    NSDateComponents *(^dateComponents)(NSInteger ,NSInteger,NSInteger) = ^(NSInteger day, NSInteger month ,NSInteger year){
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.day = day;
        dateComponents.month = month;
        dateComponents.year = year;
        return dateComponents;
    };

    beforeEach(^{
        startDate = [NSDate dateWithTimeIntervalSince1970:0];
        endDate = [NSDate dateWithTimeIntervalSince1970:1];
        
        expectedTimeSheetApprovalStatus = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:approval-status:open"
                                                                                     approvalStatus:@"Not Submitted"];

        infoDictionary = [NSMutableDictionary dictionaryWithDictionary:[RepliconSpecHelper jsonWithFixture:@"timesheet_info"]];
        injector = [InjectorProvider injector];
        
        calendar = nice_fake_for([NSCalendar class]);
        NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
        startDateComponents.day = 29;
        startDateComponents.month = 5;
        startDateComponents.year = 2017;
        
        NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
        endDateComponents.day = 4;
        endDateComponents.month = 6;
        endDateComponents.year = 2017;
        
        calendar stub_method(@selector(dateFromComponents:)).with(startDateComponents).and_return(startDate);
        calendar stub_method(@selector(dateFromComponents:)).with(endDateComponents).and_return(endDate);
        
        expectedTimesheetPeriod = [[TimesheetPeriod alloc]initWithStartDate:startDate endDate:endDate];
        [injector bind:InjectorKeyCalendarWithUTCTimeZone toInstance:calendar];
        
        remotePunchDeserializer = nice_fake_for([RemotePunchDeserializer class]);
        [injector bind:[RemotePunchDeserializer class] toInstance:remotePunchDeserializer];
        
        currencyValueDeserializer = nice_fake_for([CurrencyValueDeserializer class]);
        [injector bind:[CurrencyValueDeserializer class] toInstance:currencyValueDeserializer];
        
        grossHoursDeserializer = nice_fake_for([GrossHoursDeserializer class]);
        [injector bind:[GrossHoursDeserializer class] toInstance:grossHoursDeserializer];
        
        actualsByPayCodeDeserializer = nice_fake_for([ActualsByPayCodeDeserializer class]);
        [injector bind:[ActualsByPayCodeDeserializer class] toInstance:actualsByPayCodeDeserializer];
        
        payCodeHoursDeserializer = nice_fake_for([PayCodeHoursDeserializer class]);
        [injector bind:[PayCodeHoursDeserializer class] toInstance:payCodeHoursDeserializer];
    
        
        subject = [injector getInstance:[TimesheetInfoDeserializer class]];

    });
    
    context(@"when response is null", ^{
        beforeEach(^{
            expectedTimesheetInfo = [subject deserializeTimesheetInfo:nil];
        });
        it(@"should return an nil TimesheetInfo", ^{
            expectedTimesheetInfo should be_nil;
        });
    });
    
    context(@"when response is valid", ^{
        
        context(@"when timesheetPeriodViolations is absent", ^{
            __block RemotePunch *punchA;
            __block CurrencyValue *currencyValue;
            __block GrossHours *grossHours;
            
            beforeEach(^{
                [infoDictionary removeObjectForKey:@"timesheetPeriodViolations"];
                currencyValue = nice_fake_for([CurrencyValue class]);
                grossHours = nice_fake_for([GrossHours class]);
                punchA = nice_fake_for([RemotePunch class]);
                remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"uri":@"some-uri"}).and_return(punchA);
                NSDictionary *payableValueDictionary = @{
                                                         @"baseCurrencyValueAsOfDate": @{
                                                                 @"day": @1,
                                                                 @"month": @6,
                                                                 @"year": @2017
                                                                 },
                                                         @"multiCurrencyValue": @[
                                                                 @{
                                                                     @"amount": @3.7208,
                                                                     @"currency": @{
                                                                             @"symbol": @"$",
                                                                             @"displayText": @"$",
                                                                             @"name": @"US Dollar",
                                                                             @"uri": @"urn:replicon-tenant:eb16ca3c07834c8994f878e6cb342140:currency:1"
                                                                             }
                                                                     }
                                                                 ],
                                                         @"baseCurrencyValue": @{
                                                                 @"amount": @3.7208,
                                                                 @"currency": @{
                                                                         @"symbol": @"$",
                                                                         @"displayText": @"$",
                                                                         @"name": @"US Dollar",
                                                                         @"uri": @"urn:replicon-tenant:eb16ca3c07834c8994f878e6cb342140:currency:1"
                                                                         }
                                                                 }
                                                         };
                currencyValueDeserializer stub_method(@selector(deserializeForCurrencyValue:)).with(payableValueDictionary).and_return(currencyValue);
                NSDictionary *dateComponents =@{@"hours":@ 0,
                                                @"minutes":@0,
                                                @"seconds":@57
                                                };
                
                grossHoursDeserializer stub_method(@selector(deserializeForHoursDictionary:)).with(dateComponents).and_return(grossHours);
                expectedTimesheetInfo = [subject deserializeTimesheetInfo:@[infoDictionary]];
            });
            
            context(@"should return an valid TimesheetInfo", ^{
                
                it(@"should correctly set nonActionedValidationsCount", ^{
                    expectedTimesheetInfo.nonActionedValidationsCount should equal(0);
                });
                
                it(@"should correctly set issuesCount", ^{
                    expectedTimesheetInfo.issuesCount should equal(0);
                });
                
                it(@"should correctly set uri", ^{
                    expectedTimesheetInfo.uri should equal(@"urn:replicon-tenant:eb16ca3c07834c8994f878e6cb342140:timesheet:c080b736-ad3c-4f9a-846f-5e53ce662a5d");
                });
                
                it(@"should correctly set period", ^{
                    expectedTimesheetInfo.period should equal(expectedTimesheetPeriod);
                });
                
                it(@"should correctly set approvalStatus", ^{
                    expectedTimesheetInfo.approvalStatus should equal(expectedTimeSheetApprovalStatus);
                });
                
                context(@"should correctly set TimePeriodSummary", ^{
                    
                    context(@"should correctly set dayTimeSummaries", ^{
                        
                        context(@"for 1 object in dayTimeSummaries array", ^{
                            __block TimesheetDaySummary *timesheetDaySummary1;
                            beforeEach(^{
                                NSDateComponents *regularWorkTimeComponents1 = timeComponents(0, 0,57);
                                NSDateComponents *breakTimeComponents1 = timeComponents(0,0,0);
                                NSDateComponents *timeoffComponents1 = timeComponents(0,0,0);
                                NSDateComponents *dateComponents1 = dateComponents(29,5,2017);
                                
                                
                                timesheetDaySummary1 = [[TimesheetDaySummary alloc] initWithRegularTimeOffsetComponents:nil
                                                                                              breakTimeOffsetComponents:nil
                                                                                                  regularTimeComponents:regularWorkTimeComponents1
                                                                                             totalViolationMessageCount:0
                                                                                                    breakTimeComponents:breakTimeComponents1
                                                                                                      timeOffComponents:timeoffComponents1
                                                                                                         dateComponents:dateComponents1
                                                                                                          punchesForDay:@[punchA]
                                                                                                         isScheduledDay:YES];
                            });
                            
                            it(@"should deserialize TimesheetDaySummary correctly", ^{
                                expectedTimesheetInfo.timePeriodSummary.dayTimeSummaries[0] should equal(timesheetDaySummary1);
                            });
                        });
                        
                        context(@"for 2 object in dayTimeSummaries array", ^{
                            __block TimesheetDaySummary *timesheetDaySummary1;
                            beforeEach(^{
                                NSDateComponents *regularWorkTimeComponents1 = timeComponents(0, 0,0);
                                NSDateComponents *breakTimeComponents1 = timeComponents(0,0,0);
                                NSDateComponents *timeoffComponents1 = timeComponents(0,0,0);
                                NSDateComponents *dateComponents1 = dateComponents(30,5,2017);
                                timesheetDaySummary1 = [[TimesheetDaySummary alloc] initWithRegularTimeOffsetComponents:nil
                                                                                              breakTimeOffsetComponents:nil
                                                                                                  regularTimeComponents:regularWorkTimeComponents1
                                                                                             totalViolationMessageCount:0
                                                                                                    breakTimeComponents:breakTimeComponents1
                                                                                                      timeOffComponents:timeoffComponents1
                                                                                                         dateComponents:dateComponents1
                                                                                                          punchesForDay:nil
                                                                                                         isScheduledDay:YES];
                            });
                            
                            it(@"should deserialize TimesheetDaySummary correctly", ^{
                                expectedTimesheetInfo.timePeriodSummary.dayTimeSummaries[1] should equal(timesheetDaySummary1);
                            });
                            
                        });
                        
                        context(@"for 3 object in dayTimeSummaries array", ^{
                            __block TimesheetDaySummary *timesheetDaySummary1;
                            beforeEach(^{
                                NSDateComponents *regularWorkTimeComponents1 = timeComponents(0, 0,0);
                                NSDateComponents *breakTimeComponents1 = timeComponents(0,0,0);
                                NSDateComponents *timeoffComponents1 = timeComponents(0,0,0);
                                NSDateComponents *dateComponents1 = dateComponents(31,5,2017);
                                timesheetDaySummary1 = [[TimesheetDaySummary alloc] initWithRegularTimeOffsetComponents:nil
                                                                                              breakTimeOffsetComponents:nil
                                                                                                  regularTimeComponents:regularWorkTimeComponents1
                                                                                             totalViolationMessageCount:0
                                                                                                    breakTimeComponents:breakTimeComponents1
                                                                                                      timeOffComponents:timeoffComponents1
                                                                                                         dateComponents:dateComponents1
                                                                                                          punchesForDay:nil
                                                                                                         isScheduledDay:YES];
                            });
                            
                            it(@"should deserialize TimesheetDaySummary correctly", ^{
                                expectedTimesheetInfo.timePeriodSummary.dayTimeSummaries[2] should equal(timesheetDaySummary1);
                            });
                            
                        });
                        
                        context(@"for 4 object in dayTimeSummaries array", ^{
                            __block TimesheetDaySummary *timesheetDaySummary1;
                            beforeEach(^{
                                NSDateComponents *regularWorkTimeComponents1 = timeComponents(0, 0,0);
                                NSDateComponents *breakTimeComponents1 = timeComponents(0,0,0);
                                NSDateComponents *timeoffComponents1 = timeComponents(0,0,0);
                                NSDateComponents *dateComponents1 = dateComponents(1,6,2017);
                                timesheetDaySummary1 = [[TimesheetDaySummary alloc] initWithRegularTimeOffsetComponents:nil
                                                                                              breakTimeOffsetComponents:nil
                                                                                                  regularTimeComponents:regularWorkTimeComponents1
                                                                                             totalViolationMessageCount:0
                                                                                                    breakTimeComponents:breakTimeComponents1
                                                                                                      timeOffComponents:timeoffComponents1
                                                                                                         dateComponents:dateComponents1
                                                                                                          punchesForDay:nil
                                                                                                         isScheduledDay:YES];
                            });
                            
                            it(@"should deserialize TimesheetDaySummary correctly", ^{
                                expectedTimesheetInfo.timePeriodSummary.dayTimeSummaries[3] should equal(timesheetDaySummary1);
                            });
                            
                        });
                        
                        context(@"for 5 object in dayTimeSummaries array", ^{
                            __block TimesheetDaySummary *timesheetDaySummary1;
                            beforeEach(^{
                                NSDateComponents *regularWorkTimeComponents1 = timeComponents(0, 0,0);
                                NSDateComponents *breakTimeComponents1 = timeComponents(0,0,0);
                                NSDateComponents *timeoffComponents1 = timeComponents(0,0,0);
                                NSDateComponents *dateComponents1 = dateComponents(2,6,2017);
                                timesheetDaySummary1 = [[TimesheetDaySummary alloc] initWithRegularTimeOffsetComponents:nil
                                                                                              breakTimeOffsetComponents:nil
                                                                                                  regularTimeComponents:regularWorkTimeComponents1
                                                                                             totalViolationMessageCount:0
                                                                                                    breakTimeComponents:breakTimeComponents1
                                                                                                      timeOffComponents:timeoffComponents1
                                                                                                         dateComponents:dateComponents1
                                                                                                          punchesForDay:nil
                                                                                                         isScheduledDay:YES];
                            });
                            
                            it(@"should deserialize TimesheetDaySummary correctly", ^{
                                expectedTimesheetInfo.timePeriodSummary.dayTimeSummaries[4] should equal(timesheetDaySummary1);
                            });
                            
                        });
                        
                        context(@"for 6 object in dayTimeSummaries array", ^{
                            __block TimesheetDaySummary *timesheetDaySummary1;
                            beforeEach(^{
                                NSDateComponents *regularWorkTimeComponents1 = timeComponents(0, 0,0);
                                NSDateComponents *breakTimeComponents1 = timeComponents(0,0,0);
                                NSDateComponents *timeoffComponents1 = timeComponents(0,0,0);
                                NSDateComponents *dateComponents1 = dateComponents(3,6,2017);
                                timesheetDaySummary1 = [[TimesheetDaySummary alloc] initWithRegularTimeOffsetComponents:nil
                                                                                              breakTimeOffsetComponents:nil
                                                                                                  regularTimeComponents:regularWorkTimeComponents1
                                                                                             totalViolationMessageCount:0
                                                                                                    breakTimeComponents:breakTimeComponents1
                                                                                                      timeOffComponents:timeoffComponents1
                                                                                                         dateComponents:dateComponents1
                                                                                                          punchesForDay:nil
                                                                                                         isScheduledDay:NO];
                            });
                            
                            it(@"should deserialize TimesheetDaySummary correctly", ^{
                                expectedTimesheetInfo.timePeriodSummary.dayTimeSummaries[5] should equal(timesheetDaySummary1);
                            });
                            
                        });
                        
                        context(@"for 7 object in dayTimeSummaries array", ^{
                            __block TimesheetDaySummary *timesheetDaySummary1;
                            beforeEach(^{
                                NSDateComponents *regularWorkTimeComponents1 = timeComponents(0, 0,0);
                                NSDateComponents *breakTimeComponents1 = timeComponents(0,0,0);
                                NSDateComponents *timeoffComponents1 = timeComponents(0,0,0);
                                NSDateComponents *dateComponents1 = dateComponents(4,6,2017);
                                timesheetDaySummary1 = [[TimesheetDaySummary alloc] initWithRegularTimeOffsetComponents:nil
                                                                                              breakTimeOffsetComponents:nil
                                                                                                  regularTimeComponents:regularWorkTimeComponents1
                                                                                             totalViolationMessageCount:0
                                                                                                    breakTimeComponents:breakTimeComponents1
                                                                                                      timeOffComponents:timeoffComponents1
                                                                                                         dateComponents:dateComponents1
                                                                                                          punchesForDay:nil
                                                                                                         isScheduledDay:NO];
                            });
                            
                            it(@"should deserialize TimesheetDaySummary correctly", ^{
                                expectedTimesheetInfo.timePeriodSummary.dayTimeSummaries[6] should equal(timesheetDaySummary1);
                            });
                            
                        });
                    });
                    
                    it(@"should correctly set regularTimeComponents", ^{
                        expectedTimesheetInfo.timePeriodSummary.regularTimeComponents should equal(timeComponents(0,0,57));
                    });
                    
                    it(@"should correctly set breakTimeComponents", ^{
                        expectedTimesheetInfo.timePeriodSummary.breakTimeComponents should equal(timeComponents(0,0,0));
                    });
                    
                    it(@"should correctly set overtimeComponents", ^{
                        expectedTimesheetInfo.timePeriodSummary.overtimeComponents should be_nil;
                    });
                    
                    it(@"should correctly set timeOffComponents", ^{
                        expectedTimesheetInfo.timePeriodSummary.timeOffComponents should equal(timeComponents(0,0,0));
                    });
                    
                    it(@"should correctly set totalPay", ^{
                        expectedTimesheetInfo.timePeriodSummary.totalPay should equal(currencyValue);
                    });
                    
                    it(@"should correctly set payDetailsPermission", ^{
                        expectedTimesheetInfo.timePeriodSummary.payDetailsPermission should be_falsy;
                    });
                    
                    it(@"should correctly set payAmountDetailsPermission", ^{
                        expectedTimesheetInfo.timePeriodSummary.payAmountDetailsPermission should be_falsy;
                    });
                    
                    it(@"should correctly set totalHours", ^{
                        expectedTimesheetInfo.timePeriodSummary.totalHours should equal(grossHours);
                    });
                    
                    it(@"should correctly set scriptCalculationDate", ^{
                        expectedTimesheetInfo.timePeriodSummary.scriptCalculationDate should be_nil;
                        
                    });
                    
                    it(@"should correctly set timesheetPermittedActions", ^{
                        expectedTimesheetInfo.timePeriodSummary.timesheetPermittedActions should be_nil;
                    });
                    
                    it(@"should correctly set isSchdeuledDay", ^{
                        expectedTimesheetInfo.timePeriodSummary.isScheduledDay should be_truthy;
                    });
                    
                    context(@"should correctly set actualsByPayCode", ^{
                        
                        context(@"when actualsByPayCode is null", ^{
                            beforeEach(^{
                                infoDictionary = [NSMutableDictionary dictionaryWithDictionary:[RepliconSpecHelper jsonWithFixture:@"timesheet_info_with_no_actualsByPaycode"]];
                                expectedTimesheetInfo = [subject deserializeTimesheetInfo:@[infoDictionary]];
                            });
                            
                            it(@"should correctly set the actualsByPayCode", ^{
                                expectedTimesheetInfo.timePeriodSummary.actualsByPayCode should be_nil;
                            });
                        });
                        
                        context(@"when actualsByPayCode is present", ^{
                            __block Paycode *paycode;
                            beforeEach(^{
                                paycode = nice_fake_for([Paycode class]);
                                actualsByPayCodeDeserializer stub_method(@selector(deserializeForPayCodeDictionary:)).and_return(paycode);
                                expectedTimesheetInfo = [subject deserializeTimesheetInfo:@[infoDictionary]];
                            });
                            
                            it(@"should correctly set the actualsByPayCode", ^{
                                expectedTimesheetInfo.timePeriodSummary.actualsByPayCode should equal(@[paycode]);
                            });
                        });
                        
                    });
                    
                    context(@"should correctly set actualsByPayDuration", ^{
                        
                        context(@"when actualsByPayCode is absent", ^{
                            beforeEach(^{
                                [infoDictionary removeObjectForKey:@"actualsByPaycode"];
                                expectedTimesheetInfo = [subject deserializeTimesheetInfo:@[infoDictionary]];
                            });
                            
                            it(@"should correctly set the actualsByPayCode", ^{
                                expectedTimesheetInfo.timePeriodSummary.actualsByPayDuration should be_nil;
                            });
                        });
                        
                        context(@"when actualsByPayCode is present", ^{
                            __block Paycode *paycode;
                            __block Paycode *payCodeDuration;
                            
                            
                            context(@"when paycode is returned from actualsByPayCodeDeserializer", ^{
                                
                                context(@"when pay code duration is not nil", ^{
                                    beforeEach(^{
                                        paycode = nice_fake_for([Paycode class]);
                                        payCodeDuration = nice_fake_for([Paycode class]);
                                        actualsByPayCodeDeserializer stub_method(@selector(deserializeForPayCodeDictionary:)).and_return(paycode);
                                        payCodeHoursDeserializer stub_method(@selector(deserializeForHoursDictionary:)).and_return(payCodeDuration);
                                        expectedTimesheetInfo = [subject deserializeTimesheetInfo:@[infoDictionary]];
                                    });
                                    
                                    it(@"should correctly set the actualsByPayCode", ^{
                                        expectedTimesheetInfo.timePeriodSummary.actualsByPayDuration should equal(@[payCodeDuration]);
                                    });
                                });
                                
                                context(@"when pay code duration is nil", ^{
                                    beforeEach(^{
                                        paycode = nice_fake_for([Paycode class]);
                                        payCodeDuration = nice_fake_for([Paycode class]);
                                        actualsByPayCodeDeserializer stub_method(@selector(deserializeForPayCodeDictionary:)).and_return(paycode);
                                        payCodeHoursDeserializer stub_method(@selector(deserializeForHoursDictionary:)).and_return(nil);
                                        expectedTimesheetInfo = [subject deserializeTimesheetInfo:@[infoDictionary]];
                                    });
                                    
                                    it(@"should correctly set the actualsByPayCode", ^{
                                        expectedTimesheetInfo.timePeriodSummary.actualsByPayDuration should be_nil;
                                    });
                                });
                                
                            });
                            
                            context(@"when paycode is not returned from actualsByPayCodeDeserializer", ^{
                                beforeEach(^{
                                    actualsByPayCodeDeserializer stub_method(@selector(deserializeForPayCodeDictionary:)).and_return(nil);
                                    expectedTimesheetInfo = [subject deserializeTimesheetInfo:@[infoDictionary]];
                                });
                                
                                it(@"should correctly set the actualsByPayCode", ^{
                                    expectedTimesheetInfo.timePeriodSummary.actualsByPayDuration should be_nil;
                                });
                                
                            });
                        });
                    });
                });
            });
            
            
        });
        
        context(@"when timesheetPeriodViolations is present", ^{
            __block RemotePunch *punchA;
            __block CurrencyValue *currencyValue;
            __block GrossHours *grossHours;
            
            beforeEach(^{
                currencyValue = nice_fake_for([CurrencyValue class]);
                grossHours = nice_fake_for([GrossHours class]);
                punchA = nice_fake_for([RemotePunch class]);
                remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"uri":@"some-uri"}).and_return(punchA);
                NSDictionary *payableValueDictionary = @{
                                                         @"baseCurrencyValueAsOfDate": @{
                                                                 @"day": @1,
                                                                 @"month": @6,
                                                                 @"year": @2017
                                                                 },
                                                         @"multiCurrencyValue": @[
                                                                 @{
                                                                     @"amount": @3.7208,
                                                                     @"currency": @{
                                                                             @"symbol": @"$",
                                                                             @"displayText": @"$",
                                                                             @"name": @"US Dollar",
                                                                             @"uri": @"urn:replicon-tenant:eb16ca3c07834c8994f878e6cb342140:currency:1"
                                                                             }
                                                                     }
                                                                 ],
                                                         @"baseCurrencyValue": @{
                                                                 @"amount": @3.7208,
                                                                 @"currency": @{
                                                                         @"symbol": @"$",
                                                                         @"displayText": @"$",
                                                                         @"name": @"US Dollar",
                                                                         @"uri": @"urn:replicon-tenant:eb16ca3c07834c8994f878e6cb342140:currency:1"
                                                                         }
                                                                 }
                                                         };
                currencyValueDeserializer stub_method(@selector(deserializeForCurrencyValue:)).with(payableValueDictionary).and_return(currencyValue);
                NSDictionary *dateComponents =@{@"hours":@ 0,
                                                @"minutes":@0,
                                                @"seconds":@57
                                                };
                
                grossHoursDeserializer stub_method(@selector(deserializeForHoursDictionary:)).with(dateComponents).and_return(grossHours);
                expectedTimesheetInfo = [subject deserializeTimesheetInfo:@[infoDictionary]];
            });
            
            context(@"should return an valid TimesheetInfo", ^{
                
                it(@"should correctly set nonActionedValidationsCount", ^{
                    expectedTimesheetInfo.nonActionedValidationsCount should equal(7);
                });
                
                it(@"should correctly set issuesCount", ^{
                    expectedTimesheetInfo.issuesCount should equal(8);
                });
                
                it(@"should correctly set uri", ^{
                    expectedTimesheetInfo.uri should equal(@"urn:replicon-tenant:eb16ca3c07834c8994f878e6cb342140:timesheet:c080b736-ad3c-4f9a-846f-5e53ce662a5d");
                });
                
                it(@"should correctly set period", ^{
                    expectedTimesheetInfo.period should equal(expectedTimesheetPeriod);
                });
                
                it(@"should correctly set approvalStatus", ^{
                    expectedTimesheetInfo.approvalStatus should equal(expectedTimeSheetApprovalStatus);
                });
                
            });
        });
    });
    
    context(@"when response is valid", ^{
        
        context(@"when timepunches data coming with invalid data(with no punch uri)", ^{
            __block RemotePunch *punchA;
            __block CurrencyValue *currencyValue;
            __block GrossHours *grossHours;
            
            beforeEach(^{
                NSMutableDictionary* infoDictionaryWithInvalidPunch = [NSMutableDictionary dictionaryWithDictionary:[RepliconSpecHelper jsonWithFixture:@"timesheet_info_with_invalid_time_punches"]];
                [infoDictionaryWithInvalidPunch removeObjectForKey:@"timesheetPeriodViolations"];
                currencyValue = nice_fake_for([CurrencyValue class]);
                grossHours = nice_fake_for([GrossHours class]);
                punchA = nice_fake_for([RemotePunch class]);
                remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"uri-1":@"some-uri"}).and_return(punchA);
                NSDictionary *payableValueDictionary = @{
                                                         @"baseCurrencyValueAsOfDate": @{
                                                                 @"day": @1,
                                                                 @"month": @6,
                                                                 @"year": @2017
                                                                 },
                                                         @"multiCurrencyValue": @[
                                                                 @{
                                                                     @"amount": @3.7208,
                                                                     @"currency": @{
                                                                             @"symbol": @"$",
                                                                             @"displayText": @"$",
                                                                             @"name": @"US Dollar",
                                                                             @"uri": @"urn:replicon-tenant:eb16ca3c07834c8994f878e6cb342140:currency:1"
                                                                             }
                                                                     }
                                                                 ],
                                                         @"baseCurrencyValue": @{
                                                                 @"amount": @3.7208,
                                                                 @"currency": @{
                                                                         @"symbol": @"$",
                                                                         @"displayText": @"$",
                                                                         @"name": @"US Dollar",
                                                                         @"uri": @"urn:replicon-tenant:eb16ca3c07834c8994f878e6cb342140:currency:1"
                                                                         }
                                                                 }
                                                         };
                currencyValueDeserializer stub_method(@selector(deserializeForCurrencyValue:)).with(payableValueDictionary).and_return(currencyValue);
                NSDictionary *dateComponents =@{@"hours":@ 0,
                                                @"minutes":@0,
                                                @"seconds":@57
                                                };
                
                grossHoursDeserializer stub_method(@selector(deserializeForHoursDictionary:)).with(dateComponents).and_return(grossHours);
                expectedTimesheetInfo = [subject deserializeTimesheetInfo:@[infoDictionaryWithInvalidPunch]];
            });
            
            context(@"should return an valid TimesheetInfo", ^{
                
                it(@"should correctly set nonActionedValidationsCount", ^{
                    expectedTimesheetInfo.nonActionedValidationsCount should equal(0);
                });
                
                it(@"should correctly set issuesCount", ^{
                    expectedTimesheetInfo.issuesCount should equal(0);
                });
                
                it(@"should correctly set uri", ^{
                    expectedTimesheetInfo.uri should equal(@"urn:replicon-tenant:eb16ca3c07834c8994f878e6cb342140:timesheet:c080b736-ad3c-4f9a-846f-5e53ce662a5d");
                });
                
                it(@"should correctly set period", ^{
                    expectedTimesheetInfo.period should equal(expectedTimesheetPeriod);
                });
                
                it(@"should correctly set approvalStatus", ^{
                    expectedTimesheetInfo.approvalStatus should equal(expectedTimeSheetApprovalStatus);
                });
                
                context(@"should correctly set TimePeriodSummary", ^{
                    
                    context(@"should correctly set dayTimeSummaries", ^{
                        
                        context(@"for 1 object in dayTimeSummaries array", ^{
                            __block TimesheetDaySummary *timesheetDaySummary1;
                            beforeEach(^{
                                NSDateComponents *regularWorkTimeComponents1 = timeComponents(0, 0,57);
                                NSDateComponents *breakTimeComponents1 = timeComponents(0,0,0);
                                NSDateComponents *timeoffComponents1 = timeComponents(0,0,0);
                                NSDateComponents *dateComponents1 = dateComponents(29,5,2017);
                                
                                
                                timesheetDaySummary1 = [[TimesheetDaySummary alloc] initWithRegularTimeOffsetComponents:nil
                                                                                              breakTimeOffsetComponents:nil
                                                                                                  regularTimeComponents:regularWorkTimeComponents1
                                                                                             totalViolationMessageCount:0
                                                                                                    breakTimeComponents:breakTimeComponents1
                                                                                                      timeOffComponents:timeoffComponents1
                                                                                                         dateComponents:dateComponents1
                                                                                                          punchesForDay:nil
                                                                                                         isScheduledDay:YES];
                            });
                            
                            it(@"should deserialize TimesheetDaySummary correctly", ^{
                                expectedTimesheetInfo.timePeriodSummary.dayTimeSummaries[0] should equal(timesheetDaySummary1);
                            });
                        });
                    });
                    
                    it(@"should correctly set isSchdeuledDay", ^{
                        expectedTimesheetInfo.timePeriodSummary.isScheduledDay should be_truthy;
                    });
                    
                });
            });
        });
    });

});

SPEC_END
