#import <MacTypes.h>
#import <Cedar/Cedar.h>
#import "PunchOutController.h"
#import "AddressControllerProvider.h"
#import "UserPermissionsStorage.h"
#import "LastPunchLabelTextPresenter.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchOutControllerRegressionSpec)

describe(@"PunchOutControllerRegression", ^{
    __block PunchOutController *subject;
    __block UserPermissionsStorage *punchRulesStorage;


    beforeEach(^{
        punchRulesStorage = nice_fake_for([UserPermissionsStorage class]);
        subject = [[PunchOutController alloc] initWithTimesheetButtonControllerPresenter:nil
                                                             lastPunchLabelTextPresenter:nil
                                                        dayTimeSummaryControllerProvider:nil
                                                                 durationStringPresenter:nil
                                                                   childControllerHelper:nil
                                                                     breakTypeRepository:nil
                                                                      durationCalculator:nil
                                                                     violationRepository:nil
                                                                       punchRulesStorage:punchRulesStorage
                                                                        workHoursStorage:NULL
                                                                           buttonStylist:nil
                                                                           timerProvider:nil
                                                                            dateProvider:nil
                                                                             userSession:nil
                                                                                defaults:nil
                                                                                   theme:nil];
    });

    describe(@"showing the punchInTimeLabel", ^{
        context(@"when the user is required to take breaks and not required to log their address while punching out", ^{
            beforeEach(^{
                punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);
            });
            beforeEach(^{
                [subject view];
                [subject.addressLabelContainer removeFromSuperview];
            });

            it(@"should not hide the punchInTimeLabel behind the take a break button", ^{
                subject.breakButtonToPunchInLabelVerticalConstraint.priority should equal(subject.clockOutButtonToPunchInLabelVerticalConstraint.priority);
            });
        });
    });
});

SPEC_END
