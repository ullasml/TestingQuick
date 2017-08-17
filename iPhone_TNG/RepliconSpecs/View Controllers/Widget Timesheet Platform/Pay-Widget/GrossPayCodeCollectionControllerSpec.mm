#import <Cedar/Cedar.h>
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

SPEC_BEGIN(GrossPayCodeCollectionControllerSpec)


describe(@"GrossPayCodeCollectionController", ^{
    __block GrossPayCodeCollectionController *subject;
    __block UICollectionView *collectionView;
    __block id<Theme> theme;
    __block id<GrossPayCodeCollectionControllerDelegate> delegate;
    
    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        theme stub_method(@selector(legendsGrossPayFont)).and_return([UIFont systemFontOfSize:18.0f]);
        theme stub_method(@selector(legendsGrossPayHeaderFont)).and_return([UIFont systemFontOfSize:10.0f]);
        delegate = nice_fake_for(@protocol(GrossPayCodeCollectionControllerDelegate));
        subject = [[GrossPayCodeCollectionController alloc]initWithTheme:theme];
    });
    
    context(@"should display collectionview", ^{
        
        beforeEach(^{
            Paycode *paycode1 = [[Paycode alloc] initWithValue:@"$30" title:@"Time Off1" timeSeconds:nil];
            [subject setupWithActualsByPayCode:@[paycode1] delegate:delegate];
            subject.view should_not be_nil;
            collectionView = subject.collectionView;
            spy_on(collectionView);
        });
        
        afterEach(^{
            stop_spying_on(collectionView);
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
            Paycode *paycode1 = [[Paycode alloc] initWithValue:@"$-30.34" title:@"Time Off1" timeSeconds:nil];
            Paycode *paycode2 = [[Paycode alloc] initWithValue:@"$45.80" title:@"Time Off2" timeSeconds:nil];
            Paycode *paycode3 = [[Paycode alloc] initWithValue:@"$-29.85" title:@"Time Off3" timeSeconds:nil];
            [subject setupWithActualsByPayCode:@[paycode1, paycode2, paycode3]
                                             delegate:delegate];
            
            subject.view should_not be_nil;
            collectionView = subject.collectionView;
            spy_on(collectionView);
        });
        
        afterEach(^{
            stop_spying_on(collectionView);
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
    
            Paycode *paycode1 = [[Paycode alloc] initWithValue:@"-10h:30m" title:@"Regular Hours1" timeSeconds:nil];
            Paycode *paycode2 = [[Paycode alloc] initWithValue:@"6h:45m" title:@"Regular Hours2" timeSeconds:nil];
            Paycode *paycode3 = [[Paycode alloc] initWithValue:@"-3h:15m" title:@"Regular Hours3" timeSeconds:nil];
            [subject setupWithActualsByPayCode:@[paycode1, paycode2, paycode3]
                                             delegate:delegate];
            subject.view should_not be_nil;
            collectionView = subject.collectionView;
            spy_on(collectionView);
        });
        afterEach(^{
            stop_spying_on(collectionView);
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
            
            Paycode *paycode1 = [[Paycode alloc] initWithValue:@"-10h:30m" title:@"Regular Hours1" timeSeconds:nil];
            Paycode *paycode2 = [[Paycode alloc] initWithValue:@"6h:45m" title:@"Regular Hours2" timeSeconds:nil];
            Paycode *paycode3 = [[Paycode alloc] initWithValue:@"-3h:15m" title:@"Regular Hours3" timeSeconds:nil];
            [subject setupWithActualsByPayCode:@[paycode1, paycode2, paycode3]
                                             delegate:delegate];
            subject.view should_not be_nil;
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
    }) ;
    
    describe(@"should update its container height when view layouts", ^{
        
        beforeEach(^{
            Paycode *paycode1 = [[Paycode alloc] initWithValue:@"$30" title:@"Time Off1" timeSeconds:nil];
            [subject setupWithActualsByPayCode:@[paycode1] delegate:delegate];
            subject.view should_not be_nil;
            [subject.collectionView layoutIfNeeded];
            [subject viewDidLayoutSubviews];
        });
        
        it(@"should request its delagte to update its container height constraint", ^{
            delegate should have_received(@selector(grossPayCodeCollectionController:intendsToUpdateItsContainerWithHeight:)).with(subject,Arguments::anything);
        });
    });
    
});

SPEC_END
