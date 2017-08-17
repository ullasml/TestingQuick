#import <Cedar/Cedar.h>
#import <repliconkit/ReachabilityMonitor.h>
#import "OfflineBannerPresenter.h"
#import "Theme.h"
#import "OfflineBanner.h"
#import "UIControl+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SHARED_EXAMPLE_GROUPS_BEGIN(ReachabilityMonitorObserver)

sharedExamplesFor(@"ReachabilityMonitorObserver", ^(NSDictionary *sharedContext) {
    __block ReachabilityMonitor *reachabilityMonitor;
    __block UINavigationController<ReachabilityMonitorObserver, OfflineBannerPresenter> *subject;

    beforeEach(^{
        reachabilityMonitor = sharedContext[@"reachabilityMonitor"];
        reachabilityMonitor should be_instance_of([ReachabilityMonitor class]);

        id<Theme> theme = sharedContext[@"theme"];
        theme stub_method(@selector(offlineBannerBackgroundColor)).and_return([UIColor yellowColor]);
        theme stub_method(@selector(offlineBannerTextColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(offlineBannerFont)).and_return([UIFont italicSystemFontOfSize:13.0f]);

        subject = sharedContext[@"subject"];
        subject.view should_not be_nil;
    });

    it(@"should be a ReachabilityMonitorObserver", ^{
        subject should conform_to(@protocol(ReachabilityMonitorObserver));
    });

    it(@"should be a ViewController that presents an offline banner", ^{
        subject should conform_to(@protocol(OfflineBannerPresenter));
    });

    it(@"should set itself as the reachability monitor's delegate", ^{
        reachabilityMonitor should have_received(@selector(addObserver:)).with(subject);
    });

    it(@"should show the offline banner if network's not reachable initially", ^{
        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);

        [subject viewWillAppear:NO];

        subject.offlineBanner.hidden should be_falsy;
    });

    it(@"should hide the offline banner if network's reachable initially", ^{
        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);

        [subject viewWillAppear:NO];

        subject.offlineBanner.hidden should be_truthy;
    });

    it(@"should style the offline banner correctly using the theme", ^{
        [subject viewWillAppear:NO];
        
        subject.offlineBanner.backgroundColor should equal([UIColor yellowColor]);
        subject.offlineBanner.label.textColor should equal([UIColor orangeColor]);
        subject.offlineBanner.label.font should equal([UIFont italicSystemFontOfSize:13.0f]);
    });

    it(@"should show the offline banner when network becomes unreachable", ^{
        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
        [subject networkReachabilityChanged];

        subject.offlineBanner.hidden should be_falsy;
    });

    it(@"should hide the offline banner when the user taps the close button", ^{
        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
        [subject networkReachabilityChanged];

        [subject.offlineBanner.closeButton tap];

        subject.offlineBanner.hidden should be_truthy;
    });

    it(@"should hide the offline banner when network becomes reachable", ^{
        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
        [subject networkReachabilityChanged];

        reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
        [subject networkReachabilityChanged];

        subject.offlineBanner.hidden should be_truthy;
    });



    it(@"should display the offline banner at the top of the screen when the navigation bar is hidden", ^{
        subject.navigationBarHidden = YES;

        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
        [subject networkReachabilityChanged];

        CGRectGetMinY(subject.offlineBanner.frame) should equal(0.0f);
    });

});

SHARED_EXAMPLE_GROUPS_END

