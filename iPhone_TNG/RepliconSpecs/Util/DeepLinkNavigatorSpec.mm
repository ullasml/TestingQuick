#import <Cedar/Cedar.h>
#import "NextGenRepliconTimeSheet-Swift.h"
#import "ExpensesNavigationController.h"
#import "TimesheetNavigationController.h"
#import "BookedTimeOffNavigationController.h"
#import "ShiftsNavigationController.h"
#import "SupervisorDashboardNavigationController.h"
using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(DeepLinkNavigatorSpec)

describe(@"DeepLinkNavigator", ^{
    __block DeepLinkNavigator *subject;
    __block ModuleStorage *moduleStorage;
    __block AppDelegate *appDelegate;
    __block UITabBarController *tabBarController;
    beforeEach(^{
        moduleStorage = nice_fake_for([ModuleStorage class]);
        tabBarController = nice_fake_for([UITabBarController class]);
        UIWindow *window = [[UIWindow alloc] init];
        window.rootViewController = tabBarController;
        appDelegate = nice_fake_for([AppDelegate class]);
        appDelegate stub_method(@selector(window)).and_return(window);
        subject = [[DeepLinkNavigator alloc] initWithAppdelegate:appDelegate];
    });
    
    describe(@"Timesheet Shortcut", ^{
        __block BOOL success;
        __block ListOfTimeSheetsViewController *timesheet;
        beforeEach(^{
            UINavigationController *navigationController = nice_fake_for([TimesheetNavigationController class]);
            timesheet =  nice_fake_for([ListOfTimeSheetsViewController class]);
            navigationController stub_method(@selector(viewControllers)).and_return(@[timesheet]);
            tabBarController stub_method(@selector(viewControllers)).and_return(@[navigationController]);
            tabBarController stub_method(@selector(selectedViewController)).and_return(navigationController);
            moduleStorage stub_method(@selector(modules)).and_return(@[@"Timesheets_Module"]);
            appDelegate stub_method(@selector(moduleStorage)).and_return(moduleStorage);
            success = [subject proceedToDeeplink:DeeplinkTypeTimeSheet];
            
        });
        
        it(@"should navigate to timesheet screen and return true", ^{
            success should be_truthy;
            timesheet should have_received(@selector(launchCurrentTimeSheet));
        });
    });
    
    describe(@"Expense Shortcut", ^{
        __block BOOL success;
        __block ListOfExpenseSheetsViewController *expense;
        beforeEach(^{
            UINavigationController *navigationController = nice_fake_for([ExpensesNavigationController class]);
            expense =  nice_fake_for([ListOfExpenseSheetsViewController class]);
            navigationController stub_method(@selector(viewControllers)).and_return(@[expense]);
            tabBarController stub_method(@selector(viewControllers)).and_return(@[navigationController]);
            tabBarController stub_method(@selector(selectedViewController)).and_return(navigationController);
            moduleStorage stub_method(@selector(modules)).and_return(@[@"Expenses_Module"]);
            appDelegate stub_method(@selector(moduleStorage)).and_return(moduleStorage);
            success = [subject proceedToDeeplink:DeeplinkTypeExpense];

        });
        
        it(@"should navigate to expense screen and return true", ^{
            success should be_truthy;
            expense should have_received(@selector(addExpenseSheetAction:));
        });
    });
    
    describe(@"Login Shortcut", ^{
        __block BOOL success;
        beforeEach(^{
            moduleStorage stub_method(@selector(modules)).and_return(@[]);
            appDelegate stub_method(@selector(moduleStorage)).and_return(moduleStorage);
            appDelegate stub_method(@selector(launchLoginViewController:)).and_with(NO);
            success = [subject proceedToDeeplink:DeeplinkTypeLogin];
        });
        
        it(@"should navigate to login screen and return true", ^{
            success should be_truthy;
            appDelegate should have_received(@selector(launchLoginViewController:));
        });
    });
    
    describe(@"TimeOff Shortcut", ^{
        __block BOOL success;
        __block ListOfBookedTimeOffViewController *timeoff;
        beforeEach(^{
            UINavigationController *navigationController = nice_fake_for([BookedTimeOffNavigationController class]);
            timeoff =  nice_fake_for([ListOfBookedTimeOffViewController class]);
            navigationController stub_method(@selector(viewControllers)).and_return(@[timeoff]);
            tabBarController stub_method(@selector(viewControllers)).and_return(@[navigationController]);
            tabBarController stub_method(@selector(selectedViewController)).and_return(navigationController);
            moduleStorage stub_method(@selector(modules)).and_return(@[@"BookedTimeOff_Module"]);
            appDelegate stub_method(@selector(moduleStorage)).and_return(moduleStorage);
            success = [subject proceedToDeeplink:DeeplinkTypeTimeOff];
            
        });
        
        it(@"should navigate to timeoff screen and return true", ^{
            success should be_truthy;
            timeoff should have_received(@selector(launchBookTimeOff));
        });
    });
    
    describe(@"Shift Shortcut", ^{
        __block BOOL success;
        __block ShiftsViewController *shift;
        beforeEach(^{
            UINavigationController *navigationController = nice_fake_for([ShiftsNavigationController class]);
            shift =  nice_fake_for([ShiftsViewController class]);
            navigationController stub_method(@selector(viewControllers)).and_return(@[shift]);
            tabBarController stub_method(@selector(viewControllers)).and_return(@[navigationController]);
            tabBarController stub_method(@selector(selectedViewController)).and_return(navigationController);
            moduleStorage stub_method(@selector(modules)).and_return(@[@"Shifts_Module"]);
            appDelegate stub_method(@selector(moduleStorage)).and_return(moduleStorage);
            success = [subject proceedToDeeplink:DeeplinkTypeShift];
            
        });
        
        it(@"should navigate to shift screen and return true", ^{
            success should be_truthy;
            shift should have_received(@selector(launchCurrentShift));
        });
    });
    
    describe(@"Approval Shortcut", ^{
        __block BOOL success;
        __block SupervisorDashboardController *dashboard;
        beforeEach(^{
            UINavigationController *navigationController = nice_fake_for([SupervisorDashboardNavigationController class]);
            dashboard =  nice_fake_for([SupervisorDashboardController class]);
            navigationController stub_method(@selector(viewControllers)).and_return(@[dashboard]);
            tabBarController stub_method(@selector(viewControllers)).and_return(@[navigationController]);
            tabBarController stub_method(@selector(selectedViewController)).and_return(navigationController);
            moduleStorage stub_method(@selector(modules)).and_return(@[@"Approvals_Module"]);
            appDelegate stub_method(@selector(moduleStorage)).and_return(moduleStorage);
            success = [subject proceedToDeeplink:DeeplinkTypeTimesheetApproval];
            
        });
        
        it(@"should navigate to approval screen and return true", ^{
            success should be_truthy;
            dashboard should have_received(@selector(selectApprovalsForModule:));
        });
    });
    
});

SPEC_END
