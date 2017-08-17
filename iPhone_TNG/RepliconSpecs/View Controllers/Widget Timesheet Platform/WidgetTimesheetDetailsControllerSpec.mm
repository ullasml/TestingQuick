#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "UIControl+Spec.h"
#import "UIRefreshControl+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WidgetTimesheetDetailsControllerSpec)

WidgetTimesheet *(^doSubjectAction)(NSString *, TimesheetPeriod *,Summary *,NSArray *,TimesheetApprovalTimePunchCapabilities *,BOOL,BOOL,BOOL,AttestationStatus) = ^(NSString *uri, TimesheetPeriod *period,Summary *summary,NSArray *metadata,TimesheetApprovalTimePunchCapabilities *capabilities,BOOL displayPayAmount,BOOL canOwnerViewPayrollSummary,BOOL displayPayTotals,AttestationStatus attestationStatus){
    return [[WidgetTimesheet alloc]initWithUri:uri
                                        period:period
                                       summary:summary
                               widgetsMetaData:metadata
                 approvalTimePunchCapabilities:capabilities
                        canAutoSubmitOnDueDate:false
                              displayPayAmount:displayPayAmount 
                    canOwnerViewPayrollSummary:canOwnerViewPayrollSummary
                              displayPayTotals:displayPayTotals
                             attestationStatus:attestationStatus];
};

Summary *(^doSummarySubjectAction)(TimeSheetApprovalStatus *, TimesheetDuration *,AllViolationSections *,NSInteger,TimeSheetPermittedActions *, NSString *,NSString *,NSDate *,PayWidgetData *) = ^(TimeSheetApprovalStatus *timesheetStatus, TimesheetDuration *duration,AllViolationSections *violationsAndWaivers,NSInteger issuesCount,TimeSheetPermittedActions *timeSheetPermittedActions, NSString *status,NSString *lastUpdatedString,NSDate *lastSuccessfulScriptCalculationDate,PayWidgetData *payWidgetData){
    return [[Summary alloc]initWithTimesheetStatus:timesheetStatus
                       workBreakAndTimeoffDuration:duration
                              violationsAndWaivers:violationsAndWaivers
                                       issuesCount:issuesCount 
                         timeSheetPermittedActions:timeSheetPermittedActions
                             lastUpdatedDateString:lastUpdatedString
                                            status:status 
               lastSuccessfulScriptCalculationDate:lastSuccessfulScriptCalculationDate 
                                     payWidgetData:payWidgetData];
};

sharedExamplesFor(@"sharedContextForVerifyingContainerViewUserInteractions", ^(NSDictionary *sharedContext) {
    __block NSMutableArray *allContainers;
    __block WidgetTimesheetDetailsController *subject;
    __block BOOL shouldVerifyForIsEnabled;
    
    
    beforeEach(^{
        subject = sharedContext[@"subject"];
        shouldVerifyForIsEnabled = [sharedContext[@"shouldVerifyForIsEnabled"] boolValue];
        allContainers = [NSMutableArray arrayWithArray:@[subject.timesheetStatusAndSummaryContainerView,subject.timesheetDurationsSummaryContainerView]];
        [allContainers addObjectsFromArray:subject.widgetContainerViews];
    });
    
    
    it(@"should enable/disable all the containers", ^{
        for (UIView *container in allContainers) {
            if (shouldVerifyForIsEnabled){
                container.isUserInteractionEnabled should be_truthy;
                container.alpha should equal(1);
            }
            else{
                container.isUserInteractionEnabled should be_falsy;
                container.alpha should equal((CGFloat)0.7f);
            }
        }
    });
    
});

describe(@"WidgetTimesheetDetailsController", ^{
    __block WidgetTimesheetDetailsController *subject;
    __block id <BSInjector,BSBinder> injector;
    __block ChildControllerHelper <CedarDouble>*childControllerHelper;
    __block id <Theme> theme;
    __block WidgetTimesheet *widgetTimesheet;
    __block id <WidgetTimesheetDetailsControllerDelegate,CedarDouble> delegate;
    __block WidgetTimesheetSummaryRepository *widgetTimesheetSummaryRepository;
    __block WidgetTimesheetDetailsSeriesControllerPresenter <CedarDouble>*widgetTimesheetDetailsSeriesControllerPresenter;
    __block UserActionForTimesheetRepository *userActionForTimesheetRepository;
    __block TimeSheetPermittedActions *timeSheetPermittedActions;
    __block UIBarButtonItem *expectedRightBarButtonItem;
    __block UINavigationController *navigationController;
    __block UIBarButtonItem *barButtonItemWithActivity;
    __block TimeSheetApprovalStatus *intialTimesheetStatus;
    __block ViewHelper *viewHelper;
    __block TimesheetPeriodAndSummaryController *timesheetSummaryController;
    __block DurationSummaryWithoutOffsetController *durationsController;
    __block AllViolationSections *violationsAndWaivers;
    __block TimesheetStatusAndSummaryController *timesheetStatusAndSummaryController;
    __block NSDate *scriptCalculationDate;
    __block PunchWidgetRepository <CedarDouble>*punchWidgetRepository;
    __block TimesheetDuration *timesheetDuration;
    __block WidgetTimesheetRepository *widgetTimesheetRepository;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block UIRefreshControl *refresher;
    __block NoticeWidgetController *noticeWidgetController;
    __block AttestationWidgetController *attestationWidgetController;

    
    beforeEach(^{
        timesheetDuration = [[TimesheetDuration alloc]initWithRegularHours:nil
                                                                breakHours:nil
                                                              timeOffHours:nil];
        intialTimesheetStatus = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:timesheet-status:open"     
                                                                           approvalStatus:@"Some-value"];
        scriptCalculationDate = [NSDate dateWithTimeIntervalSince1970:0];
        injector = [InjectorProvider injector];
        barButtonItemWithActivity = [[UIBarButtonItem alloc]init];
        expectedRightBarButtonItem = [[UIBarButtonItem alloc]init];
        timeSheetPermittedActions = [[TimeSheetPermittedActions alloc]initWithCanSubmitOnDueDate:NO 
                                                                                       canReopen:true 
                                                                            canReSubmitTimeSheet:NO];
        
        
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        userPermissionsStorage stub_method(@selector(canViewPayDetails)).and_return(true);
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];

        
        noticeWidgetController = nice_fake_for([NoticeWidgetController class]);
        [injector bind:[NoticeWidgetController class] toInstance:noticeWidgetController];
        
        
        attestationWidgetController = nice_fake_for([AttestationWidgetController class]);
        [injector bind:[AttestationWidgetController class] toInstance:attestationWidgetController];
        
        widgetTimesheetSummaryRepository = nice_fake_for([WidgetTimesheetSummaryRepository class]);
        [injector bind:[WidgetTimesheetSummaryRepository class] toInstance:widgetTimesheetSummaryRepository];
        
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        
        punchWidgetRepository = nice_fake_for([PunchWidgetRepository class]);
        [injector bind:[PunchWidgetRepository class] toInstance:punchWidgetRepository];
        
        viewHelper = nice_fake_for([ViewHelper class]);
        [injector bind:[ViewHelper class] toInstance:viewHelper];
        
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        durationsController = nice_fake_for([DurationSummaryWithoutOffsetController class]);
        [injector bind:[DurationSummaryWithoutOffsetController class] toInstance:durationsController];
        
        timesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
        [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:timesheetSummaryController];
        
        timesheetStatusAndSummaryController = nice_fake_for([TimesheetStatusAndSummaryController class]);
        [injector bind:[TimesheetStatusAndSummaryController class] toInstance:timesheetStatusAndSummaryController];
        
        widgetTimesheetDetailsSeriesControllerPresenter = nice_fake_for([WidgetTimesheetDetailsSeriesControllerPresenter class]);
        [injector bind:[WidgetTimesheetDetailsSeriesControllerPresenter class] toInstance:widgetTimesheetDetailsSeriesControllerPresenter];
        
        userActionForTimesheetRepository = nice_fake_for([UserActionForTimesheetRepository class]);
        [injector bind:[UserActionForTimesheetRepository class] toInstance:userActionForTimesheetRepository];
        
        widgetTimesheetRepository = nice_fake_for([WidgetTimesheetRepository class]);
        [injector bind:[WidgetTimesheetRepository class] toInstance:widgetTimesheetRepository];

        refresher = [[UIRefreshControl alloc] init];
        [injector bind:InjectorKeyUIRefreshControl toInstance:refresher];

        subject = [injector getInstance:[WidgetTimesheetDetailsController class]];
        delegate = nice_fake_for(@protocol(WidgetTimesheetDetailsControllerDelegate));
        
        violationsAndWaivers = [[AllViolationSections alloc]initWithTotalViolationsCount:10 sections:@[]];;
        
        Summary *summary = doSummarySubjectAction(intialTimesheetStatus,timesheetDuration,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);
        
        widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);        
        widgetTimesheetDetailsSeriesControllerPresenter stub_method(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(timeSheetPermittedActions).and_return(expectedRightBarButtonItem);
        
        widgetTimesheetDetailsSeriesControllerPresenter stub_method(@selector(navigationBarRightButtonItemWithSpinner)).and_return(barButtonItemWithActivity);
        
        viewHelper stub_method(@selector(isViewControllerCurrentlyOnWindow:)).with(subject).and_return(YES);
        navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
        spy_on(navigationController);
    });
    
    afterEach(^{
        stop_spying_on(navigationController);
    });
    
    it(@"should add itself as observer to WidgetTimesheetSummaryRepository", ^{
        widgetTimesheetSummaryRepository should have_received(@selector(addListener:)).with(subject);
    });
    
    it(@"should set up widgetTimesheetDetailsSeriesControllerPresenter correctly", ^{
        widgetTimesheetDetailsSeriesControllerPresenter should have_received(@selector(setUpWithDelegate:)).with(subject);
    });
    
    describe(@"presenting the widget containers", ^{

        context(@"Removing unused widget containers", ^{
            __block KSDeferred *punchWidgetDeferred;
            __block UIStackView *stackView;
            
            beforeEach(^{
                punchWidgetDeferred = [[KSDeferred alloc]init];
                punchWidgetRepository stub_method(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"timesheet-uri").and_return(punchWidgetDeferred.promise);
                [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
                subject.view should_not be_nil;
                stackView = subject.stackView;
                spy_on(stackView);
                [subject viewDidAppear:true];
            });
            
            afterEach(^{
                stop_spying_on(stackView);
            });
            
            it(@"should remove the unused container view", ^{
                stackView should have_received(@selector(removeArrangedSubview:)).with(subject.widgetContainerViews[1]);
                stackView should have_received(@selector(removeArrangedSubview:)).with(subject.widgetContainerViews[2]);
            });
        });
        
        context(@"Presenting the Punch Widget Controller", ^{
            
            __block PlaceholderController *placeholderController;
            __block NSArray *widgetMetadata;
            
            beforeEach(^{
                
                placeholderController = nice_fake_for([PlaceholderController class]);
                [injector bind:[PlaceholderController class] toInstance:placeholderController];
                
                WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:nil
                                                                          timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"];
                widgetMetadata = @[punchWidgetData];
                Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);
                widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,false,false,false,Attested);
                [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
            });
            
            __block KSDeferred *punchWidgetDeferred;
            
            beforeEach(^{
                punchWidgetDeferred = [[KSDeferred alloc]init];
                punchWidgetRepository stub_method(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"timesheet-uri").and_return(punchWidgetDeferred.promise);
                subject.view should_not be_nil;
            });
            
            
            it(@"should add PlaceholderController as a child controller to WidgetTimesheetDetailsController", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(placeholderController,subject,subject.widgetContainerViews[0]);
            });
            
            it(@"should ask the punch widget repository for the punch widget info", ^{
                punchWidgetRepository should have_received(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"timesheet-uri");
            });
            
            it(@"should correctly set up PlaceholderController", ^{
                placeholderController should have_received(@selector(setUpWithDelegate:widgetUri:)).with(subject,@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry");
            });
            
            context(@"when the punch widget promise succeeds intially", ^{
                __block TimesheetInfo *timesheetInfo;
                __block NSArray *dayTimeSummaries;
                __block PunchWidgetTimesheetBreakdownController *punchWidgetTimesheetBreakdownController;
                __block PunchWidgetData *expectedPunchWidgetData;
                
                beforeEach(^{
                    punchWidgetTimesheetBreakdownController = nice_fake_for([PunchWidgetTimesheetBreakdownController class]);
                    [injector bind:[PunchWidgetTimesheetBreakdownController class] toInstance:punchWidgetTimesheetBreakdownController];
                    
                    TimesheetDaySummary *timesheetDaySummaryA = nice_fake_for([TimesheetDaySummary class]);
                    TimesheetDaySummary *timesheetDaySummaryB = nice_fake_for([TimesheetDaySummary class]);
                    dayTimeSummaries = @[timesheetDaySummaryA,timesheetDaySummaryB];
                    TimePeriodSummary *timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                    timePeriodSummary stub_method(@selector(dayTimeSummaries)).and_return(dayTimeSummaries);
                    
                    NSDateComponents *regularTimeComponents = [[NSDateComponents alloc]init];
                    regularTimeComponents.hour = 1;
                    regularTimeComponents.minute = 2;
                    regularTimeComponents.second = 3;
                    
                    NSDateComponents *breakTimeComponents = [[NSDateComponents alloc]init];
                    breakTimeComponents.hour = 4;
                    breakTimeComponents.minute = 5;
                    breakTimeComponents.second = 6;
                    
                    NSDateComponents *timeoffComponents = [[NSDateComponents alloc]init];
                    timeoffComponents.hour = 7;
                    timeoffComponents.minute = 8;
                    timeoffComponents.second = 9;
                    
                    timePeriodSummary stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
                    timePeriodSummary stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                    timePeriodSummary stub_method(@selector(timeOffComponents)).and_return(timeoffComponents);
                    
                    timesheetInfo = nice_fake_for([TimesheetInfo class]);
                    timesheetInfo stub_method(@selector(timePeriodSummary)).and_return(timePeriodSummary);
                    
                    TimesheetDuration *timesheetDuration = [[TimesheetDuration alloc]initWithRegularHours:regularTimeComponents
                                                                                               breakHours:breakTimeComponents
                                                                                             timeOffHours:timeoffComponents];
                    expectedPunchWidgetData = [[PunchWidgetData alloc]initWithDaySummaries:dayTimeSummaries
                                                                       widgetLevelDuration:timesheetDuration];
                    [punchWidgetDeferred resolveWithValue:timesheetInfo];
                });
                
                it(@"should add PunchWidgetTimesheetBreakdownController as a child controller to WidgetTimesheetDetailsController", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(placeholderController,punchWidgetTimesheetBreakdownController,subject,subject.widgetContainerViews[0]);
                });
                
                it(@"should update the WidgetTimesheet with the Punch Meta Data", ^{
                    WidgetData *widgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:expectedPunchWidgetData timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"];
                    subject.widgetTimesheet.widgetsMetaData[0] should equal(widgetData);
                });
                
                it(@"should correctly set up PunchWidgetTimesheetBreakdownController", ^{
                    punchWidgetTimesheetBreakdownController should have_received(@selector(setupWithPunchWidgetData:delegate:hasBreakAccess:)).with(expectedPunchWidgetData,subject,YES);
                });
            });
            
            context(@"needsTimePunchesPromiseWhenUserEditOrAddOrDeletePunchForDayController", ^{
                __block PlaceholderController *placeholderController;
                __block KSPromise *expectedTimesheetSummaryPromise;
                __block Summary *summary;
                __block AllViolationSections *violationsAndWaivers;
                __block TimeSheetPermittedActions *newestPermittedActions;
                __block UIBarButtonItem *newestRightBarButtonItem;
                __block NSDate *newScriptCalculationDate;
                __block KSDeferred *summaryDeferred;
                __block KSDeferred *intialPunchWidgetDeferred;
                beforeEach(^{
                    summaryDeferred = [[KSDeferred alloc]init];
                    intialPunchWidgetDeferred = [[KSDeferred alloc]init];
                    punchWidgetRepository stub_method(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"timesheet-uri").again().and_return(intialPunchWidgetDeferred.promise);
                    newScriptCalculationDate = [NSDate dateWithTimeIntervalSince1970:1];
                    violationsAndWaivers = nice_fake_for([AllViolationSections class]);
                    newestPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                    summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,newestPermittedActions,nil,nil,newScriptCalculationDate,nil);
                    placeholderController = nice_fake_for([PlaceholderController class]);
                    [injector bind:[PlaceholderController class] toInstance:placeholderController];
                    [punchWidgetRepository reset_sent_messages];
                    
                    widgetTimesheetSummaryRepository stub_method(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet).and_return(summaryDeferred.promise);
                    
                    punchWidgetRepository stub_method(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"timesheet-uri").again().and_return(intialPunchWidgetDeferred.promise);

                    expectedTimesheetSummaryPromise = [subject needsTimePunchesPromiseWhenUserEditOrAddOrDeletePunchForDayController:(id)[NSNull null]];
                });
                
                it(@"should ask the punch widget repository for the punch widget info", ^{
                    punchWidgetRepository should have_received(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"timesheet-uri");
                });
                
                it(@"should fetch the newest timesheet summary", ^{
                    widgetTimesheetSummaryRepository should have_received(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet);
                });
                
                it(@"should not set up PlaceholderController", ^{
                    placeholderController should_not have_received(@selector(setUpWithDelegate:widgetUri:)).with(subject,@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry");
                });
                
                context(@"when the punch widget promise succeeds when view did appears", ^{
                    
                    __block TimesheetInfo *timesheetInfo;
                    __block NSArray *dayTimeSummaries;
                    __block PunchWidgetTimesheetBreakdownController *punchWidgetTimesheetBreakdownController;
                    __block PunchWidgetData *expectedPunchWidgetData;
                    __block TimesheetPeriodAndSummaryController *newTimesheetSummaryController;
                    
                    beforeEach(^{
                        newTimesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
                        [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:newTimesheetSummaryController];
                        
                        widgetTimesheetDetailsSeriesControllerPresenter stub_method(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(newestPermittedActions).and_return(newestRightBarButtonItem);
                        
                        [summaryDeferred resolveWithValue:summary];
                    });
                    
                    beforeEach(^{
                        punchWidgetTimesheetBreakdownController = nice_fake_for([PunchWidgetTimesheetBreakdownController class]);
                        [injector bind:[PunchWidgetTimesheetBreakdownController class] toInstance:punchWidgetTimesheetBreakdownController];
                        
                        TimesheetDaySummary *timesheetDaySummaryA = nice_fake_for([TimesheetDaySummary class]);
                        TimesheetDaySummary *timesheetDaySummaryB = nice_fake_for([TimesheetDaySummary class]);
                        dayTimeSummaries = @[timesheetDaySummaryA,timesheetDaySummaryB];
                        TimePeriodSummary *timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                        timePeriodSummary stub_method(@selector(dayTimeSummaries)).and_return(dayTimeSummaries);
                        
                        NSDateComponents *regularTimeComponents = [[NSDateComponents alloc]init];
                        regularTimeComponents.hour = 1;
                        regularTimeComponents.minute = 2;
                        regularTimeComponents.second = 3;
                        
                        NSDateComponents *breakTimeComponents = [[NSDateComponents alloc]init];
                        breakTimeComponents.hour = 4;
                        breakTimeComponents.minute = 5;
                        breakTimeComponents.second = 6;
                        
                        NSDateComponents *timeoffComponents = [[NSDateComponents alloc]init];
                        timeoffComponents.hour = 7;
                        timeoffComponents.minute = 8;
                        timeoffComponents.second = 9;
                        
                        timePeriodSummary stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
                        timePeriodSummary stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                        timePeriodSummary stub_method(@selector(timeOffComponents)).and_return(timeoffComponents);
                        
                        timesheetInfo = nice_fake_for([TimesheetInfo class]);
                        timesheetInfo stub_method(@selector(timePeriodSummary)).and_return(timePeriodSummary);
                        
                        TimesheetDuration *timesheetDuration = [[TimesheetDuration alloc]initWithRegularHours:regularTimeComponents
                                                                                                   breakHours:breakTimeComponents
                                                                                                 timeOffHours:timeoffComponents];
                        expectedPunchWidgetData = [[PunchWidgetData alloc]initWithDaySummaries:dayTimeSummaries
                                                                           widgetLevelDuration:timesheetDuration];
                        [intialPunchWidgetDeferred resolveWithValue:timesheetInfo];
                    });
                    
                    beforeEach(^{
                        [childControllerHelper reset_sent_messages];
                        [punchWidgetRepository reset_sent_messages];
                        punchWidgetTimesheetBreakdownController = nice_fake_for([PunchWidgetTimesheetBreakdownController class]);
                        [injector bind:[PunchWidgetTimesheetBreakdownController class] toInstance:punchWidgetTimesheetBreakdownController];
                    });
                    
                    context(@"when the view is currently on window", ^{
                        
                        beforeEach(^{
                            viewHelper stub_method(@selector(isViewControllerCurrentlyOnWindow:)).with(subject).again().and_return(YES);
                            [subject viewDidAppear:true];

                        });
                        it(@"should not ask the punch widget repository for the punch widget info", ^{
                            punchWidgetRepository should_not have_received(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"timesheet-uri");
                        });
                        
                        it(@"should add PunchWidgetTimesheetBreakdownController as a child controller to WidgetTimesheetDetailsController", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,punchWidgetTimesheetBreakdownController,subject,subject.widgetContainerViews[0]);
                        });
                        
                        it(@"should update the WidgetTimesheet with the Punch Meta Data", ^{
                            WidgetData *widgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:expectedPunchWidgetData timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"];
                            subject.widgetTimesheet.widgetsMetaData[0] should equal(widgetData);
                        });
                        
                        it(@"should correctly set up PunchWidgetTimesheetBreakdownController", ^{
                            punchWidgetTimesheetBreakdownController should have_received(@selector(setupWithPunchWidgetData:delegate:hasBreakAccess:)).with(expectedPunchWidgetData,subject,YES);
                        });
                    });
                    
                    context(@"when the view is currently not on window", ^{

                        beforeEach(^{
                            viewHelper stub_method(@selector(isViewControllerCurrentlyOnWindow:)).with(subject).again().and_return(NO);
                            [subject viewDidAppear:true];
                            
                        });
                        
                        it(@"should add PunchWidgetTimesheetBreakdownController as a child controller to WidgetTimesheetDetailsController", ^{
                            childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,punchWidgetTimesheetBreakdownController,subject,subject.widgetContainerViews[0]);
                        });
                        
                        it(@"should update the WidgetTimesheet with the Punch Meta Data", ^{
                            WidgetData *widgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:expectedPunchWidgetData timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"];
                            subject.widgetTimesheet.widgetsMetaData[0] should equal(widgetData);
                        });
                        
                        it(@"should correctly set up PunchWidgetTimesheetBreakdownController", ^{
                            punchWidgetTimesheetBreakdownController should_not have_received(@selector(setupWithPunchWidgetData:delegate:hasBreakAccess:));
                        });
                    });
                    

                });
                
            });
        });
        
        context(@"Presenting the Pay Widget Controller", ^{
            __block PayWidgetHomeController *payWidgetHomeController;
            __block PayWidgetData *payWidgetData;
            beforeEach(^{
                payWidgetHomeController = nice_fake_for([PayWidgetHomeController class]);
                [injector bind:[PayWidgetHomeController class] toInstance:payWidgetHomeController];
            });
            
            context(@"when pay widget needs to be shown", ^{
                beforeEach(^{
                    
                    Paycode *payCode = nice_fake_for([Paycode class]);
                    payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:nil actualsByPaycode:@[payCode] actualsByDuration:@[payCode]];
                    WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:payWidgetData
                                                                              timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"];
                    NSArray *widgetMetadata = @[punchWidgetData];
                    Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,payWidgetData);
                    widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,true,true,false,Attested);
                });
                
                context(@"when in usercontext", ^{
                    beforeEach(^{
                        [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
                        subject.view should_not be_nil;
                        [subject viewDidAppear:true];
                    });
                    
                    it(@"should add PayWidgetHomeController as a child controller to WidgetTimesheetDetailsController", ^{
                        childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(payWidgetHomeController,subject,subject.widgetContainerViews[0]);
                    });
                    it(@"should correctly set up payWidgetHomeController", ^{
                        payWidgetHomeController should have_received(@selector(setupWithPayWidgetData:displayPayAmount:displayPayTotals:delegate:)).with(payWidgetData,YES,NO,subject);
                    });
                });
                
                context(@"when in supervisorcontext", ^{
                    beforeEach(^{
                        [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
                        subject.view should_not be_nil;
                        [subject viewDidAppear:true];
                    });
                    
                    it(@"should add PayWidgetHomeController as a child controller to WidgetTimesheetDetailsController", ^{
                        childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(payWidgetHomeController,subject,subject.widgetContainerViews[0]);
                    });
                    it(@"should correctly set up payWidgetHomeController", ^{
                        payWidgetHomeController should have_received(@selector(setupWithPayWidgetData:displayPayAmount:displayPayTotals:delegate:)).with(payWidgetData,YES,NO,subject);
                    });
                });
                
                context(@"when displayPayTotals is truthy", ^{
                    beforeEach(^{  
                        Paycode *payCode = nice_fake_for([Paycode class]);
                        payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:nil actualsByPaycode:@[payCode] actualsByDuration:@[payCode]];
                        WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:payWidgetData
                                                                                  timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"];
                        NSArray *widgetMetadata = @[punchWidgetData];
                        Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,payWidgetData);;
                        widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,true,true,true,Attested);
                        [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];

                        subject.view should_not be_nil;
                        [subject viewDidAppear:true];
                    
                    });
                    
                    it(@"should add PayWidgetHomeController as a child controller to WidgetTimesheetDetailsController", ^{
                        childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(payWidgetHomeController,subject,subject.widgetContainerViews[0]);
                    });
                    it(@"should correctly set up payWidgetHomeController", ^{
                        payWidgetHomeController should have_received(@selector(setupWithPayWidgetData:displayPayAmount:displayPayTotals:delegate:)).with(payWidgetData,YES,YES,subject);
                    });
                });
                
                context(@"when displayPayTotals is falsy", ^{
                    beforeEach(^{
                        [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
                        subject.view should_not be_nil;
                        [subject viewDidAppear:true];
                    });
                    
                    it(@"should add PayWidgetHomeController as a child controller to WidgetTimesheetDetailsController", ^{
                        childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(payWidgetHomeController,subject,subject.widgetContainerViews[0]);
                    });
                    it(@"should correctly set up payWidgetHomeController", ^{
                        payWidgetHomeController should have_received(@selector(setupWithPayWidgetData:displayPayAmount:displayPayTotals:delegate:)).with(payWidgetData,YES,NO,subject);
                    });
                });
                
                context(@"when actualsByDuration is absent and actualsByPaycode is present", ^{
                    beforeEach(^{
                        Paycode *payCode = nice_fake_for([Paycode class]);
                        payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:nil actualsByPaycode:@[payCode] actualsByDuration:nil];
                        WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:payWidgetData
                                                                                  timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"];
                        NSArray *widgetMetadata = @[punchWidgetData];
                        Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,payWidgetData);;
                        widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,true,true,false,Attested);
                        [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
                        subject.view should_not be_nil;
                        [subject viewDidAppear:true];
                    });
                    
                    it(@"should not add PayWidgetHomeController as a child controller to WidgetTimesheetDetailsController", ^{
                        childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.widgetContainerViews[0]);
                    });
                    it(@"should not set up payWidgetHomeController", ^{
                        payWidgetHomeController should have_received(@selector(setupWithPayWidgetData:displayPayAmount:displayPayTotals:delegate:));
                    });
                });
                
                context(@"when actualsByDuration is absent and actualsByPaycode is present", ^{
                    beforeEach(^{
                        Paycode *payCode = nice_fake_for([Paycode class]);
                        payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:nil actualsByPaycode:nil actualsByDuration:@[payCode]];
                        WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:payWidgetData
                                                                                  timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"];
                        NSArray *widgetMetadata = @[punchWidgetData];
                        Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,payWidgetData);;
                        widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,true,true,false,Attested);
                        [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
                        subject.view should_not be_nil;
                        [subject viewDidAppear:true];
                    });
                    
                    it(@"should not add PayWidgetHomeController as a child controller to WidgetTimesheetDetailsController", ^{
                        childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(payWidgetHomeController,subject,subject.widgetContainerViews[0]);
                    });
                    it(@"should not set up payWidgetHomeController", ^{
                        payWidgetHomeController should have_received(@selector(setupWithPayWidgetData:displayPayAmount:displayPayTotals:delegate:));
                    });
                });
            });
            
            context(@"when pay widget need not  be shown", ^{
                
                
                
                context(@"when both actualsByDuration and actualsByPaycode is absent ", ^{
                    beforeEach(^{
                        payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:nil actualsByPaycode:nil actualsByDuration:nil];
                        WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:payWidgetData
                                                                                  timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"];
                        NSArray *widgetMetadata = @[punchWidgetData];
                        Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,payWidgetData);;
                        widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,true,true,false,Attested);
                        [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
                        subject.view should_not be_nil;
                        [subject viewDidAppear:true];
                    });
                    
                    it(@"should not add PayWidgetHomeController as a child controller to WidgetTimesheetDetailsController", ^{
                        childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.widgetContainerViews[0]);
                    });
                    it(@"should not set up payWidgetHomeController", ^{
                        payWidgetHomeController should_not have_received(@selector(setupWithPayWidgetData:displayPayAmount:displayPayTotals:delegate:));
                    });
                });
                
                context(@"when canViewPayrollSummary is falsy", ^{
                    beforeEach(^{
                        Paycode *payCode = nice_fake_for([Paycode class]);
                        payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:nil actualsByPaycode:nil actualsByDuration:@[payCode]];
                        WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:payWidgetData
                                                                                  timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"];
                        NSArray *widgetMetadata = @[punchWidgetData];
                        Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,payWidgetData);;
                        widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,true,false,false,Attested);
                        [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
                        subject.view should_not be_nil;
                        [subject viewDidAppear:true];
                    });
                    
                    it(@"should not add PayWidgetHomeController as a child controller to WidgetTimesheetDetailsController", ^{
                        childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.widgetContainerViews[0]);
                    });
                    it(@"should not set up payWidgetHomeController", ^{
                        payWidgetHomeController should_not have_received(@selector(setupWithPayWidgetData:displayPayAmount:displayPayTotals:delegate:));
                    });
                });
            });
            
        });
        
        context(@"Presenting the notice widget", ^{
            __block NSArray *widgetMetadata;
            beforeEach(^{
                NoticeWidgetData *noticeWidgetData = [[NoticeWidgetData alloc]initWithTitle:@"some-title" description:@"some-description"];
                WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:noticeWidgetData
                                                                          timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:notice"];
                widgetMetadata = @[punchWidgetData];
                Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);
                widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,false,false,false,Attested);
                [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
                
                subject.view should_not be_nil;
                [subject viewDidAppear:true];
            });
            
            it(@"should add NoticeWidgetController as a child controller to WidgetTimesheetDetailsController", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(noticeWidgetController,subject,subject.widgetContainerViews[0]);
            });
            it(@"should correctly set up NoticeWidgetController", ^{
                noticeWidgetController should have_received(@selector(setupWithTitle:description:delegate:)).with(@"some-title",@"some-description",subject);
            });

        });
        
        context(@"Presenting the attestation widget", ^{
            __block NSArray *widgetMetadata;
            
            context(@"when attestation status is Attested", ^{
                
                beforeEach(^{
                    AttestationWidgetData *noticeWidgetData = [[AttestationWidgetData alloc]initWithTitle:@"some-title" description:@"some-description"];
                    WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:noticeWidgetData
                                                                              timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:attestation"];
                    widgetMetadata = @[punchWidgetData];
                    Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);
                    widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,false,false,false,Attested);
                    [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
                    
                    subject.view should_not be_nil;
                    [subject viewDidAppear:true];
                });
                
                it(@"should add AttestationWidgetController as a child controller to WidgetTimesheetDetailsController", ^{
                    childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(attestationWidgetController,subject,subject.widgetContainerViews[0]);
                });
                it(@"should correctly set up AttestationWidgetController", ^{
                    attestationWidgetController should have_received(@selector(setupWithTitle:description:status:delegate:)).with(@"some-title",@"some-description",Attested,subject);
                });
                
            });
            
            context(@"when attestation status is Unattested", ^{
                beforeEach(^{
                    AttestationWidgetData *noticeWidgetData = [[AttestationWidgetData alloc]initWithTitle:@"some-title" description:@"some-description"];
                    WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:noticeWidgetData
                                                                              timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:attestation"];
                    widgetMetadata = @[punchWidgetData];
                    Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);
                    widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,false,false,false,Unattested);
                    [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
                    
                    subject.view should_not be_nil;
                    [subject viewDidAppear:true];
                });
                
                it(@"should add AttestationWidgetController as a child controller to WidgetTimesheetDetailsController", ^{
                    childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(attestationWidgetController,subject,subject.widgetContainerViews[0]);
                });
                it(@"should correctly set up AttestationWidgetController", ^{
                    attestationWidgetController should have_received(@selector(setupWithTitle:description:status:delegate:)).with(@"some-title",@"some-description",Unattested,subject);
                });
            });
           
            
        });
    });

    describe(@"refresh control action", ^{
        __block KSDeferred *timesheetsDeferred;
        __block PayWidgetHomeController *payWidgetHomeController;
        
        beforeEach(^{
            payWidgetHomeController = nice_fake_for([PayWidgetHomeController class]);
            [injector bind:[PayWidgetHomeController class] toInstance:payWidgetHomeController];
            
        });
        beforeEach(^{
            timesheetsDeferred = [[KSDeferred alloc] init];
            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,nil,0,timeSheetPermittedActions,nil,nil,scriptCalculationDate,nil);;
            widgetTimesheet = doSubjectAction(@"special-timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
            
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
            widgetTimesheetRepository stub_method(@selector(fetchWidgetTimesheetForTimesheetWithUri:)).with(@"special-timesheet-uri").and_return(timesheetsDeferred.promise);

            subject.view should_not be_nil;
            [subject viewDidAppear:true];
            
            spy_on(refresher);
            
            [refresher pullToRefresh];
        });
        
        afterEach(^{
            stop_spying_on(refresher);
        });

        it(@"should add as a subview on scrollview", ^{
            float version=[[UIDevice currentDevice].systemVersion newFloatValue];
            if (version >= 10.0){
                subject.scrollView.refreshControl should equal(refresher);
            }
            else{
                subject.scrollView.subviews should contain(refresher);
            }
        });
        
        it(@"should disable UserInteraction", ^{
            subject.view.isUserInteractionEnabled should equal(false);
        });
        
        it(@"should fetch the all configured widgets info", ^{
            widgetTimesheetRepository should have_received(@selector(fetchWidgetTimesheetForTimesheetWithUri:)).with(@"special-timesheet-uri");
        });
        
        itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
            sharedContext[@"shouldVerifyForIsEnabled"] = @1;
            sharedContext[@"subject"] = subject;
        });
        
        context(@"when the promise is resolved", ^{
            __block WidgetTimesheet *timesheet;
            __block NSArray *widgetMetadata;
            
            __block KSDeferred *punchWidgetDeferred;
            __block PlaceholderController *placeholderController;
            __block WidgetData *widgetDataForPay;
            __block PayWidgetData *payWidgetData;
            __block TimesheetPeriodAndSummaryController *newTimesheetPeriodAndSummaryController;
            __block TimesheetStatusAndSummaryController *newTimesheetStatusAndSummaryController;
            __block DurationSummaryWithoutOffsetController *newDurationsController;


            
            beforeEach(^{
                placeholderController = nice_fake_for([PlaceholderController class]);
                [injector bind:[PlaceholderController class] toInstance:placeholderController];
                
                punchWidgetDeferred = [[KSDeferred alloc]init];
                punchWidgetRepository stub_method(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"special-timesheet-uri").and_return(punchWidgetDeferred.promise);
            });

            beforeEach(^{
                
                WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:nil timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"];
                Paycode *payCode = nice_fake_for([Paycode class]);
                payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:nil actualsByPaycode:@[payCode] actualsByDuration:@[payCode]];
                widgetDataForPay = [[WidgetData alloc]initWithTimesheetWidgetMetaData:payWidgetData timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"];
                
                NoticeWidgetData *noticeWidgetMetaData = [[NoticeWidgetData alloc]initWithTitle:@"some-title" description:@"some-description"];
                WidgetData *noticeWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:noticeWidgetMetaData
                                                                          timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:notice"];
                
                AttestationWidgetData *attestationWidgetMetaData = [[AttestationWidgetData alloc]initWithTitle:@"some-title" description:@"some-description"];
                WidgetData *attestationWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:attestationWidgetMetaData
                                                                           timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:attestation"];
                    
                widgetMetadata = @[punchWidgetData,widgetDataForPay,noticeWidgetData,attestationWidgetData];
                TimeSheetApprovalStatus *status = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:timesheet-status:submitting"
                                                                                             approvalStatus:@"Submitting"];
                Summary *summary = doSummarySubjectAction(status,timesheetDuration,nil,0,timeSheetPermittedActions,nil,nil,nil,nil);
                timesheet = doSubjectAction(@"special-timesheet-uri", nil,summary,widgetMetadata,nil,false,true,false,Attested);
                [widgetTimesheetDetailsSeriesControllerPresenter reset_sent_messages];
                [delegate reset_sent_messages];
                [childControllerHelper reset_sent_messages];
                
                newTimesheetPeriodAndSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
                [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:newTimesheetPeriodAndSummaryController];
                
                newTimesheetStatusAndSummaryController = nice_fake_for([TimesheetStatusAndSummaryController class]);
                [injector bind:[TimesheetStatusAndSummaryController class] toInstance:newTimesheetStatusAndSummaryController];
                
                newDurationsController = nice_fake_for([DurationSummaryWithoutOffsetController class]);
                [injector bind:[DurationSummaryWithoutOffsetController class] toInstance:newDurationsController];
                
                [timesheetsDeferred resolveWithValue:timesheet];
            });
            
            itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
                sharedContext[@"shouldVerifyForIsEnabled"] = @0;
                sharedContext[@"subject"] = subject;
            });

            
            context(@"Presenting the TimesheetPeriodAndSummaryController", ^{
                
                it(@"should add TimesheetPeriodAndSummaryController as a child controller to WidgetTimesheetDetailsController", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetSummaryController,newTimesheetPeriodAndSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
                });
                
                it(@"should correctly set up TimesheetPeriodAndSummaryController", ^{
                    newTimesheetPeriodAndSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(timesheet,subject,subject);
                });
            });
            
            context(@"Presenting the TimesheetStatusAndSummaryController", ^{
                
                context(@"When its user context", ^{
                    it(@"should add TimesheetSummaryController as a child controller to WidgetTimesheetDetailsController", ^{
                        childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetStatusAndSummaryController,newTimesheetStatusAndSummaryController,subject,subject.timesheetStatusAndSummaryContainerView);
                    });
                    
                    it(@"should correctly set up TimesheetStatusAndSummaryController", ^{
                        newTimesheetStatusAndSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:)).with(timesheet,subject);
                    });
                });
                
            });
            
            context(@"Presenting the DurationSummaryWithoutOffsetController", ^{
                it(@"should add DurationSummaryWithoutOffsetController as a child controller to WidgetTimesheetDetailsController", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(durationsController,newDurationsController,subject,subject.timesheetDurationsSummaryContainerView);
                });
                
                it(@"should correctly set up DurationSummaryWithoutOffsetController", ^{
                    newDurationsController should have_received(@selector(setupWithTimesheetDuration:delegate:hasBreakAccess:)).with(timesheetDuration,subject,YES);
                });
            });

            context(@"Presenting the Punch Widget Related Controllers", ^{
                
                it(@"should add PlaceholderController as a child controller to WidgetTimesheetDetailsController", ^{
                    childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(placeholderController,subject,subject.widgetContainerViews[0]);
                });
                
                it(@"should ask the punch widget repository for the punch widget info", ^{
                    punchWidgetRepository should have_received(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"special-timesheet-uri");
                });
                
                it(@"should correctly set up PlaceholderController", ^{
                    placeholderController should have_received(@selector(setUpWithDelegate:widgetUri:)).with(subject,@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry");
                });
                
                context(@"when the punch widget promise succeeds intially", ^{
                    __block TimesheetInfo *timesheetInfo;
                    __block NSArray *dayTimeSummaries;
                    __block PunchWidgetTimesheetBreakdownController *punchWidgetTimesheetBreakdownController;
                    __block PunchWidgetData *expectedPunchWidgetData;
                    
                    beforeEach(^{
                        punchWidgetTimesheetBreakdownController = nice_fake_for([PunchWidgetTimesheetBreakdownController class]);
                        [injector bind:[PunchWidgetTimesheetBreakdownController class] toInstance:punchWidgetTimesheetBreakdownController];
                        
                        TimesheetDaySummary *timesheetDaySummaryA = nice_fake_for([TimesheetDaySummary class]);
                        TimesheetDaySummary *timesheetDaySummaryB = nice_fake_for([TimesheetDaySummary class]);
                        dayTimeSummaries = @[timesheetDaySummaryA,timesheetDaySummaryB];
                        TimePeriodSummary *timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                        timePeriodSummary stub_method(@selector(dayTimeSummaries)).and_return(dayTimeSummaries);
                        
                        NSDateComponents *regularTimeComponents = [[NSDateComponents alloc]init];
                        regularTimeComponents.hour = 1;
                        regularTimeComponents.minute = 2;
                        regularTimeComponents.second = 3;
                        
                        NSDateComponents *breakTimeComponents = [[NSDateComponents alloc]init];
                        breakTimeComponents.hour = 4;
                        breakTimeComponents.minute = 5;
                        breakTimeComponents.second = 6;
                        
                        NSDateComponents *timeoffComponents = [[NSDateComponents alloc]init];
                        timeoffComponents.hour = 7;
                        timeoffComponents.minute = 8;
                        timeoffComponents.second = 9;
                        
                        timePeriodSummary stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
                        timePeriodSummary stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                        timePeriodSummary stub_method(@selector(timeOffComponents)).and_return(timeoffComponents);
                        
                        timesheetInfo = nice_fake_for([TimesheetInfo class]);
                        timesheetInfo stub_method(@selector(timePeriodSummary)).and_return(timePeriodSummary);
                        
                        TimesheetDuration *timesheetDuration = [[TimesheetDuration alloc]initWithRegularHours:regularTimeComponents
                                                                                                   breakHours:breakTimeComponents
                                                                                                 timeOffHours:timeoffComponents];
                        expectedPunchWidgetData = [[PunchWidgetData alloc]initWithDaySummaries:dayTimeSummaries
                                                                           widgetLevelDuration:timesheetDuration];
                        [punchWidgetDeferred resolveWithValue:timesheetInfo];
                    });
                    
                    it(@"should add PunchWidgetTimesheetBreakdownController as a child controller to WidgetTimesheetDetailsController", ^{
                        childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(placeholderController,punchWidgetTimesheetBreakdownController,subject,subject.widgetContainerViews[0]);
                    });
                    
                    it(@"should update the WidgetTimesheet with the Punch Meta Data", ^{
                        WidgetData *widgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:expectedPunchWidgetData timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"];
                        subject.widgetTimesheet.widgetsMetaData[0] should equal(widgetData);
                    });
                    
                    it(@"should correctly set up PunchWidgetTimesheetBreakdownController", ^{
                        punchWidgetTimesheetBreakdownController should have_received(@selector(setupWithPunchWidgetData:delegate:hasBreakAccess:)).with(expectedPunchWidgetData,subject,YES);
                    });
                });
            });
            
            context(@"Presenting the Pay Widget Controller", ^{
        
                it(@"should add PayWidgetHomeController as a child controller to WidgetTimesheetDetailsController", ^{
                    childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(payWidgetHomeController,subject,subject.widgetContainerViews[1]);
                });
                it(@"should correctly set up payWidgetHomeController", ^{
                    payWidgetHomeController should have_received(@selector(setupWithPayWidgetData:displayPayAmount:displayPayTotals:delegate:)).with(payWidgetData,false,false,subject);
                });
            });
            
            context(@"Presenting the NoticeWidgetController", ^{
                
                it(@"should add NoticeWidgetController as a child controller to WidgetTimesheetDetailsController", ^{
                    
                     childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(noticeWidgetController,subject,subject.widgetContainerViews[2]);
                });
                
                it(@"should correctly set up NoticeWidgetController", ^{
                    noticeWidgetController should have_received(@selector(setupWithTitle:description:delegate:)).with(@"some-title",@"some-description",subject);
                });

            });
            
            context(@"Presenting the AttestationWidgetController", ^{
                
                it(@"should add AttestationWidgetController as a child controller to WidgetTimesheetDetailsController", ^{
                    childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(attestationWidgetController,subject,subject.widgetContainerViews[3]);
                });
                
                it(@"should correctly set up AttestationWidgetController", ^{
                    attestationWidgetController should have_received(@selector(setupWithTitle:description:status:delegate:)).with(@"some-title",@"some-description",Attested,subject);
                });
                
            });
            
            it(@"should ask the presenter to provide bar button item", ^{
                widgetTimesheetDetailsSeriesControllerPresenter should have_received(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(timeSheetPermittedActions);
                delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,expectedRightBarButtonItem);
            });
            
            it(@"should end animating", ^{
                refresher should have_received(@selector(endRefreshing));
            });
            
            it(@"should enable UserInteraction", ^{
                subject.view.isUserInteractionEnabled should equal(true);
            });
    
        });
    
        context(@"when promise is rejected", ^{
            __block NSError *error;
            beforeEach(^{
                error = [[NSError alloc]initWithDomain:@"" code:0 userInfo:nil];
                [timesheetsDeferred rejectWithError:error];
            });
            
            it(@"should end animating", ^{
                refresher should have_received(@selector(endRefreshing));
            });
            
            it(@"should enable UserInteraction", ^{
                subject.view.isUserInteractionEnabled should equal(true);
            });
        });

    });

    describe(@"presenting the right bar button item ", ^{
        
        beforeEach(^{
            
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
        });
        
        it(@"should ask the presenter to provide bar button item", ^{
            widgetTimesheetDetailsSeriesControllerPresenter should have_received(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(timeSheetPermittedActions);
            delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,expectedRightBarButtonItem);
            widgetTimesheetDetailsSeriesControllerPresenter should have_received(@selector(setUpWithDelegate:)).with(subject);
        });
    });
    
    describe(@"Presenting the TimesheetSummaryController", ^{
        
        context(@"When its user context", ^{
            
            beforeEach(^{
                [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
                subject.view should_not be_nil;
                [subject viewDidAppear:true];
                
            });
            
            it(@"should add TimesheetSummaryController as a child controller to WidgetTimesheetDetailsController", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(timesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
            });
            
            it(@"should correctly set up TimesheetSummaryController", ^{
                timesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(widgetTimesheet,subject,subject);
            });
        });
        
        context(@"When its supervisor context", ^{
            beforeEach(^{
                [subject setupWithWidgetTimesheet:widgetTimesheet delegate:nil hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
                subject.view should_not be_nil;
                [subject viewDidAppear:true];
            });
            
            it(@"should add TimesheetSummaryController as a child controller to WidgetTimesheetDetailsController", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(timesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
            });
            
            it(@"should correctly set up TimesheetSummaryController", ^{
                timesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(widgetTimesheet,subject,nil);
            });
        });
        
    });
    
    describe(@"Presenting the TimesheetStatusAndSummaryController", ^{
        
        context(@"When its user context", ^{
            
            beforeEach(^{
                [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
                subject.view should_not be_nil;
                [subject viewDidAppear:true];
                
            });
            
            it(@"should add TimesheetSummaryController as a child controller to WidgetTimesheetDetailsController", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(timesheetStatusAndSummaryController,subject,subject.timesheetStatusAndSummaryContainerView);
            });
            
            it(@"should correctly set up TimesheetStatusAndSummaryController", ^{
                timesheetStatusAndSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:)).with(widgetTimesheet,subject);
            });
        });
        
    });
    
    describe(@"Presenting the DurationSummaryWithoutOffsetController", ^{
        beforeEach(^{
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
        });
        
        it(@"should add DurationSummaryWithoutOffsetController as a child controller to WidgetTimesheetDetailsController", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(durationsController,subject,subject.timesheetDurationsSummaryContainerView);
        });
        
        it(@"should correctly set up DurationSummaryWithoutOffsetController", ^{
            durationsController should have_received(@selector(setupWithTimesheetDuration:delegate:hasBreakAccess:)).with(timesheetDuration,subject,YES);
        });
    });
    
    describe(@"As a <WidgetTimesheetDetailsControllerDelegate>", ^{
        beforeEach(^{
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
        });
        
        it(@"should inform its delegate that user intends to view issues", ^{
            [subject timesheetPeriodAndSummaryControllerDidTapPreviousButton:(id)[NSNull null]];
            delegate should have_received(@selector(widgetTimesheetDetailsControllerRequestsPreviousTimesheet:)).with(subject);
        });
        
        it(@"should inform its delegate that user intends to view issues", ^{
            [subject timesheetPeriodAndSummaryControllerDidTapNextButton:(id)[NSNull null]];
            delegate should have_received(@selector(widgetTimesheetDetailsControllerRequestsNextTimesheet:)).with(subject);
        });
        
        it(@"should inform its delegate that user intends to view issues", ^{
            [subject timesheetPeriodAndSummaryControllerIntendsToUpdateItsContainerWithHeight:10];
            subject.timesheetPeriodAndSummaryContainerHeightConstraint.constant should equal(10);
        });
        
    });
    
    describe(@"As a <DurationSummaryWithoutOffsetControllerDelegate>", ^{
        beforeEach(^{
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
            
        });
        
        it(@"should inform its delegate to update its container height", ^{
            [subject durationSummaryWithoutOffsetControllerIntendsToUpdateItsContainerWithHeight:10];
            subject.timesheetDurationSummaryContainerHeightConstraint.constant should equal(10);
        });
    });
    
    describe(@"As a <TimesheetPeriodAndSummaryControllerDelegate>", ^{
        beforeEach(^{
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
        });
        
        context(@"timesheetPeriodAndSummaryControllerIntendsToUpdateItsContainerWithHeight:", ^{
            beforeEach(^{
                [subject timesheetPeriodAndSummaryControllerIntendsToUpdateItsContainerWithHeight:10];
                
            });
            it(@"should inform its delegate to update its container height", ^{
                subject.timesheetPeriodAndSummaryContainerHeightConstraint.constant should equal(10);
            });
        });
    });
    
    describe(@"As a <ViolationsSummaryControllerDelegate>", ^{
        __block KSDeferred *summaryDeferred;
        
        beforeEach(^{
            summaryDeferred = [[KSDeferred alloc]init];
            
            Paycode *payCode = nice_fake_for([Paycode class]);
            PayWidgetData *payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:nil actualsByPaycode:nil actualsByDuration:@[payCode]];
            WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:payWidgetData
                                                                      timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"];
            NSArray *widgetMetadata = @[punchWidgetData];
            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,nil,0,timeSheetPermittedActions,nil,nil,scriptCalculationDate,payWidgetData);
            widgetTimesheet = doSubjectAction(@"special-timesheet-uri", nil,summary,widgetMetadata,nil,false,false,false,Attested);
                        
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
            widgetTimesheetSummaryRepository stub_method(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet).and_return(summaryDeferred.promise);
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
            
        });
        
        context(@"violationsSummaryControllerDidRequestViolationSectionsPromise:", ^{
            __block KSPromise *expectedTimesheetSummaryPromise;
            __block Summary *summary;
            __block AllViolationSections *violationsAndWaivers;
            __block TimeSheetPermittedActions *newestPermittedActions;
            __block UIBarButtonItem *newestRightBarButtonItem;
            __block NSDate *newScriptCalculationDate;
            __block PayWidgetData *newPayWidgetData;
            beforeEach(^{
                newScriptCalculationDate = [NSDate dateWithTimeIntervalSince1970:1];
                violationsAndWaivers = nice_fake_for([AllViolationSections class]);
                newestPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                newPayWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil 
                                                                   grossPay:nil 
                                                           actualsByPaycode:nil 
                                                          actualsByDuration:nil];
                
                summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,newestPermittedActions,nil,nil,newScriptCalculationDate,newPayWidgetData);;
                expectedTimesheetSummaryPromise = [subject violationsSummaryControllerDidRequestViolationSectionsPromise:(id)[NSNull null]];
            });
            
            it(@"should fetch the newest timesheet summary", ^{
                widgetTimesheetSummaryRepository should have_received(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet);
            });
            
            
            context(@"should correctly resolve the promise", ^{
                __block TimesheetPeriodAndSummaryController *newTimesheetSummaryController;
                
                beforeEach(^{
                    newTimesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
                    [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:newTimesheetSummaryController];
                    
                    widgetTimesheetDetailsSeriesControllerPresenter stub_method(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(newestPermittedActions).and_return(newestRightBarButtonItem);
                    [summaryDeferred resolveWithValue:summary];                     
                });
                
                it(@"should update the widgetsMetaData with the correct PayWidgetData", ^{
                    WidgetData *widgetMetaData = subject.widgetTimesheet.widgetsMetaData[0];
                    widgetMetaData.timesheetWidgetMetaData should equal(newPayWidgetData);
                });
                
                it(@"should correctly resolve the promise", ^{
                    expectedTimesheetSummaryPromise.value should equal(violationsAndWaivers);
                });
                
                it(@"should correctly set up TimesheetSummaryController", ^{
                    WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:newPayWidgetData
                                                                              timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"];
                    NSArray *widgetMetadata = @[punchWidgetData];
                    
                     Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,newestPermittedActions,nil,nil,newScriptCalculationDate,newPayWidgetData);
                    WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"special-timesheet-uri", nil,summary,widgetMetadata,nil,false,false,false,Attested);
                    newTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(newExpectedTimesheet,subject,subject);
                });
                
                it(@"should replace the older TimesheetSummaryController", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetSummaryController,newTimesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
                });
                
            });
            
            context(@"when promise is rejected", ^{
                
                __block NSError *error;
                beforeEach(^{
                    error = [[NSError alloc]initWithDomain:@"" code:0 userInfo:nil];
                    [summaryDeferred rejectWithError:error];
                });
                
                it(@"should  reject with correct error", ^{
                    expectedTimesheetSummaryPromise.error should equal(error);
                });
                
            });
        });
        
    });
    
    describe(@"As a <WidgetTimesheetDetailsSeriesControllerPresenterDelegate>", ^{
        
        __block CommentViewController *commentsViewController;
        __block KSDeferred *deferred;
        
        beforeEach(^{
            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,nil,nil);
            
            widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:NO isSupervisorContext:NO userUri:@"user-uri"];
            subject.view should_not be_nil;   
            [subject viewDidAppear:true];
            
            commentsViewController = [[CommentViewController alloc]initWithTheme:nil notificationCenter:nil];
            [injector bind:[CommentViewController class] toInstance:commentsViewController];
            spy_on(commentsViewController);
        });
        
        afterEach(^{
            stop_spying_on(commentsViewController);
        });
        
        context(@"When the user action is RightBarButtonActionTypeSubmit", ^{
            
            __block TimesheetPeriodAndSummaryController *clientStatusTimesheetSummaryController;
            __block TimesheetStatusAndSummaryController *clientStatusTimesheetStatusAndSummaryController;
            
            beforeEach(^{
                clientStatusTimesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
                [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:clientStatusTimesheetSummaryController];
                
                clientStatusTimesheetStatusAndSummaryController = nice_fake_for([TimesheetStatusAndSummaryController class]);
                [injector bind:[TimesheetStatusAndSummaryController class] toInstance:clientStatusTimesheetStatusAndSummaryController];
                
                deferred = [[KSDeferred alloc]init];
                userActionForTimesheetRepository stub_method(@selector(userActionOnTimesheetWithType:timesheetUri:comments:)).with(RightBarButtonActionTypeSubmit,@"timesheet-uri",nil).and_return(deferred.promise);
                [subject userIntendsTo:RightBarButtonActionTypeSubmit presenter:(id)[NSNull null]];
            });
            
            it(@"should submit the action to the UserActionForTimesheetRepository", ^{
                userActionForTimesheetRepository should have_received(@selector(userActionOnTimesheetWithType:timesheetUri:comments:)).with(RightBarButtonActionTypeSubmit,@"timesheet-uri",nil);
            });
            
            it(@"should show the spinner", ^{
                delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,barButtonItemWithActivity);
            });
            
            context(@"should present TimesheetSummaryController with the client status", ^{
                
                it(@"should correctly set up TimesheetSummaryController", ^{
                    
                    
                    TimeSheetApprovalStatus *status = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:timesheet-status:submitting"
                                                                                                 approvalStatus:@"Submitting"];
                    Summary *summary = doSummarySubjectAction(status,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,nil,nil);
                    WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                    clientStatusTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(newExpectedTimesheet,subject,subject);
                });
                
                it(@"should replace the older TimesheetSummaryController", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetSummaryController,clientStatusTimesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
                });
                
                itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
                    sharedContext[@"shouldVerifyForIsEnabled"] = @0;
                    sharedContext[@"subject"] = subject;
                });
            });
            
            context(@"should present TimesheetStatusAndSummaryController with the client status", ^{
                
                it(@"should correctly set up TimesheetStatusAndSummaryController", ^{
                    
                    
                    TimeSheetApprovalStatus *status = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:timesheet-status:submitting"
                                                                                                 approvalStatus:@"Submitting"];
                    Summary *summary = doSummarySubjectAction(status,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,nil,nil);
                    WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                    clientStatusTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(newExpectedTimesheet,subject,subject);
                });
                
                it(@"should replace the older TimesheetStatusAndSummaryController", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetStatusAndSummaryController,clientStatusTimesheetStatusAndSummaryController,subject,subject.timesheetStatusAndSummaryContainerView);
                });
                
                itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
                    sharedContext[@"shouldVerifyForIsEnabled"] = @0;
                    sharedContext[@"subject"] = subject;
                });
            });
            
            context(@"When submit succeeds", ^{
                __block KSDeferred *timesummaryDeferred;
                beforeEach(^{
                    timesummaryDeferred = [[KSDeferred alloc]init];
                    widgetTimesheetSummaryRepository stub_method(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet).and_return(timesummaryDeferred.promise);
                    [deferred resolveWithValue:nil];
                });
                
                it(@"should fetch the newest timesheet summary", ^{
                    widgetTimesheetSummaryRepository should have_received(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet);
                });
                
                context(@"When new timesheet summary succeeds", ^{
                    __block TimeSheetPermittedActions *newestPermittedActions;
                    __block UIBarButtonItem *newRightBarButtonItem;
                    __block TimesheetPeriodAndSummaryController *newTimesheetSummaryController;
                    __block TimesheetStatusAndSummaryController *newTimesheetStatusAndSummaryController;
                    __block NSDate *newScriptCalculationDate;
                    
                    beforeEach(^{
                        newScriptCalculationDate = [NSDate dateWithTimeIntervalSince1970:1];
                        newTimesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
                        [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:newTimesheetSummaryController];
                        
                        newTimesheetStatusAndSummaryController = nice_fake_for([TimesheetStatusAndSummaryController class]);
                        [injector bind:[TimesheetStatusAndSummaryController class] toInstance:newTimesheetStatusAndSummaryController];
                        
                        newRightBarButtonItem = [[UIBarButtonItem alloc]init];
                        newestPermittedActions = [[TimeSheetPermittedActions alloc]initWithCanSubmitOnDueDate:true 
                                                                                                    canReopen:false 
                                                                                         canReSubmitTimeSheet:true];
                        Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,nil,0,newestPermittedActions,nil,nil,newScriptCalculationDate,nil);;
                        widgetTimesheetDetailsSeriesControllerPresenter stub_method(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(newestPermittedActions).and_return(newRightBarButtonItem);
                        [timesummaryDeferred resolveWithValue:summary];
                    });
                    
                    itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
                        sharedContext[@"shouldVerifyForIsEnabled"] = @1;
                        sharedContext[@"subject"] = subject;
                    });
                    
                    it(@"should present the newest bar button item based on the newest summary", ^{
                        widgetTimesheetDetailsSeriesControllerPresenter should have_received(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(newestPermittedActions);
                        delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,newRightBarButtonItem);
                        widgetTimesheetDetailsSeriesControllerPresenter should have_received(@selector(setUpWithDelegate:)).with(subject);
                    });
                    
                    context(@"present TimesheetSummaryController", ^{
                        
                        it(@"should correctly set up TimesheetSummaryController", ^{
                            
                            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,nil,0,newestPermittedActions,nil,nil,newScriptCalculationDate,nil);
                            WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                            newTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(newExpectedTimesheet,subject,subject);
                        });
                        
                        it(@"should replace the older TimesheetSummaryController", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(clientStatusTimesheetSummaryController,newTimesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
                        });
                    });
                    
                    context(@"present TimesheetStatusAndSummaryController", ^{
                        
                        it(@"should correctly set up TimesheetStatusAndSummaryController", ^{
                            
                            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,nil,0,newestPermittedActions,nil,nil,newScriptCalculationDate,nil);
                            WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                            newTimesheetStatusAndSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:)).with(newExpectedTimesheet,subject);
                        });
                        
                        it(@"should replace the older TimesheetStatusAndSummaryController", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(clientStatusTimesheetStatusAndSummaryController,newTimesheetStatusAndSummaryController,subject,subject.timesheetStatusAndSummaryContainerView);
                        });
                    });
                    
                });
                
                context(@"When new timesheet summary fails", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = [[NSError alloc]initWithDomain:@"" code:0 userInfo:nil];
                        [timesummaryDeferred rejectWithError:error];
                        
                    });
                    
                    itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
                        sharedContext[@"shouldVerifyForIsEnabled"] = @1;
                        sharedContext[@"subject"] = subject;
                    });
                    
                    it(@"should inform its delegate to continue showing the previous last known bar button item", ^{
                        delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,expectedRightBarButtonItem);
                    });
                    
                    context(@"should present TimesheetSummaryController with the old known status", ^{
                        
                        it(@"should correctly set up TimesheetSummaryController", ^{
                            
                            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,nil,nil);
                            WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                            clientStatusTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(newExpectedTimesheet,subject,subject);
                        });
                        
                        it(@"should replace the older TimesheetSummaryController", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetSummaryController,clientStatusTimesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
                        });
                    });
                    
                    context(@"should present TimesheetStatusAndSummaryController with the old known status", ^{
                        
                        it(@"should correctly set up TimesheetStatusAndSummaryController", ^{
                            
                            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,nil,nil);
                            WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                            clientStatusTimesheetStatusAndSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:)).with(newExpectedTimesheet,subject);
                        });
                        
                        it(@"should replace the older TimesheetStatusAndSummaryController", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetStatusAndSummaryController,clientStatusTimesheetStatusAndSummaryController,subject,subject.timesheetStatusAndSummaryContainerView);
                        });
                    });
                });
            });
            
            context(@"When submit fails", ^{
                
                __block NSError *error;
                beforeEach(^{
                    error = [[NSError alloc]initWithDomain:@"" code:0 userInfo:nil];
                    [deferred rejectWithError:error];
                });
                
                itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
                    sharedContext[@"shouldVerifyForIsEnabled"] = @1;
                    sharedContext[@"subject"] = subject;
                });
                
                it(@"should fetch the newest timesheet summary", ^{
                    widgetTimesheetSummaryRepository should_not have_received(@selector(fetchSummaryForTimesheet:));
                });
                
                it(@"should inform its delegate to continue showing the previous last known bar button item", ^{
                    delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,expectedRightBarButtonItem);
                });
                
                context(@"should present TimesheetSummaryController with the old known status", ^{
                    
                    it(@"should correctly set up TimesheetSummaryController", ^{
                        
                        Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,nil,nil);
                        WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                        clientStatusTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(newExpectedTimesheet,subject,subject);
                    });
                    
                    it(@"should replace the older TimesheetSummaryController", ^{
                        childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetSummaryController,clientStatusTimesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
                    });
                });
                
                context(@"should present TimesheetStatusAndSummaryController with the old known status", ^{
                    
                    it(@"should correctly set up TimesheetStatusAndSummaryController", ^{
                        
                        Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,nil,nil);
                        WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                        clientStatusTimesheetStatusAndSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:)).with(newExpectedTimesheet,subject);
                    });
                    
                    it(@"should replace the older TimesheetStatusAndSummaryController", ^{
                        childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetStatusAndSummaryController,clientStatusTimesheetStatusAndSummaryController,subject,subject.timesheetStatusAndSummaryContainerView);
                    });
                });
                
            });
            
            
        });
        
        context(@"When the user action is RightBarButtonActionTypeReOpen", ^{
            beforeEach(^{
                
                [subject userIntendsTo:RightBarButtonActionTypeReOpen presenter:(id)[NSNull null]];
            });
            
            it(@"should present the comments controller to the user", ^{
                commentsViewController should have_received(@selector(setupAction:delegate:)).with(@"Reopen",subject);
                navigationController should have_received(@selector(pushViewController:animated:)).with(commentsViewController,Arguments::anything);
                navigationController.topViewController should be_same_instance_as(commentsViewController);
            });
            
            it(@"should submit the action to the UserActionForTimesheetRepository", ^{
                userActionForTimesheetRepository should_not have_received(@selector(userActionOnTimesheetWithType:timesheetUri:comments:));
            });
            
        });
        
        context(@"When the user action is RightBarButtonActionTypeReSubmit", ^{
            
            beforeEach(^{
                [subject userIntendsTo:RightBarButtonActionTypeReSubmit presenter:(id)[NSNull null]];
            });
            
            it(@"should present the comments controller to the user", ^{
                commentsViewController should have_received(@selector(setupAction:delegate:)).with(@"Resubmit",subject);
                navigationController should have_received(@selector(pushViewController:animated:)).with(commentsViewController,Arguments::anything);
                navigationController.topViewController should be_same_instance_as(commentsViewController);
            });
            
            it(@"should submit the action to the UserActionForTimesheetRepository", ^{
                userActionForTimesheetRepository should_not have_received(@selector(userActionOnTimesheetWithType:timesheetUri:comments:));
            });
        });
    });
    
    describe(@"As a <CommentViewControllerDelegate>", ^{
        
        __block KSDeferred *deferred;
        
        beforeEach(^{
            deferred = [[KSDeferred alloc]init];
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:NO isSupervisorContext:NO userUri:@"user-uri"];
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
            
        });
        
        context(@"When the user action is RightBarButtonActionTypeReOpen", ^{
            beforeEach(^{
                userActionForTimesheetRepository stub_method(@selector(userActionOnTimesheetWithType:timesheetUri:comments:)).with(RightBarButtonActionTypeReOpen,@"timesheet-uri",@"comments").and_return(deferred.promise);
                [subject userIntendsTo:RightBarButtonActionTypeReOpen presenter:(id)[NSNull null]];
                [subject commentsViewController:(id)[NSNull null] actionType:RightBarButtonActionTypeReOpen comments:@"comments"];
            });
            
            it(@"should submit the action to the UserActionForTimesheetRepository", ^{
                userActionForTimesheetRepository should have_received(@selector(userActionOnTimesheetWithType:timesheetUri:comments:)).with(RightBarButtonActionTypeReOpen, @"timesheet-uri",@"comments");
            });
            
            it(@"should show the spinner", ^{
                delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,barButtonItemWithActivity);
            });
            
            context(@"When ReOpen succeeds", ^{
                __block KSDeferred *timesummaryDeferred;
                beforeEach(^{
                    timesummaryDeferred = [[KSDeferred alloc]init];
                    widgetTimesheetSummaryRepository stub_method(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet).and_return(timesummaryDeferred.promise);
                    [deferred resolveWithValue:nil];
                });
                
                it(@"should fetch the newest timesheet summary", ^{
                    widgetTimesheetSummaryRepository should have_received(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet);
                });
                
                it(@"should not replace the older TimesheetSummaryController", ^{
                    childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetSummaryController,Arguments::anything,subject,subject.timesheetPeriodAndSummaryContainerView);
                });
                
                context(@"When new timesheet summary succeeds", ^{
                    __block TimeSheetPermittedActions *newestPermittedActions;
                    __block UIBarButtonItem *newRightBarButtonItem;
                    __block TimesheetPeriodAndSummaryController *newTimesheetSummaryController;
                    __block NSDate *newScriptCalculationDate;
                    
                    beforeEach(^{
                        newScriptCalculationDate = [NSDate dateWithTimeIntervalSince1970:1];
                        newTimesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
                        [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:newTimesheetSummaryController];
                        newRightBarButtonItem = [[UIBarButtonItem alloc]init];;
                        newestPermittedActions = [[TimeSheetPermittedActions alloc]initWithCanSubmitOnDueDate:true 
                                                                                                    canReopen:false 
                                                                                         canReSubmitTimeSheet:true];
                        Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,nil,0,newestPermittedActions,nil,nil,newScriptCalculationDate,nil);;
                        widgetTimesheetDetailsSeriesControllerPresenter stub_method(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(newestPermittedActions).and_return(newRightBarButtonItem);
                        
                        [timesummaryDeferred resolveWithValue:summary];
                    });
                    
                    it(@"should present the newest bar button item based on the newest summary", ^{
                        widgetTimesheetDetailsSeriesControllerPresenter should have_received(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(newestPermittedActions);
                        delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,newRightBarButtonItem);
                    });
                    
                    it(@"should correctly set up TimesheetSummaryController", ^{
                        Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,nil,0,newestPermittedActions,nil,nil,newScriptCalculationDate,nil);
                        WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                        newTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(newExpectedTimesheet,subject,subject);
                    });
                    
                    it(@"should replace the older TimesheetSummaryController", ^{
                        childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetSummaryController,newTimesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
                    });
                    
                });
                
                context(@"When new timesheet summary fails", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = [[NSError alloc]initWithDomain:@"" code:0 userInfo:nil];
                        [timesummaryDeferred rejectWithError:error];
                        
                    });
                    
                    it(@"should inform its delegate to continue showing the previous last known bar button item", ^{
                        delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,expectedRightBarButtonItem);
                    });
                });
            });
            
            context(@"When ReOpen fails", ^{
                
                __block NSError *error;
                beforeEach(^{
                    error = [[NSError alloc]initWithDomain:@"" code:0 userInfo:nil];
                    [deferred rejectWithError:error];
                });
                
                it(@"should fetch the newest timesheet summary", ^{
                    widgetTimesheetSummaryRepository should_not have_received(@selector(fetchSummaryForTimesheet:));
                });
                
                it(@"should inform its delegate to continue showing the previous last known bar button item", ^{
                    delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,expectedRightBarButtonItem);
                });
            });
            
        });
        
        context(@"When the user action is RightBarButtonActionTypeReSubmit", ^{
            
            __block TimesheetPeriodAndSummaryController *clientStatusTimesheetSummaryController;
            __block TimesheetStatusAndSummaryController *clientStatusTimesheetStatusAndSummaryController;
            
            beforeEach(^{
                clientStatusTimesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
                [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:clientStatusTimesheetSummaryController];
                
                clientStatusTimesheetStatusAndSummaryController = nice_fake_for([TimesheetStatusAndSummaryController class]);
                [injector bind:[TimesheetStatusAndSummaryController class] toInstance:clientStatusTimesheetStatusAndSummaryController];
                
                userActionForTimesheetRepository stub_method(@selector(userActionOnTimesheetWithType:timesheetUri:comments:)).with(RightBarButtonActionTypeReSubmit,@"timesheet-uri",@"comments").and_return(deferred.promise);
                
                [subject userIntendsTo:RightBarButtonActionTypeReSubmit presenter:(id)[NSNull null]];
                [subject commentsViewController:(id)[NSNull null] actionType:RightBarButtonActionTypeReSubmit comments:@"comments"];
            });
            
            it(@"should submit the action to the UserActionForTimesheetRepository", ^{
                userActionForTimesheetRepository should have_received(@selector(userActionOnTimesheetWithType:timesheetUri:comments:)).with(RightBarButtonActionTypeReSubmit, @"timesheet-uri",@"comments");
            });
            
            it(@"should show the spinner", ^{
                delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,barButtonItemWithActivity);
            });
            
            context(@"should present TimesheetSummaryController with the client status", ^{
                
                it(@"should correctly set up TimesheetSummaryController", ^{
                    
                    
                    TimeSheetApprovalStatus *status = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:timesheet-status:submitting"
                                                                                                 approvalStatus:@"Submitting"];
                    Summary *summary = doSummarySubjectAction(status,timesheetDuration,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);
                    WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                    clientStatusTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(newExpectedTimesheet,subject,subject);
                });
                
                it(@"should replace the older TimesheetSummaryController", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetSummaryController,clientStatusTimesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
                });
                
                itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
                    sharedContext[@"shouldVerifyForIsEnabled"] = @0;
                    sharedContext[@"subject"] = subject;
                });
            });
            
            context(@"should present TimesheetStatusAndSummaryController with the client status", ^{
                
                it(@"should correctly set up TimesheetStatusAndSummaryController", ^{
                    
                    
                    TimeSheetApprovalStatus *status = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:timesheet-status:submitting"
                                                                                                 approvalStatus:@"Submitting"];
                    Summary *summary = doSummarySubjectAction(status,timesheetDuration,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);
                    WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                    clientStatusTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(newExpectedTimesheet,subject,subject);
                });
                
                it(@"should replace the older TimesheetStatusAndSummaryController", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetStatusAndSummaryController,clientStatusTimesheetStatusAndSummaryController,subject,subject.timesheetStatusAndSummaryContainerView);
                });
                
                itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
                    sharedContext[@"shouldVerifyForIsEnabled"] = @0;
                    sharedContext[@"subject"] = subject;
                });
            });
            
            context(@"When ReSubmit succeeds", ^{
                __block KSDeferred *timesummaryDeferred;
                beforeEach(^{
                    timesummaryDeferred = [[KSDeferred alloc]init];
                    widgetTimesheetSummaryRepository stub_method(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet).and_return(timesummaryDeferred.promise);
                    [deferred resolveWithValue:nil];
                });
                
                it(@"should fetch the newest timesheet summary", ^{
                    widgetTimesheetSummaryRepository should have_received(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet);
                });
                
                
                context(@"When new timesheet summary succeeds", ^{
                    __block TimeSheetPermittedActions *newestPermittedActions;
                    __block UIBarButtonItem *newRightBarButtonItem;
                    __block TimesheetPeriodAndSummaryController *newTimesheetSummaryController;
                    __block TimesheetStatusAndSummaryController *newTimesheetStatusAndSummaryController;
                    __block NSDate *newScriptCalculationDate;
                    
                    beforeEach(^{
                        newScriptCalculationDate = [NSDate dateWithTimeIntervalSince1970:1];
                        newTimesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
                        [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:newTimesheetSummaryController];
                        
                        newTimesheetStatusAndSummaryController = nice_fake_for([TimesheetStatusAndSummaryController class]);
                        [injector bind:[TimesheetStatusAndSummaryController class] toInstance:newTimesheetStatusAndSummaryController];
                        
                        newRightBarButtonItem = [[UIBarButtonItem alloc]init];
                        newestPermittedActions = [[TimeSheetPermittedActions alloc]initWithCanSubmitOnDueDate:true 
                                                                                                    canReopen:true canReSubmitTimeSheet:true];
                        Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,nil,0,newestPermittedActions,nil,nil,newScriptCalculationDate,nil);;
                        
                        widgetTimesheetDetailsSeriesControllerPresenter stub_method(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(newestPermittedActions).and_return(newRightBarButtonItem);
                        
                        [timesummaryDeferred resolveWithValue:summary];
                    });
                    
                    itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
                        sharedContext[@"shouldVerifyForIsEnabled"] = @1;
                        sharedContext[@"subject"] = subject;
                    });
                    
                    it(@"should present the newest bar button item based on the newest summary", ^{
                        widgetTimesheetDetailsSeriesControllerPresenter should have_received(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(newestPermittedActions);
                        delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,newRightBarButtonItem);
                    });
                    
                    context(@"presenting the TimesheetPeriodAndSummaryController", ^{
                        it(@"should correctly set up TimesheetSummaryController", ^{
                            
                            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,nil,0,newestPermittedActions,nil,nil,newScriptCalculationDate,nil);
                            WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                            newTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(newExpectedTimesheet,subject,subject);
                        });
                        
                        it(@"should replace the older TimesheetSummaryController", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(clientStatusTimesheetSummaryController,newTimesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
                        });
                    });
                    
                    context(@"presenting the TimesheetStatusAndSummaryController", ^{
                        
                        it(@"should correctly set up TimesheetStatusAndSummaryController", ^{
                            
                            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,nil,0,newestPermittedActions,nil,nil,newScriptCalculationDate,nil);
                            WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                            newTimesheetStatusAndSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:)).with(newExpectedTimesheet,subject);
                        });
                        
                        it(@"should replace the older TimesheetSummaryController", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(clientStatusTimesheetStatusAndSummaryController,newTimesheetStatusAndSummaryController,subject,subject.timesheetStatusAndSummaryContainerView);
                        });
                    });
                    
                    
                });
                
                context(@"When new timesheet summary fails", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = [[NSError alloc]initWithDomain:@"" code:0 userInfo:nil];
                        [timesummaryDeferred rejectWithError:error];
                        
                    });
                    
                    itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
                        sharedContext[@"shouldVerifyForIsEnabled"] = @1;
                        sharedContext[@"subject"] = subject;
                    });
                    
                    it(@"should inform its delegate to continue showing the previous last known bar button item", ^{
                        delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,expectedRightBarButtonItem);
                    });
                    
                    context(@"should present TimesheetSummaryController with the old known status", ^{
                        
                        it(@"should correctly set up TimesheetSummaryController", ^{
                            
                            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,timesheetDuration,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);
                            WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                            clientStatusTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(newExpectedTimesheet,subject,subject);
                        });
                        
                        it(@"should replace the older TimesheetSummaryController", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetSummaryController,clientStatusTimesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
                        });
                    });
                    
                    context(@"should present TimesheetStatusAndSummaryController with the old known status", ^{
                        
                        it(@"should correctly set up TimesheetStatusAndSummaryController", ^{
                            
                            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,timesheetDuration,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);
                            WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                            clientStatusTimesheetStatusAndSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:)).with(newExpectedTimesheet,subject);
                        });
                        
                        it(@"should replace the older TimesheetStatusAndSummaryController", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetStatusAndSummaryController,clientStatusTimesheetStatusAndSummaryController,subject,subject.timesheetStatusAndSummaryContainerView);
                        });
                    });
                    
                    
                });
            });
            
            context(@"When ReSubmit fails", ^{
                
                __block NSError *error;
                beforeEach(^{
                    error = [[NSError alloc]initWithDomain:@"" code:0 userInfo:nil];
                    [deferred rejectWithError:error];
                });
                
                itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
                    sharedContext[@"shouldVerifyForIsEnabled"] = @1;
                    sharedContext[@"subject"] = subject;
                });
                
                it(@"should fetch the newest timesheet summary", ^{
                    widgetTimesheetSummaryRepository should_not have_received(@selector(fetchSummaryForTimesheet:));
                });
                
                it(@"should inform its delegate to continue showing the previous last known bar button item", ^{
                    delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,expectedRightBarButtonItem);
                });
                
                context(@"should present TimesheetSummaryController with the old known status", ^{
                    
                    it(@"should correctly set up TimesheetSummaryController", ^{
                        
                        Summary *summary = doSummarySubjectAction(intialTimesheetStatus,timesheetDuration,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);
                        WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                        clientStatusTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(newExpectedTimesheet,subject,subject);
                    });
                    
                    it(@"should replace the older TimesheetSummaryController", ^{
                        childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetSummaryController,clientStatusTimesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
                    });
                });
                
                context(@"should present TimesheetStatusAndSummaryController with the old known status", ^{
                    
                    it(@"should correctly set up TimesheetStatusAndSummaryController", ^{
                        
                        Summary *summary = doSummarySubjectAction(intialTimesheetStatus,timesheetDuration,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);
                        WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                        clientStatusTimesheetStatusAndSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:)).with(newExpectedTimesheet,subject);
                    });
                    
                    it(@"should replace the older TimesheetStatusAndSummaryController", ^{
                        childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetStatusAndSummaryController,clientStatusTimesheetStatusAndSummaryController,subject,subject.timesheetStatusAndSummaryContainerView);
                    });
                });
                
            });
        });
    });
    
    describe(@"As a <WidgetTimesheetSummaryRepositoryObserver>", ^{
        __block NSArray *widgetMetadata;
        __block KSDeferred *punchWidgetDeferred;
        
        beforeEach(^{
            punchWidgetDeferred = [[KSDeferred alloc]init];
            punchWidgetRepository stub_method(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"timesheet-uri").and_return(punchWidgetDeferred.promise);
        });
        
        beforeEach(^{
            WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:nil
                                                                      timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"];
            widgetMetadata = @[punchWidgetData];
            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);;
            widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,false,false,false,Attested);
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
            
            
        });
        
        context(@"When polling is required", ^{
            
            context(@"When view is not on window", ^{
                
                beforeEach(^{
                    viewHelper stub_method(@selector(isViewControllerCurrentlyOnWindow:)).with(subject).again().and_return(NO);
                });
                __block KSDeferred *summaryDeferred;
                beforeEach(^{
                    summaryDeferred = [[KSDeferred alloc]init];
                    widgetTimesheetSummaryRepository stub_method(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet).and_return(summaryDeferred.promise);
                    
                    Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,nil,nil);
                    
                    
                    [subject widgetTimesheetSummaryRepository:(id)[NSNull null] fetchedNewSummary:summary];
                });
                
                it(@"should fetch the newest timesheet summary", ^{
                    widgetTimesheetSummaryRepository should have_received(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet);
                });
                
                context(@"should correctly resolve the promise", ^{
                    __block TimeSheetPermittedActions *newestPermittedActions;
                    __block Summary *summary;
                    __block TimeSheetApprovalStatus *newestStatus;
                    beforeEach(^{
                        
                        newestStatus = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:timesheet-status:rejected"
                                                                                  approvalStatus:@"some-value"];
                        newestPermittedActions = [[TimeSheetPermittedActions alloc]initWithCanSubmitOnDueDate:false 
                                                                                                    canReopen:false 
                                                                                         canReSubmitTimeSheet:false];
                        summary = doSummarySubjectAction(newestStatus,nil,nil,0,newestPermittedActions,nil,nil,nil,nil);
                        
                        [summaryDeferred resolveWithValue:summary];                     
                    });
                    
                    it(@"should replace the older TimesheetSummaryController", ^{
                        childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
                    });
                    
                });
                
            });
            
            context(@"When view is on window", ^{
                
                beforeEach(^{
                    viewHelper stub_method(@selector(isViewControllerCurrentlyOnWindow:)).with(subject).again().and_return(YES);
                });
                
                __block KSDeferred *summaryDeferred;
                __block NSDate *scriptCalaculationDate;
                beforeEach(^{
                    scriptCalaculationDate = [NSDate dateWithTimeIntervalSince1970:0];
                    summaryDeferred = [[KSDeferred alloc]init];
                    widgetTimesheetSummaryRepository stub_method(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet).and_return(summaryDeferred.promise);
                    Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,nil,0,nil,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalaculationDate,nil);
                    [subject widgetTimesheetSummaryRepository:(id)[NSNull null] fetchedNewSummary:summary];
                });
                
                it(@"should fetch the newest timesheet summary", ^{
                    widgetTimesheetSummaryRepository should have_received(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet);
                });
                
                
                context(@"when the new script calculation date timestamp is latest ", ^{
                    __block TimesheetPeriodAndSummaryController *newTimesheetSummaryController;
                    __block TimesheetStatusAndSummaryController *newTimesheetStatusAndSummaryController;
                    __block TimeSheetPermittedActions *newestPermittedActions;
                    __block UIBarButtonItem *newestRightBarButtonItem;
                    __block Summary *summary;
                    __block TimeSheetApprovalStatus *newestStatus;
                    __block NSDate *newScriptCalaculationDate;
                    
                    context(@"When the timesheet status is still submitting", ^{
                        
                        beforeEach(^{
                            newScriptCalaculationDate = [NSDate dateWithTimeIntervalSince1970:1];
                            
                            newestStatus = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:timesheet-status:submitting"
                                                                                      approvalStatus:@"some-value"];
                            newestPermittedActions = [[TimeSheetPermittedActions alloc]initWithCanSubmitOnDueDate:false 
                                                                                                        canReopen:false 
                                                                                             canReSubmitTimeSheet:false];
                            summary = doSummarySubjectAction(newestStatus,nil,nil,0,newestPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,newScriptCalaculationDate,nil);
                            
                            newestRightBarButtonItem = [[UIBarButtonItem alloc]init];
                            
                            newTimesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
                            [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:newTimesheetSummaryController];
                            
                            newTimesheetStatusAndSummaryController = nice_fake_for([TimesheetStatusAndSummaryController class]);
                            [injector bind:[TimesheetStatusAndSummaryController class] toInstance:newTimesheetStatusAndSummaryController];
                            
                            widgetTimesheetDetailsSeriesControllerPresenter stub_method(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(newestPermittedActions).and_return(newestRightBarButtonItem);
                            
                            [summaryDeferred resolveWithValue:summary];                     
                        });

                        it(@"should not replace the older TimesheetSummaryController", ^{
                            childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,Arguments::anything,subject,subject.timesheetPeriodAndSummaryContainerView);
                        });
                        
                        it(@"should not replace the older TimesheetStatusAndSummaryController", ^{
                            childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,Arguments::anything,subject,subject.timesheetStatusAndSummaryContainerView);
                        });
                        
                        itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
                            sharedContext[@"shouldVerifyForIsEnabled"] = @0;
                            sharedContext[@"subject"] = subject;
                        });
                        
                    });
                    
                    context(@"When the timesheet status is not in submitting state", ^{
                        beforeEach(^{
                            newScriptCalaculationDate = [NSDate dateWithTimeIntervalSince1970:1];
                            
                            newestStatus = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:timesheet-status:rejected"
                                                                                      approvalStatus:@"some-value"];
                            newestPermittedActions = [[TimeSheetPermittedActions alloc]initWithCanSubmitOnDueDate:false 
                                                                                                        canReopen:false 
                                                                                             canReSubmitTimeSheet:false];
                            summary = doSummarySubjectAction(newestStatus,nil,nil,0,newestPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,newScriptCalaculationDate,nil);
                            
                            newestRightBarButtonItem = [[UIBarButtonItem alloc]init];
                            
                            newTimesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
                            [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:newTimesheetSummaryController];
                            
                            newTimesheetStatusAndSummaryController = nice_fake_for([TimesheetStatusAndSummaryController class]);
                            [injector bind:[TimesheetStatusAndSummaryController class] toInstance:newTimesheetStatusAndSummaryController];
                            
                            widgetTimesheetDetailsSeriesControllerPresenter stub_method(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(newestPermittedActions).and_return(newestRightBarButtonItem);
                            
                            [summaryDeferred resolveWithValue:summary];                     
                        });
                        
                        context(@"presenting the TimesheetSummaryController", ^{
                            it(@"should correctly set up TimesheetSummaryController", ^{
                                
                                Summary *summary = doSummarySubjectAction(newestStatus,nil,nil,0,newestPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,newScriptCalaculationDate,nil);
                                WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                                newTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(newExpectedTimesheet,subject,subject);
                            });
                            
                            it(@"should replace the older TimesheetSummaryController", ^{
                                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetSummaryController,newTimesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
                            });
                        });
                        
                        context(@"presenting the TimesheetStatusAndSummaryController", ^{
                            
                            it(@"should correctly set up TimesheetStatusAndSummaryController", ^{
                                
                                Summary *summary = doSummarySubjectAction(newestStatus,nil,nil,0,newestPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,newScriptCalaculationDate,nil);
                                WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested);
                                newTimesheetStatusAndSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:)).with(newExpectedTimesheet,subject);
                            });
                            
                            it(@"should replace the older TimesheetStatusAndSummaryController", ^{
                                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetStatusAndSummaryController,newTimesheetStatusAndSummaryController,subject,subject.timesheetStatusAndSummaryContainerView);
                            });
                        });
                    });
                    
                    
                });
                
                context(@"when the new script calculation date timestamp is not latest ", ^{
                    __block TimesheetPeriodAndSummaryController *newTimesheetSummaryController;
                    __block TimesheetStatusAndSummaryController *newTimesheetStatusAndSummaryController;
                    __block TimeSheetPermittedActions *newestPermittedActions;
                    __block UIBarButtonItem *newestRightBarButtonItem;
                    __block Summary *summary;
                    __block TimeSheetApprovalStatus *newestStatus;
                    __block NSDate *newScriptCalaculationDate;

                    beforeEach(^{
                        newScriptCalaculationDate = [NSDate dateWithTimeIntervalSince1970:0];
                        newestStatus = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:timesheet-status:rejected"
                                                                                                 approvalStatus:@"some-value"];
                        newestPermittedActions = [[TimeSheetPermittedActions alloc]initWithCanSubmitOnDueDate:false 
                                                                                                    canReopen:false 
                                                                                         canReSubmitTimeSheet:false];
                        summary = doSummarySubjectAction(newestStatus,nil,nil,0,newestPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalaculationDate,nil);
                        
                        newestRightBarButtonItem = [[UIBarButtonItem alloc]init];
                        
                        newTimesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
                        [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:newTimesheetSummaryController];
                        
                        newTimesheetStatusAndSummaryController = nice_fake_for([TimesheetStatusAndSummaryController class]);
                        [injector bind:[TimesheetStatusAndSummaryController class] toInstance:newTimesheetStatusAndSummaryController];
                        
                        widgetTimesheetDetailsSeriesControllerPresenter stub_method(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(newestPermittedActions).and_return(newestRightBarButtonItem);
                        [childControllerHelper reset_sent_messages];
                        [summaryDeferred resolveWithValue:summary];                     
                    });
                    
                    it(@"should not replace the older TimesheetSummaryController", ^{
                        childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,Arguments::anything,subject,subject.timesheetPeriodAndSummaryContainerView);
                    });
                    
                    it(@"should not replace the older TimesheetStatusAndSummaryController", ^{
                        childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,Arguments::anything,subject,subject.timesheetStatusAndSummaryContainerView);
                    });
                    
                });
        
            });
        });
        
        context(@"When polling is not required", ^{
            __block Summary *summary;
            beforeEach(^{
                summary = doSummarySubjectAction(intialTimesheetStatus,nil,nil,0,nil,@"some-value",nil,nil,nil);
                [subject widgetTimesheetSummaryRepository:(id)[NSNull null] fetchedNewSummary:summary];
            });
            
            it(@"should not fetch the newest timesheet summary", ^{
                widgetTimesheetSummaryRepository should_not have_received(@selector(fetchSummaryForTimesheet:));
            });
        });
        
        context(@"When polling is not required and status is current", ^{
            __block Summary *summary;
            __block KSDeferred *punchWidgetSummaryDeferred;
            beforeEach(^{
                punchWidgetSummaryDeferred = [[KSDeferred alloc]init];
                summary = doSummarySubjectAction(intialTimesheetStatus,nil,nil,0,nil,@"urn:replicon:mobile:timesheet:widget:summary:status:current",nil,nil,nil);
                punchWidgetRepository stub_method(@selector(fetchPunchWidgetSummaryForTimesheetWithUri:)).with(@"timesheet-uri").and_return(punchWidgetSummaryDeferred.promise);

                [subject widgetTimesheetSummaryRepository:(id)[NSNull null] fetchedNewSummary:summary];
            });
           
            it(@"should fetch the newest summaries for all the supported widgets", ^{
                punchWidgetRepository should have_received(@selector(fetchPunchWidgetSummaryForTimesheetWithUri:)).with(@"timesheet-uri");
            });
            
            context(@"when the punch widget promise succeeds when view appears", ^{
                
                __block TimesheetInfo *timesheetInfo;
                __block NSArray *dayTimeSummaries;
                __block PunchWidgetTimesheetBreakdownController *punchWidgetTimesheetBreakdownController;
                __block PunchWidgetData *expectedPunchWidgetData;
                __block TimesheetPeriodAndSummaryController *newTimesheetSummaryController;
                __block UIBarButtonItem *newestRightBarButtonItem;
                
                
                beforeEach(^{
                    newestRightBarButtonItem = [[UIBarButtonItem alloc]init];
                    newTimesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
                    [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:newTimesheetSummaryController];
                });
                
                beforeEach(^{
                    punchWidgetTimesheetBreakdownController = nice_fake_for([PunchWidgetTimesheetBreakdownController class]);
                    [injector bind:[PunchWidgetTimesheetBreakdownController class] toInstance:punchWidgetTimesheetBreakdownController];
                    
                    TimesheetDaySummary *timesheetDaySummaryA = nice_fake_for([TimesheetDaySummary class]);
                    TimesheetDaySummary *timesheetDaySummaryB = nice_fake_for([TimesheetDaySummary class]);
                    dayTimeSummaries = @[timesheetDaySummaryA,timesheetDaySummaryB];
                    TimePeriodSummary *timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                    timePeriodSummary stub_method(@selector(dayTimeSummaries)).and_return(dayTimeSummaries);
                    
                    NSDateComponents *regularTimeComponents = [[NSDateComponents alloc]init];
                    regularTimeComponents.hour = 1;
                    regularTimeComponents.minute = 2;
                    regularTimeComponents.second = 3;
                    
                    NSDateComponents *breakTimeComponents = [[NSDateComponents alloc]init];
                    breakTimeComponents.hour = 4;
                    breakTimeComponents.minute = 5;
                    breakTimeComponents.second = 6;
                    
                    NSDateComponents *timeoffComponents = [[NSDateComponents alloc]init];
                    timeoffComponents.hour = 7;
                    timeoffComponents.minute = 8;
                    timeoffComponents.second = 9;
                    
                    timePeriodSummary stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
                    timePeriodSummary stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                    timePeriodSummary stub_method(@selector(timeOffComponents)).and_return(timeoffComponents);
                    
                    timesheetInfo = nice_fake_for([TimesheetInfo class]);
                    timesheetInfo stub_method(@selector(timePeriodSummary)).and_return(timePeriodSummary);
                    
                    TimesheetDuration *timesheetDuration = [[TimesheetDuration alloc]initWithRegularHours:regularTimeComponents
                                                                                               breakHours:breakTimeComponents
                                                                                             timeOffHours:timeoffComponents];
                    expectedPunchWidgetData = [[PunchWidgetData alloc]initWithDaySummaries:dayTimeSummaries
                                                                       widgetLevelDuration:timesheetDuration];
                    
                    [childControllerHelper reset_sent_messages];
                    [punchWidgetRepository reset_sent_messages];
                    punchWidgetTimesheetBreakdownController = nice_fake_for([PunchWidgetTimesheetBreakdownController class]);
                    [injector bind:[PunchWidgetTimesheetBreakdownController class] toInstance:punchWidgetTimesheetBreakdownController];
                    
                });
                
                context(@"when the view is currently on window", ^{
                    
                    beforeEach(^{
                        viewHelper stub_method(@selector(isViewControllerCurrentlyOnWindow:)).with(subject).again().and_return(YES);
                        [punchWidgetSummaryDeferred resolveWithValue:timesheetInfo];

                    });
                    it(@"should not ask the punch widget repository for the punch widget info", ^{
                        punchWidgetRepository should_not have_received(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"timesheet-uri");
                    });
                    
                    it(@"should add PunchWidgetTimesheetBreakdownController as a child controller to WidgetTimesheetDetailsController", ^{
                        childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,punchWidgetTimesheetBreakdownController,subject,subject.widgetContainerViews[0]);
                    });
                    
                    it(@"should update the WidgetTimesheet with the Punch Meta Data", ^{
                        WidgetData *widgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:expectedPunchWidgetData timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"];
                        subject.widgetTimesheet.widgetsMetaData[0] should equal(widgetData);
                    });
                    
                    it(@"should correctly set up PunchWidgetTimesheetBreakdownController", ^{
                        punchWidgetTimesheetBreakdownController should have_received(@selector(setupWithPunchWidgetData:delegate:hasBreakAccess:)).with(expectedPunchWidgetData,subject,YES);
                    });
                });
                
                context(@"when the view is currently not on window", ^{
                    
                    beforeEach(^{
                        viewHelper stub_method(@selector(isViewControllerCurrentlyOnWindow:)).with(subject).again().and_return(NO);
                        [punchWidgetSummaryDeferred resolveWithValue:timesheetInfo];
                    });
                    
                    it(@"should add PunchWidgetTimesheetBreakdownController as a child controller to WidgetTimesheetDetailsController", ^{
                        childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,punchWidgetTimesheetBreakdownController,subject,subject.widgetContainerViews[0]);
                    });
                    
                    it(@"should update the WidgetTimesheet with the Punch Meta Data", ^{
                        WidgetData *widgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:expectedPunchWidgetData timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"];
                        subject.widgetTimesheet.widgetsMetaData[0] should equal(widgetData);
                    });
                    
                    it(@"should correctly set up PunchWidgetTimesheetBreakdownController", ^{
                        punchWidgetTimesheetBreakdownController should_not have_received(@selector(setupWithPunchWidgetData:delegate:hasBreakAccess:));
                    });
                });
            });
        });
    });
    
    describe(@"-viewDidAppear:", ^{
        beforeEach(^{
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
            subject.view should_not be_nil;
            [subject viewDidAppear:YES];
            
        });
        
        context(@"presenting TimesheetPeriodAndSummaryController", ^{
            
            it(@"should add TimesheetPeriodAndSummaryController as a child controller to WidgetTimesheetDetailsController", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(timesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
            });
            
            it(@"should correctly set up TimesheetSummaryController", ^{
                timesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(widgetTimesheet,subject,subject);
            });
            
            __block TimesheetPeriodAndSummaryController *newTimesheetSummaryController;
            context(@"when the view appears again", ^{
                beforeEach(^{
                    newTimesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
                    [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:newTimesheetSummaryController];
                    [subject viewDidAppear:true];
                });
                
                it(@"should replace TimesheetPeriodAndSummaryController as a child controller to WidgetTimesheetDetailsController", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetSummaryController,newTimesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
                });
                
                it(@"should correctly set up TimesheetSummaryController", ^{
                    newTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(widgetTimesheet,subject,subject);
                });
            });
        });
        
        context(@"presenting TimesheetStatusAndSummaryController", ^{
            
            it(@"should add TimesheetStatusAndSummaryController as a child controller to WidgetTimesheetDetailsController", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(timesheetStatusAndSummaryController,subject,subject.timesheetStatusAndSummaryContainerView);
            });
            
            it(@"should correctly set up TimesheetStatusAndSummaryController", ^{
                timesheetStatusAndSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:)).with(widgetTimesheet,subject);
            });
            
            __block TimesheetStatusAndSummaryController *newTimesheetStatusAndSummaryController;
            context(@"when the view appears again", ^{
                beforeEach(^{
                    newTimesheetStatusAndSummaryController = nice_fake_for([TimesheetStatusAndSummaryController class]);
                    [injector bind:[TimesheetStatusAndSummaryController class] toInstance:newTimesheetStatusAndSummaryController];
                    [subject viewDidAppear:true];
                });
                
                it(@"should replace TimesheetStatusAndSummaryController as a child controller to WidgetTimesheetDetailsController", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetStatusAndSummaryController,newTimesheetStatusAndSummaryController,subject,subject.timesheetStatusAndSummaryContainerView);
                });
                
                it(@"should correctly set up TimesheetStatusAndSummaryController", ^{
                    newTimesheetStatusAndSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:)).with(widgetTimesheet,subject);
                });
            });
        });
        
        context(@"presenting DurationSummaryWithoutOffsetController", ^{
            
            it(@"should add DurationSummaryWithoutOffsetController as a child controller to WidgetTimesheetDetailsController", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(durationsController,subject,subject.timesheetDurationsSummaryContainerView);
            });
            
            it(@"should correctly set up DurationSummaryWithoutOffsetController", ^{
                durationsController should have_received(@selector(setupWithTimesheetDuration:delegate:hasBreakAccess:)).with(timesheetDuration,subject,YES);
            });
            
            __block DurationSummaryWithoutOffsetController *newDurationsController;
            context(@"when the view appears again", ^{
                beforeEach(^{
                    newDurationsController = nice_fake_for([DurationSummaryWithoutOffsetController class]);
                    [injector bind:[DurationSummaryWithoutOffsetController class] toInstance:newDurationsController];
                    [subject viewDidAppear:true];
                });
                
                it(@"should replace DurationSummaryWithoutOffsetController as a child controller to WidgetTimesheetDetailsController", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(durationsController,newDurationsController,subject,subject.timesheetDurationsSummaryContainerView);
                });
                
                it(@"should correctly set up DurationSummaryWithoutOffsetController", ^{
                    newDurationsController should have_received(@selector(setupWithTimesheetDuration:delegate:hasBreakAccess:)).with(timesheetDuration,subject,YES);
                });
            });
        }); 
        
        context(@"when the timesheet status is submitting", ^{
            beforeEach(^{
                intialTimesheetStatus = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:timesheet-status:submitting"     
                                                                                   approvalStatus:@"Some-value"];
                Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);;
                widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested); 
                [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
                subject.view should_not be_nil;
                [subject viewDidAppear:YES];
            }); 
            
            itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
                sharedContext[@"shouldVerifyForIsEnabled"] = @0;
                sharedContext[@"subject"] = subject;
            });
        });
        
        context(@"when the timesheet status is not submitting", ^{
            beforeEach(^{
                intialTimesheetStatus = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:timesheet-status:open"     
                                                                                   approvalStatus:@"Some-value"];
                Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);;
                widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil,false,false,false,Attested); 
                [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
                subject.view should_not be_nil;
                [subject viewDidAppear:YES];
            });
            
            itShouldBehaveLike(@"sharedContextForVerifyingContainerViewUserInteractions",  ^(NSMutableDictionary *sharedContext) {
                sharedContext[@"shouldVerifyForIsEnabled"] = @1;
                sharedContext[@"subject"] = subject;
            });
        });
    });
    
    describe(@"As a <TimesheetStatusAndSummaryControllerDelegate>", ^{
        beforeEach(^{
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
        });
        
        context(@"timesheetStatusAndSummaryControllerIntendsToUpdateItsContainerWithHeight:", ^{
            beforeEach(^{
                [subject timesheetStatusAndSummaryControllerIntendsToUpdateItsContainerWithHeight:10];
                
            });
            it(@"should inform its delegate to update its container height", ^{
                subject.timesheetStatusAndSummaryContainerHeightConstraint.constant should equal(10);
            });
        });
        
        context(@"timesheetStatusAndSummaryControllerDidTapissuesButton:", ^{
            __block ViolationsSummaryController <CedarDouble>*violationsSummaryController;
            __block KSPromise *expectedViolationPromise;
            __block id <ViolationsSummaryControllerDelegate> expectedDelegate;
            __block UINavigationController *navigationController;
            beforeEach(^{
                
                [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
                navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                subject.view should_not be_nil;
                [subject viewDidAppear:true];
                spy_on(navigationController);
            });
            
            afterEach(^{
                stop_spying_on(navigationController);
            });
            
            context(@"Setting up ViolationsSummaryController", ^{
                beforeEach(^{
                    
                    violationsSummaryController = (id)[[ViolationsSummaryController alloc]initWithSupervisorDashboardSummaryRepository:nil
                                                                                                       violationSectionHeaderPresenter:nil
                                                                                                         selectedWaiverOptionPresenter:nil 
                                                                                                            violationSeverityPresenter:nil
                                                                                                                      teamTableStylist:nil
                                                                                                                       spinnerDelegate:nil 
                                                                                                                                 theme:nil];
                    [injector bind:[ViolationsSummaryController class] toInstance:violationsSummaryController];
                    spy_on(violationsSummaryController);
                    
                    violationsSummaryController stub_method(@selector(setupWithViolationSectionsPromise:delegate:)).and_do_block(^void(KSPromise *promise, id<ViolationsSummaryControllerDelegate> delegate){
                        expectedViolationPromise = promise;
                        expectedDelegate = delegate;
                    });
                    
                    [subject timesheetStatusAndSummaryControllerDidTapissuesButton:(id)[NSNull null]];
                    
                });
                
                afterEach(^{
                    stop_spying_on(violationsSummaryController);
                });
                
                it(@"should correctly set up the ViolationsSummaryController", ^{
                    violationsSummaryController should have_received(@selector(setupWithViolationSectionsPromise:delegate:));
                    expectedViolationPromise.value should equal(violationsAndWaivers);
                    expectedDelegate should be_same_instance_as(subject);
                });
                
                it(@"should present ViolationsSummaryController on the navigationcontroller", ^{
                    navigationController should have_received(@selector(pushViewController:animated:)).with(violationsSummaryController,true);
                });
            });
            
        });
    });
    
    describe(@"When user intends to do a action while another Timesheet summary fetch is in progress", ^{
        
        __block KSDeferred *deferred;
        __block TimesheetPeriodAndSummaryController *clientStatusTimesheetSummaryController;
        __block TimesheetStatusAndSummaryController *clientStatusTimesheetStatusAndSummaryController;
        
        beforeEach(^{
            deferred = [[KSDeferred alloc]init];
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:NO isSupervisorContext:NO userUri:@"user-uri"];
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
            clientStatusTimesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
            [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:clientStatusTimesheetSummaryController];
            
            clientStatusTimesheetStatusAndSummaryController = nice_fake_for([TimesheetStatusAndSummaryController class]);
            [injector bind:[TimesheetStatusAndSummaryController class] toInstance:clientStatusTimesheetStatusAndSummaryController];
            
            userActionForTimesheetRepository stub_method(@selector(userActionOnTimesheetWithType:timesheetUri:comments:)).with(RightBarButtonActionTypeSubmit,@"timesheet-uri",nil).and_return(deferred.promise);
            
            [subject userIntendsTo:RightBarButtonActionTypeSubmit presenter:(id)[NSNull null]];
        });
        
        it(@"should submit the action to the UserActionForTimesheetRepository", ^{
            userActionForTimesheetRepository should have_received(@selector(userActionOnTimesheetWithType:timesheetUri:comments:)).with(RightBarButtonActionTypeSubmit, @"timesheet-uri",nil);
        });
        
        it(@"should show the spinner", ^{
            delegate should have_received(@selector(widgetTimesheetDetailsController:actionButton:)).with(subject,barButtonItemWithActivity);
        });
        
        
        
        context(@"When Submit succeeds", ^{
            __block KSDeferred *timesummaryDeferred;
            beforeEach(^{
                timesummaryDeferred = [[KSDeferred alloc]init];
                widgetTimesheetSummaryRepository stub_method(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet).and_return(timesummaryDeferred.promise);
                spy_on(timesummaryDeferred.promise);
                [deferred resolveWithValue:nil];
            });
            
            afterEach(^{
                stop_spying_on(timesummaryDeferred.promise);
            });
            
            it(@"should fetch the newest timesheet summary", ^{
                widgetTimesheetSummaryRepository should have_received(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet);
            });
            
            context(@"when user intends to fetch a new timesheet summary while the older is still in queue", ^{
                __block KSDeferred *newTimesummaryDeferred;
                
                beforeEach(^{
                    newTimesummaryDeferred = [[KSDeferred alloc]init];
                    widgetTimesheetSummaryRepository stub_method(@selector(fetchSummaryForTimesheet:)).and_return(newTimesummaryDeferred.promise);
                    KSPromise *promise = [subject violationsSummaryControllerDidRequestViolationSectionsPromise:(id)[NSNull null]];
                    promise should_not be_nil;
                });
                
                it(@"should cancel the older timesheet summary promise", ^{
                    timesummaryDeferred.promise should have_received(@selector(cancel));
                });
            });
            
        });
        
    });
    
    describe(@"As a <PunchWidgetTimesheetBreakdownControllerDelegate>", ^{
        
        __block NSArray *widgetMetadata;
        __block KSDeferred *punchWidgetDeferred;
        beforeEach(^{
            NSString *widgetUri = @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry";
            WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:nil 
                                                                      timesheetWidgetTypeUri:widgetUri];
            widgetMetadata = @[punchWidgetData];
            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);;
            widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,false,false,false,Attested); 
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
            punchWidgetDeferred = [[KSDeferred alloc]init];
            punchWidgetRepository stub_method(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"timesheet-uri").and_return(punchWidgetDeferred.promise);
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
        });
        
        context(@"punchWidgetTimesheetBreakdownController:intendsToUpdateItsContainerWithHeight:", ^{
            beforeEach(^{
                [subject punchWidgetTimesheetBreakdownController:(id)[NSNull null] intendsToUpdateItsContainerWithHeight:10];
                
            });
            it(@"should inform its delegate to update its container height", ^{
                subject.widgetHeightConstraints[0].constant should equal(10);
            });
        });
        
        context(@"punchWidgetTimesheetBreakdownController:didSelectDayWithTimesheetDaySummary:", ^{
            __block TimesheetDaySummary *timesheetDaySummary;
            __block NSCalendar *calendar;
            __block NSDate *date;
            __block DayController *dayController;
            beforeEach(^{
                timesheetDaySummary = nice_fake_for([TimesheetDaySummary class]);
                calendar = nice_fake_for([NSCalendar class]);
                date = [NSDate dateWithTimeIntervalSince1970:0];
                NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
                dateComponents.hour = 1;
                dateComponents.minute = 2;
                dateComponents.second = 3;
                calendar stub_method(@selector(dateFromComponents:)).with(dateComponents).and_return(date);
                [injector bind:InjectorKeyCalendarWithLocalTimeZone toInstance:calendar];
                
                dayController = [[DayController alloc]initWithDayTimeSummaryTitlePresenter:nil
                                                               dayTimeSummaryCellPresenter:nil
                                                                     childControllerHelper:nil 
                                                                               userSession:nil
                                                                                     theme:nil];
                [injector bind:[DayController class] toInstance:dayController];
                
                spy_on(dayController);

                timesheetDaySummary stub_method(@selector(dateComponents)).and_return(dateComponents);
                [subject punchWidgetTimesheetBreakdownController:(id)[NSNull null] didSelectDayWithTimesheetDaySummary:timesheetDaySummary];
                
            });
            
            afterEach(^{
                stop_spying_on(dayController);
            });
            
            it(@"should inform its delegate to update its container height", ^{
                dayController should have_received(@selector(setupWithPunchChangeObserverDelegate:timesheetDaySummary:hasBreakAccess:delegate:userURI:date:)).with(nil,timesheetDaySummary,true,subject,@"user-uri",date);
            });
        });
    });
    
    describe(@"As a <PayWidgetHomeControllerDelegate>", ^{
        
        beforeEach(^{
            Paycode *payCode = nice_fake_for([Paycode class]);
            PayWidgetData *payWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil grossPay:nil actualsByPaycode:nil actualsByDuration:@[payCode]];
            WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:payWidgetData
                                                                      timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"];
            NSArray *widgetMetadata = @[punchWidgetData];
            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,payWidgetData);;
            widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,true,true,false,Attested);
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
        });
        
        context(@"payWidgetHomeController:intendsToUpdateItsContainerWithHeight:", ^{
            beforeEach(^{
                [subject payWidgetHomeController:(id)[NSNull null] intendsToUpdateItsContainerWithHeight:10];
                
            });
            it(@"should inform its delegate to update its container height", ^{
                subject.widgetHeightConstraints[0].constant should equal(10);
            });
        });
    });
    
    describe(@"As a <NoticeWidgetControllerDelegate>", ^{
        
        beforeEach(^{
            NoticeWidgetData *noticeWidgetData = [[NoticeWidgetData alloc]initWithTitle:@"some-title" description:@"some-description"];
            WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:noticeWidgetData
                                                                      timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:notice"];
            NSArray *widgetMetadata = @[punchWidgetData];
            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);
            widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,false,false,false,Attested);
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
            
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
        });
        
        
        context(@"noticeWidgetController:intendsToUpdateItsContainerWithHeight:", ^{
            beforeEach(^{
                [subject noticeWidgetController:(id)[NSNull null] didIntendToUpdateItsContainerHeight:(CGFloat)10.0];
            });
            it(@"should inform its delegate to update its container height", ^{
                subject.widgetHeightConstraints[0].constant should equal(10);
            });
        });
    });
    
    describe(@"As a <AttestationWidgetControllerDelegate>", ^{
        
        beforeEach(^{
            NoticeWidgetData *noticeWidgetData = [[NoticeWidgetData alloc]initWithTitle:@"some-title" description:@"some-description"];
            WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:noticeWidgetData
                                                                      timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:attestation"];
            NSArray *widgetMetadata = @[punchWidgetData];
            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);
            widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,false,false,false,Attested);
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
            
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
        });
        
        
        context(@"attestationWidgetController:intendsToUpdateItsContainerWithHeight:", ^{
            beforeEach(^{
                [subject attestationWidgetController:(id)[NSNull null] didIntendToUpdateItsContainerHeight:(CGFloat)10.0];
            });
            it(@"should inform its delegate to update its container height", ^{
                subject.widgetHeightConstraints[0].constant should equal(10);
            });
        });
    });
    
    describe(@"As a <PlaceholderControllerDelegate>", ^{
        
        __block NSArray *widgetMetadata;
        __block KSDeferred *punchWidgetDeferred;
        __block NSString *widgetUri;
        beforeEach(^{
            widgetUri = @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry";
            WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:nil 
                                                                      timesheetWidgetTypeUri:widgetUri];
            widgetMetadata = @[punchWidgetData];
            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);;
            widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,false,false,false,Attested); 
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:YES userUri:@"user-uri"];
            punchWidgetDeferred = [[KSDeferred alloc]init];
            punchWidgetRepository stub_method(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"timesheet-uri").and_return(punchWidgetDeferred.promise);
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
        });
        
        context(@"placeholderController:intendsToUpdateItsContainerWithHeight:", ^{
            beforeEach(^{
                [subject placeholderController:(id)[NSNull null] intendsToUpdateItsContainerWithHeight:10 forWidgetWithUri:widgetUri];
                
            });
            it(@"should inform its delegate to update its container height", ^{
                subject.widgetHeightConstraints[0].constant should equal(10);
            });
        });
    });
    
    describe(@"As a <DayControllerDelegate>", ^{
        __block KSDeferred *summaryDeferred;
        __block KSDeferred *punchWidgetDeferred;
        __block KSDeferred *intialPunchWidgetDeferred;
        __block NSArray *widgetMetadata;

        
        beforeEach(^{
            summaryDeferred = [[KSDeferred alloc]init];
            
            
            WidgetData *punchWidgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:nil 
                                                                      timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"];
            widgetMetadata = @[punchWidgetData];
            Summary *summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,timeSheetPermittedActions,@"urn:replicon:mobile:timesheet:widget:summary:status:out-of-date",nil,scriptCalculationDate,nil);;
            widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,false,false,false,Attested); 
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate hasBreakAccess:YES isSupervisorContext:NO userUri:@"user-uri"];
            
            widgetTimesheetSummaryRepository stub_method(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet).and_return(summaryDeferred.promise);
            
            punchWidgetDeferred = [[KSDeferred alloc]init];
            punchWidgetRepository stub_method(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"timesheet-uri").and_return(intialPunchWidgetDeferred.promise);
            
            subject.view should_not be_nil;
            [subject viewDidAppear:true];
            
            TimesheetInfo *timesheetInfo = nice_fake_for([TimesheetInfo class]);
            [intialPunchWidgetDeferred resolveWithValue:timesheetInfo];
            
        });
        
        context(@"needsTimePunchesPromiseWhenUserEditOrAddOrDeletePunchForDayController:", ^{
            __block KSPromise *expectedTimesheetSummaryPromise;
            __block Summary *summary;
            __block AllViolationSections *violationsAndWaivers;
            __block TimeSheetPermittedActions *newestPermittedActions;
            __block UIBarButtonItem *newestRightBarButtonItem;
            __block NSDate *newScriptCalculationDate;
            beforeEach(^{
                punchWidgetDeferred = [[KSDeferred alloc]init];
                punchWidgetRepository stub_method(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"timesheet-uri").again().and_return(punchWidgetDeferred.promise);
                newScriptCalculationDate = [NSDate dateWithTimeIntervalSince1970:1];
                violationsAndWaivers = nice_fake_for([AllViolationSections class]);
                newestPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                summary = doSummarySubjectAction(intialTimesheetStatus,nil,violationsAndWaivers,0,newestPermittedActions,nil,nil,newScriptCalculationDate,nil);;
                expectedTimesheetSummaryPromise = [subject needsTimePunchesPromiseWhenUserEditOrAddOrDeletePunchForDayController:(id)[NSNull null]];
            });
            
            it(@"should fetch the newest timesheet summary", ^{
                widgetTimesheetSummaryRepository should have_received(@selector(fetchSummaryForTimesheet:)).with(widgetTimesheet);
            });
            
            it(@"should ask the punch widget repository for the punch widget info", ^{
                punchWidgetRepository should have_received(@selector(fetchPunchWidgetInfoForTimesheetWithUri:)).with(@"timesheet-uri");
            });
            
            context(@"Timesheet summary promise", ^{
                
                context(@"should correctly resolve the promise", ^{
                    __block TimesheetPeriodAndSummaryController *newTimesheetSummaryController;
                    
                    beforeEach(^{
                        newTimesheetSummaryController = nice_fake_for([TimesheetPeriodAndSummaryController class]);
                        [injector bind:[TimesheetPeriodAndSummaryController class] toInstance:newTimesheetSummaryController];
                        
                        widgetTimesheetDetailsSeriesControllerPresenter stub_method(@selector(navigationBarRightButtonItemForTimesheetPermittedActions:)).with(newestPermittedActions).and_return(newestRightBarButtonItem);
                        
                        [summaryDeferred resolveWithValue:summary];                     
                    });
                    
                    it(@"should correctly set up TimesheetSummaryController", ^{
                        
                        WidgetTimesheet *newExpectedTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,widgetMetadata,nil,false,false,false,Attested);
                        newTimesheetSummaryController should have_received(@selector(setupWithWidgetTimesheet:delegate:navigationDelegate:)).with(newExpectedTimesheet,subject,subject);
                        
                    });
                    
                    it(@"should replace the older TimesheetSummaryController", ^{
                        childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetSummaryController,newTimesheetSummaryController,subject,subject.timesheetPeriodAndSummaryContainerView);
                    });
                    
                });
                
                context(@"when promise is rejected", ^{
                    
                    __block NSError *error;
                    beforeEach(^{
                        error = [[NSError alloc]initWithDomain:@"" code:0 userInfo:nil];
                        [childControllerHelper reset_sent_messages];
                        [summaryDeferred rejectWithError:error];
                    });
                    
                    it(@"should not replace the older TimesheetSummaryController", ^{
                        childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,Arguments::anything,subject,subject.timesheetPeriodAndSummaryContainerView);
                    });
                    
                });
            });
            
            context(@"Time punch widget promise ", ^{
                
                context(@"when the promise succeeds", ^{
                    __block TimesheetInfo *timesheetInfo;
                    __block NSArray *dayTimeSummaries; 
                    __block PunchWidgetTimesheetBreakdownController *punchWidgetTimesheetBreakdownController;
                    __block PunchWidgetData *expectedPunchWidgetData;
                    
                    beforeEach(^{
                        punchWidgetTimesheetBreakdownController = nice_fake_for([PunchWidgetTimesheetBreakdownController class]);
                        [injector bind:[PunchWidgetTimesheetBreakdownController class] toInstance:punchWidgetTimesheetBreakdownController];
                        
                        TimesheetDaySummary *timesheetDaySummaryA = nice_fake_for([TimesheetDaySummary class]);
                        TimesheetDaySummary *timesheetDaySummaryB = nice_fake_for([TimesheetDaySummary class]);
                        dayTimeSummaries = @[timesheetDaySummaryA,timesheetDaySummaryB];
                        TimePeriodSummary *timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                        timePeriodSummary stub_method(@selector(dayTimeSummaries)).and_return(dayTimeSummaries);
                        
                        NSDateComponents *regularTimeComponents = [[NSDateComponents alloc]init];
                        regularTimeComponents.hour = 1;
                        regularTimeComponents.minute = 2;
                        regularTimeComponents.second = 3;
                        
                        NSDateComponents *breakTimeComponents = [[NSDateComponents alloc]init];
                        breakTimeComponents.hour = 4;
                        breakTimeComponents.minute = 5;
                        breakTimeComponents.second = 6;
                        
                        NSDateComponents *timeoffComponents = [[NSDateComponents alloc]init];
                        timeoffComponents.hour = 7;
                        timeoffComponents.minute = 8;
                        timeoffComponents.second = 9;
                        
                        timePeriodSummary stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
                        timePeriodSummary stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                        timePeriodSummary stub_method(@selector(timeOffComponents)).and_return(timeoffComponents);
                        
                        timesheetInfo = nice_fake_for([TimesheetInfo class]);
                        timesheetInfo stub_method(@selector(timePeriodSummary)).and_return(timePeriodSummary);
                        
                        TimesheetDuration *timesheetDuration = [[TimesheetDuration alloc]initWithRegularHours:regularTimeComponents 
                                                                                                   breakHours:breakTimeComponents 
                                                                                                 timeOffHours:timeoffComponents];
                        expectedPunchWidgetData = [[PunchWidgetData alloc]initWithDaySummaries:dayTimeSummaries 
                                                                           widgetLevelDuration:timesheetDuration];
                        [punchWidgetDeferred resolveWithValue:timesheetInfo];
                    });
                    
                    it(@"should add PunchWidgetTimesheetBreakdownController as a child controller to WidgetTimesheetDetailsController", ^{
                        childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,punchWidgetTimesheetBreakdownController,subject,subject.widgetContainerViews[0]);
                    });
                    
                    it(@"should update the WidgetTimesheet with the Punch Meta Data", ^{
                        WidgetData *widgetData = [[WidgetData alloc]initWithTimesheetWidgetMetaData:expectedPunchWidgetData timesheetWidgetTypeUri:@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"];
                        subject.widgetTimesheet.widgetsMetaData[0] should equal(widgetData);
                    });
                    
                    it(@"should correctly set up PunchWidgetTimesheetBreakdownController", ^{
                        punchWidgetTimesheetBreakdownController should have_received(@selector(setupWithPunchWidgetData:delegate:hasBreakAccess:)).with(expectedPunchWidgetData,subject,YES);
                    });
                    
                    it(@"should correctly resolve the promise", ^{
                        expectedTimesheetSummaryPromise.value should equal(timesheetInfo);
                    });
                });
                
                context(@"when the promise fails", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = [[NSError alloc]initWithDomain:@"" code:0 userInfo:nil];
                        [punchWidgetDeferred rejectWithError:error];
                    });
                    
                    it(@"should correctly reject the error", ^{
                        expectedTimesheetSummaryPromise.error should equal(error);
                    });
                });
            });
        });
    });
});

SPEC_END
