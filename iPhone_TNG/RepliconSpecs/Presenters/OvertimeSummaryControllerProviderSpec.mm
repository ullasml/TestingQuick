#import <Cedar/Cedar.h>
#import "OvertimeSummaryControllerProvider.h"
#import <KSDeferred/KSPromise.h>
#import "OvertimeSummaryController.h"
#import "OvertimeSummaryTablePresenter.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(OvertimeSummaryControllerProviderSpec)

describe(@"OvertimeSummaryControllerProvider", ^{
    __block OvertimeSummaryControllerProvider *subject;
    __block OvertimeSummaryTablePresenter *overtimeSummaryTablePresenter;

    beforeEach(^{
        overtimeSummaryTablePresenter = nice_fake_for([OvertimeSummaryTablePresenter class]);
        subject = [[OvertimeSummaryControllerProvider alloc] initWithOvertimeSummaryTablePresenter:overtimeSummaryTablePresenter];
    });

    describe(NSStringFromSelector(@selector(provideInstanceWithOvertimeSummaryPromise:)), ^{
        it(@"should return a correctly configured controller", ^{
            KSPromise *promise = nice_fake_for([KSPromise class]);
            OvertimeSummaryController *controller = [subject provideInstanceWithOvertimeSummaryPromise:promise];
            controller should be_instance_of([OvertimeSummaryController class]);
            controller.supervisorDashboardSummaryPromise should be_same_instance_as(promise);
            controller.overtimeSummaryTablePresenter should be_same_instance_as(overtimeSummaryTablePresenter);
        });
    });
});




SPEC_END
