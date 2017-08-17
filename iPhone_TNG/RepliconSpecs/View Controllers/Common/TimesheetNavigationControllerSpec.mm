#import <Cedar/Cedar.h>
#import <repliconkit/ReachabilityMonitor.h>
#import "OfflineBanner.h"
#import "Theme.h"
#import "TimerProvider.h"
#import "TimesheetNavigationController.h"
#import "UserPermissionsStorage.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetNavigationControllerSpec)

describe(@"TimesheetNavigationController", ^{
    __block TimesheetNavigationController *subject;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block TimerProvider<CedarDouble> *timerProvider;
    __block id <Theme>theme;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block id<BSBinder, BSInjector> injector;

    
    beforeEach(^{
        UIViewController *rootViewController = [[UIViewController alloc] init];
        reachabilityMonitor = [[ReachabilityMonitor alloc]init];
        spy_on(reachabilityMonitor);
        theme  = nice_fake_for(@protocol(Theme));
        timerProvider = nice_fake_for([TimerProvider class]);
        
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[userPermissionsStorage class] toInstance:userPermissionsStorage];

        subject = [[TimesheetNavigationController alloc] initWithRootViewController:rootViewController
                                                             userPermissionsStorage:userPermissionsStorage
                                                                reachabilityMonitor:reachabilityMonitor
                                                                      timerProvider:timerProvider
                                                                              theme:theme];
    });
    
    itShouldBehaveLike(@"ReachabilityMonitorObserver", ^(NSMutableDictionary *sharedContext) {
        sharedContext[@"subject"] = subject;
        sharedContext[@"theme"] = theme;
        sharedContext[@"reachabilityMonitor"] = reachabilityMonitor;
    });
    
    describe(@"presenting instructions for offline mode after a delay", ^{
        beforeEach(^{
            userPermissionsStorage stub_method(@selector(isSimpleInOutWidget)).and_return(YES);
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
                    subject.offlineBanner.label.text should equal(@"You can enter time & submit timesheets while offline.");
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
                                subject.offlineBanner.label.text should equal(@"You can enter time & submit timesheets while offline.");
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
});

SPEC_END
