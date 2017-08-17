#import "SupervisorDashboardController.h"
#import "SupervisorDashboardSummaryRepository.h"
#import <KSDeferred/KSPromise.h>
#import <Blindside/BSInjector.h>
#import <Blindside/Blindside.h>
#import "SupervisorDashboardSummary.h"
#import "DateProvider.h"
#import "Theme.h"
#import "OvertimeSummaryControllerProvider.h"
#import "TimesheetButtonControllerPresenter.h"
#import "ChildControllerHelper.h"
#import "SupervisorTeamStatusController.h"
#import "SupervisorTrendChartController.h"
#import "SupervisorTimesheetDetailsSeriesController.h"
#import "PreviousApprovalsButtonViewController.h"
#import "ApprovalsCountViewController.h"
#import "UserPermissionsStorage.h"
#import "ErrorBannerViewParentPresenterHelper.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "ApprovalsPendingTimeOffViewController.h"
#import "ApprovalsPendingTimesheetViewController.h"


@interface SupervisorDashboardController ()

@property (nonatomic) SupervisorDashboardSummaryRepository *supervisorDashboardSummaryRepository;
@property (nonatomic) TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
@property (nonatomic) OvertimeSummaryControllerProvider *overtimeSummaryControllerProvider;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) id<Theme> theme;

@property (weak, nonatomic) id<BSInjector> injector;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inboxCardContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *teamStatusContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trendChartContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTeamTimesheetContainerHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView       *previousApprovalsButtonContainerView;
@property (weak, nonatomic) IBOutlet UIView       *timesheetButtonContainerView;
@property (weak, nonatomic) IBOutlet UIView       *teamStatusContainerView;
@property (weak, nonatomic) IBOutlet UIView       *trendChartContainerView;
@property (weak, nonatomic) IBOutlet UIView       *inboxContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *subViewsContainerScrollview;


@property (nonatomic) ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;
@property (nonatomic) SupervisorTeamStatusController       *supervisorTeamStatusController;
@property (nonatomic) SupervisorTrendChartController       *supervisorTrendChartController;
@property (nonatomic) SupervisorInboxController            *supervisorInboxController;
@property (nonatomic) UserPermissionsStorage               *userPermissionsStorage;


@end


@implementation SupervisorDashboardController

- (instancetype)initWithSupervisorDashboardSummaryRepository:(SupervisorDashboardSummaryRepository *)supervisorDashboardSummaryRepository
                        errorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                          timesheetButtonControllerPresenter:(TimesheetButtonControllerPresenter *)timesheetButtonControllerPresenter
                           overtimeSummaryControllerProvider:(OvertimeSummaryControllerProvider *)overtimeSummaryControllerProvider
                                       childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                      userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                               dateFormatter:(NSDateFormatter *)dateFormatter
                                                dateProvider:(DateProvider *)dateProvider
                                                       theme:(id<Theme>)theme {
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.errorBannerViewParentPresenterHelper = errorBannerViewParentPresenterHelper;
        self.supervisorDashboardSummaryRepository = supervisorDashboardSummaryRepository;
        self.timesheetButtonControllerPresenter = timesheetButtonControllerPresenter;
        self.overtimeSummaryControllerProvider = overtimeSummaryControllerProvider;
        self.childControllerHelper = childControllerHelper;
        self.userPermissionsStorage = userPermissionsStorage;
        self.dateFormatter = dateFormatter;
        self.dateProvider = dateProvider;
        self.theme = theme;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [self.theme supervisorDashboardBackgroundColor];

    self.supervisorInboxController = [self.injector getInstance:[SupervisorInboxController class]];
    self.supervisorInboxController.delegate = self;
    [self.childControllerHelper addChildController:self.supervisorInboxController
                                toParentController:self
                                   inContainerView:self.inboxContainerView];


    if ([self.userPermissionsStorage canViewTeamPunch])
    {
        self.supervisorTeamStatusController = [self.injector getInstance:[SupervisorTeamStatusController class]];
        [self.childControllerHelper addChildController:self.supervisorTeamStatusController
                                    toParentController:self
                                       inContainerView:self.teamStatusContainerView];

        self.supervisorTrendChartController = [self.injector getInstance:[SupervisorTrendChartController class]];
        [self.childControllerHelper addChildController:self.supervisorTrendChartController
                                    toParentController:self
                                       inContainerView:self.trendChartContainerView];
    }

    if([self.userPermissionsStorage canViewTeamTimesheet])
    {
        [self.timesheetButtonControllerPresenter presentTimesheetButtonControllerInContainer:self.timesheetButtonContainerView
                                                                      onParentController:self
                                                                                delegate:self
                                                                                   title:RPLocalizedString(@"View Team Timesheets", nil)];
    }
    else
    {
        self.viewTeamTimesheetContainerHeightConstraint.constant = 0.0;
    }
    
    [self.timesheetButtonControllerPresenter presentPreviousApprovalsButtonControllerInContainer:self.previousApprovalsButtonContainerView
                                                                              onParentController:self
                                                                                        delegate:self];


    self.teamStatusContainerHeightConstraint.constant = 0.0;
    self.trendChartContainerHeightConstraint.constant = 0.0;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.widthConstraint.constant = CGRectGetWidth(self.view.bounds);

    NSDate *currentDate = [self.dateProvider date];
    NSString *formattedDate = [self.dateFormatter stringFromDate:currentDate];
    self.navigationItem.title = [NSString stringWithFormat:RPLocalizedString(@"Dashboard at %@", @"Dashboard at %@"), formattedDate];

    KSPromise *dashboardSummaryPromise = [self.supervisorDashboardSummaryRepository fetchMostRecentDashboardSummary];

    [self.supervisorInboxController updateWithDashboardSummaryPromise:dashboardSummaryPromise];

    [dashboardSummaryPromise then:^id(SupervisorDashboardSummary *dashboardSummary) {
        NSUInteger totalUsers = dashboardSummary.clockedInUsersCount + dashboardSummary.notInUsersCount + dashboardSummary.onBreakUsersCount;
        BOOL showTrendChartAndTeamStatusWidget = (totalUsers == 0 || ![self.userPermissionsStorage canViewTeamPunch]);
        if(showTrendChartAndTeamStatusWidget)
        {
            [UIView animateWithDuration:0.4 animations:^{
                self.teamStatusContainerHeightConstraint.constant = 0;
                self.trendChartContainerHeightConstraint.constant = 0;
                [self.view layoutIfNeeded];
            }];

        }
        else
        {
            [UIView animateWithDuration:0.4 animations:^{
                self.teamStatusContainerHeightConstraint.constant = 90.0;
                self.trendChartContainerHeightConstraint.constant = 260.0;
                [self.view layoutIfNeeded];

            }];

        }
        [self.supervisorTeamStatusController updateWithDashboardSummary:dashboardSummary];
        return nil;
    } error:nil];
    [self.errorBannerViewParentPresenterHelper setScrollViewInsetWithErrorBannerPresentation:self.subViewsContainerScrollview];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

#pragma mark - <TimesheetButtonControllerDelegate>

- (void)timesheetButtonControllerWillNavigateToTimesheetDetailScreen:(TimesheetButtonController *)timesheetButtonController
{
    SupervisorTimesheetDetailsSeriesController *supervisorTimesheetDetailsSeriesController = [self.injector getInstance:[SupervisorTimesheetDetailsSeriesController class]];
    [self.navigationController pushViewController:supervisorTimesheetDetailsSeriesController animated:YES];
}

- (void) timesheetButtonControllerWillNavigateToWidgetTimesheetDetailScreen:(TimesheetButtonController *) timesheetButtonController
{
    SupervisorTimesheetDetailsSeriesController *supervisorTimesheetDetailsSeriesController = [self.injector getInstance:[SupervisorTimesheetDetailsSeriesController class]];
    [self.navigationController pushViewController:supervisorTimesheetDetailsSeriesController animated:YES];
}

- (void)approvalsButtonControllerWillNavigateToPreviousApprovalsScreen:(PreviousApprovalsButtonViewController *) previousApprovalsButtonViewController
{
    ApprovalsCountViewController *approvalsCountViewController = [self.injector getInstance:[ApprovalsCountViewController class]];
    [self.navigationController pushViewController:approvalsCountViewController animated:YES];
}


#pragma mark - <SupervisorInboxControllerDelegate>

- (void)supervisorInboxController:(SupervisorInboxController *)supervisorInboxController shouldUpdateHeight:(CGFloat)height
{
    self.inboxCardContainerHeightConstraint.constant = height;
}


-(void)selectApprovalsForModule:(NSString *)module{
    
    if ([module isEqualToString:DEEPLINKING_TIMESHEETS_APPROVALS]){
        ApprovalsPendingTimesheetViewController *approvalsPendingTimesheetViewController = [self.injector getInstance:[ApprovalsPendingTimesheetViewController class]];
        approvalsPendingTimesheetViewController.isFromDeepLink = YES;
        [self.navigationController pushViewController:approvalsPendingTimesheetViewController animated:YES];
    }else if ([module isEqualToString:DEEPLINKING_TIMEOFFS_APPROVALS]){
        ApprovalsPendingTimeOffViewController *approvalsPendingTimeOffViewController = [self.injector getInstance:[ApprovalsPendingTimeOffViewController class]];
        approvalsPendingTimeOffViewController.isFromDeepLink = YES;
        [self.navigationController pushViewController:approvalsPendingTimeOffViewController animated:YES];
    }else if ([module isEqualToString:DEEPLINKING_EXPENSES_APPROVALS]){
        ApprovalsPendingExpenseViewController *approvalsPendingExpenseViewController = [self.injector getInstance:[ApprovalsPendingExpenseViewController class]];
        approvalsPendingExpenseViewController.isFromDeepLink = YES;
        [self.navigationController pushViewController:approvalsPendingExpenseViewController animated:YES];
    }
}

@end
