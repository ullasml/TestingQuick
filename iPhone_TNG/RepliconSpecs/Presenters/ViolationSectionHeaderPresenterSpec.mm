#import <Cedar/Cedar.h>
#import "ViolationSectionHeaderPresenter.h"
#import "DateProvider.h"
#import "ViolationEmployee.h"
#import "ViolationSection.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ViolationSectionHeaderPresenterSpec)

describe(@"ViolationSectionHeaderPresenter", ^{
    __block ViolationSectionHeaderPresenter *subject;
    __block NSDateFormatter *dateFormatter;

    beforeEach(^{
        dateFormatter = nice_fake_for([NSDateFormatter class]);
        subject = [[ViolationSectionHeaderPresenter alloc] initWithDateFormatter:dateFormatter];
    });

    describe(@"presenting the section header", ^{
        context(@"with a date section", ^{
            __block NSDate *date;

            beforeEach(^{
                date = fake_for([NSDate class]);
                dateFormatter stub_method(@selector(stringFromDate:)).with(date).and_return(@"My special date");
            });

            it(@"should present todays date in the section header", ^{
                ViolationSection *violationSection = [[ViolationSection alloc] initWithTitleObject:date violations:@[] type:ViolationSectionTypeDate];
                NSString *sectionHeader = [subject sectionHeaderTextWithViolationSection:violationSection];
                sectionHeader should equal(@"My special date");
            });
        });

        context(@"with a timesheet section", ^{
            it(@"should present Timesheet Level Violations as the section header", ^{
                ViolationSection *violationSection = [[ViolationSection alloc] initWithTitleObject:nil violations:@[] type:ViolationSectionTypeTimesheet];
                NSString *sectionHeader = [subject sectionHeaderTextWithViolationSection:violationSection];
                sectionHeader should equal(RPLocalizedString(@"Timesheet Level Violations", @""));
            });
        });

        context(@"with a violation employee section", ^{
            it(@"should present the employee's name in the section header text", ^{
                ViolationEmployee *employee = [[ViolationEmployee alloc] initWithName:@"My Special Name"
                                                                                  uri:(id)[NSNull null]
                                                                           violations:(id)[NSNull null]];
                ViolationSection *violationSection = [[ViolationSection alloc] initWithTitleObject:employee violations:@[] type:ViolationSectionTypeEmployee];
                NSString *sectionHeaderText = [subject sectionHeaderTextWithViolationSection:violationSection];

                sectionHeaderText should equal(@"My Special Name");
            });
        });
    });
});

SPEC_END
