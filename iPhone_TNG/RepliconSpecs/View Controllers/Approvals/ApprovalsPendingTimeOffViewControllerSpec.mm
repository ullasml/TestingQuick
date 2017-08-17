#import <Cedar/Cedar.h>
#import "UIControl+Spec.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "ApprovalsPendingTimeOffViewController.h"
#import "ApprovalsModel.h"
#import "ApprovalsPendingTimeOffTableViewHeader.h"
#import "ApproveRejectHeaderStylist.h"
#import "ApprovalsService.h"
#import "ApprovalsPendingCustomCell.h"
#import "ApprovalCommentsController.h"
#import "InjectorKeys.h"
#import "ErrorBannerViewParentPresenterHelper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ApprovalsPendingTimeOffViewControllerSpec)

describe(@"ApprovalsPendingTimeOffViewController", ^{
    __block ApprovalsPendingTimeOffViewController *subject;
    __block NSNotificationCenter *notificationCenter;
    __block ApprovalsModel *approvalsModel;
    __block LoginModel *loginModel;
    __block ApprovalsService *approvalsService;
    __block ApproveRejectHeaderStylist *tableviewHeaderStylist;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block ApprovalCommentsController *approvalCommentsController;
    __block UINavigationController *navigationController;
    __block id<BSBinder, BSInjector> injector;
    __block LoginService *loginService;
    __block ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;


    beforeEach(^{

        injector = [InjectorProvider injector];

        tableviewHeaderStylist = nice_fake_for([ApproveRejectHeaderStylist class]);
        [injector bind:[ApproveRejectHeaderStylist class] toInstance:tableviewHeaderStylist];


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

        approvalCommentsController = [[ApprovalCommentsController alloc] initWithNotificationCenter:nil
                                                                                              theme:nil];
        [injector bind:[ApprovalCommentsController class] toInstance:approvalCommentsController];
        
        errorBannerViewParentPresenterHelper = nice_fake_for([ErrorBannerViewParentPresenterHelper class]);
        [injector bind:[ErrorBannerViewParentPresenterHelper class] toInstance:errorBannerViewParentPresenterHelper];

        loginService = [RepliconServiceManager loginService];
        spy_on(loginService);

        subject = [injector getInstance:[ApprovalsPendingTimeOffViewController class]];

        navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
        spy_on(navigationController);
        spy_on(approvalCommentsController);
    });

    describe(@"-dealloc", ^{
        it(@"should remove itself as an observer of pending approvals notifications", ^{
            @autoreleasepool {
                ApprovalsPendingTimeOffViewController *deallocatedSubject = [[ApprovalsPendingTimeOffViewController alloc] initWithErrorBannerViewParentPresenterHelper:nil
                                                                                                                                                 tableviewHeaderStylist:tableviewHeaderStylist
                                                                                                                                                     notificationCenter:notificationCenter approvalsService:approvalsService
                                                                                                                                                        spinnerDelegate:spinnerDelegate             approvalsModel:approvalsModel
                                                                                                                                                           loginService:nil
                                                                                                                                                             loginModel:nil];

                [notificationCenter addObserver:deallocatedSubject selector:@selector(handlePendingApprovalsDataReceivedAction) name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];
            };

            [notificationCenter postNotificationName:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil] should_not raise_exception;
        });
    });

    describe(@"its tableview header", ^{
        __block UITableView *tableview;
        __block UITableViewHeaderFooterView *headerView;

        beforeEach(^{
            subject.view should_not be_nil;
            tableview = subject.approvalpendingTSTableView;
            [tableview layoutIfNeeded];

            headerView = (id)tableview.tableHeaderView;
        });

        it(@"should be the correct view", ^{
            headerView should be_instance_of([ApprovalsPendingTimeOffTableViewHeader class]);
        });

        it(@"should have its buttons styled appropriately", ^{
            tableviewHeaderStylist should have_received(@selector(styleApproveRejectHeader:)).with(headerView);
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

    describe(@"approving or rejecting time off requests", ^{
        beforeEach(^{
            NSMutableDictionary *approvalModel = [@{@"timeoffUri": @"nacho-uris"} mutableCopy];
            NSMutableArray *fakeApprovals = [@[approvalModel] mutableCopy];
            approvalsModel stub_method(@selector(getAllPendingTimeoffs)).and_return(fakeApprovals);

            subject.view should_not be_nil;
            [subject viewWillAppear:NO];
        });


        context(@"when the user is required to leave comments", ^{
            beforeEach(^{
                loginModel stub_method(@selector(getAllUserDetailsInfoFromDb)).and_return(@[@{@"areTimeOffRejectCommentsRequired": @YES}]);
            });

            context(@"and when supervisor is rejecting", ^{
                beforeEach(^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [subject handleButtonClickforSelectedUser:indexPath isSelected:YES];

                    [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToReject:nil];
                });

                it(@"should set up the comments controller correctly", ^{
                    approvalCommentsController should have_received(@selector(setUpApprovalActionType:delegate:commentsRequired:)).with(RejectActionType,subject,YES);
                });

                it(@"should push a comments controller onto the nav stack", ^{
                    navigationController.topViewController should be_same_instance_as(approvalCommentsController);
                });
            });
        });

        context(@"when the user is not required to leave comments", ^{
            beforeEach(^{
                loginModel stub_method(@selector(getAllUserDetailsInfoFromDb)).and_return(@[@{@"areTimeOffRejectCommentsRequired": @NO}]);
            });

            context(@"when at least one cell is selected and approve is tapped", ^{
                beforeEach(^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [subject handleButtonClickforSelectedUser:indexPath isSelected:YES];

                    [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToApprove:nil];
                });

                it(@"should send a request to the approvals service", ^{
                    approvalsService should have_received(@selector(sendRequestToApproveTimeOffsWithURI:withComments:andDelegate:));
                });
            });

            context(@"when at least one cell is selected and reject is tapped", ^{
                beforeEach(^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [subject handleButtonClickforSelectedUser:indexPath isSelected:YES];

                    [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToReject:nil];
                });

                it(@"should send a request to the approvals service", ^{
                    approvalsService should have_received(@selector(sendRequestToRejectTimeOffsWithURI:withComments:andDelegate:));
                });
            });
        });
    });

    describe(NSStringFromSelector(@selector(handlePendingApprovalsDataReceivedAction)), ^{
        describe(@"when the request fetch pending approvals completes", ^{
            context(@"when there are zero users", ^{
                beforeEach(^{
                    approvalsModel stub_method(@selector(getAllPendingTimeoffs)).and_return(@[]);
                    [subject handlePendingApprovalsDataReceivedAction];
                });

                it(@"should remove the message label from the view", ^{
                    subject.view.subviews should contain(subject.msgLabel);
                });
            });

            context(@"when there is more than zero users", ^{
                beforeEach(^{
                    NSMutableArray *fakeMutableArrayOfUsers = [NSMutableArray array];
                    NSMutableDictionary *fakeUserJSONDictionary = [NSMutableDictionary dictionary];
                    [fakeMutableArrayOfUsers addObject:fakeUserJSONDictionary];
                    approvalsModel stub_method(@selector(getAllPendingTimeoffs)).and_return(fakeMutableArrayOfUsers);
                    [subject handlePendingApprovalsDataReceivedAction];
                });

                it(@"should not remove the message label from the view", ^{
                    subject.view.subviews should_not contain(subject.msgLabel);
                });
            });
        });
    });

    describe(@"as a <ApprovalCommentsControllerDelegate>", ^{
        __block NSMutableArray *expectedTimeOffUriArray;
        __block UIViewController *secondController;

        beforeEach(^{
            secondController = [[UIViewController alloc] init];
            [navigationController pushViewController:secondController animated:NO];

            expectedTimeOffUriArray = [NSMutableArray arrayWithArray:@[@"My-Special-TimeOff-Uri"]];
            subject.selectedSheetsIDsArr = expectedTimeOffUriArray;
            NSMutableArray *allPendingTimeOffs =
            [NSMutableArray arrayWithArray:@[
            [NSMutableArray arrayWithArray:@[
            [NSMutableDictionary dictionaryWithDictionary:@{
                                                          @"IsSelected": @0,
                                                          @"approvalStatus": @"Waiting for Approval",
                                                          @"approval_dueDate": [NSNull null],
                                                          @"approval_dueDateText": [NSNull null],
                                                          @"dueDate" : @1434648791,
                                                          @"endDate" : @1434585600,
                                                          @"startDate" : @1434585600,
                                                          @"timeoffTypeName": @"Vacation",
                                                          @"timeoffTypeUri": @"urn:replicon-tenant:astro:time-off-type:",
                                                          @"timeoffUri": @"urn:replicon-tenant:astro:time-off:351",
                                                          @"totalDurationDecimal" : @8,
                                                          @"totalDurationHour" : @"8:0",
                                                          @"totalTimeoffDays" : @1,
                                                          @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                          @"username" : @"Alba, Jessica",
                                                          }]
                                                        ]]
                                                        ]];

            approvalsModel stub_method(@selector(getAllPendingTimeoffs))
            .and_return(allPendingTimeOffs);
        });

        context(@"when supervisor enters comments and approves", ^{
            beforeEach(^{
                [subject approvalsCommentsControllerDidRequestApproveAction:approvalCommentsController withComments:@"my comments"];
            });

            it(@"should pop back", ^{
                navigationController.topViewController should be_same_instance_as(subject);
            });

            it(@"should send the approval and comments to the approvals service", ^{
                approvalsService should have_received(@selector(sendRequestToApproveTimeOffsWithURI:withComments:andDelegate:))
                    .with(@[@"My-Special-TimeOff-Uri"], @"my comments", subject);
            });
        });

        context(@"when supervisor enters comments and rejects", ^{
            beforeEach(^{
                [subject approvalsCommentsControllerDidRequestRejectAction:approvalCommentsController withComments:@"my comments"];
            });

            it(@"should pop back", ^{
                navigationController.topViewController should be_same_instance_as(subject);
            });

            it(@"should send the approval and comments to the approvals service", ^{
                approvalsService should have_received(@selector(sendRequestToRejectTimeOffsWithURI:withComments:andDelegate:))
                    .with(@[@"My-Special-TimeOff-Uri"], @"my comments", subject);
            });
        });
    });

    describe(@"responding to the notification BEFORE there is data", ^{
        __block UINavigationController *navigationController;

        beforeEach(^{
            NSArray *expensesGroupedByDueDates = [@[
                                                    [@{
                                                       @"approvalStatus " : @"Waiting for Approval",
                                                       @"approval_dueDate" : [NSNull null],
                                                       @"approval_dueDateText" : [NSNull null],
                                                       @"dueDate" : @1434708917,
                                                       @"endDate" : @1434672000,
                                                       @"startDate" : @1434672000,
                                                       @"timeoffTypeName" : @"Family Emergency",
                                                       @"timeoffTypeUri" : @"urn:replicon-tenant:astro:time-off-type:3",
                                                       @"timeoffUri" : @"urn:replicon-tenant:astro:time-off:361",
                                                       @"totalDurationDecimal" : @8,
                                                       @"totalDurationHour" : @"8:0",
                                                       @"totalTimeoffDays" : @1,
                                                       @"userUri" : @"urn:replicon-tenant:astro:user:75",
                                                       @"username" : @"astro, user",
                                                       } mutableCopy]
                                                    ] mutableCopy];

            approvalsModel stub_method(@selector(getAllPendingTimeoffs))
                .and_return(nil);

            [subject handlePendingApprovalsDataReceivedAction];

            approvalsModel stub_method(@selector(getAllPendingTimeoffs))
                .again().and_return(expensesGroupedByDueDates);

            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            subject.view should_not be_nil;
            [subject viewWillAppear:NO];

            [subject.approvalpendingTSTableView layoutIfNeeded];
        });

        it(@"should not show the 'no time off requests to approve' message label", ^{
            subject.view.subviews should_not contain(subject.msgLabel);
        });
    });

    describe(@"As a <ApprovalsPendingTimeOffTableViewHeaderDelegate>", ^{

        context(@"When select all", ^{
            beforeEach(^{

                NSMutableArray *allPendingTimeOffs =
                [NSMutableArray arrayWithArray:@[
                                                 [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                 @"IsSelected": @0,
                                                                                                 @"approvalStatus": @"Waiting for Approval",
                                                                                                 @"approval_dueDate": [NSNull null],
                                                                                                 @"approval_dueDateText": [NSNull null],
                                                                                                 @"dueDate" : @1434648791,
                                                                                                 @"endDate" : @1434585600,
                                                                                                 @"startDate" : @1434585600,
                                                                                                 @"timeoffTypeName": @"Vacation",
                                                                                                 @"timeoffTypeUri": @"urn:replicon-tenant:astro:time-off-type:",
                                                                                                 @"timeoffUri": @"urn:replicon-tenant:astro:time-off:351",
                                                                                                 @"totalDurationDecimal" : @8,
                                                                                                 @"totalDurationHour" : @"8:0",
                                                                                                 @"totalTimeoffDays" : @1,
                                                                                                 @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                 @"username" : @"Alba, Jessica",
                                                                                                 }]
                                                 ]];

                
                approvalsModel stub_method(@selector(getAllPendingTimeoffs))
                .and_return(allPendingTimeOffs);


                subject.view should_not be_nil;
                [subject viewWillAppear:NO];

                [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:nil];

            });

            it(@"should select the selected", ^{
                subject.selectedSheetsIDsArr.count should equal(1);
                subject.selectedSheetsIDsArr.firstObject should equal(@"urn:replicon-tenant:astro:time-off:351");
            });
        });

        context(@"When clear all", ^{
            beforeEach(^{
                NSMutableArray *allPendingTimeOffs =
                [NSMutableArray arrayWithArray:@[
                                                 [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                 @"IsSelected": @0,
                                                                                                 @"approvalStatus": @"Waiting for Approval",
                                                                                                 @"approval_dueDate": [NSNull null],
                                                                                                 @"approval_dueDateText": [NSNull null],
                                                                                                 @"dueDate" : @1434648791,
                                                                                                 @"endDate" : @1434585600,
                                                                                                 @"startDate" : @1434585600,
                                                                                                 @"timeoffTypeName": @"Vacation",
                                                                                                 @"timeoffTypeUri": @"urn:replicon-tenant:astro:time-off-type:",
                                                                                                 @"timeoffUri": @"urn:replicon-tenant:astro:time-off:351",
                                                                                                 @"totalDurationDecimal" : @8,
                                                                                                 @"totalDurationHour" : @"8:0",
                                                                                                 @"totalTimeoffDays" : @1,
                                                                                                 @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                                 @"username" : @"Alba, Jessica",
                                                                                                 }]
                                                 ]];

                
                approvalsModel stub_method(@selector(getAllPendingTimeoffs))
                .and_return(allPendingTimeOffs);


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

            NSMutableArray *allPendingTimeOffs =
            [NSMutableArray arrayWithArray:@[
                                             [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                             @"IsSelected": @0,
                                                                                             @"approvalStatus": @"Waiting for Approval",
                                                                                             @"approval_dueDate": [NSNull null],
                                                                                             @"approval_dueDateText": [NSNull null],
                                                                                             @"dueDate" : @1434648791,
                                                                                             @"endDate" : @1434585600,
                                                                                             @"startDate" : @1434585600,
                                                                                             @"timeoffTypeName": @"Vacation",
                                                                                             @"timeoffTypeUri": @"urn:replicon-tenant:astro:time-off-type:",
                                                                                             @"timeoffUri": @"urn:replicon-tenant:astro:time-off:351",
                                                                                             @"totalDurationDecimal" : @8,
                                                                                             @"totalDurationHour" : @"8:0",
                                                                                             @"totalTimeoffDays" : @1,
                                                                                             @"userUri" : @"urn:replicon-tenant:astro:user:70",
                                                                                             @"username" : @"Alba, Jessica",
                                                                                             }]
                                             ]];

            approvalsModel stub_method(@selector(getAllPendingTimeoffs))
            .and_return(allPendingTimeOffs);


            subject.view should_not be_nil;
            [subject viewWillAppear:NO];

            [subject approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:nil];

            [subject refreshAction];
        });

        it(@"When refresh action is successfull, should reset the toggle button title correctly", ^{
            [notificationCenter postNotificationName:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];

            ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (id)subject.approvalpendingTSTableView.tableHeaderView;
            approvalsPendingTimeOffTableViewHeader.toggleButton.titleLabel.text should equal(@"Select All");
        });

        it(@"should fetchGetMyNotificationSummary", ^{
            loginService should have_received(@selector(fetchGetMyNotificationSummary));
        });
    });
});

SPEC_END
