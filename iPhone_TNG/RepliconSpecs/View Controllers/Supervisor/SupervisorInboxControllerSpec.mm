#import <Cedar/Cedar.h>
#import "Theme.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "SupervisorInboxController.h"
#import "Violation.h"
#import "ViolationEmployee.h"
#import "SupervisorDashboardSummary.h"
#import "AllViolationSections.h"
#import "ViolationSection.h"
#import <KSDeferred/KSDeferred.h>
#import "SupervisorDashboardSummaryRepository.h"
#import "InboxSpinnerCell.h"
#import "ApprovalsPendingTimeOffViewController.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import "ApprovalsRepository.h"
#import "OvertimeSummaryController.h"
#import "violationsSummaryController.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "OvertimeSummaryControllerProvider.h"
#import "ViolationsSummaryControllerProvider.h"
#import "InjectorKeys.h"
#import "UITableViewCell+Spec.h"
#import "InboxCell.h"
#import "UserPermissionsStorage.h"
#import "FrameworkImport.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SupervisorInboxControllerSpec)

describe(@"SupervisorInboxController", ^{
    __block SupervisorInboxController *subject;
    __block id<BSBinder, BSInjector> injector;
    __block ApprovalsPendingTimesheetViewController *approvalsPendingTimesheetViewController;
    __block ApprovalsPendingExpenseViewController *approvalsPendingExpenseViewController;
    __block ApprovalsPendingTimeOffViewController *approvalsPendingTimeOffViewController;
    __block ViolationsSummaryControllerProvider *violationsSummaryControllerProvider;
    __block OvertimeSummaryControllerProvider *overtimeSummaryControllerProvider;
    __block SupervisorDashboardSummaryRepository *dashboardSummaryRepository;
    __block ViolationsSummaryController *violationsSummaryController;
    __block OvertimeSummaryController *overtimeSummaryController;
    __block UINavigationController *navigationController;
    __block UserPermissionsStorage *permissionsStorage;
    __block ApprovalsRepository *approvalsRepository;
    __block NSNotificationCenter *notificationCenter;
    __block id<Theme> theme;
    __block GATracker *tracker;
    __block LoginService *loginService;

    beforeEach(^{
        injector = [InjectorProvider injector];

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        notificationCenter = [[NSNotificationCenter alloc] init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];

        approvalsRepository = nice_fake_for([ApprovalsRepository class]);
        [injector bind:[ApprovalsRepository class] toInstance:approvalsRepository];

        approvalsPendingTimesheetViewController = [[ApprovalsPendingTimesheetViewController alloc] initWithErrorBannerViewParentPresenterHelper:nil
                                                                                                                   minimalTimesheetDeserializer:nil
                                                                                                                         userPermissionsStorage:nil
                                                                                                                            reachabilityMonitor:nil
                                                                                                                             notificationCenter:nil
                                                                                                                               approvalsService:nil
                                                                                                                                spinnerDelegate:nil
                                                                                                                                 approvalsModel:nil
                                                                                                                                    userSession:nil
                                                                                                                                     loginModel:nil
                                                                                                                                   loginService:nil];
        spy_on(approvalsPendingTimesheetViewController);
        [injector bind:[ApprovalsPendingTimesheetViewController class] toInstance:approvalsPendingTimesheetViewController];

        approvalsPendingExpenseViewController = [[ApprovalsPendingExpenseViewController alloc] initWithNotificationCenter:nil
                                                                                                          spinnerDelegate:nil
                                                                                                         approvalsService:nil
                                                                                                           approvalsModel:nil
                                                                                                               loginModel:nil
                                                                                                             loginService:nil];
        spy_on(approvalsPendingExpenseViewController);

        [injector bind:[ApprovalsPendingExpenseViewController class] toInstance:approvalsPendingExpenseViewController];

        approvalsPendingTimeOffViewController = [[ApprovalsPendingTimeOffViewController alloc] initWithErrorBannerViewParentPresenterHelper:nil
                                                                                                                     tableviewHeaderStylist:nil
                                                                                                                         notificationCenter:nil
                                                                                                                           approvalsService:nil
                                                                                                                            spinnerDelegate:nil
                                                                                                                             approvalsModel:nil
                                                                                                                               loginService:nil
                                                                                                                                 loginModel:nil];
        spy_on(approvalsPendingTimeOffViewController);
        [injector bind:[approvalsPendingTimeOffViewController class] toInstance:approvalsPendingTimeOffViewController];

        overtimeSummaryController = (id) [[UIViewController alloc]init];
        overtimeSummaryControllerProvider = fake_for([OvertimeSummaryControllerProvider class]);
        overtimeSummaryControllerProvider stub_method(@selector(provideInstanceWithOvertimeSummaryPromise:)).and_return(overtimeSummaryController);
        [injector bind:[OvertimeSummaryControllerProvider class] toInstance:overtimeSummaryControllerProvider];

        violationsSummaryController = (id) [[UIViewController alloc]init];
        violationsSummaryControllerProvider = nice_fake_for([ViolationsSummaryControllerProvider class]);
        violationsSummaryControllerProvider stub_method(@selector(provideInstanceWithViolationSectionsPromise:delegate:)).and_return(violationsSummaryController);
        [injector bind:[ViolationsSummaryControllerProvider class] toInstance:violationsSummaryControllerProvider];

        dashboardSummaryRepository = nice_fake_for([SupervisorDashboardSummaryRepository class]);
        [injector bind:[SupervisorDashboardSummaryRepository class] toInstance:dashboardSummaryRepository];

        permissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:permissionsStorage];
        permissionsStorage stub_method(@selector(canApproveTimesheets)).and_return(YES);
        permissionsStorage stub_method(@selector(canApproveExpenses)).and_return(YES);
        permissionsStorage stub_method(@selector(canApproveTimeoffs)).and_return(YES);

        tracker = nice_fake_for([GATracker class]);
        [injector bind:[GATracker class] toInstance:tracker];

        loginService = [RepliconServiceManager loginService];
        spy_on(loginService);
    });

    beforeEach(^{
        subject = [injector getInstance:[SupervisorInboxController class]];
        subject.delegate = nice_fake_for(@protocol(SupervisorInboxControllerDelegate));;

        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
    });

    describe(@"styling the views", ^{
        beforeEach(^{
            theme stub_method(@selector(cardContainerBackgroundColor)).and_return([UIColor purpleColor]);
            theme stub_method(@selector(cardContainerHeaderFont)).and_return([UIFont italicSystemFontOfSize:17.0f]);
            theme stub_method(@selector(cardContainerHeaderColor)).and_return([UIColor greenColor]);
            theme stub_method(@selector(cardContainerSeparatorColor)).and_return([UIColor cyanColor]);
            theme stub_method(@selector(cardContainerBorderColor)).and_return([[UIColor magentaColor] CGColor]);
            theme stub_method(@selector(cardContainerBorderWidth)).and_return((CGFloat)12.0);

            subject.view should_not be_nil;
        });

        it(@"should style the view", ^{
            subject.view.backgroundColor should equal([UIColor purpleColor]);
            subject.view.layer.borderColor should equal([[UIColor magentaColor] CGColor]);
            subject.view.layer.borderWidth should equal(12.0f);
        });

        it(@"should style the header label", ^{
            subject.headerLabel.textColor should equal([UIColor greenColor]);
            subject.headerLabel.font should equal([UIFont italicSystemFontOfSize:17.0f]);
        });

        it(@"should style the separator", ^{
            subject.separatorView.backgroundColor should equal([UIColor cyanColor]);
        });
    });

    describe(@"as a <ViolationsSummaryControllerDelegate>", ^{
        describe(@"violationsSummaryControllerDidRequestViolationSectionsPromise:", ^{
            __block KSPromise *violationsPromise;
            __block KSDeferred *dashboardSummaryDeferred;
            __block NSArray *employeeViolationsArray;
            __block ViolationEmployee *violationEmployee;

            beforeEach(^{
                subject.view should_not be_nil;

                dashboardSummaryDeferred = [[KSDeferred alloc] init];
                dashboardSummaryRepository stub_method(@selector(fetchMostRecentDashboardSummary)).and_return(dashboardSummaryDeferred.promise);

                Violation *violation = [[Violation alloc] initWithSeverity:ViolationSeverityError waiver:nil title:nil];
                employeeViolationsArray = @[violation];
                violationEmployee = [[ViolationEmployee alloc] initWithName:@"asdf" uri:@"asdf" violations:employeeViolationsArray];

                SupervisorDashboardSummary *summary = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:0
                                                                                                    expensesNeedingApprovalCount:0
                                                                                             timeOffRequestsNeedingApprovalCount:0
                                                                                                             clockedInUsersCount:0
                                                                                                                 notInUsersCount:0
                                                                                                               onBreakUsersCount:0
                                                                                                     usersWithOvertimeHoursCount:0
                                                                                                        usersWithViolationsCount:1
                                                                                                              overtimeUsersArray:0
                                                                                                    employeesWithViolationsArray:@[violationEmployee]];
                [dashboardSummaryDeferred resolveWithValue:summary];

                violationsPromise = [subject violationsSummaryControllerDidRequestViolationSectionsPromise:nil];
            });

            it(@"should make a request for todays violations", ^{
                AllViolationSections *violationSections = violationsPromise.value;
                violationSections.sections.count should equal(1);

                ViolationSection *section = [violationSections.sections firstObject];
                section.titleObject should be_same_instance_as(violationEmployee);
                section.type should equal(ViolationSectionTypeEmployee);
                section.violations should be_same_instance_as(employeeViolationsArray);
            });
        });
    });

    describe(@"supervisor inbox", ^{
        __block KSDeferred *dashboardSummaryDeferred;

        beforeEach(^{
            dashboardSummaryDeferred = [KSDeferred defer];
            [subject updateWithDashboardSummaryPromise:dashboardSummaryDeferred.promise];
        });

        context(@"when the view is first loaded", ^{
            __block NSIndexPath *firstRowIndexPath;

            beforeEach(^{
                firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                subject.view should_not be_nil;
            });

            it(@"should have a single row with a spinner in it", ^{
                subject.tableView.numberOfSections should equal(1);
                [subject.tableView numberOfRowsInSection:0] should equal(1);

                UITableViewCell *loadingCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                loadingCell should be_instance_of([InboxSpinnerCell class]);
            });

            it(@"should ask the inboxCardContentStylist to set the height of the inbox card content correctly", ^{
                CGFloat height = 80.0f;
                subject.delegate should have_received(@selector(supervisorInboxController:shouldUpdateHeight:)).with(subject, height);
            });

            describe(@"tapping on the spinner row", ^{
                it(@"should do nothing", ^{
                    UITableViewCell *loadingCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [loadingCell tap];

                    navigationController.topViewController should be_same_instance_as(subject);
                });
            });
        });

        context(@"when the repository succesfully fetches the summary", ^{

            context(@"with values for all of the rows with permissions", ^{
                beforeEach(^{
                    SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);
                    dashboardSummary stub_method(@selector(timesheetsNeedingApprovalCount)).and_return((NSInteger) 4);
                    dashboardSummary stub_method(@selector(expensesNeedingApprovalCount)).and_return((NSInteger) 2);
                    dashboardSummary stub_method(@selector(timeOffRequestsNeedingApprovalCount)).and_return((NSInteger) 3);
                    dashboardSummary stub_method(@selector(usersWithOvertimeHoursCount)).and_return((NSInteger) 6);
                    dashboardSummary stub_method(@selector(usersWithViolationsCount)).and_return((NSInteger) 9);

                    [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
                });

                it(@"should update the inbox with the totals", ^{
                    NSString *expectedString;

                    subject.tableView.numberOfSections should equal(1);
                    [subject.tableView numberOfRowsInSection:0] should equal(5);

                    InboxCell *timesheetsCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@",4,RPLocalizedString(@"Timesheets for Approval", @"supervisor-dashboard.%lu Timesheets for Approval")];
                    timesheetsCell.label.text should equal(expectedString);
                    timesheetsCell.contentView.subviews.count should equal(1);
                    timesheetsCell.contentView.subviews.lastObject should_not be_instance_of([UIActivityIndicatorView class]);

                    InboxCell *expensesCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@",2,RPLocalizedString(@"Expenses for Approval", @"supervisor-dashboard.%lu Expenses for Approval")];
                    expensesCell.label.text should equal(expectedString);
                    expensesCell.contentView.subviews.count should equal(1);
                    expensesCell.contentView.subviews.lastObject should_not be_instance_of([UIActivityIndicatorView class]);

                    InboxCell *timeOffCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@",3,RPLocalizedString(@"Time Off Requests for Approval", @"supervisor-dashboard.%lu Time Off Requests for Approval")];
                    timeOffCell.label.text should equal(expectedString);
                    timeOffCell.contentView.subviews.count should equal(1);
                    timeOffCell.contentView.subviews.lastObject should_not be_instance_of([UIActivityIndicatorView class]);

                    InboxCell *overtimeCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@",6,RPLocalizedString(@"Employees on Overtime", @"supervisor-dashboard.%lu Employees on Overtime")];
                    overtimeCell.label.text should equal(expectedString);
                    overtimeCell.contentView.subviews.count should equal(1);
                    overtimeCell.contentView.subviews.lastObject should_not be_instance_of([UIActivityIndicatorView class]);

                    InboxCell *violationsCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                     expectedString = [NSString stringWithFormat:@"%d %@",9,RPLocalizedString(@"Violations", @"supervisor-dashboard.%lu Violations")];
                    violationsCell.label.text should equal(expectedString);
                    violationsCell.contentView.subviews.count should equal(1);
                    violationsCell.contentView.subviews.lastObject should_not be_instance_of([UIActivityIndicatorView class]);
                });

                it(@"should indicate selectable cells in the inbox", ^{
                    InboxCell *cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cell1.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    cell1.selectionStyle should equal(UITableViewCellSelectionStyleDefault);

                    InboxCell *cell2 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    cell2.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    cell2.selectionStyle should equal(UITableViewCellSelectionStyleDefault);

                    InboxCell *cell3 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    cell3.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    cell3.selectionStyle should equal(UITableViewCellSelectionStyleDefault);

                    InboxCell *cell4 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    cell4.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    cell4.selectionStyle should equal(UITableViewCellSelectionStyleDefault);

                    InboxCell *cell5 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                    cell5.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    cell5.selectionStyle should equal(UITableViewCellSelectionStyleDefault);
                });

                it(@"should ask the inboxCardContentStylist to set the height of the inbox card content correctly", ^{
                    CGFloat height = 256;
                    subject.delegate should have_received(@selector(supervisorInboxController:shouldUpdateHeight:)).with(subject, height);
                });

                describe(@"when the view is shown again", ^{
                    __block NSIndexPath *firstRowIndexPath;

                    beforeEach(^{
                        [(id<CedarDouble>)dashboardSummaryRepository reset_sent_messages];
                        KSPromise *unfulfilledPromise = nice_fake_for([KSPromise class]);
                        dashboardSummaryRepository stub_method(@selector(fetchMostRecentDashboardSummary)).and_return(unfulfilledPromise);
                        [subject updateWithDashboardSummaryPromise:unfulfilledPromise];
                    });

                    beforeEach(^{
                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    });

                    it(@"should show the spinner again", ^{
                        id <UITableViewDataSource> inboxTableDataSource = subject.tableView.dataSource;

                        subject.tableView.numberOfSections should equal(1);
                        [inboxTableDataSource tableView:subject.tableView numberOfRowsInSection:0] should equal(1);

                        UITableViewCell *loadingCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        loadingCell should be_instance_of([InboxSpinnerCell class]);
                    });
                });
            });

            context(@"with values for all of the rows without permissions", ^{
                beforeEach(^{
                    SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);

                    permissionsStorage stub_method(@selector(canApproveTimesheets)).again().and_return(NO);
                    permissionsStorage stub_method(@selector(canApproveExpenses)).again().and_return(NO);
                    permissionsStorage stub_method(@selector(canApproveTimeoffs)).again().and_return(NO);

                    dashboardSummary stub_method(@selector(timesheetsNeedingApprovalCount)).and_return((NSInteger) 4);
                    dashboardSummary stub_method(@selector(expensesNeedingApprovalCount)).and_return((NSInteger) 2);
                    dashboardSummary stub_method(@selector(timeOffRequestsNeedingApprovalCount)).and_return((NSInteger) 3);
                    dashboardSummary stub_method(@selector(usersWithOvertimeHoursCount)).and_return((NSInteger) 6);
                    dashboardSummary stub_method(@selector(usersWithViolationsCount)).and_return((NSInteger) 9);

                    [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
                });

                it(@"should update the inbox with the totals", ^{
                    NSString *expectedString;

                    subject.tableView.numberOfSections should equal(1);
                    [subject.tableView numberOfRowsInSection:0] should equal(2);

                    InboxCell *overtimeCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@",6,RPLocalizedString(@"Employees on Overtime", @"supervisor-dashboard.%lu Employees on Overtime")];
                    overtimeCell.label.text should equal(expectedString);
                    overtimeCell.contentView.subviews.count should equal(1);
                    overtimeCell.contentView.subviews.lastObject should_not be_instance_of([UIActivityIndicatorView class]);

                    InboxCell *violationsCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@",9,RPLocalizedString(@"Violations", @"supervisor-dashboard.%lu Violations")];
                    violationsCell.label.text should equal(expectedString);
                    violationsCell.contentView.subviews.count should equal(1);
                    violationsCell.contentView.subviews.lastObject should_not be_instance_of([UIActivityIndicatorView class]);
                });

                it(@"should indicate selectable cells in the inbox", ^{

                    InboxCell *cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cell1.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    cell1.selectionStyle should equal(UITableViewCellSelectionStyleDefault);

                    InboxCell *cell2 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    cell2.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    cell2.selectionStyle should equal(UITableViewCellSelectionStyleDefault);
                });

                it(@"should ask the inboxCardContentStylist to set the height of the inbox card content correctly", ^{
                    CGFloat height = 124;
                    subject.delegate should have_received(@selector(supervisorInboxController:shouldUpdateHeight:)).with(subject, height);
                });

                describe(@"when the view is shown again", ^{
                    __block NSIndexPath *firstRowIndexPath;

                    beforeEach(^{
                        [(id<CedarDouble>)dashboardSummaryRepository reset_sent_messages];
                        KSPromise *unfulfilledPromise = nice_fake_for([KSPromise class]);
                        dashboardSummaryRepository stub_method(@selector(fetchMostRecentDashboardSummary)).and_return(unfulfilledPromise);
                        [subject updateWithDashboardSummaryPromise:unfulfilledPromise];
                    });

                    beforeEach(^{
                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    });

                    it(@"should show the spinner again", ^{
                        id <UITableViewDataSource> inboxTableDataSource = subject.tableView.dataSource;

                        subject.tableView.numberOfSections should equal(1);
                        [inboxTableDataSource tableView:subject.tableView numberOfRowsInSection:0] should equal(1);
                        
                        UITableViewCell *loadingCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        loadingCell should be_instance_of([InboxSpinnerCell class]);
                    });
                });
            });

            context(@"Tapping on one of the cells", ^{
                describe(@"tapping on the 'timesheets' cell", ^{
                    beforeEach(^{
                        SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);
                        dashboardSummary stub_method(@selector(timesheetsNeedingApprovalCount)).and_return((NSInteger) 4);
                        [dashboardSummaryDeferred resolveWithValue:dashboardSummary];

                        [subject viewWillAppear:YES];
                    });

                    it(@"should push a timesheets approvals controller onto the navigation stack", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        [cell tap];

                        navigationController.topViewController should be_same_instance_as(approvalsPendingTimesheetViewController);
                    });

                    it(@"accidentally double tapping on the rows should not crash", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        [cell tap];
                        [cell tap];

                        navigationController.topViewController should be_same_instance_as(approvalsPendingTimesheetViewController);
                    });

                    it(@"should received event for GA Tracker", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        [cell tap];
                        tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"approvals", TrackerProduct);
                    });
                });

                describe(@"tapping on the 'expenses' cell", ^{
                    beforeEach(^{
                        SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);
                        dashboardSummary stub_method(@selector(expensesNeedingApprovalCount)).and_return((NSInteger) 4);
                        [dashboardSummaryDeferred resolveWithValue:dashboardSummary];

                        [subject viewWillAppear:YES];
                    });

                    it(@"should push an expenses approvals controller onto the navigation stack", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        [cell tap];

                        navigationController.topViewController should be_same_instance_as(approvalsPendingExpenseViewController);
                    });

                    it(@"should received event for GA Tracker", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        [cell tap];
                        tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"approvals", TrackerProduct);
                    });
                });

                describe(@"tapping on the 'time off' cell", ^{
                    beforeEach(^{
                        SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);

                        dashboardSummary stub_method(@selector(timeOffRequestsNeedingApprovalCount)).and_return((NSInteger) 4);
                        [dashboardSummaryDeferred resolveWithValue:dashboardSummary];

                        [subject viewWillAppear:YES];
                    });

                    it(@"should push an time off approvals controller onto the navigation stack", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        [cell tap];

                        navigationController.topViewController should be_same_instance_as(approvalsPendingTimeOffViewController);
                    });
                    it(@"should received event for GA Tracker", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        [cell tap];
                        tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"approvals", TrackerProduct);
                    });
                });

                describe(@"tapping on the 'Overtime' cell", ^{
                    beforeEach(^{
                        SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);
                        dashboardSummary stub_method(@selector(usersWithOvertimeHoursCount)).and_return((NSInteger) 4);
                        [dashboardSummaryDeferred resolveWithValue:dashboardSummary];

                        [subject viewWillAppear:YES];
                    });

                    it(@"should push an overtime status summary controller onto the navigation stack, passing in the overtime summary request promise", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        [cell tap];

                        overtimeSummaryControllerProvider should have_received(@selector(provideInstanceWithOvertimeSummaryPromise:)).with(dashboardSummaryDeferred.promise);
                        navigationController.topViewController should be_same_instance_as(overtimeSummaryController);
                    });
                    it(@"should not have received event for GA Tracker", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        [cell tap];
                        tracker should_not have_received(@selector(trackUIEvent:forTracker:)).with(@"approvals", TrackerProduct);
                    });
                });

                describe(@"tapping on the 'Violations' cell", ^{
                    __block NSArray *expectedEmployeesWithViolationsArray;
                    __block ViolationEmployee *violationEmployee;
                    __block NSArray *violationEmployeeViolations;

                    beforeEach(^{
                        violationEmployeeViolations = @[];
                        violationEmployee = [[ViolationEmployee alloc] initWithName:nil uri:nil violations:violationEmployeeViolations];
                        expectedEmployeesWithViolationsArray = @[violationEmployee];
                        SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);
                        dashboardSummary stub_method(@selector(employeesWithViolationsArray)).and_return(expectedEmployeesWithViolationsArray);
                        dashboardSummary stub_method(@selector(usersWithViolationsCount)).and_return((NSInteger) 4);
                        [dashboardSummaryDeferred resolveWithValue:dashboardSummary];

                        [subject viewWillAppear:YES];
                    });

                    it(@"should push an violations summary controller onto the navigation stack, passing in the supervisor dashboard summary promise", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        [cell tap];

                        navigationController.topViewController should be_same_instance_as(violationsSummaryController);
                    });

                    it(@"should only send along the employeesWithViolationsArray", ^{
                        NSInvocation *invocation = [[(id<CedarDouble>)violationsSummaryControllerProvider sent_messages] lastObject];

                        __autoreleasing KSPromise *promise;
                        [invocation getArgument:&promise atIndex:2];

                        AllViolationSections *violationSections = promise.value;

                        violationSections should be_instance_of([AllViolationSections class]);
                        ViolationSection *section = [violationSections.sections firstObject];
                        section.titleObject should be_same_instance_as(violationEmployee);
                        section.violations should be_same_instance_as(violationEmployeeViolations);

                        __autoreleasing id<ViolationsSummaryControllerDelegate> delegate;
                        [invocation getArgument:&delegate atIndex:3];
                        delegate should be_same_instance_as(subject);
                    });

                    it(@"should not have received event for GA Tracker", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        [cell tap];
                        tracker should_not have_received(@selector(trackUIEvent:forTracker:)).with(@"approvals", TrackerProduct);
                    });
                });
            });

            context(@"with a zero value for timesheets", ^{
                beforeEach(^{
                    SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);

                    dashboardSummary stub_method(@selector(timesheetsNeedingApprovalCount)).and_return((NSInteger) 0);
                    dashboardSummary stub_method(@selector(expensesNeedingApprovalCount)).and_return((NSInteger) 1);
                    dashboardSummary stub_method(@selector(timeOffRequestsNeedingApprovalCount)).and_return((NSInteger) 1);
                    dashboardSummary stub_method(@selector(usersWithOvertimeHoursCount)).and_return((NSInteger) 6);
                    dashboardSummary stub_method(@selector(usersWithViolationsCount)).and_return((NSInteger) 9);

                    [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
                });

                it(@"should update the inbox, omitting the timesheets row", ^{
                    NSString *expectedString;

                    subject.tableView.numberOfSections should equal(1);
                    [subject.tableView numberOfRowsInSection:0]should equal(4);

                    InboxCell *expensesCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@",1,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Expense for Approval", @"")]];
                    expensesCell.label.text should equal(expectedString);

                    InboxCell *timeOffCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 1,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Time Off Request for Approval", @"")]];
                    timeOffCell.label.text should equal(expectedString);

                    InboxCell *overtimeCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 6,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Employees on Overtime", @"")]];
                    overtimeCell.label.text should equal(expectedString);

                    InboxCell *violationsCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 9,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Violations", @"")]];
                    violationsCell.label.text should equal(expectedString);
                });
            });

            context(@"with a zero value for expenses", ^{
                beforeEach(^{
                    SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);

                    dashboardSummary stub_method(@selector(timesheetsNeedingApprovalCount)).and_return((NSInteger) 1);
                    dashboardSummary stub_method(@selector(expensesNeedingApprovalCount)).and_return((NSInteger) 0);
                    dashboardSummary stub_method(@selector(timeOffRequestsNeedingApprovalCount)).and_return((NSInteger) 3);
                    dashboardSummary stub_method(@selector(usersWithOvertimeHoursCount)).and_return((NSInteger) 6);
                    dashboardSummary stub_method(@selector(usersWithViolationsCount)).and_return((NSInteger) 9);

                    [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
                });

                it(@"should update the inbox, omitting the expenses row", ^{
                    NSString *expectedString;

                    subject.tableView.numberOfSections should equal(1);
                    [subject.tableView numberOfRowsInSection:0]should equal(4);

                    InboxCell *timesheetsCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 1,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Timesheet for Approval", @"")]];
                    timesheetsCell.label.text should equal(expectedString);

                    InboxCell *timeOffCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 3,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Time Off Requests for Approval", @"")]];
                    timeOffCell.label.text should equal(expectedString);

                    InboxCell *overtimeCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 6,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Employees on Overtime", @"")]];
                    overtimeCell.label.text should equal(expectedString);

                    InboxCell *violationsCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 9,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Violations", @"")]];
                    violationsCell.label.text should equal(expectedString);

                });
            });

            context(@"with a zero value for time off requests", ^{
                beforeEach(^{
                    SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);

                    dashboardSummary stub_method(@selector(timesheetsNeedingApprovalCount)).and_return((NSInteger) 1);
                    dashboardSummary stub_method(@selector(expensesNeedingApprovalCount)).and_return((NSInteger) 2);
                    dashboardSummary stub_method(@selector(timeOffRequestsNeedingApprovalCount)).and_return((NSInteger) 0);
                    dashboardSummary stub_method(@selector(usersWithOvertimeHoursCount)).and_return((NSInteger) 6);
                    dashboardSummary stub_method(@selector(usersWithViolationsCount)).and_return((NSInteger) 9);

                    [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
                });

                it(@"should update the inbox, omitting the time off requests row", ^{
                    NSString *expectedString;

                    subject.tableView.numberOfSections should equal(1);
                    [subject.tableView numberOfRowsInSection:0]should equal(4);

                    InboxCell *expensesCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 1,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Timesheet for Approval", @"")]];
                    expensesCell.label.text should equal(expectedString);

                    InboxCell *timeOffCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 2,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Expenses for Approval", @"")]];
                    timeOffCell.label.text should equal(expectedString);

                    InboxCell *overtimeCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 6,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Employees on Overtime", @"")]];
                    overtimeCell.label.text should equal(expectedString);

                    InboxCell *violationsCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 9,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Violations", @"")]];
                    violationsCell.label.text should equal(expectedString);
                });
            });

            context(@"with a zero value for overtime", ^{
                beforeEach(^{
                    SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);

                    dashboardSummary stub_method(@selector(timesheetsNeedingApprovalCount)).and_return((NSInteger) 1);
                    dashboardSummary stub_method(@selector(expensesNeedingApprovalCount)).and_return((NSInteger) 2);
                    dashboardSummary stub_method(@selector(timeOffRequestsNeedingApprovalCount)).and_return((NSInteger) 3);
                    dashboardSummary stub_method(@selector(usersWithViolationsCount)).and_return((NSInteger) 9);

                    [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
                });

                it(@"should update the inbox, omitting the overtime row", ^{
                    NSString *expectedString;

                    subject.tableView.numberOfSections should equal(1);
                    [subject.tableView numberOfRowsInSection:0]should equal(4);

                    InboxCell *timesheetsCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 1,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Timesheet for Approval", @"")]];
                    timesheetsCell.label.text should equal(expectedString);

                    InboxCell *expensesCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 2,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Expenses for Approval", @"")]];
                    expensesCell.label.text should equal(expectedString);

                    InboxCell *timeOffCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 3,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Time Off Requests for Approval", @"")]];
                    timeOffCell.label.text should equal(expectedString);

                    InboxCell *violationsCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 9,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Violations", @"")]];
                    violationsCell.label.text should equal(expectedString);
                });
            });

            context(@"with a zero value for violations", ^{
                beforeEach(^{
                    SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);

                    dashboardSummary stub_method(@selector(timesheetsNeedingApprovalCount)).and_return((NSInteger) 1);
                    dashboardSummary stub_method(@selector(expensesNeedingApprovalCount)).and_return((NSInteger) 2);
                    dashboardSummary stub_method(@selector(timeOffRequestsNeedingApprovalCount)).and_return((NSInteger) 3);
                    dashboardSummary stub_method(@selector(usersWithOvertimeHoursCount)).and_return((NSInteger) 6);

                    [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
                });

                it(@"should update the inbox, omitting the Violations row", ^{
                    NSString *expectedString;

                    subject.tableView.numberOfSections should equal(1);
                    [subject.tableView numberOfRowsInSection:0]should equal(4);

                    InboxCell *timesheetsCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 1,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Timesheet for Approval", @"")]];
                    timesheetsCell.label.text should equal(expectedString);

                    InboxCell *expensesCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 2,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Expenses for Approval", @"")]];
                    expensesCell.label.text should equal(expectedString);

                    InboxCell *timeOffCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 3,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Time Off Requests for Approval", @"")]];
                    timeOffCell.label.text should equal(expectedString);

                    InboxCell *overtimeCell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    expectedString = [NSString stringWithFormat:@"%d %@", 6,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Employees on Overtime", @"")]];
                    overtimeCell.label.text should equal(expectedString);
                });
            });

            context(@"with a zero value for everything", ^{
                beforeEach(^{
                    theme stub_method(@selector(cardContainerHeaderFont)).and_return([UIFont italicSystemFontOfSize:15.0f]);

                    SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);
                    [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
                });

                it(@"should update the inbox with the totals", ^{
                    subject.tableView.numberOfSections should equal(1);
                    [subject.tableView numberOfRowsInSection:0] should equal(1);

                    InboxCell *cell = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    NSString *noPendingitemsStr = [NSString stringWithFormat:@"%@",RPLocalizedString(@"No pending items", @"")];
                    cell.label.text should equal(noPendingitemsStr);
                    cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                    cell.accessoryType should equal(UITableViewCellAccessoryNone);
                    cell.label.font should equal([UIFont italicSystemFontOfSize:15.0f]);
                });

                it(@"should inform its delegate with its height", ^{
                    CGFloat height = 80;
                    subject.delegate should have_received(@selector(supervisorInboxController:shouldUpdateHeight:)).with(subject, height);
                });

                it(@"should do nothing when the cell is tapped", ^{
                    UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [cell tap];

                    navigationController.topViewController should be_same_instance_as(subject);
                });
            });
        });
    });

    describe(@"configuring the time off approvals view controller", ^{
        __block KSDeferred *dashboardSummaryDeferred;

        beforeEach(^{
            dashboardSummaryDeferred = [KSDeferred defer];
            [subject updateWithDashboardSummaryPromise:dashboardSummaryDeferred.promise];
        });

        context(@"when there are time off requests to be approved", ^{
            __block SupervisorDashboardSummary *dashboardSummary;
            beforeEach(^{
                dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);
                dashboardSummary stub_method(@selector(timeOffRequestsNeedingApprovalCount)).and_return((NSInteger) 3);
                [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
            });

            it(@"should set up the approvals time off view controller to be an observer of the pending approvals notification", ^{
                [notificationCenter postNotificationName:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];

                approvalsPendingTimeOffViewController should have_received(@selector(handlePendingApprovalsDataReceivedAction));
            });

            it(@"should tell the time off approvals repositor to fetch approvals and post a notification", ^{
                approvalsRepository should have_received(@selector(fetchTimeOffApprovalsAndPostNotification));
            });

            it(@"should fetchGetMyNotificationSummary", ^{
                loginService should have_received(@selector(fetchGetMyNotificationSummary));
            });
        });
    });

    describe(@"configuring the timesheet approvals view controller", ^{
        __block KSDeferred *dashboardSummaryDeferred;

        beforeEach(^{
            dashboardSummaryDeferred = [KSDeferred defer];
            [subject updateWithDashboardSummaryPromise:dashboardSummaryDeferred.promise];
        });

        context(@"when there are time off requests to be approved", ^{
            __block SupervisorDashboardSummary *dashboardSummary;
            beforeEach(^{
                dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);
                dashboardSummary stub_method(@selector(timesheetsNeedingApprovalCount)).and_return((NSInteger) 3);

                [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
            });

            it(@"should set up the approvals timesheet view controller to be an observer of the pending approvals notification", ^{
                [notificationCenter postNotificationName:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];

                approvalsPendingTimesheetViewController should have_received(@selector(handlePendingApprovalsDataReceivedAction));
            });

            it(@"should tell the time off approvals repositor to fetch approvals and post a notification", ^{
                approvalsRepository should have_received(@selector(fetchTimesheetApprovalsAndPostNotification));
            });

            it(@"should fetchGetMyNotificationSummary", ^{
                loginService should have_received(@selector(fetchGetMyNotificationSummary));
            });
        });
    });

    describe(@"configuring the expense approvals view controller", ^{
        __block KSDeferred *dashboardSummaryDeferred;

        beforeEach(^{
            dashboardSummaryDeferred = [KSDeferred defer];
            [subject updateWithDashboardSummaryPromise:dashboardSummaryDeferred.promise];
        });

        context(@"when there are time off requests to be approved", ^{
            __block SupervisorDashboardSummary *dashboardSummary;
            beforeEach(^{
                dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);
                dashboardSummary stub_method(@selector(expensesNeedingApprovalCount)).and_return((NSInteger) 3);
                [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
            });

            it(@"should set up the expenses time off view controller to be an observer of the pending approvals notification", ^{
                [notificationCenter postNotificationName:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];

                approvalsPendingExpenseViewController should have_received(@selector(handlePendingApprovalsDataReceivedAction));
            });

            it(@"should tell the time off approvals repositor to fetch approvals and post a notification", ^{
                approvalsRepository should have_received(@selector(fetchExpenseApprovalsAndPostNotification));
            });

            it(@"should fetchGetMyNotificationSummary", ^{
                loginService should have_received(@selector(fetchGetMyNotificationSummary));
            });
        });
    });
});

SPEC_END
