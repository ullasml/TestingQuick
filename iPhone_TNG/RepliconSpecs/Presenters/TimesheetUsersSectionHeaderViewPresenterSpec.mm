#import <Cedar/Cedar.h>
#import "TimesheetUsersSectionHeaderViewPresenter.h"
#import "Theme.h"
#import "TeamTimesheetsForTimePeriod.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetUsersSectionHeaderViewPresenterSpec)

describe(@"TimesheetUsersSectionHeaderViewPresenter", ^{
    __block TimesheetUsersSectionHeaderViewPresenter *subject;
    __block id<Theme> theme;
    __block NSDateFormatter *longDateFormatter;
    __block NSDateFormatter *shortDateFormatter;

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        longDateFormatter = fake_for([NSDateFormatter class]);
        shortDateFormatter = fake_for([NSDateFormatter class]);

        subject = [[TimesheetUsersSectionHeaderViewPresenter alloc] initWithTheme:theme
                                                            dateWithYearFormatter:longDateFormatter
                                                         dateWithoutYearFormatter:shortDateFormatter];
    });

    context(@"labelForSectionHeaderWithTimesheet", ^{
        __block TeamTimesheetsForTimePeriod *teamTimesheetsForTimePeriod;

        beforeEach(^{
            NSDate *fakeStartDate = nice_fake_for([NSDate class]);
            NSDate *fakeEndDate = nice_fake_for([NSDate class]);
            teamTimesheetsForTimePeriod = nice_fake_for([TeamTimesheetsForTimePeriod class]);
            teamTimesheetsForTimePeriod stub_method(@selector(startDate)).and_return(fakeStartDate);
            teamTimesheetsForTimePeriod stub_method(@selector(endDate)).and_return(fakeEndDate);

            shortDateFormatter stub_method(@selector(stringFromDate:))
                .with(teamTimesheetsForTimePeriod.startDate)
                .and_return(@"Mar 1");

            longDateFormatter stub_method(@selector(stringFromDate:))
                .with(teamTimesheetsForTimePeriod.endDate)
                .and_return(@"Mar 7, 2015");
        });

        it(@"should return the correctly formatted date", ^{
            NSString *label = [subject labelForSectionHeaderWithTimesheet:teamTimesheetsForTimePeriod];
            label should equal(@"Mar 1 - Mar 7, 2015");
        });
    });

    context(@"fontForSectionHeader", ^{
        beforeEach(^{
            theme stub_method(@selector(supervisorTeamTimesheetsSectionHeaderFont)).and_return([UIFont systemFontOfSize:12.0f]);
        });

        it(@"should return the font from the theme", ^{
            [subject fontForSectionHeader] should equal([UIFont systemFontOfSize:12.0f]);
        });
    });

    context(@"fontColorForSectionHeader", ^{
        beforeEach(^{
            theme stub_method(@selector(supervisorTeamTimesheetsSectionFontColor)).and_return([UIColor redColor]);
        });

        it(@"should return the color from the theme", ^{
            [subject fontColorForSectionHeader] should equal([UIColor redColor]);
        });
    });


});

SPEC_END
