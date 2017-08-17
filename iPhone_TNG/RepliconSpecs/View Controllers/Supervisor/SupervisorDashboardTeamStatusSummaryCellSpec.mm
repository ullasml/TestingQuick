#import <Cedar/Cedar.h>
#import "SupervisorDashboardTeamStatusSummaryCell.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(SupervisorDashboardTeamStatusSummaryCellSpec)

describe(@"SupervisorDashboardTeamStatusSummaryCell", ^{
    __block SupervisorDashboardTeamStatusSummaryCell *subject;
    __block CGRect expectedFrame;

    beforeEach(^{
        expectedFrame = CGRectMake(0, 0, 300, 100);
        subject = [[SupervisorDashboardTeamStatusSummaryCell alloc] initWithFrame:expectedFrame];
    });

    describe(@"when the view is initialized", ^{
        it(@"should use the given frame", ^{
            subject.frame should equal(expectedFrame);
        });

        it(@"should initialize a title and value label and add them as subviews", ^{
            subject.titleLabel should be_instance_of([UILabel class]);
            subject.valueLabel should be_instance_of([UILabel class]);

            subject.contentView.subviews should contain(subject.titleLabel);
            subject.contentView.subviews should contain(subject.valueLabel);
        });
    });
});

SPEC_END
