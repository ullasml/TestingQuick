#import <Cedar/Cedar.h>
#import "DonutChartViewController.h"
#import "Paycode.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;
using namespace Cedar::Doubles::Arguments;


SPEC_BEGIN(DonutChartViewControllerSpec)

describe(@"DonutChartViewController", ^{
    __block id<Theme> theme;
    __block DonutChartViewController *subject;

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        subject = [[DonutChartViewController alloc]initWithTheme:theme];
        
    });

    describe(@"donut chart should be added as subview", ^{
        __block PNPieChart *donutChart;
        beforeEach(^{
            subject.view should_not be_nil;
           donutChart = subject.view.subviews.firstObject;
        });

        it(@"should add the donut chart view as a subview ", ^{
            subject.view.subviews.count should equal(1);
            donutChart should be_instance_of([PNPieChart class]);

        });


        it(@"correct properties set for donut chart", ^{
            donutChart.descriptionTextShadowColor should equal([UIColor clearColor]);
            donutChart.showAbsoluteValues should be_falsy;
            donutChart.showOnlyValues should be_truthy;
            donutChart.hideValues should be_truthy;
            donutChart.enableMultipleSelection should be_falsy;
            donutChart.shouldHighlightSectorOnTouch should be_falsy;
        });

    });

    describe(@"plotting donut chart for pay hours", ^{

        context(@"check for donutChart frame", ^{
            __block Paycode *payCode1;
            
            beforeEach(^{
                CGRect donutChartViewBounds = CGRectMake(0, 0, 242, 242);
                payCode1 = [[Paycode alloc] initWithValue:@"$3" title:@"Dollar" timeSeconds:nil];
                [subject setupWithActualsPayCode:@[payCode1] currencyDisplayText:nil donutChartViewBounds:donutChartViewBounds];
                [subject viewDidLoad];
               });
            
                it(@"correct height and width for donut chart should be set", ^{
                    subject.pieChart.bounds should equal(CGRectMake(0, 0, 242, 242));
                });
                
            
        });
        
        context(@"when all positive values present", ^{
            __block Paycode *payCode1;
            __block Paycode *payCode2;
            __block Paycode *payCode3;
            __block Paycode *payCode4;
            
            beforeEach(^{
                payCode1 = [[Paycode alloc] initWithValue:@"12h:2m" title:@"payCode1" timeSeconds:@"12h:2m:10s"];
                payCode2 = [[Paycode alloc] initWithValue:@"0h:59m" title:@"payCode2" timeSeconds:@"12h:2m:20s"];
                payCode3 = [[Paycode alloc] initWithValue:@"100h:05m" title:@"payCode3" timeSeconds:@"12h:2m:30s"];
                payCode4 = [[Paycode alloc] initWithValue:@"0h:0m" title:@"payCode4" timeSeconds:@"0h:0m:0s"];
                
                [subject setupWithActualsPayCode:@[payCode1,payCode2,payCode3,payCode4] currencyDisplayText:nil donutChartViewBounds:CGRectZero];
                [subject view];
            });


            
            it(@"items in donut chart should match", ^{

                subject.items.count should equal(4);

                PNPieChartDataItem *item1 = subject.items[0];
                PNPieChartDataItem *item2 = subject.items[1];
                PNPieChartDataItem *item3 = subject.items[2];
                PNPieChartDataItem *item4 = subject.items[3];


                item1.value should equal((CGFloat)12.036111111111111);
                const CGFloat *components1 = CGColorGetComponents(item1.color.CGColor);
                components1[0]*255 should equal(50); //red
                components1[1]*255 should equal(77); //green
                components1[2]*255 should equal(91); //blue


                item2.value should equal((CGFloat)12.03888888888889);
                const CGFloat *component2 = CGColorGetComponents(item2.color.CGColor);
                component2[0]*255 should equal(101.25); //red
                component2[1]*255 should equal(121.5); //green
                component2[2]*255 should equal(132); //blue


                item3.value should equal((CGFloat)12.041666666666666);
                const CGFloat *component3 = CGColorGetComponents(item3.color.CGColor);
                component3[0]*255 should equal(139.6875); //red
                component3[1]*255 should equal(154.875); //green
                component3[2]*255 should equal(162.75); //blue


                item4.value should equal(0);
                const CGFloat *component4 = CGColorGetComponents(item4.color.CGColor);
                component4[0]*255 should equal(168.515625); //red
                component4[1]*255 should equal(179.90625); //green
                component4[2]*255 should equal(185.8125); //blue



            });
        });

        context(@"when atleast one negative value present", ^{
            __block Paycode *payCode1;
            __block Paycode *payCode2;
            __block Paycode *payCode3;
            __block Paycode *payCode4;
            beforeEach(^{
                payCode1 = [[Paycode alloc] initWithValue:@"12h:2m" title:@"payCode1" timeSeconds:nil];
                payCode2 = [[Paycode alloc] initWithValue:@"-0h:59m" title:@"payCode2" timeSeconds:nil];
                payCode3 = [[Paycode alloc] initWithValue:@"100h:05m" title:@"payCode3" timeSeconds:nil];
                payCode4 = [[Paycode alloc] initWithValue:@"0h:0m" title:@"payCode4" timeSeconds:nil];

                [subject setupWithActualsPayCode:@[payCode1,payCode2,payCode3,payCode4] currencyDisplayText:nil donutChartViewBounds:CGRectZero];
                [subject view];

            });

            it(@"items in donut chart should match", ^{

                subject.items.count should equal(1);

                PNPieChartDataItem *item1 = subject.items[0];


                item1.value should equal(0);
                const CGFloat *components1 = CGColorGetComponents(item1.color.CGColor);
                components1[0]*255 should equal(221); //red
                components1[1]*255 should equal(223); //green
                components1[2]*255 should equal(224); //blue


            });
            
        });
        
        context(@"when total amounts to 0 hours", ^{
            __block Paycode *payCode1;
            __block Paycode *payCode2;

            beforeEach(^{
                payCode1 = [[Paycode alloc] initWithValue:@"0h:0m" title:@"payCode1" timeSeconds:nil];
                payCode2 = [[Paycode alloc] initWithValue:@"0h:0m" title:@"payCode2" timeSeconds:nil];

                [subject setupWithActualsPayCode:@[payCode1,payCode2] currencyDisplayText:nil donutChartViewBounds:CGRectZero];
                [subject view];

            });

            it(@"items in donut chart should match", ^{

                subject.items.count should equal(1);

                PNPieChartDataItem *item1 = subject.items[0];


                item1.value should equal(0);
                const CGFloat *components1 = CGColorGetComponents(item1.color.CGColor);
                components1[0]*255 should equal(221); //red
                components1[1]*255 should equal(223); //green
                components1[2]*255 should equal(224); //blue
                
                
            });
        });
        
        
    });

    describe(@"plotting donut chart for pay amounts", ^{

        context(@"when all positive values present", ^{
            __block Paycode *payCode1;
            __block Paycode *payCode2;
            __block Paycode *payCode3;
            __block Paycode *payCode4;
            beforeEach(^{
                payCode1 = [[Paycode alloc] initWithValue:@"USD$30.5" title:@"payCode1" timeSeconds:nil];
                payCode2 = [[Paycode alloc] initWithValue:@"USD$140.99" title:@"payCode2" timeSeconds:nil];
                payCode3 = [[Paycode alloc] initWithValue:@"USD$50" title:@"payCode3" timeSeconds:nil];
                payCode4 = [[Paycode alloc] initWithValue:@"USD$60.654" title:@"payCode4" timeSeconds:nil];

                [subject setupWithActualsPayCode:@[payCode1,payCode2,payCode3,payCode4] currencyDisplayText:@"USD$" donutChartViewBounds:CGRectZero];
                [subject view];
            });

            it(@"items in donut chart should match", ^{

                subject.items.count should equal(4);

                PNPieChartDataItem *item1 = subject.items[0];
                PNPieChartDataItem *item2 = subject.items[1];
                PNPieChartDataItem *item3 = subject.items[2];
                PNPieChartDataItem *item4 = subject.items[3];


                item1.value should equal(30.5);
                const CGFloat *components1 = CGColorGetComponents(item1.color.CGColor);
                components1[0]*255 should equal(50); //red
                components1[1]*255 should equal(77); //green
                components1[2]*255 should equal(91); //blue


                item2.value should equal((CGFloat)140.99);
                const CGFloat *component2 = CGColorGetComponents(item2.color.CGColor);
                component2[0]*255 should equal(101.25); //red
                component2[1]*255 should equal(121.5); //green
                component2[2]*255 should equal(132); //blue


                item3.value should equal(50.0);
                const CGFloat *component3 = CGColorGetComponents(item3.color.CGColor);
                component3[0]*255 should equal(139.6875); //red
                component3[1]*255 should equal(154.875); //green
                component3[2]*255 should equal(162.75); //blue


                item4.value should equal((CGFloat)60.654);
                const CGFloat *component4 = CGColorGetComponents(item4.color.CGColor);
                component4[0]*255 should equal(168.515625); //red
                component4[1]*255 should equal(179.90625); //green
                component4[2]*255 should equal(185.8125); //blue



            });
        });
        context(@"when atleast one negative value present", ^{
            __block Paycode *payCode1;
            __block Paycode *payCode2;
            __block Paycode *payCode3;
            __block Paycode *payCode4;
            beforeEach(^{
                payCode1 = [[Paycode alloc] initWithValue:@"$10.99" title:@"payCode1" timeSeconds:nil];
                payCode2 = [[Paycode alloc] initWithValue:@"$-0.5" title:@"payCode2" timeSeconds:nil];
                payCode3 = [[Paycode alloc] initWithValue:@"$60" title:@"payCode3" timeSeconds:nil];
                payCode4 = [[Paycode alloc] initWithValue:@"$012" title:@"payCode4" timeSeconds:nil];

                [subject setupWithActualsPayCode:@[payCode1,payCode2,payCode3,payCode4] currencyDisplayText:@"$" donutChartViewBounds:CGRectZero];
                [subject view];

            });

            it(@"items in donut chart should match", ^{

                subject.items.count should equal(1);

                PNPieChartDataItem *item1 = subject.items[0];


                item1.value should equal(0);
                const CGFloat *components1 = CGColorGetComponents(item1.color.CGColor);
                components1[0]*255 should equal(221); //red
                components1[1]*255 should equal(223); //green
                components1[2]*255 should equal(224); //blue


            });

        });

        context(@"when total amounts to 0 hours", ^{
            __block Paycode *payCode1;
            __block Paycode *payCode2;

            beforeEach(^{
                payCode1 = [[Paycode alloc] initWithValue:@"$0.0" title:@"payCode1" timeSeconds:nil];
                payCode2 = [[Paycode alloc] initWithValue:@"$0" title:@"payCode2" timeSeconds:nil];

                [subject setupWithActualsPayCode:@[payCode1,payCode2] currencyDisplayText:@"$" donutChartViewBounds:CGRectZero];
                [subject view];

            });

            it(@"items in donut chart should match", ^{

                subject.items.count should equal(1);

                PNPieChartDataItem *item1 = subject.items[0];


                item1.value should equal(0);
                const CGFloat *components1 = CGColorGetComponents(item1.color.CGColor);
                components1[0]*255 should equal(221); //red
                components1[1]*255 should equal(223); //green
                components1[2]*255 should equal(224); //blue
                
                
            });
        });

    });
});

SPEC_END
