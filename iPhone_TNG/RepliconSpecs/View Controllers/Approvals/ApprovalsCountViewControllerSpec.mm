#import <Cedar/Cedar.h>
#import "UIBarButtonItem+Spec.h"
#import "ApprovalsCountViewController.h"
#import "UIAlertView+Spec.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"
#import "LoginModel.h"
#import "ApprovalsService.h"
#import "InjectorKeys.h"
#import "UITableViewCell+Spec.h"
#import "ApprovalsExpenseHistoryViewController.h"
#import "ApprovalsTimeOffHistoryViewController.h"
#import "ApprovalsTimesheetHistoryViewController.h"
#import "UserPermissionsStorage.h"
#import "UserSession.h"
#import "InboxCell.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ApprovalsCountViewControllerSpec)

describe(@"ApprovalsCountViewController", ^{
    __block ApprovalsCountViewController <CedarDouble>*subject;
    __block NSNotificationCenter *notificationCenter;
    __block LoginModel *loginModel;
    __block id<BSInjector, BSBinder> injector;
    __block UINavigationController *navigationController;
    __block id <SpinnerDelegate> spinnerDelegate;
    __block ApprovalsModel *approvalsModel;
    __block ApprovalsService *approvalsService;
    __block ApprovalsExpenseHistoryViewController *approvalsExpenseHistoryViewController;
    __block ApprovalsTimeOffHistoryViewController *approvalsTimeOffHistoryViewController;
    __block ApprovalsTimesheetHistoryViewController *approvalsTimesheetHistoryViewController;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block MinimalTimesheetDeserializer *minimalTimesheetDeserializer;
    __block id<UserSession> userSession;

    beforeEach(^{
        injector = [InjectorProvider injector];

        reachabilityMonitor = nice_fake_for([ReachabilityMonitor class]);
        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
        [injector bind:[ReachabilityMonitor class] toInstance:reachabilityMonitor];

        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        [injector bind:@protocol(SpinnerDelegate) toInstance:spinnerDelegate];

        loginModel = nice_fake_for([LoginModel class]);
        [injector bind:[LoginModel class] toInstance:loginModel];

        notificationCenter = [[NSNotificationCenter alloc] init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];


        approvalsModel = nice_fake_for([ApprovalsModel class]);
        [injector bind:[ApprovalsModel class] toInstance:approvalsModel];

        approvalsService = nice_fake_for([ApprovalsService class]);
        [injector bind:[ApprovalsService class] toInstance:approvalsService];

        userPermissionsStorage = fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];

        minimalTimesheetDeserializer = nice_fake_for([MinimalTimesheetDeserializer class]);
        [injector bind:[MinimalTimesheetDeserializer class] toInstance:minimalTimesheetDeserializer];

        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"expected-user-uri");
        [injector bind:@protocol(UserSession) toInstance:userSession];


        subject = [injector getInstance:[ApprovalsCountViewController class]];
        spy_on(subject);
        navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
        spy_on(navigationController);

        approvalsExpenseHistoryViewController= [[ApprovalsExpenseHistoryViewController alloc] initWithNotificationCenter:notificationCenter
                                                                                                         spinnerDelegate:spinnerDelegate
                                                                                                        approvalsService:approvalsService
                                                                                                          approvalsModel:approvalsModel
                                                                                                              loginModel:loginModel];
        [injector bind:[ApprovalsExpenseHistoryViewController class] toInstance:approvalsExpenseHistoryViewController];
        spy_on(approvalsExpenseHistoryViewController);

        approvalsTimeOffHistoryViewController= [[ApprovalsTimeOffHistoryViewController alloc] initWithErrorBannerViewParentPresenterHelper:nil
                                                                                                                        notificationCenter:notificationCenter
                                                                                                                           spinnerDelegate:spinnerDelegate
                                                                                                                          approvalsService:approvalsService
                                                                                                                            approvalsModel:approvalsModel
                                                                                                                                loginModel:loginModel];
        [injector bind:[ApprovalsTimeOffHistoryViewController class] toInstance:approvalsTimeOffHistoryViewController];
        spy_on(approvalsTimeOffHistoryViewController);

        approvalsTimesheetHistoryViewController= [[ApprovalsTimesheetHistoryViewController alloc] initWithErrorBannerViewParentPresenterHelper:nil
                                                                                                                  minimalTimesheetDeserializer:minimalTimesheetDeserializer userPermissionsStorage:userPermissionsStorage
                                                                                                                           reachabilityMonitor:reachabilityMonitor
                                                                                                                            notificationCenter:notificationCenter
                                                                                                                              approvalsService:approvalsService
                                                                                                                               spinnerDelegate:spinnerDelegate
                                                                                                                                approvalsModel:approvalsModel
                                                                                                                                   userSession:userSession
                                                                                                                                    loginModel:loginModel];

        [injector bind:[ApprovalsTimesheetHistoryViewController class] toInstance:approvalsTimesheetHistoryViewController];
        
        spy_on(approvalsTimesheetHistoryViewController);


        subject.view should_not be_nil;
        spy_on(subject.approvalsTableView);
    });

    it(@"should have a title for the navigation bar", ^{

        subject.title should equal (RPLocalizedString(PREVIOUS_APPROVALS_TITLE_MSG, @""));
    });

    describe(@"view will appear called", ^{

        __block InboxCell *firstCell;
        __block InboxCell *secondCell;
        __block InboxCell *thirdCell;

        beforeEach(^{
            NSDictionary*userDict=@{@"isTimesheetApprover":@1,@"isExpenseApprover":@1,@"isTimeOffApprover":@1};
            (id<CedarDouble>)subject stub_method(@selector(userDetailsArray)).and_return(@[userDict]);


            [subject viewWillAppear:NO];

            firstCell =(InboxCell *)[subject.approvalsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            secondCell =(InboxCell *)[subject.approvalsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            thirdCell =(InboxCell *)[subject.approvalsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];

            spy_on(secondCell);
        });

        it(@"should have correct values in approvalsPermissionArray", ^{
            subject.approvalsPermissionArray.count should equal(3);
        });


        it(@"number of sections in table view", ^{
            subject.approvalsTableView.numberOfSections should equal(3);
        });

        it(@"number of rows in table view", ^{
            subject.approvalsTableView.visibleCells.count should equal(3);
        });
        it(@"should show correct text for rows", ^{

            firstCell should be_instance_of([InboxCell class]);
            firstCell.label.text should equal(RPLocalizedString(PREVIOUS_TIMESHEETS_APPROVALS, @""));

            secondCell should be_instance_of([InboxCell class]);
            secondCell.label.text  should equal(RPLocalizedString(PREVIOUS_EXPENSE_APPROVALS, @""));

            thirdCell should be_instance_of([InboxCell class]);
            thirdCell.label.text  should equal(RPLocalizedString(PREVIOUS_TIMEOFFS_APPROVALS, @""));


        });

        describe(@"Previous Expense Approvals cell tapped", ^{

            context(@"and there are no expense sheets cached", ^{
                beforeEach(^{
                    approvalsModel stub_method(@selector(getAllPreviousExpensesheetsOfApprovalFromDB)).and_return(@[]);
                    [secondCell tap];
                });

                it(@"should make a service call to fetch the expensesheet", ^{
                    approvalsService should have_received(@selector(fetchSummaryOfPreviousExpenseApprovalsForUser:)).with(subject);
                });

                it(@"should start the spinner", ^{
                    spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                });

                it(@"should have correctly push ApprovalsExpenseHistoryViewController", ^{
                    navigationController should have_received(@selector(pushViewController:animated:)).with(approvalsExpenseHistoryViewController,YES);

                });

                it(@"should deselect the row", ^{

                    subject.approvalsTableView should have_received(@selector(deselectRowAtIndexPath:animated:));
                });

               

            });

            context(@"when there is a expense sheet in the cache", ^{
                beforeEach(^{
                    approvalsModel stub_method(@selector(getAllPreviousExpensesheetsOfApprovalFromDB)).and_return(@[@{}]);
                    [secondCell tap];
                });

                it(@"should not make a service call", ^{
                    approvalsService should_not have_received(@selector(fetchSummaryOfPreviousExpenseApprovalsForUser:));
                });

                it(@"should not start the spinner", ^{
                    spinnerDelegate should_not have_received(@selector(showTransparentLoadingOverlay));
                });

                it(@"should post previous approvals notification", ^{
                     [notificationCenter postNotificationName:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil] should_not raise_exception;
                });

                it(@"should have correctly push ApprovalsExpenseHistoryViewController", ^{
                    navigationController should have_received(@selector(pushViewController:animated:)).with(approvalsExpenseHistoryViewController,YES);

                });

                it(@"should deselect the row", ^{

                    subject.approvalsTableView should have_received(@selector(deselectRowAtIndexPath:animated:));
                });

            });




        });

        describe(@"Previous TimeOff Approvals cell tapped", ^{

            context(@"and there are no time offs cached", ^{
                beforeEach(^{
                    approvalsModel stub_method(@selector(getAllPreviousTimeOffsOfApprovalFromDB)).and_return(@[]);
                    [thirdCell tap];
                });

                it(@"should make a service call to fetch the timeoff", ^{
                    approvalsService should have_received(@selector(fetchSummaryOfPreviousTimeOffsApprovalsForUser:)).with(subject);
                });

                it(@"should start the spinner", ^{
                    spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                });

                it(@"should have correctly push ApprovalsTimeOffHistoryViewController", ^{
                    navigationController should have_received(@selector(pushViewController:animated:)).with(approvalsTimeOffHistoryViewController,YES);

                });

                it(@"should deselect the row", ^{

                    subject.approvalsTableView should have_received(@selector(deselectRowAtIndexPath:animated:));
                });


            });

            context(@"when there is a timeoff in the cache", ^{
                beforeEach(^{
                    approvalsModel stub_method(@selector(getAllPreviousTimeOffsOfApprovalFromDB)).and_return(@[@{}]);
                    [thirdCell tap];
                });

                it(@"should not make a service call", ^{
                    approvalsService should_not have_received(@selector(fetchSummaryOfPreviousTimeOffsApprovalsForUser:));
                });

                it(@"should not start the spinner", ^{
                    spinnerDelegate should_not have_received(@selector(showTransparentLoadingOverlay));
                });

                it(@"should post previous approvals notification", ^{
                    [notificationCenter postNotificationName:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil] should_not raise_exception;
                });

                it(@"should have correctly push ApprovalsTimeOffHistoryViewController", ^{
                    navigationController should have_received(@selector(pushViewController:animated:)).with(approvalsTimeOffHistoryViewController,YES);

                });

                it(@"should deselect the row", ^{
                    
                    subject.approvalsTableView should have_received(@selector(deselectRowAtIndexPath:animated:));
                });
                
            });
            
            
            
            
        });


        describe(@"Previous Timesheet Approvals cell tapped", ^{

            context(@"and there are no timesheets cached", ^{
                beforeEach(^{
                    approvalsModel stub_method(@selector(getAllPreviousTimesheetsOfApprovalFromDB)).and_return(@[]);
                    [firstCell tap];
                });

                it(@"should make a service call to fetch the timesheets", ^{
                    approvalsService should have_received(@selector(fetchSummaryOfPreviousTimeSheetApprovalsForUser:)).with(subject);
                });

                it(@"should start the spinner", ^{
                    spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                });

                it(@"should have correctly push ApprovalsTimesheetHistoryViewController", ^{
                    navigationController should have_received(@selector(pushViewController:animated:)).with(approvalsTimesheetHistoryViewController,YES);

                });

                it(@"should deselect the row", ^{

                    subject.approvalsTableView should have_received(@selector(deselectRowAtIndexPath:animated:));
                });


            });

            context(@"when there is a timesheet in the cache", ^{
                beforeEach(^{
                    approvalsModel stub_method(@selector(getAllPreviousTimesheetsOfApprovalFromDB)).and_return(@[@{}]);
                    [firstCell tap];
                });

                it(@"should not make a service call", ^{
                    approvalsService should_not have_received(@selector(fetchSummaryOfPreviousTimeSheetApprovalsForUser:));
                });

                it(@"should not start the spinner", ^{
                    spinnerDelegate should_not have_received(@selector(showTransparentLoadingOverlay));
                });

                it(@"should post previous approvals notification", ^{
                    [notificationCenter postNotificationName:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil] should_not raise_exception;
                });

                it(@"should have correctly push ApprovalsTimesheetHistoryViewController", ^{
                    navigationController should have_received(@selector(pushViewController:animated:)).with(approvalsTimesheetHistoryViewController,YES);

                });

                it(@"should deselect the row", ^{
                    
                    subject.approvalsTableView should have_received(@selector(deselectRowAtIndexPath:animated:));
                });
                
            });
            
            
            
            
        });

    });




});

SPEC_END
