#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "TimesheetRepository.h"
#import "UserPermissionsStorage.h"
#import "NextGenRepliconTimeSheet-Swift.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WidgetTimesheetDetailsSeriesControllerSpec)

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

describe(@"WidgetTimesheetDetailsSeriesController", ^{
    __block WidgetTimesheetDetailsSeriesController *subject;
    __block id<BSBinder, BSInjector> injector;
    __block DateProvider *dateProvider;
    __block WidgetTimesheetRepository *widgetTimesheetRepository;
    __block KSDeferred *timesheetsDeferred;
    __block id<UserSession> userSession;
    __block ChildControllerHelper <CedarDouble>*childControllerHelper;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block WidgetTimesheetDetailsController *widgetTimesheetDetailsController;
    __block UINavigationController *navigationController;
    __block UIActivityIndicatorView *activityIndicatorView;
    __block NSDate *intialStartDate;
    __block TimeSheetPermittedActions *timeSheetPermittedActions;
    __block UIBarButtonItem *rightBarButtonItem;
    __block WidgetTimesheetSummaryRepository <CedarDouble>*widgetTimesheetSummaryRepository;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        
        widgetTimesheetSummaryRepository = nice_fake_for(@protocol(WidgetTimesheetSummaryRepositoryInterface));
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        userPermissionsStorage stub_method(@selector(breaksRequired)).and_return(YES);
        rightBarButtonItem = nice_fake_for([UIBarButtonItem class]);
        timeSheetPermittedActions = [[TimeSheetPermittedActions alloc]initWithCanSubmitOnDueDate:false
                                                                                       canReopen:false
                                                                            canReSubmitTimeSheet:false];
        dateProvider = nice_fake_for([DateProvider class]);
        widgetTimesheetRepository = nice_fake_for([WidgetTimesheetRepository class]);
        userSession = nice_fake_for(@protocol(UserSession));
        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        
        timesheetsDeferred = [[KSDeferred alloc] init];
        NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *startDateComponents = [[NSDateComponents alloc]init];
        startDateComponents.day = 10;
        startDateComponents.month = 7;
        startDateComponents.year = 2017;
        intialStartDate = [calendar dateFromComponents:startDateComponents];
        
        dateProvider stub_method(@selector(date)).and_return(intialStartDate);
        widgetTimesheetRepository stub_method(@selector(fetchWidgetTimesheetForDate:)).with(intialStartDate).and_return(timesheetsDeferred.promise);
        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");
        
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        childControllerHelper stub_method(@selector(addChildController:toParentController:inContainerView:)).and_do_block(^(UIViewController *childController, UIViewController *parentController, UIView *containerView) {
            [parentController addChildViewController:childController];
        });
        
        widgetTimesheetDetailsController = nice_fake_for([WidgetTimesheetDetailsController class]);
        activityIndicatorView = [[UIActivityIndicatorView alloc]init];
        spy_on(activityIndicatorView);
        rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:activityIndicatorView];
        
        [injector bind:[WidgetTimesheetSummaryRepository class] toInstance:widgetTimesheetSummaryRepository];
        [injector bind:InjectorKeyActivityIndicator toInstance:activityIndicatorView];
        [injector bind:@protocol(SpinnerDelegate) toInstance:spinnerDelegate];
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:[WidgetTimesheetRepository class] toInstance:widgetTimesheetRepository];
        [injector bind:[DateProvider class] toInstance:dateProvider];
        [injector bind:@protocol(SpinnerDelegate) toInstance:spinnerDelegate];
        [injector bind:[WidgetTimesheetDetailsController class] toInstance:widgetTimesheetDetailsController];
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];
        
        subject = [injector getInstance:[WidgetTimesheetDetailsSeriesController class]];
        navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
        spy_on(navigationController);
        subject.navigationItem.rightBarButtonItem = rightBarButtonItem;
        subject.view should_not be_nil;
        
    });
    
    afterEach(^{
        stop_spying_on(navigationController);
        stop_spying_on(activityIndicatorView);
        
    });
    
    context(@"dealloc:", ^{
        beforeEach(^{
            
            @autoreleasepool {
                subject = [injector getInstance:[WidgetTimesheetDetailsSeriesController class]];
                subject = nil;
            };
        });
        
        it(@"should remove all the timesheet summary observers", ^{
            widgetTimesheetSummaryRepository should have_received(@selector(removeAllListeners));
        });
    });
    
    it(@"should request for the current timesheet", ^{
        widgetTimesheetRepository should have_received(@selector(fetchWidgetTimesheetForDate:)).with(intialStartDate);
    });
    
    it(@"should show the navigation bar correctly", ^{
        navigationController should have_received(@selector(setNavigationBarHidden:animated:)).with(false,Arguments::anything);
        subject.title should equal(RPLocalizedString(@"My Timesheet", nil));
        subject.navigationItem.rightBarButtonItem.customView should equal(activityIndicatorView);
        activityIndicatorView should have_received(@selector(startAnimating));
    });
    
    
    
    describe(@"when view loads initially", ^{
        
        context(@"When timesheet promise succeeds", ^{
            
            __block WidgetTimesheet *timesheet;
            beforeEach(^{
                
                Summary *summary = doSummarySubjectAction(nil,nil,nil,0,timeSheetPermittedActions,nil,nil,nil);
                timesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil);
                [timesheetsDeferred resolveWithValue:timesheet];
            });
            
            it(@"should remove all the timesheet summary observers", ^{
                widgetTimesheetSummaryRepository should have_received(@selector(removeAllListeners));
            });
            
            it(@"should add the WidgetTimesheetDetailsControllerontroller as its child controller", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,widgetTimesheetDetailsController,subject,subject.view);
            });
            
            it(@"should set up the WidgetTimesheetDetailsController correctly", ^{
                widgetTimesheetDetailsController should have_received(@selector(setupWithWidgetTimesheet:delegate:hasBreakAccess:isSupervisorContext:userUri:)).with(timesheet,subject,YES,NO,@"user-uri");
            });
            
            it(@"should stop the activity indicator", ^{
                activityIndicatorView should have_received(@selector(stopAnimating));
            });
            
            
        });
        
        context(@"When timesheet promise fails", ^{
            
            beforeEach(^{
                [timesheetsDeferred rejectWithError:nil];
            });
            
            it(@"should not add the WidgetTimesheetDetailsControllerontroller as its child controller", ^{
                childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });
            
            it(@"should stop the activity indicator", ^{
                activityIndicatorView should have_received(@selector(stopAnimating));
            });
            
            it(@"should show the old bar button item", ^{
                subject.navigationItem.rightBarButtonItem should equal(rightBarButtonItem);
            });
            
        });
    });
    
    describe(@"As a <WidgetTimesheetDetailsControllerDelegate>", ^{
        
        __block WidgetTimesheet *timesheet;
        __block NSDate *startDate;
        __block NSDate *endDate;
        
        beforeEach(^{
            NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *startDateComponents = [[NSDateComponents alloc]init];
            startDateComponents.day = 10;
            startDateComponents.month = 7;
            startDateComponents.year = 2017;
            startDate = [calendar dateFromComponents:startDateComponents];
            
            NSDateComponents *endDateComponents = [[NSDateComponents alloc]init];
            endDateComponents.day = 15;
            endDateComponents.month = 7;
            endDateComponents.year = 2017;
            endDate = [calendar dateFromComponents:endDateComponents];
            
            widgetTimesheetDetailsController = nice_fake_for([WidgetTimesheetDetailsController class]);
            [injector bind:[WidgetTimesheetDetailsController class] toInstance:widgetTimesheetDetailsController];
            
            TimesheetPeriod *period = [[TimesheetPeriod alloc]initWithStartDate:startDate endDate:endDate];

            Summary *summary = doSummarySubjectAction(nil,nil,nil,0,timeSheetPermittedActions,nil,nil,nil);
            timesheet = doSubjectAction(@"timesheet-uri", period,summary,nil,nil);
            [timesheetsDeferred resolveWithValue:timesheet];
            
        });
        
        it(@"should remove all the timesheet summary observers", ^{
            widgetTimesheetSummaryRepository should have_received(@selector(removeAllListeners));
        });
        
        context(@"widgetTimesheetDetailsControllerRequestsPreviousTimesheet:", ^{
            
            __block KSDeferred *previousTimesheetsDeferred;
            __block NSDate *expectedPreviousTimesheetDate;
            beforeEach(^{
                NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *startDateComponents = [[NSDateComponents alloc]init];
                startDateComponents.day = 9;
                startDateComponents.month = 7;
                startDateComponents.year = 2017;
                expectedPreviousTimesheetDate = [calendar dateFromComponents:startDateComponents];
                
                previousTimesheetsDeferred = [[KSDeferred alloc]init];
                widgetTimesheetRepository stub_method(@selector(fetchWidgetTimesheetForDate:)).with(expectedPreviousTimesheetDate).and_return(previousTimesheetsDeferred.promise);
                [subject widgetTimesheetDetailsControllerRequestsPreviousTimesheet:(id)[NSNull null]];
                [childControllerHelper reset_sent_messages];
                [widgetTimesheetSummaryRepository reset_sent_messages];
                
            });

            
            it(@"should still continue to show activity indicator", ^{
                activityIndicatorView.hidden should be_falsy;
            });
            

            context(@"When timesheet promise succeeds", ^{
                
                __block TimeSheetPermittedActions *newTimeSheetPermittedActions;
                __block WidgetTimesheet *previousTimesheet;
                __block UIBarButtonItem *newRightBarButtonItem;
                
                beforeEach(^{
                    newRightBarButtonItem = nice_fake_for([UIBarButtonItem class]);
                    newTimeSheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);                    

                    Summary *summary = doSummarySubjectAction(nil,nil,nil,0,newTimeSheetPermittedActions,nil,nil,nil);
                    previousTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil);
                    [previousTimesheetsDeferred resolveWithValue:previousTimesheet];
                });
                
                it(@"should remove all the timesheet summary observers", ^{
                    widgetTimesheetSummaryRepository should have_received(@selector(removeAllListeners));
                });
                
                it(@"should add the WidgetTimesheetDetailsControllerontroller as its child controller", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,widgetTimesheetDetailsController,subject,subject.view);
                });
                
                it(@"should set up the WidgetTimesheetDetailsController correctly", ^{
                    widgetTimesheetDetailsController should have_received(@selector(setupWithWidgetTimesheet:delegate:hasBreakAccess:isSupervisorContext:userUri:)).with(previousTimesheet,subject,YES,NO,@"user-uri");
                });
                
                it(@"should stop the activity indicator", ^{
                    activityIndicatorView should have_received(@selector(stopAnimating));
                });
                
            });
            
            context(@"When timesheet promise fails", ^{
                beforeEach(^{
                    [previousTimesheetsDeferred rejectWithError:nil];
                });
                
                it(@"should intially show the spinner controller", ^{
                    childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:));
                });
                
                it(@"should stop the activity indicator", ^{
                    activityIndicatorView should have_received(@selector(stopAnimating));
                });
            });
        });
        
        context(@"widgetTimesheetDetailsControllerRequestsNextTimesheet:", ^{
            
            __block KSDeferred *nextTimesheetsDeferred;
            __block NSDate *expectedNextTimesheetDate;
            beforeEach(^{
                NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *startDateComponents = [[NSDateComponents alloc]init];
                startDateComponents.day = 16;
                startDateComponents.month = 7;
                startDateComponents.year = 2017;
                expectedNextTimesheetDate = [calendar dateFromComponents:startDateComponents];
                nextTimesheetsDeferred = [[KSDeferred alloc]init];
                widgetTimesheetRepository stub_method(@selector(fetchWidgetTimesheetForDate:)).with(expectedNextTimesheetDate).and_return(nextTimesheetsDeferred.promise);
                [subject widgetTimesheetDetailsControllerRequestsNextTimesheet:(id)[NSNull null]];
                [childControllerHelper reset_sent_messages];
                [widgetTimesheetSummaryRepository reset_sent_messages];
                
            });
            
            it(@"should request for the next timesheet", ^{
                widgetTimesheetRepository should have_received(@selector(fetchWidgetTimesheetForDate:)).with(expectedNextTimesheetDate);
            });
            
            it(@"should still continue to show activity indicator", ^{
                activityIndicatorView.hidden should be_falsy;
            });
            
            context(@"When timesheet promise succeeds", ^{
                __block TimeSheetPermittedActions *newTimeSheetPermittedActions;
                __block WidgetTimesheet *nextTimesheet;
                
                beforeEach(^{
                    newTimeSheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                    Summary *summary = doSummarySubjectAction(nil,nil,nil,0,newTimeSheetPermittedActions,nil,nil,nil);
                    nextTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil);
                    [nextTimesheetsDeferred resolveWithValue:nextTimesheet];
                });
                
                it(@"should remove all the timesheet summary observers", ^{
                    widgetTimesheetSummaryRepository should have_received(@selector(removeAllListeners));
                });
                
                it(@"should add the WidgetTimesheetDetailsController as its child controller", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,widgetTimesheetDetailsController,subject,subject.view);
                });
                
                it(@"should set up the WidgetTimesheetDetailsController correctly", ^{
                    widgetTimesheetDetailsController should have_received(@selector(setupWithWidgetTimesheet:delegate:hasBreakAccess:isSupervisorContext:userUri:)).with(nextTimesheet,subject,YES,NO,@"user-uri");
                });
                
                it(@"should stop the activity indicator", ^{
                    activityIndicatorView should have_received(@selector(stopAnimating));
                });
            });
            
            context(@"When timesheet promise fails", ^{
                beforeEach(^{
                    [nextTimesheetsDeferred rejectWithError:nil];
                });
                
                it(@"should intially show the spinner controller", ^{
                    childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:));
                });
                
                it(@"should stop the activity indicator", ^{
                    activityIndicatorView should have_received(@selector(stopAnimating));
                });
                
            });
        });
        
        context(@"when user requests previous timesheet when older timesheet request is still in progress", ^{
            __block KSDeferred *intialTimesheetsDeferred;
            __block KSDeferred *mostRecentPreviousTimesheetsDeferred;
            
            __block NSDate *expectedPreviousTimesheetDate;
            beforeEach(^{
                NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *startDateComponents = [[NSDateComponents alloc]init];
                startDateComponents.day = 9;
                startDateComponents.month = 7;
                startDateComponents.year = 2017;
                expectedPreviousTimesheetDate = [calendar dateFromComponents:startDateComponents];
                
                intialTimesheetsDeferred = [[KSDeferred alloc]init];
                mostRecentPreviousTimesheetsDeferred = [[KSDeferred alloc]init];
                widgetTimesheetRepository stub_method(@selector(fetchWidgetTimesheetForDate:)).with(expectedPreviousTimesheetDate).and_return(intialTimesheetsDeferred.promise);
                [subject widgetTimesheetDetailsControllerRequestsPreviousTimesheet:(id)[NSNull null]];
                
                widgetTimesheetRepository stub_method(@selector(fetchWidgetTimesheetForDate:)).and_return(mostRecentPreviousTimesheetsDeferred.promise);
                
                [subject widgetTimesheetDetailsControllerRequestsPreviousTimesheet:(id)[NSNull null]];
                
                
            });
            
            it(@"should cancel older timesheet promise", ^{
                intialTimesheetsDeferred.promise.cancelled should be_truthy;
            });
        });
        
        context(@"when user requests next timesheet when older timesheet request is still in progress", ^{
            __block KSDeferred *initialTimesheetsDeferred;
            __block NSDate *expectedNextTimesheetDate;
            __block KSDeferred *mostRecentNextTimesheetsDeferred;
            
            beforeEach(^{
                NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *startDateComponents = [[NSDateComponents alloc]init];
                startDateComponents.day = 9;
                startDateComponents.month = 7;
                startDateComponents.year = 2017;
                expectedNextTimesheetDate = [calendar dateFromComponents:startDateComponents];
                
                initialTimesheetsDeferred = [[KSDeferred alloc]init];
                mostRecentNextTimesheetsDeferred = [[KSDeferred alloc]init];
                widgetTimesheetRepository stub_method(@selector(fetchWidgetTimesheetForDate:)).and_return(initialTimesheetsDeferred.promise);
                [subject widgetTimesheetDetailsControllerRequestsNextTimesheet:(id)[NSNull null]];
                
                widgetTimesheetRepository stub_method(@selector(fetchWidgetTimesheetForDate:)).again().and_return(mostRecentNextTimesheetsDeferred.promise);
                [subject widgetTimesheetDetailsControllerRequestsNextTimesheet:(id)[NSNull null]];
                
            });
            
            it(@"should cancel older timesheet promise", ^{
                initialTimesheetsDeferred.promise.cancelled should be_truthy;
            });
        });
        
        context(@"widgetTimesheetDetailsController:actionButton:", ^{
            
            __block UIBarButtonItem *expectedRightBarButtonItem;
            beforeEach(^{
                expectedRightBarButtonItem = nice_fake_for([UIBarButtonItem class]);
                [subject widgetTimesheetDetailsController:nice_fake_for([UIViewController class]) actionButton:expectedRightBarButtonItem];
                
            });
            
            it(@"should set the right bar button correctly", ^{
                subject.navigationItem.rightBarButtonItem should equal(expectedRightBarButtonItem);
            });
        });
        
    });
});

SPEC_END
