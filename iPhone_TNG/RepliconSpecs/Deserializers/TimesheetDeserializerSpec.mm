#import <Cedar/Cedar.h>
#import "TimesheetDeserializer.h"
#import "TimesheetForDateRange.h"
#import "RepliconSpecHelper.h"
#import "TimesheetPeriod.h"
#import "TimeSheetApprovalStatus.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimesheetDeserializerSpec)

describe(@"TimesheetDeserializer", ^{
    __block TimesheetDeserializer *subject;

    beforeEach(^{
        subject = [[TimesheetDeserializer alloc] init];
    });


    describe(NSStringFromSelector(@selector(deserialize:)), ^{

        __block NSArray *deserializedTimesheets;
        __block TimesheetForDateRange *expectedTimesheetA;
        __block TimesheetForDateRange *expectedTimesheetB;

        NSDictionary *mostRecentTimesheetDictionary = [RepliconSpecHelper jsonWithFixture:@"get_timesheet"];

        context(@"when provided a dictionary representing an array of timesheets", ^{
            beforeEach(^{
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];

                NSDateComponents *startDateComponentsA = [[NSDateComponents alloc] init];
                NSDateComponents *endDateComponentsA = [[NSDateComponents alloc] init];

                startDateComponentsA.day = 6;
                startDateComponentsA.month = 4;
                startDateComponentsA.year = 2015;

                endDateComponentsA.day = 12;
                endDateComponentsA.month = 4;
                endDateComponentsA.year = 2015;

                TimesheetPeriod *periodA = [[TimesheetPeriod alloc] initWithStartDate:[calendar dateFromComponents:startDateComponentsA]
                                                                              endDate:[calendar dateFromComponents:endDateComponentsA]];

                TimeSheetApprovalStatus *approvalStatusA = [[TimeSheetApprovalStatus alloc] initWithApprovalStatusUri:@"urn:replicon:approval-status:waiting" approvalStatus:@"Waiting for Approval"];

                expectedTimesheetA = [[TimesheetForDateRange alloc] initWithUri:@"urn:replicon-tenant:astro:timesheet:timesheet-a-uri"
                                                                         period:periodA approvalStatus:approvalStatusA];

                NSDateComponents *startDateComponentsB = [[NSDateComponents alloc] init];
                NSDateComponents *endDateComponentsB = [[NSDateComponents alloc] init];

                startDateComponentsB.day = 30;
                startDateComponentsB.month = 3;
                startDateComponentsB.year = 2015;

                endDateComponentsB.day = 5;
                endDateComponentsB.month = 4;
                endDateComponentsB.year = 2015;

                TimesheetPeriod *periodB = [[TimesheetPeriod alloc] initWithStartDate:[calendar dateFromComponents:startDateComponentsB]
                                                                              endDate:[calendar dateFromComponents:endDateComponentsB]];

                TimeSheetApprovalStatus *approvalStatusB = [[TimeSheetApprovalStatus alloc] initWithApprovalStatusUri:@"urn:replicon:approval-status:waiting" approvalStatus:@"Waiting for Approval"];

                expectedTimesheetB = [[TimesheetForDateRange alloc] initWithUri:@"urn:replicon-tenant:astro:timesheet:timesheet-b-uri"
                                                                         period:periodB approvalStatus:approvalStatusB];

                deserializedTimesheets = [subject deserialize:mostRecentTimesheetDictionary];
            });

            it(@"should deserialize 2 timesheets", ^{
                deserializedTimesheets.count should equal(2);
            });

            it(@"should set the uri property", ^{
                [deserializedTimesheets[0] uri] should equal(expectedTimesheetA.uri);
                [deserializedTimesheets[1] uri] should equal(expectedTimesheetB.uri);
            });

            it(@"should set the startDateComponents property", ^{
                [[deserializedTimesheets[0] period] startDate] should equal(expectedTimesheetA.period.startDate);
                [[deserializedTimesheets[1] period] startDate] should equal(expectedTimesheetB.period.startDate);
            });

            it(@"should set the endDateComponents property", ^{
                [[deserializedTimesheets[0] period] endDate] should equal(expectedTimesheetA.period.endDate);
                [[deserializedTimesheets[1] period] endDate] should equal(expectedTimesheetB.period.endDate);
            });

            it(@"should set the approvalStatus property", ^{
                TimeSheetApprovalStatus *approvalStatus = (TimeSheetApprovalStatus *)[deserializedTimesheets[0] approvalStatus];
                approvalStatus.approvalStatusUri should equal(expectedTimesheetA.approvalStatus.approvalStatusUri);
                approvalStatus.approvalStatus should equal(expectedTimesheetB.approvalStatus.approvalStatus);
            });
        });
    });
});

SPEC_END
