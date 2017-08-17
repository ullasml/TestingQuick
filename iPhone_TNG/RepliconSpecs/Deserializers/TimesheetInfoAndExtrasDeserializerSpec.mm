#import <Cedar/Cedar.h>
#import "TimesheetInfoAndExtrasDeserializer.h"
#import <Blindside/BlindSide.h>
#import "InjectorProvider.h"
#import "ViolationsForTimesheetPeriodDeserializer.h"
#import "InjectorKeys.h"
#import "RepliconSpecHelper.h"
#import "AllViolationSections.h"
#import "TimesheetAdditionalInfo.h"
#import "TimeSheetPermittedActionsDeserializer.h"
#import "TimeSheetPermittedActions.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetInfoAndExtrasDeserializerSpec)

describe(@"TimesheetInfoAndExtrasDeserializer", ^{
    __block TimesheetInfoAndExtrasDeserializer *subject;
    __block id <BSInjector,BSBinder> injector;
    __block ViolationsForTimesheetPeriodDeserializer *violationsForTimesheetPeriodDeserializer;
    __block NSCalendar *calendar;
    __block NSDateFormatter *dateFormatterWithWeekday;
    __block NSDateFormatter *dateFormatterWithAMPM;
    __block NSMutableDictionary *jsonDictionary;
    __block AllViolationSections *expectedViolationSections;
    __block TimeSheetPermittedActions *expectedTimeSheetPermittedActions;
    __block TimesheetAdditionalInfo *timesheetAdditionalInfo;
    __block TimeSheetPermittedActionsDeserializer *timeSheetPermittedActionsDeserializer;

    beforeEach(^{
        
        injector = [InjectorProvider injector];
        
        expectedViolationSections = nice_fake_for([AllViolationSections class]);
        expectedTimeSheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);

        timeSheetPermittedActionsDeserializer = nice_fake_for([TimeSheetPermittedActionsDeserializer class]);
        [injector bind:[TimeSheetPermittedActionsDeserializer class] toInstance:timeSheetPermittedActionsDeserializer];

        violationsForTimesheetPeriodDeserializer = nice_fake_for([ViolationsForTimesheetPeriodDeserializer class]);
        [injector bind:[ViolationsForTimesheetPeriodDeserializer class] toInstance:violationsForTimesheetPeriodDeserializer];

        dateFormatterWithWeekday = nice_fake_for([NSDateFormatter class]);
        [injector bind:InjectorKeyShortDateWithWeekdayInLocalTimeZoneFormatter toInstance:dateFormatterWithWeekday];

        dateFormatterWithAMPM = nice_fake_for([NSDateFormatter class]);
        [injector bind:InjectorKeyShortTimeWithAMPMInLocalTimeZoneFormatter toInstance:dateFormatterWithAMPM];

        calendar = nice_fake_for([NSCalendar class]);
        [injector bind:InjectorKeyCalendarWithUTCTimeZone toInstance:calendar];
        
        jsonDictionary = [NSMutableDictionary dictionaryWithDictionary:[RepliconSpecHelper jsonWithFixture:@"timesheet_extras"]];

        violationsForTimesheetPeriodDeserializer stub_method(@selector(deserialize:timesheetType:)).with(jsonDictionary,AstroTimesheetType).and_return(expectedViolationSections);
        timeSheetPermittedActionsDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedTimeSheetPermittedActions);
        
        subject = [injector getInstance:[TimesheetInfoAndExtrasDeserializer class]];


    });
    
    context(@"deserialize:", ^{
        
        beforeEach(^{
            timesheetAdditionalInfo = [subject deserialize:jsonDictionary];
        });
        
        it(@"should correctly deserialize and set AllViolationSections", ^{
            timesheetAdditionalInfo.allViolationSections should equal(expectedViolationSections);
        });
        
        it(@"should correctly deserialize and set TimeSheetPermittedActions", ^{
            timesheetAdditionalInfo.timesheetPermittedActions should equal(expectedTimeSheetPermittedActions);
        });
        
        context(@"should correctly deserialize scriptCalculationStatus", ^{
            
            context(@"when scriptCalculationStatus is absent", ^{
                beforeEach(^{
                    [jsonDictionary removeObjectForKey:@"scriptCalculationStatus"];
                    timesheetAdditionalInfo = [subject deserialize:jsonDictionary];
                });
                
                it(@"should correctly set scriptCalculationDateValue", ^{
                    timesheetAdditionalInfo.scriptCalculationDateValue should be_nil;
                });
            });
            
            context(@"when scriptCalculationStatus is present", ^{
                __block NSDate *date;
                __block NSString *expectedScriptCalculationString;
                beforeEach(^{
                    date = nice_fake_for([NSDate date]);
                    NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
                    dateComponents.day = 5;
                    dateComponents.month = 6;
                    dateComponents.year = 2017;
                    dateComponents.hour = 7;
                    dateComponents.minute = 2;
                    dateComponents.second = 47;
                    
                    calendar stub_method(@selector(dateFromComponents:)).with(dateComponents).and_return(date);
                    
                    dateFormatterWithWeekday stub_method(@selector(stringFromDate:)).with(date).and_return(@"some-weekday");
                    dateFormatterWithAMPM stub_method(@selector(stringFromDate:)).with(date).and_return(@"some-am-pm");


                    expectedScriptCalculationString = [NSString stringWithFormat:@"%@ %@ at %@",RPLocalizedString(@"Data as of", @""),@"some-weekday",@"some-am-pm"];
                    
                    timesheetAdditionalInfo = [subject deserialize:jsonDictionary];
                });
                
                it(@"should correctly set scriptCalculationDateValue", ^{
                    timesheetAdditionalInfo.scriptCalculationDateValue should equal(expectedScriptCalculationString);
                });
            });
        });
        
        context(@"should correctly deserialize and set payAmountDetailsPermission", ^{

            it(@"when displayPayAmount is absent", ^{
                [jsonDictionary removeObjectForKey:@"permittedActions"];
                timesheetAdditionalInfo = [subject deserialize:jsonDictionary];
                timesheetAdditionalInfo.payAmountDetailsPermission should be_falsy;
            });
            
            it(@"when displayPayAmount is present", ^{
                timesheetAdditionalInfo = [subject deserialize:jsonDictionary];
                timesheetAdditionalInfo.payAmountDetailsPermission should be_truthy;
            });
        });
        
        context(@"should correctly deserialize and set payDetailsPermission", ^{
            
            it(@"when canOwnerViewPayrollSummary is absent", ^{
                [jsonDictionary removeObjectForKey:@"permittedActions"];
                timesheetAdditionalInfo = [subject deserialize:jsonDictionary];
                timesheetAdditionalInfo.payDetailsPermission should be_falsy;
            });
            
            it(@"when canOwnerViewPayrollSummary is present", ^{
                timesheetAdditionalInfo = [subject deserialize:jsonDictionary];
                timesheetAdditionalInfo.payDetailsPermission should be_truthy;
            });
        });
    });
});

SPEC_END
