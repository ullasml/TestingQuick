#import <Cedar/Cedar.h>
#import "TimesheetForDateRange.h"
#import "TimesheetPeriod.h"
#import "TimeSheetApprovalStatus.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetSpec)

describe(@"Timesheet", ^{
    describe(NSStringFromSelector(@selector(isEqual:)), ^{
        it(@"should not be equal when comparing a different type of object", ^{
            TimesheetForDateRange *TimesheetA = [[TimesheetForDateRange alloc] initWithUri:nil period:nil approvalStatus:nil];

            TimesheetA should_not equal((TimesheetForDateRange *)[NSDate date]);
        });

        it(@"should not be equal when the userURI are not equal", ^{
            NSString *userURI_A = @"user-URI-A";
            NSString *userURI_B = @"user-URI-B";

            TimesheetForDateRange *TimesheetA = [[TimesheetForDateRange alloc] initWithUri:userURI_A period:nil approvalStatus:nil];
            TimesheetForDateRange *TimesheetB = [[TimesheetForDateRange alloc] initWithUri:userURI_B period:nil approvalStatus:nil];

            TimesheetA should_not equal(TimesheetB);
        });

        it(@"should not be equal when the start date components are not equal", ^{
            TimesheetPeriod *periodA = [[TimesheetPeriod alloc] initWithStartDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0] endDate:nil];
            TimesheetPeriod *periodB = [[TimesheetPeriod alloc] initWithStartDate:[NSDate dateWithTimeIntervalSinceReferenceDate:1] endDate:nil];

            TimesheetForDateRange *TimesheetA = [[TimesheetForDateRange alloc] initWithUri:nil period:periodA approvalStatus:nil];
            TimesheetForDateRange *TimesheetB = [[TimesheetForDateRange alloc] initWithUri:nil period:periodB approvalStatus:nil];
            TimesheetA should_not equal(TimesheetB);
        });

        it(@"should not be equal when the end date components are not equal", ^{
            TimesheetPeriod *periodA = [[TimesheetPeriod alloc] initWithStartDate:nil endDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
            TimesheetPeriod *periodB = [[TimesheetPeriod alloc] initWithStartDate:nil endDate:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];

            TimesheetForDateRange *TimesheetA = [[TimesheetForDateRange alloc] initWithUri:nil period:periodA approvalStatus:nil];
            TimesheetForDateRange *TimesheetB = [[TimesheetForDateRange alloc] initWithUri:nil period:periodB approvalStatus:nil];

            TimesheetA should_not equal(TimesheetB);
        });

        it(@"should not be equal when approval status are not equal", ^{
            TimesheetPeriod *periodA = [[TimesheetPeriod alloc] initWithStartDate:nil endDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
            TimesheetPeriod *periodB = [[TimesheetPeriod alloc] initWithStartDate:nil endDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];

            TimeSheetApprovalStatus *approvalStatusA = [[TimeSheetApprovalStatus alloc] initWithApprovalStatusUri:@"approval-status-uri-a" approvalStatus:@"approval-status-a"];
            TimeSheetApprovalStatus *approvalStatusB = [[TimeSheetApprovalStatus alloc] initWithApprovalStatusUri:@"approval-status-uri-b" approvalStatus:@"approval-status-b"];

            TimesheetForDateRange *TimesheetA = [[TimesheetForDateRange alloc] initWithUri:nil period:periodA approvalStatus:approvalStatusA];
            TimesheetForDateRange *TimesheetB = [[TimesheetForDateRange alloc] initWithUri:nil period:periodB approvalStatus:approvalStatusB];

            TimesheetA should_not equal(TimesheetB);
        });

        it(@"should be equal when all of the members are nil", ^{
            TimesheetForDateRange *TimesheetA = [[TimesheetForDateRange alloc] initWithUri:nil period:nil approvalStatus:nil];
            TimesheetForDateRange *TimesheetB = [[TimesheetForDateRange alloc] initWithUri:nil period:nil approvalStatus:nil];

            TimesheetA should equal(TimesheetB);
        });

        it(@"should be equal when all of the members are equal", ^{
            NSString *userURI = @"USER URI";

            TimesheetPeriod *period = [[TimesheetPeriod alloc] initWithStartDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                         endDate:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];

            TimeSheetApprovalStatus *approvalStatus = [[TimeSheetApprovalStatus alloc] initWithApprovalStatusUri:@"approval-status-uri" approvalStatus:@"approval-status"];

            TimesheetForDateRange *TimesheetA = [[TimesheetForDateRange alloc] initWithUri:userURI period:period approvalStatus:approvalStatus];
            TimesheetForDateRange *TimesheetB = [[TimesheetForDateRange alloc] initWithUri:userURI period:period approvalStatus:approvalStatus];

            TimesheetA should equal(TimesheetB);
        });
    });
});

SPEC_END
