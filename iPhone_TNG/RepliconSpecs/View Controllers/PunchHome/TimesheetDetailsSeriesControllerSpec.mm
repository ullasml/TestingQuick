#import <Cedar/Cedar.h>
#import "TimesheetDetailsSeriesController.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "TimesheetRepository.h"
#import "TimesheetDetailsController.h"
#import <KSDeferred/KSDeferred.h>
#import "ChildControllerHelper.h"
#import "IndexCursor.h"
#import "UserSession.h"
#import "TimesheetForDateRange.h"
#import "TimesheetDetailsSeriesController+RightBarButtonAction.h"
#import "TimePeriodSummary.h"
#import "TimesheetPeriod.h"
#import "TimeSheetPermittedActions.h"
#import "TimeSummaryRepository.h"
#import "UIBarButtonItem+Spec.h"
#import "CommentViewController.h"
#import "DateProvider.h"
#import "TimesheetInfo.h"
#import "UserPermissionsStorage.h"
#import "TimesheetActionRequestBodyProvider.h"
#import "SpinnerDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetDetailsSeriesControllerSpec)

sharedExamplesFor(@"sharedContextForRefreshTimesheetDetailsControllerWithTimesheet", ^(NSDictionary *sharedContext) {
    
    __block KSDeferred *timesheetDeferred;
    __block TimesheetDetailsSeriesController *subject;
    __block KSPromise <CedarDouble>*previousTimesheetPromise;
    __block id<BSBinder, BSInjector> injector;
    __block SpinnerOperationsCounter *spinnerOperationsCounter;
    __block ChildControllerHelper *childControllerHelper;
    __block TimesheetDetailsController *timesheetDetailsController;


    describe(@"when Timesheet Details Controller is refreshed With Timesheet", ^{
        
        __block TimesheetInfo *timesheet;
        __block IndexCursor *indexCursor;
        __block TimesheetInfo *olderTimesheet;

        
        beforeEach(^{
            timesheetDeferred                   = sharedContext[@"timesheetDeferred"];
            injector                            = sharedContext[@"injector"];
            subject                             = sharedContext[@"subject"];
            previousTimesheetPromise            = sharedContext[@"previousTimesheetPromise"];
            childControllerHelper               = sharedContext[@"childControllerHelper"];
            olderTimesheet                      = sharedContext[@"olderTimesheet"];
            timesheetDetailsController          = [[TimesheetDetailsController alloc] initWithTimesheetInfoAndPermissionsRepository:nil
                                                                                                              childControllerHelper:nil
                                                                                                              timeSummaryRepository:nil
                                                                                                                violationRepository:nil
                                                                                                                auditHistoryStorage:nil
                                                                                                                  punchRulesStorage:nil
                                                                                                                              theme:nil];
            spinnerOperationsCounter            = nice_fake_for([SpinnerOperationsCounter class]);
            [injector bind:[SpinnerOperationsCounter class] toInstance:spinnerOperationsCounter];
            [injector bind:[TimesheetDetailsController class] toInstance:timesheetDetailsController];
            timesheet = nice_fake_for([TimesheetInfo class]);
            indexCursor = nice_fake_for([IndexCursor class]);
            [injector bind:[IndexCursor class] toInstance:indexCursor];
            spy_on(timesheetDetailsController);
        });
        
        afterEach(^{
            stop_spying_on(timesheetDetailsController);
        });
        
        it(@"should cancel if there are any older timesheet promise", ^{
            previousTimesheetPromise.cancelled should be_truthy;
        });
        
        describe(@"When Timesheet promise resolves", ^{
            beforeEach(^{
                [timesheetDeferred resolveWithValue:timesheet];
            });
            
            it(@"should set the timesheet refrence correctly", ^{
                subject.timesheetInfo should equal(timesheet);
            });
            
            it(@"should configure indexCursor correctly", ^{
                indexCursor should have_received(@selector(setUpWithCurrentTimesheet:olderTimesheet:)).with(timesheet,nil);
            });
            
            it(@"should configure spinnerOperationsCounter correctly", ^{
                spinnerOperationsCounter should have_received(@selector(setupWithDelegate:)).with(subject);
            });
            
            it(@"should have configured a timesheet details controller with a spinner operations counter and a cursor", ^{
                timesheetDetailsController should have_received(@selector(setupWithSpinnerOperationsCounter:delegate:timesheet:hasPayrollSummary:hasBreakAccess:cursor:userURI:title:))
                .with(spinnerOperationsCounter,subject,timesheet, NO,NO, indexCursor, @"user-uri",nil);
            });
            
            it(@"should present the timesheet details controller", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:))
                .with(Arguments::anything, timesheetDetailsController, subject, subject.view);
            });
        });
        
        describe(@"When Timesheet promise fails", ^{
            beforeEach(^{
                [timesheetDeferred rejectWithError:nil];
            });
            
            it(@"should set the timesheet refrence correctly", ^{
                subject.timesheetInfo should equal(olderTimesheet);
            });
            
            it(@"should configure indexCursor correctly", ^{
                indexCursor should have_received(@selector(setUpWithCurrentTimesheet:olderTimesheet:)).with(nil,olderTimesheet);
            });
            
            it(@"should configure spinnerOperationsCounter correctly", ^{
                spinnerOperationsCounter should have_received(@selector(setupWithDelegate:)).with(subject);
            });
            
            it(@"should have configured a timesheet details controller with a spinner operations counter and a cursor", ^{
                timesheetDetailsController should have_received(@selector(setupWithSpinnerOperationsCounter:delegate:timesheet:hasPayrollSummary:hasBreakAccess:cursor:userURI:title:))
                .with(spinnerOperationsCounter,subject,olderTimesheet, NO,NO, indexCursor, @"user-uri",nil);
            });
            
            it(@"should present the timesheet details controller", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:))
                .with(Arguments::anything, timesheetDetailsController, subject, subject.view);
            });

        });
    });
});

describe(@"TimesheetDetailsSeriesController", ^{
    __block id<BSBinder, BSInjector> injector;
    __block DateProvider *dateProvider;
    __block NSDate *date;
    __block TimesheetRepository *timesheetRepository;
    __block KSDeferred *timesheetsDeferred;
    __block id<UserSession> userSession;
    __block SpinnerOperationsCounter *spinnerOperationsCounter;
    __block ChildControllerHelper *childControllerHelper;
    __block TimesheetDetailsSeriesController *subject;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block TimeSummaryRepository *timeSummaryRepository;
    __block TimesheetActionRequestBodyProvider *timesheetActionRequestBodyProvider;
    __block UINavigationController *navigationController;
    __block UIEdgeInsets expectedContentInset;
    __block TimesheetDetailsController *dummyTimesheetDetailsController;
    __block id<SpinnerDelegate> spinnerDelegate;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        timeSummaryRepository = nice_fake_for([TimeSummaryRepository class]);
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        dateProvider = nice_fake_for([DateProvider class]);
        timesheetRepository = fake_for([TimesheetRepository class]);
        userSession = nice_fake_for(@protocol(UserSession));
        spinnerOperationsCounter = nice_fake_for([SpinnerOperationsCounter class]);
        timesheetActionRequestBodyProvider = nice_fake_for([TimesheetActionRequestBodyProvider class]);

        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        [injector bind:@protocol(SpinnerDelegate) toInstance:spinnerDelegate];

        timesheetsDeferred = [[KSDeferred alloc] init];
        date = [NSDate dateWithTimeIntervalSince1970:0];
        dateProvider stub_method(@selector(date)).and_return(date);
        timesheetRepository stub_method(@selector(fetchTimesheetInfoForDate:)).with(date).and_return(timesheetsDeferred.promise);
        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");
        
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        childControllerHelper stub_method(@selector(addChildController:toParentController:inContainerView:)).and_do_block(^(UIViewController *childController, UIViewController *parentController, UIView *containerView) {
            [parentController addChildViewController:childController];
        });
        
        [injector bind:[TimeSummaryRepository class] toInstance:timeSummaryRepository];
        [injector bind:[TimesheetActionRequestBodyProvider class] toInstance:timesheetActionRequestBodyProvider];
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        [injector bind:[SpinnerOperationsCounter class] toInstance:spinnerOperationsCounter];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:[TimesheetRepository class] toInstance:timesheetRepository];
        [injector bind:[DateProvider class] toInstance:dateProvider];
        
        dummyTimesheetDetailsController = [[TimesheetDetailsController alloc] initWithTimesheetInfoAndPermissionsRepository:nil
                                                                                                      childControllerHelper:nil
                                                                                                      timeSummaryRepository:nil
                                                                                                        violationRepository:nil
                                                                                                        auditHistoryStorage:nil
                                                                                                          punchRulesStorage:nil
                                                                                                                      theme:nil];
        spy_on(dummyTimesheetDetailsController);
        [injector bind:[TimesheetDetailsController class] toInstance:dummyTimesheetDetailsController];

        
        subject = [injector getInstance:[TimesheetDetailsSeriesController class]];
        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
        spy_on(navigationController);
        
        subject.view should_not be_nil;
        
        spy_on(subject.topLayoutGuide);
        subject.topLayoutGuide stub_method(@selector(length)).and_return((CGFloat)42.0f);
        expectedContentInset = UIEdgeInsetsMake(42, 0, 0, 0);
    });
    
    afterEach(^{
        stop_spying_on(navigationController);
    });
    
    it(@"should make a request to fetchTimesheetInfoForDate", ^{
        timesheetRepository should have_received(@selector(fetchTimesheetInfoForDate:)).with(date);
    });
    
    it(@"should set the correct background colour", ^{
        subject.view.backgroundColor should equal([UIColor whiteColor]);
    });
    
    it(@"should set automaticallyAdjustsScrollViewInsets to false", ^{
        subject.automaticallyAdjustsScrollViewInsets should equal(false);
    });
    
    it(@"should add a view controller as its child intially", ^{
        childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
        .with(dummyTimesheetDetailsController, subject, subject.view);
    });
    
    describe(@"when the timesheet promise", ^{
        
        describe(@"resolves", ^{
            
            __block id <Timesheet> timesheet;
            __block IndexCursor *indexCursor;
            __block TimesheetDetailsController *timesheetDetailsController;
            
            
            beforeEach(^{
                timesheet = nice_fake_for(@protocol(Timesheet));
                indexCursor = nice_fake_for([IndexCursor class]);
                [injector bind:[IndexCursor class] toInstance:indexCursor];
                userPermissionsStorage stub_method(@selector(breaksRequired)).and_return(false);
                timesheetDetailsController = nice_fake_for([TimesheetDetailsController class]);
                [injector bind:[TimesheetDetailsController class] toInstance:timesheetDetailsController];
                [timesheetsDeferred resolveWithValue:timesheet];
            });
            
            it(@"should have configured a timesheet details controller with a spinner operations counter and a cursor", ^{
                indexCursor should have_received(@selector(setUpWithCurrentTimesheet:olderTimesheet:)).with(timesheet,nil);
                
                timesheetDetailsController should have_received(@selector(setupWithSpinnerOperationsCounter:delegate:timesheet:hasPayrollSummary:hasBreakAccess:cursor:userURI:title:))
                .with(spinnerOperationsCounter,subject,timesheet, NO,NO, indexCursor, @"user-uri",nil);
            });
            
            it(@"should have registered itself as the spinner counter delegate", ^{
                spinnerOperationsCounter should have_received(@selector(setupWithDelegate:)).with(subject);
            });
            
            it(@"should present the timesheet details controller", ^{

               childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:))
                .with(Arguments::anything, timesheetDetailsController, subject, subject.view);
            });
            
        });
        
        describe(@"fails", ^{
            
            beforeEach(^{
                [timesheetsDeferred rejectWithError:nil];
            });
            
            it(@"should have stopped the spinner", ^{
                subject.spinnerView.hidden should be_truthy;
            });
        });
    });
    
    describe(@"as a <SpinnerOperationsCounterDelegate>", ^{
        __block UIActivityIndicatorView *spinner;
        
        beforeEach(^{
            subject.view should_not be_nil;
            spinner = (id)subject.navigationItem.rightBarButtonItem.customView;
        });
        
        it(@"should not show the spinner when the view first loads", ^{
            spinner should be_instance_of([UIActivityIndicatorView class]);
            spinner.isAnimating should be_truthy;
            spinner.hidden should be_truthy;
        });
        
        describe(@"spinnerOperationsCounterShouldShowSpinner:", ^{
            it(@"should show the spinner", ^{
                [subject spinnerOperationsCounterShouldShowSpinner:nil];
                spinner.hidden should be_falsy;
            });
            
            describe(@"spinnerOperationsCounterShouldHideSpinner:", ^{
                it(@"should hide the spinner", ^{
                    [subject spinnerOperationsCounterShouldHideSpinner:nil];
                    spinner.hidden should be_truthy;
                });
            });
        });
    });
    
    describe(@"as a <TimesheetDetailsControllerDelegate>", ^{
        
        __block TimesheetInfo *intialTimesheet;
        __block TimesheetPeriod *intialTimesheetPeriod;
        __block NSDate *intialStartDate;
        __block NSDate *intialEndDate;

        beforeEach(^{
            intialTimesheetPeriod = nice_fake_for([TimesheetPeriod class]);
            intialStartDate = [NSDate dateWithTimeIntervalSince1970:0];
            intialEndDate = [NSDate dateWithTimeIntervalSince1970:1];
            intialTimesheetPeriod stub_method(@selector(startDate)).and_return(intialStartDate);
            intialTimesheetPeriod stub_method(@selector(endDate)).and_return(intialEndDate);
            intialTimesheet = nice_fake_for([TimesheetInfo class]);
            intialTimesheet stub_method(@selector(uri)).and_return(@"timesheet-uri");
            intialTimesheet stub_method(@selector(period)).and_return(intialTimesheetPeriod);
            subject.view should_not be_nil;
            [timesheetsDeferred resolveWithValue:intialTimesheet];
        });
        
        describe(@"timesheetDetailsControllerRequestsPreviousTimesheet:", ^{
            __block NSDate *expectedDate;
            __block KSDeferred *newTimesheetDeferred;
            beforeEach(^{
                newTimesheetDeferred = [KSDeferred defer];
                expectedDate = [intialStartDate dateByAddingDays:-1];
                timesheetRepository stub_method(@selector(fetchTimesheetInfoForDate:)).with(expectedDate).and_return(newTimesheetDeferred.promise);
                [subject timesheetDetailsControllerRequestsPreviousTimesheet:nil];
            });
            it(@"should fetch the new timesheet for the correct timesheet date",^{
                timesheetRepository should have_received(@selector(fetchTimesheetInfoForDate:)).with(expectedDate);
            });
            
            it(@"should add dummy controller", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:))
                .with(Arguments::anything, dummyTimesheetDetailsController, subject, subject.view);
            });
            
            describe(@"should Refresh Timesheet Details Controller With Timesheet", ^{
                itShouldBehaveLike(@"sharedContextForRefreshTimesheetDetailsControllerWithTimesheet", ^(NSMutableDictionary *context) {
                    context[@"timesheetDeferred"] = newTimesheetDeferred;
                    context[@"subject"] = subject;
                    context[@"previousTimesheetPromise"] = timesheetsDeferred.promise;
                    context[@"injector"] = injector;
                    context[@"spinnerOperationsCounter"] = spinnerOperationsCounter;
                    context[@"childControllerHelper"] = childControllerHelper;
                    context[@"olderTimesheet"] = intialTimesheet;


                });
            });
        });
        
        describe(@"timesheetDetailsControllerRequestsNextTimesheet:", ^{
            __block NSDate *expectedDate;
            __block KSDeferred *newTimesheetDeferred;
            beforeEach(^{
                newTimesheetDeferred = [KSDeferred defer];
                expectedDate = [intialEndDate dateByAddingDays:1];
                timesheetRepository stub_method(@selector(fetchTimesheetInfoForDate:)).with(expectedDate).and_return(newTimesheetDeferred.promise);
                [subject timesheetDetailsControllerRequestsNextTimesheet:nil];
            });
            it(@"should fetch the new timesheet for the correct timesheet date",^{
                timesheetRepository should have_received(@selector(fetchTimesheetInfoForDate:)).with(expectedDate);
            });
            
            it(@"should add dummy controller", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:))
                .with(Arguments::anything, dummyTimesheetDetailsController, subject, subject.view);
            });
            
            describe(@"should Refresh Timesheet Details Controller With Timesheet", ^{
                itShouldBehaveLike(@"sharedContextForRefreshTimesheetDetailsControllerWithTimesheet", ^(NSMutableDictionary *context) {
                    context[@"timesheetDeferred"] = newTimesheetDeferred;
                    context[@"subject"] = subject;
                    context[@"previousTimesheetPromise"] = timesheetsDeferred.promise;
                    context[@"injector"] = injector;
                    context[@"spinnerOperationsCounter"] = spinnerOperationsCounter;
                    context[@"childControllerHelper"] = childControllerHelper;
                    context[@"olderTimesheet"] = intialTimesheet;
                });
            });
        });
        
        describe(@"timesheetDetailsControllerRequestsLatestPunches:", ^{
            
            __block KSPromise *expectedPromise;
            __block KSDeferred *timesheetDeferred;
            __block TimesheetInfo *timesheet;
            
            beforeEach(^{
                timesheetDeferred = [KSDeferred defer];
                timesheet = nice_fake_for([TimesheetInfo class]);
                timesheetRepository stub_method(@selector(fetchTimesheetInfoForDate:)).again().with(intialStartDate).and_return(timesheetDeferred.promise);
                expectedPromise = [subject timesheetDetailsControllerRequestsLatestPunches:nil];
            });
            
            describe(@"When promise resolves", ^{
                beforeEach(^{
                    [timesheetDeferred resolveWithValue:timesheet];
                });
                it(@"should fetch the new timesheet for the correct timesheet date",^{
                    timesheetRepository should have_received(@selector(fetchTimesheetInfoForDate:)).with(intialStartDate);
                    subject.timesheetInfo should equal(timesheet);
                    expectedPromise.value should equal(timesheet);
                });
            });
            
            describe(@"When promise fails", ^{
                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    [timesheetDeferred rejectWithError:error];
                });
                
                it(@"should fetch the new timesheet for the correct timesheet date",^{
                    subject.timesheetInfo should equal(intialTimesheet);
                    subject.spinnerView.hidden should be_truthy;
                    timesheetRepository should have_received(@selector(fetchTimesheetInfoForDate:)).with(intialStartDate);
                    expectedPromise.error should equal(error);
                });
            });
            
        });
        
        describe(@"timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary", ^{
            
            __block TimeSheetPermittedActions *timesheetPermittedActions;
            __block TimesheetPeriod *timesheetPeriod;
            __block TimePeriodSummary *timePeriodSummary;
            __block UIBarButtonItem *barButtonItem;

            beforeEach(^{
                timesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                timesheetPeriod = nice_fake_for([TimesheetPeriod class]);
                timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
            });
            
            context(@"When Submit button to be shown", ^{
                
                beforeEach(^{
                    timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(NO);
                    timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(YES);
                    timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(NO);
                    timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                    intialTimesheet stub_method(@selector(timePeriodSummary)).and_return(timePeriodSummary);
                    [subject displayUserActionsButtons:timePeriodSummary];
                    
                });
                
                it(@"should display submit button", ^{
                    subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(@"Submit", nil));
                });
                
                context(@"When Submit button tapped", ^{
                    
                    __block KSDeferred *submitDeferred;
                    __block NSDictionary *expectedRequestBodyDictionary;

                    beforeEach(^{
                        expectedRequestBodyDictionary = nice_fake_for([NSDictionary class]);
                        submitDeferred = [KSDeferred defer];
                        barButtonItem = subject.navigationItem.rightBarButtonItem;
                        timesheetActionRequestBodyProvider stub_method(@selector(requestBodyDictionaryWithComment:timesheet:)).with(nil,intialTimesheet).and_return(expectedRequestBodyDictionary);
                        timeSummaryRepository stub_method(@selector(submitTimeSheetData:)).with(expectedRequestBodyDictionary).and_return(submitDeferred.promise);
                        [barButtonItem tap];
                    });
                    
                    it(@"should show overlay", ^{
                        subject.spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                    });

                    it(@"should not have spinner rotating", ^{
                        subject.spinnerView.hidden should be_truthy;
                    });
                    
                    it(@"should return the correct request body", ^{
                        timesheetActionRequestBodyProvider should have_received(@selector(requestBodyDictionaryWithComment:timesheet:)).with(nil,intialTimesheet);
                    });
                    
                    it(@"should ask the timeSummaryRepository to submit timesheet", ^{
                        timeSummaryRepository should have_received(@selector(submitTimeSheetData:)).with(expectedRequestBodyDictionary);
                    });
                    
                    context(@"When Submit without comments fails", ^{
                        beforeEach(^{
                            [submitDeferred rejectWithError:nil];
                        });
                        
                        it(@"should remove overlay", ^{
                            subject.spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        it(@"should retain the button state to Resubmit", ^{
                            subject.navigationItem.rightBarButtonItem.title should equal(@"Submit");
                        });
                    });
                });
            });
            
            context(@"When Resubmit button to be shown", ^{
                beforeEach(^{
                    timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(YES);
                    timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(NO);
                    timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(NO);
                    timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                    [subject displayUserActionsButtons:timePeriodSummary];
                    spy_on(navigationController);
                });
                
                afterEach(^{
                    stop_spying_on(navigationController);
                });
                
                it(@"should display re-submit button", ^{
                    subject.navigationItem.rightBarButtonItem.title should equal(@"Resubmit");
                });
                
                context(@"When re-submit button tapped", ^{
                    __block CommentViewController *commentViewController;

                    beforeEach(^{
                        commentViewController = [injector getInstance:[CommentViewController class]];
                        spy_on(commentViewController);
                        [injector bind:[CommentViewController class] toInstance:commentViewController];
                        barButtonItem = subject.navigationItem.rightBarButtonItem;
                        [barButtonItem tap];
                    });
                    afterEach(^{
                        stop_spying_on(commentViewController);
                    });
                    
                    
                    it(@"should not have spinner rotating", ^{
                        subject.spinnerView.hidden should be_truthy;
                    });
                    
                    it(@"should push comment view controller", ^{
                        commentViewController should have_received(@selector(setupAction:delegate:)).with(@"Resubmit",subject);
                        navigationController should have_received(@selector(pushViewController:animated:)).with(commentViewController,Arguments::anything);
                    });
                });
            });
            
            context(@"When Reopen button to be shown", ^{
                
                beforeEach(^{
                    timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(NO);
                    timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(NO);
                    timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(YES);
                    timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                    [subject displayUserActionsButtons:timePeriodSummary];
                    
                });
                
                it(@"should display Reopen button", ^{
                    subject.navigationItem.rightBarButtonItem.title should equal(@"Reopen");
                });
                
                context(@"When Reopen button tapped", ^{
                    __block CommentViewController *commentViewController;
                    
                    beforeEach(^{
                        commentViewController = [injector getInstance:[CommentViewController class]];
                        spy_on(commentViewController);
                        [injector bind:[CommentViewController class] toInstance:commentViewController];
                        barButtonItem = subject.navigationItem.rightBarButtonItem;
                        [barButtonItem tap];
                    });
                    
                    afterEach(^{
                        stop_spying_on(commentViewController);
                    });
                    
                    it(@"should not have spinner rotating", ^{
                        subject.spinnerView.hidden should be_truthy;
                    });
                    
                    it(@"should push comment view controller", ^{
                        commentViewController should have_received(@selector(setupAction:delegate:)).with(@"Reopen",subject);
                        navigationController should have_received(@selector(pushViewController:animated:)).with(commentViewController,Arguments::anything);
                    });
                });
            });
    
        });
    });
    
    describe(@"as a <CommentViewControllerDelegate>", ^{
        
        __block TimesheetInfo *intialTimesheet;
        __block TimesheetPeriod *intialTimesheetPeriod;
        __block NSDate *intialStartDate;
        __block NSDate *intialEndDate;
        
        beforeEach(^{
            intialTimesheetPeriod = nice_fake_for([TimesheetPeriod class]);
            intialStartDate = [NSDate dateWithTimeIntervalSince1970:0];
            intialEndDate = [NSDate dateWithTimeIntervalSince1970:1];
            intialTimesheetPeriod stub_method(@selector(startDate)).and_return(intialStartDate);
            intialTimesheetPeriod stub_method(@selector(endDate)).and_return(intialEndDate);
            intialTimesheet = nice_fake_for([TimesheetInfo class]);
            intialTimesheet stub_method(@selector(uri)).and_return(@"timesheet-uri");
            intialTimesheet stub_method(@selector(period)).and_return(intialTimesheetPeriod);
            subject.view should_not be_nil;
            [timesheetsDeferred resolveWithValue:intialTimesheet];
        });
        
        context(@"When user enters comments for Reopen action", ^{
            __block KSDeferred *reopenDeffered;
            __block TimeSheetPermittedActions *timesheetPermittedActions;
            __block TimesheetPeriod *timesheetPeriod;
            __block TimePeriodSummary *timePeriodSummary;
            __block NSDictionary *expectedRequestBodyDictionary;
            
            beforeEach(^{
                expectedRequestBodyDictionary = nice_fake_for([NSDictionary class]);
                reopenDeffered = [KSDeferred defer];
                timesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                timesheetPeriod = nice_fake_for([TimesheetPeriod class]);
                timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(NO);
                timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(NO);
                timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(YES);
                timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                intialTimesheet stub_method(@selector(timePeriodSummary)).and_return(timePeriodSummary);
                [subject displayUserActionsButtons:timePeriodSummary];
                timesheetActionRequestBodyProvider stub_method(@selector(requestBodyDictionaryWithComment:timesheet:)).with(@"Hello",intialTimesheet).and_return(expectedRequestBodyDictionary);
                timeSummaryRepository stub_method(@selector(reopenTimeSheet:)).with(expectedRequestBodyDictionary).and_return(reopenDeffered.promise);
                [subject commentsViewController:nil didPressOnActionButton:subject.navigationItem.rightBarButtonItem withCommentsText:@"Hello"];

            });
            
            it(@"should request timesheetActionRequestBodyProvider to correctly provide the request body", ^{
                timesheetActionRequestBodyProvider should have_received(@selector(requestBodyDictionaryWithComment:timesheet:)).with(@"Hello",intialTimesheet);
            });
            
            it(@"should request timeSummaryRepository to reopen the timesheet with correct comments", ^{
                timeSummaryRepository should have_received(@selector(reopenTimeSheet:)).with(expectedRequestBodyDictionary);
            });
            
            it(@"should show overlay", ^{
                subject.spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
            });
            
            context(@"When reopen with comments fails", ^{
                beforeEach(^{
                    [reopenDeffered rejectWithError:nil];
                });
                
                it(@"should retain the button state to reopen", ^{
                    subject.navigationItem.rightBarButtonItem.title should equal(@"Reopen");
                });
                
                it(@"should remove overlay", ^{
                    subject.spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                });
            });
        });
        
        context(@"When user enters comments for Resubmit action", ^{
            
            __block KSDeferred *resubmitDeferred;
            __block TimeSheetPermittedActions *timesheetPermittedActions;
            __block TimesheetPeriod *timesheetPeriod;
            __block TimePeriodSummary *timePeriodSummary;
            __block NSDictionary *expectedRequestBodyDictionary;
            
            beforeEach(^{
                expectedRequestBodyDictionary = nice_fake_for([NSDictionary class]);
                resubmitDeferred = [KSDeferred defer];
                timesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                timesheetPeriod = nice_fake_for([TimesheetPeriod class]);
                timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(YES);
                timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(NO);
                timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(NO);
                timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                intialTimesheet stub_method(@selector(timePeriodSummary)).and_return(timePeriodSummary);

                [subject displayUserActionsButtons:timePeriodSummary];
                timesheetActionRequestBodyProvider stub_method(@selector(requestBodyDictionaryWithComment:timesheet:)).with(@"Hello",intialTimesheet).and_return(expectedRequestBodyDictionary);
                timeSummaryRepository stub_method(@selector(submitTimeSheetData:)).with(expectedRequestBodyDictionary).and_return(resubmitDeferred.promise);
                [subject commentsViewController:nil didPressOnActionButton:subject.navigationItem.rightBarButtonItem withCommentsText:@"Hello"];
                
            });
            
            it(@"should request timesheetActionRequestBodyProvider to correctly provide the request body", ^{
                timesheetActionRequestBodyProvider should have_received(@selector(requestBodyDictionaryWithComment:timesheet:)).with(@"Hello",intialTimesheet);
            });
            
            it(@"should request timeSummaryRepository to reopen the timesheet with correct comments", ^{
                timeSummaryRepository should have_received(@selector(submitTimeSheetData:)).with(expectedRequestBodyDictionary);
            });
            
            it(@"should show overlay", ^{
                subject.spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
            });

            context(@"When Resubmit with comments fails", ^{
                beforeEach(^{
                    [resubmitDeferred rejectWithError:nil];
                });
                
                it(@"should remove overlay", ^{
                    subject.spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                it(@"should retain the button state to Resubmit", ^{
                    subject.navigationItem.rightBarButtonItem.title should equal(@"Resubmit");
                });
            });
        });
    });
    
    
    
});

SPEC_END
