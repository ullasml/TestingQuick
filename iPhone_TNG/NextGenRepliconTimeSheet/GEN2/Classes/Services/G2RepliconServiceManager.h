//
//  RepliconServiceManager.h
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2LoginService.h"
#import "G2SupportDataService.h"
#import "G2ExpensesService.h"
#import "G2PermissionsService.h"
#import "G2TimesheetService.h"
#import "G2ApprovalsService.h"
#import "G2AppDelegateService.h"
#import "G2LockedInOutTimesheetService.h"
@interface G2RepliconServiceManager : NSObject {

}
+ (G2LoginService *)loginService;
+ (G2PermissionsService *)permissionsService;
+(G2SupportDataService*)supportDataService;
+ (G2ExpensesService *)expensesService;
+ (G2TimesheetService *)timesheetService;
+ (G2LockedInOutTimesheetService *)lockedInOutTimesheetService;
+ (G2ApprovalsService *)approvalsService;
+ (G2AppDelegateService *)appDelegateService;
@end
