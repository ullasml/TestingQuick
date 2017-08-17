#import <Cedar/Cedar.h>
#import "ViolationsSummaryControllerProvider.h"
#import <KSDeferred/KSPromise.h>
#import "ViolationsSummaryController.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "ViolationSectionHeaderPresenter.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ViolationsSummaryControllerProviderSpec)

describe(@"ViolationsSummaryControllerProvider", ^{
    __block ViolationsSummaryControllerProvider *subject;
    __block id<BSInjector> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];

        subject = [injector getInstance:[ViolationsSummaryControllerProvider class]];
    });

    describe(NSStringFromSelector(@selector(provideInstanceWithViolationSectionsPromise:delegate:)), ^{
        it(@"should set up a violations summary controller with the given promise", ^{
            id<ViolationsSummaryControllerDelegate> delegate = nice_fake_for(@protocol(ViolationsSummaryControllerDelegate));
            KSPromise *promise = nice_fake_for([KSPromise class]);
            ViolationsSummaryController *controller = [subject provideInstanceWithViolationSectionsPromise:promise delegate:delegate];

            controller should be_instance_of([ViolationsSummaryController class]);
            controller.delegate should be_same_instance_as(delegate);
            controller.violationSectionHeaderPresenter should be_instance_of([ViolationSectionHeaderPresenter class]);
        });
    });
});

SPEC_END
