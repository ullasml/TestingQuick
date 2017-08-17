#import "RootTabBarController.h"
#import "TimesheetNavigationController.h"
#import "ListOfTimeSheetsViewController.h"
#import "ListOfExpenseSheetsViewController.h"
#import "ExpensesNavigationController.h"
#import "BookedTimeOffNavigationController.h"
#import "ListOfBookedTimeOffViewController.h"
#import "AttendanceNavigationController.h"
#import "AttendanceViewController.h"
#import "PunchHistoryNavigationController.h"
#import "TeamTimeViewController.h"
#import "ShiftsNavigationController.h"
#import "ShiftsViewController.h"
#import "ApprovalsNavigationController.h"
#import "ApprovalsCountViewController.h"
#import "TeamTimeNavigationController.h"
#import "ListOfExpenseSheetsViewControllerProvider.h"
#import "SettingsNavigationController.h"
#import "MoreViewController.h"
#import "ListOfTimeSheetsViewControllerProvider.h"
#import "PunchHomeController.h"
#import "URLSessionClient.h"
#import "JSONClient.h"
#import "GUIDProvider.h"
#import "PunchRepository.h"
#import "PunchHomeControllerProvider.h"
#import "DateProvider.h"
#import "LaunchLoginDelegate.h"
#import "SupervisorDashboardController.h"
#import "DoorKeeper.h"
#import "PunchHomeNavigationController.h"
#import "NavigationBarStylist.h"
#import "Theme.h"
#import "ReachabilityMonitor.h"
#import "SupervisorDashboardNavigationController.h"
#import "TimerProvider.h"
#import "Blindside.h"
#import "InjectorProvider.h"


@interface RootTabBarController ()

@property (nonatomic) ListOfTimeSheetsViewControllerProvider *listOfTimesheetsViewControllerProvider;
@property (nonatomic) ListOfExpenseSheetsViewControllerProvider *listOfExpenseSheetsViewControllerProvider;
@property (nonatomic) PunchHomeControllerProvider *punchHomeControllerProvider;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic, weak) id<LaunchLoginDelegate> launchLoginDelegate;
@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic) id<Theme> theme;
@property (nonatomic, weak) id<BSInjector> injector;

@end

@implementation RootTabBarController

- (instancetype)initWithInjector:(id<BSInjector>)injector
                             modulesArray:(NSArray *)modulesArray
listOfExpenseSheetsViewControllerProvider:(ListOfExpenseSheetsViewControllerProvider *)listOfExpenseSheetsViewControllerProvider
   listOfTimeSheetsViewControllerProvider:(ListOfTimeSheetsViewControllerProvider *)listOfTimeSheetsViewControllerProvider
              punchHomeControllerProvider:(PunchHomeControllerProvider *)punchHomeControllerProvider
                     navigationBarStylist:(NavigationBarStylist *)navigationBarStylist
                      launchLoginDelegate:(id<LaunchLoginDelegate>)launchLoginDelegate
                      reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                               doorKeeper:(DoorKeeper *)doorKeeper
                                    theme:(id<Theme>)theme
{
    if (self = [super init]) {
        self.injector = injector;
        self.listOfTimesheetsViewControllerProvider = listOfTimeSheetsViewControllerProvider;
        self.listOfExpenseSheetsViewControllerProvider = listOfExpenseSheetsViewControllerProvider;
        self.punchHomeControllerProvider=punchHomeControllerProvider;
        self.doorKeeper = doorKeeper;
        self.launchLoginDelegate = launchLoginDelegate;
        self.reachabilityMonitor = reachabilityMonitor;
        self.theme = theme;

        self.viewControllers = [self buildViewControllersWithModulesArray:modulesArray];
        self.tabBar.translucent = NO;
        self.tabBar.tintColor = [self.theme tabBarTintColor];

        [navigationBarStylist styleNavigationBar];
    }
    return self;
}

- (NSArray *)buildViewControllersWithModulesArray:(NSArray *)modulesArray {
    NSMutableArray *viewControllersAndRanks = [NSMutableArray array];

    for (NSString *moduleName in modulesArray) {
        if ([moduleName isEqualToString:TIMESHEETS_TAB_MODULE_NAME]) {
            ListOfTimeSheetsViewController *timeSheetsViewController = [self.listOfTimesheetsViewControllerProvider provideInstance];
            TimesheetNavigationController *navController = [[TimesheetNavigationController alloc] initWithRootViewController:timeSheetsViewController];
            navController.tabBarItem.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
            navController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timesheets"];
            NSArray *navControllerAndRank = @[navController, @(0)];
            [viewControllersAndRanks addObject:navControllerAndRank];
        } else if ([moduleName isEqualToString:EXPENSES_TAB_MODULE_NAME]) {
            ListOfExpenseSheetsViewController *expenseSheetsViewController = [self.listOfExpenseSheetsViewControllerProvider provideInstance];
            ExpensesNavigationController *navController = [[ExpensesNavigationController alloc] initWithRootViewController:expenseSheetsViewController];
            navController.tabBarItem.title = RPLocalizedString(ExpenseTabbarTitle, ExpenseTabbarTitle);
            navController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_expenses"];
            NSArray *navControllerAndRank = @[navController, @(3)];
            [viewControllersAndRanks addObject:navControllerAndRank];
        } else if ([moduleName isEqualToString:TIME_OFF_TAB_MODULE_NAME]) {
            ListOfBookedTimeOffViewController *bookedTimeOffViewController = [[ListOfBookedTimeOffViewController alloc] init];
            BookedTimeOffNavigationController *navController = [[BookedTimeOffNavigationController alloc] initWithRootViewController:bookedTimeOffViewController];
            navController.tabBarItem.title = RPLocalizedString(BookedTimeOffTabbarTitle, BookedTimeOffTabbarTitle);
            navController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timeOff"];
            NSArray *navControllerAndRank = @[navController, @(4)];
            [viewControllersAndRanks addObject:navControllerAndRank];
        } else if ([moduleName isEqualToString:CLOCK_IN_OUT_TAB_MODULE_NAME]) {
            [viewControllersAndRanks addObject:[self buildTabControllerWithNavigationControllerClass:[AttendanceNavigationController class]
                                                                             rootViewControllerClass:[AttendanceViewController class]
                                                                                            titleKey:AttendanceTabbarTitle
                                                                                           imageName:@"icon_tabBar_clockInOut"
                                                                                                rank:6]];
        } else if ([moduleName isEqualToString:PUNCH_HISTORY_TAB_MODULE_NAME]) {
            [viewControllersAndRanks addObject:[self buildTabControllerWithNavigationControllerClass:[PunchHistoryNavigationController class]
                                                                             rootViewControllerClass:[TeamTimeViewController class]
                                                                                            titleKey:PunchHistoryTabbarTitle
                                                                                           imageName:@"icon_tabBar_punchHistory"
                                                                                                rank:7]];
        } else if ([moduleName isEqualToString:APPROVAL_TAB_MODULE_NAME]) {
            [viewControllersAndRanks addObject:[self buildTabControllerWithNavigationControllerClass:[ApprovalsNavigationController class]
                                                                             rootViewControllerClass:[ApprovalsCountViewController class]
                                                                                            titleKey:ApprovalsTabbarTitle
                                                                                           imageName:@"icon_tabBar_approvals"
                                                                                                rank:2]];

            SupervisorDashboardController *supervisorDashboard = [self.injector getInstance:[SupervisorDashboardController class]];
            SupervisorDashboardNavigationController *navController = [[SupervisorDashboardNavigationController alloc] initWithRootViewController:supervisorDashboard
                                                                                                                             reachabilityMonitor:self.reachabilityMonitor
                                                                                                                                           theme:self.theme];
            navController.tabBarItem.title = RPLocalizedString(DashboardTabbarTitle, DashboardTabbarTitle);
            navController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_teamPunches"];
            [viewControllersAndRanks addObject:@[navController, @2]];

        } else if ([moduleName isEqualToString:SCHEDULE_TAB_MODULE_NAME]) {
            [viewControllersAndRanks addObject:[self buildTabControllerWithNavigationControllerClass:[ShiftsNavigationController class]
                                                                             rootViewControllerClass:[ShiftsViewController class]
                                                                                            titleKey:ShiftsTabbarTitle
                                                                                           imageName:@"icon_tabBar_schedule"
                                                                                                rank:1]];
        } else if ([moduleName isEqualToString:TIME_PUNCHES_TAB_MODULE_NAME]) {
            [viewControllersAndRanks addObject:[self buildTabControllerWithNavigationControllerClass:[TeamTimeNavigationController class]
                                                                             rootViewControllerClass:[TeamTimeViewController class]
                                                                                            titleKey:TeamTimeTabbarTitle
                                                                                           imageName:@"icon_tabBar_teamPunches"
                                                                                                rank:8]];

        } else if ([moduleName isEqualToString:SETTINGS_TAB_MODULE_NAME]) {
            NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
            MoreViewController *moreViewController =  [[MoreViewController alloc] initWithDoorKeeper:self.doorKeeper
                                                                                 launchLoginDelegate:self.launchLoginDelegate
                                                                                        userDefaults:userDefaults];
            SettingsNavigationController *navController = [[SettingsNavigationController alloc] initWithRootViewController:moreViewController];
            navController.tabBarItem.title = RPLocalizedString(MoreTabbarTitle, MoreTabbarTitle);
            navController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_settings"];

            NSArray *navControllerAndRank = @[navController, @(5)];
            [viewControllersAndRanks addObject:navControllerAndRank];

        } else if([moduleName isEqualToString:NEW_PUNCH_WIDGET_MODULE_NAME]){
            PunchHomeController *punchHomeController = [self.punchHomeControllerProvider provideInstance];
            TimerProvider *timerProvider = [[TimerProvider alloc] init];
            PunchHomeNavigationController *navigationController = [[PunchHomeNavigationController alloc] initWithRootViewController:punchHomeController
                                                                                                                reachabilityMonitor:self.reachabilityMonitor
                                                                                                                      timerProvider:timerProvider
                                                                                                                              theme:self.theme];
            navigationController.navigationBarHidden = YES;
            punchHomeController.tabBarItem.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
            punchHomeController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timesheets"];
            NSArray *navControllerAndRank = @[navigationController, @(0)];
            [viewControllersAndRanks addObject:navControllerAndRank];
        }
    }

    return [self sortViewControllersForTabOrdering:viewControllersAndRanks];
}

//update badge Count
-(void)updateBadgeCountForEachModule
{
    if (self.viewControllers != nil && [self.viewControllers count]>0) {
        for (NSUInteger index = 0; index<[self.viewControllers count]; index++) {
            UINavigationController *navigationType = [self.viewControllers objectAtIndex:index];
            if ([navigationType isKindOfClass:[TimesheetNavigationController class]]) {
                int badgeValue =[[[NSUserDefaults standardUserDefaults] objectForKey:REJECTED_TIMESHEET_COUNT_KEY] intValue]+[[[NSUserDefaults standardUserDefaults] objectForKey:TIMESHEET_PAST_DUE_COUNT_KEY] intValue];
                if (badgeValue != 0)
                    navigationType.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeValue];
            }
            else if ([navigationType isKindOfClass:[BookedTimeOffNavigationController class]]) {
                int badgeValue =[[[NSUserDefaults standardUserDefaults] objectForKey:REJECTED_TIMEOFF_BOOKING_COUNT_KEY] intValue];
                if (badgeValue != 0)
                    navigationType.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeValue];
            }
            else if ([navigationType isKindOfClass:[ExpensesNavigationController class]]) {
                int badgeValue =[[[NSUserDefaults standardUserDefaults] objectForKey:REJECTED_EXPENSE_SHEETS_COUNT_KEY] intValue];
                if (badgeValue != 0)
                    navigationType.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeValue];
            }
            else if ([navigationType isKindOfClass:[ApprovalsNavigationController class]]) {
                int badgeValue =[[[NSUserDefaults standardUserDefaults] objectForKey:PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY] intValue]+[[[NSUserDefaults standardUserDefaults] objectForKey:PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY] intValue]+[[[NSUserDefaults standardUserDefaults] objectForKey:PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY] intValue];
                if (badgeValue != 0)
                    navigationType.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeValue];
            }
        }
    }
}

#pragma mark - Private

- (NSArray *)sortViewControllersForTabOrdering:(NSArray *)viewControllersAndRanks {
    NSArray *sortedViewControllersAndRanks = [viewControllersAndRanks sortedArrayUsingComparator:^NSComparisonResult(NSArray *controllerAndRankA, NSArray *controllerAndRankB) {
        NSInteger rankA = [controllerAndRankA[1] integerValue];
        NSInteger rankB = [controllerAndRankB[1] integerValue];

        if (rankA > rankB) {
            return (NSComparisonResult) NSOrderedDescending;
        } else if (rankA < rankB) {
            return (NSComparisonResult) NSOrderedAscending;
        }
        return (NSComparisonResult) NSOrderedSame;
    }];

    NSMutableArray *sortedViewControllers = [NSMutableArray array];

    for(NSArray *controllerAndRank in sortedViewControllersAndRanks) {
        [sortedViewControllers addObject:controllerAndRank[0]];
    }
    return [sortedViewControllers copy];
}

- (NSArray *)buildTabControllerWithNavigationControllerClass:(Class)navigationControllerClass rootViewControllerClass:(Class)rootViewControllerClass titleKey:(NSString *)titleKey imageName:(NSString *)imageName rank:(NSInteger)rank {
    UIViewController *rootViewController = [[rootViewControllerClass alloc] init];
    UINavigationController *navController = [[navigationControllerClass alloc] initWithRootViewController:rootViewController];
    navController.tabBarItem.title = RPLocalizedString(titleKey, titleKey);
    navController.tabBarItem.image = [UIImage imageNamed:imageName];
    return @[navController, @(rank)];
}

@end
