#import <Cedar/Cedar.h>
#import "ApprovalStatusPresenter.h"
#import "Theme.h"
#import "Constants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ApprovalStatusPresenterSpec)

describe(@"ApprovalStatusPresenter", ^{
    __block ApprovalStatusPresenter *subject;
    __block id<Theme> theme;

    beforeEach(^{
        theme = fake_for(@protocol(Theme));

        subject = [[ApprovalStatusPresenter alloc] initWithTheme:theme];
    });

    describe(NSStringFromSelector(@selector(colorForStatus:)), ^{
        __block UIColor *notSubmittedColor;
        __block UIColor *waitingForApprovalColor;
        __block UIColor *rejectedColor;
        __block UIColor *timesheetNotApprovedColor;
        __block UIColor *defaultColor;

        beforeEach(^{
            notSubmittedColor = [UIColor magentaColor];
            waitingForApprovalColor = [UIColor yellowColor];
            rejectedColor = [UIColor redColor];
            timesheetNotApprovedColor = [UIColor orangeColor];
            defaultColor = [UIColor brownColor];

            theme stub_method(@selector(approvalStatusNotSubmittedColor)).and_return(notSubmittedColor);
            theme stub_method(@selector(approvalStatusWaitingForApprovalColor)).and_return(waitingForApprovalColor);
            theme stub_method(@selector(approvalStatusRejectedColor)).and_return(rejectedColor);
            theme stub_method(@selector(approvalStatusTimesheetNotApprovedColor)).and_return(timesheetNotApprovedColor);
            theme stub_method(@selector(approvalStatusDefaultColor)).and_return(defaultColor);
        });

        it(@"should return the correct color when called with a not submitted status", ^{
            [subject colorForStatus:NOT_SUBMITTED_STATUS] should be_same_instance_as(notSubmittedColor);
        });

        it(@"should return the correct color when called with a waiting for approval status", ^{
            [subject colorForStatus:WAITING_FOR_APRROVAL_STATUS] should be_same_instance_as(waitingForApprovalColor);
        });

        it(@"should return the correct color when called with a rejected approval status", ^{
            [subject colorForStatus:REJECTED_STATUS] should be_same_instance_as(rejectedColor);
        });

        it(@"should return the correct color when called with a timesheet pending submission status", ^{
            [subject colorForStatus:TIMESHEET_PENDING_SUBMISSION] should be_same_instance_as(timesheetNotApprovedColor);
        });

        it(@"should return the correct color when called with a timesheet submitted status", ^{
            [subject colorForStatus:TIMESHEET_SUBMITTED] should be_same_instance_as(timesheetNotApprovedColor);
        });

        it(@"should return the correct color when called with a timesheet conflicted status", ^{
            [subject colorForStatus:TIMESHEET_CONFLICTED] should be_same_instance_as(timesheetNotApprovedColor);
        });

        it(@"should return the correct color for all other strings", ^{
            // NB: given the color used, this is likely the 'approved' status,
            // but we're not sure if there's other edge cases that it covers - hence continuing to
            // implement the 'else' logic from the original code.

            NSString *randomString = [[NSProcessInfo processInfo] globallyUniqueString];
            [subject colorForStatus:randomString] should be_same_instance_as(defaultColor);
        });
    });
});

SPEC_END
