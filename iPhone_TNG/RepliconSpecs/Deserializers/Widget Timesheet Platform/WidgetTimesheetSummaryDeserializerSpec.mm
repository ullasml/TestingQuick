#import <Cedar/Cedar.h>
#import "RepliconSpecHelper.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WidgetTimesheetSummaryDeserializerSpec)


describe(@"WidgetTimesheetSummaryDeserializer", ^{
    __block WidgetTimesheetSummaryDeserializer *subject;
    __block id <BSInjector,BSBinder> injector;
    __block ViolationsForTimesheetPeriodDeserializer *violationsForTimesheetPeriodDeserializer;
    __block Summary *receivedWidgetTimesheetSummary;
    __block NSDateFormatter *shortDateFormatter;
    __block NSDateFormatter *shortTimeFormatter;
    __block NSCalendar *calendar;
    __block TimeSheetPermittedActionsDeserializer *timeSheetPermittedActionsDeserializer;
    __block CurrencyValueDeserializer *currencyValueDeserializer;
    __block GrossHoursDeserializer *grossHoursDeserializer;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        violationsForTimesheetPeriodDeserializer = nice_fake_for([ViolationsForTimesheetPeriodDeserializer class]);
        [injector bind:[ViolationsForTimesheetPeriodDeserializer class] toInstance:violationsForTimesheetPeriodDeserializer];
        
        currencyValueDeserializer = nice_fake_for([CurrencyValueDeserializer class]);
        [injector bind:[CurrencyValueDeserializer class] toInstance:currencyValueDeserializer];
        
        grossHoursDeserializer = nice_fake_for([GrossHoursDeserializer class]);
        [injector bind:[GrossHoursDeserializer class] toInstance:grossHoursDeserializer];
        
        timeSheetPermittedActionsDeserializer = nice_fake_for([TimeSheetPermittedActionsDeserializer class]);
        [injector bind:[TimeSheetPermittedActionsDeserializer class] toInstance:timeSheetPermittedActionsDeserializer];
        
        shortDateFormatter = nice_fake_for([NSDateFormatter class]);
        [injector bind:InjectorKeyShortDateWithWeekdayInLocalTimeZoneFormatter toInstance:shortDateFormatter];
        
        shortTimeFormatter = nice_fake_for([NSDateFormatter class]);
        [injector bind:InjectorKeyShortTimeWithAMPMInLocalTimeZoneFormatter toInstance:shortTimeFormatter];
        
        calendar = nice_fake_for([NSCalendar class]);
        [injector bind:InjectorKeyCalendarWithUTCTimeZone toInstance:calendar];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
        NSDateComponents *expectedDateComponents = [[NSDateComponents alloc]init];
        expectedDateComponents.hour = 22;
        expectedDateComponents.minute = 42;
        expectedDateComponents.second = 20;
        expectedDateComponents.day = 20;
        expectedDateComponents.month = 7;
        expectedDateComponents.year = 2017;
        
        
        calendar stub_method(@selector(dateFromComponents:)).with(expectedDateComponents).and_return(date);
        shortDateFormatter stub_method(@selector(stringFromDate:)).with(date).and_return(@"some");
        shortTimeFormatter stub_method(@selector(stringFromDate:)).with(date).and_return(@"thing");
        
        subject = [injector getInstance:[WidgetTimesheetSummaryDeserializer class]];
    });
    
    describe(@"deserialize:", ^{
        __block TimeSheetApprovalStatus *approvalStatus;
        __block TimesheetPeriod *timesheetPeriod;
        __block NSMutableDictionary *jsonDictionary;
        __block TimesheetDuration *timesheetDuration;
        __block AllViolationSections *violationsAndWaivers;
        __block TimeSheetPermittedActions *timeSheetPermittedActions;
        __block CurrencyValue *expectedGrossPay;
        __block GrossHours *expectedGrossHours;
        __block NSArray *expectedActualsByPayCodes;
        __block NSArray *expectedActualsByDuration;

        
        context(@"when valid json response", ^{
            
            beforeEach(^{
                violationsAndWaivers = nice_fake_for([AllViolationSections class]);
                jsonDictionary = [NSMutableDictionary dictionaryWithDictionary:[RepliconSpecHelper jsonWithFixture:@"widget_timesheet_summary"]];
                timeSheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                violationsForTimesheetPeriodDeserializer stub_method(@selector(deserialize:timesheetType:)).with(jsonDictionary[@"timesheetPeriodViolations"],WidgetTimesheetType).and_return(violationsAndWaivers);
                
                timeSheetPermittedActionsDeserializer stub_method(@selector(deserializeForWidgetTimesheet:isAutoSubmitEnabled:)).with(jsonDictionary,false).and_return(timeSheetPermittedActions);
                
                NSCalendar * calendar = [injector getInstance:InjectorKeyCalendarWithUTCTimeZone];
                NSDateComponents *startDateComponents = [[NSDateComponents alloc]init];
                startDateComponents.day = 10;
                startDateComponents.month = 7;
                startDateComponents.year = 2017;
                
                NSDateComponents *endDateComponents = [[NSDateComponents alloc]init];
                endDateComponents.day = 16;
                endDateComponents.month = 7;
                endDateComponents.year = 2017;
                
                NSDateComponents *workComponents = [[NSDateComponents alloc]init];
                workComponents.hour = 3;
                workComponents.minute = 4;
                workComponents.second = 5;
                
                NSDateComponents *breakComponents = [[NSDateComponents alloc]init];
                breakComponents.hour = 1;
                breakComponents.minute = 2;
                breakComponents.second = 3;
                
                NSDateComponents *timeoffComponents = [[NSDateComponents alloc]init];
                timeoffComponents.hour = 6;
                timeoffComponents.minute = 7;
                timeoffComponents.second = 8;
                
                
                timesheetDuration = [[TimesheetDuration alloc]initWithRegularHours:workComponents
                                                                        breakHours:breakComponents
                                                                      timeOffHours:timeoffComponents];
                
                NSDate *startDate = [calendar dateFromComponents:startDateComponents];
                NSDate *endDate = [calendar dateFromComponents:endDateComponents];
                approvalStatus = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:timesheet-status:open"
                                                                            approvalStatus:@"Not Submitted"];
                
                timesheetPeriod = [[TimesheetPeriod alloc]initWithStartDate:startDate
                                                                    endDate:endDate];
                
                Paycode *payCode = [[Paycode alloc]initWithValue:@"$0.00" title:@"Regular Time" timeSeconds:nil];
                Paycode *payCodeDuration = [[Paycode alloc]initWithValue:@"1h:0m" title:@"Regular Time" timeSeconds:@"1h:0m:0s"];
                expectedActualsByPayCodes = @[payCode];
                expectedActualsByDuration = @[payCodeDuration];
                expectedGrossPay = nice_fake_for([CurrencyValue class]);
                expectedGrossHours = nice_fake_for([GrossHours class]);
                grossHoursDeserializer stub_method(@selector(deserializeForHoursDictionary:)).with(jsonDictionary[@"totalPayableTimeDuration"]).and_return(expectedGrossHours);
                currencyValueDeserializer stub_method(@selector(deserializeForCurrencyValue:)).with(jsonDictionary[@"totalPayablePay"]).and_return(expectedGrossPay);
                
                receivedWidgetTimesheetSummary = [subject deserialize:jsonDictionary isAutoSubmitEnabled:false];
                
            });
            
            it(@"should correctly set the  workBreakAndTimeoffDuration", ^{
                receivedWidgetTimesheetSummary.workBreakAndTimeoffDuration should equal(timesheetDuration);
            });
            
            it(@"should correctly deserialize PayWidgetData", ^{
                receivedWidgetTimesheetSummary.payWidgetData.grossHours should equal(expectedGrossHours);
                receivedWidgetTimesheetSummary.payWidgetData.grossPay should equal(expectedGrossPay);
                receivedWidgetTimesheetSummary.payWidgetData.actualsByPaycode should equal(expectedActualsByPayCodes);
                receivedWidgetTimesheetSummary.payWidgetData.actualsByDuration should equal(expectedActualsByDuration);
            });
            
            context(@"should correctly deserialize timeSheetPermittedActions", ^{
                
                context(@"when isAutoSubmitEnabled is truthy", ^{
                    
                    beforeEach(^{
                        timeSheetPermittedActionsDeserializer stub_method(@selector(deserializeForWidgetTimesheet:isAutoSubmitEnabled:)).with(jsonDictionary,true).and_return(timeSheetPermittedActions);
                        receivedWidgetTimesheetSummary = [subject deserialize:jsonDictionary isAutoSubmitEnabled:true];
                    });
                    
                    it(@"should correctly set the  timeSheetPermittedActions", ^{
                        receivedWidgetTimesheetSummary.timeSheetPermittedActions should equal(timeSheetPermittedActions);                
                    });
                });
                
                context(@"when isAutoSubmitEnabled is falsy", ^{
                    
                    beforeEach(^{
                        timeSheetPermittedActionsDeserializer stub_method(@selector(deserializeForWidgetTimesheet:isAutoSubmitEnabled:)).with(jsonDictionary,false).again().and_return(timeSheetPermittedActions);

                        receivedWidgetTimesheetSummary = [subject deserialize:jsonDictionary isAutoSubmitEnabled:false];
                    });
                    
                    it(@"should correctly set the  timeSheetPermittedActions", ^{
                        receivedWidgetTimesheetSummary.timeSheetPermittedActions should equal(timeSheetPermittedActions);                
                    });
                });
            });
            
            it(@"should correctly set the TimesheetStatus", ^{
                receivedWidgetTimesheetSummary.timesheetStatus should equal(approvalStatus);
            });
            
            it(@"should correctly set the last script calculation Date String", ^{
                receivedWidgetTimesheetSummary.lastUpdatedDateString should equal(@"some thing");
            });
            
            it(@"should ask ViolationsForTimesheetPeriodDeserializer to return correct ViolationsAndWaivers", ^{
                NSDictionary *expectedViolationsDeserializationDictionary = @{
                                                                              @"validationMessagesByDate": @[],
                                                                              @"totalTimesheetPeriodViolationMessagesCount": @0,
                                                                              @"timesheetLevelValidationMessages": @[],
                                                                              @"totalInformationCount": @0,
                                                                              @"totalErrorCount": @0,
                                                                              @"totalWarningCount": @0
                                                                              };
                violationsForTimesheetPeriodDeserializer should have_received(@selector(deserialize:timesheetType:)).with(expectedViolationsDeserializationDictionary,WidgetTimesheetType);
                receivedWidgetTimesheetSummary.violationsAndWaivers should equal(violationsAndWaivers);
            });

        });
        
        context(@"when invalid json response", ^{
            
            context(@"When nil json response", ^{
                
                beforeEach(^{
                    receivedWidgetTimesheetSummary = [subject deserialize:nil isAutoSubmitEnabled:false];
                });
                
                it(@"should request the JSONHelper to provide JSON", ^{
                    receivedWidgetTimesheetSummary should be_nil;
                });
            });
            
            context(@"When non nil invalid json response", ^{
                
                beforeEach(^{
                    receivedWidgetTimesheetSummary = [subject deserialize:@"" isAutoSubmitEnabled:false];
                });
                
                it(@"should request the SwiftyJSONHelper to provide JSON", ^{
                    receivedWidgetTimesheetSummary should be_nil;
                });
            });
            
        });
        
    });
});

SPEC_END
