#import <Cedar/Cedar.h>
#import "UITableViewCell+Spec.h"
#import "UIBarButtonItem+Spec.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"
#import "UserPermissionsStorage.h"
#import "ApprovalsModel.h"
#import "TimesheetDetailsController.h"
#import "ApprovalsScrollViewController.h"
#import "SpinnerDelegate.h"
#import "Timesheet.h"
#import <KSDeferred/KSDeferred.h>
#import "MinimalTimesheetDeserializer.h"
#import "ApprovalsService.h"
#import "LoginModel.h"
#import "ApprovalCommentsController.h"
#import "UIAlertView+Spec.h"
#import "UserSession.h"
#import "ApproveTimesheetContainerController.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "InjectorKeys.h"
#import "ApprovalsPendingCustomCell.h"
#import "UIControl+Spec.h"
#import "ErrorBannerViewParentPresenterHelper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ApprovalsPendingTimesheetViewControllerSpec)

describe(@"ApprovalsPendingTimesheetViewController", ^{
    __block ApprovalsPendingTimesheetViewController *subject;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block ApprovalsModel *approvalsModel;
    __block ApprovalsService *approvalsService;
    __block MinimalTimesheetDeserializer *minimalTimesheetDeserializer;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block id<UserSession> userSession;

    __block id<BSInjector, BSBinder> injector;
    __block LoginModel *loginModel;
    __block UINavigationController *navigationController;
    __block ApprovalCommentsController *approvalCommentsController;
    __block NSNotificationCenter *notificationCenter;
    __block ReachabilityMonitor *reachabilityMonitor;

    __block LoginService *loginService;

    __block UITableView *tableview;
    __block ApprovalsPendingCustomCell *returnCell;
    __block ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;

    beforeEach(^{
        injector = [InjectorProvider injector];

        reachabilityMonitor = nice_fake_for([ReachabilityMonitor class]);
        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
        [injector bind:[ReachabilityMonitor class] toInstance:reachabilityMonitor];

        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        [injector bind:@protocol(SpinnerDelegate) toInstance:spinnerDelegate];

        approvalsService = nice_fake_for([ApprovalsService class]);
        [injector bind:[ApprovalsService class] toInstance:approvalsService];

        userPermissionsStorage = fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];

        minimalTimesheetDeserializer = nice_fake_for([MinimalTimesheetDeserializer class]);
        [injector bind:[MinimalTimesheetDeserializer class] toInstance:minimalTimesheetDeserializer];

        approvalsModel = nice_fake_for([ApprovalsModel class]);
        [injector bind:[ApprovalsModel class] toInstance:approvalsModel];

        loginModel = nice_fake_for([LoginModel class]);
        [injector bind:[LoginModel class] toInstance:loginModel];

        approvalCommentsController = [[ApprovalCommentsController alloc] initWithNotificationCenter:nil theme:nil];
        [injector bind:[ApprovalCommentsController class] toInstance:approvalCommentsController];

        notificationCenter = [[NSNotificationCenter alloc] init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];
        
        errorBannerViewParentPresenterHelper = nice_fake_for([ErrorBannerViewParentPresenterHelper class]);
        [injector bind:[ErrorBannerViewParentPresenterHelper class] toInstance:errorBannerViewParentPresenterHelper];

        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"expected-user-uri");
        [injector bind:@protocol(UserSession) toInstance:userSession];

        loginService = [RepliconServiceManager loginService];
        spy_on(loginService);

        subject = [injector getInstance:[ApprovalsPendingTimesheetViewController class]];
        spy_on(subject);

        navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
        spy_on(navigationController);
        spy_on(approvalCommentsController);
    });

    __block NSMutableArray *timesheetsGroupedByDueDates;;
    beforeEach(^{
        timesheetsGroupedByDueDates = [NSMutableArray arrayWithArray:@[
                                                                       @[
                                                                           @{
                                                                               @"IsSelected": @0,
                                                                               @"approvalStatus": @"Waiting for Approval",
                                                                               @"approval_dueDate": @1433721600,
                                                                               @"approval_dueDateText": @"Jun 8, 2015",
                                                                               @"canEditTimesheet": [NSNull null],
                                                                               @"dueDate" : @1433635200,
                                                                               @"mealBreakPenalties": [NSNull null],
                                                                               @"overtimeDurationDecimal": @0,
                                                                               @"overtimeDurationHour" : @"0:0",
                                                                               @"regularDurationDecimal" : @0,
                                                                               @"regularDurationHour" : @"0:0",
                                                                               @"timeoffDurationDecimal" : @0,
                                                                               @"timeoffDurationHour" : @"0:0",
                                                                               @"timesheetFormat" : [NSNull null],
                                                                               @"timesheetPeriod" : @"June 01, 2015 - June 07, 2015",
                                                                               @"timesheetUri" : @"urn:replicon-tenant:astro:timesheet:93f4de07-8bb9-4dcf-8d99-aff9ae9e69ed",
                                                                               @"totalDurationDecimal" : @0,
                                                                               @"totalDurationHour" : @"0:0",
                                                                               @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                               @"username" : @"Alba, Jessica",
                                                                               }
                                                                           ]
                                                                       ]];

        
        approvalsModel stub_method(@selector(getAllPendingTimeSheetsGroupedByDueDatesWithStatus:))
            .and_return(timesheetsGroupedByDueDates);
    });


    describe(@"showing the timesheet for a user", ^{
        __block UINavigationController *navigationController;
        __block UIViewController *expectedViewController;

        beforeEach(^{
            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            subject.view should_not be_nil;
            [subject viewWillAppear:NO];

            [subject.approvalpendingTSTableView layoutIfNeeded];

            expectedViewController = [[ApproveTimesheetContainerController alloc] initWithTimesheetRepository:nil
                                                                                    widgetTimesheetRepository:nil
                                                                                        childControllerHelper:nil
                                                                                           notificationCenter:nil
                                                                                             approvalsService:nil
                                                                                              spinnerDelegate:nil
                                                                                               approvalsModel:nil
                                                                                           oefTypesRepository:nil
                                                                                                    appConfig:nil];
            [injector bind:[ApproveTimesheetContainerController class] toInstance:expectedViewController];

            NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
            UITableViewCell *cell = [subject.approvalpendingTSTableView cellForRowAtIndexPath:firstRow];
            [cell tap];
        });

        it(@"should push the correct view controller onto the navigation stack", ^{
            navigationController.topViewController should be_same_instance_as(expectedViewController);
        });
    });
    
    describe(@"the error banner view", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        
        it(@"should check for error banner view and set inset for tableview", ^{
            [subject viewWillAppear:NO];
            
            errorBannerViewParentPresenterHelper should have_received(@selector(setTableViewInsetWithErrorBannerPresentation:))
            .with(subject.approvalpendingTSTableView);
        });
    });


    describe(@"responding to the notification BEFORE there is data", ^{
        __block UINavigationController *navigationController;

        beforeEach(^{
            approvalsModel stub_method(@selector(getAllPendingTimeSheetsGroupedByDueDatesWithStatus:))
                .again().and_return(nil);

            [subject handlePendingApprovalsDataReceivedAction];

            approvalsModel stub_method(@selector(getAllPendingTimeSheetsGroupedByDueDatesWithStatus:))
                .again().and_return(timesheetsGroupedByDueDates);

            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            subject.view should_not be_nil;
            [subject viewWillAppear:NO];

            [subject.approvalpendingTSTableView layoutIfNeeded];
        });

        it(@"should not show the 'no timesheets to approve' message label", ^{
            subject.view.subviews should_not contain(subject.msgLabel);
        });
    });

    describe(@"showing the comments view controller", ^{

        context(@"When user has not selected timesheets for approvals", ^{

            context(@"When approving ", ^{
                __block UIAlertView *alertView;
                beforeEach(^{
                    subject.view should_not be_nil;
                    [subject viewWillAppear:NO];
                    [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToApprove:nil];
                    alertView = [UIAlertView currentAlertView];
                });

                it(@"should present the alertview to indicate user needs to select the timesheets", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(APPROVAL_TIMESHEET_VALIDATION_MSG);
                });
            });

            context(@"When rejecting ", ^{
                __block UIAlertView *alertView;
                beforeEach(^{
                    subject.view should_not be_nil;
                    [subject viewWillAppear:NO];
                    [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToReject:nil];
                    alertView = [UIAlertView currentAlertView];
                });

                it(@"should present the alertview to indicate user needs to select the timesheets", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(APPROVAL_TIMESHEET_VALIDATION_MSG);
                });
            });

        });
        context(@"When user has selected timesheets for approvals", ^{
            beforeEach(^{
                subject.selectedSheetsIDsArr = [NSMutableArray arrayWithArray:@[@"My-Special-Timesheet"]];
            });
            context(@"When approval needs comments permission is true", ^{
                beforeEach(^{
                    loginModel stub_method(@selector(getAllUserDetailsInfoFromDb)).and_return(@[@{@"areTimeSheetRejectCommentsRequired":[NSNumber numberWithInt:1]}]);
                });

                context(@"and when supervisor is rejecting", ^{
                    beforeEach(^{
                        [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToReject:nil];
                    });
                    it(@"should setup ApprovalCommentsController", ^{
                        approvalCommentsController should have_received(@selector(setUpApprovalActionType:delegate:commentsRequired:)).with(RejectActionType,subject, YES);
                    });
                    it(@"should navigate to ApprovalCommentsController", ^{
                        navigationController should have_received(@selector(pushViewController:animated:)).with(approvalCommentsController,YES);
                        navigationController.topViewController should be_same_instance_as(approvalCommentsController);
                    });


                });
            });

            context(@"When reject needs comments permission is false", ^{
                beforeEach(^{
                    loginModel stub_method(@selector(getAllUserDetailsInfoFromDb)).and_return(@[@{@"areTimeSheetRejectCommentsRequired":[NSNumber numberWithInt:0]}]);
                });

                context(@"and when supervisor is rejecting", ^{
                    beforeEach(^{
                        [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToReject:nil];
                    });
                    it(@"should navigate to ApprovalCommentsController", ^{
                        navigationController should_not have_received(@selector(pushViewController:animated:));
                    });
                });
            });
        });

    });

    describe(@"as a <ApprovalCommentsControllerDelegate>", ^{

        __block NSMutableArray *expectedTimesheetUriArray;

        beforeEach(^{
            expectedTimesheetUriArray = [NSMutableArray arrayWithArray:@[@"My-Special-Timesheet-Uri"]];
            subject.selectedSheetsIDsArr = expectedTimesheetUriArray;
            NSMutableArray *timesheetsGroupedByDueDates = [NSMutableArray arrayWithArray:@[
                                                                                           [NSMutableArray arrayWithArray:@[
                                                                                                                            [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                                                                                            @"IsSelected": @0,
                                                                                                                                                                            @"approvalStatus": @"Waiting for Approval",
                                                                                                                                                                            @"approval_dueDate": @1433721600,
                                                                                                                                                                            @"approval_dueDateText": @"Jun 8, 2015",
                                                                                                                                                                            @"canEditTimesheet": [NSNull null],
                                                                                                                                                                            @"dueDate" : @1433635200,
                                                                                                                                                                            @"mealBreakPenalties": [NSNull null],
                                                                                                                                                                            @"overtimeDurationDecimal": @0,
                                                                                                                                                                            @"overtimeDurationHour" : @"0:0",
                                                                                                                                                                            @"regularDurationDecimal" : @0,
                                                                                                                                                                            @"regularDurationHour" : @"0:0",
                                                                                                                                                                            @"timeoffDurationDecimal" : @0,
                                                                                                                                                                            @"timeoffDurationHour" : @"0:0",
                                                                                                                                                                            @"timesheetFormat" : [NSNull null],
                                                                                                                                                                            @"timesheetPeriod" : @"June 01, 2015 - June 07, 2015",
                                                                                                                                                                            @"timesheetUri" : @"urn:replicon-tenant:astro:timesheet:93f4de07-8bb9-4dcf-8d99-aff9ae9e69ed",
                                                                                                                                                                            @"totalDurationDecimal" : @0,
                                                                                                                                                                            @"totalDurationHour" : @"0:0",
                                                                                                                                                                            @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                                                                                            @"username" : @"Alba, Jessica",
                                                                                                                                                                            }]
                                                                                                                            ]]
                                                                                           ]];


            approvalsModel stub_method(@selector(getAllPendingTimeSheetsGroupedByDueDatesWithStatus:)).again()
                .and_return(timesheetsGroupedByDueDates);
        });

        context(@"When approving", ^{
            beforeEach(^{
                [subject approvalsCommentsControllerDidRequestApproveAction:approvalCommentsController withComments:@"My-Special-Comments"];
            });

            it(@"When approving should send the selected timesheet uri's to the server using correct endpoint ", ^{
                approvalsService should have_received(@selector(sendRequestToApproveTimesheetsWithURI:withComments:andDelegate:)).with(expectedTimesheetUriArray,@"My-Special-Comments",subject);
            });

        });

        context(@"When rejecting", ^{
            beforeEach(^{
                [subject approvalsCommentsControllerDidRequestRejectAction:approvalCommentsController withComments:@"My-Special-Comments"];
            });

            it(@"should send the selected timesheet uri's to the server", ^{
                approvalsService should have_received(@selector(sendRequestToRejectTimesheetsWithURI:withComments:andDelegate:)).with(expectedTimesheetUriArray,@"My-Special-Comments",subject);
            });
            
            it(@"when the reject action is successfull should pop the view controller to itself", ^{
                [notificationCenter postNotificationName:APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
                subject should be_instance_of([ApprovalsPendingTimesheetViewController class]);
                navigationController should_not have_received(@selector(popToViewController:animated:)).with(subject,YES);
            });
            
            it(@"when the reject action is failure should not pop the view controller to itself", ^{
                navigationController should_not have_received(@selector(popViewControllerAnimated:));
            });
        });
    });

    describe(@"as a <ApproveTimesheetContainerControllerDelegate>", ^{
        __block id<Timesheet> timesheet;

        beforeEach(^{
            subject.view should_not be_nil;
            [subject viewWillAppear:NO];
            timesheet = nice_fake_for(@protocol(Timesheet));
            timesheet stub_method(@selector(uri)).and_return(@"selected-timesheet-uri");

            [subject approveTimesheetContainerController:nil didApproveTimesheet:timesheet];
        });

        it(@"should approveTimesheetsWithComments", ^{
            subject.spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
            subject.approvalsService should have_received(@selector(sendRequestToApproveTimesheetsWithURI:withComments:andDelegate:));
        });

    });

    describe(@"As a <ApprovalsPendingTimeOffTableViewHeaderDelegate>", ^{

        context(@"When select all", ^{
            beforeEach(^{

                NSMutableArray *timesheetsGroupedByDueDates = [NSMutableArray arrayWithArray:@[
                                                                                               [NSMutableArray arrayWithArray:@[
                                                                                                                                [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                                                                                                @"IsSelected": @0,
                                                                                                                                                                                @"approvalStatus": @"Waiting for Approval",
                                                                                                                                                                                @"approval_dueDate": @1433721600,
                                                                                                                                                                                @"approval_dueDateText": @"Jun 8, 2015",
                                                                                                                                                                                @"canEditTimesheet": [NSNull null],
                                                                                                                                                                                @"dueDate" : @1433635200,
                                                                                                                                                                                @"mealBreakPenalties": [NSNull null],
                                                                                                                                                                                @"overtimeDurationDecimal": @0,
                                                                                                                                                                                @"overtimeDurationHour" : @"0:0",
                                                                                                                                                                                @"regularDurationDecimal" : @0,
                                                                                                                                                                                @"regularDurationHour" : @"0:0",
                                                                                                                                                                                @"timeoffDurationDecimal" : @0,
                                                                                                                                                                                @"timeoffDurationHour" : @"0:0",
                                                                                                                                                                                @"timesheetFormat" : [NSNull null],
                                                                                                                                                                                @"timesheetPeriod" : @"June 01, 2015 - June 07, 2015",
                                                                                                                                                                                @"timesheetUri" : @"urn:replicon-tenant:astro:timesheet:93f4de07-8bb9-4dcf-8d99-aff9ae9e69ed",
                                                                                                                                                                                @"totalDurationDecimal" : @0,
                                                                                                                                                                                @"totalDurationHour" : @"0:0",
                                                                                                                                                                                @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                                                                                                @"username" : @"Alba, Jessica",
                                                                                                                                                                                }]
                                                                                                                                ]]
                                                                                               ]];




                approvalsModel stub_method(@selector(getAllPendingTimeSheetsGroupedByDueDatesWithStatus:)).again()
                .and_return(timesheetsGroupedByDueDates);


                subject.view should_not be_nil;
                [subject viewWillAppear:NO];

                [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:nil];

            });

            it(@"should select the selected", ^{
                subject.selectedSheetsIDsArr.count should equal(1);
                subject.selectedSheetsIDsArr.firstObject should equal(@"urn:replicon-tenant:astro:timesheet:93f4de07-8bb9-4dcf-8d99-aff9ae9e69ed");
            });
        });

        context(@"When clear all", ^{
            beforeEach(^{
                NSMutableArray *timesheetsGroupedByDueDates = [NSMutableArray arrayWithArray:@[
                                                                                               [NSMutableArray arrayWithArray:@[
                                                                                                                                [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                                                                                                @"IsSelected": @0,
                                                                                                                                                                                @"approvalStatus": @"Waiting for Approval",
                                                                                                                                                                                @"approval_dueDate": @1433721600,
                                                                                                                                                                                @"approval_dueDateText": @"Jun 8, 2015",
                                                                                                                                                                                @"canEditTimesheet": [NSNull null],
                                                                                                                                                                                @"dueDate" : @1433635200,
                                                                                                                                                                                @"mealBreakPenalties": [NSNull null],
                                                                                                                                                                                @"overtimeDurationDecimal": @0,
                                                                                                                                                                                @"overtimeDurationHour" : @"0:0",
                                                                                                                                                                                @"regularDurationDecimal" : @0,
                                                                                                                                                                                @"regularDurationHour" : @"0:0",
                                                                                                                                                                                @"timeoffDurationDecimal" : @0,
                                                                                                                                                                                @"timeoffDurationHour" : @"0:0",
                                                                                                                                                                                @"timesheetFormat" : [NSNull null],
                                                                                                                                                                                @"timesheetPeriod" : @"June 01, 2015 - June 07, 2015",
                                                                                                                                                                                @"timesheetUri" : @"urn:replicon-tenant:astro:timesheet:93f4de07-8bb9-4dcf-8d99-aff9ae9e69ed",
                                                                                                                                                                                @"totalDurationDecimal" : @0,
                                                                                                                                                                                @"totalDurationHour" : @"0:0",
                                                                                                                                                                                @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                                                                                                @"username" : @"Alba, Jessica",
                                                                                                                                                                                }]
                                                                                                                                ]]
                                                                                               ]];




                approvalsModel stub_method(@selector(getAllPendingTimeSheetsGroupedByDueDatesWithStatus:)).again()
                .and_return(timesheetsGroupedByDueDates);


                subject.view should_not be_nil;
                [subject viewWillAppear:NO];

                [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:nil];
                [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToClearAll:nil];
            });
            it(@"should unselect the selected", ^{
                subject.selectedSheetsIDsArr.count should equal(0);
            });

        });
    });

    describe(@"When pull to refresh", ^{
        beforeEach(^{

            NSMutableArray *timesheetsGroupedByDueDates = [NSMutableArray arrayWithArray:@[
                                                                                           [NSMutableArray arrayWithArray:@[
                                                                                                                            [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                                                                                            @"IsSelected": @0,
                                                                                                                                                                            @"approvalStatus": @"Waiting for Approval",
                                                                                                                                                                            @"approval_dueDate": @1433721600,
                                                                                                                                                                            @"approval_dueDateText": @"Jun 8, 2015",
                                                                                                                                                                            @"canEditTimesheet": [NSNull null],
                                                                                                                                                                            @"dueDate" : @1433635200,
                                                                                                                                                                            @"mealBreakPenalties": [NSNull null],
                                                                                                                                                                            @"overtimeDurationDecimal": @0,
                                                                                                                                                                            @"overtimeDurationHour" : @"0:0",
                                                                                                                                                                            @"regularDurationDecimal" : @0,
                                                                                                                                                                            @"regularDurationHour" : @"0:0",
                                                                                                                                                                            @"timeoffDurationDecimal" : @0,
                                                                                                                                                                            @"timeoffDurationHour" : @"0:0",
                                                                                                                                                                            @"projectDurationDecimal"
                                                                                                                                    : @0,
                                                                                                                                                                            @"projectDurationHour" :
                                                                                                                                    @"0:0",
                                                                                                                                    
                                                                                                                                                                            @"timesheetFormat" : [NSNull null],
                                                                                                                                                                            @"timesheetPeriod" : @"June 01, 2015 - June 07, 2015",
                                                                                                                                                                            @"timesheetUri" : @"urn:replicon-tenant:astro:timesheet:93f4de07-8bb9-4dcf-8d99-aff9ae9e69ed",
                                                                                                                                                                            @"totalDurationDecimal" : @0,
                                                                                                                                                                            @"totalDurationHour" : @"0:0",
                                                                                                                                                                            @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                                                                                            @"username" : @"Alba, Jessica",
                                                                                                                                                                            }]
                                                                                                                            ]]
                                                                                           ]];




            approvalsModel stub_method(@selector(getAllPendingTimeSheetsGroupedByDueDatesWithStatus:)).again()
            .and_return(timesheetsGroupedByDueDates);


            subject.view should_not be_nil;
            [subject viewWillAppear:NO];

            [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:nil];

            [subject refreshAction];
        });

        it(@"When refresh action is successfull, should reset the toggle button title correctly", ^{
            [notificationCenter postNotificationName:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];

            ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (id)subject.approvalpendingTSTableView.tableHeaderView;
            approvalsPendingTimeOffTableViewHeader.toggleButton.titleLabel.text should equal(@"Select All");
        });

        it(@"should fetchGetMyNotificationSummary", ^{
            loginService should have_received(@selector(fetchGetMyNotificationSummary));
        });
    });


    describe(@"cellForRowAtIndexPath: when displaySummaryByPayCode is false", ^{

        beforeEach(^{

            NSMutableArray *timesheetsGroupedByDueDates = [NSMutableArray arrayWithArray:@[
                                                                                           [NSMutableArray arrayWithArray:@[
                                                                                                                            [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                                                                                            @"IsSelected": @0,
                                                                                                                                                                            @"approvalStatus": @"Waiting for Approval",
                                                                                                                                                                            @"approval_dueDate": @1433721600,
                                                                                                                                                                            @"approval_dueDateText": @"Jun 8, 2015",
                                                                                                                                                                            @"canEditTimesheet": [NSNull null],
                                                                                                                                                                            @"dueDate" : @1433635200,
                                                                                                                                                                            @"mealBreakPenalties": [NSNull null],
                                                                                                                                                                            @"overtimeDurationDecimal": @1.5,
                                                                                                                                                                            @"overtimeDurationHour" : @"1:5",
                                                                                                                                                                            @"regularDurationDecimal" : @8.0,
                                                                                                                                                                            @"regularDurationHour" : @"8:0",
                                                                                                                                                                            @"timeoffDurationDecimal" : @4.50,
                                                                                                                                                                            @"timeoffDurationHour" : @"4:5",
                                                                                                                                                                            @"projectDurationDecimal"
                                                                                                                                                                            : @2.0,
                                                                                                                                                                            @"projectDurationHour" :
                                                                                                                                                                                @"2:0",

                                                                                                                                                                            @"timesheetFormat" : [NSNull null],
                                                                                                                                                                            @"timesheetPeriod" : @"June 01, 2015 - June 07, 2015",
                                                                                                                                                                            @"timesheetUri" : @"urn:replicon-tenant:astro:timesheet:93f4de07-8bb9-4dcf-8d99-aff9ae9e69ed",
                                                                                                                                                                            @"totalDurationDecimal" : @30.0,
                                                                                                                                                                            @"totalDurationHour" : @"30:0",
                                                                                                                                                                            @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                                                                                            @"username" : @"Alba, Jessica",
                                                                                                                                                                            
                                                                                                                                                                            @"displaySummaryByPayCode" : @0
                                                                                                                                                                            }]
                                                                                                                            ]]
                                                                                           ]];



            approvalsModel stub_method(@selector(getAllPendingTimeSheetsGroupedByDueDatesWithStatus:)).again()
            .and_return(timesheetsGroupedByDueDates);


            subject.view should_not be_nil;
            [subject viewWillAppear:NO];

            tableview = nice_fake_for([UITableView class]);

            returnCell = nice_fake_for([ApprovalsPendingCustomCell class]);
            tableview stub_method(@selector(dequeueReusableCellWithIdentifier:)).with(@"PendingApprovalsCellIdentifier").and_return(returnCell);


            [subject tableView:tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

        });

        it(@"should receive correct selector for cell", ^{
            returnCell should have_received(@selector(createCellLayoutWithParams:
                                                leftLowerString:
                                                rightstr:
                                                radioButtonTag:
                                                overTimeStr:
                                                mealStr:
                                                timeOffStr:
                                                regularStr:
                                                projectHourStr:
                                       displaySummaryByPayCode:)).with(@"Alba, Jessica",@" Jan 01 - Jan 01",@"30.00",0,@"1.50",@"<null>",@"4.50",@"8.00",@"2.00", false);
        });

        it(@"should have correct number of subview", ^{
            ApprovalsPendingCustomCell *cell = [subject.approvalpendingTSTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell.contentView.subviews.count should equal(5);
        });

        it(@"should have correct value for subview", ^{
            ApprovalsPendingCustomCell *cell = [subject.approvalpendingTSTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

            UILabel *rightLowerLbl = [cell viewWithTag:6];
            rightLowerLbl.text should equal(@"Proj 2.00, TO 4.50, OT 1.50, Reg 8.00");

            UILabel *rightLbl = [cell viewWithTag:5];
            rightLbl.text should equal(@"30.00");

            UILabel *mealLabel = [cell viewWithTag:4];
            mealLabel.text should be_nil;

            UILabel *mealBreakImageView = [cell viewWithTag:3];
            mealBreakImageView should be_nil;

            UILabel *leftLowerLbl = [cell viewWithTag:2];
            leftLowerLbl.text should equal(@" Jan 01 - Jan 01");

            UILabel *leftLbl = [cell viewWithTag:1];
            leftLbl.text should equal(@"Alba, Jessica");

            rightLbl.hidden should be_truthy;
            rightLowerLbl.hidden should be_truthy;
        });
    });
    
    describe(@"cellForRowAtIndexPath: when displaySummaryByPayCode is false", ^{
        
        beforeEach(^{
            
            NSMutableArray *timesheetsGroupedByDueDates = [NSMutableArray arrayWithArray:@[
                                                                                           [NSMutableArray arrayWithArray:@[
                                                                                                                            [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                                                                                            @"IsSelected": @0,
                                                                                                                                                                            @"approvalStatus": @"Waiting for Approval",
                                                                                                                                                                            @"approval_dueDate": @1433721600,
                                                                                                                                                                            @"approval_dueDateText": @"Jun 8, 2015",
                                                                                                                                                                            @"canEditTimesheet": [NSNull null],
                                                                                                                                                                            @"dueDate" : @1433635200,
                                                                                                                                                                            @"mealBreakPenalties": [NSNull null],
                                                                                                                                                                            @"overtimeDurationDecimal": @1.5,
                                                                                                                                                                            @"overtimeDurationHour" : @"1:5",
                                                                                                                                                                            @"regularDurationDecimal" : @8.0,
                                                                                                                                                                            @"regularDurationHour" : @"8:0",
                                                                                                                                                                            @"timeoffDurationDecimal" : @4.50,
                                                                                                                                                                            @"timeoffDurationHour" : @"4:5",
                                                                                                                                                                            @"projectDurationDecimal"
                                                                                                                                                                            : @2.0,
                                                                                                                                                                            @"projectDurationHour" :
                                                                                                                                                                                @"2:0",
                                                                                                                                                                            
                                                                                                                                                                            @"timesheetFormat" : [NSNull null],
                                                                                                                                                                            @"timesheetPeriod" : @"June 01, 2015 - June 07, 2015",
                                                                                                                                                                            @"timesheetUri" : @"urn:replicon-tenant:astro:timesheet:93f4de07-8bb9-4dcf-8d99-aff9ae9e69ed",
                                                                                                                                                                            @"totalDurationDecimal" : @30.0,
                                                                                                                                                                            @"totalDurationHour" : @"30:0",
                                                                                                                                                                            @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                                                                                            @"username" : @"Alba, Jessica",
                                                                                                                                                                            
                                                                                                                                                                            @"displaySummaryByPayCode" : @1
                                                                                                                                                                            }]
                                                                                                                            ]]
                                                                                           ]];
            
            
            
            approvalsModel stub_method(@selector(getAllPendingTimeSheetsGroupedByDueDatesWithStatus:)).again()
            .and_return(timesheetsGroupedByDueDates);
            
            
            subject.view should_not be_nil;
            [subject viewWillAppear:NO];
            
            tableview = nice_fake_for([UITableView class]);
            
            returnCell = nice_fake_for([ApprovalsPendingCustomCell class]);
            tableview stub_method(@selector(dequeueReusableCellWithIdentifier:)).with(@"PendingApprovalsCellIdentifier").and_return(returnCell);
            
            
            [subject tableView:tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
        });
        
        it(@"should receive correct selector for cell", ^{
            returnCell should have_received(@selector(createCellLayoutWithParams:
                                                      leftLowerString:
                                                      rightstr:
                                                      radioButtonTag:
                                                      overTimeStr:
                                                      mealStr:
                                                      timeOffStr:
                                                      regularStr:
                                                      projectHourStr:
                                                      displaySummaryByPayCode:)).with(@"Alba, Jessica",@" Jan 01 - Jan 01",@"30.00",0,@"1.50",@"<null>",@"4.50",@"8.00",@"2.00", true);
        });
        
        it(@"should have correct number of subview", ^{
            ApprovalsPendingCustomCell *cell = [subject.approvalpendingTSTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell.contentView.subviews.count should equal(5);
        });
        
        it(@"should have correct value for subview", ^{
            ApprovalsPendingCustomCell *cell = [subject.approvalpendingTSTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            UILabel *rightLowerLbl = [cell viewWithTag:6];
            rightLowerLbl.text should equal(@"Proj 2.00, TO 4.50, OT 1.50, Reg 8.00");
            
            UILabel *rightLbl = [cell viewWithTag:5];
            rightLbl.text should equal(@"30.00");
            
            UILabel *mealLabel = [cell viewWithTag:4];
            mealLabel.text should be_nil;
            
            UILabel *mealBreakImageView = [cell viewWithTag:3];
            mealBreakImageView should be_nil;
            
            UILabel *leftLowerLbl = [cell viewWithTag:2];
            leftLowerLbl.text should equal(@" Jan 01 - Jan 01");
            
            UILabel *leftLbl = [cell viewWithTag:1];
            leftLbl.text should equal(@"Alba, Jessica");
            
            rightLbl.hidden should be_falsy;
            rightLowerLbl.hidden should be_falsy;
        });
    });

    describe(@"meal penalties has values", ^{
        beforeEach(^{

            NSMutableArray *timesheetsGroupedByDueDates = [NSMutableArray arrayWithArray:@[
                                                                                           [NSMutableArray arrayWithArray:@[
                                                                                                                            [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                                                                                            @"IsSelected": @0,
                                                                                                                                                                            @"approvalStatus": @"Waiting for Approval",
                                                                                                                                                                            @"approval_dueDate": @1433721600,
                                                                                                                                                                            @"approval_dueDateText": @"Jun 8, 2015",
                                                                                                                                                                            @"canEditTimesheet": [NSNull null],
                                                                                                                                                                            @"dueDate" : @1433635200,
                                                                                                                                                                            @"mealBreakPenalties": @"3.0",
                                                                                                                                                                            @"overtimeDurationDecimal": @1.5,
                                                                                                                                                                            @"overtimeDurationHour" : @"1:5",
                                                                                                                                                                            @"regularDurationDecimal" : @8.0,
                                                                                                                                                                            @"regularDurationHour" : @"8:0",
                                                                                                                                                                            @"timeoffDurationDecimal" : @4.50,
                                                                                                                                                                            @"timeoffDurationHour" : @"4:5",
                                                                                                                                                                            @"projectDurationDecimal"
                                                                                                                                                                            : @2.0,
                                                                                                                                                                            @"projectDurationHour" :
                                                                                                                                                                                @"2:0",

                                                                                                                                                                            @"timesheetFormat" : [NSNull null],
                                                                                                                                                                            @"timesheetPeriod" : @"June 01, 2015 - June 07, 2015",
                                                                                                                                                                            @"timesheetUri" : @"urn:replicon-tenant:astro:timesheet:93f4de07-8bb9-4dcf-8d99-aff9ae9e69ed",
                                                                                                                                                                            @"totalDurationDecimal" : @30.0,
                                                                                                                                                                            @"totalDurationHour" : @"30:0",
                                                                                                                                                                            @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                                                                                            @"username" : @"Alba, Jessica",
                                                                                                                                                                            }]
                                                                                                                            ]]
                                                                                           ]];



            approvalsModel stub_method(@selector(getAllPendingTimeSheetsGroupedByDueDatesWithStatus:)).again()
            .and_return(timesheetsGroupedByDueDates);


            subject.view should_not be_nil;
            [subject viewWillAppear:NO];

            tableview = nice_fake_for([UITableView class]);

            returnCell = nice_fake_for([ApprovalsPendingCustomCell class]);
            tableview stub_method(@selector(dequeueReusableCellWithIdentifier:)).with(@"PendingApprovalsCellIdentifier").and_return(returnCell);

            [subject.approvalpendingTSTableView reloadData];

            [subject tableView:tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

        });


        it(@"should set meal penalty correctly", ^{
            ApprovalsPendingCustomCell *cell = [subject.approvalpendingTSTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

            UILabel *mealLabel = [cell viewWithTag:4];
            mealLabel.text should equal(@"3.0");

            UIImageView *mealBreakImageView = [cell viewWithTag:3];
            mealBreakImageView.image should_not be_nil;

        });


    });

    describe(@"project hours values", ^{

        context(@"project hours is <null>", ^{
            beforeEach(^{

                NSMutableArray *timesheetsGroupedByDueDates = [NSMutableArray arrayWithArray:@[
                                                                                               [NSMutableArray arrayWithArray:@[
                                                                                                                                [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                                                                                                @"IsSelected": @0,
                                                                                                                                                                                @"approvalStatus": @"Waiting for Approval",
                                                                                                                                                                                @"approval_dueDate": @1433721600,
                                                                                                                                                                                @"approval_dueDateText": @"Jun 8, 2015",
                                                                                                                                                                                @"canEditTimesheet": [NSNull null],
                                                                                                                                                                                @"dueDate" : @1433635200,
                                                                                                                                                                                @"mealBreakPenalties": [NSNull null],
                                                                                                                                                                                @"overtimeDurationDecimal": @1.5,
                                                                                                                                                                                @"overtimeDurationHour" : @"1:5",
                                                                                                                                                                                @"regularDurationDecimal" : @8.0,
                                                                                                                                                                                @"regularDurationHour" : @"8:0",
                                                                                                                                                                                @"timeoffDurationDecimal" : @4.50,
                                                                                                                                                                                @"timeoffDurationHour" : @"4:5",
                                                                                                                                                                                @"projectDurationDecimal"
                                                                                                                                                                                : [NSNull null],
                                                                                                                                                                                @"projectDurationHour" :
                                                                                                                                                                                    @"0:0",

                                                                                                                                                                                @"timesheetFormat" : [NSNull null],
                                                                                                                                                                                @"timesheetPeriod" : @"June 01, 2015 - June 07, 2015",
                                                                                                                                                                                @"timesheetUri" : @"urn:replicon-tenant:astro:timesheet:93f4de07-8bb9-4dcf-8d99-aff9ae9e69ed",
                                                                                                                                                                                @"totalDurationDecimal" : @30.0,
                                                                                                                                                                                @"totalDurationHour" : @"30:0",
                                                                                                                                                                                @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                                                                                                @"username" : @"Alba, Jessica",
                                                                                                                                                                                }]
                                                                                                                                ]]
                                                                                               ]];



                approvalsModel stub_method(@selector(getAllPendingTimeSheetsGroupedByDueDatesWithStatus:)).again()
                .and_return(timesheetsGroupedByDueDates);


                subject.view should_not be_nil;
                [subject viewWillAppear:NO];

                tableview = nice_fake_for([UITableView class]);

                returnCell = nice_fake_for([ApprovalsPendingCustomCell class]);
                tableview stub_method(@selector(dequeueReusableCellWithIdentifier:)).with(@"PendingApprovalsCellIdentifier").and_return(returnCell);

                [subject.approvalpendingTSTableView reloadData];

                [subject tableView:tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

            });


            it(@"should set project hours correctly", ^{
                ApprovalsPendingCustomCell *cell = [subject.approvalpendingTSTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                UILabel *rightLowerLbl = [cell viewWithTag:6];
                rightLowerLbl.text should equal(@"TO 4.50, OT 1.50, Reg 8.00");

            });
        });

        context(@"project hours is 0", ^{
            beforeEach(^{

                NSMutableArray *timesheetsGroupedByDueDates = [NSMutableArray arrayWithArray:@[
                                                                                               [NSMutableArray arrayWithArray:@[
                                                                                                                                [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                                                                                                @"IsSelected": @0,
                                                                                                                                                                                @"approvalStatus": @"Waiting for Approval",
                                                                                                                                                                                @"approval_dueDate": @1433721600,
                                                                                                                                                                                @"approval_dueDateText": @"Jun 8, 2015",
                                                                                                                                                                                @"canEditTimesheet": [NSNull null],
                                                                                                                                                                                @"dueDate" : @1433635200,
                                                                                                                                                                                @"mealBreakPenalties": [NSNull null],
                                                                                                                                                                                @"overtimeDurationDecimal": @1.5,
                                                                                                                                                                                @"overtimeDurationHour" : @"1:5",
                                                                                                                                                                                @"regularDurationDecimal" : @8.0,
                                                                                                                                                                                @"regularDurationHour" : @"8:0",
                                                                                                                                                                                @"timeoffDurationDecimal" : @4.50,
                                                                                                                                                                                @"timeoffDurationHour" : @"4:5",
                                                                                                                                                                                @"projectDurationDecimal"
                                                                                                                                                                                : @0.0,
                                                                                                                                                                                @"projectDurationHour" :
                                                                                                                                                                                    @"0:0",

                                                                                                                                                                                @"timesheetFormat" : [NSNull null],
                                                                                                                                                                                @"timesheetPeriod" : @"June 01, 2015 - June 07, 2015",
                                                                                                                                                                                @"timesheetUri" : @"urn:replicon-tenant:astro:timesheet:93f4de07-8bb9-4dcf-8d99-aff9ae9e69ed",
                                                                                                                                                                                @"totalDurationDecimal" : @30.0,
                                                                                                                                                                                @"totalDurationHour" : @"30:0",
                                                                                                                                                                                @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                                                                                                @"username" : @"Alba, Jessica",
                                                                                                                                                                                }]
                                                                                                                                ]]
                                                                                               ]];



                approvalsModel stub_method(@selector(getAllPendingTimeSheetsGroupedByDueDatesWithStatus:)).again()
                .and_return(timesheetsGroupedByDueDates);


                subject.view should_not be_nil;
                [subject viewWillAppear:NO];

                tableview = nice_fake_for([UITableView class]);

                returnCell = nice_fake_for([ApprovalsPendingCustomCell class]);
                tableview stub_method(@selector(dequeueReusableCellWithIdentifier:)).with(@"PendingApprovalsCellIdentifier").and_return(returnCell);

                [subject.approvalpendingTSTableView reloadData];
                
                [subject tableView:tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
            });
            
            
            it(@"should set project hours correctly", ^{
                ApprovalsPendingCustomCell *cell = [subject.approvalpendingTSTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                UILabel *rightLowerLbl = [cell viewWithTag:6];
                rightLowerLbl.text should equal(@"TO 4.50, OT 1.50, Reg 8.00");
                
            });
        });
        
        
    });

});

SPEC_END
