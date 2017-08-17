//
//  RepliconServiceManager.m
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2RepliconServiceManager.h"

static G2LoginService *loginService = nil;
static G2ExpensesService *expensesService = nil;
static G2PermissionsService *permissionsService = nil;
static G2SupportDataService *supportDataService = nil;
static G2TimesheetService *timesheetService = nil;
static G2ApprovalsService *approvalsService = nil;
static G2AppDelegateService *appDelegateService = nil;
static G2LockedInOutTimesheetService *lockedInOutTimesheetService =nil;
@implementation G2RepliconServiceManager


+ (G2LoginService *)loginService{
	
  @synchronized(self) {
	if (loginService == nil) {
		loginService = [[G2LoginService alloc] init];
	}
  }
	return loginService;

}

+ (G2PermissionsService *)permissionsService{
	@synchronized(self) {
		if (permissionsService == nil) {
			permissionsService = [[G2PermissionsService alloc] init];
		}
	}
	return permissionsService;
}
+(G2SupportDataService*)supportDataService{
	@synchronized(self) {
		if (supportDataService == nil) {
			supportDataService = [[G2SupportDataService alloc] init];
		}
	}
	return supportDataService;
}
+ (G2ExpensesService *)expensesService{
	
	@synchronized(self) {
	  if (expensesService == nil) {
		expensesService = [[G2ExpensesService alloc] init];
	  }
	}
	return expensesService;
	
}

/*
 * This method creates timesheetService obj and returns the obj.
*/

+ (G2TimesheetService *)timesheetService
{
	@synchronized(self) {
		if (timesheetService == nil) {
			timesheetService = [[G2TimesheetService alloc] init];
		}
	}
	return timesheetService;
}

+ (G2LockedInOutTimesheetService *)lockedInOutTimesheetService
{
	@synchronized(self) {
		if (lockedInOutTimesheetService == nil) {
			lockedInOutTimesheetService = [[G2LockedInOutTimesheetService alloc] init];
		}
	}
	return lockedInOutTimesheetService;
}


+ (G2ApprovalsService *)approvalsService
{
	@synchronized(self) {
		if (approvalsService == nil) {
			approvalsService = [[G2ApprovalsService alloc] init];
		}
	}
	return approvalsService;
}

+ (G2AppDelegateService *)appDelegateService
{
	@synchronized(self) {
		if (appDelegateService == nil) {
			appDelegateService = [[G2AppDelegateService alloc] init];
		}
	}
	return appDelegateService;
}

@end
