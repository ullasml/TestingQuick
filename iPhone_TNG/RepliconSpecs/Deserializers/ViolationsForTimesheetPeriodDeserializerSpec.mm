#import <Cedar/Cedar.h>
#import "RepliconSpecHelper.h"

#import "ViolationsForTimesheetPeriodDeserializer.h"
#import "SingleViolationDeserializer.h"
#import "ViolationSection.h"
#import "AllViolationSections.h"
#import "Util.h"
#import "Violation.h"
#import "Waiver.h"
#import "ViolationsDeserializer.h"
#import "WaiverDeserializer.h"
#import "WaiverOption.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ViolationsForTimesheetPeriodDeserializerSpec)

describe(@"ViolationsForTimesheetPeriodDeserializer", ^{
    __block ViolationsForTimesheetPeriodDeserializer *subject;
    __block NSCalendar *calendar;

    beforeEach(^{
        WaiverDeserializer *waiverDeserializer = [[WaiverDeserializer alloc] init];
        SingleViolationDeserializer *singleViolationDeserializer = [[SingleViolationDeserializer alloc] initWithWaiverDeserializer:waiverDeserializer];

        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

        subject = [[ViolationsForTimesheetPeriodDeserializer alloc] initWithSingleViolationDeserializer:singleViolationDeserializer
                                                                                               calendar:calendar];
    });

    describe(@"creating a list of violations for a timesheet period, grouped by date", ^{
        __block AllViolationSections *allViolationSections;

        beforeEach(^{
            NSDictionary *violationsForTimesheetPeriodDictionary = [RepliconSpecHelper jsonWithFixture:@"employee_violations_by_day"];
            allViolationSections = [subject deserialize:violationsForTimesheetPeriodDictionary timesheetType:AstroTimesheetType];
        });

        it(@"should have as many sections as there are days with violations", ^{
            allViolationSections.sections.count should equal(5);
        });

        it(@"should correction deserialize the date for each violation section", ^{
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            dateComponents.year = 2015;
            dateComponents.month = 6;
            dateComponents.day = 1;

            NSDate *expectedDate = [calendar dateFromComponents:dateComponents];

            ViolationSection *section = allViolationSections.sections.firstObject;
            section.type should equal(ViolationSectionTypeDate);
            section.titleObject should equal(expectedDate);
        });

        it(@"should deserialize the violations for each violation section", ^{
            ViolationSection *section1 = allViolationSections.sections[0];
            section1.violations.count should equal(1);

            Violation *violation1 = section1.violations.firstObject;
            violation1.title should equal(@"Please enter at least 8 hours.");
            violation1.severity should equal(ViolationSeverityError);
            violation1.waiver should be_nil;

            ViolationSection *section2 = allViolationSections.sections[1];
            section2.violations.count should equal(2);

            Violation *violation2 = section2.violations.firstObject;
            violation2.title should equal(@"You did not take a meal break.");
            violation2.severity should equal(ViolationSeverityWarning);

            Waiver *waiver = violation2.waiver;
            waiver.URI should equal(@"urn:replicon-tenant:vin-test:validation-waiver:d8c4eba9-4076-4dca-8c7b-670cab968350");
            waiver.displayText should equal(@"To waive this violation, click the button below.");
            waiver.options.count should equal(2);

            WaiverOption *option = waiver.options[0];
            option.displayText should equal(@"Waive Meal Penalty");
            option.value should equal(@"accept");

            waiver.selectedOption.displayText should equal(@"Do not Waive");
            waiver.selectedOption.value should equal(@"reject");
        });

        it(@"should have as many violations as totalTimesheetPeriodValidationMessagesCount", ^{
            allViolationSections.totalViolationsCount should equal(8);
        });
    });

    describe(@"creating a list of violations for a timesheet period with timesheet level violations", ^{
        __block AllViolationSections *allViolationSections;

        beforeEach(^{
            NSDictionary *violationsForTimesheetPeriodDictionary = [RepliconSpecHelper jsonWithFixture:@"employee_violations_by_day_plus_timesheet_level_violation"];
            allViolationSections = [subject deserialize:violationsForTimesheetPeriodDictionary timesheetType:AstroTimesheetType];
        });

        it(@"should have as many sections as there are days with violations plus a timesheet level violations section", ^{
            allViolationSections.sections.count should equal(2);
        });

        it(@"should deserialize the timesheet level violation section appropriately", ^{
            ViolationSection *section = allViolationSections.sections.firstObject;
            section.type should equal(ViolationSectionTypeTimesheet);
            section.titleObject should be_nil;
        });

        it(@"should deserialize the violations for each violation section", ^{
            ViolationSection *section1 = allViolationSections.sections[0];
            section1.violations.count should equal(1);

            Violation *violation1 = section1.violations.firstObject;
            violation1.title should equal(@"Time Entered information is not equal to 35");
            violation1.severity should equal(ViolationSeverityError);

            Waiver *waiver = violation1.waiver;
            waiver.URI should equal(@"urn:replicon-tenant:vin-test:validation-waiver:a2cc2e7e-2390-43f5-b856-d34db33f");
            waiver.displayText should equal(@"To waive this violation, click the button below.");
            waiver.options.count should equal(2);

            ViolationSection *section2 = allViolationSections.sections[1];
            section2.violations.count should equal(1);

            Violation *violation2 = section2.violations.firstObject;
            violation2.title should equal(@"Please enter at least 8 hours.");
            violation2.severity should equal(ViolationSeverityError);
            violation2.waiver should be_nil;
        });

        it(@"should have as many violations as totalTimesheetPeriodValidationMessagesCount", ^{
            allViolationSections.totalViolationsCount should equal(2);
        });
    });
    
    describe(@"creating a list of violations for a timesheet period, grouped by date for widget timeshhet", ^{
        __block AllViolationSections *allViolationSections;
        
        beforeEach(^{
            NSMutableDictionary *violationsForTimesheetPeriodDictionary = [NSMutableDictionary dictionaryWithDictionary:[RepliconSpecHelper jsonWithFixture:@"employee_violations_by_day"]];
            violationsForTimesheetPeriodDictionary[@"totalTimesheetPeriodViolationMessagesCount"] = @4;
            allViolationSections = [subject deserialize:violationsForTimesheetPeriodDictionary timesheetType:WidgetTimesheetType];
        });
        
        it(@"should have as many sections as there are days with violations", ^{
            allViolationSections.sections.count should equal(5);
        });
        
        it(@"should correction deserialize the date for each violation section", ^{
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            dateComponents.year = 2015;
            dateComponents.month = 6;
            dateComponents.day = 1;
            
            NSDate *expectedDate = [calendar dateFromComponents:dateComponents];
            
            ViolationSection *section = allViolationSections.sections.firstObject;
            section.type should equal(ViolationSectionTypeDate);
            section.titleObject should equal(expectedDate);
        });
        
        it(@"should deserialize the violations for each violation section", ^{
            ViolationSection *section1 = allViolationSections.sections[0];
            section1.violations.count should equal(1);
            
            Violation *violation1 = section1.violations.firstObject;
            violation1.title should equal(@"Please enter at least 8 hours.");
            violation1.severity should equal(ViolationSeverityError);
            violation1.waiver should be_nil;
            
            ViolationSection *section2 = allViolationSections.sections[1];
            section2.violations.count should equal(2);
            
            Violation *violation2 = section2.violations.firstObject;
            violation2.title should equal(@"You did not take a meal break.");
            violation2.severity should equal(ViolationSeverityWarning);
            
            Waiver *waiver = violation2.waiver;
            waiver.URI should equal(@"urn:replicon-tenant:vin-test:validation-waiver:d8c4eba9-4076-4dca-8c7b-670cab968350");
            waiver.displayText should equal(@"To waive this violation, click the button below.");
            waiver.options.count should equal(2);
            
            WaiverOption *option = waiver.options[0];
            option.displayText should equal(@"Waive Meal Penalty");
            option.value should equal(@"accept");
            
            waiver.selectedOption.displayText should equal(@"Do not Waive");
            waiver.selectedOption.value should equal(@"reject");
        });
        
        it(@"should have as many violations as totalTimesheetPeriodValidationMessagesCount", ^{
            allViolationSections.totalViolationsCount should equal(4);
        });
    });
});

SPEC_END
