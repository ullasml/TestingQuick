//
//  LoginModel.m
//  Replicon
//
//  Created by Devi Malladi on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginModel.h"
#import "AppDelegate.h"
#import <repliconkit/repliconkit.h>


static NSString *userDetailsTable =@"userDetails";
static NSString *newUserDetailsTable =@"newuserDetails";
static NSString *userDeFinedFieldsTable =@"userDefinedFields";
static NSString *userDeFinedFieldsCloneTable =@"userDefinedFieldsClone";
static NSString *udfDropDownOptionsTable=@"UdfDropDownOptions";
static NSString *oefDropDownTagOptionsTable=@"OEFDropDownTagOptions";

@implementation LoginModel

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		
	}
	return self;
}

-(NSMutableArray*)getAllUserDetailsInfoFromDb
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query = [NSString stringWithFormat:@" select * from %@",userDetailsTable];
	NSMutableArray *userDetails = [myDB executeQueryToConvertUnicodeValues:query];
	
	if(userDetails == nil || [userDetails count] != 1)
		return nil;
	return userDetails;
}

-(NSString *)getUserUriInfoFromDb
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select * from %@",userDetailsTable];
    NSMutableArray *userDetails = [myDB executeQueryToConvertUnicodeValues:query];
    NSString *userUri = nil;
    if(userDetails != nil && userDetails!=(id)[NSNull null])
    {
        CLS_LOG(@"-------print userDetails :%@", userDetails);
        if(userDetails.count>=1)
        {
            userUri = [[userDetails objectAtIndex:0] objectForKey:@"uri"];
        }
    }
    CLS_LOG(@"-------print userUri from DB :%@", userUri);
    return userUri;
}

-(NSMutableArray*)getAllNewUserDetailsInfoFromDb
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select * from %@",newUserDetailsTable];
    NSMutableArray *userDetails = [myDB executeQueryToConvertUnicodeValues:query];
    
    if(userDetails == nil || [userDetails count] != 1)
        return nil;
    return userDetails;
}


-(void)flushDBInfoForOldUser :(BOOL)deleteLogin
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
   
    [myDB deleteFromTable:@"userDetails" inDatabase:@""];
    [myDB deleteFromTable:@"newuserDetails" inDatabase:@""];
    [myDB deleteFromTable:@"Timesheets" inDatabase:@""];
    [myDB deleteFromTable:@"TimesheetProjectSummary" inDatabase:@""];
    [myDB deleteFromTable:@"TimesheetPayrollSummary" inDatabase:@""];
    [myDB deleteFromTable:@"TimesheetDaySummary" inDatabase:@""];
    [myDB deleteFromTable:@"TimesheetBillingSummary" inDatabase:@""];
    [myDB deleteFromTable:@"TimesheetApproverSummary" inDatabase:@""];
    [myDB deleteFromTable:@"TimeoffTypes" inDatabase:@""];
    [myDB deleteFromTable:@"Disclaimer" inDatabase:@""];
    [myDB deleteFromTable:@"TimesheetActivitySummary" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalTimesheets" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalExpensesheets" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalTimeOffs" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalTimesheets" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalExpensesheets" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalTimeOffs" inDatabase:@""];
    [myDB deleteFromTable:@"Clients" inDatabase:@""];
    [myDB deleteFromTable:@"Projects" inDatabase:@""];
    [myDB deleteFromTable:@"Time_entries" inDatabase:@""];
    [myDB deleteFromTable:@"TimesheetPermittedApprovalActions" inDatabase:@""];
    [myDB deleteFromTable:@"ExpensePermittedApprovalActions" inDatabase:@""];
    [myDB deleteFromTable:@"ExpenseSheets" inDatabase:@""];
    [myDB deleteFromTable:@"ExpenseEntries" inDatabase:@""];
    [myDB deleteFromTable:@"ExpenseIncurredAmountTax" inDatabase:@""];
    [myDB deleteFromTable:@"SystemCurrencies" inDatabase:@""];
    [myDB deleteFromTable:@"SystemPaymentMethods" inDatabase:@""];
    [myDB deleteFromTable:@"ExpenseCodes" inDatabase:@""];
    [myDB deleteFromTable:@"TimesheetApproverHistory" inDatabase:@""];
    [myDB deleteFromTable:@"Timeoff" inDatabase:@""];
    [myDB deleteFromTable:@"TimeOffBalanceSummaryMultiDayBooking" inDatabase:@""];
    [myDB deleteFromTable:@"CompanyHolidays" inDatabase:@""];
    [myDB deleteFromTable:@"TimeoffTypeBalanceSummary" inDatabase:@""];
    [myDB deleteFromTable:@"BookedTimeoffTypes" inDatabase:@""];
    [myDB deleteFromTable:@"UdfDropDownOptions" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalTimesheetDaySummary" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalTimesheetProjectSummary" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalTimesheetActivitySummary" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalTimesheetBillingSummary" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalTimesheetPayrollSummary" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalTimesheetCustomFields" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalTimeEntries" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalTimesheetApproverHistory" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalDisclaimer" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalTimeoffEntries" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalTimeoffCustomFields" inDatabase:@""];
    [myDB deleteFromTable:@"ExpenseCodeDetails" inDatabase:@""];
    [myDB deleteFromTable:@"ExpenseTaxCodes" inDatabase:@""];
    [myDB deleteFromTable:@"PendingExpenseCodeDetails" inDatabase:@""];
    [myDB deleteFromTable:@"PendingExpenseTaxCodes" inDatabase:@""];
    [myDB deleteFromTable:@"ApprovalsPendingExpenseTaxCodes" inDatabase:@""];
    [myDB deleteFromTable:@"ApprovalsPendingExpenseCodeDetails" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalTimesheetDaySummary" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalTimesheetCustomFields" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalTimesheetProjectSummary" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalTimesheetActivitySummary" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalTimesheetBillingSummary" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalTimesheetPayrollSummary" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalTimeEntries" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalTimesheetApproverHistory" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalDisclaimer" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalsTimesheetCapabilities" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalExpenseEntries" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalsExpenseCapabilities" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalExpenseCustomFields" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalExpenseIncurredAmountTax" inDatabase:@""];
    [myDB deleteFromTable:@"ApprovalsPreviousExpenseTaxCodes" inDatabase:@""];
    [myDB deleteFromTable:@"ApprovalsPreviousExpenseCodeDetails" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalExpenseSheetApprovalHistory" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalTimeoffEntries" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousApprovalTimeoffCustomFields" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalExpenseEntries" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalExpenseCustomFields" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalExpenseIncurredAmountTax" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalExpenseSheetApprovalHistory" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalsTimesheetCapabilities" inDatabase:@""];
    [myDB deleteFromTable:@"PendingApprovalsExpenseCapabilities" inDatabase:@""];
    //Implementation for US8906 Shifts//JUHI
    [myDB deleteFromTable:@"Shifts" inDatabase:@""];
    [myDB deleteFromTable:@"ShiftEntry" inDatabase:@""];
    [myDB deleteFromTable:@"ShiftDetails" inDatabase:@""];
    [myDB deleteFromTable:@"TeamTimePunches" inDatabase:@""];
    [myDB deleteFromTable:@"TeamTimeUserCapabilities" inDatabase:@""];
    [myDB deleteFromTable:@"PunchHistory" inDatabase:@""];
    [myDB deleteFromTable:@"userDefinedFields" inDatabase:@""];
    [myDB deleteFromTable:@"UDFPreferences" inDatabase:@""];
    [myDB deleteFromTable:@"UDFPendingPreferences" inDatabase:@""];
    [myDB deleteFromTable:@"UDFPreviousPreferences" inDatabase:@""];
    [myDB deleteFromTable:@"userDefinedFieldsClone" inDatabase:@""];
    [myDB deleteFromTable:@"udfPendingTimeoffPreferences" inDatabase:@""];
    [myDB deleteFromTable:@"udfPreviousTimeoffPreferences" inDatabase:@""];
    [myDB deleteFromTable:@"udfTimeoffPreferences" inDatabase:@""];
    [myDB deleteFromTable:@"LastPunchData" inDatabase:@""];
    [myDB deleteFromTable:@"WidgetPunchHistory" inDatabase:@""];
    [myDB deleteFromTable:@"WidgetPendingPunchHistory" inDatabase:@""];
    [myDB deleteFromTable:@"WidgetPreviousPunchHistory" inDatabase:@""];
    [myDB deleteFromTable:@"EnabledWidgets" inDatabase:@""];
    [myDB deleteFromTable:@"PendingEnabledWidgets" inDatabase:@""];
    [myDB deleteFromTable:@"PreviousEnabledWidgets" inDatabase:@""];
    [myDB deleteFromTable:@"WidgetNotice" inDatabase:@""];
    [myDB deleteFromTable:@"WidgetPendingNotice" inDatabase:@""];
    [myDB deleteFromTable:@"WidgetPreviousNotice" inDatabase:@""];
    [myDB deleteFromTable:@"ShiftObjectExtensionFields" inDatabase:@""];//Implemtation for Sched-114//JUHI
    [myDB deleteFromTable:@"WidgetPreviousTimesheetSummary" inDatabase:@""];
    [myDB deleteFromTable:@"WidgetPendingTimesheetSummary" inDatabase:@""];
    [myDB deleteFromTable:@"WidgetTimesheetSummary" inDatabase:@""];
    [myDB deleteFromTable:@"Programs" inDatabase:@""];//MOBI-746
    [myDB deleteFromTable:@"TimesheetCapabilities" inDatabase:@""];
    [myDB deleteFromTable:@"WidgetAttestation" inDatabase:@""];
    [myDB deleteFromTable:@"WidgetPreviousAttestation" inDatabase:@""];
    [myDB deleteFromTable:@"WidgetPendingAttestation" inDatabase:@""];
    [myDB deleteFromTable:@"WidgetPayrollSummary" inDatabase:@""];
    [myDB deleteFromTable:@"WidgetPendingPayrollSummary" inDatabase:@""];
    [myDB deleteFromTable:@"WidgetPreviousPayrollSummary" inDatabase:@""];

    [myDB updateColumnFromTable:@"lastSyncDate" fromTable:@"DataSyncDetails" withString:@"null" inDatabase:@""];
    
    [myDB deleteFromTable:@"TimesheetSummaryCachedData" inDatabase:@""];
    [myDB deleteFromTable:@"TimesheetObjectExtensionFields" inDatabase:@""];
    [myDB deleteFromTable:@"TimeEntriesObjectExtensionFields" inDatabase:@""];
    [myDB deleteFromTable:@"OEFDropDownTagOptions"inDatabase:@""];
    
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"isSuccessLogin"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"holidayCalendarURI"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"weeklyDaysOff"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"hoursPerWorkday"];
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY];
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:REJECTED_TIMESHEET_COUNT_KEY];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:TIMESHEET_PAST_DUE_COUNT_KEY];
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:REJECTED_EXPENSE_SHEETS_COUNT_KEY];
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:REJECTED_TIMEOFF_BOOKING_COUNT_KEY];
    
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:TAB_BAR_MODULES_KEY];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"TimeSheetLastModifiedTime"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"ErrorTimeSheetLastModifiedTime"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ExpenseSheetLastModifiedTime"];//Implementation of ExpenseSheetLastModified
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"timeoffEnableOnlyUdfUriArr"];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"iBeaconActivated"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OldHomeFlowServiceReceivedData"];
    
    // COMMENT THIS WHEN ACTIVATING iBEACON
     [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HRTECH_LOGIN"];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastHomeFlowServiceResponse"];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PunchRecordedLastModifiedTime"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"oldMostRecentPunchData"];
    
// DEBUG WILL BE SWITCHED OFF
 /*   if (!deleteLogin)
    {
        [LogUtil setDebugMode:NO];
    }
   */
    

}

-(BOOL)getStatusForGivenPermissions:(NSString*)permissionName
{
	
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select * from %@",userDetailsTable];
	NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:query];
    if(permissionArr!=nil && ![permissionArr isKindOfClass:[NSNull class]] && [permissionArr count]>0)
    {
        if([[[permissionArr objectAtIndex:0] objectForKey:permissionName] intValue]==1)
        {
            return YES;
        }
    }
	
    return NO;
    
}

-(NSString *)getStatusForDisclaimerPermissionForColumnName:(NSString *)columnName
{
	
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select %@ from %@",columnName,userDetailsTable];
	NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:query];
	if(permissionArr!=nil && ![permissionArr isKindOfClass:[NSNull class]] && [permissionArr count]>0)
    {
		return [[permissionArr objectAtIndex:0] objectForKey:columnName];
	}
    
    return nil;
    
}


-(NSMutableArray *)getUserDefinedFieldsForURI:(NSString *)uri
{
	
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select * from %@ where url=%@",userDeFinedFieldsTable,uri];
	NSMutableArray *udfsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if(udfsArr!=nil && ![udfsArr isKindOfClass:[NSNull class]] && [udfsArr count]>0)
    {
		return udfsArr;
	}
    
    return nil;
    
}


-(void)saveUserDefinedFieldsDataToDB:(NSDictionary *)udfDict
{
   
    SQLiteDB *myDB = [SQLiteDB getInstance];
//    NSArray *udfArr = [self getUserDefinedFieldsForURI:[udfDict objectForKey:@"uri"]];
//    if ([udfArr count]>0)
//    {
//        NSString *whereString=[NSString stringWithFormat:@"uri='%@'",[udfDict objectForKey:@"uri"]];
//        [myDB updateTable:userDeFinedFieldsTable data:udfDict where:whereString intoDatabase:@""];
//    }
//    else
//    {
        [myDB insertIntoTable:userDeFinedFieldsTable  data:udfDict intoDatabase:@""];
//    }

}
-(void)saveUserDefinedFieldsCloneDataToDB:(NSDictionary *)udfDict
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //    NSArray *udfArr = [self getUserDefinedFieldsForURI:[udfDict objectForKey:@"uri"]];
    //    if ([udfArr count]>0)
    //    {
    //        NSString *whereString=[NSString stringWithFormat:@"uri='%@'",[udfDict objectForKey:@"uri"]];
    //        [myDB updateTable:userDeFinedFieldsTable data:udfDict where:whereString intoDatabase:@""];
    //    }
    //    else
    //    {
    [myDB insertIntoTable:userDeFinedFieldsCloneTable  data:udfDict intoDatabase:@""];
    //    }
    
}
-(void)saveUfdDropDownOptionDataToDB:(NSMutableArray*)responseArray{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    for (int i=0; i<[responseArray count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSMutableDictionary *detailDict=[responseArray objectAtIndex:i];
        //Fix for defect DE15459
        if (detailDict!=nil&&![detailDict isKindOfClass:[NSNull class]])
        {
            NSString *dropdownOptionName=nil;
            NSString *dropdownOptionUri=nil;
            
            if ([detailDict objectForKey:@"displayText"]!=nil&&![[detailDict objectForKey:@"displayText"] isKindOfClass:[NSNull class]]) {
                dropdownOptionName=[detailDict objectForKey:@"displayText"];
            }
            if ([detailDict objectForKey:@"uri"]!=nil&&![[detailDict objectForKey:@"uri"] isKindOfClass:[NSNull class]])
            {
                dropdownOptionUri=[detailDict objectForKey:@"uri"];
            }
            int isDefaultValue     =0;
            int isEnabled  =0;
            
            if (([detailDict objectForKey:@"isEnabled"]!=nil&&![[detailDict objectForKey:@"isEnabled"] isKindOfClass:[NSNull class]])&&[[detailDict objectForKey:@"isEnabled"] boolValue] == YES )
            {
                isEnabled = 1;
            }
            
            if (([detailDict objectForKey:@"isDefaultValue"]!=nil&&![[detailDict objectForKey:@"isDefaultValue"] isKindOfClass:[NSNull class]])&&[[detailDict objectForKey:@"isDefaultValue"] boolValue] == YES )
            {
                isDefaultValue = 1;
            }
            
            if (dropdownOptionName!=nil)
            {
                [dataDict setObject:dropdownOptionName forKey:@"name"];
            }
            if (dropdownOptionUri!=nil)
            {
                [dataDict setObject:dropdownOptionUri forKey:@"uri"];
            }
            [dataDict setObject:[NSNumber numberWithInt:isDefaultValue] forKey:@"defaultOption"];
            [dataDict setObject:[NSNumber numberWithInt:isEnabled] forKey:@"enabled"];
            
            NSArray *expArr = [self getUdfDropDownOptionInfoDropDownOptionUri:dropdownOptionUri];
            if ([expArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"uri='%@'",dropdownOptionUri];
                [myDB updateTable: udfDropDownOptionsTable data:dataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:udfDropDownOptionsTable data:dataDict intoDatabase:@""];
            }
        }
        
        
        
        
    }
    
}

-(void)saveOEFDropDownTagOptionDataToDB:(NSMutableArray*)responseArray{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    for (int i=0; i<[responseArray count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSMutableDictionary *detailDict=[responseArray objectAtIndex:i];
        if (detailDict!=nil&&![detailDict isKindOfClass:[NSNull class]])
        {
            NSString *oefDropDownTagDisplayText=nil;
            NSString *oefDropDownTagUri=nil;

            if ([detailDict objectForKey:@"displayText"]!=nil&&![[detailDict objectForKey:@"displayText"] isKindOfClass:[NSNull class]]) {
                oefDropDownTagDisplayText=[detailDict objectForKey:@"displayText"];
            }
            if ([detailDict objectForKey:@"uri"]!=nil&&![[detailDict objectForKey:@"uri"] isKindOfClass:[NSNull class]])
            {
                oefDropDownTagUri=[detailDict objectForKey:@"uri"];
            }


            if (oefDropDownTagDisplayText!=nil)
            {
                [dataDict setObject:oefDropDownTagDisplayText forKey:@"oefDropDownTagDisplayText"];
            }
            if (oefDropDownTagUri!=nil)
            {
                [dataDict setObject:oefDropDownTagUri forKey:@"oefDropDownTagUri"];
            }


            NSArray *tagOptionsArr = [self getOEFDropDownTagOptionInfoForDropDownOptionUri:oefDropDownTagUri];
            if ([tagOptionsArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"oefDropDownTagUri='%@'",oefDropDownTagUri];
                [myDB updateTable: oefDropDownTagOptionsTable data:dataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:oefDropDownTagOptionsTable data:dataDict intoDatabase:@""];
            }
        }

    }

}

-(void)flushUserDefinedFields
{
     SQLiteDB *myDB = [SQLiteDB getInstance];
    [myDB deleteFromTable:userDeFinedFieldsTable inDatabase:@""];
    [myDB deleteFromTable:userDeFinedFieldsCloneTable inDatabase:@""];
}

-(NSMutableArray *)getEnabledOnlyUDFsforModuleName:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where enabled=1 and visible=1 and moduleName='%@'order by required desc,name asc",userDeFinedFieldsTable,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *)getRequiredOnlyUDFsforModuleName:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where required=1 and enabled=1 and visible=1 and moduleName='%@'order by required desc,name asc",userDeFinedFieldsTable,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(BOOL )getMandatoryStatusforUDFWithIdentity:(NSString *)udfIdentity forModuleName:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select required from %@ where uri='%@' and moduleName='%@'order by required desc,name asc",userDeFinedFieldsTable,udfIdentity,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return [[[array objectAtIndex:0] objectForKey:@"required"] boolValue];
	}
	return nil;
}
-(NSArray *)getUdfDropDownOptionInfoDropDownOptionUri:(NSString *)dropDownOptionUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where uri = '%@' ",udfDropDownOptionsTable,dropDownOptionUri];
	NSMutableArray *timeOffsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeOffsArr count]!=0)
    {
		return timeOffsArr;
	}
	return nil;
    
}

-(NSArray *)getOEFDropDownTagOptionInfoForDropDownOptionUri:(NSString *)dropDownTagOptionUri
{

    SQLiteDB *myDB = [SQLiteDB getInstance];

    NSString *query=[NSString stringWithFormat:@" select * from %@ where oefDropDownTagUri = '%@' ",oefDropDownTagOptionsTable,dropDownTagOptionUri];
    NSMutableArray *dropDownOptionsArr = [myDB executeQueryToConvertUnicodeValues:query];
    if ([dropDownOptionsArr count]!=0)
    {
        return dropDownOptionsArr;
    }
    return nil;
    
}

-(NSMutableArray *)getDropDownOptionsFromDatabase{
	SQLiteDB *myDB  = [SQLiteDB getInstance];
	NSString *whereString = @"enabled = 1";
	NSMutableArray *udfDropDownArr = [myDB select:@"*" from:udfDropDownOptionsTable where:whereString intoDatabase:@""];
	
	if ([udfDropDownArr count]!=0) {
		return udfDropDownArr;
	}
	return nil;
}
-(void)deleteAllDropDownOptionsInfoFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ ",udfDropDownOptionsTable];
	[myDB executeQuery:query];
}

-(NSMutableArray *)getOEFDropDownTagOptionsFromDatabase{
    SQLiteDB *myDB  = [SQLiteDB getInstance];
    NSMutableArray *oefDropDownTagOptionsArr = [myDB select:@"*" from:oefDropDownTagOptionsTable where:@"" intoDatabase:@""];

    if ([oefDropDownTagOptionsArr count]!=0) {
        return oefDropDownTagOptionsArr;
    }
    return nil;
}

-(void)deleteAllOEFDropDownTagOptionsInfoFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query=[NSString stringWithFormat:@"delete from %@ ",oefDropDownTagOptionsTable];
    [myDB executeQuery:query];
}

-(NSMutableDictionary *)getDataforUDFWithIdentity:(NSString *)udfIdentity
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where uri='%@' ",userDeFinedFieldsCloneTable,udfIdentity];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return [array objectAtIndex:0];
	}
	return nil;
}
@end
