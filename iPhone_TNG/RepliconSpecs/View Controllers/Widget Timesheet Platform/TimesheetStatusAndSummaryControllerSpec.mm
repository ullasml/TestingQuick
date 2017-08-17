


#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "UIControl+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetStatusAndSummaryControllerSpec)

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


describe(@"TimesheetStatusAndSummaryController", ^{
    __block TimesheetStatusAndSummaryController *subject;
    __block id <BSInjector,BSBinder> injector;
    __block ChildControllerHelper *childControllerHelper;
    __block TimesheetDetailsPresenter *timesheetDetailsPresenter;
    __block id <Theme> theme;
    __block WidgetTimesheet *widgetTimesheet;
    __block TimesheetPeriod *period;
    __block TimeSheetApprovalStatus *status;
    __block TimesheetDuration *timesheetDuration;
    __block id <TimesheetStatusAndSummaryControllerDelegate> delegate;
    __block TimesheetStatusAndIssuesController *timesheetStatusAndIssuesController;
    __block TimeSheetPermittedActions *timeSheetPermittedActions;
    
    
    beforeEach(^{
        timeSheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
        injector = [InjectorProvider injector];
        period = nice_fake_for([TimesheetPeriod class]);
        status = nice_fake_for([TimeSheetApprovalStatus class]);
        timesheetDuration = nice_fake_for([TimesheetDuration class]);
        delegate = nice_fake_for(@protocol(TimesheetStatusAndSummaryControllerDelegate));
        
        timesheetDetailsPresenter = nice_fake_for([TimesheetDetailsPresenter class]);
        theme = nice_fake_for(@protocol(Theme));
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        timesheetStatusAndIssuesController = nice_fake_for([TimesheetStatusAndIssuesController class]);
        [injector bind:[TimesheetStatusAndIssuesController class] toInstance:timesheetStatusAndIssuesController];
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        [injector bind:@protocol(Theme) toInstance:theme];
        [injector bind:[TimesheetDetailsPresenter class] toInstance:timesheetDetailsPresenter];
        
        subject = [injector getInstance:[TimesheetStatusAndSummaryController class]];
        Summary *summary = doSummarySubjectAction(status,timesheetDuration,nil,3,timeSheetPermittedActions,nil,@"Some date string",nil);
        widgetTimesheet = doSubjectAction(@"timesheet-uri", period,summary,nil,nil);
        
        timesheetDetailsPresenter stub_method(@selector(dateRangeTextWithTimesheetPeriod:)).with(period).and_return(@"my-timesheet-period-text");
        [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate];
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
                subject.violationsAndStatusButtonContainerView.backgroundColor should equal([UIColor magentaColor]);
                subject.updatedDateLabel.font should equal([UIFont systemFontOfSize:12.0f]);
            });
        });
        
        describe(@"presenting the TimesheetStatusAndIssuesController", ^{
            
            beforeEach(^{
                subject.view should_not be_nil;
            });
            
            it(@"should add the header button controller as its child", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(timesheetStatusAndIssuesController,subject,subject.violationsAndStatusButtonContainerView);
            });
            
            it(@"should configure the header button controller correctly", ^{
                timesheetStatusAndIssuesController should have_received(@selector(setupWithWidgetTimesheet:delegate:)).with(widgetTimesheet,subject);
            });
            
        });
        
        describe(@"presenting the last update recieved label", ^{
            context(@"when the last update is present", ^{
                beforeEach(^{
                    [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate];
                    subject.view should_not be_nil;
                });
                
                it(@"should show the last updated date correctly", ^{
                    subject.updatedDateLabel.text should equal(@"* Data as of Some date string");
                });
            });
            
            context(@"when the last update is absent", ^{
                beforeEach(^{
                    Summary *summary = [[Summary alloc]initWithTimesheetStatus:status
                                                   workBreakAndTimeoffDuration:timesheetDuration
                                                          violationsAndWaivers:nil
                                                                   issuesCount:3 
                                                     timeSheetPermittedActions:timeSheetPermittedActions
                                                         lastUpdatedDateString:nil
                                                                        status:nil 
                                           lastSuccessfulScriptCalculationDate:nil 
                                                                 payWidgetData:nil];
                    widgetTimesheet = doSubjectAction(@"timesheet-uri", period,summary,nil,nil);                    
                    [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate];
                    subject.view should_not be_nil;
                });
                
                it(@"should show the last updated date correctly", ^{
                    subject.view.subviews should_not contain(subject.updatedDateLabel);
                });
            });
            
        });
        
        
    });
    
    describe(@"As a <TimesheetStatusAndIssuesControllerDelegate>", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject timesheetStatusAndIssuesControllerIntendToViewViolationsWidget:(id)[NSNull null]];
        });
        
        it(@"should inform its delegate that user intends to view issues", ^{
            delegate should have_received(@selector(timesheetStatusAndSummaryControllerDidTapissuesButton:)).with(subject);
        });
    });
    
    describe(@"updates its height when view layouts", ^{
        
        beforeEach(^{
            subject.view should_not be_nil;
            [subject viewDidLayoutSubviews];
        });
        
        it(@"should request its delagte to update its container height constraint", ^{
            delegate should have_received(@selector(timesheetStatusAndSummaryControllerIntendsToUpdateItsContainerWithHeight:)).with(Arguments::anything);
            
        });
    });
    
});

SPEC_END
