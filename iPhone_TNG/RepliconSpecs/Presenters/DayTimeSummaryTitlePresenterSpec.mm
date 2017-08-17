#import <Cedar/Cedar.h>
#import "DayTimeSummaryTitlePresenter.h"
#import "InjectorKeys.h"
#import "InjectorProvider.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorKeys.h"
#import "Theme.h"
#import "WorkHours.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(DayTimeSummaryTitlePresenterSpec)

describe(@"DayTimeSummaryTitlePresenter", ^{
    __block DayTimeSummaryTitlePresenter *subject;
    __block NSCalendar *calendar;
    __block NSDateFormatter *dateFormatter;
    __block id<Theme> theme;
    __block id<BSBinder, BSInjector> injector;
    __block id <WorkHours> workHours;
    __block NSDateComponents *dateComponents;
    __block NSDate *date;
    __block NSAttributedString *expectedAttributedString;

    beforeEach(^{
        injector = [InjectorProvider injector];
        
        date = nice_fake_for([NSDate class]);
        
        workHours = nice_fake_for(@protocol(WorkHours));
        dateComponents = nice_fake_for([NSDateComponents class]);
        workHours stub_method(@selector(dateComponents)).and_return(dateComponents);
        
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        calendar = nice_fake_for([NSCalendar class]);
        [injector bind:InjectorKeyCalendarWithLocalTimeZone toInstance:calendar];
        
        dateFormatter = nice_fake_for([NSDateFormatter class]);
        [injector bind:InjectorKeyDayMonthInLocalTimeZoneFormatterWithComma toInstance:dateFormatter];
        
        theme stub_method(@selector(timesheetBreakdownDateFont)).and_return([UIFont systemFontOfSize:1]);
        calendar stub_method(@selector(dateFromComponents:)).with(dateComponents).and_return(date);
        dateFormatter stub_method(@selector(stringFromDate:)).with(date).and_return(@"some-string");
        expectedAttributedString = [[NSAttributedString alloc] initWithString:@"some-string"
                                                                   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:1]}];
        subject = [injector getInstance:[DayTimeSummaryTitlePresenter class]];
        

    });
    
    it(@"should correctly return NSAttributedString", ^{
        NSAttributedString *attributedString = [subject dateStringForDayTimeSummary:workHours];
        calendar should have_received(@selector(dateFromComponents:)).with(dateComponents);
        dateFormatter should have_received(@selector(stringFromDate:)).with(date);
        attributedString should equal(expectedAttributedString);
    });
    
});

SPEC_END
