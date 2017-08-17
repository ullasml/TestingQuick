#import <Cedar/Cedar.h>
#import "SupervisorTrendChartController.h"
#import "Theme.h"
#import "EmployeeClockInTrendSummaryRepository.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import <KSDeferred/KSDeferred.h>
#import "EmployeeClockInTrendSummary.h"
#import "EmployeeClockInTrendSummaryDataPoint.h"
#import "DateProvider.h"
#import "SupervisorTrendChartPlotView.h"
#import "InjectorKeys.h"
#import "SupervisorTrendChartPresenter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(SupervisorTrendChartControllerSpec)

describe(@"SupervisorTrendChartController", ^{

    __block EmployeeClockInTrendSummaryRepository *employeeClockInTrendSummaryRepository;
    beforeEach(^{
        employeeClockInTrendSummaryRepository = fake_for([EmployeeClockInTrendSummaryRepository class]);
        employeeClockInTrendSummaryRepository stub_method(@selector(fetchEmployeeClockInTrendSummary));
    });

    __block id<BSBinder, BSInjector> injector;
    __block SupervisorTrendChartController *subject;
    __block id<Theme> theme;
    __block DateProvider *dateProvider;
    __block SupervisorTrendChartPresenter *supervisorTrendChartPresenter;
    beforeEach(^{
        injector = [InjectorProvider injector];
        theme = nice_fake_for(@protocol(Theme));

        supervisorTrendChartPresenter = fake_for([SupervisorTrendChartPresenter class]);

        [injector bind:[EmployeeClockInTrendSummaryRepository class] toInstance:employeeClockInTrendSummaryRepository];
        [injector bind:[SupervisorTrendChartPresenter class] toInstance:supervisorTrendChartPresenter];
        [injector bind:[DateProvider class] toInstance:dateProvider];
        [injector bind:@protocol(Theme) toInstance:theme];

        subject = [injector getInstance:[SupervisorTrendChartController class]];
    });

    it(@"should have the correct header text", ^{
        subject.view should_not be_nil;
        subject.headerLabel.text should equal(RPLocalizedString(@"Employee Clock In Trend", @"Employee Clock In Trend"));
    });

    describe(@"presenting the employee clock in trend chart", ^{
        __block KSDeferred *employeeTrendSummaryDeferred;
        beforeEach(^{
            employeeTrendSummaryDeferred = [[KSDeferred alloc] init];
            employeeClockInTrendSummaryRepository stub_method(@selector(fetchEmployeeClockInTrendSummary)).again().and_return(employeeTrendSummaryDeferred.promise);

            subject.view should_not be_nil;
            [subject.view layoutIfNeeded];
            [subject viewWillAppear:NO];
        });

        it(@"should make a request for the employee clock in trend summary", ^{
            employeeClockInTrendSummaryRepository should have_received(@selector(fetchEmployeeClockInTrendSummary));
        });

        it(@"should set the y labels to blank while the chart is loading", ^{
            subject.topYLabel.text should equal(@"");
            subject.middleYLabel.text should equal(@"");
            subject.bottomYLabel.text should equal(@"");
        });

        it(@"should initially hide the no clockins label", ^{
            subject.noClockinsLabel.hidden should be_truthy;
        });

        context(@"When the employee clock in trend summary succeeds", ^{
            __block NSArray *valuesFromPresenter;

            context(@"when there are zero employees clocked in over the last 24 hours", ^{
                beforeEach(^{

                    NSDate *dateA = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
                    EmployeeClockInTrendSummaryDataPoint *dataPointA = [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:5 startDate:dateA];
                    NSDate *dateB = [NSDate dateWithTimeIntervalSinceReferenceDate:3600];
                    EmployeeClockInTrendSummaryDataPoint *dataPointB = [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:5 startDate:dateB];
                    NSArray *dataPoints = @[dataPointA, dataPointB];

                    valuesFromPresenter = @[@0, @0];
                    EmployeeClockInTrendSummary *employeeClockInTrendSummary = [[EmployeeClockInTrendSummary alloc] initWithDataPoints:dataPoints samplingIntervalSeconds:3600];

                    supervisorTrendChartPresenter stub_method(@selector(valuesForEmployeeClockInTrendSummary:)).with(employeeClockInTrendSummary).and_return(valuesFromPresenter);
                    supervisorTrendChartPresenter stub_method(@selector(maximumValueForDataPoints:)).with(dataPoints).and_return((NSInteger)0);
                    supervisorTrendChartPresenter stub_method(@selector(xLabelsForDataPoints:)).with(dataPoints).and_return(@[@"1 AM", @"2 AM"]);

                    [employeeTrendSummaryDeferred resolveWithValue:employeeClockInTrendSummary];
                });

                it(@"should set the y labels with non-zero default values", ^{
                    subject.topYLabel.text should equal(@"2");
                    subject.middleYLabel.text should equal(@"1");
                    subject.bottomYLabel.text should equal(@"0");
                });

                it(@"should show the no clockins label", ^{
                    subject.noClockinsLabel.hidden should be_falsy;
                    subject.noClockinsLabel.text should equal(RPLocalizedString(@"No Recent Clock-Ins",@""));
                });
            });

            context(@"when there are more than zero employees clocked in over the last 24 hours", ^{
                beforeEach(^{
                    theme stub_method(@selector(plotLabelFont)).and_return([UIFont italicSystemFontOfSize:42.f]);
                    theme stub_method(@selector(plotLabelTextColor)).and_return([UIColor magentaColor]);

                    spy_on(subject.chartView);

                    NSDate *dateA = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
                    EmployeeClockInTrendSummaryDataPoint *dataPointA = [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:5 startDate:dateA];
                    NSDate *dateB = [NSDate dateWithTimeIntervalSinceReferenceDate:3600];
                    EmployeeClockInTrendSummaryDataPoint *dataPointB = [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:5 startDate:dateB];
                    NSArray *dataPoints = @[dataPointA, dataPointB];

                    valuesFromPresenter = @[@1, @2];
                    EmployeeClockInTrendSummary *employeeClockInTrendSummary = [[EmployeeClockInTrendSummary alloc] initWithDataPoints:dataPoints samplingIntervalSeconds:3600];

                    supervisorTrendChartPresenter stub_method(@selector(valuesForEmployeeClockInTrendSummary:)).with(employeeClockInTrendSummary).and_return(valuesFromPresenter);
                    supervisorTrendChartPresenter stub_method(@selector(maximumValueForDataPoints:)).with(dataPoints).and_return((NSInteger)42);
                    supervisorTrendChartPresenter stub_method(@selector(xLabelsForDataPoints:)).with(dataPoints).and_return(@[@"1 AM", @"2 AM"]);

                    [employeeTrendSummaryDeferred resolveWithValue:employeeClockInTrendSummary];
                });

                it(@"should configure the plot view correctly", ^{
                    subject.chartView should have_received(@selector(updateWithValues:yScale:)).with(valuesFromPresenter, 42);
                });

                it(@"should set the yLabels appropriately", ^{
                    subject.topYLabel.text should equal(@"42");
                    subject.middleYLabel.text should equal(@"21");
                    subject.bottomYLabel.text should equal(@"0");
                });

                it(@"should hide the no clockins label", ^{
                    subject.noClockinsLabel.hidden should be_truthy;
                });

                describe(@"the x labels", ^{
                    __block NSMutableArray *xLabels;

                    beforeEach(^{
                        xLabels = [[NSMutableArray alloc] initWithCapacity:subject.scrollView.subviews.count];
                        for (UIView *subview in subject.scrollView.subviews)
                        {
                            if ([subview isKindOfClass:[UILabel class]])
                            {
                                [xLabels addObject:subview];
                            }
                        }
                    });

                    it(@"should create a label per hour", ^{
                        xLabels.count should equal(2);
                    });

                    it(@"should configure the labels correctly", ^{
                        UILabel *labelA = xLabels[0];
                        labelA.text should equal(@"1 AM");
                        labelA.font should equal([UIFont italicSystemFontOfSize:42.0f]);
                        labelA.textColor should equal([UIColor magentaColor]);

                        UILabel *labelB = xLabels[1];
                        labelB.text should equal(@"2 AM");
                        labelB.font should equal([UIFont italicSystemFontOfSize:42.0f]);
                        labelB.textColor should equal([UIColor magentaColor]);
                    });

                    it(@"should place the labels in order", ^{
                        UILabel *labelA = xLabels[0];
                        UILabel *labelB = xLabels[1];

                        labelA.frame.origin.x should be_less_than(labelB.frame.origin.x);
                    });

                    describe(@"when the view appears again and the trend promise is resolved", ^{
                        beforeEach(^{
                            employeeTrendSummaryDeferred = [[KSDeferred alloc] init];
                            employeeClockInTrendSummaryRepository stub_method(@selector(fetchEmployeeClockInTrendSummary)).again().and_return(employeeTrendSummaryDeferred.promise);

                            NSDate *dateA = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
                            EmployeeClockInTrendSummaryDataPoint *dataPointA = [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:5 startDate:dateA];
                            NSDate *dateB = [NSDate dateWithTimeIntervalSinceReferenceDate:3600];
                            EmployeeClockInTrendSummaryDataPoint *dataPointB = [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:5 startDate:dateB];
                            NSArray *dataPoints = @[dataPointA, dataPointB];

                            valuesFromPresenter = @[@1, @2];
                            EmployeeClockInTrendSummary *employeeClockInTrendSummary = [[EmployeeClockInTrendSummary alloc] initWithDataPoints:dataPoints samplingIntervalSeconds:3600];

                            supervisorTrendChartPresenter stub_method(@selector(valuesForEmployeeClockInTrendSummary:)).with(employeeClockInTrendSummary).and_return(valuesFromPresenter);
                            supervisorTrendChartPresenter stub_method(@selector(maximumValueForDataPoints:)).with(dataPoints).and_return((NSInteger)42);
                            supervisorTrendChartPresenter stub_method(@selector(xLabelsForDataPoints:)).with(dataPoints).and_return(@[@"3 AM", @"4 AM"]);

                            [subject viewWillAppear:NO];
                            [employeeTrendSummaryDeferred resolveWithValue:employeeClockInTrendSummary];
                        });

                        beforeEach(^{
                            xLabels = [[NSMutableArray alloc] initWithCapacity:subject.scrollView.subviews.count];
                            for (UIView *subview in subject.scrollView.subviews)
                            {
                                if ([subview isKindOfClass:[UILabel class]])
                                {
                                    [xLabels addObject:subview];
                                }
                            }
                        });

                        it(@"should create a label per hour", ^{
                            xLabels.count should equal(2);
                        });

                        it(@"should still have a plot", ^{
                            BOOL chartExists;

                            for (UIView *subview in subject.scrollView.subviews)
                            {
                                if ([subview isKindOfClass:[SupervisorTrendChartPlotView class]])
                                {
                                    chartExists = YES;
                                    break;
                                }
                            }
                            
                            chartExists should be_truthy;
                        });
                        
                        it(@"should configure the labels correctly", ^{
                            UILabel *labelA = xLabels[0];
                            labelA.text should equal(@"3 AM");
                            labelA.font should equal([UIFont italicSystemFontOfSize:42.0f]);
                            labelA.textColor should equal([UIColor magentaColor]);
                            
                            UILabel *labelB = xLabels[1];
                            labelB.text should equal(@"4 AM");
                            labelB.font should equal([UIFont italicSystemFontOfSize:42.0f]);
                            labelB.textColor should equal([UIColor magentaColor]);
                        });
                    });
                });
            });
        });
    });

    describe(@"styling the views", ^{
        beforeEach(^{
            theme stub_method(@selector(cardContainerBackgroundColor)).and_return([UIColor purpleColor]);
            theme stub_method(@selector(cardContainerBorderColor)).and_return([[UIColor magentaColor] CGColor]);
            theme stub_method(@selector(cardContainerBorderWidth)).and_return((CGFloat)12.0);
            theme stub_method(@selector(cardContainerHeaderColor)).and_return([UIColor greenColor]);
            theme stub_method(@selector(cardContainerHeaderFont)).and_return([UIFont italicSystemFontOfSize:17.0f]);

            theme stub_method(@selector(plotBarColor)).and_return([UIColor yellowColor]);
            theme stub_method(@selector(plotHorizontalLineColor)).and_return([UIColor brownColor]);
            theme stub_method(@selector(plotLabelFont)).and_return([UIFont systemFontOfSize:666.f]);
            theme stub_method(@selector(plotLabelTextColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(plotNoCheckinsLabelFont)).and_return([UIFont italicSystemFontOfSize:21.0f]);

            subject.view should_not be_nil;
        });

        it(@"should style the view", ^{
            subject.view.backgroundColor should equal([UIColor purpleColor]);
            subject.view.layer.borderColor should equal([[UIColor magentaColor] CGColor]);
            subject.view.layer.borderWidth should equal(12.0f);
        });

        it(@"should style the header label", ^{
            subject.headerLabel.textColor should equal([UIColor greenColor]);
            subject.headerLabel.font should equal([UIFont italicSystemFontOfSize:17.0f]);
        });

        it(@"should style the plot", ^{
            SupervisorTrendChartPlotView *plotView = subject.chartView;
            plotView.barColor should equal([UIColor yellowColor]);
        });

        it(@"should style the y-axis labels", ^{
            subject.topYLabel.font should equal([UIFont systemFontOfSize:666.f]);
            subject.middleYLabel.font should equal([UIFont systemFontOfSize:666.f]);
            subject.bottomYLabel.font should equal([UIFont systemFontOfSize:666.f]);

            subject.topYLabel.textColor should equal([UIColor orangeColor]);
            subject.middleYLabel.textColor should equal([UIColor orangeColor]);
            subject.bottomYLabel.textColor should equal([UIColor orangeColor]);
        });

        it(@"should style the chart lines", ^{
            subject.topLineView.backgroundColor should equal([UIColor brownColor]);
            subject.middleLineView.backgroundColor should equal([UIColor brownColor]);
            subject.bottomLineView.backgroundColor should equal([UIColor brownColor]);
        });

        it(@"should style the plot no checkins label", ^{
            subject.noClockinsLabel.font should equal([UIFont italicSystemFontOfSize:21.0f]);
            subject.noClockinsLabel.textColor should equal([UIColor orangeColor]);
        });
    });
});

SPEC_END
