#import <Cedar/Cedar.h>
#import "GrossPayCollectionViewViewController.h"
#import "Theme.h"
#import "Paycode.h"
#import "GrossPayHoursCell.h"
#import "UIControl+Spec.h"
#import "GrossPayHours.h"
#import "GrossPayController.h"
#import "GrossHoursController.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(GrossPayCollectionViewViewControllerSpec)

describe(@"GrossPayCollectionViewViewController", ^{
    __block GrossPayCollectionViewViewController *subject;
    __block UICollectionView *collectionView;
    __block id<Theme> theme;
    __block id<GrossPayCollectionViewControllerDelegate> delegate;
    __block id <GrossPayHours> grossPayHours;

    beforeEach(^{
        subject = [[GrossPayCollectionViewViewController alloc]init];
        theme = nice_fake_for(@protocol(Theme));
        delegate = nice_fake_for(@protocol(GrossPayCollectionViewControllerDelegate));
        
        [subject.view layoutIfNeeded];
        [subject viewDidLoad];
    });
    
    context(@"should display collectionview", ^{
        beforeEach(^{
            
            theme stub_method(@selector(legendsGrossPayFont)).and_return([UIFont systemFontOfSize:18.0f]);
            theme stub_method(@selector(legendsGrossPayHeaderFont)).and_return([UIFont systemFontOfSize:10.0f]);

            Paycode *paycode1 = [[Paycode alloc] initWithValue:@"$30" title:@"Time Off1" timeSeconds:nil];
            [subject setupWithActualsByPayCodeDetails:@[paycode1]
                                            theme:theme
                                             delegate:delegate
                                scriptCalculationDate:nil];
            collectionView = subject.collectionView;
            spy_on(collectionView);
        });
        
        it(@"should reload the workhours collection view", ^{
            [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(1);
        });
        
        it(@"should style the cells appropriately", ^{
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
             
            GrossPayHoursCell *cell = (id)[subject collectionView:subject.collectionView cellForItemAtIndexPath:firstItemIndexPath];
            cell.valueLabel.text should equal(@"$30");
            cell.titleLabel.text should equal(@"Time Off1");
            cell.valueLabel.font should equal([UIFont systemFontOfSize:18.0f]);
            cell.titleLabel.font should equal([UIFont systemFontOfSize:10.0f]);
        });
        
    });
    
    context(@"should display collectionview with negative values", ^{
        beforeEach(^{
            
            theme stub_method(@selector(legendsGrossPayFont)).and_return([UIFont systemFontOfSize:18.0f]);
            theme stub_method(@selector(legendsGrossPayHeaderFont)).and_return([UIFont systemFontOfSize:10.0f]);
            
            Paycode *paycode1 = [[Paycode alloc] initWithValue:@"$-30.34" title:@"Time Off1" timeSeconds:nil];
            Paycode *paycode2 = [[Paycode alloc] initWithValue:@"$45.80" title:@"Time Off2" timeSeconds:nil];
            Paycode *paycode3 = [[Paycode alloc] initWithValue:@"$-29.85" title:@"Time Off3" timeSeconds:nil];
            [subject setupWithActualsByPayCodeDetails:@[paycode1, paycode2, paycode3]
                                                theme:theme
                                             delegate:delegate
                                scriptCalculationDate:nil];
            
            [subject.collectionView layoutIfNeeded];
            collectionView = subject.collectionView;
            spy_on(collectionView);
        });
        
        it(@"should reload the workhours collection view", ^{
            [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(3);
        });
        
        it(@"should style the cells appropriately", ^{
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            
            GrossPayHoursCell *cell = (id)[subject collectionView:subject.collectionView cellForItemAtIndexPath:firstItemIndexPath];
            cell.valueLabel.text should equal(@"$-30.34");
            cell.titleLabel.text should equal(@"Time Off1");
            cell.valueLabel.font should equal([UIFont systemFontOfSize:18.0f]);
            cell.titleLabel.font should equal([UIFont systemFontOfSize:10.0f]);
        });
        
        it(@"should style the cells appropriately", ^{
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            
            GrossPayHoursCell *cell = (id)[subject collectionView:subject.collectionView cellForItemAtIndexPath:firstItemIndexPath];
            cell.valueLabel.text should equal(@"$45.80");
            cell.titleLabel.text should equal(@"Time Off2");
            cell.valueLabel.font should equal([UIFont systemFontOfSize:18.0f]);
            cell.titleLabel.font should equal([UIFont systemFontOfSize:10.0f]);
        });
        
        it(@"should style the cells appropriately", ^{
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
            
            GrossPayHoursCell *cell = (id)[subject collectionView:subject.collectionView cellForItemAtIndexPath:firstItemIndexPath];
            cell.valueLabel.text should equal(@"$-29.85");
            cell.titleLabel.text should equal(@"Time Off3");
            cell.valueLabel.font should equal([UIFont systemFontOfSize:18.0f]);
            cell.titleLabel.font should equal([UIFont systemFontOfSize:10.0f]);
        });
    });
    
    context(@"should display collectionview with negative hours", ^{
        beforeEach(^{
            
            theme stub_method(@selector(legendsGrossPayFont)).and_return([UIFont systemFontOfSize:18.0f]);
            theme stub_method(@selector(legendsGrossPayHeaderFont)).and_return([UIFont systemFontOfSize:10.0f]);
            
            Paycode *paycode1 = [[Paycode alloc] initWithValue:@"-10h:30m" title:@"Regular Hours1" timeSeconds:nil];
            Paycode *paycode2 = [[Paycode alloc] initWithValue:@"6h:45m" title:@"Regular Hours2" timeSeconds:nil];
            Paycode *paycode3 = [[Paycode alloc] initWithValue:@"-3h:15m" title:@"Regular Hours3" timeSeconds:nil];
            [subject setupWithActualsByPayCodeDetails:@[paycode1, paycode2, paycode3]
                                                theme:theme
                                             delegate:delegate
                                scriptCalculationDate:nil];
            [subject.collectionView layoutIfNeeded];
            collectionView = subject.collectionView;
            spy_on(collectionView);
        });
        
        it(@"should reload the workhours collection view", ^{
            [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(3);
        });
        
        it(@"should style the cells appropriately", ^{
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            
            GrossPayHoursCell *cell = (id)[subject collectionView:subject.collectionView cellForItemAtIndexPath:firstItemIndexPath];
            cell.valueLabel.text should equal(@"-10h:30m");
            cell.titleLabel.text should equal(@"Regular Hours1");
            cell.valueLabel.font should equal([UIFont systemFontOfSize:18.0f]);
            cell.titleLabel.font should equal([UIFont systemFontOfSize:10.0f]);
        });
        
        it(@"should style the cells appropriately", ^{
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            
            GrossPayHoursCell *cell = (id)[subject collectionView:subject.collectionView cellForItemAtIndexPath:firstItemIndexPath];
            cell.valueLabel.text should equal(@"6h:45m");
            cell.titleLabel.text should equal(@"Regular Hours2");
            cell.valueLabel.font should equal([UIFont systemFontOfSize:18.0f]);
            cell.titleLabel.font should equal([UIFont systemFontOfSize:10.0f]);
        });
        
        it(@"should style the cells appropriately", ^{
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
            
            GrossPayHoursCell *cell = (id)[subject collectionView:subject.collectionView cellForItemAtIndexPath:firstItemIndexPath];
            cell.valueLabel.text should equal(@"-3h:15m");
            cell.titleLabel.text should equal(@"Regular Hours3");
            cell.valueLabel.font should equal([UIFont systemFontOfSize:18.0f]);
            cell.titleLabel.font should equal([UIFont systemFontOfSize:10.0f]);
        });
    });
    
    context(@"should display collectionview with Color codes", ^{
        beforeEach(^{
            
            theme stub_method(@selector(legendsGrossPayFont)).and_return([UIFont systemFontOfSize:18.0f]);
            theme stub_method(@selector(legendsGrossPayHeaderFont)).and_return([UIFont systemFontOfSize:10.0f]);
            
            Paycode *paycode1 = [[Paycode alloc] initWithValue:@"-10h:30m" title:@"Regular Hours1" timeSeconds:nil];
            Paycode *paycode2 = [[Paycode alloc] initWithValue:@"6h:45m" title:@"Regular Hours2" timeSeconds:nil];
            Paycode *paycode3 = [[Paycode alloc] initWithValue:@"-3h:15m" title:@"Regular Hours3" timeSeconds:nil];
            [subject setupWithActualsByPayCodeDetails:@[paycode1, paycode2, paycode3]
                                                theme:theme
                                             delegate:delegate
                                scriptCalculationDate:@"Some Text"];
            collectionView = subject.collectionView;
            spy_on(collectionView);
            [subject.view layoutIfNeeded];
            [subject viewWillAppear:NO];
        });
        
        it(@"should make the last update constraint height 25", ^{
            subject.lastUpdatedLabelHeightConstraint.constant should equal(25.0f);
        });
        
        it(@"should reload the workhours collection view", ^{
            [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(3);
        });
        
        it(@"should style the cells appropriately", ^{
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            
            GrossPayHoursCell *cell = (id)[subject collectionView:subject.collectionView cellForItemAtIndexPath:firstItemIndexPath];
            cell.valueLabel.text should equal(@"-10h:30m");
            cell.titleLabel.text should equal(@"Regular Hours1");
            cell.valueLabel.font should equal([UIFont systemFontOfSize:18.0f]);
            cell.titleLabel.font should equal([UIFont systemFontOfSize:10.0f]);

            cell.colorView.cornerRadius should equal(cell.colorView.frame.size.height/2);
            const CGFloat *components1 = CGColorGetComponents(cell.colorView.backgroundColor.CGColor);
            components1[0]*255 should equal(50); //red
            components1[1]*255 should equal(77); //green
            components1[2]*255 should equal(91); //blue

        });
        
        it(@"should style the cells appropriately", ^{
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            
            GrossPayHoursCell *cell = (id)[subject collectionView:subject.collectionView cellForItemAtIndexPath:firstItemIndexPath];
            cell.valueLabel.text should equal(@"6h:45m");
            cell.titleLabel.text should equal(@"Regular Hours2");
            cell.valueLabel.font should equal([UIFont systemFontOfSize:18.0f]);
            cell.titleLabel.font should equal([UIFont systemFontOfSize:10.0f]);
           
            cell.colorView.cornerRadius should equal(cell.colorView.frame.size.height/2);
            CGFloat red = 117.64999389648438f;
            CGFloat green = 135.739990234375f;
            CGFloat blue = 145.1199951171875f;

            const CGFloat *component2 = CGColorGetComponents(cell.colorView.backgroundColor.CGColor);
            component2[0]*255 should equal(red); //red
            component2[1]*255 should equal(green); //green
            component2[2]*255 should equal(blue); //blue

        });
        
        it(@"should style the cells appropriately", ^{
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
            
            GrossPayHoursCell *cell = (id)[subject collectionView:subject.collectionView cellForItemAtIndexPath:firstItemIndexPath];
            cell.valueLabel.text should equal(@"-3h:15m");
            cell.titleLabel.text should equal(@"Regular Hours3");
            cell.valueLabel.font should equal([UIFont systemFontOfSize:18.0f]);
            cell.titleLabel.font should equal([UIFont systemFontOfSize:10.0f]);
            
            cell.colorView.cornerRadius should equal(cell.colorView.frame.size.height/2);
            CGFloat red = 162.97549438476563;
            CGFloat green = 175.09579467773438;
            CGFloat blue = 181.38040161132813;
            
            const CGFloat *component3 = CGColorGetComponents(cell.colorView.backgroundColor.CGColor);
            component3[0]*255 should equal(red); //red
            component3[1]*255 should equal(green); //green
            component3[2]*255 should equal(blue); //blue

        });
    });
    

    
    context(@"Last Update Label and View More", ^{
        __block Paycode *paycode1;
        __block Paycode *paycode2;
        __block Paycode *paycode3;
        __block Paycode *paycode4;
        __block Paycode *paycode5;
        beforeEach(^{
            paycode1 = [[Paycode alloc] initWithValue:@"-10h:30m" title:@"Regular Hours1" timeSeconds:nil];
            paycode2 = [[Paycode alloc] initWithValue:@"6h:45m" title:@"Regular Hours2" timeSeconds:nil];
            paycode3 = [[Paycode alloc] initWithValue:@"-3h:15m" title:@"Regular Hours3" timeSeconds:nil];
            paycode4 = [[Paycode alloc] initWithValue:@"-3h:15m" title:@"Regular Hours3" timeSeconds:nil];
            paycode5 = [[Paycode alloc] initWithValue:@"-3h:15m" title:@"Regular Hours3" timeSeconds:nil];
        });
    describe(@"when scriptCalculationDate is nil", ^{
        
            beforeEach(^{
                [subject setupWithActualsByPayCodeDetails:@[paycode1, paycode2, paycode3, paycode4, paycode5]
                                                    theme:theme
                                                 delegate:delegate
                                    scriptCalculationDate:nil];
                [subject.view layoutIfNeeded];
                [subject viewWillAppear:NO];
            });
            
            it(@"should make the last update constraint height 0", ^{
                subject.lastUpdatedLabelHeightConstraint.constant should equal(0.0f);
            });
        it(@"should change button title", ^{
            subject.viewItemsButton.titleLabel.text  should equal(@"Show More");
        });
        
        it(@"should not display the last updated label text", ^{
            subject.lastUpdateTimeLabel.text should_not be_empty;
        });
        
        it(@"should set height for asterix label as 0", ^{
            subject.asterixHeightConstraint.constant should equal(0);
        });
    });
    
    describe(@"when scriptCalculationDate is not nil", ^{
        
        
            beforeEach(^{
                [subject setupWithActualsByPayCodeDetails:@[paycode1, paycode2]
                                                    theme:theme
                                                 delegate:delegate
                                    scriptCalculationDate:@"Data as of x date"];
                [subject.view layoutIfNeeded];
                [subject viewWillAppear:NO];
                
            });
            
        it(@"should make the last update constraint height 25", ^{
            subject.lastUpdatedLabelHeightConstraint.constant should equal(25.0f);
        });
        it(@"should display the last updated label text", ^{
            subject.lastUpdateTimeLabel.text should equal(@"Data as of x date");
        });
        
    });
    
    describe(@"when scriptCalculationDate is not nil and actuals array count greater than 4", ^{
        beforeEach(^{
                [subject setupWithActualsByPayCodeDetails:@[paycode1, paycode2]
                                                    theme:theme
                                                 delegate:delegate
                                    scriptCalculationDate:@"Some Text"];
            [subject.view layoutIfNeeded];
            [subject viewWillAppear:NO];
            
            });
            
            it(@"should make the last update constraint height 25", ^{
                subject.lastUpdatedLabelHeightConstraint.constant should equal(25.0f);
            });
        });
    

    describe(@"when scriptCalculationDate is not nil and actuals array count greater than 4 and action less", ^{
        
        context(@"should not show last updated label", ^{
            
            beforeEach(^{
                [subject setupWithActualsByPayCodeDetails:@[paycode1, paycode2, paycode3, paycode4, paycode5]
                                                    theme:theme
                                                 delegate:delegate
                                    scriptCalculationDate:@"Some Text"];
                [subject.view layoutIfNeeded];
                [subject viewWillAppear:NO];
                [subject.viewItemsButton tap];
                
            });
            it(@"delegate should have received grossPayTimeHomeViewControllerIntendsToUpdateHeight", ^{
                delegate should have_received(@selector(grossPayTimeHomeViewControllerIntendsToUpdateHeight:viewItem:)).with(0.0f,More);
            });
            it(@"should change button title", ^{
                subject.viewItemsButton.titleLabel.text  should equal(@"Show Less");
            });
            it(@"should make the last update constraint height non 25", ^{
                subject.lastUpdatedLabelHeightConstraint.constant should equal(25.0f);
            });
            
            it(@"should set height for asterix label", ^{
                subject.asterixHeightConstraint.constant should equal(21);
            });
        });
    });
});
    
    describe(@"check for gross pay controller", ^{
        __block GrossPayController *grossPayController;
        beforeEach(^{
            grossPayController = [[GrossPayController alloc] initWithChildControllerHelper:nil theme:nil];
            delegate stub_method(@selector(grossPayCollectionControllerNeedsGrossPay)).and_return(grossPayController);
            [subject setupWithActualsByPayCodeDetails:@[]
                                                theme:theme
                                             delegate:delegate
                                scriptCalculationDate:@"Some Text"];
            [subject viewDidLoad];
        });
        it(@"should be same instance of GrossPayController", ^{
            subject.grossPayHours should be_instance_of([GrossPayController class]);
        });
    });
    

    describe(@"check for gross hours controller", ^{
        __block GrossHoursController *grossHoursController;
        beforeEach(^{
            grossHoursController = [[GrossHoursController alloc] initWithChildControllerHelper:nil theme:nil];
            delegate stub_method(@selector(grossPayCollectionControllerNeedsGrossPay)).and_return(grossHoursController);
            [subject setupWithActualsByPayCodeDetails:@[]
                                                theme:theme
                                             delegate:delegate
                                scriptCalculationDate:@"Some Text"];
            [subject viewDidLoad];
        });
        it(@"should be same instance of GrossHoursController", ^{
            subject.grossPayHours should be_instance_of([GrossHoursController class]);
        });
    });
    
    describe(@"<GrossPayHours>", ^{
        beforeEach(^{
             grossPayHours = nice_fake_for(@protocol(GrossPayHours));
            delegate stub_method(@selector(grossPayCollectionControllerNeedsGrossPay)).and_return(grossPayHours);
            [subject setupWithActualsByPayCodeDetails:@[]
                                                theme:theme
                                             delegate:delegate
                                scriptCalculationDate:@"Some Text"];
            [subject viewDidLoad];
        });
        it(@"GrossPayHours protocol should not be nil", ^{
            subject.grossPayHours should_not be_nil;
        });
    });
    
});

SPEC_END
