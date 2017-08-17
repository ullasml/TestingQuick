#import <Cedar/Cedar.h>
#import "TabProvider.h"
#import "ListOfTimeSheetsViewController.h"
#import "TimesheetNavigationController.h"
#import "ExpensesNavigationController.h"
#import "ListOfExpenseSheetsViewController.h"
#import "BookedTimeOffNavigationController.h"
#import "ListOfBookedTimeOffViewController.h"
#import "AttendanceNavigationController.h"
#import "AttendanceViewController.h"
#import "Constants.h"
#import "PunchHistoryNavigationController.h"
#import "TeamTimeViewController.h"
#import "ApprovalsNavigationController.h"
#import "ApprovalsCountViewController.h"
#import "ShiftsViewController.h"
#import "ShiftsNavigationController.h"
#import "TeamTimeNavigationController.h"
#import "MoreViewController.h"
#import "PunchHomeController.h"
#import "DoorKeeper.h"
#import "LaunchLoginDelegate.h"
#import "SupervisorDashboardController.h"
#import "PunchHomeNavigationController.h"
#import "NavigationBarStylist.h"
#import "Theme.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "SupervisorDashboardNavigationController.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "ModuleStorage.h"
#import "UserPermissionsStorage.h"
#import "NoTimeSheetAssignedViewController.h"
#import "PunchIntoProjectHomeController.h"
#import "WrongConfigurationMessageViewController.h"
#import "SettingsNavigationController.h"
#import "ViewTimesheetNavigationController.h"
#import "TimesheetDetailsSeriesController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TabProviderSpec)

describe(@"TabProvider", ^{
    __block TabProvider *subject;
    __block UINavigationController *navController;
    __block UIViewController *listOfTimesheetsViewController;
    __block ListOfExpenseSheetsViewController *expensesViewController;
    __block UIViewController *supervisorDashboardViewController;
    __block UIViewController *punchHomeController;
    __block UIViewController *timesheetDetailsSeriesController;
    __block UIViewController *punchProjectController;
    __block DoorKeeper *fakeDoorKeeper;
    __block id<LaunchLoginDelegate> launchLoginDelegate;
    __block NavigationBarStylist *navigationBarStylist;
    __block ModuleStorage *moduleOrderer;
    __block id<BSInjector, BSBinder> injector;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block id<Theme> theme;
    __block UserPermissionsStorage *userPermissionsStorage;
    
    beforeEach(^{
        injector = [InjectorProvider injector];

        listOfTimesheetsViewController = [[UIViewController alloc] init];
        [injector bind:[ListOfTimeSheetsViewController class] toInstance:listOfTimesheetsViewController];

        expensesViewController = [[ListOfExpenseSheetsViewController alloc] initWithDefaultTableViewCellStylist:nil
                                                                                         searchTextFieldStylist:nil
                                                                                             notificationCenter:nil
                                                                                                spinnerDelegate:nil
                                                                                                 expenseService:nil
                                                                                                   expenseModel:nil
                                                                                                   userDefaults:nil];
        [injector bind:[ListOfExpenseSheetsViewController class] toInstance:expensesViewController];

        punchHomeController = [[UIViewController alloc] init];
        [injector bind:[PunchHomeController class] toInstance:punchHomeController];

        timesheetDetailsSeriesController = [[UIViewController alloc] init];
        [injector bind:[TimesheetDetailsSeriesController class] toInstance:timesheetDetailsSeriesController];
        
        punchProjectController = [[UIViewController alloc] init];
        [injector bind:[PunchIntoProjectHomeController class] toInstance:punchProjectController];

        moduleOrderer = nice_fake_for([ModuleStorage class]);
        [injector bind:[ModuleStorage class] toInstance:moduleOrderer];

        supervisorDashboardViewController = [[UIViewController alloc] init];
        [injector bind:[SupervisorDashboardController class] toInstance:supervisorDashboardViewController];

        fakeDoorKeeper = nice_fake_for([DoorKeeper class]);
        [injector bind:[DoorKeeper class] toInstance:fakeDoorKeeper];

        launchLoginDelegate = nice_fake_for(@protocol(LaunchLoginDelegate));
        [injector bind:@protocol(LaunchLoginDelegate) toInstance:launchLoginDelegate];

        navigationBarStylist = nice_fake_for([NavigationBarStylist class]);
        [injector bind:[NavigationBarStylist class] toInstance:navigationBarStylist];

        reachabilityMonitor = [[ReachabilityMonitor alloc]init];
        [injector bind:[ReachabilityMonitor class] toInstance:reachabilityMonitor];

        spy_on(reachabilityMonitor);

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];

        subject = [injector getInstance:[TabProvider class]];
    });

    describe(@"creating view controllers for modules", ^{

        context(@"when no modules are enabled", ^{
            it(@"should not have any view controllers", ^{
                [subject viewControllersForModules:@[]] should be_empty;
            });
        });

        context(@"when configured with a timesheet module", ^{
            beforeEach(^{
                NSArray *viewControllers = [subject viewControllersForModules:@[TIMESHEETS_TAB_MODULE_NAME]];
                navController = viewControllers.firstObject;
            });

            it(@"should add a TimesheetNavigationController whose root view is a ListOfTimeSheetsViewController", ^{
                navController should be_instance_of([TimesheetNavigationController class]);
            });
            
            it(@"should be configured correctly", ^{
                TimesheetNavigationController *timesheetNavigationController = (id)navController;
                timesheetNavigationController.reachabilityMonitor should be_same_instance_as(reachabilityMonitor);
                timesheetNavigationController.theme should be_same_instance_as(theme);
            });
            
            it(@"should add a ListOfTimeSheetsViewController", ^{
                navController.viewControllers.count should equal(1);
                
                ListOfTimeSheetsViewController *configuredListOfTimeSheetsViewController = (id)navController.topViewController;
                configuredListOfTimeSheetsViewController should be_same_instance_as(listOfTimesheetsViewController);
            });

            it(@"should initialize the TimesheetNavigationController with the correct tab bar item title and image",^{
                UITabBarItem *tabBarItem = navController.tabBarItem;

                tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
            });
        });

        context(@"when configured with a Astro punch module without projects or clients access", ^{

            context(@"when configured with a punch Widget module and timesheet Assigned", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(YES);
                    userPermissionsStorage  stub_method(@selector(hasTimePunchAccess)).and_return(YES);
                    NSArray *viewControllers = [subject viewControllersForModules:@[NEW_PUNCH_WIDGET_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });

                it(@"should be the correct type", ^{
                    navController should be_instance_of([PunchHomeNavigationController class]);
                });

                it(@"should be configured correctly", ^{
                    PunchHomeNavigationController *punchHomeNavigationController = (id)navController;
                    punchHomeNavigationController.reachabilityMonitor should be_same_instance_as(reachabilityMonitor);
                    punchHomeNavigationController.theme should be_same_instance_as(theme);
                });

                it(@"should add a PunchHomeController", ^{
                    navController.viewControllers.count should equal(1);

                    PunchHomeController *configuredPunchHomeController = (id)navController.topViewController;
                    configuredPunchHomeController should be_same_instance_as(punchHomeController);
                });

                it(@"should initialize the PunchHomeController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;

                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });
            
            context(@"when configured with a punch Widget module and timesheet Assigned for cloud clock user", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(YES);
                    userPermissionsStorage  stub_method(@selector(hasTimePunchAccess)).and_return(NO);
                    NSArray *viewControllers = [subject viewControllersForModules:@[NEW_PUNCH_WIDGET_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });
                
                it(@"should be the correct type", ^{
                    navController should be_instance_of([ViewTimesheetNavigationController class]);
                });
                
                it(@"should be configured correctly", ^{
                    ViewTimesheetNavigationController *viewTimesheetNavigationController = (id)navController;
                    viewTimesheetNavigationController.reachabilityMonitor should be_same_instance_as(reachabilityMonitor);
                    viewTimesheetNavigationController.theme should be_same_instance_as(theme);
                });
                
                it(@"should add a TimesheetDetailsSeriesController", ^{
                    navController.viewControllers.count should equal(1);
                    
                    TimesheetDetailsSeriesController *configuredTimesheetDetailsSeriesController = (id)navController.topViewController;
                    configuredTimesheetDetailsSeriesController should be_same_instance_as(timesheetDetailsSeriesController);
                });
                
                it(@"should initialize the TimesheetDetailsSeriesController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;
                    
                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });
            
            context(@"when configured with a punch Widget module and timesheet Assigned for cloud clock user and widget platform is supported", ^{
                __block ViewTimesheetNavigationController *viewTimesheetNavigationController;
                
                beforeEach(^{
                    viewTimesheetNavigationController = [[ViewTimesheetNavigationController alloc]initWithRootViewController:[[UIViewController alloc]init] userPermissionsStorage:nil reachabilityMonitor:nil timerProvider:nil theme:nil];
                    [injector bind:InjectorKeyWidgetPlatformNavigationController toInstance:viewTimesheetNavigationController];
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(YES);
                    userPermissionsStorage  stub_method(@selector(hasTimePunchAccess)).and_return(NO);
                    userPermissionsStorage  stub_method(@selector(isWidgetPlatformSupported)).and_return(YES);
                    NSArray *viewControllers = [subject viewControllersForModules:@[NEW_PUNCH_WIDGET_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });
                
                it(@"should be the correct type", ^{
                    navController should be_same_instance_as(viewTimesheetNavigationController);
                });
                
                it(@"should initialize the TimesheetDetailsSeriesController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;
                    
                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });

            context(@"when configured with a punch Widget module and no timesheet Assigned", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(NO);
                    NSArray *viewControllers = [subject viewControllersForModules:@[NEW_PUNCH_WIDGET_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });

                it(@"should be the correct type", ^{
                    navController should be_instance_of([NoTimeSheetAssignedViewController class]);
                });

                it(@"should initialize the PunchHomeController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;

                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });

        });

        context(@"when configured with a Astro punch module with projects or clients access", ^{

            beforeEach(^{
                userPermissionsStorage  stub_method(@selector(hasClientAccess)).and_return(YES);
            });
            context(@"when configured with a punch Widget module and timesheet Assigned", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(YES);
                    userPermissionsStorage  stub_method(@selector(hasTimePunchAccess)).and_return(YES);
                    NSArray *viewControllers = [subject viewControllersForModules:@[PUNCH_IN_PROJECT_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });

                it(@"should be the correct type", ^{
                    navController should be_instance_of([PunchHomeNavigationController class]);
                });

                it(@"should be configured correctly", ^{
                    PunchHomeNavigationController *punchHomeNavigationController = (id)navController;
                    punchHomeNavigationController.reachabilityMonitor should be_same_instance_as(reachabilityMonitor);
                    punchHomeNavigationController.theme should be_same_instance_as(theme);
                });

                it(@"should add a PunchIntoProjectHomeController", ^{
                    navController.viewControllers.count should equal(1);

                    PunchIntoProjectHomeController *configuredPunchHomeController = (id)navController.topViewController;
                    configuredPunchHomeController should be_same_instance_as(punchProjectController);
                });

                it(@"should initialize the ProjectPunchHomeController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;

                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });
            
            context(@"when configured with a punch Widget module and timesheet Assigned for cloud clock user", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(YES);
                    userPermissionsStorage  stub_method(@selector(hasTimePunchAccess)).and_return(NO);
                    NSArray *viewControllers = [subject viewControllersForModules:@[PUNCH_IN_PROJECT_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });
                
                it(@"should be the correct type", ^{
                    navController should be_instance_of([ViewTimesheetNavigationController class]);
                });
                
                it(@"should be configured correctly", ^{
                    ViewTimesheetNavigationController *viewTimesheetNavigationController = (id)navController;
                    viewTimesheetNavigationController.reachabilityMonitor should be_same_instance_as(reachabilityMonitor);
                    viewTimesheetNavigationController.theme should be_same_instance_as(theme);
                });
                
                it(@"should add a TimesheetDetailsSeriesController", ^{
                    navController.viewControllers.count should equal(1);
                    
                    TimesheetDetailsSeriesController *configuredTimesheetDetailsSeriesController = (id)navController.topViewController;
                    configuredTimesheetDetailsSeriesController should be_same_instance_as(timesheetDetailsSeriesController);
                });
                
                it(@"should initialize the TimesheetDetailsSeriesController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;
                    
                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });
            
            context(@"when configured with a punch Widget module and timesheet Assigned for cloud clock user and widget platform is supported", ^{
                __block ViewTimesheetNavigationController *viewTimesheetNavigationController;
                
                beforeEach(^{
                   viewTimesheetNavigationController = [[ViewTimesheetNavigationController alloc]initWithRootViewController:[[UIViewController alloc]init] userPermissionsStorage:nil reachabilityMonitor:nil timerProvider:nil theme:nil];
                    [injector bind:InjectorKeyWidgetPlatformNavigationController toInstance:viewTimesheetNavigationController];
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(YES);
                    userPermissionsStorage  stub_method(@selector(hasTimePunchAccess)).and_return(NO);
                    userPermissionsStorage  stub_method(@selector(isWidgetPlatformSupported)).and_return(YES);
                    NSArray *viewControllers = [subject viewControllersForModules:@[PUNCH_IN_PROJECT_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });
                
                it(@"should be the correct type", ^{
                    navController should be_same_instance_as(viewTimesheetNavigationController);
                });
                
                it(@"should initialize the TimesheetDetailsSeriesController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;
                    
                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });
            
            context(@"when configured with a punch Widget module and no timesheet Assigned", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(NO);
                    NSArray *viewControllers = [subject viewControllersForModules:@[PUNCH_IN_PROJECT_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });

                it(@"should be the correct type", ^{
                    navController should be_instance_of([NoTimeSheetAssignedViewController class]);
                });

                it(@"should initialize the PunchHomeController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;

                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });

        });

        context(@"when configured with a Astro punch module with activity access", ^{

            beforeEach(^{
                userPermissionsStorage  stub_method(@selector(hasActivityAccess)).and_return(YES);
            });
            context(@"when configured with a punch Widget module and timesheet Assigned", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(YES);
                    userPermissionsStorage  stub_method(@selector(hasTimePunchAccess)).and_return(YES);
                    NSArray *viewControllers = [subject viewControllersForModules:@[PUNCH_INTO_ACTIVITIES_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });

                it(@"should be the correct type", ^{
                    navController should be_instance_of([PunchHomeNavigationController class]);
                });

                it(@"should be configured correctly", ^{
                    PunchHomeNavigationController *punchHomeNavigationController = (id)navController;
                    punchHomeNavigationController.reachabilityMonitor should be_same_instance_as(reachabilityMonitor);
                    punchHomeNavigationController.theme should be_same_instance_as(theme);
                });

                it(@"should add a PunchIntoProjectHomeController", ^{
                    navController.viewControllers.count should equal(1);

                    PunchIntoProjectHomeController *configuredPunchHomeController = (id)navController.topViewController;
                    configuredPunchHomeController should be_same_instance_as(punchProjectController);
                });

                it(@"should initialize the ProjectPunchHomeController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;

                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });
            
            context(@"when configured with a punch Widget module and timesheet Assigned for cloud clock user", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(YES);
                    userPermissionsStorage  stub_method(@selector(hasTimePunchAccess)).and_return(NO);
                    NSArray *viewControllers = [subject viewControllersForModules:@[PUNCH_INTO_ACTIVITIES_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });
                
                it(@"should be the correct type", ^{
                    navController should be_instance_of([ViewTimesheetNavigationController class]);
                });
                
                it(@"should be configured correctly", ^{
                    ViewTimesheetNavigationController *viewTimesheetNavigationController = (id)navController;
                    viewTimesheetNavigationController.reachabilityMonitor should be_same_instance_as(reachabilityMonitor);
                    viewTimesheetNavigationController.theme should be_same_instance_as(theme);
                });
                
                it(@"should add a TimesheetDetailsSeriesController", ^{
                    navController.viewControllers.count should equal(1);
                    
                    TimesheetDetailsSeriesController *configuredTimesheetDetailsSeriesController = (id)navController.topViewController;
                    configuredTimesheetDetailsSeriesController should be_same_instance_as(timesheetDetailsSeriesController);
                });
                
                it(@"should initialize the TimesheetDetailsSeriesController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;
                    
                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });

            context(@"when configured with a punch Widget module and timesheet Assigned for cloud clock user and widget platform is supported", ^{
                __block ViewTimesheetNavigationController *viewTimesheetNavigationController;
                
                beforeEach(^{
                    viewTimesheetNavigationController = [[ViewTimesheetNavigationController alloc]initWithRootViewController:[[UIViewController alloc]init] userPermissionsStorage:nil reachabilityMonitor:nil timerProvider:nil theme:nil];
                    [injector bind:InjectorKeyWidgetPlatformNavigationController toInstance:viewTimesheetNavigationController];
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(YES);
                    userPermissionsStorage  stub_method(@selector(hasTimePunchAccess)).and_return(NO);
                    userPermissionsStorage  stub_method(@selector(isWidgetPlatformSupported)).and_return(YES);
                    NSArray *viewControllers = [subject viewControllersForModules:@[PUNCH_INTO_ACTIVITIES_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });
                
                it(@"should be the correct type", ^{
                    navController should be_same_instance_as(viewTimesheetNavigationController);
                });
                
                it(@"should initialize the TimesheetDetailsSeriesController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;
                    
                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });
            
            context(@"when configured with a punch Widget module and no timesheet Assigned", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(NO);
                    NSArray *viewControllers = [subject viewControllersForModules:@[PUNCH_INTO_ACTIVITIES_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });

                it(@"should be the correct type", ^{
                    navController should be_instance_of([NoTimeSheetAssignedViewController class]);
                });

                it(@"should initialize the PunchHomeController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;

                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });
            
        });

        context(@"when configured with a Astro punch module with simple punch + OEF access", ^{

            context(@"when configured with a punch Widget module and timesheet Assigned", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(YES);
                    userPermissionsStorage  stub_method(@selector(hasTimePunchAccess)).and_return(YES);
                    NSArray *viewControllers = [subject viewControllersForModules:@[PUNCH_INTO_SIMPLE_PUNCH_OEF_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });

                it(@"should be the correct type", ^{
                    navController should be_instance_of([PunchHomeNavigationController class]);
                });

                it(@"should be configured correctly", ^{
                    PunchHomeNavigationController *punchHomeNavigationController = (id)navController;
                    punchHomeNavigationController.reachabilityMonitor should be_same_instance_as(reachabilityMonitor);
                    punchHomeNavigationController.theme should be_same_instance_as(theme);
                });

                it(@"should add a PunchIntoProjectHomeController", ^{
                    navController.viewControllers.count should equal(1);

                    PunchIntoProjectHomeController *configuredPunchHomeController = (id)navController.topViewController;
                    configuredPunchHomeController should be_same_instance_as(punchProjectController);
                });

                it(@"should initialize the ProjectPunchHomeController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;

                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });
            
            context(@"when configured with a punch Widget module and timesheet Assigned for cloud clock user", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(YES);
                    userPermissionsStorage  stub_method(@selector(hasTimePunchAccess)).and_return(NO);
                    NSArray *viewControllers = [subject viewControllersForModules:@[PUNCH_INTO_SIMPLE_PUNCH_OEF_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });
                
                it(@"should be the correct type", ^{
                    navController should be_instance_of([ViewTimesheetNavigationController class]);
                });
                
                it(@"should be configured correctly", ^{
                    ViewTimesheetNavigationController *viewTimesheetNavigationController = (id)navController;
                    viewTimesheetNavigationController.reachabilityMonitor should be_same_instance_as(reachabilityMonitor);
                    viewTimesheetNavigationController.theme should be_same_instance_as(theme);
                });
                
                it(@"should add a TimesheetDetailsSeriesController", ^{
                    navController.viewControllers.count should equal(1);
                    
                    TimesheetDetailsSeriesController *configuredTimesheetDetailsSeriesController = (id)navController.topViewController;
                    configuredTimesheetDetailsSeriesController should be_same_instance_as(timesheetDetailsSeriesController);
                });
                
                it(@"should initialize the TimesheetDetailsSeriesController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;
                    
                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });
            
            context(@"when configured with a punch Widget module and timesheet Assigned for cloud clock user and widget platform is supported", ^{
                __block ViewTimesheetNavigationController *viewTimesheetNavigationController;
                
                beforeEach(^{
                    viewTimesheetNavigationController = [[ViewTimesheetNavigationController alloc]initWithRootViewController:[[UIViewController alloc]init] userPermissionsStorage:nil reachabilityMonitor:nil timerProvider:nil theme:nil];
                    [injector bind:InjectorKeyWidgetPlatformNavigationController toInstance:viewTimesheetNavigationController];
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(YES);
                    userPermissionsStorage  stub_method(@selector(hasTimePunchAccess)).and_return(NO);
                    userPermissionsStorage  stub_method(@selector(isWidgetPlatformSupported)).and_return(YES);
                    NSArray *viewControllers = [subject viewControllersForModules:@[PUNCH_INTO_SIMPLE_PUNCH_OEF_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });
                
                it(@"should be the correct type", ^{
                    navController should be_same_instance_as(viewTimesheetNavigationController);
                });
                
                it(@"should initialize the TimesheetDetailsSeriesController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;
                    
                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });

            context(@"when configured with a punch Widget module and no timesheet Assigned", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(NO);
                    NSArray *viewControllers = [subject viewControllersForModules:@[PUNCH_INTO_SIMPLE_PUNCH_OEF_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });

                it(@"should be the correct type", ^{
                    navController should be_instance_of([NoTimeSheetAssignedViewController class]);
                });

                it(@"should initialize the PunchHomeController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;

                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });
            
        });

        context(@"when configured with expenses module", ^{
            beforeEach(^{
                NSArray *viewControllers = [subject viewControllersForModules:@[EXPENSES_TAB_MODULE_NAME]];
                navController = viewControllers.firstObject;
            });

            it(@"should add a ExpenseNavigationController whose root view is an ListOfExpenseSheetsViewController", ^{
                navController should be_instance_of([ExpensesNavigationController class]);
                navController.topViewController should be_same_instance_as(expensesViewController);
            });

            it(@"should initialize the ExpensesNavigationController with the correct tab bar item title and image",^{
                UITabBarItem *tabBarItem = navController.tabBarItem;

                tabBarItem.title should equal(RPLocalizedString(ExpenseTabbarTitle, ExpenseTabbarTitle));
                tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_expenses"]);
            });
        });

        context(@"when configured with a time off module", ^{
            beforeEach(^{
                NSArray *viewControllers = [subject viewControllersForModules:@[TIME_OFF_TAB_MODULE_NAME]];
                navController = viewControllers.firstObject;
            });

            it(@"should initialize the BookedTimeOffNavigationController with the correct tab bar item title and image", ^{
                UITabBarItem *tabBarItem = navController.tabBarItem;

                tabBarItem.title should equal(RPLocalizedString(BookedTimeOffTabbarTitle, BookedTimeOffTabbarTitle));
                tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timeOff"]);
            });
        });

        context(@"when configured with a clock in/out module", ^{
            beforeEach(^{
                NSArray *viewControllers = [subject viewControllersForModules:@[CLOCK_IN_OUT_TAB_MODULE_NAME]];
                navController = viewControllers.firstObject;
            });

            it(@"should add an AttendanceNavigationController whose root view is an AttendanceViewController", ^{
                navController should be_instance_of([AttendanceNavigationController class]);
                navController.topViewController should be_instance_of([AttendanceViewController class]);
            });

            it(@"should initialize the AttendanceNavigationController with the correct tab bar item title and image", ^{
                UITabBarItem *tabBarItem = navController.tabBarItem;

                tabBarItem.title should equal(RPLocalizedString(AttendanceTabbarTitle, AttendanceTabbarTitle));
                tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_clockInOut"]);
            });
        });

        context(@"when configured with a punch history module", ^{
            beforeEach(^{
                NSArray *viewControllers = [subject viewControllersForModules:@[PUNCH_HISTORY_TAB_MODULE_NAME]];
                navController = viewControllers.firstObject;
            });

            it(@"should add a PunchHistoryNavigationController whose root view is a TeamTimeViewController", ^{
                navController should be_instance_of([PunchHistoryNavigationController class]);
                navController.topViewController should be_instance_of([TeamTimeViewController class]);
            });

            it(@"should initialize the PunchHistoryNavigationController with the correct tab bar item and image", ^{
                UITabBarItem *tabBarItem = navController.tabBarItem;

                tabBarItem.title should equal(RPLocalizedString(PunchHistoryTabbarTitle, PunchHistoryTabbarTitle));
                tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_punchHistory"]);
            });
        });

        context(@"when configured with a approvals module", ^{
            __block SupervisorDashboardNavigationController *supervisorNavigationController;

            beforeEach(^{
                NSArray *viewControllers = [subject viewControllersForModules:@[APPROVAL_TAB_MODULE_NAME]];

                viewControllers.count should equal(1);

                supervisorNavigationController = viewControllers[0];
            });

            it(@"should add a navigation controller whose root view is a SupervisorDashboardController", ^{
                supervisorNavigationController should be_instance_of([SupervisorDashboardNavigationController class]);
                supervisorNavigationController.topViewController should be_same_instance_as(supervisorDashboardViewController);
            });

            it(@"should initialize the SupervisorDashboardNavigationController with the correct tab bar item and image", ^{
                UITabBarItem *tabBarItem = supervisorNavigationController.tabBarItem;

                tabBarItem.title should equal(RPLocalizedString(DashboardTabbarTitle, DashboardTabbarTitle));
                tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_dashboard"]);
            });
        });

        context(@"when configured with a shifts module", ^{
            beforeEach(^{
                NSArray *viewControllers = [subject viewControllersForModules:@[SCHEDULE_TAB_MODULE_NAME]];
                navController = viewControllers.firstObject;
            });

            it(@"should add a ShiftsNavigationController whose root view is a ShiftsViewController", ^{
                navController should be_instance_of([ShiftsNavigationController class]);
                navController.topViewController should be_instance_of([ShiftsViewController class]);
            });

            it(@"should initialize the ShiftsNavigationController with the correct tab bar item and image", ^{
                UITabBarItem *tabBarItem = navController.tabBarItem;

                tabBarItem.title should equal(RPLocalizedString(ShiftsTabbarTitle, ShiftsTabbarTitle));
                tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_schedule"]);
            });
        });



        context(@"when configured with a settings module", ^{
            beforeEach(^{
                NSArray *viewControllers = [subject viewControllersForModules:@[SETTINGS_TAB_MODULE_NAME]];
                navController = viewControllers.firstObject;
            });

            it(@"should add a SettingsNavigationController whose root view is a MoreViewController", ^{
                MoreViewController *moreViewController = (MoreViewController *)navController.topViewController;
                moreViewController should be_instance_of([MoreViewController class]);

                moreViewController.doorKeeper should be_same_instance_as(fakeDoorKeeper);
                moreViewController.launchLoginDelegate  should be_same_instance_as(launchLoginDelegate);
            });

            it(@"should initialize the TeamTimeNavigationController with the correct tab bar item and image", ^{
                UITabBarItem *tabBarItem = navController.tabBarItem;

                tabBarItem.title should equal(RPLocalizedString(MoreTabbarTitle, MoreTabbarTitle));
                tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_settings"]);
            });
        });

        context(@"when configured with an erroneous module name", ^{
            it(@"should ignore that module and order the tabs correctly", ^{
                NSArray *viewControllers = [subject viewControllersForModules:@[@"Bad_Module", TIMESHEETS_TAB_MODULE_NAME, SETTINGS_TAB_MODULE_NAME]];

                NSMutableArray *actualViewControllerClasses = [NSMutableArray array];
                for(UIViewController *viewController in viewControllers) {
                    [actualViewControllerClasses addObject:[viewController class]];
                }

                NSArray *expectedViewControllerClasses  = @[[TimesheetNavigationController class], [SettingsNavigationController class]];
                actualViewControllerClasses should equal(expectedViewControllerClasses);
            });
        });
        
        context(@"when configured with a Astro punch module with projects, clients and activity access", ^{
            
            context(@"when configured with a punch Widget module and no timesheet Assigned", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(NO);
                    NSArray *viewControllers = [subject viewControllersForModules:@[NEW_PUNCH_WIDGET_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });
                
                it(@"should be the correct type", ^{
                    navController should be_instance_of([NoTimeSheetAssignedViewController class]);
                });
                
                it(@"should initialize the PunchHomeController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;
                    
                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });

            context(@"when configured with a punch Widget module and timesheet Assigned", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(YES);
                    NSArray *viewControllers = [subject viewControllersForModules:@[WRONG_CONFIGURATION_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });
                
                it(@"should be the correct type", ^{
                    navController should be_instance_of([WrongConfigurationMessageViewController class]);
                });
                
                it(@"should initialize the WrongConfigurationMessageViewController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;
                    
                    tabBarItem.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_timesheets"]);
                });
            });

            context(@"when configured with a punch Widget module and timesheet Assigned and also has timesheet module", ^{
                beforeEach(^{
                    userPermissionsStorage  stub_method(@selector(hasTimesheetAccess)).and_return(YES);
                    NSArray *viewControllers = [subject viewControllersForModules:@[WRONG_CONFIGURATION_MODULE_NAME,TIMESHEETS_TAB_MODULE_NAME]];
                    navController = viewControllers.firstObject;
                });

                it(@"should be the correct type", ^{
                    navController should be_instance_of([WrongConfigurationMessageViewController class]);
                });

                it(@"should initialize the WrongConfigurationMessageViewController with the correct tab bar item title and image",^{
                    UITabBarItem *tabBarItem = navController.tabBarItem;

                    tabBarItem.title should equal(RPLocalizedString(AttendanceTabbarTitle, AttendanceTabbarTitle));
                    tabBarItem.image should equal([UIImage imageNamed:@"icon_tabBar_clockInOut"]);
                });
            });
        });
    });

    describe(@"getting module names for view controllers", ^{
        it(@"should return a list of module names for view controllers", ^{
            NSArray *modules = @[
                                 NEW_PUNCH_WIDGET_MODULE_NAME,
                                 TIMESHEETS_TAB_MODULE_NAME,
                                 SCHEDULE_TAB_MODULE_NAME,
                                 APPROVAL_TAB_MODULE_NAME,
                                 EXPENSES_TAB_MODULE_NAME,
                                 TIME_OFF_TAB_MODULE_NAME,
                                 SETTINGS_TAB_MODULE_NAME,
                                 CLOCK_IN_OUT_TAB_MODULE_NAME,
                                 PUNCH_HISTORY_TAB_MODULE_NAME,
                                 ];

            NSArray *viewControllers = [subject viewControllersForModules:modules];

            NSArray *translatedModules = [subject modulesForViewControllers:viewControllers];

            translatedModules should equal(modules);
        });
    });

});

SPEC_END
