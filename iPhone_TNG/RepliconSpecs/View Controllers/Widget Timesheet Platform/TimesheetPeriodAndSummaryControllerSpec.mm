#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "UIControl+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetPeriodAndSummaryControllerSpec)

WidgetTimesheet *(^doSubjectAction)(NSString *, TimesheetPeriod *,Summary *,NSArray *,TimesheetApprovalTimePunchCapabilities *) = ^(NSString *uri, TimesheetPeriod *period,Summary *summary,NSArray *metadata,TimesheetApprovalTimePunchCapabilities *capabilities){
    return [[WidgetTimesheet alloc]initWithUri:uri
                                        period:period
                                       summary:summary
                               widgetsMetaData:metadata
                 approvalTimePunchCapabilities:capabilities
                        canAutoSubmitOnDueDate:false
                              displayPayAmount:false 
                    canOwnerViewPayrollSummary:false
                              displayPayTotals:false
                             attestationStatus:Attested];
};

Summary *(^doSummarySubjectAction)(TimeSheetApprovalStatus *, TimesheetDuration *,AllViolationSections *,NSInteger,TimeSheetPermittedActions *, NSString *,NSString *,NSDate *) = ^(TimeSheetApprovalStatus *timesheetStatus, TimesheetDuration *duration,AllViolationSections *violationsAndWaivers,NSInteger issuesCount,TimeSheetPermittedActions *timeSheetPermittedActions, NSString *status,NSString *lastUpdatedString,NSDate *lastSuccessfulScriptCalculationDate){
    return [[Summary alloc]initWithTimesheetStatus:timesheetStatus
                       workBreakAndTimeoffDuration:duration
                              violationsAndWaivers:violationsAndWaivers
                                       issuesCount:issuesCount 
                         timeSheetPermittedActions:timeSheetPermittedActions
                             lastUpdatedDateString:lastUpdatedString
                                            status:status 
               lastSuccessfulScriptCalculationDate:lastSuccessfulScriptCalculationDate 
                                     payWidgetData:nil];
};


describe(@"TimesheetPeriodAndSummaryController", ^{
    __block TimesheetPeriodAndSummaryController *subject;
    __block id <BSInjector,BSBinder> injector;
    __block ChildControllerHelper *childControllerHelper;
    __block TimesheetDetailsPresenter *timesheetDetailsPresenter;
    __block id <Theme> theme;
    __block WidgetTimesheet *widgetTimesheet;
    __block TimesheetPeriod *period;
    __block TimeSheetApprovalStatus *status;
    __block TimesheetDuration *timesheetDuration;
    __block id <TimesheetPeriodAndSummaryControllerDelegate> delegate;
    __block id <TimesheetPeriodAndSummaryControllerNavigationDelegate> navigationDelegate;
    __block TimesheetStatusAndIssuesController *timesheetStatusAndIssuesController;
    __block TimeSheetPermittedActions *timeSheetPermittedActions;

    
    beforeEach(^{
        timeSheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
        injector = [InjectorProvider injector];
        period = nice_fake_for([TimesheetPeriod class]);
        status = nice_fake_for([TimeSheetApprovalStatus class]);
        timesheetDuration = nice_fake_for([TimesheetDuration class]);
        delegate = nice_fake_for(@protocol(TimesheetPeriodAndSummaryControllerDelegate));
        navigationDelegate = nice_fake_for(@protocol(TimesheetPeriodAndSummaryControllerNavigationDelegate));

        timesheetDetailsPresenter = nice_fake_for([TimesheetDetailsPresenter class]);
        theme = nice_fake_for(@protocol(Theme));
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        timesheetStatusAndIssuesController = nice_fake_for([TimesheetStatusAndIssuesController class]);
        [injector bind:[TimesheetStatusAndIssuesController class] toInstance:timesheetStatusAndIssuesController];
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        [injector bind:@protocol(Theme) toInstance:theme];
        [injector bind:[TimesheetDetailsPresenter class] toInstance:timesheetDetailsPresenter];

        subject = [injector getInstance:[TimesheetPeriodAndSummaryController class]];
        Summary *summary = doSummarySubjectAction(status,timesheetDuration,nil,3,timeSheetPermittedActions,nil,@"Some date string",nil);
        widgetTimesheet = doSubjectAction(@"timesheet-uri", period,summary,nil,nil);
        
        timesheetDetailsPresenter stub_method(@selector(dateRangeTextWithTimesheetPeriod:)).with(period).and_return(@"my-timesheet-period-text");
        [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate navigationDelegate:navigationDelegate];
    });
    
    describe(@"when the view loads", ^{
        
        describe(@"styling the views", ^{
            beforeEach(^{
                theme stub_method(@selector(timesheetDetailDateRangeFont)).and_return([UIFont italicSystemFontOfSize:15.0f]);
                theme stub_method(@selector(timesheetDetailCurrentPeriodFont)).and_return([UIFont boldSystemFontOfSize:14.0f]);
                theme stub_method(@selector(timesheetDetailCurrentPeriodTextColor)).and_return([UIColor redColor]);
                theme stub_method(@selector(timesheetDetailDateRangeTextColor)).and_return([UIColor greenColor]);
                theme stub_method(@selector(cardContainerBackgroundColor)).and_return([UIColor magentaColor]);
                theme stub_method(@selector(lastUpdateTimeFont)).and_return([UIFont systemFontOfSize:12.0f]);
                subject.view should_not be_nil;
            });
            
            it(@"should style the labels", ^{
                subject.dateRangeLabel.font should equal([UIFont italicSystemFontOfSize:15.0f]);
                subject.currentPeriodLabel.font should equal([UIFont boldSystemFontOfSize:14.0f]);
                subject.currentPeriodLabel.textColor should equal([UIColor redColor]);
                subject.dateRangeLabel.textColor should equal([UIColor greenColor]);
                
                subject.dateRangeLabel.backgroundColor should equal([UIColor clearColor]);
                subject.currentPeriodLabel.backgroundColor should equal([UIColor clearColor]);
                subject.nextTimesheetButton.backgroundColor should equal([UIColor clearColor]);
                subject.previousTimesheetButton.backgroundColor should equal([UIColor clearColor]);
            });
        });
        
        context(@"presenting the period of timesheet", ^{
            
            beforeEach(^{
                subject.view should_not be_nil;
                timesheetDetailsPresenter should have_received(@selector(dateRangeTextWithTimesheetPeriod:)).with(period);
            });
            
            it(@"should show the period corrcetly", ^{
                subject.dateRangeLabel.text should equal(@"my-timesheet-period-text *");
            });
            
        });
        
        context(@"presenting the current period title text ", ^{
            
            context(@"When timesheet is current timesheet", ^{
                
                beforeEach(^{
                    timesheetDetailsPresenter stub_method(@selector(isCurrentTimesheetForPeriod:)).with(period).and_return(YES);
                    subject.view should_not be_nil;
                    spy_on(subject.currentPeriodLabel);
                });
                
                afterEach(^{
                    stop_spying_on(subject.currentPeriodLabel);
                });
                
                it(@"should show the current timesheet title correctly", ^{
                    timesheetDetailsPresenter should have_received(@selector(isCurrentTimesheetForPeriod:)).with(period);
                    subject.currentPeriodLabel.text should equal(RPLocalizedString(@"Current Period", nil));
                });
            });
            
            context(@"When timesheet is not current timesheet", ^{
                beforeEach(^{
                    timesheetDetailsPresenter stub_method(@selector(isCurrentTimesheetForPeriod:)).with(period).and_return(NO);
                    subject.view should_not be_nil;
                    spy_on(subject.currentPeriodLabel);
                });
                
                afterEach(^{
                    stop_spying_on(subject.currentPeriodLabel);
                });
                
                it(@"should not show the current timesheet title", ^{
                    timesheetDetailsPresenter should have_received(@selector(isCurrentTimesheetForPeriod:)).with(period);
                    subject.view.subviews should_not contain(subject.currentPeriodLabel);
                });
            });
            
        });
        
        context(@"presenting the timesheet navigation buttons ", ^{
            
            context(@"When timesheet is current timesheet", ^{
                
                beforeEach(^{
                    timesheetDetailsPresenter stub_method(@selector(isCurrentTimesheetForPeriod:)).with(period).and_return(YES);
                    subject.view should_not be_nil;
                });
                
                it(@"should not both next timesheet button", ^{
                    subject.nextTimesheetButton.hidden should be_truthy;
                });
                
                it(@"should show previous timesheet button", ^{
                    subject.previousTimesheetButton.hidden should be_falsy;
                });
            });
            
            context(@"When timesheet is not current timesheet", ^{
                beforeEach(^{
                    timesheetDetailsPresenter stub_method(@selector(isCurrentTimesheetForPeriod:)).with(period).and_return(NO);
                    subject.view should_not be_nil;
                });
                
                it(@"should show next timesheet button", ^{
                    subject.nextTimesheetButton.hidden should be_falsy;
                });
                
                it(@"should show previous timesheet button", ^{
                    subject.previousTimesheetButton.hidden should be_falsy;
                });
            });
            
            context(@"tapping on the timesheet navigation button", ^{
                
                context(@"Whent next timesheet button is tapped ", ^{
                    beforeEach(^{
                        timesheetDetailsPresenter stub_method(@selector(isCurrentTimesheetForPeriod:)).with(period).and_return(NO);
                        subject.view should_not be_nil;
                        
                        [subject.nextTimesheetButton tap];
                    });
                    
                    it(@"should inform its delegate that user has tapped next timesheet button", ^{
                        navigationDelegate should have_received(@selector(timesheetPeriodAndSummaryControllerDidTapNextButton:)).with(subject);
                        //subject.nextTimesheetButton.isEnabled should be_falsy;

                    });
                });
                
                context(@"Whent previous timesheet button is tapped ", ^{
                    beforeEach(^{
                        timesheetDetailsPresenter stub_method(@selector(isCurrentTimesheetForPeriod:)).with(period).and_return(NO);
                        subject.view should_not be_nil;
                        
                        [subject.previousTimesheetButton tap];
                    });
                    
                    it(@"should inform its delegate that user has tapped previous timesheet button", ^{
                        navigationDelegate should have_received(@selector(timesheetPeriodAndSummaryControllerDidTapPreviousButton:)).with(subject);
                        //subject.previousTimesheetButton.isEnabled should be_falsy;
                    });
                });
            });
            
        });
    });
    
    describe(@"updates its height when view layouts", ^{
        
        beforeEach(^{
            subject.view should_not be_nil;
            [subject viewDidLayoutSubviews];
        });
        
        it(@"should request its delagte to update its container height constraint", ^{
            delegate should have_received(@selector(timesheetPeriodAndSummaryControllerIntendsToUpdateItsContainerWithHeight:)).with(Arguments::anything);
            
        });
    });
    
    describe(@"when the TimesheetPeriodAndSummaryControllerNavigationDelegate is nil", ^{
        
        beforeEach(^{
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate navigationDelegate:nil];
            subject.view should_not be_nil;

        });
        
        it(@"should hide the previous and next timesheet navigation buttons", ^{
            subject.previousTimesheetButton.hidden should be_truthy;
            subject.nextTimesheetButton.hidden should be_truthy;

        });

    });
    
});

SPEC_END
