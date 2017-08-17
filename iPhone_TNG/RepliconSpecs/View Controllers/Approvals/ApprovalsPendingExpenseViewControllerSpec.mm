#import <Cedar/Cedar.h>
#import "UIBarButtonItem+Spec.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "UIAlertView+Spec.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"
#import "LoginModel.h"
#import "ApprovalsService.h"
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ApprovalsPendingExpenseViewControllerSpec)

describe(@"ApprovalsPendingExpenseViewController", ^{
    __block ApprovalsPendingExpenseViewController *subject;
    __block NSNotificationCenter *notificationCenter;
    __block LoginModel *loginModel;
    __block id<BSInjector, BSBinder> injector;
    __block ApprovalCommentsController *approvalCommentsController;
    __block UINavigationController *navigationController;
    __block id <SpinnerDelegate> spinnerDelegate;
    __block ApprovalsModel *approvalsModel;
    __block ApprovalsService *approvalsService;
    __block LoginService *loginService;

    beforeEach(^{
        injector = [InjectorProvider injector];

        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        [injector bind:@protocol(SpinnerDelegate) toInstance:spinnerDelegate];

        loginModel = nice_fake_for([LoginModel class]);
        [injector bind:[LoginModel class] toInstance:loginModel];

        notificationCenter = [[NSNotificationCenter alloc] init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];

        approvalCommentsController = [[ApprovalCommentsController alloc] initWithNotificationCenter:nil
                                                                                              theme:nil];

        approvalsModel = nice_fake_for([ApprovalsModel class]);
        [injector bind:[ApprovalsModel class] toInstance:approvalsModel];

        approvalsService = nice_fake_for([ApprovalsService class]);
        [injector bind:[ApprovalsService class] toInstance:approvalsService];

        [injector bind:[ApprovalCommentsController class] toInstance:approvalCommentsController];

        loginService = [RepliconServiceManager loginService];
        spy_on(loginService);

        subject = [injector getInstance:[ApprovalsPendingExpenseViewController class]];

        navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
        spy_on(navigationController);
        spy_on(approvalCommentsController);
    });

    describe(@"dealloc", ^{
        describe(@"deallocating the object", ^{
            it(@"should remove itself as an observer of pending approvals notifications", ^{
                [notificationCenter addObserver:subject selector:@selector(handlePendingApprovalsDataReceivedAction) name:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];

                @autoreleasepool {
                    subject = nil;
                };

                [notificationCenter postNotificationName:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil] should_not raise_exception;
            });
        });
    });

    describe(@"showing the comments view controller", ^{

        context(@"When user has not selected expenses for approvals", ^{

            context(@"When approving ", ^{
                __block UIAlertView *alertView;
                beforeEach(^{
                    subject.view should_not be_nil;
                    [subject viewWillAppear:NO];
                    [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToApprove:nil];
                    alertView = [UIAlertView currentAlertView];
                });

                it(@"should present the alertview to indicate user needs to select the expenses", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(APPROVAL_EXPENSESHEET_VALIDATION_MSG);
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

                it(@"should present the alertview to indicate user needs to select the Expense", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(APPROVAL_EXPENSESHEET_VALIDATION_MSG);
                });
            });

        });
        context(@"when user has selected Expense for approvals", ^{
            beforeEach(^{
                subject.selectedSheetsIDsArr = [NSMutableArray arrayWithArray:@[@"My-Special-Expense"]];
            });

            context(@"when approval needs comments permission is true", ^{
                beforeEach(^{
                    loginModel stub_method(@selector(getAllUserDetailsInfoFromDb)).and_return(@[@{@"areExpenseRejectCommentsRequired":[NSNumber numberWithInt:1]}]);
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

            context(@"when approval needs comments permission is false", ^{
                beforeEach(^{
                    loginModel stub_method(@selector(getAllUserDetailsInfoFromDb)).and_return(@[@{@"areExpenseRejectCommentsRequired": @NO}]);
                });

                context(@"and when supervisor is approving", ^{
                    beforeEach(^{
                        [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToApprove:nil];
                    });

                    it(@"should send the expense approval to the approvals service", ^{
                        approvalsService should have_received(@selector(sendRequestToApproveExpenseSheetsWithURI:withComments:andDelegate:))
                            .with(@[@"My-Special-Expense"], [NSNull null], subject);
                    });
                });

                context(@"and when supervisor is approving", ^{
                    beforeEach(^{
                        [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToReject:nil];
                    });

                    it(@"should send the expense approval to the approvals service", ^{
                        approvalsService should have_received(@selector(sendRequestToRejectExpenseSheetsWithURI:withComments:andDelegate:))
                            .with(@[@"My-Special-Expense"], [NSNull null], subject);
                    });
                });
            });
        });

    });

    describe(@"as a <ApprovalCommentsControllerDelegate>", ^{

        __block NSMutableArray *expectedExpenseUriArray;

        beforeEach(^{
            expectedExpenseUriArray = [NSMutableArray arrayWithArray:@[@"My-Special-ExpenseSheet-Uri"]];
            subject.selectedSheetsIDsArr = expectedExpenseUriArray;
            NSMutableArray *expenseSheetsGroupedByDueDates =
            [NSMutableArray arrayWithArray:@[
                                             [NSMutableArray arrayWithArray:@[[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                                              @"IsSelected": @0,
                                                                                                                              @"approvalStatus": @"Waiting for Approval",
                                                                                                                              @"approval_dueDate": @1431388800,
                                                                                                                              @"approval_dueDateText": @"Jun 8, 2015",
                                                                                                                              @"description": @"Dashboard Demo in New York",
                                                                                                                              @"expenseDate" : @1431302400,
                                                                                                                              @"expenseSheetUri": @"urn:replicon-tenant:astro:expense-sheet:22",
                                                                                                                              @"incurredAmount" : @"2725.5",
                                                                                                                              @"incurredAmountCurrencyName" : @"$",
                                                                                                                              @"incurredAmountCurrencyUri" : @"urn:replicon-tenant:astro:currency:1",
                                                                                                                              @"reimbursementAmount" : @"2725.5",
                                                                                                                              @"reimbursementAmountCurrencyName" : @"$",
                                                                                                                              @"reimbursementAmountCurrencyUri" : @"urn:replicon-tenant:astro:currency:1",
                                                                                                                              @"trackingNumber" : @000022,
                                                                                                                              @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                                              @"username" : @"Alba, Jessica",
                                                                                                                              }]
                                                                              ]]
                                             ]];
            approvalsModel stub_method(@selector(getAllPendingExpenseSheetsGroupedByDueDates))
            .and_return(expenseSheetsGroupedByDueDates);
        });
        
        context(@"when supervisor enters comments and approves", ^{
            beforeEach(^{
                [subject  approvalsCommentsControllerDidRequestApproveAction:approvalCommentsController withComments:@"my comments"];
            });

            it(@"should pop back", ^{
                navigationController.topViewController should be_same_instance_as(subject);
            });

            it(@"should send the approval and comments to the approvals service", ^{
                approvalsService should have_received(@selector(sendRequestToApproveExpenseSheetsWithURI:withComments:andDelegate:))
                .with(@[@"My-Special-ExpenseSheet-Uri"], @"my comments", subject);
            });
        });

        context(@"when supervisor enters comments and rejects", ^{
            beforeEach(^{
                [subject  approvalsCommentsControllerDidRequestRejectAction:approvalCommentsController withComments:@"my comments"];
            });

            it(@"should pop back", ^{
                navigationController.topViewController should be_same_instance_as(subject);
            });

            it(@"should send the approval and comments to the approvals service", ^{
                approvalsService should have_received(@selector(sendRequestToRejectExpenseSheetsWithURI:withComments:andDelegate:))
                .with(@[@"My-Special-ExpenseSheet-Uri"], @"my comments", subject);
            });
        });
    });


    describe(@"responding to the notification BEFORE there is data", ^{
        __block UINavigationController *navigationController;

        beforeEach(^{
            NSArray *expensesGroupedByDueDates = [@[
                                                    [@[
                                                       [@{
                                                          @"IsSelected" : @0,
                                                          @"approvalStatus" : @"Waiting for Approval",
                                                          @"approval_dueDate" : @1434758400,
                                                          @"approval_dueDateText" : @"Jun 20, 2015",
                                                          @"description" : @"today",
                                                          @"expenseDate" : @1434672000,
                                                          @"expenseSheetUri" : @"urn:replicon-tenant:astro:expense-sheet:38",
                                                          @"incurredAmount" : @0,
                                                          @"incurredAmountCurrencyName" : @"$",
                                                          @"incurredAmountCurrencyUri" : @"urn:replicon-tenant:astro:currency:1",
                                                          @"reimbursementAmount" : @0,
                                                          @"reimbursementAmountCurrencyName" : @"$",
                                                          @"reimbursementAmountCurrencyUri" : @"urn:replicon-tenant:astro:currency:1",
                                                          @"trackingNumber" : @"000038",
                                                          @"userUri" : @"urn:replicon-tenant:astro:user:75",
                                                          @"username" : @"astro, user",
                                                          } mutableCopy]
                                                       ] mutableCopy]
                                                    ] mutableCopy];

            approvalsModel stub_method(@selector(getAllPendingExpenseSheetsGroupedByDueDates))
                .and_return(nil);

            [subject handlePendingApprovalsDataReceivedAction];

            approvalsModel stub_method(@selector(getAllPendingExpenseSheetsGroupedByDueDates))
                .again().and_return(expensesGroupedByDueDates);

            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            subject.view should_not be_nil;
            [subject viewWillAppear:NO];

            [subject.approvalpendingTSTableView layoutIfNeeded];
        });

        it(@"should not show the 'no expense sheets to approve' message label", ^{
            subject.view.subviews should_not contain(subject.msgLabel);
        });
    });


    describe(@"As a <ApprovalsPendingTimeOffTableViewHeaderDelegate>", ^{

        context(@"When select all", ^{
            beforeEach(^{

                NSMutableArray *expenseSheetsGroupedByDueDates =
                [NSMutableArray arrayWithArray:@[
                                                 [NSMutableArray arrayWithArray:@[[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                                                  @"IsSelected": @0,
                                                                                                                                  @"approvalStatus": @"Waiting for Approval",
                                                                                                                                  @"approval_dueDate": @1431388800,
                                                                                                                                  @"approval_dueDateText": @"Jun 8, 2015",
                                                                                                                                  @"description": @"Dashboard Demo in New York",
                                                                                                                                  @"expenseDate" : @1431302400,
                                                                                                                                  @"expenseSheetUri": @"urn:replicon-tenant:astro:expense-sheet:22",
                                                                                                                                  @"incurredAmount" : @"2725.5",
                                                                                                                                  @"incurredAmountCurrencyName" : @"$",
                                                                                                                                  @"incurredAmountCurrencyUri" : @"urn:replicon-tenant:astro:currency:1",
                                                                                                                                  @"reimbursementAmount" : @"2725.5",
                                                                                                                                  @"reimbursementAmountCurrencyName" : @"$",
                                                                                                                                  @"reimbursementAmountCurrencyUri" : @"urn:replicon-tenant:astro:currency:1",
                                                                                                                                  @"trackingNumber" : @000022,
                                                                                                                                  @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                                                  @"username" : @"Alba, Jessica",
                                                                                                                                  }]
                                                                                  ]]
                                                 ]];
                approvalsModel stub_method(@selector(getAllPendingExpenseSheetsGroupedByDueDates))
                .and_return(expenseSheetsGroupedByDueDates);


                subject.view should_not be_nil;
                [subject viewWillAppear:NO];

                [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:nil];
            });

            it(@"should select the selected", ^{
                subject.selectedSheetsIDsArr.count should equal(1);
                subject.selectedSheetsIDsArr.firstObject should equal(@"urn:replicon-tenant:astro:expense-sheet:22");
            });
        });

        context(@"When clear all", ^{
            beforeEach(^{
                NSMutableArray *expenseSheetsGroupedByDueDates =
                [NSMutableArray arrayWithArray:@[
                                                 [NSMutableArray arrayWithArray:@[[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                                                  @"IsSelected": @0,
                                                                                                                                  @"approvalStatus": @"Waiting for Approval",
                                                                                                                                  @"approval_dueDate": @1431388800,
                                                                                                                                  @"approval_dueDateText": @"Jun 8, 2015",
                                                                                                                                  @"description": @"Dashboard Demo in New York",
                                                                                                                                  @"expenseDate" : @1431302400,
                                                                                                                                  @"expenseSheetUri": @"urn:replicon-tenant:astro:expense-sheet:22",
                                                                                                                                  @"incurredAmount" : @"2725.5",
                                                                                                                                  @"incurredAmountCurrencyName" : @"$",
                                                                                                                                  @"incurredAmountCurrencyUri" : @"urn:replicon-tenant:astro:currency:1",
                                                                                                                                  @"reimbursementAmount" : @"2725.5",
                                                                                                                                  @"reimbursementAmountCurrencyName" : @"$",
                                                                                                                                  @"reimbursementAmountCurrencyUri" : @"urn:replicon-tenant:astro:currency:1",
                                                                                                                                  @"trackingNumber" : @000022,
                                                                                                                                  @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                                                  @"username" : @"Alba, Jessica",
                                                                                                                                  }]
                                                                                  ]]
                                                 ]];
                approvalsModel stub_method(@selector(getAllPendingExpenseSheetsGroupedByDueDates))
                .and_return(expenseSheetsGroupedByDueDates);


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

            NSMutableArray *expenseSheetsGroupedByDueDates =
            [NSMutableArray arrayWithArray:@[
                                             [NSMutableArray arrayWithArray:@[[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                                              @"IsSelected": @0,
                                                                                                                              @"approvalStatus": @"Waiting for Approval",
                                                                                                                              @"approval_dueDate": @1431388800,
                                                                                                                              @"approval_dueDateText": @"Jun 8, 2015",
                                                                                                                              @"description": @"Dashboard Demo in New York",
                                                                                                                              @"expenseDate" : @1431302400,
                                                                                                                              @"expenseSheetUri": @"urn:replicon-tenant:astro:expense-sheet:22",
                                                                                                                              @"incurredAmount" : @"2725.5",
                                                                                                                              @"incurredAmountCurrencyName" : @"$",
                                                                                                                              @"incurredAmountCurrencyUri" : @"urn:replicon-tenant:astro:currency:1",
                                                                                                                              @"reimbursementAmount" : @"2725.5",
                                                                                                                              @"reimbursementAmountCurrencyName" : @"$",
                                                                                                                              @"reimbursementAmountCurrencyUri" : @"urn:replicon-tenant:astro:currency:1",
                                                                                                                              @"trackingNumber" : @000022,
                                                                                                                              @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                                              @"username" : @"Alba, Jessica",
                                                                                                                              }]
                                                                              ]]
                                             ]];
            approvalsModel stub_method(@selector(getAllPendingExpenseSheetsGroupedByDueDates))
            .and_return(expenseSheetsGroupedByDueDates);


            subject.view should_not be_nil;
            [subject viewWillAppear:NO];

            [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:nil];
            
            [subject refreshAction];
        });
        
        it(@"When refresh action is successfull, should reset the toggle button title correctly", ^{
            [notificationCenter postNotificationName:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];

            ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (id)subject.approvalpendingTSTableView.tableHeaderView;
            approvalsPendingTimeOffTableViewHeader.toggleButton.titleLabel.text should equal(@"Select All");
        });

        it(@"should fetchGetMyNotificationSummary", ^{
            loginService should have_received(@selector(fetchGetMyNotificationSummary));
        });
    });
});

SPEC_END
