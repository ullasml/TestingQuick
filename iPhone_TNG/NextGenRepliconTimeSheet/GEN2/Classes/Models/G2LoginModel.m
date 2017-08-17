//
//  LoginModel.m
//  Replicon
//
//  Created by Devi Malladi on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2LoginModel.h"

static NSString *tableName = @"login";
static NSString *tablelicences = @"user_licences";
@implementation G2LoginModel

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		
	}
	return self;
}

- (void) insertUserInfoToDataBase:(NSArray *) userDetailsArray WithLoginPreferences:(NSMutableDictionary*)loginPreferencesDict {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSMutableDictionary *credentialDict =[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
	
	NSString *pwdEncripted=[G2Util encryptUserPassword:[credentialDict objectForKey:@"password"]];
	
	
	
	NSDictionary *startDateDict = [[[userDetailsArray objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"StartDate"];
	
	NSString *startDate =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:[[startDateDict objectForKey:@"Month"]intValue]],
						  [startDateDict objectForKey:@"Day"],
						  [startDateDict objectForKey:@"Year"]];
	
	NSDictionary *endDateDict =  [[[userDetailsArray objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"EndDate"];
	NSString *endDate =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:[[endDateDict objectForKey:@"Month"]intValue]],
						[endDateDict objectForKey:@"Day"],
						[endDateDict objectForKey:@"Year"]];
	
	
		//ravi - DON'T DELETE THIS. THIS FUNCTIONALITY WILL BE ENABLED LATER
	/*BOOL forcePasswordChangeStatus =[[[[userDetailsArray objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"ForcePasswordChange"]boolValue];
	 BOOL disablePasswordChangeStatus = [[[[userDetailsArray objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"DisablePasswordChange"]boolValue];
	 
	 NSNumber *forcePasswordChange,*disablePasswordChange;
	 
	 if (forcePasswordChangeStatus == NO) {
	 forcePasswordChange = [NSNumber numberWithInt:0];
	 }else {
	 forcePasswordChange = [NSNumber numberWithInt:1];
	 }
	 
	 if (disablePasswordChangeStatus == NO) {
	 disablePasswordChange = [NSNumber numberWithInt:0];
	 }else {
	 disablePasswordChange = [NSNumber numberWithInt:1];
	 }
	 
	 NSDictionary *passwordLastChangedDict = [[[userDetailsArray objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"PasswordLastChanged"];
	 NSString *passwordLastChanged =[NSString stringWithFormat:@"%@ %@, %@",[Util getMonthNameForMonthId:[[passwordLastChangedDict objectForKey:@"Month"]intValue]],
	 [passwordLastChangedDict objectForKey:@"Day"],
	 [passwordLastChangedDict objectForKey:@"Year"]];
	 */
	NSNumber *forcePasswordChange = [NSNumber numberWithInt:0];
	NSNumber *disablePasswordChange = [NSNumber numberWithInt:0];
		//NSNumber *rememberCompany	= [NSNumber numberWithInt:1];
		//NSNumber *rememberUser		= [NSNumber numberWithInt:1];
		//NSNumber *rememberPassword  = [NSNumber numberWithInt:1];
	NSString *passwordLastChanged = @"";
	NSDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
							  [credentialDict objectForKey:@"companyName"],@"company",
							  [[[userDetailsArray objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"LoginName"],@"login",
							  //[credentialDict objectForKey:@"password"],@"password",
							  pwdEncripted,@"password",
							  [NSNumber numberWithInt:1],@"id",
							  startDate,@"startDate",
							  endDate ,@"endDate",
							  passwordLastChanged,@"passwordLastChanged",
							  [[userDetailsArray objectAtIndex:0]objectForKey:@"Identity"],	@"identity",
							  forcePasswordChange,@"forcePasswordChange",
							  disablePasswordChange, @"disablePasswordChange",
							  [loginPreferencesDict objectForKey:@"rememberUser"],@"rememberUser",
							  [loginPreferencesDict objectForKey:@"rememberCompany"],@"rememberCompany",
							  [loginPreferencesDict objectForKey:@"rememberPassword"],@"rememberPassword",  
							  [loginPreferencesDict objectForKey:@"rememberPwdStartDate"],@"rememberPwdStartDate",
							  nil]; 
	[myDB insertIntoTable:tableName data:infoDict intoDatabase:@""];
    
    
    NSArray *modulesArray = [[[userDetailsArray objectAtIndex:0]objectForKey:@"Relationships"]objectForKey:@"ModuleGroups"];
    
    [myDB deleteFromTable:tablelicences inDatabase:@""];
    
    for (int i=0; i<[modulesArray count]; i++)
    {
        NSDictionary *valueDict=[modulesArray objectAtIndex:i];
        
        NSString *identity=[valueDict objectForKey:@"Identity"];
        NSString *name=[[valueDict objectForKey:@"Properties"]objectForKey:@"Name"];
        
        if (identity==nil)
        {
            identity=@"";
        }
        
        if (name==nil)
        {
            name=@"";
        }
        
       
        NSDictionary *moduleDict=[NSDictionary dictionaryWithObjectsAndKeys:identity,@"identity",name,@"licenceName", nil];
        [myDB insertIntoTable:tablelicences data:moduleDict intoDatabase:@""];
    }
    
}

- (void) insertUserInfoToDataBase:(NSArray *) userDetailsArray{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSMutableDictionary *credentialDict =[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
	
    if ([[credentialDict allKeys] count]==0)
    {
        credentialDict=[NSMutableDictionary dictionary];
        [credentialDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"SSOCompanyName"] forKey:@"companyName"];
         [credentialDict setObject:[[[userDetailsArray objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"StartDate"] forKey:@"Password"];

    }
    
	NSString *pwdEncripted=[G2Util encryptUserPassword:[credentialDict objectForKey:@"password"]];

	if (pwdEncripted==nil) 
    {
        pwdEncripted=@"";
    }
	
	NSDictionary *startDateDict = [[[userDetailsArray objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"StartDate"];
	
	NSString *startDate =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:[[startDateDict objectForKey:@"Month"]intValue]],
						  [startDateDict objectForKey:@"Day"],
						  [startDateDict objectForKey:@"Year"]];
	
	NSDictionary *endDateDict =  [[[userDetailsArray objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"EndDate"];
	NSString *endDate =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:[[endDateDict objectForKey:@"Month"]intValue]],
						  [endDateDict objectForKey:@"Day"],
						  [endDateDict objectForKey:@"Year"]];
	
	
	//ravi - DON'T DELETE THIS. THIS FUNCTIONALITY WILL BE ENABLED LATER
	/*BOOL forcePasswordChangeStatus =[[[[userDetailsArray objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"ForcePasswordChange"]boolValue];
	BOOL disablePasswordChangeStatus = [[[[userDetailsArray objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"DisablePasswordChange"]boolValue];
	
	NSNumber *forcePasswordChange,*disablePasswordChange;
	
	if (forcePasswordChangeStatus == NO) {
		forcePasswordChange = [NSNumber numberWithInt:0];
	}else {
		forcePasswordChange = [NSNumber numberWithInt:1];
	}

	if (disablePasswordChangeStatus == NO) {
		disablePasswordChange = [NSNumber numberWithInt:0];
	}else {
		disablePasswordChange = [NSNumber numberWithInt:1];
	}
	
	NSDictionary *passwordLastChangedDict = [[[userDetailsArray objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"PasswordLastChanged"];
	NSString *passwordLastChanged =[NSString stringWithFormat:@"%@ %@, %@",[Util getMonthNameForMonthId:[[passwordLastChangedDict objectForKey:@"Month"]intValue]],
						  [passwordLastChangedDict objectForKey:@"Day"],
						  [passwordLastChangedDict objectForKey:@"Year"]];
	*/
	NSNumber *forcePasswordChange = [NSNumber numberWithInt:0];
	NSNumber *disablePasswordChange = [NSNumber numberWithInt:0];
	NSNumber *rememberCompany	= [NSNumber numberWithInt:1];
	NSNumber *rememberUser		= [NSNumber numberWithInt:1];
	NSNumber *rememberPassword  = [NSNumber numberWithInt:5];
	NSString *passwordLastChanged = @"";
	NSDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
						  [credentialDict objectForKey:@"companyName"],@"company",
						  [[[userDetailsArray objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"LoginName"],@"login",
						  //[credentialDict objectForKey:@"password"],@"password",
							  pwdEncripted,@"password",
						  [NSNumber numberWithInt:1],@"id",
							  startDate,@"startDate",
							  endDate ,@"endDate",
							  passwordLastChanged,@"passwordLastChanged",
						  [[userDetailsArray objectAtIndex:0]objectForKey:@"Identity"],	@"identity",
						 forcePasswordChange,@"forcePasswordChange",
						  disablePasswordChange, @"disablePasswordChange",
							rememberUser,@"rememberUser",
							rememberCompany,@"rememberCompany",
							rememberPassword,@"rememberPassword", 
							  [NSDate date],@"rememberPwdStartDate",
						  nil];
    
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[[[userDetailsArray objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"LoginName"] forKey:@"SSOLoginName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
	[myDB insertIntoTable:tableName data:infoDict intoDatabase:@""];
	
    
    NSArray *modulesArray = [[[userDetailsArray objectAtIndex:0]objectForKey:@"Relationships"]objectForKey:@"ModuleGroups"];
    
    [myDB deleteFromTable:tablelicences inDatabase:@""];
    
    for (int i=0; i<[modulesArray count]; i++)
    {
        NSDictionary *valueDict=[modulesArray objectAtIndex:i];
        
        NSString *identity=[valueDict objectForKey:@"Identity"];
        NSString *name=[[valueDict objectForKey:@"Properties"]objectForKey:@"Name"];
        
        if (identity==nil)
        {
            identity=@"";
        }
        
        if (name==nil)
        {
            name=@"";
        }
        
        
        NSDictionary *moduleDict=[NSDictionary dictionaryWithObjectsAndKeys:identity,@"identity",name,@"licenceName", nil];
        [myDB insertIntoTable:tablelicences data:moduleDict intoDatabase:@""];
    }


}

-(void)deleteUserInfoFromDatabase{
} 


-(void)updateChangePasswordFlagManually
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *query = [NSString stringWithFormat:@"update  login set forcePasswordChange = 0"];
	[myDB executeQuery:query];
	
}

-(NSMutableArray *) fetchLoginDetails: (NSString *)uName pwd: (NSString *) pwd companyName:(NSString*)cmpName;
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	//NSString *whereString = [NSString stringWithFormat:@"login='%@' and company='%@' and password='%@'", uName,cmpName, pwd];
	//NSMutableArray *loginDetails = [myDB select:@"*" from: tableName where: whereString intoDatabase:@""];
	NSString *query = [NSString stringWithFormat:@" select * from login where  login='%@' and company='%@' and password='%@' ",[uName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ],[cmpName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ], [pwd stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSMutableArray *loginDetails = [myDB executeQueryToConvertUnicodeValues:query];
	
	if(loginDetails == nil || [loginDetails count] != 1)
		return nil;
	
	return loginDetails;
}


-(NSMutableArray*)getAllUserInfoFromDb
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *query = [NSString stringWithFormat:@" select * from login"];
	NSMutableArray *loginUserData = [myDB executeQueryToConvertUnicodeValues:query];
	
	if(loginUserData == nil || [loginUserData count] != 1)
		return nil;
	
	return loginUserData;
}



-(void)getDBPathForDeletion
{
NSString* docDir = [G2Util getDocumentDirectoryWithMask:NSUserDomainMask expandTilde:YES];
appProperties = [G2AppProperties getInstance];
	
NSString *dbPath = [NSString stringWithFormat:@"%@%@",docDir,[appProperties getAppPropertyFor:@"DatabasePath"]];
NSString *dbName = [appProperties getAppPropertyFor:@"DatabaseName"];



if(dbPath == nil)
dbPath = @"/tmp/";

else if(dbName == nil)
dbName = @"replicon";
BOOL dbExists = [G2SQLiteDB databaseExists:dbName atPath:dbPath];

if(dbExists == YES) {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:dbPath error:NULL];
}
}


-(void)flushDBInfoForOldUser :(BOOL)deleteLogin
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
		if (deleteLogin) {
			[myDB deleteFromTable:@"login" inDatabase:@""];
		}
		
		[myDB deleteFromTable:@"systemPaymentMethods" inDatabase:@""];
		[myDB deleteFromTable:@"systemCurrencies" inDatabase:@""];
		[myDB deleteFromTable:@"userPreferences" inDatabase:@""];
		[myDB deleteFromTable:@"projects" inDatabase:@""];
		[myDB deleteFromTable:@"clients" inDatabase:@""];
		[myDB deleteFromTable:@"expense_entries" inDatabase:@""];
		[myDB deleteFromTable:@"userPermissions" inDatabase:@""];
		[myDB deleteFromTable:@"expenseTypes" inDatabase:@""];
		[myDB deleteFromTable:@"baseCurrency" inDatabase:@""];
		[myDB deleteFromTable:@"systemPreferences" inDatabase:@""];
		[myDB deleteFromTable:@"udfDropDownOptions" inDatabase:@""];
		[myDB deleteFromTable:@"userDefinedFields" inDatabase:@""];
		[myDB deleteFromTable:@"taxCodes" inDatabase:@""];
		[myDB deleteFromTable:@"entry_udfs" inDatabase:@""];
		[myDB deleteFromTable:@"expense_sheets" inDatabase:@""];
		[myDB deleteFromTable:@"timesheets" inDatabase:@""];
		[myDB deleteFromTable:@"time_entries" inDatabase:@""];
		[myDB deleteFromTable:@"user_activites" inDatabase:@""];
		[myDB deleteFromTable:@"timeOff_codes" inDatabase:@""];
		[myDB deleteFromTable:@"project_tasks" inDatabase:@""];
		[myDB deleteFromTable:@"project_billingOptions" inDatabase:@""];
		[myDB deleteFromTable:@"booked_time_off_entries" inDatabase:@""];
		[myDB deleteFromTable:@"timeOffBookings" inDatabase:@""];
		[myDB updateColumnFromTable:@"lastSyncDate" fromTable:@"dataSyncDetails" withString:@"null" inDatabase:@""];
        [myDB deleteFromTable:@"punchclock_time_entries" inDatabase:@""];
    [myDB deleteFromTable:@"approvals_timesheets" inDatabase:@""];
    [myDB deleteFromTable:@"approvals_time_entries" inDatabase:@""];
    [myDB deleteFromTable:@"approvals_entry_udfs" inDatabase:@""];
    [myDB deleteFromTable:@"approvals_userPermissions" inDatabase:@""];
    [myDB deleteFromTable:@"approvals_userDefinedFields" inDatabase:@""];
    [myDB deleteFromTable:@"approvals_user_activities" inDatabase:@""];
    [myDB deleteFromTable:@"approvals_udfDropDownOptions" inDatabase:@""];
    [myDB deleteFromTable:@"approvals_userPreferences" inDatabase:@""];
    [myDB deleteFromTable:@"approvals_booked_time_off_entries" inDatabase:@""];
    [myDB deleteFromTable:@"user_licences" inDatabase:@""];
    [myDB deleteFromTable:@"user_licences" inDatabase:@""];
    [myDB deleteFromTable:@"disclaimers" inDatabase:@""];
    [myDB deleteFromTable:@"disclaimers" inDatabase:@""];
    [myDB deleteFromTable:@"mealBreaks_entries" inDatabase:@""];
    [myDB deleteFromTable:@"approvals_mealBreaks_entries" inDatabase:@""];
    [myDB deleteFromTable:@"expense_Project_Type" inDatabase:@""];

	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"expenseSheetsArray"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"expenseEntriesArray"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SELECTED_EXPENSE_ENTRY"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"expensePermissionFlag"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimeSheetProjectPermissionType"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"approvalsexpensePermissionFlag"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"approvalsTimeSheetProjectPermissionType"];
  
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimeSheetQueryHandler"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ApprovalTimeSheetQueryHandler"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:TIMESHEET_FETCH_START_INDEX];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:APPROVAL_TIMESHEET_FETCH_START_INDEX];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:APPROVAL_LAST_DOWNLOADED_TIMESHEETS_COUNT];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:APPROVAL_RECENT_DOWNLOADED_TIMESHEETS_COUNT];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NumberOfTimeSheets"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"nextRecentResponseCount"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"QueryHandler"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:APPROVAL_QUERY_HANDLE];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastDownloadedSheetsCount"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:UNSUBMITTED_TIME_SHEETS];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:UNSUBMITTED_EXPENSE_SHEETS];
     [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"isSuccessLogin"];
    
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"updateRecentTimeSheetsDone"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
   
    NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:[documentsDirectory stringByAppendingFormat:@"/log.txt"] error:NULL];
}

@end
