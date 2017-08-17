#import <Cedar/Cedar.h>
#import "MinimalTimesheetDeserializer.h"
#import "Timesheet.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "TimesheetPeriod.h"
#import "TimeSheetApprovalStatus.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(MinimalTimesheetDeserializerSpec)

describe(@"MinimalTimesheetDeserializer", ^{
    __block MinimalTimesheetDeserializer *subject;
    __block id<BSInjector, BSBinder> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];
        subject = [injector getInstance:[MinimalTimesheetDeserializer class]];
    });

    describe(@"deserialize:", ^{
        __block id<Timesheet> timesheet;
        __block NSCalendar *calendar;

        beforeEach(^{
            calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            dateFormatter.locale = [NSLocale currentLocale];
            [dateFormatter setDateFormat:@"MMMM d, yyyy"];
            
            
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setDay:01];
            [comps setMonth:06];
            [comps setYear:2015];
            NSDate *startTestDate = [calendar dateFromComponents:comps];
            NSString *startDateString = [dateFormatter stringFromDate:startTestDate];
            
            [comps setDay:07];
            [comps setMonth:06];
            [comps setYear:2015];
            NSDate *endTestDate = [calendar dateFromComponents:comps];
            NSString *endDateString = [dateFormatter stringFromDate:endTestDate];
            
            //@"June 01, 2015 - June 07, 2015"
            NSDictionary *jsonDictionary = @{@"timesheetPeriod" : [NSString stringWithFormat:@"%@ - %@",startDateString,endDateString],
                                             @"timesheetUri" : @"urn:replicon-tenant:astro:timesheet:93f4de07-8bb9-4dcf-8d99-aff9ae9e69ed",
                                             @"approvalStatus" : @"Approved"};
            timesheet = [subject deserialize:jsonDictionary];
        });

        it(@"should deserialize it", ^{
            timesheet.uri should equal(@"urn:replicon-tenant:astro:timesheet:93f4de07-8bb9-4dcf-8d99-aff9ae9e69ed");
        });

        it(@"should deserialize the start date", ^{
            NSDateComponents *startDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:timesheet.period.startDate];

            startDateComponents.year should equal(2015);
            startDateComponents.month should equal(6);
            startDateComponents.day should equal(1);
        });

        it(@"should deserialize the end date", ^{
            NSDateComponents *endDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:timesheet.period.endDate];

            endDateComponents.year should equal(2015);
            endDateComponents.month should equal(6);
            endDateComponents.day should equal(7);
        });

        it(@"should deserialize the approval status", ^{
            timesheet.approvalStatus should_not be_nil;
            timesheet.approvalStatus.approvalStatusUri should equal(nil);
            timesheet.approvalStatus.approvalStatus should equal(@"Approved");
        });
    });
});

SPEC_END
