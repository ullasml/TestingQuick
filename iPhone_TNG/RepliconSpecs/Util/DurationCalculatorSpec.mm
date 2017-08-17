#import <Cedar/Cedar.h>
#import "DurationCalculator.h"
#import "DateProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(DurationCalculatorSpec)

describe(NSStringFromClass([DurationCalculator class]), ^{
    __block DurationCalculator *subject;
    __block NSCalendar *calendar;
    __block DateProvider *dateProvider;

    describe(NSStringFromSelector(@selector(timeSinceStartDate:)), ^{
        beforeEach(^{
            calendar = nice_fake_for([NSCalendar class]);
            dateProvider = nice_fake_for([DateProvider class]);

            subject = [[DurationCalculator alloc] initWithCalendar:calendar dateProvider:dateProvider];
        });

        __block NSDateComponents *durationComponents;
        __block NSDateComponents *expectedDurationComponents;
        __block NSDate *startDate;
        __block NSDate *endDate;

        beforeEach(^{
            expectedDurationComponents = nice_fake_for([NSDateComponents class]);
            calendar stub_method(@selector(components:fromDate:toDate:options:)).and_return(expectedDurationComponents);

            startDate = [NSDate dateWithTimeIntervalSince1970:0];

            endDate = [[NSDate alloc] initWithTimeIntervalSince1970:3661];
            dateProvider stub_method(@selector(date)).and_return(endDate);

            durationComponents = [subject timeSinceStartDate:startDate];
        });

        it(@"should ask the calendar ALL the right questions", ^{
            calendar should have_received(@selector(components:fromDate:toDate:options:)).with(NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond, startDate, endDate, 0);
        });

        it(@"should return a date components object representing the duration since the given start date", ^{
            durationComponents should equal(expectedDurationComponents);
        });
    });

    describe(NSStringFromSelector(@selector(sumOfTimeByAddingDateComponents:toDateComponents:)), ^{
        beforeEach(^{
            calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            dateProvider = nice_fake_for([DateProvider class]);

            subject = [[DurationCalculator alloc] initWithCalendar:calendar dateProvider:dateProvider];
        });

        it(@"should return a date components object representing the sum of the hours, minutes and seconds of the arguments", ^{
            NSDateComponents *dateComponentsA = [[NSDateComponents alloc] init];
            dateComponentsA.hour = 1;
            dateComponentsA.minute = 59;
            dateComponentsA.second = 59;

            NSDateComponents *dateComponentsB = [[NSDateComponents alloc] init];
            dateComponentsB.hour = 2;
            dateComponentsB.minute = 2;
            dateComponentsB.second = 2;

            NSDateComponents *expectedDateComponents = [[NSDateComponents alloc] init];
            expectedDateComponents.hour = 4;
            expectedDateComponents.minute = 2;
            expectedDateComponents.second = 1;

            NSDateComponents *summedComponents = [subject sumOfTimeByAddingDateComponents:dateComponentsA toDateComponents:dateComponentsB];

            summedComponents should equal(expectedDateComponents);
        });
    });
});

SPEC_END
