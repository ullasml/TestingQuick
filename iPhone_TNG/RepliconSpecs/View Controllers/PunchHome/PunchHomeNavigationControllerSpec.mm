#import <Cedar/Cedar.h>
#import "PunchHomeNavigationController.h"
#import "PunchHomeController.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "OfflineBanner.h"
#import "Theme.h"
#import "TimerProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchHomeNavigationControllerSpec)

describe(@"PunchHomeNavigationController", ^{
    __block PunchHomeNavigationController  *subject;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block TimerProvider<CedarDouble> *timerProvider;
    __block id <Theme>theme;

    beforeEach(^{
        UIViewController *rootViewController = [[UIViewController alloc] init];
        reachabilityMonitor = [[ReachabilityMonitor alloc]init];
        spy_on(reachabilityMonitor);
        theme  = nice_fake_for(@protocol(Theme));
        timerProvider = nice_fake_for([TimerProvider class]);
        subject = [[PunchHomeNavigationController alloc] initWithRootViewController:rootViewController
                                                                reachabilityMonitor:reachabilityMonitor
                                                                      timerProvider:timerProvider
                                                                              theme:theme];
        spy_on(subject);
    });

    itShouldBehaveLike(@"ReachabilityMonitorObserver", ^(NSMutableDictionary *sharedContext) {
        sharedContext[@"subject"] = subject;
        sharedContext[@"theme"] = theme;
        sharedContext[@"reachabilityMonitor"] = reachabilityMonitor;
    });

    describe(@"presenting instructions for offline mode after a delay", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject viewWillAppear:YES];
        });

        context(@"when notified that the network is offline", ^{
            __block NSTimer *timer;
            beforeEach(^{
                timer = nice_fake_for([NSTimer class]);
                timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:))
                    .and_return(timer);

                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
                [subject networkReachabilityChanged];
            });

            it(@"should start the timer", ^{
                timerProvider should have_received(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:))
                    .with((NSTimeInterval)10, subject, @selector(showOfflineInstructions), nil, NO);
            });

            it(@"should display the original offline message", ^{
                subject.offlineBanner.label.text should equal(RPLocalizedString(@"No Internet Connection.",@""));
            });

            context(@"when 10 seconds has elapsed", ^{
                beforeEach(^{
                    [subject showOfflineInstructions];
                });

                it(@"should invalidate the current timer", ^{
                    timer should have_received(@selector(invalidate));
                });


                it(@"should display the correct instructions", ^{
                    subject.offlineBanner.label.text should equal(@"You can still clock in and out while offline.");
                });
                
                context(@"when notified that the network is back online", ^{
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                        [subject networkReachabilityChanged];
                    });

                    it(@"should invalidate the current timer", ^{
                        timer should have_received(@selector(invalidate));
                    });

                    context(@"when the network goes offline again", ^{
                        __block NSTimer *secondTimer;
                        beforeEach(^{
                            secondTimer = nice_fake_for([NSTimer class]);
                            [timerProvider reset_sent_messages];
                            timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:))
                                .again()
                                .and_return(secondTimer);

                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                            [subject networkReachabilityChanged];
                        });

                        it(@"should start the new timer", ^{
                            timerProvider should have_received(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:))
                                .with((NSTimeInterval)10, subject, @selector(showOfflineInstructions), nil, NO);
                        });

                        it(@"should display the original offline message again", ^{
                            subject.offlineBanner.label.text should equal(RPLocalizedString(@"No Internet Connection.",@""));
                        });

                        context(@"when 10 seconds have elapsed", ^{
                            beforeEach(^{
                                [subject showOfflineInstructions];
                            });

                            it(@"should invalidate the new timer", ^{
                                secondTimer should have_received(@selector(invalidate));
                            });

                            it(@"should display the correct offline instructions", ^{
                                subject.offlineBanner.label.text should equal(@"You can still clock in and out while offline.");
                            });
                        });
                    });
                });
            });
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

    describe(@"fetchAndDisplayChildControllerForMostRecentPunch", ^{
        context(@"when the root view controller is a punch home controller", ^{
            __block PunchHomeController *punchHomeController;

            beforeEach(^{
                punchHomeController = [[PunchHomeController alloc] initWithPunchImagePickerControllerProvider:nil punchControllerProvider:nil allowAccessAlertHelper:nil imageNormalizer:nil punchRepository:nil oefTypeStorage:nil userSession:nil punchClock:nil timeLinePunchesStorage:nil];

                spy_on(punchHomeController);
                subject = [[PunchHomeNavigationController alloc] initWithRootViewController:punchHomeController
                                                                        reachabilityMonitor:nil
                                                                              timerProvider:nil
                                                                                      theme:nil];
                [subject fetchAndDisplayChildControllerForMostRecentPunch];
            });

            it(@"should call fetchAndDisplayChildControllerForMostRecentPunch on its rootmost view controller", ^{
                punchHomeController should have_received(@selector(fetchAndDisplayChildControllerForMostRecentPunch));
            });
        });

        context(@"when the root view controller is not a punch home controller", ^{
            __block UIViewController *otherController;

            beforeEach(^{
                otherController = [[UIViewController alloc] init];
                subject = [[PunchHomeNavigationController alloc] initWithRootViewController:otherController
                                                                        reachabilityMonitor:nil
                                                                              timerProvider:nil
                                                                                      theme:nil];
            });

            it(@"should call fetchAndDisplayChildControllerForMostRecentPunch on its rootmost view controller", ^{
                ^{ [subject fetchAndDisplayChildControllerForMostRecentPunch]; } should_not raise_exception;
            });
        });
    });
});

SPEC_END
