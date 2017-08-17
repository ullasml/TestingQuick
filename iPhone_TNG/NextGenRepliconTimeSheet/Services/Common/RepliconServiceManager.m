#import "RepliconServiceManager.h"
#import "TabModuleNameProvider.h"
#import "AppDelegate.h"


#import "RepliconServiceManager.h"
#import "AstroUserDetector.h"
#import "MobileMonitorURLProvider.h"
#import <Blindside/Blindside.h>
#import <repliconkit/AppConfig.h>

static LoginService *loginService = nil;
static TimesheetService *timesheetService = nil;
static ApprovalsService *approvalsService=nil;
static ExpenseService *expenseService=nil;
static TimeoffService *timeoffService=nil;

static ShiftsService *shiftsService=nil;
static AttendanceService *attendanceService=nil;
static TeamTimeService *teamTimeService=nil;
static PunchHistoryService *punchHistoryService=nil;
static FreeTrialService *freeTrialService=nil;
static HRFreeTrialService *HrFreeTrialService=nil;
static CalculatePunchTotalService *calculatePunchTotalService=nil;
static TimesheetRequest *timesheetRequest=nil;

@implementation RepliconServiceManager

+ (LoginService *)loginService{

    @synchronized(self) {
        if (loginService == nil) {

            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            AstroUserDetector *astroUserDetector = [[AstroUserDetector alloc]init];
            TabModuleNameProvider *tabModuleNameProvider = [[TabModuleNameProvider alloc] initWithAstroUserDetector:astroUserDetector];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            MobileMonitorURLProvider *mobileMonitorURLProvider = [[MobileMonitorURLProvider alloc] initWithUserDefaults:userDefaults];
            AppConfig *appConfig = [appDelegate.injector getInstance:[AppConfig class]];

            loginService = [[LoginService alloc] initWithTabModuleNameProvider:tabModuleNameProvider
                                                                  userDefaults:userDefaults
                                                               spinnerDelegate:appDelegate
                                                           homeSummaryDelegate:appDelegate
                                                                   appDelegate:appDelegate
                                                      mobileMonitorURLProvider:mobileMonitorURLProvider
                                                                     appConfig:appConfig];
        }
    }
	return loginService;

}

+ (TimesheetService *)timesheetService
{
	@synchronized(self) {
		if (timesheetService == nil) {
            id<SpinnerDelegate> appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
			timesheetService = [[TimesheetService alloc] initWithSpinnerDelegate:appDelegate];
		}
	}
	return timesheetService;
}

+(void)resetTimesheetService
{
    timesheetService=nil;
}

+ (ApprovalsService *)approvalsService
{
    @synchronized(self) {
		if (approvalsService == nil) {
			approvalsService = [[ApprovalsService alloc] init];
		}
	}
	return approvalsService;
}
+(ExpenseService*)expenseService{
    @synchronized(self) {
		if (expenseService == nil) {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
			expenseService = [[ExpenseService alloc] initWithSpinnerDelegate:appDelegate];
		}
	}
	return expenseService;
}

+(void)resetExpenseService
{
    expenseService=nil;
}


+(TimeoffService*)timeoffService{
    @synchronized(self) {
		if (timeoffService == nil) {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            timeoffService = [[TimeoffService alloc] initWithSpinnerDelegate:appDelegate];
		}
	}
	return timeoffService;
}

+ (void)resetTimeoffService {
    timeoffService = nil;
}

+(ShiftsService*)shiftsService{
    @synchronized(self) {
		if (shiftsService == nil) {
			shiftsService = [[ShiftsService alloc] init];
		}
	}
	return shiftsService;
}
+(AttendanceService*)attendanceService{
    @synchronized(self) {
		if (attendanceService == nil) {
			attendanceService = [[AttendanceService alloc] init];
		}
	}
	return attendanceService;
}
+ (TeamTimeService *)teamTimeService{

    @synchronized(self) {
        if (teamTimeService == nil) {
            teamTimeService = [[TeamTimeService alloc] init];
        }
    }
	return teamTimeService;

}

+ (PunchHistoryService*)punchHistoryService{

    @synchronized(self) {
        if (punchHistoryService == nil) {
            punchHistoryService = [[PunchHistoryService alloc] init];
        }
    }
	return punchHistoryService;

}

+(FreeTrialService*)freeTrialService{
    @synchronized(self) {
		if (freeTrialService == nil) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            MobileMonitorURLProvider *mobileMonitorURLProvider = [[MobileMonitorURLProvider alloc] initWithUserDefaults:userDefaults];
            AppConfig *appConfig = [appDelegate.injector getInstance:[AppConfig class]];
            
            
			freeTrialService = [[FreeTrialService alloc] initWithMobileMonitorURLProvider:mobileMonitorURLProvider appConfig:appConfig];
		}
	}
	return freeTrialService;
}
//HRTrial//JUHI
+(HRFreeTrialService*)HrFreeTrialService{
    @synchronized(self) {
		if (HrFreeTrialService == nil) {
			HrFreeTrialService = [[HRFreeTrialService alloc] init];
		}
	}
	return HrFreeTrialService;
}

+(CalculatePunchTotalService *)calculatePunchTotalService{
    @synchronized(self) {
        if (calculatePunchTotalService == nil) {
            calculatePunchTotalService = [[CalculatePunchTotalService alloc] init];
        }
    }
    return calculatePunchTotalService;
}

+ (TimesheetRequest *)timesheetRequest{
    
    @synchronized(self) {
        if (timesheetRequest == nil) {
            timesheetRequest = [[TimesheetRequest alloc] init];
        }
    }
    return timesheetRequest;
    
}

@end
