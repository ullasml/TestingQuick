#import <MacTypes.h>
#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "UICollectionViewCell+Spec.h"
#import "SupervisorDashboardController.h"
#import "SupervisorDashboardSummaryRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "SupervisorDashboardSummary.h"
#import "Constants.h"
#import "DateProvider.h"
#import "Theme.h"
#import "SupervisorDashboardTeamStatusSummaryCell.h"
#import "TeamStatusSummaryCardContentStylist.h"
#import "TeamStatusSummaryRepository.h"
#import "TeamStatusSummaryControllerProvider.h"
#import "TeamStatusSummaryController.h"
#import "TimesheetButtonControllerPresenter.h"
#import "OvertimeSummaryControllerProvider.h"
#import "OvertimeSummaryController.h"
#import "ViolationsSummaryControllerProvider.h"
#import "ViolationsSummaryController.h"
#import "ApprovalsService.h"
#import "RepliconServiceProvider.h"
#import "ApprovalsRepository.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "InboxSpinnerCell.h"
#import "FakeApprovalsPendingController.h"
#import "ApprovalsPendingTimeOffViewController.h"
#import "AllViolationSections.h"
#import "ViolationSection.h"
#import "ViolationEmployee.h"
#import "Violation.h"
#import "SupervisorTimesheetDetailsSeriesController.h"
#import "InjectorKeys.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import "ChildControllerHelper.h"
#import "SupervisorTeamStatusController.h"
#import "SupervisorTrendChartController.h"
#import "ApprovalsCountViewController.h"
#import "UserPermissionsStorage.h"
#import "ErrorBannerViewParentPresenterHelper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(SupervisorDashboardControllerSpec)

describe(@"SupervisorDashboardController", ^{
    __block SupervisorDashboardController *subject;
    __block id<BSBinder, BSInjector> injector;
    __block WidgetTimesheetDetailsSeriesController *newTimesheetDetailsSeriesController;
    __block ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;
    __block TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
    __block SupervisorDashboardSummaryRepository *dashboardSummaryRepository;
    __block SupervisorTeamStatusController *supervisorTeamStatusController;
    __block SupervisorTrendChartController *supervisorTrendChartController;
    __block SupervisorInboxController *supervisorInboxController;
    __block ChildControllerHelper *childControllerHelper;
    __block UINavigationController *navigationController;
    __block KSDeferred *dashboardSummaryDeferred;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block NSDateFormatter *dateFormatter;
    __block DateProvider *dateProvider;
    __block NSDate *providedDate;
    __block id<Theme> theme;

    beforeEach(^{
        injector = [InjectorProvider injector];

        dashboardSummaryDeferred = [[KSDeferred alloc] init];
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];
        userPermissionsStorage stub_method(@selector(canViewTeamPunch)).and_return(YES);

        dashboardSummaryRepository = nice_fake_for([SupervisorDashboardSummaryRepository class]);
        dashboardSummaryRepository stub_method(@selector(fetchMostRecentDashboardSummary)).and_return(dashboardSummaryDeferred.promise);
        [injector bind:[SupervisorDashboardSummaryRepository class] toInstance:dashboardSummaryRepository];

        dateProvider = nice_fake_for([DateProvider class]);
        [injector bind:[DateProvider class] toInstance:dateProvider];

        providedDate = [NSDate dateWithTimeIntervalSince1970:1429288750];
        dateProvider stub_method(@selector(date)).and_return(providedDate);

        dateFormatter = nice_fake_for([NSDateFormatter class]);
        [injector bind:InjectorKeyHoursAndMinutesInLocalTimeZoneDateFormatter toInstance:dateFormatter];
        dateFormatter stub_method(@selector(stringFromDate:)).with(providedDate).and_return(@"9:39 AM");

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        timesheetButtonControllerPresenter = nice_fake_for([TimesheetButtonControllerPresenter class]);
        [injector bind:[TimesheetButtonControllerPresenter class] toInstance:timesheetButtonControllerPresenter];

        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        
        errorBannerViewParentPresenterHelper = nice_fake_for([ErrorBannerViewParentPresenterHelper class]);
        [injector bind:[ErrorBannerViewParentPresenterHelper class] toInstance:errorBannerViewParentPresenterHelper];
        
        newTimesheetDetailsSeriesController = (id)[[UIViewController alloc] init];
        [injector bind:[WidgetTimesheetDetailsSeriesController class] toInstance:newTimesheetDetailsSeriesController];

        supervisorInboxController = [[SupervisorInboxController alloc] initWithViolationsSummaryControllerProvider:nil
                                                                                 overtimeSummaryControllerProvider:nil
                                                                                        dashboardSummaryRepository:nil
                                                                                            userPermissionsStorage:NULL
                                                                                               approvalsRepository:nil
                                                                                                notificationCenter:nil
                                                                                                             theme:nil
                                                                                                           tracker:nil
                                                                                                      loginService:nil];
        spy_on(supervisorInboxController);
        [injector bind:[SupervisorInboxController class] toInstance:supervisorInboxController];

        supervisorTeamStatusController = [[SupervisorTeamStatusController alloc] initWithTeamStatusSummaryCardContentStylist:nil
                                                                                         teamStatusSummaryControllerProvider:nil
                                                                                                 teamStatusSummaryRepository:nil
                                                                                                                       theme:nil];
        spy_on(supervisorTeamStatusController);
        [injector bind:[SupervisorTeamStatusController class] toInstance:supervisorTeamStatusController];

        supervisorTrendChartController = [[SupervisorTrendChartController alloc] initWithEmployeeClockInTrendSummaryRepository:nil
                                                                                                 supervisorTrendChartPresenter:nil
                                                                                                                         theme:nil];
        [injector bind:[SupervisorTrendChartController class] toInstance:supervisorTrendChartController];

        subject = [injector getInstance:[SupervisorDashboardController class]];

        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
    });

    describe(@"when the view appears", ^{
        beforeEach(^{
            [subject viewWillAppear:NO];
        });

        it(@"should set the navigation controller's title to the correct string", ^{
            subject.navigationItem.title should equal([NSString stringWithFormat:RPLocalizedString(@"Dashboard at %@", @"Dashboard at %@"), @"9:39 AM"]);
        });

        it(@"should ask the dashboard summary repository for the most recent summary", ^{
            dashboardSummaryRepository should have_received(@selector(fetchMostRecentDashboardSummary));
        });
    });

    describe(@"the supervisor inbox", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });

        it(@"should add a supervisorInboxController as a child controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(supervisorInboxController, subject, subject.inboxContainerView);
        });

        it(@"should set itself as the inbox controller's delegate", ^{
            supervisorInboxController.delegate should equal(subject);
        });

        it(@"should update the inbox when the view appears", ^{
            [subject viewWillAppear:NO];

            supervisorInboxController should have_received(@selector(updateWithDashboardSummaryPromise:))
                .with(dashboardSummaryDeferred.promise);
        });
    });

    describe(@"the team status", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });

        it(@"should add a supervisorInboxController as a child controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(supervisorTeamStatusController, subject, subject.teamStatusContainerView);
        });

        it(@"should update the team status when the dashboard summary is loaded", ^{
            [subject viewWillAppear:NO];

            SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);
            [dashboardSummaryDeferred resolveWithValue:dashboardSummary];

            supervisorTeamStatusController should have_received(@selector(updateWithDashboardSummary:))
                .with(dashboardSummary);
        });

        context(@"when the dashboard summary has zero counts for clocked in/not in/on-break users", ^{
            beforeEach(^{
                [subject viewWillAppear:NO];

                SupervisorDashboardSummary *dashboardSummary = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:1
                                                                                                             expensesNeedingApprovalCount:1
                                                                                                      timeOffRequestsNeedingApprovalCount:1
                                                                                                                      clockedInUsersCount:0
                                                                                                                          notInUsersCount:0
                                                                                                                        onBreakUsersCount:0
                                                                                                              usersWithOvertimeHoursCount:1
                                                                                                                 usersWithViolationsCount:1
                                                                                                                       overtimeUsersArray:@[]
                                                                                                             employeesWithViolationsArray:@[]];

                [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
            });

            it(@"set the team staus container view's height constraint to zero", ^{
                subject.teamStatusContainerHeightConstraint.constant should equal(0);
            });
        });

        context(@"when the dashboard summary has a non zero count for clocked in users", ^{
            beforeEach(^{
                [subject viewWillAppear:NO];

                SupervisorDashboardSummary *dashboardSummary = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:1
                                                                                                             expensesNeedingApprovalCount:1
                                                                                                      timeOffRequestsNeedingApprovalCount:1
                                                                                                                      clockedInUsersCount:1
                                                                                                                          notInUsersCount:0
                                                                                                                        onBreakUsersCount:0
                                                                                                              usersWithOvertimeHoursCount:1
                                                                                                                 usersWithViolationsCount:1
                                                                                                                       overtimeUsersArray:@[]
                                                                                                             employeesWithViolationsArray:@[]];

                [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
            });

            it(@"should not set the team status container view's height constraint to zero", ^{
                subject.teamStatusContainerHeightConstraint.constant should be_greater_than(0);
            });
        });

        context(@"when the dashboard summary has a non zero count for not in users", ^{
            beforeEach(^{
                [subject viewWillAppear:NO];

                SupervisorDashboardSummary *dashboardSummary = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:1
                                                                                                             expensesNeedingApprovalCount:1
                                                                                                      timeOffRequestsNeedingApprovalCount:1
                                                                                                                      clockedInUsersCount:0
                                                                                                                          notInUsersCount:1
                                                                                                                        onBreakUsersCount:0
                                                                                                              usersWithOvertimeHoursCount:1
                                                                                                                 usersWithViolationsCount:1
                                                                                                                       overtimeUsersArray:@[]
                                                                                                             employeesWithViolationsArray:@[]];

                [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
            });

            it(@"should not set the team status container view's height constraint to zero", ^{
                subject.teamStatusContainerHeightConstraint.constant should be_greater_than(0);
            });
        });

        context(@"when the dashboard summary has a non zero count for clocked in users", ^{
            beforeEach(^{
                [subject viewWillAppear:NO];

                SupervisorDashboardSummary *dashboardSummary = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:1
                                                                                                             expensesNeedingApprovalCount:1
                                                                                                      timeOffRequestsNeedingApprovalCount:1
                                                                                                                      clockedInUsersCount:0
                                                                                                                          notInUsersCount:0
                                                                                                                        onBreakUsersCount:1
                                                                                                              usersWithOvertimeHoursCount:1
                                                                                                                 usersWithViolationsCount:1
                                                                                                                       overtimeUsersArray:@[]
                                                                                                             employeesWithViolationsArray:@[]];

                [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
            });

            it(@"should not set the team status container view's height constraint to zero", ^{
                subject.teamStatusContainerHeightConstraint.constant should be_greater_than(0);
            });
        });
    });

    describe(@"the trend graph", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });

        it(@"should add a SupervisorTrendChartController as a child controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(supervisorTrendChartController, subject, subject.trendChartContainerView);
        });

        context(@"when the dashboard summary has zero counts for clocked in/not in/on-break users", ^{
            beforeEach(^{
                [subject viewWillAppear:NO];

                SupervisorDashboardSummary *dashboardSummary = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:1
                                                                                                             expensesNeedingApprovalCount:1
                                                                                                      timeOffRequestsNeedingApprovalCount:1
                                                                                                                      clockedInUsersCount:0
                                                                                                                          notInUsersCount:0
                                                                                                                        onBreakUsersCount:0
                                                                                                              usersWithOvertimeHoursCount:1
                                                                                                                 usersWithViolationsCount:1
                                                                                                                       overtimeUsersArray:@[]
                                                                                                             employeesWithViolationsArray:@[]];

                [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
            });

            it(@"should set the trend chart container view's height constraint to zero", ^{
                subject.trendChartContainerHeightConstraint.constant should equal(0);
            });
        });

        context(@"when the dashboard summary has a non zero count for clocked in users", ^{
            beforeEach(^{
                [subject viewWillAppear:NO];

                SupervisorDashboardSummary *dashboardSummary = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:1
                                                                                                             expensesNeedingApprovalCount:1
                                                                                                      timeOffRequestsNeedingApprovalCount:1
                                                                                                                      clockedInUsersCount:1
                                                                                                                          notInUsersCount:0
                                                                                                                        onBreakUsersCount:0
                                                                                                              usersWithOvertimeHoursCount:1
                                                                                                                 usersWithViolationsCount:1
                                                                                                                       overtimeUsersArray:@[]
                                                                                                             employeesWithViolationsArray:@[]];

                [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
            });

            it(@"should not set the trend chart container view's height constraint to zero", ^{
                subject.trendChartContainerHeightConstraint.constant should be_greater_than(0);
            });
        });

        context(@"when the dashboard summary has a non zero count for not in users", ^{
            beforeEach(^{
                [subject viewWillAppear:NO];

                SupervisorDashboardSummary *dashboardSummary = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:1
                                                                                                             expensesNeedingApprovalCount:1
                                                                                                      timeOffRequestsNeedingApprovalCount:1
                                                                                                                      clockedInUsersCount:0
                                                                                                                          notInUsersCount:1
                                                                                                                        onBreakUsersCount:0
                                                                                                              usersWithOvertimeHoursCount:1
                                                                                                                 usersWithViolationsCount:1
                                                                                                                       overtimeUsersArray:@[]
                                                                                                             employeesWithViolationsArray:@[]];

                [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
            });

            it(@"should not set the trend chart container view's height constraint to zero", ^{
                subject.trendChartContainerHeightConstraint.constant should be_greater_than(0);
            });
        });

        context(@"when the dashboard summary has a non zero count for clocked in users", ^{
            beforeEach(^{
                [subject viewWillAppear:NO];

                SupervisorDashboardSummary *dashboardSummary = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:1
                                                                                                             expensesNeedingApprovalCount:1
                                                                                                      timeOffRequestsNeedingApprovalCount:1
                                                                                                                      clockedInUsersCount:0
                                                                                                                          notInUsersCount:0
                                                                                                                        onBreakUsersCount:1
                                                                                                              usersWithOvertimeHoursCount:1
                                                                                                                 usersWithViolationsCount:1
                                                                                                                       overtimeUsersArray:@[]
                                                                                                             employeesWithViolationsArray:@[]];

                [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
            });

            it(@"should not set the trend chart container view's height constraint to zero", ^{
                subject.trendChartContainerHeightConstraint.constant should be_greater_than(0);
            });
        });
    });
    
    describe(@"the error banner view", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        
        it(@"should check for error banner view", ^{
            [subject viewWillAppear:NO];
            
            errorBannerViewParentPresenterHelper should have_received(@selector(setScrollViewInsetWithErrorBannerPresentation:))
            .with(subject.subViewsContainerScrollview);
        });
    });


    describe(@"presenting the current timesheet period button controller", ^{
        beforeEach(^{
            userPermissionsStorage stub_method(@selector(canViewTeamTimesheet)).and_return(YES);
            subject.view should_not be_nil;
        });
        
        it(@"should have the  timesheet button container view", ^{
            subject.timesheetButtonContainerView should_not be_nil;
        });
        
        it(@"should have received presentTimesheetButtonControllerInContainer", ^{
            timesheetButtonControllerPresenter should have_received(@selector(presentTimesheetButtonControllerInContainer:onParentController:delegate:title:));
        });
    });
    
    describe(@"View Team Timesheet button should not be shown if has no view teamTimesheet permission", ^{
        beforeEach(^{
            userPermissionsStorage stub_method(@selector(canViewTeamTimesheet)).and_return(NO);
            subject.view should_not be_nil;
        });
        
        it(@"height of the view team timesheet should be 0", ^{
            subject.viewTeamTimesheetContainerHeightConstraint.constant should equal(0);
        });
        
        it(@"should not have received presentTimesheetButtonControllerInContainer", ^{
            timesheetButtonControllerPresenter should_not have_received(@selector(presentTimesheetButtonControllerInContainer:onParentController:delegate:title:))
            .with(subject.timesheetButtonContainerView, subject, subject, RPLocalizedString(@"View Team Timesheets", nil));

        });

    });

    
    describe(@"presenting the view previous approvals button controller", ^{
        beforeEach(^{
            timesheetButtonControllerPresenter stub_method(@selector(presentPreviousApprovalsButtonControllerInContainer:onParentController:delegate:));
            subject.view should_not be_nil;
        });

        it(@"should have the  approvals button container view", ^{
            subject.previousApprovalsButtonContainerView should_not be_nil;
        });

        it(@"should present the view previous approvals  button controller", ^{
            timesheetButtonControllerPresenter should have_received(@selector(presentPreviousApprovalsButtonControllerInContainer:onParentController:delegate:))
            .with(subject.previousApprovalsButtonContainerView, subject, subject);
        });
    });

    describe(@"as a <TimesheetButtonControllerDelegate>", ^{
        describe(@"timesheetButtonControllerWillNavigateToTimesheetDetailScreen:", ^{
            __block UINavigationController *navigationController;
                __block SupervisorTimesheetDetailsSeriesController *supervisorTimesheetDetailsSeriesController;

            beforeEach(^{
                supervisorTimesheetDetailsSeriesController = (id)[[UIViewController alloc] init];
                [injector bind:[SupervisorTimesheetDetailsSeriesController class] toInstance:supervisorTimesheetDetailsSeriesController];

                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                spy_on(navigationController);

                [subject view];
                [subject timesheetButtonControllerWillNavigateToTimesheetDetailScreen:nil];
            });

            it(@"should navigate to the TimesheetDetails series screen", ^{
                navigationController should have_received(@selector(pushViewController:animated:)).with(supervisorTimesheetDetailsSeriesController, YES);
            });
        });
        
        describe(@"timesheetButtonControllerWillNavigateToWidgetTimesheetDetailScreen:", ^{
            __block UINavigationController *navigationController;
            __block SupervisorTimesheetDetailsSeriesController *supervisorTimesheetDetailsSeriesController;
            
            beforeEach(^{
                supervisorTimesheetDetailsSeriesController = (id)[[UIViewController alloc] init];
                [injector bind:[SupervisorTimesheetDetailsSeriesController class] toInstance:supervisorTimesheetDetailsSeriesController];
                
                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                spy_on(navigationController);
                
                [subject view];
                [subject timesheetButtonControllerWillNavigateToTimesheetDetailScreen:nil];
            });
            
            it(@"should navigate to the TimesheetDetails series screen", ^{
                navigationController should have_received(@selector(pushViewController:animated:)).with(supervisorTimesheetDetailsSeriesController, YES);
            });
        });
    });

    describe(@"as a <PreviousApprovalsButtonControllerDelegate>", ^{
        describe(@"approvalsButtonControllerWillNavigateToPreviousApprovalsScreen:", ^{
            __block UINavigationController *navigationController;
            __block ApprovalsCountViewController *approvalsCountViewController;

            beforeEach(^{
                approvalsCountViewController = (id)[[UIViewController alloc] init];
                [injector bind:[ApprovalsCountViewController class] toInstance:approvalsCountViewController];

                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                spy_on(navigationController);

                [subject view];
                [subject approvalsButtonControllerWillNavigateToPreviousApprovalsScreen:nil];
            });

            it(@"should navigate to the TimesheetDetails series screen", ^{
                navigationController should have_received(@selector(pushViewController:animated:)).with(approvalsCountViewController, YES);
            });
        });
    });

    describe(@"styling the views", ^{
        beforeEach(^{
            theme stub_method(@selector(supervisorDashboardBackgroundColor)).and_return([UIColor grayColor]);
            subject.view should_not be_nil;
        });

        it(@"apply the theme to the views", ^{
            subject.view.backgroundColor should equal([UIColor grayColor]);
        });
    });

    describe(@"When supervisor has no permission to view time punch", ^{
        beforeEach(^{
            userPermissionsStorage stub_method(@selector(canViewTeamPunch)).again().and_return(NO);
            [subject viewWillAppear:NO];

            SupervisorDashboardSummary *dashboardSummary = [[SupervisorDashboardSummary alloc] initWithTimesheetsNeedingApprovalCount:1
                                                                                                         expensesNeedingApprovalCount:1
                                                                                                  timeOffRequestsNeedingApprovalCount:1
                                                                                                                  clockedInUsersCount:1
                                                                                                                      notInUsersCount:0
                                                                                                                    onBreakUsersCount:0
                                                                                                          usersWithOvertimeHoursCount:1
                                                                                                             usersWithViolationsCount:1
                                                                                                                   overtimeUsersArray:@[]
                                                                                                         employeesWithViolationsArray:@[]];

            [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
            subject.view should_not be_nil;
        });

        it(@"should not add a SupervisorTrendChartController as a child controller", ^{
            childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:))
            .with(supervisorTrendChartController, subject, subject.trendChartContainerView);
        });

        it(@"should not add a supervisorInboxController as a child controller", ^{
            childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:))
            .with(supervisorTeamStatusController, subject, subject.teamStatusContainerView);
        });

        it(@"set the team staus container view's height constraint to zero", ^{
            subject.teamStatusContainerHeightConstraint.constant should equal(0);
        });

        it(@"should not set the trend chart container view's height constraint to zero", ^{
            subject.trendChartContainerHeightConstraint.constant should equal(0);
        });
    });
});

SPEC_END
