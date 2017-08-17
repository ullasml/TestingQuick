#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PayWidgetHomeControllerSpec)

describe(@"PayWidgetHomeController", ^{
    __block PayWidgetHomeController *subject;
    __block id <Theme> theme;
    __block ChildControllerHelper *childControllerHelper;
    __block id<BSBinder, BSInjector> injector;
    __block id<PayWidgetHomeControllerDelegate>delegate;
    __block PayWidgetData *payWidgetData;
    __block PayWidgetPagingController *payWidgetPagingController;
    __block GrossPayOrHoursController *grossHoursController;
    __block GrossPayOrHoursController *grossPayController;
    __block PayWidgetPagingControllerPresenter *payWidgetPagingControllerPresenter;

    beforeEach(^{
        
        injector = [InjectorProvider injector];
        
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        theme stub_method(@selector(timesheetWidgetTitleFont)).and_return([UIFont systemFontOfSize:10]);
        theme stub_method(@selector(timesheetWidgetTitleTextColor)).and_return([UIColor orangeColor]);

        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        
        payWidgetPagingControllerPresenter = nice_fake_for([PayWidgetPagingControllerPresenter class]);
        [injector bind:[PayWidgetPagingControllerPresenter class] toInstance:payWidgetPagingControllerPresenter];
        
        childControllerHelper stub_method(@selector(addChildController:toParentController:inContainerView:)).and_do_block(^(UIViewController *childController, UIViewController *parentController, UIView *containerView) {
            [subject addChildViewController:[[UIViewController alloc] init]];
        });
        
        payWidgetPagingController = nice_fake_for([PayWidgetPagingController class]);
        [injector bind:[PayWidgetPagingController class] toInstance:payWidgetPagingController];

        grossHoursController = [[GrossPayOrHoursController alloc]initWithChildControllerHelper:nil theme:nil];
        grossPayController = [[GrossPayOrHoursController alloc]initWithChildControllerHelper:nil theme:nil];

        delegate = nice_fake_for(@protocol(PayWidgetHomeControllerDelegate));
        subject = [injector getInstance:[PayWidgetHomeController class]];
        
    });
    
    context(@"presenting the title", ^{
        __block Paycode *payCode;
        beforeEach(^{
            payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
            CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
            GrossHours *grossHours = [[GrossHours alloc]initWithHours:@"hours" minutes:@"minutes"];
            payWidgetData = [[PayWidgetData alloc]initWithGrossHours:grossHours grossPay:grossPay actualsByPaycode:@[payCode] actualsByDuration:@[payCode]];
            
            payWidgetPagingControllerPresenter stub_method(@selector(pagingViewControllersWithPayWidgetData:delegate:viewMode:displayPay:displayPayTotals:)).with(payWidgetData,subject,ShowActualsLess,YES,YES).and_return(@[grossPayController,grossHoursController]);
            [subject setupWithPayWidgetData:payWidgetData displayPayAmount:YES displayPayTotals:YES delegate:delegate];
            subject.view should_not be_nil;            
        });
        
        it(@"should correctly set the title", ^{
            subject.titleLabel.text should equal(RPLocalizedString(@"Payroll Summary", nil));
        });
    });
    
    context(@"when the displayPayAmount is truthy", ^{
        
        __block Paycode *payCode;
        beforeEach(^{
            payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
            CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
            GrossHours *grossHours = [[GrossHours alloc]initWithHours:@"hours" minutes:@"minutes"];
            payWidgetData = [[PayWidgetData alloc]initWithGrossHours:grossHours grossPay:grossPay actualsByPaycode:@[payCode] actualsByDuration:@[payCode]];
            payWidgetPagingControllerPresenter stub_method(@selector(pagingViewControllersWithPayWidgetData:delegate:viewMode:displayPay:displayPayTotals:)).with(payWidgetData,subject,ShowActualsLess,YES,YES).and_return(@[grossPayController,grossHoursController]);
            [subject setupWithPayWidgetData:payWidgetData displayPayAmount:YES displayPayTotals:YES delegate:delegate];
            subject.view should_not be_nil;            
        });
        
        it(@"should correctly set up the payWidgetPagingController", ^{
            payWidgetPagingController should have_received(@selector(setUpWithGrossViewControllers:currentlySelectedIndex:delegate:datasource:)).with(@[grossPayController,grossHoursController],0,nil,subject);
        });
        
        it(@"should add PayWidgetPagingController as a child to PayWidgetHomeController", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(payWidgetPagingController,subject,subject.pageControllerContainerView);
        });
        
        context(@"User intends to swipe", ^{
            __block UIViewController *expectedViewControllerAfterSwipe;
            
            context(@"when user tries to swipe left", ^{
                beforeEach(^{
                    expectedViewControllerAfterSwipe = [subject pageViewController:(id)[NSNull null] viewControllerBeforeViewController:grossPayController];
                });
                
                it(@"should not have any effect when swiped", ^{
                    expectedViewControllerAfterSwipe should be_nil;
                });
            });
            
            context(@"when user tries to swipe right", ^{
                beforeEach(^{
                    expectedViewControllerAfterSwipe = [subject pageViewController:(id)[NSNull null] viewControllerAfterViewController:grossPayController];
                });
                
                it(@"should correctly show grossHoursController when swiped right", ^{
                    expectedViewControllerAfterSwipe should be_same_instance_as(grossHoursController);
                });
                
                it(@"should not have any effect when swiped right again", ^{
                    expectedViewControllerAfterSwipe = [subject pageViewController:(id)[NSNull null] viewControllerAfterViewController:grossHoursController];
                    expectedViewControllerAfterSwipe should be_nil;
                });
                
                it(@"should correctly show grossPayController when swiped left", ^{
                    expectedViewControllerAfterSwipe = [subject pageViewController:(id)[NSNull null] viewControllerBeforeViewController:grossHoursController];
                    expectedViewControllerAfterSwipe should be_same_instance_as(grossPayController);
                });
            });
            
        });
        
    });
    
    context(@"when the displayPayAmount is falsy", ^{

        __block Paycode *payCode;
        beforeEach(^{
             payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
            CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
            payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[payCode] actualsByDuration:nil];
            payWidgetPagingControllerPresenter stub_method(@selector(pagingViewControllersWithPayWidgetData:delegate:viewMode:displayPay:displayPayTotals:)).with(payWidgetData,subject,ShowActualsLess,NO,YES).and_return(@[grossHoursController]);
            [subject setupWithPayWidgetData:payWidgetData displayPayAmount:NO displayPayTotals:YES delegate:delegate];
            subject.view should_not be_nil;            
        });
        
        it(@"should correctly set up the payWidgetPagingController", ^{
            payWidgetPagingController should have_received(@selector(setUpWithGrossViewControllers:currentlySelectedIndex:delegate:datasource:)).with(@[grossHoursController],0,nil,nil);
        });
        
        it(@"should add PayWidgetPagingController as a child to PayWidgetHomeController", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(payWidgetPagingController,subject,subject.pageControllerContainerView);
        });
        
        context(@"User intends to swipe", ^{
            __block UIViewController *expectedViewControllerAfterSwipe;
            context(@"when user tries to swipe left", ^{
                beforeEach(^{
                    expectedViewControllerAfterSwipe = [subject pageViewController:(id)[NSNull null] viewControllerBeforeViewController:grossHoursController];
                });
                
                it(@"should not have any effect when swiped", ^{
                    expectedViewControllerAfterSwipe should be_nil;
                });
            });
            
            context(@"when user tries to swipe right", ^{
                beforeEach(^{
                    expectedViewControllerAfterSwipe = [subject pageViewController:(id)[NSNull null] viewControllerAfterViewController:grossHoursController];
                });
                
                it(@"should not have any effect when swiped", ^{
                    expectedViewControllerAfterSwipe should be_nil;
                });
            });
            
        });

    });
    
    context(@"when the displayPayTotals is truthy", ^{
        
        __block Paycode *payCode;
        beforeEach(^{
            payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
            CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
            GrossHours *grossHours = [[GrossHours alloc]initWithHours:@"hours" minutes:@"minutes"];
            payWidgetData = [[PayWidgetData alloc]initWithGrossHours:grossHours grossPay:grossPay actualsByPaycode:@[payCode] actualsByDuration:@[payCode]];
            payWidgetPagingControllerPresenter stub_method(@selector(pagingViewControllersWithPayWidgetData:delegate:viewMode:displayPay:displayPayTotals:)).with(payWidgetData,subject,ShowActualsLess,YES,YES).and_return(@[grossPayController,grossHoursController]);
            [subject setupWithPayWidgetData:payWidgetData displayPayAmount:YES displayPayTotals:YES delegate:delegate];
            subject.view should_not be_nil;            
        });
        
        it(@"should correctly set up the payWidgetPagingController", ^{
            payWidgetPagingController should have_received(@selector(setUpWithGrossViewControllers:currentlySelectedIndex:delegate:datasource:)).with(@[grossPayController,grossHoursController],0,nil,subject);
        });
        
        it(@"should add PayWidgetPagingController as a child to PayWidgetHomeController", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(payWidgetPagingController,subject,subject.pageControllerContainerView);
        });
        
    });
    
    context(@"when the displayPayAmount is falsy", ^{
        
        __block Paycode *payCode;
        beforeEach(^{
            payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
            CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
            payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[payCode] actualsByDuration:nil];
            payWidgetPagingControllerPresenter stub_method(@selector(pagingViewControllersWithPayWidgetData:delegate:viewMode:displayPay:displayPayTotals:)).with(payWidgetData,subject,ShowActualsLess,NO,NO).and_return(@[grossHoursController]);
            [subject setupWithPayWidgetData:payWidgetData displayPayAmount:NO displayPayTotals:NO delegate:delegate];
            subject.view should_not be_nil;            
        });
        
        it(@"should correctly set up the payWidgetPagingController", ^{
            payWidgetPagingController should have_received(@selector(setUpWithGrossViewControllers:currentlySelectedIndex:delegate:datasource:)).with(@[grossHoursController],0,nil,nil);
        });
        
        it(@"should add PayWidgetPagingController as a child to PayWidgetHomeController", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(payWidgetPagingController,subject,subject.pageControllerContainerView);
        });
        
    });
    
    describe(@"should update its container height when view layouts", ^{
        
        __block Paycode *payCode;
        beforeEach(^{
            payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
            CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
            GrossHours *grossHours = [[GrossHours alloc]initWithHours:@"hours" minutes:@"minutes"];
            payWidgetData = [[PayWidgetData alloc]initWithGrossHours:grossHours grossPay:grossPay actualsByPaycode:@[payCode] actualsByDuration:@[payCode]];
            payWidgetPagingControllerPresenter stub_method(@selector(pagingViewControllersWithPayWidgetData:delegate:viewMode:displayPay:displayPayTotals:)).with(payWidgetData,subject,ShowActualsLess,YES,YES).and_return(@[grossPayController,grossHoursController]);
            [subject setupWithPayWidgetData:payWidgetData displayPayAmount:YES displayPayTotals:YES delegate:delegate];
            subject.view should_not be_nil;  
            [subject viewDidLayoutSubviews];

        });
        
        it(@"should request its delegte to update its container height constraint", ^{
            delegate should have_received(@selector(payWidgetHomeController:intendsToUpdateItsContainerWithHeight:)).with(subject,Arguments::anything);
        });
    });
    
    describe(@"As a <GrossPayOrHoursControllerDelegate>", ^{
        
        __block Paycode *payCode;
        beforeEach(^{
            payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
            CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
            GrossHours *grossHours = [[GrossHours alloc]initWithHours:@"hours" minutes:@"minutes"];
            payWidgetData = [[PayWidgetData alloc]initWithGrossHours:grossHours grossPay:grossPay actualsByPaycode:@[payCode] actualsByDuration:@[payCode]];
            payWidgetPagingControllerPresenter stub_method(@selector(pagingViewControllersWithPayWidgetData:delegate:viewMode:displayPay:displayPayTotals:)).with(payWidgetData,subject,ShowActualsLess,YES,YES).and_return(@[grossPayController,grossHoursController]);
            [subject setupWithPayWidgetData:payWidgetData displayPayAmount:YES displayPayTotals:YES delegate:delegate];
            subject.view should_not be_nil;  
            [subject viewDidLayoutSubviews];
            
        });
        
        context(@"grossPayOrHoursController:intendsToUpdateItsContainerWithHeight:", ^{
            
            beforeEach(^{
                [subject grossPayOrHoursController:(id)[NSNull null] intendsToUpdateItsContainerWithHeight:10];
            });
            
            it(@"should update the PayCodesContainerHeightConstraint", ^{
                subject.payCodesContainerHeightConstraint.constant should equal(10);
            });
            
            it(@"should request its delegte to update its container height constraint", ^{
                delegate should have_received(@selector(payWidgetHomeController:intendsToUpdateItsContainerWithHeight:)).with(subject,Arguments::anything);
            });
            
        });
        
        context(@"grossPayOrHoursController:intendsToRefreshWithViewMode:", ^{
            __block PayWidgetPagingController *newPayWidgetPagingController;
            beforeEach(^{
                newPayWidgetPagingController = nice_fake_for([PayWidgetPagingController class]);
                [injector bind:[PayWidgetPagingController class] toInstance:newPayWidgetPagingController];
                payWidgetPagingControllerPresenter stub_method(@selector(pagingViewControllersWithPayWidgetData:delegate:viewMode:displayPay:displayPayTotals:)).with(payWidgetData,subject,ShowActualsMore,YES,YES).and_return(@[grossPayController,grossHoursController]);
                [subject grossPayOrHoursController:(id)[NSNull null] intendsToRefreshWithViewMode:ShowActualsMore];
            });
            
            it(@"should return correct paging view controllers", ^{
                payWidgetPagingControllerPresenter should have_received(@selector(pagingViewControllersWithPayWidgetData:delegate:viewMode:displayPay:displayPayTotals:)).with(payWidgetData,subject,ShowActualsMore,YES,YES);
            });
            
            it(@"should correctly set up the payWidgetPagingController", ^{
                newPayWidgetPagingController should have_received(@selector(setUpWithGrossViewControllers:currentlySelectedIndex:delegate:datasource:)).with(@[grossPayController,grossHoursController],0,nil,subject);
            });
            
            it(@"should replace older PayWidgetPagingController", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,newPayWidgetPagingController,subject,subject.pageControllerContainerView);
            });
            
            context(@"when user intendsToRefreshWithViewMode ShowActualsLess", ^{
                __block PayWidgetPagingController *newPayWidgetPagingController;
                __block GrossPayOrHoursController *newGrossHoursController;
                __block GrossPayOrHoursController *newGrossPayController;
               
                beforeEach(^{
                    newPayWidgetPagingController = nice_fake_for([PayWidgetPagingController class]);
                    [injector bind:[PayWidgetPagingController class] toInstance:newPayWidgetPagingController];
                    
                    newGrossHoursController = [[GrossPayOrHoursController alloc]initWithChildControllerHelper:nil theme:nil];
                    newGrossPayController = [[GrossPayOrHoursController alloc]initWithChildControllerHelper:nil theme:nil];
                    
                    payWidgetPagingControllerPresenter stub_method(@selector(pagingViewControllersWithPayWidgetData:delegate:viewMode:displayPay:displayPayTotals:)).with(payWidgetData,subject,ShowActualsLess,YES,YES).again().and_return(@[newGrossPayController,newGrossHoursController]);
                    [subject grossPayOrHoursController:(id)[NSNull null] intendsToRefreshWithViewMode:ShowActualsLess];
                });
                
                it(@"should return correct paging view controllers", ^{
                    payWidgetPagingControllerPresenter should have_received(@selector(pagingViewControllersWithPayWidgetData:delegate:viewMode:displayPay:displayPayTotals:)).with(payWidgetData,subject,ShowActualsLess,YES,YES);
                });
                
                it(@"should correctly set up the payWidgetPagingController", ^{
                    newPayWidgetPagingController should have_received(@selector(setUpWithGrossViewControllers:currentlySelectedIndex:delegate:datasource:)).with(@[newGrossPayController,newGrossHoursController],0,nil,subject);
                });
                
                it(@"should replace older PayWidgetPagingController", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,newPayWidgetPagingController,subject,subject.pageControllerContainerView);
                });
            });

        });
    });

});

SPEC_END
