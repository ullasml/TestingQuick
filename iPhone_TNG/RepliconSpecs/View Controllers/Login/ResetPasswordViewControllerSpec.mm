#import <Cedar/Cedar.h>
#import "ResetPasswordViewController.h"
#import "SpinnerDelegate.h"
#import "Router.h"
#import "FrameworkImport.h"
#import "Theme.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ResetPasswordViewControllerSpec)

describe(@"ResetPasswordViewController", ^{
    __block ResetPasswordViewController *subject;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block id<Router> router;
    __block GATracker *tracker;
    __block id<Theme> theme;
    beforeEach(^{
        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        router = nice_fake_for(@protocol(Router));
        tracker = nice_fake_for([GATracker class]);
        theme = nice_fake_for(@protocol(Theme));
        subject = [[ResetPasswordViewController alloc] initWithSpinnerDelegate:spinnerDelegate router:router tracker:tracker theme:theme];
    });

    describe(NSStringFromProtocol(@protocol(LoginDelegate)), ^{
        describe(NSStringFromSelector(@selector(loginServiceDidFinishLoggingIn:)), ^{
            describe(@"when the login service did complete fetching the home summary", ^{
                beforeEach(^{
                    [subject loginServiceDidFinishLoggingIn:nil];
                });

                it(@"should route to the tab bar controller", ^{
                    router should have_received(@selector(launchTabBarController));
                });

                it(@"should hide the spinner", ^{
                    spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                });

                it(@"should received event for GA Tracker", ^{
                    tracker should have_received(@selector(trackUIEvent:forTracker:)).with(@"login", TrackerProduct);
                });
            });
        });
    });
    
    describe(@"left navigation bar button should have correct style", ^{
        beforeEach(^{
            theme stub_method(@selector(defaultleftBarButtonColor)).and_return([UIColor magentaColor]);
            [subject view];
        });
        
        it(@"should have correct color", ^{
            subject.navigationItem.leftBarButtonItem.tintColor should equal([UIColor magentaColor]);
        });
        
        
    });
});

SPEC_END
