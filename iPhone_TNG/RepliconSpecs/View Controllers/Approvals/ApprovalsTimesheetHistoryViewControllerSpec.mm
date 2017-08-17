#import <Cedar/Cedar.h>
#import "ApprovalsTimesheetHistoryViewController.h"
#import "UITableViewCell+Spec.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "UserSession.h"
#import "UITableViewCell+Spec.h"
#import "UIControl+Spec.h"
#import "ErrorBannerViewParentPresenterHelper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ApprovalsTimesheetHistoryViewControllerSpec)

describe(@"ApprovalsTimesheetHistoryViewController", ^{
    __block ApprovalsTimesheetHistoryViewController *subject;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block ApprovalsModel *approvalsModel;
    __block ApprovalsService *approvalsService;
    __block MinimalTimesheetDeserializer *minimalTimesheetDeserializer;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block id<UserSession> userSession;

    __block id<BSInjector, BSBinder> injector;
    __block LoginModel *loginModel;
    __block UINavigationController *navigationController;

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

        notificationCenter = [[NSNotificationCenter alloc] init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];
        
        errorBannerViewParentPresenterHelper = nice_fake_for([ErrorBannerViewParentPresenterHelper class]);
        [injector bind:[ErrorBannerViewParentPresenterHelper class] toInstance:errorBannerViewParentPresenterHelper];

        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"expected-user-uri");
        [injector bind:@protocol(UserSession) toInstance:userSession];

        loginService = [RepliconServiceManager loginService];
        spy_on(loginService);

        subject = [injector getInstance:[ApprovalsTimesheetHistoryViewController class]];
        spy_on(subject);

        navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
        spy_on(navigationController);
    });

    describe(@"cellForRowAtIndexPath:", ^{

        beforeEach(^{

            NSArray *timesheetHistory = @[@{
                                                     @"approvalStatus" : @"Approved",
                                                     @"approval_dueDate" : @1457913600,
                                                     @"approval_dueDateText" : @"March 14, 2016",
                                                     @"canEditTimesheet" : @"<null>",
                                                     @"dueDate" : @1457827200,
                                                     @"endDate" : @1457827200,
                                                     @"isFromViewTeamTime" : @0,
                                                     @"mealBreakPenalties" : @"<null>",
                                                     @"overtimeDurationDecimal" : @1.50,
                                                     @"overtimeDurationHour" : @"1:5",
                                                     @"projectDurationDecimal" : @"2.0",
                                                     @"projectDurationHour" : @"<2:0",
                                                     @"regularDurationDecimal" : @"25.71666666666667",
                                                     @"regularDurationHour" : @"25:43",
                                                     @"startDate" : @1457308800,
                                                     @"timeoffDurationDecimal" : @0.5,
                                                     @"timeoffDurationHour" : @"0:30",
                                                     @"timesheetFormat" : @"<null>",
                                                     @"timesheetPeriod" : @"March 07, 2016 - March 13, 2016",
                                                     @"timesheetUri" : @"urn:replicon-tenant:repliconiphone-2:timesheet:5b852612-6b0b-4983-b505-c7b4a9b18490",
                                                     @"totalDurationDecimal" : @"25.71666666666667",
                                                     @"totalDurationHour" : @"25:43",
                                                     @"userUri" : @"urn:replicon-tenant:repliconiphone-2:user:670",
                                                     @"username" : @"act, pa1",
                                                     @"displaySummaryByPayCode":@1
                                                     }];



            approvalsModel stub_method(@selector(getAllPreviousTimesheetsOfApprovalFromDB))
            .and_return(timesheetHistory);


            subject.view should_not be_nil;
            [subject viewWillAppear:NO];

            tableview = nice_fake_for([UITableView class]);

            returnCell = nice_fake_for([ApprovalsPendingCustomCell class]);
            tableview stub_method(@selector(dequeueReusableCellWithIdentifier:)).with(@"PendingApprovalsCellIdentifier").and_return(returnCell);

            [subject.approvalHistoryTableView reloadData];

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
                                                      displaySummaryByPayCode:)).with(@"act, pa1",@" Mar 07 - Mar 13",@"25.72",0,@"1.50",@"<null>",@"0.50",@"25.72",@"2.00",true);
        });

        it(@"should have correct number of subview", ^{
            ApprovalsPendingCustomCell *cell = [subject.approvalHistoryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell.contentView.subviews.count should equal(5);
        });

        it(@"should have correct value for subview", ^{
            ApprovalsPendingCustomCell *cell = [subject.approvalHistoryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

            UILabel *rightLowerLbl = [cell viewWithTag:6];
            rightLowerLbl.text should equal(@"Proj 2.00, TO 0.50, OT 1.50, Reg 25.72");

            UILabel *rightLbl = [cell viewWithTag:5];
            rightLbl.text should equal(@"25.72");

            UILabel *mealLabel = [cell viewWithTag:4];
            mealLabel.text should be_nil;

            UILabel *mealBreakImageView = [cell viewWithTag:3];
            mealBreakImageView should be_nil;

            UILabel *leftLowerLbl = [cell viewWithTag:2];
            leftLowerLbl.text should equal(@" Mar 07 - Mar 13");

            UILabel *leftLbl = [cell viewWithTag:1];
            leftLbl.text should equal(@"act, pa1");
            
            
        });

    });

    describe(@"meal penalties has values", ^{
        beforeEach(^{

            NSArray *timesheetHistory = @[@{
                                              @"approvalStatus" : @"Approved",
                                              @"approval_dueDate" : @1457913600,
                                              @"approval_dueDateText" : @"March 14, 2016",
                                              @"canEditTimesheet" : @"<null>",
                                              @"dueDate" : @1457827200,
                                              @"endDate" : @1457827200,
                                              @"isFromViewTeamTime" : @0,
                                              @"mealBreakPenalties" : @"3.0",
                                              @"overtimeDurationDecimal" : @1.50,
                                              @"overtimeDurationHour" : @"1:5",
                                              @"projectDurationDecimal" : @"2.0",
                                              @"projectDurationHour" : @"<2:0",
                                              @"regularDurationDecimal" : @"25.71666666666667",
                                              @"regularDurationHour" : @"25:43",
                                              @"startDate" : @1457308800,
                                              @"timeoffDurationDecimal" : @0.5,
                                              @"timeoffDurationHour" : @"0:30",
                                              @"timesheetFormat" : @"<null>",
                                              @"timesheetPeriod" : @"March 07, 2016 - March 13, 2016",
                                              @"timesheetUri" : @"urn:replicon-tenant:repliconiphone-2:timesheet:5b852612-6b0b-4983-b505-c7b4a9b18490",
                                              @"totalDurationDecimal" : @"25.71666666666667",
                                              @"totalDurationHour" : @"25:43",
                                              @"userUri" : @"urn:replicon-tenant:repliconiphone-2:user:670",
                                              @"username" : @"act, pa1"
                                              }];



            approvalsModel stub_method(@selector(getAllPreviousTimesheetsOfApprovalFromDB))
            .and_return(timesheetHistory);


            subject.view should_not be_nil;
            [subject viewWillAppear:NO];

            tableview = nice_fake_for([UITableView class]);

            returnCell = nice_fake_for([ApprovalsPendingCustomCell class]);
            tableview stub_method(@selector(dequeueReusableCellWithIdentifier:)).with(@"PendingApprovalsCellIdentifier").and_return(returnCell);

            [subject.approvalHistoryTableView reloadData];

            [subject tableView:tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

        });


        it(@"should set meal penalty correctly", ^{
            ApprovalsPendingCustomCell *cell = [subject.approvalHistoryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

            UILabel *mealLabel = [cell viewWithTag:4];
            mealLabel.text should equal(@"3.0");

            UIImageView *mealBreakImageView = [cell viewWithTag:3];
            mealBreakImageView.image should_not be_nil;

        });


    });

    describe(@"the error banner view", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        
        it(@"should check for error banner view and set inset for tableview", ^{
            [subject viewWillAppear:NO];
            
            errorBannerViewParentPresenterHelper should have_received(@selector(setTableViewInsetWithErrorBannerPresentation:))
            .with(subject.approvalHistoryTableView);
        });
    });

    describe(@"project hours values", ^{

        context(@"project hours is <null>", ^{
            beforeEach(^{

                NSArray *timesheetHistory = @[@{
                                                  @"approvalStatus" : @"Approved",
                                                  @"approval_dueDate" : @1457913600,
                                                  @"approval_dueDateText" : @"March 14, 2016",
                                                  @"canEditTimesheet" : @"<null>",
                                                  @"dueDate" : @1457827200,
                                                  @"endDate" : @1457827200,
                                                  @"isFromViewTeamTime" : @0,
                                                  @"mealBreakPenalties" : @"<null>",
                                                  @"overtimeDurationDecimal" : @1.50,
                                                  @"overtimeDurationHour" : @"1:5",
                                                  @"projectDurationDecimal" : @"<null>",
                                                  @"projectDurationHour" : @"<null>",
                                                  @"regularDurationDecimal" : @"25.71666666666667",
                                                  @"regularDurationHour" : @"25:43",
                                                  @"startDate" : @1457308800,
                                                  @"timeoffDurationDecimal" : @0.5,
                                                  @"timeoffDurationHour" : @"0:30",
                                                  @"timesheetFormat" : @"<null>",
                                                  @"timesheetPeriod" : @"March 07, 2016 - March 13, 2016",
                                                  @"timesheetUri" : @"urn:replicon-tenant:repliconiphone-2:timesheet:5b852612-6b0b-4983-b505-c7b4a9b18490",
                                                  @"totalDurationDecimal" : @"25.71666666666667",
                                                  @"totalDurationHour" : @"25:43",
                                                  @"userUri" : @"urn:replicon-tenant:repliconiphone-2:user:670",
                                                  @"username" : @"act, pa1"
                                                  }];



                approvalsModel stub_method(@selector(getAllPreviousTimesheetsOfApprovalFromDB))
                .and_return(timesheetHistory);


                subject.view should_not be_nil;
                [subject viewWillAppear:NO];

                tableview = nice_fake_for([UITableView class]);

                returnCell = nice_fake_for([ApprovalsPendingCustomCell class]);
                tableview stub_method(@selector(dequeueReusableCellWithIdentifier:)).with(@"PendingApprovalsCellIdentifier").and_return(returnCell);

                [subject.approvalHistoryTableView reloadData];

                [subject tableView:tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

            });


            it(@"should set project hours correctly", ^{
                ApprovalsPendingCustomCell *cell = [subject.approvalHistoryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                UILabel *rightLowerLbl = [cell viewWithTag:6];
                rightLowerLbl.text should equal(@"TO 0.50, OT 1.50, Reg 25.72");
                
            });
        });

        context(@"project hours is 0", ^{
            beforeEach(^{

                NSArray *timesheetHistory = @[@{
                                                  @"approvalStatus" : @"Approved",
                                                  @"approval_dueDate" : @1457913600,
                                                  @"approval_dueDateText" : @"March 14, 2016",
                                                  @"canEditTimesheet" : @"<null>",
                                                  @"dueDate" : @1457827200,
                                                  @"endDate" : @1457827200,
                                                  @"isFromViewTeamTime" : @0,
                                                  @"mealBreakPenalties" : @"<null>",
                                                  @"overtimeDurationDecimal" : @1.50,
                                                  @"overtimeDurationHour" : @"1:5",
                                                  @"projectDurationDecimal" : @"0",
                                                  @"projectDurationHour" : @"0:0",
                                                  @"regularDurationDecimal" : @"25.71666666666667",
                                                  @"regularDurationHour" : @"25:43",
                                                  @"startDate" : @1457308800,
                                                  @"timeoffDurationDecimal" : @0.5,
                                                  @"timeoffDurationHour" : @"0:30",
                                                  @"timesheetFormat" : @"<null>",
                                                  @"timesheetPeriod" : @"March 07, 2016 - March 13, 2016",
                                                  @"timesheetUri" : @"urn:replicon-tenant:repliconiphone-2:timesheet:5b852612-6b0b-4983-b505-c7b4a9b18490",
                                                  @"totalDurationDecimal" : @"25.71666666666667",
                                                  @"totalDurationHour" : @"25:43",
                                                  @"userUri" : @"urn:replicon-tenant:repliconiphone-2:user:670",
                                                  @"username" : @"act, pa1"
                                                  }];



                approvalsModel stub_method(@selector(getAllPreviousTimesheetsOfApprovalFromDB))
                .and_return(timesheetHistory);


                subject.view should_not be_nil;
                [subject viewWillAppear:NO];

                tableview = nice_fake_for([UITableView class]);

                returnCell = nice_fake_for([ApprovalsPendingCustomCell class]);
                tableview stub_method(@selector(dequeueReusableCellWithIdentifier:)).with(@"PendingApprovalsCellIdentifier").and_return(returnCell);

                [subject.approvalHistoryTableView reloadData];

                [subject tableView:tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

            });


            it(@"should set project hours correctly", ^{
                ApprovalsPendingCustomCell *cell = [subject.approvalHistoryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                UILabel *rightLowerLbl = [cell viewWithTag:6];
                rightLowerLbl.text should equal(@"TO 0.50, OT 1.50, Reg 25.72");
                
            });
        });
        
        
    });
});

SPEC_END
