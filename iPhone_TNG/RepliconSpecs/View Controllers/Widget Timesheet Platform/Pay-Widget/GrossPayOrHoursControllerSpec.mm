#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "UIControl+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(GrossPayOrHoursControllerSpec)

describe(@"GrossPayOrHoursController", ^{
    __block GrossPayOrHoursController *subject;
    __block id <Theme> theme;
    __block ChildControllerHelper *childControllerHelper;
    __block PayWidgetData *payWidgetData;
    __block id<GrossPayOrHoursControllerDelegate> delegate;
    __block id<BSBinder, BSInjector> injector;
    __block DonutChartViewController *donutChartViewController;
    __block UIButton *showMoreOrLessButton;

    beforeEach(^{
        
        injector = [InjectorProvider injector];
        
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        donutChartViewController = [[DonutChartViewController alloc]initWithTheme:nil];
        [injector bind:[DonutChartViewController class] toInstance:donutChartViewController];
        
        spy_on(donutChartViewController);

        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];

        delegate = nice_fake_for(@protocol(GrossPayOrHoursControllerDelegate));
        subject = [injector getInstance:[GrossPayOrHoursController class]];

    });
    
    afterEach(^{
        stop_spying_on(donutChartViewController);
    });
    
    context(@"presenting the gross header title and its value", ^{
        
        context(@"when screen type is GrossPay", ^{
            
            context(@"when the  displayPayTotals is truthy", ^{
                __block Paycode *payCode;
                beforeEach(^{
                    payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                    CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"$" amount:@30];
                    payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[payCode] actualsByDuration:nil];
                    [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:true];
                    subject.view should_not be_nil;
                });
                
                it(@"should correctly set grossHeaderLabel and grossValueLabel", ^{
                    subject.grossHeaderLabel.text should equal(RPLocalizedString(@"Gross Pay", nil));
                    subject.grossValueLabel.text should equal(@"$30.00");
                });
            });
            
            context(@"when the  displayPayTotals is falsy", ^{
                __block Paycode *payCode;
                beforeEach(^{
                    payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                    CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"$" amount:@30];
                    payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[payCode] actualsByDuration:nil];
                    [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:false];
                    subject.view should_not be_nil;
                });
                
                it(@"should hide grossHeaderLabel and grossValueLabel", ^{
                    subject.grossHeaderLabel.isHidden should be_truthy;
                    subject.grossValueLabel.isHidden should be_truthy;
                });
            });
            
        });
        
        context(@"when screen type is GrossHours", ^{
            
            context(@"when the  displayPayTotals is truthy", ^{
                __block Paycode *payCode;
                beforeEach(^{
                    GrossHours *grossHours = [[GrossHours alloc]initWithHours:@"hours" minutes:@"minutes"];
                    payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                    payWidgetData = [[PayWidgetData alloc]initWithGrossHours:grossHours grossPay:nil actualsByPaycode:nil actualsByDuration:@[payCode]];
                    [subject setupWithPayWidgetData:payWidgetData screenType:GrossHoursScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:true];
                    subject.view should_not be_nil;
                });
                
                it(@"should correctly set grossHeaderLabel and grossValueLabel", ^{
                    subject.grossHeaderLabel.text should equal(RPLocalizedString(@"Total Time", nil));
                    subject.grossValueLabel.text should equal(@"hoursh:minutesm");
                });
            });
            
            context(@"when the  displayPayTotals is falsy", ^{
                
                __block Paycode *payCode;
                beforeEach(^{
                    GrossHours *grossHours = [[GrossHours alloc]initWithHours:@"hours" minutes:@"minutes"];
                    payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                    payWidgetData = [[PayWidgetData alloc]initWithGrossHours:grossHours grossPay:nil actualsByPaycode:nil actualsByDuration:@[payCode]];
                    [subject setupWithPayWidgetData:payWidgetData screenType:GrossHoursScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:false];
                    subject.view should_not be_nil;
                });
        
                it(@"should hide grossHeaderLabel and grossValueLabel", ^{
                    subject.grossHeaderLabel.isHidden should be_truthy;
                    subject.grossValueLabel.isHidden should be_truthy;
                });
            });
        });
    });
    
    context(@"presenting the show more or less button", ^{
        
        context(@"when paycodes are more than 4", ^{
            __block Paycode *payCodeA;
            __block Paycode *payCodeB;
            __block Paycode *payCodeC;
            __block Paycode *payCodeD;
            __block Paycode *payCodeE;
            beforeEach(^{
                payCodeA = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                payCodeB = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                payCodeC = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                payCodeD = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                payCodeE = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];

                CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
                payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[payCodeA,payCodeB,payCodeC,payCodeD,payCodeE] actualsByDuration:nil];
                [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:true];
                subject.view should_not be_nil;
                showMoreOrLessButton = subject.showMoreOrLessButton;
                spy_on(showMoreOrLessButton);
                
            });
            
            afterEach(^{
                stop_spying_on(showMoreOrLessButton);
            });
            
            it(@"should not remove showMoreOrLessButton from the view", ^{
                showMoreOrLessButton should_not have_received(@selector(removeFromSuperview));
            });
        });
        
        context(@"when paycodes are less than 4", ^{
            __block Paycode *payCode;
            beforeEach(^{
                payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
                payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[payCode] actualsByDuration:nil];
                [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:true];
                subject.view should_not be_nil;
                spy_on(subject.showMoreOrLessButton);

            });
            
            afterEach(^{
                stop_spying_on(subject.showMoreOrLessButton);
            });
            
            it(@"should remove showMoreOrLessButton from the view", ^{
                subject.view.subviews should_not contain(subject.showMoreOrLessButton);
            });
            
            
        });
        
        context(@"when paycodes are equal to 4", ^{
            __block Paycode *payCode;
            beforeEach(^{
                payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
                payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[payCode,payCode,payCode,payCode] actualsByDuration:nil];
                [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:true];
                subject.view should_not be_nil;
                spy_on(subject.showMoreOrLessButton);
                
            });
            
            afterEach(^{
                stop_spying_on(subject.showMoreOrLessButton);
            });
            
            it(@"should remove showMoreOrLessButton from the view", ^{                
                subject.view.subviews should_not contain(subject.showMoreOrLessButton);
            });
            
            
        });
        
        context(@"show more or less button title and the tag", ^{
            
            context(@"when view mode is show more", ^{
                __block Paycode *payCode;
                beforeEach(^{
                    payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                    CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
                    payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[payCode,payCode,payCode,payCode] actualsByDuration:nil];
                    [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:true];
                    subject.view should_not be_nil;
                    spy_on(subject.showMoreOrLessButton);
                    
                });
                
                it(@"should correctly set the title", ^{
                    subject.showMoreOrLessButton.currentTitle should equal(RPLocalizedString(@"Show Less", nil));
                });
                
                it(@"should correctly set the tag", ^{
                    subject.showMoreOrLessButton.tag should equal(ShowActualsMore);
                });
                
                
            });
            
            context(@"when view mode is show less", ^{
                __block Paycode *payCode;
                beforeEach(^{
                    payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                    CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
                    payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[payCode,payCode,payCode,payCode] actualsByDuration:nil];
                    [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsLess displayPayTotals:true];
                    subject.view should_not be_nil;
                    spy_on(subject.showMoreOrLessButton);
                    
                });
                
                it(@"should correctly set the title", ^{
                    subject.showMoreOrLessButton.currentTitle should equal(RPLocalizedString(@"Show More", nil));
                });
                
                it(@"should correctly set the tag", ^{
                    subject.showMoreOrLessButton.tag should equal(ShowActualsLess);
                });
            });
        });
        
        context(@"when user taps on show more or less button", ^{
            
            context(@"when user taps on show more", ^{
                __block Paycode *payCode;
                beforeEach(^{
                    payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                    CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
                    payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[payCode,payCode,payCode,payCode,payCode] actualsByDuration:nil];
                    [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:true];
                    subject.view should_not be_nil;                    
                    [subject.showMoreOrLessButton tap];
                    
                });
                
                it(@"should correctly take action for viewing more items", ^{
                    delegate should have_received(@selector(grossPayOrHoursController:intendsToRefreshWithViewMode:)).with(subject,ShowActualsLess);
                    subject.showMoreOrLessButton.tag should equal(ShowActualsMore);
                    subject.showMoreOrLessButton.currentTitle should equal(RPLocalizedString(@"Show Less", nil));
                });

            });
            
            context(@"when user taps on show less", ^{
                __block Paycode *payCode;
                beforeEach(^{
                    payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                    CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
                    payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[payCode,payCode,payCode,payCode,payCode] actualsByDuration:nil];
                    [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsLess displayPayTotals:true];
                    subject.view should_not be_nil;                    
                    [subject.showMoreOrLessButton tap];
                });
                
                it(@"should correctly take action for viewing less items", ^{
                    delegate should have_received(@selector(grossPayOrHoursController:intendsToRefreshWithViewMode:)).with(subject,ShowActualsMore);
                    subject.showMoreOrLessButton.tag should equal(ShowActualsLess);
                    subject.showMoreOrLessButton.currentTitle should equal(RPLocalizedString(@"Show More", nil));
                });
            });
        });
    });
    
    context(@"presenting the GrossPayCodeCollectionController", ^{
        
        __block GrossPayCodeCollectionController *grossPayCodeCollectionController;
        
        beforeEach(^{
            grossPayCodeCollectionController = [[GrossPayCodeCollectionController alloc]initWithTheme:nil];
            [injector bind:[GrossPayCodeCollectionController class] toInstance:grossPayCodeCollectionController];
            
            spy_on(grossPayCodeCollectionController);
        });
        
        afterEach(^{
            stop_spying_on(grossPayCodeCollectionController);
        });
        
        context(@"when the actuals are present", ^{
            
            context(@"when the view mode is ShowActualsMore", ^{
                __block Paycode *payCode;
                beforeEach(^{
                    payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                    CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
                    payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[payCode,payCode,payCode,payCode] actualsByDuration:nil];
                    [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:true];
                    subject.view should_not be_nil;
                    spy_on(subject.showMoreOrLessButton);
                    
                });
                
                it(@"should add the grossPayCodeCollectionController as a child to GrossPayOrHoursController", ^{
                    grossPayCodeCollectionController should have_received(@selector(setupWithActualsByPayCode:delegate:)).with(@[payCode,payCode,payCode,payCode],subject);
                    childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(grossPayCodeCollectionController,subject,subject.grossPayLegendsContainerView);
                });
            });
            
            context(@"when the view mode is ShowActualsLess", ^{
                __block Paycode *payCode;
                beforeEach(^{
                    payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                    CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
                    payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[payCode,payCode,payCode,payCode,payCode] actualsByDuration:nil];
                    [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsLess displayPayTotals:true];
                    subject.view should_not be_nil;
                    spy_on(subject.showMoreOrLessButton);
                    
                });
                
                it(@"should add the grossPayCodeCollectionController as a child to GrossPayOrHoursController", ^{
                    grossPayCodeCollectionController should have_received(@selector(setupWithActualsByPayCode:delegate:)).with(@[payCode,payCode,payCode,payCode],subject);
                    childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(grossPayCodeCollectionController,subject,subject.grossPayLegendsContainerView);
                });
            });
        
        });
        
        context(@"when the actuals are not present", ^{
            __block Paycode *payCode;
            beforeEach(^{
                payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
                payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[] actualsByDuration:@[]];
                [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:true];
                subject.view should_not be_nil;
                spy_on(subject.showMoreOrLessButton);
                
            });
            
            it(@"should not add the grossPayCodeCollectionController as a child to GrossPayOrHoursController", ^{
                grossPayCodeCollectionController should_not have_received(@selector(setupWithActualsByPayCode:delegate:));
                childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(grossPayCodeCollectionController,subject,subject.grossPayLegendsContainerView);
            });

        });
    });
    
    context(@"presenting the DonutChartViewController", ^{
        
        context(@"when screen type is GrossPay", ^{
            __block Paycode *payCode;
            beforeEach(^{
                payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
                payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[payCode] actualsByDuration:nil];
                [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:true];
                subject.view should_not be_nil;
            });
            
            
            it(@"should corrcetly set up the donutChartViewController", ^{
                donutChartViewController should have_received(@selector(setupWithActualsPayCode:currencyDisplayText:donutChartViewBounds:)).with(@[payCode],@"some-currency",Arguments::anything);
            });  
            
            it(@"should add the DonutChartViewController as a child to GrossPayOrHoursController", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(donutChartViewController,subject,subject.donutWidgetView);
            });
            
        });
        
        context(@"when screen type is GrossHours", ^{
            __block Paycode *payCode;
            beforeEach(^{
                GrossHours *grossHours = [[GrossHours alloc]initWithHours:@"some-hours" minutes:@"some-minutes"];
                payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                payWidgetData = [[PayWidgetData alloc]initWithGrossHours:grossHours grossPay:nil actualsByPaycode:nil actualsByDuration:@[payCode]];
                [subject setupWithPayWidgetData:payWidgetData screenType:GrossHoursScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:true];
                subject.view should_not be_nil;
            });
            
            
            it(@"should corrcetly set up the donutChartViewController", ^{
                donutChartViewController should have_received(@selector(setupWithActualsPayCode:currencyDisplayText:donutChartViewBounds:)).with(@[payCode],nil,Arguments::anything);
            });  
            
            it(@"should add the DonutChartViewController as a child to GrossPayOrHoursController", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(donutChartViewController,subject,subject.donutWidgetView);
            });
            
        });
    });
    
    describe(@"should update its container height when view layouts", ^{
        
        __block Paycode *payCode;
        beforeEach(^{
            payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
            CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
            payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[] actualsByDuration:@[]];
            [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:true];
            subject.view should_not be_nil;
            [subject viewDidLayoutSubviews];
            
        });
        
        it(@"should request its delagte to update its container height constraint", ^{
            delegate should have_received(@selector(grossPayOrHoursController:intendsToUpdateItsContainerWithHeight:)).with(subject,Arguments::anything);
        });
    });
    
    describe(@"As a <GrossPayCodeCollectionControllerDelegate>", ^{
        
        __block Paycode *payCode;
        beforeEach(^{
            payCode = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
            CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"some-currency" amount:@30];
            payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:grossPay actualsByPaycode:@[] actualsByDuration:@[]];
            [subject setupWithPayWidgetData:payWidgetData screenType:GrossPayScreen delegate:delegate viewMode:ShowActualsMore displayPayTotals:true];
            subject.view should_not be_nil;
            spy_on(subject.showMoreOrLessButton);
            
        });
        
        context(@"grossPayOrHoursController:intendsToUpdateItsContainerWithHeight:", ^{
            beforeEach(^{
                [subject grossPayCodeCollectionController:(id)[NSNull null] intendsToUpdateItsContainerWithHeight:10];
                
            });
            it(@"should inform its delegate to update its container height", ^{
                subject.payCodeContainerHeight.constant should equal(10);
                delegate should have_received(@selector(grossPayOrHoursController:intendsToUpdateItsContainerWithHeight:)).with(subject,Arguments::anything);
            });
        });
    });

});

SPEC_END
