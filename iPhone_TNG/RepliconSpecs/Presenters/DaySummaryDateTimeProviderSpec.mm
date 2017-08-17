#import <Cedar/Cedar.h>
#import "DaySummaryDateTimeProvider.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "DayTimeSummary.h"
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(DaySummaryDateTimeProviderSpec)

describe(@"DaySummaryDateTimeProvider", ^{
    __block DaySummaryDateTimeProvider *subject;
    __block id<BSInjector, BSBinder> injector;
    __block NSCalendar *calendar;
    __block NSDate *currentDate;
    __block NSDateFormatter *dayFormatter;

    beforeEach(^{
        injector = [InjectorProvider injector];
        
        dayFormatter = [injector getInstance:InjectorKeyDayMonthInLocalTimeZoneFormatterWithComma];
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.day = 1;
        dateComponents.month = 1;
        dateComponents.year = 2017;
        dateComponents.hour = 1;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        
        currentDate = [NSDate dateWithDateComponents:dateComponents];
        
        calendar = nice_fake_for([NSCalendar class]);
        calendar stub_method(@selector(dateFromComponents:)).and_return(currentDate);
        
        [injector bind:InjectorKeyCalendarWithLocalTimeZone toInstance:calendar];
        subject = [injector getInstance:[DaySummaryDateTimeProvider class]];
    });
    
    describe(@"dateWithCurrentTime:", ^{
        it(@"should return a date ", ^{
            
            NSDateComponents *selectedDateComponents = [[NSDateComponents alloc] init];
            selectedDateComponents.day = 30;
            selectedDateComponents.month = 12;
            selectedDateComponents.year = 2016;
            selectedDateComponents.hour = 1;
            selectedDateComponents.minute = 0;
            selectedDateComponents.second = 0;
            
            NSDate *selectedDate = [NSDate dateWithDateComponents:selectedDateComponents];
            
            calendar stub_method(@selector(dateByAddingComponents:toDate:options:)).and_return(selectedDate);

            NSDate *date = [subject dateWithCurrentTime:selectedDate];
            
            selectedDate should equal(date);
        });
    });

});

SPEC_END
