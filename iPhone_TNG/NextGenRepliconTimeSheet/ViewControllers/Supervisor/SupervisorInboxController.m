#import "SupervisorInboxController.h"
#import <KSDeferred/KSPromise.h>
#import "SupervisorDashboardSummary.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "ApprovalsPendingTimeOffViewController.h"
#import "InboxRowPresenter.h"
#import "ApprovalsRepository.h"
#import "OvertimeSummaryController.h"
#import "ViolationsSummaryControllerProvider.h"
#import "OvertimeSummaryControllerProvider.h"
#import "AllViolationSections.h"
#import "ViolationSection.h"
#import "Theme.h"
#import <Blindside/Blindside.h>
#import "SupervisorDashboardSummaryRepository.h"
#import "ViolationEmployee.h"
#import "InboxSpinnerCell.h"
#import "InboxCell.h"
#import "UserPermissionsStorage.h"
#import "FrameworkImport.h"
#import "LoginService.h"

@interface SupervisorInboxController ()

@property (nonatomic) ViolationsSummaryControllerProvider *violationsSummaryControllerProvider;
@property (nonatomic) OvertimeSummaryControllerProvider *overtimeSummaryControllerProvider;
@property (nonatomic) SupervisorDashboardSummaryRepository *dashboardSummaryRepository;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic) ApprovalsRepository *approvalsRepository;
@property (nonatomic) NSNotificationCenter *notificationCenter;

@property (nonatomic) id<Theme> theme;

@property (nonatomic, weak) id<BSInjector> injector;

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) KSPromise *dashboardSummaryPromise;
@property (nonatomic, copy) NSArray *contentRows;
@property (nonatomic) GATracker *tracker;
@property (nonatomic) LoginService *loginService;
@end


@implementation SupervisorInboxController

#pragma mark - UIViewController

- (instancetype)initWithViolationsSummaryControllerProvider:(ViolationsSummaryControllerProvider *)violationsSummaryControllerProvider
                          overtimeSummaryControllerProvider:(OvertimeSummaryControllerProvider *)overtimeSummaryControllerProvider
                                 dashboardSummaryRepository:(SupervisorDashboardSummaryRepository *)dashboardSummaryRepository
                                     userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                        approvalsRepository:(ApprovalsRepository *)approvalsRepository
                                         notificationCenter:(NSNotificationCenter *)notificationCenter
                                                theme:(id<Theme>)theme
                                                    tracker:(GATracker *)tracker
                                               loginService:(LoginService *)loginService
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.violationsSummaryControllerProvider = violationsSummaryControllerProvider;
        self.overtimeSummaryControllerProvider = overtimeSummaryControllerProvider;
        self.dashboardSummaryRepository = dashboardSummaryRepository;
        self.userPermissionsStorage = userPermissionsStorage;
        self.approvalsRepository = approvalsRepository;
        self.notificationCenter = notificationCenter;
        self.theme = theme;
        self.tracker = tracker;
        self.loginService = loginService;
    }
    return self;
}

- (void)updateWithDashboardSummaryPromise:(KSPromise *)dashboardSummaryPromise
{
    self.dashboardSummaryPromise = dashboardSummaryPromise;

    [self.dashboardSummaryPromise then:^id(SupervisorDashboardSummary *dashboardSummary) {
        NSMutableArray *contentRows = [NSMutableArray array];

        if (dashboardSummary.timesheetsNeedingApprovalCount && [self.userPermissionsStorage canApproveTimesheets])
        {

            NSString *text=@"";
            if(dashboardSummary.timesheetsNeedingApprovalCount==1)
            {
                text = [NSString stringWithFormat:@"%lu %@",(long)dashboardSummary.timesheetsNeedingApprovalCount,[NSString stringWithFormat:@"%@", RPLocalizedString(@"Timesheet for Approval",@"")]];
            }
            else
            {
                text = [NSString stringWithFormat:@"%lu %@",(long)dashboardSummary.timesheetsNeedingApprovalCount,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Timesheets for Approval",@"")]];
            }


            ApprovalsPendingTimesheetViewController *approvalsPendingTimesheetViewController = [self.injector getInstance:[ApprovalsPendingTimesheetViewController class]];
            [self.notificationCenter addObserver:approvalsPendingTimesheetViewController selector:@selector(handlePendingApprovalsDataReceivedAction) name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];

            [self.approvalsRepository fetchTimesheetApprovalsAndPostNotification];
            [self.loginService fetchGetMyNotificationSummary];

            InboxRowPresenter *timesheetsRowPresenter = [[InboxRowPresenter alloc] initWithText:text controller:approvalsPendingTimesheetViewController];

            [contentRows addObject:timesheetsRowPresenter];
        }

        if (dashboardSummary.expensesNeedingApprovalCount && [self.userPermissionsStorage canApproveExpenses])
        {
            NSString *text=@"";
            if(dashboardSummary.expensesNeedingApprovalCount==1)
            {
                text = [NSString stringWithFormat:@"%lu %@",(long)dashboardSummary.expensesNeedingApprovalCount,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Expense for Approval",@"")]];
            }
            else
            {
                text = [NSString stringWithFormat:@"%lu %@",(long)dashboardSummary.expensesNeedingApprovalCount,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Expenses for Approval",@"")]];
            }


            ApprovalsPendingExpenseViewController *approvalsPendingExpenseViewController = [self.injector getInstance:[ApprovalsPendingExpenseViewController class]];

            [self.notificationCenter addObserver:approvalsPendingExpenseViewController selector:@selector(handlePendingApprovalsDataReceivedAction) name:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];

            [self.approvalsRepository fetchExpenseApprovalsAndPostNotification];
            [self.loginService fetchGetMyNotificationSummary];

            InboxRowPresenter *expensesRowPresenter = [[InboxRowPresenter alloc] initWithText:text controller:approvalsPendingExpenseViewController];
            [contentRows addObject:expensesRowPresenter];
        }

        if (dashboardSummary.timeOffRequestsNeedingApprovalCount && [self.userPermissionsStorage canApproveTimeoffs])
        {
            NSString *text=@"";
            if(dashboardSummary.timeOffRequestsNeedingApprovalCount==1)
            {
                text = [NSString stringWithFormat:@"%lu %@", (long)dashboardSummary.timeOffRequestsNeedingApprovalCount,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Time Off Request for Approval",@"")]];
            }
            else
            {
                text = [NSString stringWithFormat:@"%lu %@", (long)dashboardSummary.timeOffRequestsNeedingApprovalCount,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Time Off Requests for Approval",@"")]];
            }


            ApprovalsPendingTimeOffViewController *approvalsPendingTimeOffViewController = [self.injector getInstance:[ApprovalsPendingTimeOffViewController class]];
            [self.notificationCenter addObserver:approvalsPendingTimeOffViewController selector:@selector(handlePendingApprovalsDataReceivedAction) name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];

            [self.approvalsRepository fetchTimeOffApprovalsAndPostNotification];
            [self.loginService fetchGetMyNotificationSummary];

            InboxRowPresenter *timeOffRowPresenter = [[InboxRowPresenter alloc] initWithText:text controller:approvalsPendingTimeOffViewController];
            [contentRows addObject:timeOffRowPresenter];
        }

        if (dashboardSummary.usersWithOvertimeHoursCount)
        {
            NSString *text=@"";
            if(dashboardSummary.usersWithOvertimeHoursCount==1)
            {
                text = [NSString stringWithFormat:@"%lu %@", (long)dashboardSummary.usersWithOvertimeHoursCount,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Employee on Overtime",@"")]];
            }
            else
            {
                text = [NSString stringWithFormat:@"%lu %@", (long)dashboardSummary.usersWithOvertimeHoursCount,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Employees on Overtime",@"")]];
            }


            OvertimeSummaryController *overtimeSummaryController = [self.overtimeSummaryControllerProvider provideInstanceWithOvertimeSummaryPromise:self.dashboardSummaryPromise];
            InboxRowPresenter *overtimeRowPresenter = [[InboxRowPresenter alloc] initWithText:text controller:overtimeSummaryController];

            [contentRows addObject:overtimeRowPresenter];
        }

        if (dashboardSummary.usersWithViolationsCount)
        {
            NSString *text=@"";
            if(dashboardSummary.usersWithViolationsCount==1)
            {
                text = [NSString stringWithFormat:@"%lu %@", (long)dashboardSummary.usersWithViolationsCount,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Violation",@"")]];
            }
            else
            {
                text = [NSString stringWithFormat:@"%lu %@", (long)dashboardSummary.usersWithViolationsCount,[NSString stringWithFormat:@"%@",RPLocalizedString(@"Violations",@"")]];
            }


            KSPromise *violationSectionsPromise = [dashboardSummaryPromise then:^id(SupervisorDashboardSummary *supervisorDashboardSummary) {
                NSArray *violationEmployees = supervisorDashboardSummary.employeesWithViolationsArray;
                return [self violationSectionsWithEmployeesWithViolationsArray:violationEmployees];
            } error:nil];

            ViolationsSummaryController *violationsSummaryController = [self.violationsSummaryControllerProvider provideInstanceWithViolationSectionsPromise:violationSectionsPromise
                                                                                                                                                    delegate:self];

            InboxRowPresenter *violationsRowPresenter = [[InboxRowPresenter alloc] initWithText:text controller:violationsSummaryController];
            [contentRows addObject:violationsRowPresenter];
        }

        self.contentRows = contentRows;

        [self.tableView reloadData];
        [self updateHeight];
        return nil;
    } error:nil];

    [self.tableView reloadData];
    [self updateHeight];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [self.theme cardContainerBackgroundColor];

    self.headerLabel.text = RPLocalizedString(@"Inbox", @"Inbox");
    self.headerLabel.font = [self.theme cardContainerHeaderFont];
    self.headerLabel.textColor = [self.theme cardContainerHeaderColor];

    self.separatorView.backgroundColor = [self.theme cardContainerSeparatorColor];

    self.view.layer.borderWidth = [self.theme cardContainerBorderWidth];
    self.view.layer.borderColor = [self.theme cardContainerBorderColor];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 44.0f;
    [self.tableView setAccessibilityLabel:@"supervisor_inbox_table_view"];

    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"InboxCell"];

    NSString *inboxCellIdentifier = NSStringFromClass([InboxCell class]);
    NSString *spinnerCellIdentifier = NSStringFromClass([InboxSpinnerCell class]);

    UINib *spinnerCellNib = [UINib nibWithNibName:spinnerCellIdentifier bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:spinnerCellNib forCellReuseIdentifier:spinnerCellIdentifier];

    UINib *inboxCellNib = [UINib nibWithNibName:inboxCellIdentifier bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:inboxCellNib forCellReuseIdentifier:inboxCellIdentifier];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dashboardSummaryPromise.fulfilled && self.contentRows.count > 0)
    {
        return self.contentRows.count;
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dashboardSummaryPromise.fulfilled)
    {
        InboxCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InboxCell class]) forIndexPath:indexPath];
        cell.label.font = [self.theme cardContainerHeaderFont];

        if (self.contentRows.count > 0)
        {
            InboxRowPresenter *presenter = self.contentRows[indexPath.row];

            cell.label.text = presenter.text;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            cell.label.text = RPLocalizedString(@"No pending items", @"No pending items");
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        return cell;
    }
    else
    {
        return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InboxSpinnerCell class]) forIndexPath:indexPath];
    }
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{


    if (self.dashboardSummaryPromise.fulfilled && self.contentRows.count > 0)
    {
        InboxRowPresenter *rowPresenter = self.contentRows[indexPath.row];

        if (rowPresenter.controller)
        {
            if (self.navigationController.topViewController == rowPresenter.controller)
            {
                return;
            }

            [self.navigationController pushViewController:rowPresenter.controller animated:YES];
            if ([rowPresenter.controller isKindOfClass:[ApprovalsPendingTimesheetViewController class]] || [rowPresenter.controller isKindOfClass:[ApprovalsPendingExpenseViewController class]] || [rowPresenter.controller isKindOfClass:[ApprovalsPendingTimeOffViewController class]])
            {
                [self.tracker trackScreenView:@"approvals" forTracker:TrackerProduct];
            }

        }
    }
}

#pragma mark - <ViolationsSummaryControllerDelegate>

- (KSPromise *)violationsSummaryControllerDidRequestViolationSectionsPromise:(ViolationsSummaryController *)violationsSummaryController
{
    KSPromise *dashboardSummaryPromise = [self.dashboardSummaryRepository fetchMostRecentDashboardSummary];

    return [dashboardSummaryPromise then:^id(SupervisorDashboardSummary *dashboardSummary) {
        NSArray *violationEmployees = dashboardSummary.employeesWithViolationsArray;
        return [self violationSectionsWithEmployeesWithViolationsArray:violationEmployees];
    } error:nil];
}

#pragma mark - Private

- (AllViolationSections *)violationSectionsWithEmployeesWithViolationsArray:(NSArray *)employeesWithViolationsArray
{
    NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:employeesWithViolationsArray.count];
    for (ViolationEmployee *employee in employeesWithViolationsArray) {
        ViolationSection *violationSection = [[ViolationSection alloc] initWithTitleObject:employee
                                                                                violations:employee.violations
                                                                                      type:ViolationSectionTypeEmployee];
        [sections addObject:violationSection];
    }

    return [[AllViolationSections alloc] initWithTotalViolationsCount:0 sections:sections];
}

- (void)updateHeight
{
    [self.view layoutIfNeeded];

    CGFloat totalHeight = CGRectGetMinY(self.tableView.frame) + self.tableView.contentSize.height;
    [self.delegate supervisorInboxController:self shouldUpdateHeight:totalHeight];
}

@end
