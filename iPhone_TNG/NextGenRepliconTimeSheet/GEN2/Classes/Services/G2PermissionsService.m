//
//  PermissionsService.m
//  Replicon
//
//  Created by Devi Malladi on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2PermissionsService.h"
#import "RepliconAppDelegate.h"

@implementation G2PermissionsService

- (id) init
{
	self = [super init];
	if (self != nil) {
		baseService=[G2BaseService new];
		if (permissionsModel == nil) {
			permissionsModel = [[G2PermissionsModel alloc] init];
		}
	}
	return self;
}


/*-(void)sendRequestToGetAllUserPermissionsWithDelegate:(id)delegate{

	
{
"Action": "CheckUserPermissions",
"Permissions": [
				"UseTimesheet",
				"ProjectExpense",
				"NonProjectExpense",
				"TimeOffBookingUser",
				]
}*/

 /*/* NSArray *permissionsArray = [NSArray arrayWithObjects:@"UseTimesheet",@"ProjectExpense",@"NonProjectExpense",@"TimeOffBookingUser",@"UnsubmitExpense",nil];
  NSDictionary *mainDict = [NSDictionary dictionaryWithObjectsAndKeys:@"CheckUserPermissions",@"Action"
						  ,permissionsArray,@"Permissions"
						  ,nil];
  NSError *err = nil;
  NSString *str = [JsonWrapper writeJson:mainDict error:&err];
  DLog(@"checkpermissions %@",str);

NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
[paramDict setObject:str forKey:@"PayLoadStr"];

[self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
[self setServiceID:[ServiceUtil getServiceIDForServiceName:@"CheckUserPermissions"]];
[self setServiceDelegate:delegate];
[self executeRequest];


}*/
/**
 *Above query modified in order to get the 
 *permission set for all the modules instead of only expenses
 **/

-(void)sendRequestToGetAllUserPermissionsWithDelegate{
	
	/*{
	 "Action": "CheckUserPermissions",
	 "Permissions": [
	 "UseTimesheet",
	 "ProjectExpense",
	 "ClassicTimesheet",
	 "LockedInOutTimesheet",
	 "InOutTimesheet",
	 "TimeoffTimesheet",
	 "UnsubmitTimesheet",
	 "NonProjectExpense",
	 "NewTimesheet",
	 "TimeOffBookingUser",
	 "EditFutureTimeOffBookingUser",
	 "ProjectTimesheet",
	 "NonProjectTimesheet",
	 "BillingTimesheet",
	 "AllowBlankTimesheetComments",
	 "AllowBlankResubmitComment",
	 "TimesheetEntryUDF1",
	 "TimesheetEntryUDF2",
	 "TimesheetEntryUDF3",
	 "TimesheetEntryUDF4",
	 "TimesheetEntryUDF5",
	 "ReportPeriodUDF1",
	 "ReportPeriodUDF2",
	 "ReportPeriodUDF3",
	 "ReportPeriodUDF4",
	 "ReportPeriodUDF5",
	 "TimeOffUDF1",
	 "TimeOffUDF2",
	 "TimeOffUDF3",
	 "TimeOffUDF4",
	 "TimeOffUDF5"
	 
	 ]
	 }*/
	
	NSMutableArray *permissionsArray = [NSMutableArray arrayWithObjects:
										@"UseTimesheet",
										@"ProjectExpense",
										@"ClassicTimesheet",
										@"LockedInOutTimesheet",
										@"InOutTimesheet",
                                        @"NewInOutTimesheet",
                                        @"RequireDisclaimerAcceptance",
                                        @"ShowTimesheetDisclaimer",
										@"TimeoffTimesheet",
										@"UnsubmitTimesheet",
										@"UnsubmitExpense",
										@"NonProjectExpense",
										@"NewTimesheet",
										@"TimeOffBookingUser",
										@"EditFutureTimeOffBookingUser",
										@"ProjectTimesheet",
										@"NonProjectTimesheet",
										@"BillingTimesheet",
										@"AllowBlankTimesheetComments",
										@"AllowBlankResubmitComment",
                                        @"AllowBlankResubmitExpenseComment",//US2669
                                        @"ApproverAllowBlankRejectComment",
                                        @"ApprovalMenu",
										@"TimesheetEntryUDF1",
										@"TimesheetEntryUDF2",
										@"TimesheetEntryUDF3",
										@"TimesheetEntryUDF4",
										@"TimesheetEntryUDF5",
										@"ReportPeriodUDF1",
										@"ReportPeriodUDF2",
										@"ReportPeriodUDF3",
										@"ReportPeriodUDF4",
										@"ReportPeriodUDF5",
										@"TimeOffUDF1",
										@"TimeOffUDF2",
										@"TimeOffUDF3",
										@"TimeOffUDF4",
										@"TimeOffUDF5",
										@"TimesheetActivityRequired",
                                        @"TimesheetDisplayActivities",
										@"TaskTimesheetUDF1",
										@"TaskTimesheetUDF2",
										@"TaskTimesheetUDF3",
										@"TaskTimesheetUDF4",
                                        @"TaskTimesheetUDF5",
										@"MobileLockedInOutTimesheet",@"ReopenTimesheet",nil];//Us4660//Juhi
	NSDictionary *permissionsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"CheckUserPermissions",@"Action"
							  ,permissionsArray,@"Permissions"
							  ,nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:permissionsDict error:&err];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[baseService setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[baseService setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"CheckUserPermissions"]];
	[baseService setServiceDelegate:self];
	[baseService executeRequest];
}

-(void)handleUserPermissonsResponse:(id)response{
	if (response!=nil && [(NSMutableArray *)response count]!=0) {
			[permissionsModel insertUserPermissionsInToDataBase:response];
			[permissionsModel getUserPermissions];
		//Added
		NSMutableArray   *enabledPermissions = [permissionsModel getAllEnabledUserPermissions];
		
		BOOL projectTimeSheet     = [enabledPermissions containsObject:@"ProjectTimesheet"];
		BOOL nonProjectTimeSheet  = [enabledPermissions containsObject:@"NonProjectTimesheet"];
		
		
		BOOL projectExpense     = [enabledPermissions containsObject:@"ProjectExpense"];
		BOOL nonProjectExpense  = [enabledPermissions containsObject:@"NonProjectExpense"];
		
		
		NSString *expensePermission=nil;
		if (projectExpense == YES && nonProjectExpense == YES) {
			expensePermission = BOTH;
		}else if(projectExpense == YES && nonProjectExpense == NO){
			expensePermission = PROJECT_SPECIFIC;
		}else if(projectExpense == NO && nonProjectExpense == YES) {
			expensePermission = NON_PROJECT_SPECIFIC;
		}
		
		
		NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
		if (expensePermission!=nil && ![expensePermission isKindOfClass:[NSNull class]]) {
			[standardUserDefaults setObject:expensePermission forKey:@"expensePermissionFlag"];	
            [standardUserDefaults synchronize];
		}
		//NSString *_projPermissionType = [standardUserDefaults objectForKey:@"expensePermissionFlag"];
		
		
		NSString *permissionType  = @"";
		
		//DLog(@"handleUserPermissonsResponse %@",enabledPermissions);
		
		if (projectTimeSheet == YES && nonProjectTimeSheet == YES) {
			permissionType = BOTH;
		}else if(projectTimeSheet == YES && nonProjectTimeSheet == NO){
			permissionType = AGAINSTPROJECT;
		}else if(projectTimeSheet == NO && nonProjectTimeSheet == YES) {
			permissionType = WITHOUT_REQUIRING_PROJECT;
		}
		[[NSUserDefaults standardUserDefaults] setObject:permissionType 
												  forKey:@"TimeSheetProjectPermissionType"];
        [standardUserDefaults synchronize];
		
//			[[NSNotificationCenter defaultCenter] 
//			 postNotificationName:USER_PERMISSIONS_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:FALSE] forKey:@"value"]];
	}else {
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	}
	
	
}

#pragma mark ServiceURL Response Handling

- (void) serverDidRespondWithResponse:(id) response{
	if (response!=nil) {
		NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		NSNumber *serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
		if ([status isEqualToString:@"OK"]) {		  
			if ([serviceID intValue] == CheckUserPermissions_ServiceID_2) {
				[self handleUserPermissonsResponse:[[response objectForKey:@"response"]objectForKey:@"Value"]];
			}
		}
	}
}
- (void) serverDidFailWithError:(NSError *) error{
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		[G2Util showOfflineAlert];
		return;
	}
    [self showErrorAlert:error];
	
	return;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==SAML_SESSION_TIMEOUT_TAG)
    {
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchWebViewController)];
    }
}

-(void)showErrorAlert:(NSError *) error
{
    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED]) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {
            UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED)
                                                                      delegate:self cancelButtonTitle:RPLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
            [confirmAlertView setDelegate:self];
            [confirmAlertView setTag:-SAML_SESSION_TIMEOUT_TAG];
            [confirmAlertView show];
            
        }
        else 
        {
             [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED) ];
        }
        
    }
    else  if ([appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) {
        [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(G2PASSWORD_EXPIRED, G2PASSWORD_EXPIRED) ];
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
    }
    else
    {
        [G2Util errorAlert:RPLocalizedString( @"Connection failed",@"") errorMessage:[error localizedDescription]];
    }
}


@end
