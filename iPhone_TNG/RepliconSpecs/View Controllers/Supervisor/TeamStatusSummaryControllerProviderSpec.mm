#import <Cedar/Cedar.h>
#import "TeamStatusSummaryControllerProvider.h"
#import <KSDeferred/KSPromise.h>
#import "TeamStatusSummaryController.h"
#import "TeamStatusTablePresenter.h"
#import "TeamTableStylist.h"
#import "ErrorBannerViewParentPresenterHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TeamStatusSummaryControllerProviderSpec)

describe(@"TeamStatusSummaryControllerProvider", ^{
    __block TeamStatusSummaryControllerProvider *subject;
    __block TeamStatusTablePresenter *teamStatusSummaryCellPresenter;
    __block TeamTableStylist *teamTableStylist;
    __block ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;
    
    beforeEach(^{
        teamStatusSummaryCellPresenter = nice_fake_for([TeamStatusTablePresenter class]);
        teamTableStylist = nice_fake_for([TeamTableStylist class]);
        errorBannerViewParentPresenterHelper = nice_fake_for([ErrorBannerViewParentPresenterHelper class]);
        subject = [[TeamStatusSummaryControllerProvider alloc] initWithErrorBannerViewParentPresenterHelper:errorBannerViewParentPresenterHelper
                                                                             teamStatusSummaryCellPresenter:teamStatusSummaryCellPresenter
                                                                                           teamTableStylist:teamTableStylist];
    });

    describe(NSStringFromSelector(@selector(provideInstanceWithTeamStatusSummaryPromise:initiallyDisplayedSection:)), ^{
        it(@"should return a correctly configured controller", ^{
            KSPromise *promise = nice_fake_for([KSPromise class]);
            TeamStatusSummaryController *controller = [subject provideInstanceWithTeamStatusSummaryPromise:promise initiallyDisplayedSection:TeamStatusTableSectionClockedIn];

            controller should be_instance_of([TeamStatusSummaryController class]);
            controller.teamTableStylist should be_same_instance_as(teamTableStylist);
            controller.teamStatusSummaryPromise should be_same_instance_as(promise);
            controller.teamStatusTablePresenter should be_same_instance_as(teamStatusSummaryCellPresenter);
            controller.initiallyDisplayedSection should equal(TeamStatusTableSectionClockedIn);
            controller.errorBannerViewParentPresenterHelper should be_same_instance_as(errorBannerViewParentPresenterHelper);
        });
    });
});

SPEC_END
