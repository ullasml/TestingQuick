#import <Cedar/Cedar.h>
#import "ApprovalsPendingTimeOffTableViewHeader.h"
#import "Constants.h"
#import "UIControl+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ApprovalsPendingTimeOffTableViewHeaderSpec)

describe(@"ApprovalsPendingTimeOffTableViewHeader", ^{
    __block ApprovalsPendingTimeOffTableViewHeader *subject;
    __block id <ApprovalsPendingTimeOffTableViewHeaderDelegate> delegate;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(ApprovalsPendingTimeOffTableViewHeaderDelegate));

        subject = [[ApprovalsPendingTimeOffTableViewHeader alloc]initWithFrame:CGRectZero];
        subject.delegate = delegate;
    });

    it(@"should display correct titles for the button", ^{
        subject.rejectButton.titleLabel.text should equal(RPLocalizedString(REJECT_TEXT, REJECT_TEXT));
        subject.approveButton.titleLabel.text should equal(RPLocalizedString(APPROVE_TEXT, APPROVE_TEXT));
        subject.toggleButton.titleLabel.text should equal(RPLocalizedString(@"Select All", @"Select All"));
    });

    it(@"should inform its delegate that reject button was clicked", ^{
        [subject.rejectButton tap];
        subject.delegate should have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToReject:)).with(subject);
        subject.delegate should_not have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToApprove:)).with(subject);
        subject.delegate should_not have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:)).with(subject);
        subject.delegate should_not have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToClearAll:)).with(subject);
    });

    it(@"should inform its delegate that approve button was clicked", ^{
        [subject.approveButton tap];
        subject.delegate should have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToApprove:)).with(subject);
        subject.delegate should_not have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToReject:)).with(subject);
        subject.delegate should_not have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:)).with(subject);
        subject.delegate should_not have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToClearAll:)).with(subject);
    });

    it(@"should inform its delegate that check all button was clicked", ^{
        subject.toggleButton.tag = CHECK_ALL_BUTTON_TAG;
        [subject.toggleButton tap];

        subject.delegate should have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:)).with(subject);
        subject.delegate should_not have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToApprove:)).with(subject);
        subject.delegate should_not have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToReject:)).with(subject);
        subject.delegate should_not have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToClearAll:)).with(subject);
    });

    it(@"should inform its delegate that clear all button was clicked", ^{
        subject.toggleButton.tag = CLEAR_ALL_BUTTON_TAG;
        [subject.toggleButton tap];

        subject.delegate should_not have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:)).with(subject);
        subject.delegate should_not have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToApprove:)).with(subject);
        subject.delegate should_not have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToReject:)).with(subject);
        subject.delegate should have_received(@selector(approvalsPendingTimeOffTableViewHeaderDidSignalIntentToClearAll:)).with(subject);
    });
});

SPEC_END
