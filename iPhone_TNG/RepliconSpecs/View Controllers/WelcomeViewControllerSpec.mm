#import <Cedar/Cedar.h>
#import "WelcomeViewController.h"
#import "Theme.h"
#import "WelcomeFlowControllerProvider.h"
#import "WelcomeContentViewController.h"
#import <Blindside/Blindside.h>
#import "AppDelegate.h"
#import "UIControl+Spec.h"
#import "Constants.h"
#import "WelcomeContentViewController.h"
#import "FrameworkImport.h"
#import "InjectorProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WelcomeViewControllerSpec)

describe(@"WelcomeViewController", ^{
    __block WelcomeViewController *subject;
    __block id <Theme> theme;
    __block WelcomeFlowControllerProvider *welcomeFlowControllerProvider;
    __block UIPageViewController *pageViewController;
    __block AppDelegate *appDelegate;
    __block GATracker *tracker;
    
    beforeEach(^{
        WelcomeContentViewController*welcomeContentViewController = nice_fake_for([WelcomeContentViewController class]);
        
        
        welcomeFlowControllerProvider = nice_fake_for([WelcomeFlowControllerProvider class]);
        pageViewController = nice_fake_for([UIPageViewController class]);
        
        welcomeFlowControllerProvider stub_method(@selector(providePageViewControllerInstance)).and_return(pageViewController);
        
        [pageViewController setViewControllers:@[welcomeContentViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
        appDelegate = nice_fake_for([AppDelegate class]);
        appDelegate stub_method(@selector(injector)).and_return([InjectorProvider injector]);
        tracker = nice_fake_for([GATracker class]);
        
        subject = [[WelcomeViewController alloc] initWithAppDelegate:appDelegate tracker:tracker];
        
        theme = subject.theme;
        pageViewController = subject.pageViewController;
        
        spy_on(theme);
        spy_on(subject);
        spy_on(welcomeFlowControllerProvider);
        
        theme stub_method(@selector(signInButtonTitleColor)).and_return([UIColor greenColor]);
        theme stub_method(@selector(SignInButtonTitleLabelFont)).and_return([UIFont systemFontOfSize:12.0f]);
    });
    
    describe(@"styling", ^{
        beforeEach(^{
            theme stub_method(@selector(welcomeViewBGColor)).and_return([UIColor whiteColor]);
            subject.view should_not be_nil;
        });
        
        it(@"should style the background", ^{
            subject.view.backgroundColor should equal([UIColor whiteColor]);
            subject.pageControl.currentPage should equal(0);
        });
        
        it(@"should display the button title", ^{
            subject.signInButton.titleLabel.text should equal(RPLocalizedString(LOGIN_TEXT, LOGIN_TEXT));
        });
        
        it(@"should style the signin button", ^{
            subject.signInButton.titleLabel.textColor should equal([UIColor greenColor]);
            subject.signInButton.titleLabel.font should equal([UIFont systemFontOfSize:12.0f]);
        });
    });

    
    describe(@"sign in button action", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject.signInButton tap];
        });
        
        it(@"should launch login view", ^{
            appDelegate should have_received(@selector(launchLoginViewController:));
        });
    });

    describe(@"as a <UIPageViewControllerDelegate>", ^{
        
        describe(@"previousViewControllers", ^{
            __block WelcomeContentViewController*welcomeContentViewController;
            beforeEach(^{
                welcomeContentViewController = nice_fake_for([WelcomeContentViewController class]);
                [subject pageViewController:pageViewController didFinishAnimating:YES previousViewControllers:@[welcomeContentViewController] transitionCompleted:YES];
            });
            
            it(@"should stop video for previous view", ^{
                welcomeContentViewController should have_received(@selector(stopVideo));
            });

            it(@"should have send event to GA", ^{
                subject should have_received(@selector(trackGAScreenEventsForIndex:));
            });
        });
    });
    
    describe(@"as a <WelcomeContentViewControllerDelegate>", ^{
        describe(@"auto adavnce", ^{
            __block WelcomeContentViewController *welcomeContentViewController;
            
            beforeEach(^{
                welcomeContentViewController = nice_fake_for([WelcomeContentViewController class]);
                subject stub_method(@selector(viewControllerAtIndex:)).with(1).and_return(welcomeContentViewController);
                [subject welcomeContentVideoDidFinished:welcomeContentViewController];
            });
            
            it(@"should play video for next view", ^{
                welcomeContentViewController should have_received(@selector(playVideo));
            });

            it(@"should have send event to GA", ^{
                subject should have_received(@selector(trackGAScreenEventsForIndex:));
            });
        });
        
    });

    describe(@"trackGAScreenEventsForIndex:", ^{

        context(@"slide 1", ^{
            beforeEach(^{
                [subject trackGAScreenEventsForIndex:0];
            });
            it(@"should have received correct GA event", ^{
                subject.tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"demoslide1_time_capture_for_attendance",TrackerProduct);
            });
        });
        context(@"slide 2", ^{
            beforeEach(^{
                [subject trackGAScreenEventsForIndex:1];
            });
            it(@"should have received correct GA event", ^{
                subject.tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"demoslide2_approvals_for_time_and_attendance",TrackerProduct);
            });
        });
        context(@"slide 3", ^{
            beforeEach(^{
                [subject trackGAScreenEventsForIndex:2];
            });
            it(@"should have received correct GA event", ^{
                subject.tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"demoslide3_time_capture_for_client_billing",TrackerProduct);
            });
        });
        context(@"slide 4", ^{
            beforeEach(^{
                [subject trackGAScreenEventsForIndex:3];
            });
            it(@"should have received correct GA event", ^{
                subject.tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"demoslide4_approvals_for_client_billing",TrackerProduct);
            });
        });
    });
});

SPEC_END
