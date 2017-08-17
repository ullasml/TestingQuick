#import <Cedar/Cedar.h>
#import "SupervisorDashboardNavigationController.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "OfflineBanner.h"
#import "Theme.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SupervisorDashboardNavigationControllerSpec)


describe(@"SupervisorDashboardNavigationController", ^{
    __block SupervisorDashboardNavigationController *subject;
    __block id <Theme> theme;
    __block ReachabilityMonitor *reachabilityMonitor;
    
    beforeEach(^{
        theme  = nice_fake_for(@protocol(Theme));
        UIViewController *rootViewController = [[UIViewController alloc] init];
        reachabilityMonitor = [[ReachabilityMonitor alloc]init];
        spy_on(reachabilityMonitor);
        subject = [[SupervisorDashboardNavigationController alloc] initWithRootViewController:rootViewController reachabilityMonitor:reachabilityMonitor theme:theme];
    });

    itShouldBehaveLike(@"ReachabilityMonitorObserver", ^(NSMutableDictionary *sharedContext) {
        sharedContext[@"subject"] = subject;
        sharedContext[@"theme"] = theme;
        sharedContext[@"reachabilityMonitor"] = reachabilityMonitor;
    });
    
    describe(@"presenting offline banner", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject viewWillAppear:YES];
        });
    
        context(@"when navigation bar is not hidden", ^{
            __block CGFloat offlineBannerTop;
            __block CGFloat offlineBannerHeight = 26.0f;
            
            beforeEach(^{
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
                [subject networkReachabilityChanged];
            });
            
            it(@"should set correct frame", ^{
                CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
                CGRect navBarFrame = subject.navigationBar.frame;
                offlineBannerTop = CGRectGetHeight(statusBarFrame) + CGRectGetHeight(navBarFrame) ;
                CGRect bannerFrame = CGRectMake(0.0f, offlineBannerTop, CGRectGetWidth(subject.view.bounds), offlineBannerHeight);
                subject.offlineBanner.frame should equal(bannerFrame);
            });
        });
        
        context(@"when navigation bar is hidden", ^{
            __block CGFloat offlineBannerTop;
            __block CGFloat offlineBannerHeight = 26.0f;
            
            beforeEach(^{
                [subject setNavigationBarHidden:YES];
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
                [subject networkReachabilityChanged];
            });
            
            it(@"should set correct frame", ^{
                offlineBannerTop = 0.0f;
                CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
                offlineBannerHeight += CGRectGetHeight(statusBarFrame);
                CGRect bannerFrame = CGRectMake(0.0f, offlineBannerTop, CGRectGetWidth(subject.view.bounds), offlineBannerHeight);
                subject.offlineBanner.frame should equal(bannerFrame);
            });
        });
    });

});

SPEC_END
