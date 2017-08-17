#import <Cedar/Cedar.h>
#import "TimesheetForDateRange.h"
#import "RepliconSpecHelper.h"
#import "TimesheetPeriod.h"
#import "CurrentTimesheetDeserializer.h"
#import "DateProvider.h"
#import "IndexCursor.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(CurrentTimesheetDeserializerSpec)

describe(@"CurrentTimesheetDeserializer", ^{
    __block CurrentTimesheetDeserializer *subject;
    __block DateProvider *dateProvider;
    __block IndexCursor *expectedIndexCursor;
    __block NSDictionary *mostRecentTimesheetDictionary;
    __block NSCalendar *calendar;
    __block id<BSInjector, BSBinder> injector;

    beforeEach(^{

        mostRecentTimesheetDictionary = [RepliconSpecHelper jsonWithFixture:@"get_timesheet_current"];
        dateProvider = nice_fake_for([DateProvider class]);
        injector = [InjectorProvider injector];

    });

    context(@"When IST timezone", ^{
        beforeEach(^{
            NSDateComponents* components = [[NSDateComponents alloc]init];
            components.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            [components setYear:2015];
            [components setMonth:7];
            [components setDay:19];
            [components setHour:15];
            [components setMinute:30];
            [components setSecond:0];
            NSDate *date = [NSDate dateWithDateComponents:components];
            dateProvider stub_method(@selector(date)).and_return(date);

            calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];

            [injector bind:InjectorKeyCalendarWithLocalTimeZone toInstance:calendar];
            [injector bind:[DateProvider class] toInstance:dateProvider];
            subject = [injector getInstance:[CurrentTimesheetDeserializer class]];
            
            expectedIndexCursor = [subject deserialize:mostRecentTimesheetDictionary];
        });
        it(@"should correctly deserialize the expectedIndexCursor", ^{
            expectedIndexCursor.count should equal(2);
            expectedIndexCursor.timesheets.count should equal(2);
             [expectedIndexCursor.timesheets[0] period] should_not equal(nil);
            [expectedIndexCursor.timesheets[0] approvalStatus] should_not equal(nil);
            expectedIndexCursor.position should equal(1);
        });
    });

    context(@"When PST timezone", ^{
        beforeEach(^{
            NSDateComponents* components = [[NSDateComponents alloc]init];
            components.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            [components setYear:2015];
            [components setMonth:7];
            [components setDay:19];
            [components setHour:22];
            [components setMinute:30];
            [components setSecond:0];
            NSDate *date = [NSDate dateWithDateComponents:components];
            dateProvider stub_method(@selector(date)).and_return(date);

            calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];

            [injector bind:InjectorKeyCalendarWithLocalTimeZone toInstance:calendar];
            [injector bind:[DateProvider class] toInstance:dateProvider];
            subject = [injector getInstance:[CurrentTimesheetDeserializer class]];

            expectedIndexCursor = [subject deserialize:mostRecentTimesheetDictionary];
        });
        it(@"should correctly deserialize the expectedIndexCursor", ^{
            expectedIndexCursor.count should equal(2);
            expectedIndexCursor.timesheets.count should equal(2);
            [expectedIndexCursor.timesheets[0] period] should_not equal(nil);
            [expectedIndexCursor.timesheets[0] approvalStatus] should_not equal(nil);
            expectedIndexCursor.position should equal(1);
        });
    });


});

SPEC_END
