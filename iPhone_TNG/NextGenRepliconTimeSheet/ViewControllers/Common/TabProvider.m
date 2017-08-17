#import "TabProvider.h"
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
#import "MoreViewController.h"
#import "PunchHomeController.h"
#import "PunchHomeNavigationController.h"
#import "SupervisorDashboardNavigationController.h"
#import "ModuleStorage.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"
#import "UserPermissionsStorage.h"
#import "NoTimeSheetAssignedViewController.h"
#import "WrongConfigurationMessageViewController.h"
#import "SettingsNavigationController.h"
#import "ViewTimesheetNavigationController.h"

@interface TabProvider ()

@property (nonatomic, weak) id<BSInjector> injector;
@property (nonatomic) NSDictionary *moduleTags;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@end


@implementation TabProvider

- (instancetype)initWithUserPermissionStorage:(UserPermissionsStorage *)userPermissionsStorage
{
    self = [super init];
    if (self)
    {
        self.userPermissionsStorage = userPermissionsStorage;
        self.moduleTags = @{
                            NEW_PUNCH_WIDGET_MODULE_NAME        : @1,
                            PUNCH_IN_PROJECT_MODULE_NAME        : @2,
                            PUNCH_INTO_ACTIVITIES_MODULE_NAME   : @3,
                            TIMESHEETS_TAB_MODULE_NAME          : @4,
                            SCHEDULE_TAB_MODULE_NAME            : @5,
                            APPROVAL_TAB_MODULE_NAME            : @6,
                            EXPENSES_TAB_MODULE_NAME            : @7,
                            TIME_OFF_TAB_MODULE_NAME            : @8,
                            SETTINGS_TAB_MODULE_NAME            : @9,
                            CLOCK_IN_OUT_TAB_MODULE_NAME        : @10,
                            PUNCH_HISTORY_TAB_MODULE_NAME       : @11
                            };
    }
    return self;
}

- (NSArray *)viewControllersForModules:(NSArray *)modules
{
    NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:modules.count];
    BOOL hasTimePunchAccess = [self.userPermissionsStorage hasTimePunchAccess];
    for (NSString *moduleName in modules)
    {
        if ([moduleName isEqualToString:TIMESHEETS_TAB_MODULE_NAME] )
        {
            TimesheetNavigationController *navController = [self.injector getInstance:InjectorKeyTimesheetNavigationController];
            navController.tabBarItem.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
            navController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timesheets"];
            navController.view.tag = [self.moduleTags[moduleName] integerValue];
            [viewControllers addObject:navController];
        }
        else if ([moduleName isEqualToString:EXPENSES_TAB_MODULE_NAME])
        {
            ExpensesNavigationController *navController = [self.injector getInstance:[ExpensesNavigationController class]];
            navController.tabBarItem.title = RPLocalizedString(ExpenseTabbarTitle, ExpenseTabbarTitle);
            navController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_expenses"];

            navController.view.tag = [self.moduleTags[moduleName] integerValue];
            [viewControllers addObject:navController];
        }
        else if ([moduleName isEqualToString:TIME_OFF_TAB_MODULE_NAME])
        {

            BookedTimeOffNavigationController *navController = [self.injector getInstance:[BookedTimeOffNavigationController class]];
            navController.tabBarItem.title = RPLocalizedString(BookedTimeOffTabbarTitle, BookedTimeOffTabbarTitle);
            navController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timeOff"];

            navController.view.tag = [self.moduleTags[moduleName] integerValue];
            [viewControllers addObject:navController];
        }
        else if ([moduleName isEqualToString:CLOCK_IN_OUT_TAB_MODULE_NAME])
        {

            AttendanceNavigationController *navController = [self.injector getInstance:[AttendanceNavigationController class]];
            navController.tabBarItem.title = RPLocalizedString(AttendanceTabbarTitle, AttendanceTabbarTitle);
            navController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_clockInOut"];

            navController.view.tag = [self.moduleTags[moduleName] integerValue];
            [viewControllers addObject:navController];
        }
        else if ([moduleName isEqualToString:PUNCH_HISTORY_TAB_MODULE_NAME])
        {

            PunchHistoryNavigationController *navController = [self.injector getInstance:[PunchHistoryNavigationController class]];
            navController.tabBarItem.title = RPLocalizedString(PunchHistoryTabbarTitle, PunchHistoryTabbarTitle);
            navController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_punchHistory"];

            navController.view.tag = [self.moduleTags[moduleName] integerValue];
            [viewControllers addObject:navController];
        }
        else if ([moduleName isEqualToString:APPROVAL_TAB_MODULE_NAME])
        {
            SupervisorDashboardNavigationController *supervisorDashboardNavigationController = [self.injector getInstance:[SupervisorDashboardNavigationController class]];
            supervisorDashboardNavigationController.tabBarItem.title = RPLocalizedString(DashboardTabbarTitle, DashboardTabbarTitle);
            supervisorDashboardNavigationController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_dashboard"];
            supervisorDashboardNavigationController.view.tag = [self.moduleTags[moduleName] integerValue];
            [supervisorDashboardNavigationController.tabBarItem setAccessibilityLabel:@"dashboard_tabbar_item"];
            [viewControllers addObject:supervisorDashboardNavigationController];
        }
        else if ([moduleName isEqualToString:SCHEDULE_TAB_MODULE_NAME])
        {
            
            ShiftsNavigationController *navController = [self.injector getInstance:[ShiftsNavigationController class]];
            navController.tabBarItem.title = RPLocalizedString(ShiftsTabbarTitle, ShiftsTabbarTitle);
            navController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_schedule"];


            navController.view.tag = [self.moduleTags[moduleName] integerValue];
            [viewControllers addObject:navController];
        }
        
        else if ([moduleName isEqualToString:SETTINGS_TAB_MODULE_NAME])
        {

            SettingsNavigationController *navController = [self.injector getInstance:[SettingsNavigationController class]];
            navController.tabBarItem.title = RPLocalizedString(MoreTabbarTitle, MoreTabbarTitle);
            navController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_settings"];
            navController.interactivePopGestureRecognizer.enabled = NO;
            navController.navigationBar.translucent = NO;

            navController.view.tag = [self.moduleTags[moduleName] integerValue];
            [navController.tabBarItem setAccessibilityLabel:@"settings_tabbar_item"];
            [viewControllers addObject:navController];
        }
        else if ([moduleName isEqualToString:NEW_PUNCH_WIDGET_MODULE_NAME])
        {
            if ([self.userPermissionsStorage hasTimesheetAccess])
            {
                if(!hasTimePunchAccess) {
                    ViewTimesheetNavigationController *navController = [self getViewMyTimeSheetWithTagUsingModule:moduleName];
                    [viewControllers addObject:navController];
                }else {
                    PunchHomeNavigationController *navigationController = [self.injector getInstance:InjectorKeyPunchHomeNavigationControllerWithoutProjects];
                    navigationController.tabBarItem.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
                    navigationController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timesheets"];
                    navigationController.view.tag = [self.moduleTags[moduleName] integerValue];
                    [viewControllers addObject:navigationController];
                }

            }
            else
            {
                NoTimeSheetAssignedViewController *viewController = [self.injector getInstance:[NoTimeSheetAssignedViewController class]];
                viewController.tabBarItem.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
                viewController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timesheets"];
                viewController.view.tag = [self.moduleTags[moduleName] integerValue];
                [viewControllers addObject:viewController];
            }
        }
        else if ([moduleName isEqualToString:PUNCH_IN_PROJECT_MODULE_NAME])
        {
            if ([self.userPermissionsStorage hasTimesheetAccess])
            {
                if(!hasTimePunchAccess) {
                    ViewTimesheetNavigationController *navController = [self getViewMyTimeSheetWithTagUsingModule:moduleName];
                    [viewControllers addObject:navController];
                }else {
                    PunchHomeNavigationController *navigationController = [self.injector getInstance:InjectorKeyPunchHomeNavigationControllerWithProjects];
                    
                    navigationController.tabBarItem.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
                    navigationController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timesheets"];
                    
                    navigationController.view.tag = [self.moduleTags[moduleName] integerValue];
                    [viewControllers addObject:navigationController];
                }
                
            }
            else
            {
                NoTimeSheetAssignedViewController *viewController = [self.injector getInstance:[NoTimeSheetAssignedViewController class]];
                viewController.tabBarItem.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
                viewController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timesheets"];
                viewController.view.tag = [self.moduleTags[moduleName] integerValue];
                [viewControllers addObject:viewController];
            }
        }

        else if ([moduleName isEqualToString:PUNCH_INTO_ACTIVITIES_MODULE_NAME])
        {
            if ([self.userPermissionsStorage hasTimesheetAccess])
            {
                if(!hasTimePunchAccess) {
                    ViewTimesheetNavigationController *navController = [self getViewMyTimeSheetWithTagUsingModule:moduleName];
                    [viewControllers addObject:navController];
                }else {
                    PunchHomeNavigationController *navigationController = [self.injector getInstance:InjectorKeyPunchHomeNavigationControllerWithProjects];

                    navigationController.tabBarItem.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
                    navigationController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timesheets"];

                    navigationController.view.tag = [self.moduleTags[moduleName] integerValue];
                    [viewControllers addObject:navigationController];
                }
            }
            else
            {
                NoTimeSheetAssignedViewController *viewController = [self.injector getInstance:[NoTimeSheetAssignedViewController class]];
                viewController.tabBarItem.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
                viewController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timesheets"];
                viewController.view.tag = [self.moduleTags[moduleName] integerValue];
                [viewControllers addObject:viewController];
            }
        }


        else if ([moduleName isEqualToString:PUNCH_INTO_SIMPLE_PUNCH_OEF_MODULE_NAME])
        {
            if ([self.userPermissionsStorage hasTimesheetAccess])
            {
                if(!hasTimePunchAccess) {
                    ViewTimesheetNavigationController *navController = [self getViewMyTimeSheetWithTagUsingModule:moduleName];
                    [viewControllers addObject:navController];
                }else {
                    PunchHomeNavigationController *navigationController = [self.injector getInstance:InjectorKeyPunchHomeNavigationControllerWithProjects];

                    navigationController.tabBarItem.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
                    navigationController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timesheets"];

                    navigationController.view.tag = [self.moduleTags[moduleName] integerValue];
                    [viewControllers addObject:navigationController];
                }
            }
            else
            {
                NoTimeSheetAssignedViewController *viewController = [self.injector getInstance:[NoTimeSheetAssignedViewController class]];
                viewController.tabBarItem.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
                viewController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timesheets"];
                viewController.view.tag = [self.moduleTags[moduleName] integerValue];
                [viewControllers addObject:viewController];
            }
        }

        else if ([moduleName isEqualToString:WRONG_CONFIGURATION_MODULE_NAME])
        {
            if ([self.userPermissionsStorage hasTimesheetAccess])
            {
                WrongConfigurationMessageViewController *viewController = [self.injector getInstance:[WrongConfigurationMessageViewController class]];
                if ([modules containsObject:TIMESHEETS_TAB_MODULE_NAME])
                {
                    viewController.tabBarItem.title = RPLocalizedString(AttendanceTabbarTitle, AttendanceTabbarTitle);
                    viewController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_clockInOut"];
                }
                else
                {
                   viewController.tabBarItem.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
                    viewController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timesheets"];
                }


                viewController.view.tag = [self.moduleTags[moduleName] integerValue];
                [viewControllers addObject:viewController];
            }
            else
            {
                NoTimeSheetAssignedViewController *viewController = [self.injector getInstance:[NoTimeSheetAssignedViewController class]];
                viewController.tabBarItem.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
                viewController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timesheets"];
                viewController.view.tag = [self.moduleTags[moduleName] integerValue];
                [viewControllers addObject:viewController];
            }
        }
    }

    return viewControllers;
}

- (ViewTimesheetNavigationController *)getViewMyTimeSheetWithTagUsingModule:(NSString *)moduleName{
    
    ViewTimesheetNavigationController *navController = nil;
    if (self.userPermissionsStorage.isWidgetPlatformSupported)
    {
        navController = [self.injector getInstance:InjectorKeyWidgetPlatformNavigationController];
    }
    else{
        navController = [self.injector getInstance:InjectorKeyViewMyTimesheetNavigationController];
    }
    navController.tabBarItem.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
    navController.tabBarItem.image = [UIImage imageNamed:@"icon_tabBar_timesheets"];
    navController.view.tag = [self.moduleTags[moduleName] integerValue];
    return navController;
}

- (NSArray *)modulesForViewControllers:(NSArray *)viewControllers
{
    NSMutableArray *modules = [NSMutableArray arrayWithCapacity:viewControllers.count];

    for (UIViewController *viewController in viewControllers)
    {
        NSNumber *viewControllerTag = @(viewController.view.tag);

        NSSet *keys = [self.moduleTags keysOfEntriesPassingTest:^BOOL(NSString *key, NSNumber *value, BOOL *stop) {
            return [value isEqualToNumber:viewControllerTag];
        }];

        if (keys.count)
        {
            [modules addObject:keys.anyObject];
        }
    }

    return modules;
}



@end
