#import <Cedar/Cedar.h>
#import "DayTimeSummaryCellPresenter.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "DayTimeSummary.h"
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(DayTimeSummaryCellPresenterSpec)

describe(@"DayTimeSummaryCellPresenter", ^{
    __block DayTimeSummaryCellPresenter *subject;
    __block id<BSInjector, BSBinder> injector;
    __block DayTimeSummary *dayTimeSummary;
    __block NSCalendar *calendar;
    __block NSDate *expectedDate;
    __block NSDateFormatter *dayFormatter;

    beforeEach(^{
        injector = [InjectorProvider injector];
        
        dayFormatter = [injector getInstance:InjectorKeyDayMonthInLocalTimeZoneFormatterWithComma];
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.day = 1;
        dateComponents.month = 2;
        dateComponents.year = 2015;

        NSDateComponents *regularTimeComponents = [[NSDateComponents alloc] init];
        regularTimeComponents.hour = 1;
        regularTimeComponents.minute = 2;

        NSDateComponents *breakTimeComponents = [[NSDateComponents alloc] init];
        breakTimeComponents.hour = 3;
        breakTimeComponents.minute = 4;
        
        NSDateComponents *timeOffTimeComponents = [[NSDateComponents alloc] init];
        timeOffTimeComponents.hour = 6;
        timeOffTimeComponents.minute = 55;

        expectedDate = [NSDate dateWithDateComponents:dateComponents];

        calendar = nice_fake_for([NSCalendar class]);
        calendar stub_method(@selector(dateFromComponents:)).and_return(expectedDate);
        [injector bind:InjectorKeyCalendarWithLocalTimeZone toInstance:calendar];
        
        subject = [injector getInstance:[DayTimeSummaryCellPresenter class]];
        
        dayTimeSummary = [[DayTimeSummary alloc] initWithRegularTimeOffsetComponents:nil
                                                           breakTimeOffsetComponents:nil
                                                               regularTimeComponents:regularTimeComponents
                                                                 breakTimeComponents:breakTimeComponents
                                                                   timeOffComponents:timeOffTimeComponents
                                                                      dateComponents:dateComponents
                                                                      isScheduledDay:YES];
    });

    describe(@"dateStringForDayTimeSummary:", ^{
        it(@"should return a properly formatted date string", ^{
            NSAttributedString *formattedString = [subject dateStringForDayTimeSummary:dayTimeSummary];
            NSDate *date = [calendar dateFromComponents:dayTimeSummary.dateComponents];
            NSString *dateString = [dayFormatter stringFromDate:date];
            [formattedString string] should equal(dateString);
        });
    });

    describe(@"regularTimeStringForDayTimeSummary:", ^{
        it(@"should return a properly formatted time string", ^{
            NSAttributedString *formattedString = [subject regularTimeStringForDayTimeSummary:dayTimeSummary];
            NSString *workStr = [NSString stringWithFormat:@"1h:2m"];
            [formattedString string] should equal(workStr);
        });
    });

    describe(@"breakTimeStringForDayTimeSummary:", ^{
        it(@"should return a properly formatted time string", ^{
            NSAttributedString *formattedString = [subject breakTimeStringForDayTimeSummary:dayTimeSummary];
            NSString *breakStr = [NSString stringWithFormat:@"%@: 3h:4m",RPLocalizedString(@"Break", @"")];
            [formattedString string] should equal(breakStr);
        });
    });
    
    describe(@"timeOffTimeStringForDayTimeSummary:", ^{
        it(@"should return a properly formatted time string", ^{
            NSAttributedString *formattedString = [subject timeOffTimeStringForDayTimeSummary:dayTimeSummary];
            NSString *timeoffStr = [NSString stringWithFormat:@"%@: 6h:55m",RPLocalizedString(@"TimeOff", @"")];
            [formattedString string] should equal(timeoffStr);
        });
    });

    describe(@"dateForDayTimeSummary:", ^{
        it(@"should return a date for a given time summary", ^{
            NSDate *date = [subject dateForDayTimeSummary:dayTimeSummary];

            expectedDate should be_same_instance_as(date);
        });
    });
});

SPEC_END
