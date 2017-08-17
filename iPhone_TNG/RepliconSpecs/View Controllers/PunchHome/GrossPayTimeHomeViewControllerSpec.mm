#import <Cedar/Cedar.h>
#import "GrossPayTimeHomeViewController.h"
#import "CurrencyValue.h"
#import "GrossHours.h"
#import "GrossPayController.h"
#import "GrossHoursController.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "ChildControllerHelper.h"
#import "GrossSummary.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(GrossPayTimeHomeViewControllerSpec)

describe(@"GrossPayTimeHomeViewController", ^{
    __block GrossPayTimeHomeViewController *subject;
    __block GrossPayPagingController *grossPayPagingController;
    __block id<Theme> theme;
    __block CurrencyValue *grossPay;
    __block GrossHours *grossHours;
    __block GrossPayController *grossPayController;
    __block GrossHoursController *grossHoursController;
    __block ChildControllerHelper *childControllerHelper;
    __block id <BSBinder,BSInjector> injector;
    __block id<GrossPayTimeHomeControllerDelegate> delegate;
    __block id <GrossSummary>grossSummary;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        
        grossPay = fake_for([CurrencyValue class]);
        grossHours = fake_for([GrossHours class]);
        theme = fake_for(@protocol(Theme));
        grossPayController = nice_fake_for([GrossPayController class]);
        grossHoursController = nice_fake_for([GrossHoursController class]);
        grossPayPagingController = nice_fake_for([GrossPayPagingController class]);
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);

        delegate = nice_fake_for(@protocol(GrossPayTimeHomeControllerDelegate));
        
        grossSummary = nice_fake_for(@protocol(GrossSummary));
        grossSummary stub_method(@selector(totalPay)).and_return(grossPay);
        grossSummary stub_method(@selector(totalHours)).and_return(grossHours);
        grossSummary stub_method(@selector(actualsByPayCode)).and_return(@[@"some-random-pay-code-value"]);
        grossSummary stub_method(@selector(actualsByPayDuration)).and_return(@[@"some-random-pay-duration-value"]);
        grossSummary stub_method(@selector(scriptCalculationDate)).and_return(@"Data as of x date");
        
        [injector bind:@protocol(Theme) toInstance:theme];
        [injector bind:[GrossPayController class] toInstance:grossPayController];
        [injector bind:[GrossHoursController class] toInstance:grossHoursController];
        [injector bind:[GrossPayPagingController class] toInstance:grossPayPagingController];
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        
        subject = [injector getInstance:[GrossPayTimeHomeViewController class]];
        [subject setupWithGrossSummary:grossSummary delegate:delegate];;


    });
    
    afterEach(^{
        stop_spying_on(grossPayController);
    });
    
    describe(@"should configure child controllers", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        
        it(@"grossHoursController correctly", ^{
            grossHoursController should have_received(@selector(setupWithGrossHours:grossHoursHeaderText:actualsPayCode:delegate:scriptCalculationDate:)).with(grossHours,RPLocalizedString(@"Total Time", @"Total Time"),@[@"some-random-pay-duration-value"],subject,@"Data as of x date");
        });
        
        it(@"grossPayController correctly", ^{
            grossPayController should have_received(@selector(setupWithGrossPay:grossPayHeaderText:actualsPayCode:delegate:scriptCalculationDate:)).with(grossPay,RPLocalizedString(@"Gross Pay", @"Gross Pay"),@[@"some-random-pay-code-value"],subject,@"Data as of x date");
        });
    });
    
    describe(@"pay amount is disabled and pay hours permission is disabled", ^{
        beforeEach(^{
            
            grossPayPagingController stub_method(@selector(viewControllers)).and_return(@[grossPayController, grossHoursController]);
            grossSummary stub_method(@selector(payAmountDetailsPermission)).and_return(NO);
            grossSummary stub_method(@selector(payHoursDetailsPermission)).and_return(NO);
            [subject setupWithGrossSummary:grossSummary delegate:delegate];;
            
            subject.view should_not be_nil;
            
        });
        
        it(@"should correctly add grossPayPagingController as a childcontroller", ^{
            childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(grossPayPagingController,subject,subject.pageControllerContainerView);
        });
    });

    
    describe(@"pay amount permission is enabled", ^{
        beforeEach(^{

            grossPayPagingController stub_method(@selector(viewControllers)).and_return(@[grossPayController, grossHoursController]);
            grossSummary stub_method(@selector(payAmountDetailsPermission)).and_return(YES);
            grossSummary stub_method(@selector(payHoursDetailsPermission)).and_return(YES);
            [subject setupWithGrossSummary:grossSummary delegate:delegate];;

            subject.view should_not be_nil;

        });

        it(@"should correctly add grossPayPagingController as a childcontroller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(grossPayPagingController,subject,subject.pageControllerContainerView);
        });

        it(@"should have visible viewcontroller on pageViewController", ^{
            grossPayPagingController.viewControllers.count should equal(2);
            grossPayPagingController.viewControllers.firstObject should be_same_instance_as(grossPayController);
            grossPayPagingController.viewControllers.lastObject should be_same_instance_as(grossHoursController);

        });
        
        it(@"should have userinteraction enabled", ^{
            subject.view.userInteractionEnabled should be_truthy;
        });
        
        it(@"should not hide page controller", ^{
            subject.pageControl.hidden should be_falsy;
        });

        it(@"should not have any effect on page scroll", ^{
            UIViewController *controller = [subject pageViewController:grossPayPagingController viewControllerAfterViewController:grossHoursController];
            controller should be_nil;
            subject.pageControl.currentPage should equal(1);
        });

        it(@"should not have any effect on page scroll if scrolled to the left", ^{
            UIViewController *controller = [subject pageViewController:grossPayPagingController viewControllerBeforeViewController:grossPayController];
            controller should be_nil;
            subject.pageControl.currentPage should equal(0);
        });

        it(@"should show the correct controller when scrolled to the right", ^{
            UIViewController *controller1 = [subject pageViewController:grossPayPagingController viewControllerAfterViewController:grossPayController];
            controller1 should be_same_instance_as(grossHoursController);
            subject.pageControl.currentPage should equal(1);

            UIViewController *controller2 = [subject pageViewController:grossPayPagingController viewControllerAfterViewController:grossHoursController];
            controller2 should be_nil;
            subject.pageControl.currentPage should equal(1);
        });

    });
    
    describe(@"when pay amount permission is disabled", ^{
        beforeEach(^{

            grossPayPagingController stub_method(@selector(viewControllers)).and_return(@[grossHoursController]);

            grossSummary stub_method(@selector(payAmountDetailsPermission)).and_return(NO);
            grossSummary stub_method(@selector(payHoursDetailsPermission)).and_return(YES);
            [subject setupWithGrossSummary:grossSummary delegate:delegate];
            subject.view should_not be_nil;
        });

        it(@"should correctly add grossPayPagingController as a childcontroller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(grossPayPagingController,subject,subject.pageControllerContainerView);
        });
        
        it(@"should have visible viewcontroller on pageViewController", ^{
            grossPayPagingController.viewControllers.count should equal(1);
            grossPayPagingController.viewControllers.firstObject should be_same_instance_as(grossHoursController);
        });

        it(@"should disable pageController scrolling", ^{
            grossPayPagingController.dataSource should be_nil;
        });
        
        it(@"should have userinteraction enabled", ^{
            subject.view.userInteractionEnabled should be_truthy;
        });
        
        it(@"should not hide page controller", ^{
            subject.pageControl.hidden should be_truthy;
        });

        it(@"should not have any effect on page scroll", ^{
            UIViewController *controller = [subject pageViewController:grossPayPagingController viewControllerAfterViewController:grossHoursController];
            controller should be_nil;
            subject.pageControl.currentPage should equal(0);
        });

        it(@"should not have any effect on page scroll", ^{
            UIViewController *controller = [subject pageViewController:grossPayPagingController viewControllerBeforeViewController:grossHoursController];
            controller should be_nil;
            subject.pageControl.currentPage should equal(0);
        });
        
    });
    
    describe(@"when pay amount permission is enabled and pay hours permission is disabled", ^{
        beforeEach(^{
            
            grossPayPagingController stub_method(@selector(viewControllers)).and_return(@[grossPayController]);
            grossSummary stub_method(@selector(payAmountDetailsPermission)).and_return(YES);
            grossSummary stub_method(@selector(payHoursDetailsPermission)).and_return(NO);
            [subject setupWithGrossSummary:grossSummary delegate:delegate];
            subject.view should_not be_nil;
        });
        
        it(@"should have visible viewcontroller on pageViewController", ^{
            grossPayPagingController.viewControllers.count should equal(1);
            grossPayPagingController.viewControllers.firstObject should be_same_instance_as(grossPayController);
        });
        
        it(@"should disable pageController scrolling", ^{
            grossPayPagingController.dataSource should be_nil;
        });
        
        it(@"should not hide page controller", ^{
            subject.pageControl.hidden should be_truthy;
        });
        
    });
    
    describe(@"when pay amount permission is disabled and hours permission enabled", ^{
        beforeEach(^{
            
            grossPayPagingController stub_method(@selector(viewControllers)).and_return(@[grossHoursController]);
            grossSummary stub_method(@selector(payAmountDetailsPermission)).and_return(NO);
            grossSummary stub_method(@selector(payHoursDetailsPermission)).and_return(YES);
            [subject setupWithGrossSummary:grossSummary delegate:delegate];
            subject.view should_not be_nil;
        });
        
        
        it(@"should have visible viewcontroller on pageViewController", ^{
            grossPayPagingController.viewControllers.count should equal(1);
            grossPayPagingController.viewControllers.firstObject should be_same_instance_as(grossHoursController);
        });
        
        it(@"should disable pageController scrolling", ^{
            grossPayPagingController.dataSource should be_nil;
        });
        
        it(@"should not hide page controller", ^{
            subject.pageControl.hidden should be_truthy;
        });
        
        
    });
});

SPEC_END
