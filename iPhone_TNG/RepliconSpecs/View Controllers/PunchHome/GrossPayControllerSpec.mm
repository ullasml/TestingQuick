#import <Cedar/Cedar.h>
#import "GrossPayController.h"
#import "CurrencyValue.h"
#import "Theme.h"
#import "ChildControllerHelper.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "GrossPayCollectionViewViewController.h"
#import "DonutChartViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(GrossPayControllerSpec)

describe(@"GrossPayController", ^{
    __block GrossPayController *subject;
    __block id<Theme> theme;
    __block ChildControllerHelper *childControllerHelper;
    __block GrossPayCollectionViewViewController *grossPayCollectionViewViewController;
    __block id<BSBinder, BSInjector> injector;
    __block DonutChartViewController *donutChartViewController;
    __block id<GrossPayControllerDelegate> delegate;
    
    beforeEach(^{
        theme = fake_for(@protocol(Theme));
        theme stub_method(@selector(grossPayFont)).and_return([UIFont systemFontOfSize:32.f]);
        theme stub_method(@selector(grossPayHeaderFont)).and_return([UIFont systemFontOfSize:17.f]);
        theme stub_method(@selector(grossPayTextColor)).and_return([UIColor brownColor]);
        theme stub_method(@selector(grossPaySeparatorBackgroundColor)).and_return([UIColor magentaColor]);
        delegate = nice_fake_for(@protocol(GrossPayControllerDelegate));
        
        injector = [InjectorProvider injector];
        [injector bind:@protocol(Theme) toInstance:theme];
        
        donutChartViewController = nice_fake_for([DonutChartViewController class]);
        [injector bind:[DonutChartViewController class] toInstance:donutChartViewController];

        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        
        subject = [injector getInstance:[GrossPayController class]];
    });
    describe(@"ScriptCalculationDate is nil", ^{
        
    
    __block CurrencyValue *totalPay;
    beforeEach(^{

        totalPay = [[CurrencyValue alloc] initWithCurrencyDisplayText:@"£" amount:@120];
        [subject setupWithGrossPay:totalPay
                grossPayHeaderText:@"My Special Header"
                    actualsPayCode:nil
                          delegate:delegate
             scriptCalculationDate:nil];
        
        subject.view should_not be_nil;
    });
 
    it(@"should display the header text", ^{
        subject.grossPayHeaderLabel.text should equal(@"My Special Header");
    });
    
    it(@"asterix height constant should be 0", ^{
        subject.asterixHeightConstraint.constant should equal(0);
    });

    it(@"should display the total pay", ^{
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        numberFormatter.currencySymbol = @"£";
        NSString *totalPayable = [numberFormatter stringFromNumber:[NSNumber numberWithInt:120]];
        subject.totalPayLabel.text should equal(totalPayable);
    });

    it(@"should use the theme to style the view", ^{
        subject.totalPayLabel.font should equal([UIFont systemFontOfSize:32.f]);
        subject.totalPayLabel.textColor should equal([UIColor brownColor]);
        subject.grossPayHeaderLabel.font should equal([UIFont systemFontOfSize:17.f]);
        subject.grossPayHeaderLabel.textColor should equal([UIColor brownColor]);
        subject.asterixPayLabel.textColor should equal([UIColor brownColor]);
        subject.separatorView.backgroundColor should equal([UIColor magentaColor]);
    });
});
    describe(@"updateWithGrossPay:", ^{
        __block CurrencyValue *totalPay;
        beforeEach(^{
            totalPay = [[CurrencyValue alloc] initWithCurrencyDisplayText:@"£" amount:@120];
            [subject setupWithGrossPay:totalPay
                    grossPayHeaderText:@"My Special Header"
                        actualsPayCode:nil
                              delegate:delegate
                 scriptCalculationDate:nil];
            
            subject.view should_not be_nil;
            spy_on(subject);
        });

        it(@"should assign the passedin Currency value", ^{
            subject.grossPay should be_same_instance_as(totalPay);
        });

        it(@"asterix height should be 0", ^{
            subject.asterixHeightConstraint.constant should equal(0);
        });
    });
    
    describe(@"should have called DonutChart setup method", ^{
        beforeEach(^{
            [subject viewDidLoad];
        });
        
        it(@"should have received DonutChartViewController", ^{
            donutChartViewController should have_received(@selector(setupWithActualsPayCode:currencyDisplayText:donutChartViewBounds:));
        });
        
        it(@"childControllerHelper should have received DonutChartViewController", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
            .with(donutChartViewController, subject, subject.donutWidgetView);
        });
    });
    
    describe(@"actualsByPaycode is nil", ^{
        __block CurrencyValue *totalPay;
        beforeEach(^{
            grossPayCollectionViewViewController = [[GrossPayCollectionViewViewController alloc]init];
            spy_on(grossPayCollectionViewViewController);
            [injector bind:[GrossPayCollectionViewViewController class] toInstance:grossPayCollectionViewViewController];
            
            totalPay = [[CurrencyValue alloc] initWithCurrencyDisplayText:@"£" amount:@120];
            spy_on(subject);
            [subject setupWithGrossPay:totalPay
                    grossPayHeaderText:@"My Special Header"
                        actualsPayCode:nil
                              delegate:delegate
                 scriptCalculationDate:nil];

            [subject viewDidLoad];
        });
        
        it(@"should not call grossPayCollectionViewViewController when actualsByPaycode is nil", ^{
            grossPayCollectionViewViewController should_not have_received(@selector(setupWithActualsByPayCodeDetails:theme:delegate:scriptCalculationDate:));
        });
    });
    
    describe(@"actualsByPaycode is not nil", ^{
        __block CurrencyValue *totalPay;
        beforeEach(^{
            grossPayCollectionViewViewController = [[GrossPayCollectionViewViewController alloc]init];
            spy_on(grossPayCollectionViewViewController);
            [injector bind:[GrossPayCollectionViewViewController class] toInstance:grossPayCollectionViewViewController];
            
            totalPay = [[CurrencyValue alloc] initWithCurrencyDisplayText:@"£" amount:@120];
            spy_on(subject);
            [subject setupWithGrossPay:totalPay
                    grossPayHeaderText:@"My Special Header"
                        actualsPayCode:@[]
                              delegate:delegate
                 scriptCalculationDate:nil];
            [subject viewDidLoad];
        });
        it(@"should call grossPayCollectionViewViewController when actualsByPaycode is not nil", ^{
            grossPayCollectionViewViewController should have_received(@selector(setupWithActualsByPayCodeDetails:theme:delegate:scriptCalculationDate:));
        });
       
    });
    
    describe(@"should call delegate", ^{
         __block CurrencyValue *totalPay;
        beforeEach(^{
            totalPay = [[CurrencyValue alloc] initWithCurrencyDisplayText:@"£" amount:@120];
            spy_on(subject);
            [subject setupWithGrossPay:totalPay
                    grossPayHeaderText:@"My Special Header"
                        actualsPayCode:@[]
                              delegate:delegate
                 scriptCalculationDate:nil];
            [subject checkForViewMore];
        });
        
        it(@"delegate should have received grossPayControllerIntendsToUpdateHeight", ^{
            delegate should have_received(@selector(didGrossPayHomeViewControllerShowingViewMore));
        });
    });
    

});

SPEC_END
