#import <Cedar/Cedar.h>
#import "BaseNavigationController.h"
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "ErrorBannerViewController.h"
#import "AppDelegate.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(BaseNavigationControllerSpec)

describe(@"BaseNavigationController", ^{
    __block BaseNavigationController *subject;
    __block id<BSBinder, BSInjector> injector;
    __block AppDelegate *appDelegate;
    beforeEach(^{
        injector = [InjectorProvider injector];
        subject = [injector getInstance:[BaseNavigationController class]];
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        spy_on(appDelegate);
        subject.view should_not be_nil;
        [subject viewDidAppear:NO];
    });


    it(@"should call correct selector to add the error banner as subview", ^{
        subject.view.subviews.count should equal(3);

        subject.view.subviews.lastObject should be_instance_of([UIView class]);

         ErrorBannerViewController *errorBannerViewController = [injector getInstance:InjectorKeyErrorBannerViewController];

        subject.view.subviews.lastObject should be_same_instance_as(errorBannerViewController.view);

    });

    describe(@"should present error details view controller on local notification with error at the time of subsequent login", ^{

        context(@"when deep linking needs to be done", ^{
            beforeEach(^{
                appDelegate stub_method(@selector(isWaitingForDeepLinkToErrorDetails)).and_return(YES);
                [subject viewDidAppear:NO];
            });
            it(@"navigate to error details", ^{
                appDelegate should have_received(@selector(launchErrorDetailsViewController));
            });
            afterEach(^{
                appDelegate stub_method(@selector(isWaitingForDeepLinkToErrorDetails)).again().and_return(NO);
                stop_spying_on(appDelegate);
            });


        });

        context(@"when deep linking needs not be done", ^{
            beforeEach(^{
                [subject viewDidAppear:NO];
            });
            it(@"navigate to error details", ^{
                appDelegate should_not have_received(@selector(launchErrorDetailsViewController));
            });
            afterEach(^{
                stop_spying_on(appDelegate);
            });
        });
    });
});

SPEC_END
