#import <Cedar/Cedar.h>
#import "GrossHoursController.h"
#import "Theme.h"
#import "ChildControllerHelper.h"
#import "GrossHours.h"
#import "GrossPayCollectionViewViewController.h"
#import <KSDeferred/KSPromise.h>
#import <KSDeferred/KSDeferred.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "DonutChartViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(GrossHoursControllerSpec)

describe(@"GrossHoursController", ^{
    __block GrossHoursController *subject;
    __block id<Theme> theme;
    __block ChildControllerHelper *childControllerHelper;
    __block GrossPayCollectionViewViewController *grossPayCollectionViewViewController;
    __block id<BSBinder, BSInjector> injector;
    __block DonutChartViewController *donutChartViewController;
    __block id<GrossHoursControllerDelegate> delegate;
    
    beforeEach(^{
        injector = (id)[InjectorProvider injector];
        theme = fake_for(@protocol(Theme));
        
        theme stub_method(@selector(grossPayFont)).and_return([UIFont systemFontOfSize:32.f]);
        theme stub_method(@selector(grossPayHeaderFont)).and_return([UIFont systemFontOfSize:17.f]);
        theme stub_method(@selector(grossPaySeparatorBackgroundColor)).and_return([UIColor magentaColor]);
        theme stub_method(@selector(grossPayTextColor)).and_return([UIColor brownColor]);
        
        donutChartViewController = nice_fake_for([DonutChartViewController class]);
        [injector bind:[DonutChartViewController class] toInstance:donutChartViewController];
         [injector bind:@protocol(Theme) toInstance:theme];
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
    
        delegate = nice_fake_for(@protocol(GrossHoursControllerDelegate));
        subject = [injector getInstance:[GrossHoursController class]];

    });
    describe(@"scriptCalculationDate is not nil", ^{
        
   
    __block GrossHours *totalHours;
    beforeEach(^{
        totalHours = [[GrossHours alloc] initWithHours:@"5" minutes:@"30"];
        [subject setupWithGrossHours:totalHours
                grossHoursHeaderText:@"Total Time"
                      actualsPayCode:nil
                            delegate:delegate
               scriptCalculationDate:@"Script"];
        
        subject.view should_not be_nil;
    });
    
    it(@"should display the header text", ^{
        subject.grossHoursHeaderLabel.text should equal(@"Total Time");
        subject.asterixHeightConstraint.constant should equal(20);
        subject.asterixHoursLabel.text should equal(@"*");
    });
    
    
    it(@"should use the theme to style the view", ^{
        subject.grossHoursHeaderLabel.font should equal([UIFont systemFontOfSize:17.f]);
        subject.totalHoursLabel.font should equal([UIFont systemFontOfSize:32.f]);
        subject.grossHoursHeaderLabel.textColor should equal([UIColor brownColor]);
        subject.totalHoursLabel.textColor should equal([UIColor brownColor]);
        subject.asterixHoursLabel.textColor should equal([UIColor brownColor]);
        subject.separatorView.backgroundColor should equal([UIColor magentaColor]);
    });
     });
    describe(@"updateWithGrossPay:", ^{
        __block GrossHours *totalHours;
        beforeEach(^{
            totalHours = [[GrossHours alloc] initWithHours:@"6" minutes:@"35"];
            [subject setupWithGrossHours:totalHours
                    grossHoursHeaderText:@"Total Time"
                          actualsPayCode:nil
                                delegate:delegate
                   scriptCalculationDate:nil];
            
            subject.view should_not be_nil;
        });
        
        it(@"should assign the passedin Currency value", ^{
            subject.grossHours should be_same_instance_as(totalHours);
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
         __block GrossHours *totalHours;
        beforeEach(^{
            grossPayCollectionViewViewController = [[GrossPayCollectionViewViewController alloc]init];
            spy_on(grossPayCollectionViewViewController);
            [injector bind:[GrossPayCollectionViewViewController class] toInstance:grossPayCollectionViewViewController];

            totalHours = [[GrossHours alloc] initWithHours:@"6" minutes:@"35"];
            spy_on(subject);
            [subject setupWithGrossHours:totalHours
                    grossHoursHeaderText:@"Total Time"
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
        __block GrossHours *totalHours;
        beforeEach(^{
            grossPayCollectionViewViewController = [[GrossPayCollectionViewViewController alloc]init];
            spy_on(grossPayCollectionViewViewController);
            [injector bind:[GrossPayCollectionViewViewController class] toInstance:grossPayCollectionViewViewController];
            
            totalHours = [[GrossHours alloc] initWithHours:@"6" minutes:@"35"];
            spy_on(subject);
            [subject setupWithGrossHours:totalHours
                    grossHoursHeaderText:@"Total Time"
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
       __block GrossHours *totalHours;
        beforeEach(^{
            totalHours = [[GrossHours alloc] initWithHours:@"6" minutes:@"35"];
            spy_on(subject);
            [subject setupWithGrossHours:totalHours
                    grossHoursHeaderText:@"Total Time"
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
