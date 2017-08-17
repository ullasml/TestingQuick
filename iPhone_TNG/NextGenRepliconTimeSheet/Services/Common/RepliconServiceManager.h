//
//  RepliconServiceManager.h
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginService.h"
#import "TimesheetService.h"
#import "ApprovalsService.h"
#import "ExpenseService.h"
#import "TimeoffService.h"
#import "ShiftsService.h"
#import "TimesheetRequest.h"
#import "AttendanceService.h"
#import "TeamTimeService.h"
#import "PunchHistoryService.h"
#import "FreeTrialService.h"
#import "HRFreeTrialService.h"//HRTrial//JUHI
#import "CalculatePunchTotalService.h"

@interface RepliconServiceManager : NSObject {
    
}
+ (LoginService *)loginService;
+ (TimesheetService *)timesheetService;
+ (ApprovalsService *)approvalsService;
+ (ExpenseService*)expenseService;
+ (TimeoffService*)timeoffService;
+ (ShiftsService*)shiftsService;

+ (AttendanceService*)attendanceService;
+ (TeamTimeService*)teamTimeService;
+ (PunchHistoryService*)punchHistoryService;
+ (FreeTrialService*)freeTrialService;
+ (HRFreeTrialService*)HrFreeTrialService;//HRTrial//JUHI
+ (CalculatePunchTotalService *) calculatePunchTotalService;
+ (TimesheetRequest *) timesheetRequest;
+(void)resetTimesheetService;
+(void)resetExpenseService;


+ (void)resetTimeoffService;
@end
