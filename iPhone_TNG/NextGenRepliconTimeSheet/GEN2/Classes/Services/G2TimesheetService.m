//
//  TimesheetService.m
//  Replicon
//
//  Created by enl4macbkpro on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2TimesheetService.h"
#import "G2RepliconServiceManager.h"
#import "RepliconAppDelegate.h"

@implementation G2TimesheetService

@synthesize timesheetModel;

@synthesize isNewTimeOffPopUp; //DE6520//Juhi
- (id) init
{
	self = [super init];
	if (self != nil) {
		if(timesheetModel == nil) {
			timesheetModel = [[G2TimesheetModel alloc] init];
		}
		if (supportDataModel == nil) {
			supportDataModel = [[G2SupportDataModel alloc] init];
		}
        
        
	}
	return self;
}

/*This method sends request to api to fetch most recent timesheets for logged in user.
 *Calling class - HomeViewController - timesheetAction
 */
#pragma mark -
#pragma mark Request Methods


-(void) fetchTimeSheetUSerDataForDate:(id)_delegate andDate:(NSDate *)date
{
    //    BOOL supportDataCanRun = [Util shallExecuteQuery:TIMESHEET_SUPPORT_DATA_SERVICE_SECTION];
    
	
	//ravi - Reset the total requests sent and received before sending the new requests
	totalRequestsServed = 0;
	totalRequestsSent = 0;
	
    BOOL supportDataCanRun=TRUE;
	if (supportDataCanRun) {
        
        G2PermissionsModel *permissionsModel   = [[G2PermissionsModel alloc] init];
        NSMutableArray *enabledPermissionSet = [permissionsModel getEnabledUserPermissions];
        
        NSDictionary *cellUdfDict = nil;
        NSDictionary *rowUdfDict = nil;
        NSDictionary *entireUdfDict = nil;
        NSMutableArray *udfpermissions = [NSMutableArray array];
        NSMutableArray  *permissionSet = [NSMutableArray array];
        for (NSDictionary *permissionDict in enabledPermissionSet) {
            NSString * permission = [permissionDict objectForKey:@"permissionName"];
            NSString *shortString = nil;
            if (![permission isKindOfClass:[NSNull class] ])
            {
                if ([permission length]-4 > 0) {
                    NSRange stringRange = {0, MIN([permission length], [permission length]-4)};
                    stringRange = [permission rangeOfComposedCharacterSequencesForRange:stringRange];
                    shortString = [permission substringWithRange:stringRange];
                    //DLog(@"Short String:HomeViewController %@",shortString);
                }
                
            }
            [udfpermissions addObject:shortString];
        }
        if ([udfpermissions containsObject:TimesheetEntry_CellLevel]) {
            cellUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:TimesheetEntry_CellLevel];
        }
        if ([udfpermissions containsObject:TaskTimesheet_RowLevel]) {
            rowUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:TaskTimesheet_RowLevel];
        }
        if ([udfpermissions containsObject:ReportPeriod_SheetLevel]) {
            entireUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:ReportPeriod_SheetLevel];
        }
        
        if (cellUdfDict != nil) {
            [permissionSet addObject:cellUdfDict];
        }
        if (rowUdfDict != nil) {
            [permissionSet addObject:rowUdfDict];
        }
        if (entireUdfDict != nil) {
            [permissionSet addObject:entireUdfDict];
        }
        
		
		[[G2RepliconServiceManager timesheetService] sendTimeSheetRequestToFetchSheetLevelUDFsWithPermissionSet:permissionSet];	
		
		totalRequestsSent += 1;
	}
    
    
    
    
}

-(void)sendRequestToFetchTimeSheetByDate:(NSDate *)date
{
    NSDictionary *dateDict = [G2Util convertDateToApiDateDictionary:date];
    NSString *userId=[[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
    NSMutableArray *argsArray=[NSMutableArray array];
	NSDictionary *argsDict=[NSDictionary dictionaryWithObjectsAndKeys:userId,@"Identity",@"Replicon.Domain.User",@"__type",nil];
	[argsArray addObject:argsDict];
    [argsArray addObject:dateDict];
    NSMutableArray *loadArray=[NSMutableArray array];
	NSDictionary *loadDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeEntries",@"Relationship",nil];
	[loadArray addObject:loadDict];
    
    
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:argsArray,@"Args",
							 @"Query",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
							 @"EntryTimesheetByUserDate",@"QueryType",
							 argsArray,@"Args",loadArray,@"Load",
							 nil];
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"GetTimesheetWithDate"]];
	[self setServiceDelegate:self];
	[self executeRequest];
    
}

-(void)sendRequestToFetchMostRecentTimesheetsForUser
{
	/*
	 {
	 "Count": 5,
	 "Args": [
	 {
	 "Identity": "49",
	 "__type": "Replicon.Domain.User"
	 }
	 ],
	 "SortBy": [
	 {
	 "Property": "ApprovalStatus",
	 "EnumOrder": [
	 "Approved"
	 ],
	 "Descending": true
	 },
	 {
	 "Property": "EndDate",
	 "Descending": true
	 }
	 ],
	 "Action": "Query",
	 "DomainType": "Replicon.Suite.Domain.EntryTimesheet",
	 "Load": [
	 {
	 "Relationship": "TimeEntries",
	 "Load": [
	 {
	 "Relationship": "Activity"
	 },
	 {
	 "Relationship": "ProjectRole"
	 },
	 {
	 "Relationship": "BillingRateDepartment"
	 }
	 {
	 "Relationship": "Client"
	 },
	 {
	 "Relationship": "Task",
	 "Load": [
	 {
	 "CountOf": "ChildTasks"
	 },
	 {
	 "Relationship": "Project",
	 "Load": [
	 {
	 "Relationship": "ProjectClients",
	 "Load": [
	 {
	 "Relationship": "Client"
	 }
	 ]
	 }
	 ]
	 }
	 ]
	 }
	 ]
	 },
	 {
	 "Relationship": "TimeOffEntries",
	 "Load" : [
	 {
	 "Relationship": "TimeOffCode"
	 }
	 ]
	 }
	 ],
	 "QueryType": "EntryTimesheetByUser",
	 "StartIndex": 0
	 }
	 */
	
	
	NSNumber *count= [[G2AppProperties getInstance] getAppPropertyFor:@"MostRecentTimeSheetsCount"];
	NSNumber *startIndex=[NSNumber numberWithInt:0];
	NSString *userId=[[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
	NSMutableArray *argsArray=[NSMutableArray array];
	NSDictionary *argsDict=[NSDictionary dictionaryWithObjectsAndKeys:userId,@"Identity",@"Replicon.Domain.User",@"__type",nil];
	[argsArray addObject:argsDict];
	NSArray *enumArr = [NSArray arrayWithObjects:@"Approved",nil];
	NSDictionary *approveSortDict=[NSDictionary dictionaryWithObjectsAndKeys:@"ApprovalStatus",@"Property",
								   enumArr,@"EnumOrder",		  
								   [NSNumber numberWithBool:YES],@"Descending",nil]; 
	NSDictionary *endDateSortDict=[NSDictionary dictionaryWithObjectsAndKeys:@"EndDate",@"Property",
								   [NSNumber numberWithBool:YES],@"Descending",nil]; 
	
	NSMutableArray *loadArray=[NSMutableArray array];
	
	NSMutableArray *sortArray=[NSMutableArray array];
	[sortArray addObject:approveSortDict];
	[sortArray addObject:endDateSortDict];
	
	NSDictionary *activityDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Activity",@"Relationship",nil];
	NSDictionary *projectRoleDict = [NSDictionary dictionaryWithObjectsAndKeys:@"ProjectRole",@"Relationship",nil];
	NSDictionary *billingDepartmentDict = [NSDictionary dictionaryWithObjectsAndKeys:@"BillingRateDepartment",@"Relationship",nil];
	NSDictionary *clientDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
	NSDictionary *billingDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Billable",@"Relationship",nil];
    
	//load array for client relatonship in projectClient and add to projectclientDict
	NSArray *projectClientLoadArray = [NSArray arrayWithObjects:clientDict,nil];
	NSDictionary *projectClientDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   @"ProjectClients",@"Relationship",
									   projectClientLoadArray,@"Load",
									   nil];
	//load array for projectClients in project and add to projectDict
	NSArray *projectLoadArray = [NSArray arrayWithObjects:projectClientDict,nil];
	NSDictionary *projectDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Project",@"Relationship",
								 projectLoadArray,@"Load",
								 nil];
	NSDictionary *childTaskCountDict = [NSDictionary dictionaryWithObject:@"ChildTasks" forKey:@"CountOf"];
	NSDictionary *parentTaskDict  = [NSDictionary dictionaryWithObject:@"ParentTask" forKey:@"Relationship"];
	//Load array for project in task and add to taskDict
	NSArray *taskLoadArray = [NSArray arrayWithObjects:projectDict,childTaskCountDict,parentTaskDict,nil];
	NSDictionary *taskDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Task",@"Relationship",
							  taskLoadArray,@"Load",
							  nil];
	
	//Load array for activity,project role,client, task to timeentries and add to TimeEntriesDict
	NSArray *timeEntriesLoadArray = [NSArray arrayWithObjects:activityDict,projectRoleDict,billingDepartmentDict,clientDict,taskDict,billingDict,nil];
	NSDictionary *timeEntriesDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeEntries",@"Relationship",
								   timeEntriesLoadArray,@"Load",
								   nil];
	NSDictionary *timeOffCodeDict = [NSDictionary dictionaryWithObjectsAndKeys:@"TimeOffCode",@"Relationship",nil];
	NSArray *timeOffEntriesLoadArray = [NSArray arrayWithObject:timeOffCodeDict];
	NSDictionary *timeOffEntriesDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeOffEntries",@"Relationship",
									  timeOffEntriesLoadArray,@"Load",
									  nil];
	NSDictionary *remainingApproversDict = [NSDictionary dictionaryWithObjectsAndKeys:
											@"RemainingApprovers",@"Relationship",
											nil];
	NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Type",@"Relationship",nil];
	NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
	NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"FilteredHistory",@"Relationship",
										 approvalLoadArray,@"Load",
										 nil];
    
    NSDictionary *languageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Language",@"Relationship",nil];
    NSArray *languageArray=[NSArray arrayWithObject:languageDict];
	NSDictionary *mealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BreakRuleViolationEntries",@"Relationship",languageArray,@"Load",nil];
    NSDictionary *finalmealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BreakRuleViolations",@"Relationship",[NSArray arrayWithObject:mealBreakViolationsDict],@"Load",nil];
    
	[loadArray addObject:timeEntriesDict];
	[loadArray addObject:timeOffEntriesDict];
	[loadArray addObject:remainingApproversDict];
	[loadArray addObject:filteredHistoryDict];
    [loadArray addObject:finalmealBreakViolationsDict];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:count,@"Count",argsArray,@"Args",sortArray,@"SortBy",
							 @"Query",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
							 loadArray,@"Load",@"EntryTimesheetByUser",@"QueryType",startIndex,@"StartIndex",
							 nil];
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	
	//set the start index for next fetch
	[[NSUserDefaults standardUserDefaults] setObject:startIndex forKey:TIMESHEET_FETCH_START_INDEX];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName:@"EntryTimesheetByUser"]];//Service Id: 38 Notification: TIMESHEETS_RECEIVED_NOTIFICATION
	[self setServiceDelegate: self];
	[self executeRequest];	 
}

-(void)sendRequestToFetchNextRecentTimeSheets:(NSString *)handleIdentity 
							   withStartIndex:(NSNumber*)startingIndex 
								   countLimit:(NSNumber*)limit{
	/*{
	 "Action": "Query",
	 "QueryHandle": "8EA58ED9-3E01-4cf1-A98D-A21BB36AAB3C",
	 "StartIndex": 5,
	 "Count": 5,
	 }*/
	
#ifdef DEV_DEBUG
	DLog(@"\nsendRequestToFetchNextRecentTimeSheets:::TimeSheet Service");
	DLog(@"handleIdentity::%@",handleIdentity);
	DLog(@"startingIndex::%d",[startingIndex intValue]);
	DLog(@"limit::%d",[limit intValue]);
#endif
	
	NSDictionary *recentTimeSheetsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
										handleIdentity,@"QueryHandle",
										startingIndex,@"StartIndex",
										limit,@"Count",nil];
	
	NSString *queryString=	[JsonWrapper writeJson:recentTimeSheetsDict error:nil];
#ifdef DEV_DEBUG
	DLog(@" sendRequestToFetchNextRecentTimeSheets::::jsonQuery  %@",queryString);
#endif
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	
	/*NSMutableDictionary *refDict1 =[NSMutableDictionary dictionaryWithObjectsAndKeys:limitedCount,@"limitedCount",
	 @"NextRecentExpenseSheets",@"refrenceName",
	 nil];*/
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"FetchNextRecentTimeSheets"]];
	[self setServiceDelegate:self];
	[self executeRequest];
	
}
-(void) getTimesheetFromApiAndAddTimeEntry:(G2TimeSheetEntryObject *)entryObj {
	
	/*
	 {
	 "Action": "Query",
	 "DomainType": "Replicon.Suite.Domain.EntryTimesheet",
	 "QueryType": "EntryTimesheetByUserDate",
	 "Args": [
	 {
	 "Identity": "2",
	 "__type": "Replicon.Domain.User"
	 },
	 {
	 "__type": "Date",
	 "Year": 2011,
	 "Month": 5,
	 "Day": 25
	 }
	 ],
	 "Load": [
	 {
	 "Relationship": "TimeEntries",
	 "Load": [
	 {
	 "Relationship": "Activity"
	 },
	 {
	 "Relationship": "ProjectRole"
	 },
	 {
	 "Relationship": "Client"
	 },
	 {
	 "Relationship": "Task",
	 "Load": [
	 {
	 "Relationship": "Project",
	 "Load": [
	 {
	 "Relationship": "ProjectClients",
	 "Load": [
	 {
	 "Relationship": "Client"
	 }
	 ]
	 }
	 ]
	 }
	 ]
	 }
	 ]
	 },
	 {
	 "Relationship": "TimeOffEntries",
	 "Load" : [
	 {
	 "Relationship": "TimeOffCode"
	 }
	 ]
	 }
	 ]
	 }
	 */
	NSString *userIdentity = [[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
	NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  userIdentity,@"Identity",
							  @"Replicon.Domain.User",@"__type",
							  nil];
	DLog(@"user dict %@",userDict);
	//NSString *entryDateString = [entryObj dateDefaultValue];
	NSDate *entryDate = [entryObj entryDate];
	DLog(@"entyr date to convert %@",entryDate);
	NSDictionary *apiDateDict = [G2Util convertDateToApiDateDictionary:entryDate];
	DLog(@"got api date dict");
	NSArray *argsArray = [NSArray arrayWithObjects:userDict,apiDateDict,nil];
	
	NSMutableArray *loadArray = [NSMutableArray array];
	
	NSDictionary *activityDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Activity",@"Relationship",nil];
	NSDictionary *projectRoleDict = [NSDictionary dictionaryWithObjectsAndKeys:@"ProjectRole",@"Relationship",nil];
	NSDictionary *clientDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
	NSDictionary *billingDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Billable",@"Relationship",nil];
	//NSDictionary *clientsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
	//load array for client relatonship in projectClient and add to projectclientDict
	NSArray *projectClientLoadArray = [NSArray arrayWithObjects:clientDict,nil];
	NSDictionary *projectClientDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   @"ProjectClients",@"Relationship",
									   projectClientLoadArray,@"Load",
									   nil];
	//load array for projectClients in project and add to projectDict
	NSArray *projectLoadArray = [NSArray arrayWithObjects:projectClientDict,nil];
	NSDictionary *projectDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Project",@"Relationship",
								 projectLoadArray,@"Load",
								 nil];
	NSDictionary *childTaskCountDict = [NSDictionary dictionaryWithObject:@"ChildTasks" forKey:@"CountOf"];
	NSDictionary *parentTaskDict = [NSDictionary dictionaryWithObject:@"ParentTask" forKey:@"Relationship"];
	//Load array for project in task and add to taskDict
	NSArray *taskLoadArray = [NSArray arrayWithObjects:projectDict,childTaskCountDict,parentTaskDict,nil];
	NSDictionary *taskDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Task",@"Relationship",
							  taskLoadArray,@"Load",
							  nil];
	
	//Load array for activity,project role,client, task to timeentries and add to TimeEntriesDict
	NSArray *timeEntriesLoadArray = [NSArray arrayWithObjects:activityDict,projectRoleDict,clientDict,taskDict,billingDict,nil];
	NSDictionary *timeEntriesDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeEntries",@"Relationship",
								   timeEntriesLoadArray,@"Load",
								   nil];
	NSDictionary *timeOffCodeDict = [NSDictionary dictionaryWithObjectsAndKeys:@"TimeOffCode",@"Relationship",nil];
	NSArray *timeOffEntriesLoadArray = [NSArray arrayWithObject:timeOffCodeDict];
	NSDictionary *timeOffEntriesDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeOffEntries",@"Relationship",
									  timeOffEntriesLoadArray,@"Load",
									  nil];
	NSDictionary *remainingApproversDict = [NSDictionary dictionaryWithObjectsAndKeys:
											@"RemainingApprovers",@"Relationship",
											nil];
	NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Type",@"Relationship",nil];
	NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
	NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"FilteredHistory",@"Relationship",
										 approvalLoadArray,@"Load",
										 nil];
    
    NSDictionary *languageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Language",@"Relationship",nil];
    NSArray *languageArray=[NSArray arrayWithObject:languageDict];
	NSDictionary *mealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BreakRuleViolationEntries",@"Relationship",languageArray,@"Load",nil];
    NSDictionary *finalmealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BreakRuleViolations",@"Relationship",[NSArray arrayWithObject:mealBreakViolationsDict],@"Load",nil];
	
	[loadArray addObject:timeEntriesDict];
	[loadArray addObject:timeOffEntriesDict];
	[loadArray addObject:remainingApproversDict];
	[loadArray addObject:filteredHistoryDict];
    [loadArray addObject:finalmealBreakViolationsDict];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:argsArray,@"Args",
							 @"Query",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
							 @"EntryTimesheetByUserDate",@"QueryType",
							 loadArray,@"Load",
							 nil];
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"QueryAndCreateTimesheet"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}

-(void) getTimeOffFromApiAndAddTimeEntry:(G2TimeOffEntryObject *)entryObj {
	

	NSString *userIdentity = [[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
	NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  userIdentity,@"Identity",
							  @"Replicon.Domain.User",@"__type",
							  nil];
	
	NSDate *entryDate = [entryObj timeOffDate];
    NSDictionary *apiDateDict = [G2Util convertDateToApiDateDictionary:entryDate];
	NSArray *argsArray = [NSArray arrayWithObjects:userDict,apiDateDict,nil];
	
	NSMutableArray *loadArray = [NSMutableArray array];
	
	NSDictionary *activityDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Activity",@"Relationship",nil];
	NSDictionary *projectRoleDict = [NSDictionary dictionaryWithObjectsAndKeys:@"ProjectRole",@"Relationship",nil];
	NSDictionary *clientDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
	NSDictionary *billingDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Billable",@"Relationship",nil];
	//NSDictionary *clientsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
	//load array for client relatonship in projectClient and add to projectclientDict
	NSArray *projectClientLoadArray = [NSArray arrayWithObjects:clientDict,nil];
	NSDictionary *projectClientDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   @"ProjectClients",@"Relationship",
									   projectClientLoadArray,@"Load",
									   nil];
	//load array for projectClients in project and add to projectDict
	NSArray *projectLoadArray = [NSArray arrayWithObjects:projectClientDict,nil];
	NSDictionary *projectDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Project",@"Relationship",
								 projectLoadArray,@"Load",
								 nil];
	NSDictionary *childTaskCountDict = [NSDictionary dictionaryWithObject:@"ChildTasks" forKey:@"CountOf"];
	NSDictionary *parentTaskDict = [NSDictionary dictionaryWithObject:@"ParentTask" forKey:@"Relationship"];
	//Load array for project in task and add to taskDict
	NSArray *taskLoadArray = [NSArray arrayWithObjects:projectDict,childTaskCountDict,parentTaskDict,nil];
	NSDictionary *taskDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Task",@"Relationship",
							  taskLoadArray,@"Load",
							  nil];
	
	//Load array for activity,project role,client, task to timeentries and add to TimeEntriesDict
	NSArray *timeEntriesLoadArray = [NSArray arrayWithObjects:activityDict,projectRoleDict,clientDict,taskDict,billingDict,nil];
	NSDictionary *timeEntriesDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeEntries",@"Relationship",
								   timeEntriesLoadArray,@"Load",
								   nil];
	NSDictionary *timeOffCodeDict = [NSDictionary dictionaryWithObjectsAndKeys:@"TimeOffCode",@"Relationship",nil];
	NSArray *timeOffEntriesLoadArray = [NSArray arrayWithObject:timeOffCodeDict];
	NSDictionary *timeOffEntriesDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeOffEntries",@"Relationship",
									  timeOffEntriesLoadArray,@"Load",
									  nil];
	NSDictionary *remainingApproversDict = [NSDictionary dictionaryWithObjectsAndKeys:
											@"RemainingApprovers",@"Relationship",
											nil];
	NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Type",@"Relationship",nil];
	NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
	NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"FilteredHistory",@"Relationship",
										 approvalLoadArray,@"Load",
										 nil];
	
	[loadArray addObject:timeEntriesDict];
	[loadArray addObject:timeOffEntriesDict];
	[loadArray addObject:remainingApproversDict];
	[loadArray addObject:filteredHistoryDict];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:argsArray,@"Args",
							 @"Query",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
							 @"EntryTimesheetByUserDate",@"QueryType",
							 loadArray,@"Load",
							 nil];
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"QueryAndCreateTimeOff"]];
	[self setServiceDelegate:self];
	[self executeRequest];

}

/*
 * This method submits a Timesheet with Identity 
 */

-(void) submitTimesheetWithComments: (NSString *)sheetIdentity comments:(NSString *)comments{
	/*
	 [
	 {
	 "Action": "Edit",
	 "Type": "Replicon.Suite.Domain.EntryTimesheet",
	 "Identity": "1",
	 "Operations": [
	 {
	 "__operation": "Submit",
	 "Comment": "My submit comment"
	 }
	 ]
	 }
	 ]
	 */
	NSDictionary *submitOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"Submit",@"__operation",
										 comments,@"Comment",
										 nil];
	NSArray *operationsArray = [NSArray arrayWithObject:submitOperationDict];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Edit",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"Type",
							 sheetIdentity,@"Identity",
							 operationsArray,@"Operations",
							 nil];
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"SubmitTimesheet"]];
	[self setServiceDelegate:self];
	[self executeRequest];
	
}

/*
 * This method fetches the Timesheetwith Identity
 */
-(void)getTimesheetFromApiWithIdentity:(NSString *)sheetIdentity {
	/*
	 [
	 {
	 "Action": "Query",
	 "QueryType": "EntryTimesheetById",
	 "DomainType": "Replicon.Suite.Domain.EntryTimesheet",
	 "Args": [
	 [
	 "74"
	 ]
	 ],
	 }
	 ]
	 */
	
	NSArray *identityArray = [NSArray arrayWithObject:sheetIdentity];
 NSDictionary *remainingApproverDict = [NSDictionary dictionaryWithObjectsAndKeys:
										   @"RemainingApprovers",@"Relationship",
										   nil];
	
	
    
    NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Type",@"Relationship",nil];
	NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
	NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"FilteredHistory",@"Relationship",
										 approvalLoadArray,@"Load",
										 nil];

    NSArray *loadArray = [NSArray arrayWithObjects:remainingApproverDict,filteredHistoryDict,
						  nil];
	NSArray *argsArray = [NSArray arrayWithObject:identityArray];
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:argsArray,@"Args",
							 @"Query",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
							 @"EntryTimesheetById",@"QueryType",
							 argsArray,@"Args",loadArray,@"Load",
							 nil];
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"GetTimesheetWithIdentity"]];
	[self setServiceDelegate:self];
	[self executeRequest];
	
}


-(void) unsubmitTimesheetWithIdentity: (NSString *)sheetIdentity {
	/*
	 [
	 {
	 "Action": "Edit",
	 "Type": "Replicon.Suite.Domain.EntryTimesheet",
	 "Identity": "1",
	 "Operations": [
	 {
	 "__operation": "Unsubmit"
	 }
	 ]
	 }
	 ]
	 */
	NSDictionary *submitOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"Unsubmit",@"__operation",
										 nil];
	NSArray *operationsArray = [NSArray arrayWithObject:submitOperationDict];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Edit",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"Type",
							 sheetIdentity,@"Identity",
							 operationsArray,@"Operations",
							 nil];
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"UnsubmitTimesheet"]];
	[self setServiceDelegate:self];
	[self executeRequest];
	
}
//US4754
//US4660//Juhi
-(void) reopenTimesheetWithIdentity:(NSString *)sheetIdentity comments:(NSString *)comments  {
	/*
	 [
	 {
	 "Action": "Edit",
	 "Type": "Replicon.Suite.Domain.EntryTimesheet",
	 "Identity": "1",
	 "Operations": [
	 {
	 "__operation": "Reopen",
	 "Comment": "My submit comment"
	 }
	 ]
	 }
	 ]
	 */
	NSDictionary *reopenOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"Reopen",@"__operation",
										comments,@"Comment",
										 nil];
	NSArray *operationsArray = [NSArray arrayWithObject:reopenOperationDict];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Edit",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"Type",
							 sheetIdentity,@"Identity",
							 operationsArray,@"Operations",
							 nil];
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ReopenTimesheet"]];
	[self setServiceDelegate:self];
	[self executeRequest];
	
}
/*
 * This method fetches the Approval History for a sheet
 */

-(void)getApprovalHistoryFromApiForSheet: (NSString *)sheetIdentity {
	/*
	 {
	 "Action": "LoadIdentity",
	 "DomainType": "Replicon.Suite.Domain.EntryTimesheet",
	 "Identity": "13",
	 "Load": [
	 {
	 "Relationship": "History",
	 "Load": [
	 {
	 "Relationship":"Approver"
	 }
	 ]
	 },
	 {
	 "Relationship": "WaitingOnApprovers"
	 },
	 {
	 "Relationship": "RemainingApprovers"
	 }
	 ]
	 }
	 */
	NSDictionary *approverDict = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"Approver",@"Relationship",
								  nil];
	NSArray *approverLoadArray = [NSArray arrayWithObject:approverDict];
	
	NSDictionary *historyRelationDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"History",@"Relationship",
										 approverLoadArray,@"Load",
										 nil];
	NSDictionary *waitingApproversDict = [NSDictionary dictionaryWithObjectsAndKeys:
										  @"WaitingOnApprovers",@"Relationship",
										  nil];
	NSDictionary *remainingApproverDict = [NSDictionary dictionaryWithObjectsAndKeys:
										   @"RemainingApprovers",@"Relationship",
										   nil];
	
	NSArray *loadArray = [NSArray arrayWithObjects:historyRelationDict,waitingApproversDict,remainingApproverDict,
						  nil];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
							 @"LoadIdentity",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
							 sheetIdentity,@"Identity",
							 loadArray,@"Load",
							 nil];
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"TimesheetApprovalHistory"]];
	[self setServiceDelegate:self];
	[self executeRequest];
	
}

/*
 *This method fetches Tasks for a project to entry Time against.
 This does not include entry date , can be added in future
 */
-(void)sendRequestToFetchTasksForProject:(G2TimeSheetEntryObject *)entryObject {
	
	/*
	 { "Action": "Query",
	 "QueryType": "OpenTasksByUserAndProjectFilterByTaskCount",
	 "DomainType": "Replicon.Project.Domain.Task",
	 "Args": [ 
	 { 
	 "__type": "Replicon.Domain.User",
	 "Identity": "45"
	 },
	 { 
	 "__type": "Replicon.Project.Domain.Project",
	 "Identity": "20"
	 },
	 100
	 ],
	 "Load":[
	 {
	 "Relationship":"ParentTask"
	 },
	 {
	 "CountOf": "ChildTasks"
	 }
	 ]
	 }
	 */
	NSString *userIdentity = [[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
	NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  userIdentity,@"Identity",
							  @"Replicon.Domain.User",@"__type",
							  nil];
	NSString *projectIdentity = [entryObject projectIdentity];
	NSDictionary *projectDict = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"Replicon.Project.Domain.Project",@"__type",
								 projectIdentity,@"Identity",
								 nil];
	NSNumber *fetchCount = [NSNumber numberWithInt:TASKS_FETCH_COUNT];
	NSArray *argsArray = [NSArray arrayWithObjects:userDict,projectDict,fetchCount,nil];
	NSDictionary *parentTaskDict = [NSDictionary dictionaryWithObject:@"ParentTask" forKey:@"Relationship"];
	NSDictionary *childTaskCountDict = [NSDictionary dictionaryWithObject:@"ChildTasks" forKey:@"CountOf"];
	NSArray *loadArray = [NSArray arrayWithObjects:parentTaskDict,childTaskCountDict,nil];
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Query",@"Action",@"OpenTasksByUserAndProjectFilterByTaskCount",@"QueryType",
							 @"Replicon.Project.Domain.Task",@"DomainType",
							 argsArray,@"Args",
							 loadArray,@"Load",
							 nil];
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	//DLog(@" TIME SHEET Task QUERY::::Fetch Tasks %@",str);
	NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	NSMutableDictionary *otherParamsDict = [[NSMutableDictionary alloc] init];
	if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]]) {
		[otherParamsDict setObject:projectIdentity forKey:@"projectIdentity"];
	}
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"TimesheetProjectTasks"]];
	[self setServiceDelegate:self];
	[self executeRequest:otherParamsDict];
	
	
}

/*
 * This method fetches tasks for a parent task.
 */
-(void)sendRequestToFetchSubTasksForParentTask:(NSString *) selectedTaskIdentity :(NSString *) projectIdentity {
	/*
	 { 
	 "Action": "Query",
	 "QueryType": "AllOpenTasksByUserAndParentTask",
	 "DomainType": "Replicon.Project.Domain.Task",
	 "Args": [
	 {
	 "__type": "Replicon.Domain.User",
	 "Identity": "45"
	 }, 
	 { 
	 "__type": "Replicon.Project.Domain.Task",
	 "Identity": "40"
	 }
	 ]
	 "Load" : [
	 {
	 "CountOf": "ChildTasks"
	 }
	 ]
	 }
	 */
	
	NSString *userIdentity = [[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
	NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  userIdentity,@"Identity",
							  @"Replicon.Domain.User",@"__type",
							  nil];
	NSDictionary *taskDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"Replicon.Project.Domain.Task",@"__type",
							  selectedTaskIdentity,@"Identity",
							  nil];
	//NSNumber *fetchCount = [NSNumber numberWithInt:TASKS_FETCH_COUNT];
	//NSArray *argsArray = [NSArray arrayWithObjects:userDict,taskDict,fetchCount,nil];
	NSArray *argsArray = [NSArray arrayWithObjects:userDict,taskDict,nil];
	NSDictionary *childTaskCountDict = [NSDictionary dictionaryWithObject:@"ChildTasks" forKey:@"CountOf"];
	NSArray *loadArray = [NSArray arrayWithObjects:childTaskCountDict,nil];
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Query",@"Action",@"AllOpenTasksByUserAndParentTask",@"QueryType",
							 @"Replicon.Project.Domain.Task",@"DomainType",
							 argsArray,@"Args",
							 loadArray,@"Load",
							 nil];
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET Task QUERY:::::SubTasks	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	NSMutableDictionary *otherParamsDict = [NSMutableDictionary dictionary];
	if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]]) {
		[otherParamsDict setObject:projectIdentity forKey:@"projectIdentity"];
	}
	if (selectedTaskIdentity != nil && ![selectedTaskIdentity isKindOfClass:[NSNull class]]) {
		[otherParamsDict setObject:selectedTaskIdentity forKey:@"parentTaskIdentity"];
	}
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"TimesheetProjectSubTasks"]];
	[self setServiceDelegate:self];
	[self executeRequest:otherParamsDict];
}
/**
 *Request to Edit the Time Entry Details
 *Date:June 21st
 **/
-(void)sendRequestToEditTheTimeEntryDetailsWithUserData:(G2TimeSheetEntryObject *)_timeEntryObject{
	DLog(@"sendRequestToEditTheTimeEntryDetailsWithUserData::::TimeSheetService");
	/*
	 [
	 {
	 "Action": "Edit",
	 "Type": "Replicon.Suite.Domain.EntryTimesheet",
	 "Identity": "1",
	 "Operations": [
	 {
	 "__operation": "CollectionEdit",
	 "Collection": "TimeEntries",
	 "Operations": [
	 {
	 "__operation": "SetProperties",
	 "CalculationModeObject": {
	 "__type": "Replicon.TimeSheet.Domain.CalculationModeObject",
	 "Identity": "CalculateDuration"
	 },
	 "EntryDate": {
	 "__type": "Date",
	 "Year": 2011,
	 "Month": 5,
	 "Day": 12
	 },
	 "TimeIn": {
	 "__type": "Time",
	 "Hour": 8,
	 "Minute": 0
	 },
	 "TimeOut": {
	 "__type": "Time",
	 "Hour": 11,
	 "Minute": 0
	 },
	 "Comments": "hello 123",
	 "Task": {
	 "Identity": "1"
	 },
	 "Activity": {
	 "Identity": "1"
	 }
	 
	 },
	 {
	 "__operation": "SetTimeEntryBilling",
	 "BillingType": {
	 "__type": "Replicon.Project.Domain.Timesheets.TimesheetBillingType",
	 "Identity": "ProjectRate"
	 },
	 "Project": {
	 "__type": "Replicon.Project.Domain.Project",
	 "Identity": "1"
	 }
	 }
	 ]
	 }
	 ]
	 }
	 ]
	 */
	
	
	//timeEntryReference				    = _timeEntryObject;
	
	NSString     *projectIdentity       = [_timeEntryObject projectIdentity];
	NSString     *billingIdentity       = [_timeEntryObject billingIdentity];
	NSString     *activityIdentity		= [_timeEntryObject activityIdentity];
	//NSString     *taskIdentity		    = [_timeEntryObject taskIdentity];
	NSString     *taskIdentity		    = [_timeEntryObject.taskObj taskIdentity];
	NSString     *comments				= [_timeEntryObject comments];
	NSDate		 *entryDate				= [_timeEntryObject entryDate];
	NSString	 *sheetIdentity			= [_timeEntryObject sheetId];
	NSNumber	 *projectRoleId			= [_timeEntryObject projectRoleId];
	NSString     *timeHours				= [_timeEntryObject numberOfHours];
	NSString	 *entryIdentity         = [_timeEntryObject identity];
	
	NSDictionary *entryDateDict			= [G2Util convertDateToApiDateDictionary:entryDate];
    
    BOOL doesUserHaveViewOrEditBilling   = [self checkForPermissionExistence:@"BillingTimesheet"]; //US4006//Juhi
    
    if([_timeEntryObject projectBillableStatus]!=nil && ![[_timeEntryObject projectBillableStatus] isKindOfClass:[NSNull class]])
    {
        if ([[_timeEntryObject projectBillableStatus] isEqualToString:@"AllowBillable"])
        {
            doesUserHaveViewOrEditBilling=TRUE;
        }
    }

	
	NSMutableDictionary *propertiesDictionary     = [NSMutableDictionary dictionary];
    NSMutableDictionary *propertiesDictionary1     = [NSMutableDictionary dictionary]; 
	
	NSMutableDictionary *calculationModeDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      @"Replicon.TimeSheet.Domain.CalculationModeObject",@"__type",
                                                      @"CalculateInOutTime",@"Identity",nil];
	[propertiesDictionary1 setObject:@"SetProperties" forKey:@"__operation"];
	[propertiesDictionary1 setObject:calculationModeDictionary forKey:@"CalculationModeObject"];
	
	if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]] && ![projectIdentity isEqualToString:NO_CLIENT_ID]) {
		//[propertiesDictionary setObject:projectIdentity forKey:@"Identity"];
	}
	[propertiesDictionary setObject:@"SetProperties" forKey:@"__operation"];
	
	if (entryDateDict != nil && [entryDateDict isKindOfClass:[NSDictionary class]]) {
		[propertiesDictionary setObject:entryDateDict forKey:@"EntryDate"];
	}
	if (comments != nil && ![comments isKindOfClass:[NSNull class]] && ![comments isEqualToString:NULL_STRING]) {
		[propertiesDictionary setObject:comments forKey:@"Comments"];
	}	
	
	if (taskIdentity != nil && ![taskIdentity isKindOfClass:[NSNull class]] && ![taskIdentity isEqualToString:NULL_STRING]) {
		NSDictionary *taskDict = [NSDictionary dictionaryWithObject:taskIdentity forKey:@"Identity"];
		[propertiesDictionary setObject:taskDict forKey:@"Task"];
	}
	else if (taskIdentity == nil && projectIdentity != nil && ![projectIdentity isEqualToString:NO_CLIENT_ID]) {
		
		NSString *projectTaskIdentity = [supportDataModel getProjectRootTaskIdentity:projectIdentity]; 
		if (projectTaskIdentity != nil && ![projectTaskIdentity isKindOfClass:[NSNull class]]) {
			NSDictionary *taskDict = [NSDictionary dictionaryWithObject:projectTaskIdentity forKey:@"Identity"];
			[propertiesDictionary setObject:taskDict forKey:@"Task"];
		}
	}else if (taskIdentity == nil && (projectIdentity == nil || [projectIdentity isEqualToString:NO_CLIENT_ID])){
		//taskIdentity =(NSString *) [NSNull null];
		[propertiesDictionary setObject:[NSNull null] forKey:@"Task"];
		
	}
	if (activityIdentity != nil && ![activityIdentity isKindOfClass:[NSNull class]] && ![activityIdentity isEqualToString:NULL_STRING]) {
		if (![activityIdentity isEqualToString:@""]) {
            NSDictionary *activityDict = [NSDictionary dictionaryWithObject:activityIdentity forKey:@"Identity"];
            [propertiesDictionary setObject:activityDict forKey:@"Activity"];
        }
        else
        {
            NSDictionary *activityDict = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"Identity"];
            [propertiesDictionary setObject:activityDict forKey:@"Activity"];
        }
        
	}
	
	if (timeHours != nil && ![timeHours isKindOfClass:[NSNull class]]) {
		NSDictionary *timeDict = [G2Util convertDecimalHoursToApiTimeDict:timeHours];
		if (timeDict != nil && [timeDict isKindOfClass:[NSDictionary class]]) {
			[propertiesDictionary setObject:timeDict forKey:@"Duration"];
		}
	}	
	
	NSMutableDictionary *clientPropertyDict = nil;
	if ([[_timeEntryObject clientAllocationId] isEqualToString:PROJECT_TYPE_BUCKET]) {
		NSString *clientId = [_timeEntryObject clientIdentity];
		NSMutableDictionary *clientDict = [NSMutableDictionary dictionaryWithObject:clientId forKey:@"Identity"];
		
		clientPropertyDict = [NSMutableDictionary dictionaryWithObject:clientDict forKey:@"Client"];
		[clientPropertyDict setObject:@"SetProperties" forKey:@"__operation"];
	}
    //US4006//Juhi
//	else {
//		clientPropertyDict = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"Client"];
//		[clientPropertyDict setObject:@"SetProperties" forKey:@"__operation"];
//	}
    
	
	NSMutableDictionary *billingOperationDictionary = [NSMutableDictionary dictionary];
	
	
	////////////////////////////////////////////////////////////////////////////////////////////
	if (billingIdentity != nil && ![billingIdentity isKindOfClass:[NSNull class]] && ![billingIdentity isEqualToString:NULL_STRING]) {
		
		NSMutableDictionary *billingTypeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
												@"Replicon.Project.Domain.Timesheets.TimesheetBillingType",@"__type",
												nil];
		NSDictionary *projectRoleDict = nil;
		DLog(@"projectRoleId %@",projectRoleId);
		if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]
			&& ![billingIdentity isEqualToString:BILLING_NONBILLABLE]) {
			
			billingIdentity = BILLING_ROLE_RATE;
			projectRoleDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",projectRoleId],@"Identity",@"Replicon.Project.Domain.ProjectRole",@"__type",
                               nil];
		}
		else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
			projectRoleDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",projectRoleId],@"Identity",@"Replicon.Domain.Department",@"__type",
                               nil];
		}
		if (doesUserHaveViewOrEditBilling)
        {
           
            [billingTypeDict setObject:billingIdentity forKey:@"Identity"];//US4006 Ullas M L
            [billingOperationDictionary setObject:billingTypeDict forKey:@"BillingType"];//US4006 Ullas M L 
            [billingOperationDictionary setObject:@"SetTimeEntryBilling" forKey:@"__operation"];//US4006 Ullas M L 
        }
        else if (billingIdentity!=nil && ![billingIdentity isKindOfClass:[NSNull class]])
        {
            if ([billingIdentity isEqualToString:BILLING_NONBILLABLE])
            {
                [billingTypeDict setObject:billingIdentity forKey:@"Identity"];
                [billingOperationDictionary setObject:billingTypeDict forKey:@"BillingType"];
                [billingOperationDictionary setObject:@"SetTimeEntryBilling" forKey:@"__operation"];
            }
        }
        
//        [billingTypeDict setObject:billingIdentity forKey:@"Identity"];//US4006 Ullas M L
//        [billingOperationDictionary setObject:billingTypeDict forKey:@"BillingType"];//US4006 Ullas M L
//        [billingOperationDictionary setObject:@"SetTimeEntryBilling" forKey:@"__operation"];//US4006 Ullas M L
		
		
		if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]
			&& ![billingIdentity isEqualToString:BILLING_NONBILLABLE]) {
			[billingOperationDictionary setObject:projectRoleDict forKey:@"ProjectRole"];
		}
		else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
			[billingOperationDictionary setObject:projectRoleDict forKey:@"BillingDepartment"];
		}
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////
    
	if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]] 
		&& ![projectIdentity isEqualToString:NO_CLIENT_ID]
		&& ![projectIdentity isEqualToString:@""]) {
		NSDictionary *projectDictionary     = [NSDictionary dictionaryWithObjectsAndKeys:
											   @"Replicon.Project.Domain.Project",@"__type",
											   projectIdentity,@"Identity",nil];
		[billingOperationDictionary setObject:projectDictionary forKey:@"Project"];
	}
    NSMutableDictionary *rowUDFPropertyDict = nil;
    if([[_timeEntryObject rowUDFArray]count]>0)
    {
        rowUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetRowUdfValues" forKey:@"__operation"];
        for (int k=0; k<[[_timeEntryObject rowUDFArray]count]; k++) {
            NSDictionary *fetchDict=[[_timeEntryObject rowUDFArray] objectAtIndex:k];
            for (id key in fetchDict) {
                [rowUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
            }
        }
    }
    
    NSMutableDictionary *cellUDFPropertyDict = nil;
    if([[_timeEntryObject cellUDFArray]count]>0)
    {
        cellUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetCellUdfValues" forKey:@"__operation"];
        for (int k=0; k<[[_timeEntryObject cellUDFArray]count]; k++) {
            NSDictionary *fetchDict=[[_timeEntryObject cellUDFArray] objectAtIndex:k];
            for (id key in fetchDict) {
                [cellUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
            }
        }
    }
    
	
    NSMutableArray *innerOperationsArray=[NSMutableArray array];
    if (propertiesDictionary1) {
        [innerOperationsArray addObject:propertiesDictionary1]; 
    }
    if (propertiesDictionary) {
        [innerOperationsArray addObject:propertiesDictionary]; 
    }
    
    if (rowUDFPropertyDict) {
        [innerOperationsArray addObject:rowUDFPropertyDict]; 
    }
    
    if (cellUDFPropertyDict) {
        [innerOperationsArray addObject:cellUDFPropertyDict]; 
    }
    
    if (billingOperationDictionary) {
        //US4006//Juhi
      
        if (doesUserHaveViewOrEditBilling)
        {
            [innerOperationsArray addObject:billingOperationDictionary];
        }
        else if (billingIdentity!=nil && ![billingIdentity isKindOfClass:[NSNull class]])
        {
            if ([billingIdentity isEqualToString:BILLING_NONBILLABLE])
            {
                [innerOperationsArray addObject:billingOperationDictionary];
            }
        }
        
    }
    
    if (clientPropertyDict) {
        [innerOperationsArray addObject:clientPropertyDict]; 
    }
    
    
	
	NSDictionary *mainOperationDict				= [NSDictionary dictionaryWithObjectsAndKeys:
												   @"CollectionEdit",@"__operation",
												   @"TimeEntries",@"Collection",
												   innerOperationsArray,@"Operations",
												   entryIdentity,@"Identity",nil];
	
	NSArray      *outerOperationsArray			= [NSArray arrayWithObject:mainOperationDict];
	NSDictionary *queryDict						= [NSDictionary dictionaryWithObjectsAndKeys:
												   @"Edit",@"Action",
												   @"Replicon.Suite.Domain.EntryTimesheet",@"Type",
												   sheetIdentity,@"Identity",
												   outerOperationsArray,@"Operations",nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TESTING QUERY:::::sendRequestToEditTheTimeEntryDetailsWithUserData:: %@",str);
    str=[str stringByReplacingOccurrencesOfString:@"{\"Identity\":null}" withString:@"null"];
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"EditTimeEntry"]];
	[self setServiceDelegate:self];
	[self executeRequest];
	
	
}


-(void)sendRequestToEditTheTimeOffEntryDetailsWithUserData:(G2TimeOffEntryObject *)entryObject
{

	
    
    
	NSString *sheetIdentity = [entryObject sheetId];
    
    NSString *entryIdentity=[entryObject identity];
	
	NSDate *entryDate = [entryObject timeOffDate];
	NSDictionary *entryDateDict = [G2Util convertDateToApiDateDictionary:entryDate];
 	NSMutableDictionary *propertiesOperationDict = [NSMutableDictionary dictionary];
    
	
    
    
	if (entryDateDict != nil && [entryDateDict isKindOfClass:[NSDictionary class]]) {
		[propertiesOperationDict setObject:entryDateDict forKey:@"EntryDate"];
	}
	
	
    NSDictionary *timeOffCodeDict = [NSDictionary dictionaryWithObject:[entryObject typeIdentity] forKey:@"Identity"];
    if (timeOffCodeDict != nil && [timeOffCodeDict isKindOfClass:[NSDictionary class]]) {
		[propertiesOperationDict setObject:timeOffCodeDict forKey:@"TimeOffCode"];
	}
    
	NSString *comments = [entryObject comments];
	if (comments != nil && ![comments isKindOfClass:[NSNull class]] && ![comments isEqualToString:NULL_STRING]) {
		[propertiesOperationDict setObject:comments forKey:@"Comments"];
	}
	
	
	[propertiesOperationDict setObject:@"SetProperties" forKey:@"__operation"];
	
	
	
	NSString *timeHours = [entryObject numberOfHours];
	if (timeHours != nil && ![timeHours isKindOfClass:[NSNull class]]) {
		DLog(@"String time is %@",timeHours);
		NSDictionary *timeDict = [G2Util convertDecimalHoursToApiTimeDict:timeHours];
		if (timeDict != nil && [timeDict isKindOfClass:[NSDictionary class]]) {
			[propertiesOperationDict setObject:timeDict forKey:@"Duration"];
		}
	}
	
    
	
    
    NSMutableDictionary *uUDFPropertyDict = nil;
    if([[entryObject udfArray]count]>0)
    {
        uUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetUdfValues" forKey:@"__operation"];
        for (int k=0; k<[[entryObject udfArray]count]; k++) {
            NSDictionary *fetchDict=[[entryObject udfArray] objectAtIndex:k];
            for (id key in fetchDict) {
                [uUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
            }
        }
    }
    
    
    
    NSMutableArray *subOperationsArray=[NSMutableArray array];
    
    if (propertiesOperationDict) {
        [subOperationsArray addObject:propertiesOperationDict]; 
    }
    
    if (uUDFPropertyDict) {
        [subOperationsArray addObject:uUDFPropertyDict]; 
    }
    
    
    
	
	NSDictionary *mainOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   @"CollectionEdit",@"__operation",
									   @"TimeOffEntries",@"Collection",
									   subOperationsArray,@"Operations",
                                        entryIdentity,@"Identity",nil];
									   
	
	NSArray *mainOperationsArray = [NSArray arrayWithObject:mainOperationDict];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Edit",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"Type",
							 sheetIdentity,@"Identity",
							 mainOperationsArray,@"Operations",
							 nil];
	
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    //    str=[str stringByReplacingOccurrencesOfString:@"\"null\"" withString:@"\"\""];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"EditTimeOffEntry"]];
	[self setServiceDelegate:self];
	[self executeRequest];

	
	
}

-(void)sendRequestToEditTheTimeEntryDetailsWithUserDataForInOutTimesheets:(G2TimeSheetEntryObject *)_timeEntryObject
{
	DLog(@"sendRequestToEditTheTimeEntryDetailsWithUserData::::TimeSheetService");
	NSString     *projectIdentity       = [_timeEntryObject projectIdentity];
	NSString     *billingIdentity       = [_timeEntryObject billingIdentity];
	NSString     *activityIdentity		= [_timeEntryObject activityIdentity];
	//NSString     *taskIdentity		    = [_timeEntryObject taskIdentity];
	NSString     *taskIdentity		    = [_timeEntryObject.taskObj taskIdentity];
	NSString     *comments				= [_timeEntryObject comments];
	NSDate		 *entryDate				= [_timeEntryObject entryDate];
	NSString	 *sheetIdentity			= [_timeEntryObject sheetId];
	NSNumber	 *projectRoleId			= [_timeEntryObject projectRoleId];
    //	NSString     *timeHours				= [_timeEntryObject numberOfHours];
	NSString	 *entryIdentity         = [_timeEntryObject identity];
	BOOL doesUserHaveViewOrEditBilling   = [self checkForPermissionExistence:@"BillingTimesheet"];//US4006//Juhi
    
    if([_timeEntryObject projectBillableStatus]!=nil && ![[_timeEntryObject projectBillableStatus] isKindOfClass:[NSNull class]])
    {
        if ([[_timeEntryObject projectBillableStatus] isEqualToString:@"AllowBillable"])
        {
            doesUserHaveViewOrEditBilling=TRUE;
        }
    }
    
	NSDictionary *entryDateDict			= [G2Util convertDateToApiDateDictionary:entryDate];
	
	NSMutableDictionary *propertiesDictionary     = [NSMutableDictionary dictionary];
    NSMutableDictionary *propertiesDictionary1     = [NSMutableDictionary dictionary]; 
	
	NSMutableDictionary *calculationModeDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      @"Replicon.TimeSheet.Domain.CalculationModeObject",@"__type",
                                                      @"CalculateDuration",@"Identity",nil];
	[propertiesDictionary1 setObject:@"SetProperties" forKey:@"__operation"];
	[propertiesDictionary1 setObject:calculationModeDictionary forKey:@"CalculationModeObject"];
	
	if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]]) {
		//[propertiesDictionary setObject:projectIdentity forKey:@"Identity"];
	}
	[propertiesDictionary setObject:@"SetProperties" forKey:@"__operation"];
	
	if (entryDateDict != nil && [entryDateDict isKindOfClass:[NSDictionary class]]) {
		[propertiesDictionary setObject:entryDateDict forKey:@"EntryDate"];
	}
	if (comments != nil && ![comments isKindOfClass:[NSNull class]] && ![comments isEqualToString:NULL_STRING]) {
		[propertiesDictionary setObject:comments forKey:@"Comments"];
	}	
	
	if (taskIdentity != nil && ![taskIdentity isKindOfClass:[NSNull class]] && ![taskIdentity isEqualToString:NULL_STRING]) {
		NSDictionary *taskDict = [NSDictionary dictionaryWithObject:taskIdentity forKey:@"Identity"];
		[propertiesDictionary setObject:taskDict forKey:@"Task"];
	}
	else if (taskIdentity == nil && projectIdentity != nil && ![projectIdentity isEqualToString:NO_CLIENT_ID]) {
		
		NSString *projectTaskIdentity = [supportDataModel getProjectRootTaskIdentity:projectIdentity]; 
		if (projectTaskIdentity != nil && ![projectTaskIdentity isKindOfClass:[NSNull class]]) {
			NSDictionary *taskDict = [NSDictionary dictionaryWithObject:projectTaskIdentity forKey:@"Identity"];
			[propertiesDictionary setObject:taskDict forKey:@"Task"];
		}
	}else if (taskIdentity == nil && (projectIdentity == nil || [projectIdentity isEqualToString:NO_CLIENT_ID])){
		//taskIdentity =(NSString *) [NSNull null];
		[propertiesDictionary setObject:[NSNull null] forKey:@"Task"];
		
	}
	if (activityIdentity != nil && ![activityIdentity isKindOfClass:[NSNull class]] && ![activityIdentity isEqualToString:NULL_STRING]) {
		if (![activityIdentity isEqualToString:@""]) {
            NSDictionary *activityDict = [NSDictionary dictionaryWithObject:activityIdentity forKey:@"Identity"];
            [propertiesDictionary setObject:activityDict forKey:@"Activity"];
        }
        else
        {
            NSDictionary *activityDict = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"Identity"];
            [propertiesDictionary setObject:activityDict forKey:@"Activity"];
        }
        
	}
	
    //	if (timeHours != nil && ![timeHours isKindOfClass:[NSNull class]]) {
    //		NSDictionary *timeDict = [Util convertDecimalHoursToApiTimeDict:timeHours];
    //		if (timeDict != nil && [timeDict isKindOfClass:[NSDictionary class]]) {
    //			[propertiesDictionary setObject:timeDict forKey:@"Duration"];
    //		}
    //	}	
	
    NSString *inTime=[_timeEntryObject inTime];
    if (inTime != nil && ![inTime isKindOfClass:[NSNull class]]) 
    {
        NSDictionary *inTimeDict = [G2Util convertTimeToHourMinutesSecondsFormat:inTime];
        if (inTimeDict != nil && [inTimeDict isKindOfClass:[NSDictionary class]]) 
        {
            [propertiesDictionary setObject:inTimeDict forKey:@"TimeIn"];
        }
    }
    
    NSString *outTime=[_timeEntryObject outTime];
    if (outTime != nil && ![outTime isKindOfClass:[NSNull class]]) 
    {
        NSDictionary *outTimeDict = [G2Util convertTimeToHourMinutesSecondsFormat:outTime];
        if (outTimeDict != nil && [outTimeDict isKindOfClass:[NSDictionary class]]) 
        {
            [propertiesDictionary setObject:outTimeDict forKey:@"TimeOut"];
        }
    }
    
    
	NSMutableDictionary *clientPropertyDict = nil;
	if ([[_timeEntryObject clientAllocationId] isEqualToString:PROJECT_TYPE_BUCKET]) {
		NSString *clientId = [_timeEntryObject clientIdentity];
		NSMutableDictionary *clientDict = [NSMutableDictionary dictionaryWithObject:clientId forKey:@"Identity"];
		
		clientPropertyDict = [NSMutableDictionary dictionaryWithObject:clientDict forKey:@"Client"];
		[clientPropertyDict setObject:@"SetProperties" forKey:@"__operation"];
	}
    //US4006//Juhi
//	else {
//		clientPropertyDict = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"Client"];
//		[clientPropertyDict setObject:@"SetProperties" forKey:@"__operation"];
//	}
    
	
	NSMutableDictionary *billingOperationDictionary = [NSMutableDictionary dictionary];
	
	
	////////////////////////////////////////////////////////////////////////////////////////////
	if (billingIdentity != nil && ![billingIdentity isKindOfClass:[NSNull class]] && ![billingIdentity isEqualToString:NULL_STRING]) {
		
		NSMutableDictionary *billingTypeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
												@"Replicon.Project.Domain.Timesheets.TimesheetBillingType",@"__type",
												nil];
		NSDictionary *projectRoleDict = nil;
		DLog(@"projectRoleId %@",projectRoleId);
		if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]
			&& ![billingIdentity isEqualToString:BILLING_NONBILLABLE]) {
			
			billingIdentity = BILLING_ROLE_RATE;
			projectRoleDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",projectRoleId],@"Identity",@"Replicon.Project.Domain.ProjectRole",@"__type",
                               nil];
		}
		else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
			projectRoleDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",projectRoleId],@"Identity",@"Replicon.Domain.Department",@"__type",
                               nil];
		}
		
        if (doesUserHaveViewOrEditBilling) 
        {
         [billingTypeDict setObject:billingIdentity forKey:@"Identity"];//US4006 Ullas M L
         [billingOperationDictionary setObject:billingTypeDict forKey:@"BillingType"];//US4006 Ullas M L 
         [billingOperationDictionary setObject:@"SetTimeEntryBilling" forKey:@"__operation"];//US4006 Ullas M L 
        }
        else if (billingIdentity!=nil && ![billingIdentity isKindOfClass:[NSNull class]])
        {
            if ([billingIdentity isEqualToString:BILLING_NONBILLABLE])
            {
                [billingTypeDict setObject:billingIdentity forKey:@"Identity"];
                [billingOperationDictionary setObject:billingTypeDict forKey:@"BillingType"];
                [billingOperationDictionary setObject:@"SetTimeEntryBilling" forKey:@"__operation"];
            }
        }
        //sending billing information if doesUserHaveViewOrEditBilling is yes else not sending
        //If user does not have "View/select billing options for projects/tasks" permission enabled, do not require the "Billing" field to be sent in the API request.
        

		
		
		if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]
			&& ![billingIdentity isEqualToString:BILLING_NONBILLABLE]) {
			[billingOperationDictionary setObject:projectRoleDict forKey:@"ProjectRole"];
		}
		else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
			[billingOperationDictionary setObject:projectRoleDict forKey:@"BillingDepartment"];
		}
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////
    
	if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]] 
		&& ![projectIdentity isEqualToString:NO_CLIENT_ID]
		&& ![projectIdentity isEqualToString:@""]) {
		NSDictionary *projectDictionary     = [NSDictionary dictionaryWithObjectsAndKeys:
											   @"Replicon.Project.Domain.Project",@"__type",
											   projectIdentity,@"Identity",nil];
		[billingOperationDictionary setObject:projectDictionary forKey:@"Project"];
	}
    NSMutableDictionary *rowUDFPropertyDict = nil;
    if([[_timeEntryObject rowUDFArray]count]>0)
    {
        rowUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetRowUdfValues" forKey:@"__operation"];
        for (int k=0; k<[[_timeEntryObject rowUDFArray]count]; k++) {
            NSDictionary *fetchDict=[[_timeEntryObject rowUDFArray] objectAtIndex:k];
            for (id key in fetchDict) {
                [rowUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
            }
        }
    }
    
    NSMutableDictionary *cellUDFPropertyDict = nil;
    if([[_timeEntryObject cellUDFArray]count]>0)
    {
        cellUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetCellUdfValues" forKey:@"__operation"];
        for (int k=0; k<[[_timeEntryObject cellUDFArray]count]; k++) {
            NSDictionary *fetchDict=[[_timeEntryObject cellUDFArray] objectAtIndex:k];
            for (id key in fetchDict) {
                [cellUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
            }
        }
    }
    
	
    NSMutableArray *innerOperationsArray=[NSMutableArray array];
    if (propertiesDictionary1) {
        [innerOperationsArray addObject:propertiesDictionary1]; 
    }
    if (propertiesDictionary) {
        [innerOperationsArray addObject:propertiesDictionary]; 
    }
    
    if (rowUDFPropertyDict) {
        [innerOperationsArray addObject:rowUDFPropertyDict]; 
    }
    
    if (cellUDFPropertyDict) {
        [innerOperationsArray addObject:cellUDFPropertyDict]; 
    }
    
    if (billingOperationDictionary) {
        //US4006//Juhi
        //BOOL doesUserHaveViewOrEditBilling   = [self checkForPermissionExistence:@"BillingTimesheet"];
        if (doesUserHaveViewOrEditBilling) 
        {
            [innerOperationsArray addObject:billingOperationDictionary];
        }
        else if (billingIdentity!=nil && ![billingIdentity isKindOfClass:[NSNull class]])
        {
            if ([billingIdentity isEqualToString:BILLING_NONBILLABLE])
            {
                [innerOperationsArray addObject:billingOperationDictionary];
            }
        }
        
    }

    
    if (clientPropertyDict) {
        [innerOperationsArray addObject:clientPropertyDict]; 
    }
    
    
	NSDictionary *mainOperationDict				= [NSDictionary dictionaryWithObjectsAndKeys:
												   @"CollectionEdit",@"__operation",
												   @"TimeEntries",@"Collection",
												   innerOperationsArray,@"Operations",
												   entryIdentity,@"Identity",nil];
	
	NSArray      *outerOperationsArray			= [NSArray arrayWithObject:mainOperationDict];
	NSDictionary *queryDict						= [NSDictionary dictionaryWithObjectsAndKeys:
												   @"Edit",@"Action",
												   @"Replicon.Suite.Domain.EntryTimesheet",@"Type",
												   sheetIdentity,@"Identity",
												   outerOperationsArray,@"Operations",nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TESTING QUERY:::::sendRequestToEditTheTimeEntryDetailsWithUserData:: %@",str);
    str=[str stringByReplacingOccurrencesOfString:@"{\"Identity\":null}" withString:@"null"];
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"EditTimeEntry"]];
	[self setServiceDelegate:self];
	[self executeRequest];
	
	
}
//US4513 Ullas
-(void)sendRequestToEditTheTimeEntryDetailsWithUserDataForNewInOutTimesheets:(NSMutableArray *)_timeEntryObjectArray
{
    BOOL isEntryDateInTimeSheetPeriod=NO;
    NSMutableArray *jsonPayloadArray=[NSMutableArray array];
	for (int count=0; count<[_timeEntryObjectArray count]; count++) {
        G2TimeSheetEntryObject *_timeEntryObject=[_timeEntryObjectArray objectAtIndex:count];
        NSNumber *sheetIdentityNumber=[NSNumber numberWithInt:[[_timeEntryObject sheetId]intValue]];
        isEntryDateInTimeSheetPeriod=[timesheetModel checkWhetherEntryDateFalssInTimeSheetPeriod:[_timeEntryObject entryDate] :sheetIdentityNumber];
        if (count==0) {
            
            DLog(@"sendRequestToEditTheTimeEntryDetailsWithUserData::::TimeSheetService");
            NSString     *projectIdentity       = [_timeEntryObject projectIdentity];
            NSString     *billingIdentity       = [_timeEntryObject billingIdentity];
            NSString     *activityIdentity		= [_timeEntryObject activityIdentity];
            //NSString     *taskIdentity		    = [_timeEntryObject taskIdentity];
            NSString     *taskIdentity		    = [_timeEntryObject.taskObj taskIdentity];
            NSString     *comments				= [_timeEntryObject comments];
            NSDate		 *entryDate				= [_timeEntryObject entryDate];
            NSString	 *sheetIdentity			= [_timeEntryObject sheetId];
            NSNumber	 *projectRoleId			= [_timeEntryObject projectRoleId];
            //	NSString     *timeHours				= [_timeEntryObject numberOfHours];
            NSString	 *entryIdentity         = [_timeEntryObject identity];
            
            NSDictionary *entryDateDict			= [G2Util convertDateToApiDateDictionary:entryDate];
            
            NSMutableDictionary *propertiesDictionary     = [NSMutableDictionary dictionary];
            NSMutableDictionary *propertiesDictionary1     = [NSMutableDictionary dictionary]; 
            
            NSMutableDictionary *calculationModeDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                              @"Replicon.TimeSheet.Domain.CalculationModeObject",@"__type",
                                                              @"CalculateDuration",@"Identity",nil];
            [propertiesDictionary1 setObject:@"SetProperties" forKey:@"__operation"];
            [propertiesDictionary1 setObject:calculationModeDictionary forKey:@"CalculationModeObject"];
            
            if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]]) {
                //[propertiesDictionary setObject:projectIdentity forKey:@"Identity"];
            }
            [propertiesDictionary setObject:@"SetProperties" forKey:@"__operation"];
            
            if (entryDateDict != nil && [entryDateDict isKindOfClass:[NSDictionary class]]) {
                [propertiesDictionary setObject:entryDateDict forKey:@"EntryDate"];
            }
            if (comments != nil && ![comments isKindOfClass:[NSNull class]] && ![comments isEqualToString:NULL_STRING]) {
                [propertiesDictionary setObject:comments forKey:@"Comments"];
            }	
            
            if (taskIdentity != nil && ![taskIdentity isKindOfClass:[NSNull class]] && ![taskIdentity isEqualToString:NULL_STRING]) {
                NSDictionary *taskDict = [NSDictionary dictionaryWithObject:taskIdentity forKey:@"Identity"];
                [propertiesDictionary setObject:taskDict forKey:@"Task"];
            }
            else if (taskIdentity == nil && projectIdentity != nil && ![projectIdentity isEqualToString:NO_CLIENT_ID]) {
                
                NSString *projectTaskIdentity = [supportDataModel getProjectRootTaskIdentity:projectIdentity]; 
                if (projectTaskIdentity != nil && ![projectTaskIdentity isKindOfClass:[NSNull class]]) {
                    NSDictionary *taskDict = [NSDictionary dictionaryWithObject:projectTaskIdentity forKey:@"Identity"];
                    [propertiesDictionary setObject:taskDict forKey:@"Task"];
                }
            }else if (taskIdentity == nil && (projectIdentity == nil || [projectIdentity isEqualToString:NO_CLIENT_ID])){
                //taskIdentity =(NSString *) [NSNull null];
                [propertiesDictionary setObject:[NSNull null] forKey:@"Task"];
                
            }
            if (activityIdentity != nil && ![activityIdentity isKindOfClass:[NSNull class]] && ![activityIdentity isEqualToString:NULL_STRING]) {
                if (![activityIdentity isEqualToString:@""]) {
                    NSDictionary *activityDict = [NSDictionary dictionaryWithObject:activityIdentity forKey:@"Identity"];
                    [propertiesDictionary setObject:activityDict forKey:@"Activity"];
                }
                else
                {
                    NSDictionary *activityDict = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"Identity"];
                    [propertiesDictionary setObject:activityDict forKey:@"Activity"];
                }
                
            }
            
            //	if (timeHours != nil && ![timeHours isKindOfClass:[NSNull class]]) {
            //		NSDictionary *timeDict = [Util convertDecimalHoursToApiTimeDict:timeHours];
            //		if (timeDict != nil && [timeDict isKindOfClass:[NSDictionary class]]) {
            //			[propertiesDictionary setObject:timeDict forKey:@"Duration"];
            //		}
            //	}	
            
            NSString *inTime=[_timeEntryObject inTime];
            if (inTime != nil && ![inTime isKindOfClass:[NSNull class]]) 
            {
                NSDictionary *inTimeDict = [G2Util convertTimeToHourMinutesSecondsFormat:inTime];
                if (inTimeDict != nil && [inTimeDict isKindOfClass:[NSDictionary class]]) 
                {
                    [propertiesDictionary setObject:inTimeDict forKey:@"TimeIn"];
                }
            }
            
            NSString *outTime=[_timeEntryObject outTime];
            if (outTime != nil && ![outTime isKindOfClass:[NSNull class]]) 
            {
                NSDictionary *outTimeDict = [G2Util convertTimeToHourMinutesSecondsFormat:outTime];
                if (outTimeDict != nil && [outTimeDict isKindOfClass:[NSDictionary class]]) 
                {
                    [propertiesDictionary setObject:outTimeDict forKey:@"TimeOut"];
                }
            }
            
            
            NSMutableDictionary *clientPropertyDict = nil;
            if ([[_timeEntryObject clientAllocationId] isEqualToString:PROJECT_TYPE_BUCKET]) {
                NSString *clientId = [_timeEntryObject clientIdentity];
                NSMutableDictionary *clientDict = [NSMutableDictionary dictionaryWithObject:clientId forKey:@"Identity"];
                
                clientPropertyDict = [NSMutableDictionary dictionaryWithObject:clientDict forKey:@"Client"];
                [clientPropertyDict setObject:@"SetProperties" forKey:@"__operation"];
            }
            else {
                clientPropertyDict = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"Client"];
                [clientPropertyDict setObject:@"SetProperties" forKey:@"__operation"];
            }
            
            
            NSMutableDictionary *billingOperationDictionary = [NSMutableDictionary dictionary];
            [billingOperationDictionary setObject:@"SetTimeEntryBilling" forKey:@"__operation"];
            
            ////////////////////////////////////////////////////////////////////////////////////////////
            if (billingIdentity != nil && ![billingIdentity isKindOfClass:[NSNull class]] && ![billingIdentity isEqualToString:NULL_STRING]) {
                
                NSMutableDictionary *billingTypeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                        @"Replicon.Project.Domain.Timesheets.TimesheetBillingType",@"__type",
                                                        nil];
                NSDictionary *projectRoleDict = nil;
                DLog(@"projectRoleId %@",projectRoleId);
                if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]
                    && ![billingIdentity isEqualToString:BILLING_NONBILLABLE]) {
                    
                    billingIdentity = BILLING_ROLE_RATE;
                    projectRoleDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",projectRoleId],@"Identity",@"Replicon.Project.Domain.ProjectRole",@"__type",
                                       nil];
                }
                else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
                    projectRoleDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",projectRoleId],@"Identity",@"Replicon.Domain.Department",@"__type",
                                       nil];
                }
                
                [billingTypeDict setObject:billingIdentity forKey:@"Identity"];
                [billingOperationDictionary setObject:billingTypeDict forKey:@"BillingType"];
                
                if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]
                    && ![billingIdentity isEqualToString:BILLING_NONBILLABLE]) {
                    [billingOperationDictionary setObject:projectRoleDict forKey:@"ProjectRole"];
                }
                else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
                    [billingOperationDictionary setObject:projectRoleDict forKey:@"BillingDepartment"];
                }
            }
            /////////////////////////////////////////////////////////////////////////////////////////////////
            
            if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]] 
                && ![projectIdentity isEqualToString:NO_CLIENT_ID]
                && ![projectIdentity isEqualToString:@""]) {
                NSDictionary *projectDictionary     = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       @"Replicon.Project.Domain.Project",@"__type",
                                                       projectIdentity,@"Identity",nil];
                [billingOperationDictionary setObject:projectDictionary forKey:@"Project"];
            }
            NSMutableDictionary *rowUDFPropertyDict = nil;
            if([[_timeEntryObject rowUDFArray]count]>0)
            {
                rowUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetRowUdfValues" forKey:@"__operation"];
                for (int k=0; k<[[_timeEntryObject rowUDFArray]count]; k++) {
                    NSDictionary *fetchDict=[[_timeEntryObject rowUDFArray] objectAtIndex:k];
                    for (id key in fetchDict) {
                        [rowUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
                    }
                }
            }
            
            NSMutableDictionary *cellUDFPropertyDict = nil;
            if([[_timeEntryObject cellUDFArray]count]>0)
            {
                cellUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetCellUdfValues" forKey:@"__operation"];
                for (int k=0; k<[[_timeEntryObject cellUDFArray]count]; k++) {
                    NSDictionary *fetchDict=[[_timeEntryObject cellUDFArray] objectAtIndex:k];
                    for (id key in fetchDict) {
                        [cellUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
                    }
                }
            }
            
            
            NSMutableArray *innerOperationsArray=[NSMutableArray array];
            if (propertiesDictionary1) {
                [innerOperationsArray addObject:propertiesDictionary1]; 
            }
            if (propertiesDictionary) {
                [innerOperationsArray addObject:propertiesDictionary]; 
            }
            
            if (rowUDFPropertyDict) {
                [innerOperationsArray addObject:rowUDFPropertyDict]; 
            }
            
            if (cellUDFPropertyDict) {
                [innerOperationsArray addObject:cellUDFPropertyDict]; 
            }
            
            if (billingOperationDictionary) {
                [innerOperationsArray addObject:billingOperationDictionary]; 
            }
            
            if (clientPropertyDict) {
                [innerOperationsArray addObject:clientPropertyDict]; 
            }
            
            
            NSDictionary *mainOperationDict				= [NSDictionary dictionaryWithObjectsAndKeys:
                                                           @"CollectionEdit",@"__operation",
                                                           @"TimeEntries",@"Collection",
                                                           innerOperationsArray,@"Operations",
                                                           entryIdentity,@"Identity",nil];
            
            NSArray      *outerOperationsArray			= [NSArray arrayWithObject:mainOperationDict];
            NSDictionary *queryDict						= [NSDictionary dictionaryWithObjectsAndKeys:
                                                           @"Edit",@"Action",
                                                           @"Replicon.Suite.Domain.EntryTimesheet",@"Type",
                                                           sheetIdentity,@"Identity",
                                                          outerOperationsArray,@"Operations",nil];
            //if (isEntryDateInTimeSheetPeriod)
            //{
                [jsonPayloadArray addObject:queryDict];//4513 Defect
            //}
                       
        }
        
        else
        {
            
                NSString *sheetIdentity = [_timeEntryObject sheetId];
                
                NSDate *entryDate = [_timeEntryObject entryDate];
                NSDictionary *entryDateDict = [G2Util convertDateToApiDateDictionary:entryDate];
                NSMutableDictionary *propertiesOperationDict = [NSMutableDictionary dictionary];
                NSMutableDictionary *propertiesOperationDict1 = [NSMutableDictionary dictionary];
                
                if (entryDateDict != nil && [entryDateDict isKindOfClass:[NSDictionary class]]) {
                    [propertiesOperationDict setObject:entryDateDict forKey:@"EntryDate"];
                }
                
                
                NSString *comments = [_timeEntryObject comments];
                if (comments != nil && ![comments isKindOfClass:[NSNull class]] && ![comments isEqualToString:NULL_STRING]) {
                    [propertiesOperationDict setObject:comments forKey:@"Comments"];
                }
                
                //NSString *taskIdentity = [entryObject taskIdentity];
                NSString *taskIdentity = [_timeEntryObject.taskObj taskIdentity];
                NSString *projectIdentity = [_timeEntryObject projectIdentity];
                if (taskIdentity != nil && ![taskIdentity isKindOfClass:[NSNull class]] && ![taskIdentity isEqualToString:NULL_STRING]) {
                    NSDictionary *taskDict = [NSDictionary dictionaryWithObject:taskIdentity forKey:@"Identity"];
                    [propertiesOperationDict setObject:taskDict forKey:@"Task"];
                }
                else if (taskIdentity == nil && projectIdentity != nil && ![projectIdentity isEqualToString:NO_CLIENT_ID]) {
                    
                    NSString *projectTaskIdentity = [supportDataModel getProjectRootTaskIdentity:projectIdentity]; 
                    if (projectTaskIdentity != nil && ![projectTaskIdentity isKindOfClass:[NSNull class]]) {
                        NSDictionary *taskDict = [NSDictionary dictionaryWithObject:projectTaskIdentity forKey:@"Identity"];
                        [propertiesOperationDict setObject:taskDict forKey:@"Task"];
                    }
                }
                NSString *activityIdentity = [_timeEntryObject activityIdentity];
                if (activityIdentity != nil && ![activityIdentity isKindOfClass:[NSNull class]] && ![activityIdentity isEqualToString:NULL_STRING] && ![activityIdentity isEqualToString:@""]) {
                    NSDictionary *activityDict = [NSDictionary dictionaryWithObject:activityIdentity forKey:@"Identity"];
                    [propertiesOperationDict setObject:activityDict forKey:@"Activity"];
                }
                
                [propertiesOperationDict setObject:@"SetProperties" forKey:@"__operation"];
                
                NSDictionary *calculationModeDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     @"Replicon.TimeSheet.Domain.CalculationModeObject",@"__type",
                                                     @"CalculateDuration",@"Identity",
                                                     nil];
                [propertiesOperationDict1 setObject:@"SetProperties" forKey:@"__operation"];
                [propertiesOperationDict1 setObject:calculationModeDict forKey:@"CalculationModeObject"];
                
                //	NSString *timeHours = [entryObject numberOfHours];
                //	if (timeHours != nil && ![timeHours isKindOfClass:[NSNull class]]) {
                //		DLog(@"String time is %@",timeHours);
                //		NSDictionary *timeDict = [Util convertDecimalHoursToApiTimeDict:timeHours];
                //		if (timeDict != nil && [timeDict isKindOfClass:[NSDictionary class]]) {
                //			[propertiesOperationDict setObject:timeDict forKey:@"Duration"];
                //		}
                //	}
                
                NSString *inTime=[_timeEntryObject inTime];
                if (inTime != nil && ![inTime isKindOfClass:[NSNull class]]) 
                {
                    NSDictionary *inTimeDict = [G2Util convertTimeToHourMinutesSecondsFormat:inTime];
                    if (inTimeDict != nil && [inTimeDict isKindOfClass:[NSDictionary class]]) 
                    {
                        [propertiesOperationDict setObject:inTimeDict forKey:@"TimeIn"];
                    }
                }
                
                NSString *outTime=[_timeEntryObject outTime];
                if (outTime != nil && ![outTime isKindOfClass:[NSNull class]]) 
                {
                    NSDictionary *outTimeDict = [G2Util convertTimeToHourMinutesSecondsFormat:outTime];
                    if (outTimeDict != nil && [outTimeDict isKindOfClass:[NSDictionary class]]) 
                    {
                        [propertiesOperationDict setObject:outTimeDict forKey:@"TimeOut"];
                    }
                }
                
                NSMutableDictionary *billingOperationsDict = [NSMutableDictionary dictionary];
                NSMutableDictionary *billingTypeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                        @"Replicon.Project.Domain.Timesheets.TimesheetBillingType",@"__type",
                                                        nil];
                
                NSString *billingIdentity = [_timeEntryObject billingIdentity];
                NSNumber *projectRoleId = [_timeEntryObject projectRoleId];
                DLog(@"billing Identity %@",billingIdentity);
                if (billingIdentity != nil && ![billingIdentity isKindOfClass:[NSNull class]] && ![billingIdentity isEqualToString:NULL_STRING]) {
                    
                    
                    NSDictionary *projectRoleDict = nil;
                    if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]
                        && ![billingIdentity isEqualToString:BILLING_NONBILLABLE]) {
                        
                        billingIdentity = BILLING_ROLE_RATE;
                        projectRoleDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",projectRoleId]
                                                                      forKey:@"Identity"];
                    }
                    else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
                        projectRoleDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",projectRoleId]
                                                                      forKey:@"Identity"];
                    }
                    
                    [billingTypeDict setObject:billingIdentity forKey:@"Identity"];
                    [billingOperationsDict setObject:billingTypeDict forKey:@"BillingType"];
                    
                    if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]
                        && ![billingIdentity isEqualToString:BILLING_NONBILLABLE]) {
                        [billingOperationsDict setObject:projectRoleDict forKey:@"ProjectRole"];
                    }
                    else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
                        [billingOperationsDict setObject:projectRoleDict forKey:@"BillingDepartment"];
                    }
                }
                else {
                    [billingTypeDict setObject:BILLING_NONBILLABLE forKey:@"Identity"];
                    [billingOperationsDict setObject:billingTypeDict forKey:@"BillingType"];
                }
                
                //NSString *projectIdentity = [_timeEntryObject projectIdentity];
                if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]] && ![projectIdentity isEqualToString:NO_CLIENT_ID]) {
                    NSDictionary *projectDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 projectIdentity,@"Identity",
                                                 @"Replicon.Project.Domain.Project",@"__type",
                                                 nil];
                    [billingOperationsDict setObject:projectDict forKey:@"Project"];
                }
                
                [billingOperationsDict setObject:@"SetTimeEntryBilling" forKey:@"__operation"];
                
                NSMutableDictionary *clientPropertyDict = nil;
                if ([[_timeEntryObject clientAllocationId] isEqualToString:PROJECT_TYPE_BUCKET]) {
                    NSString *clientId = [_timeEntryObject clientIdentity];
                    NSMutableDictionary *clientDict = [NSMutableDictionary dictionaryWithObject:clientId forKey:@"Identity"];
                    
                    clientPropertyDict = [NSMutableDictionary dictionaryWithObject:clientDict forKey:@"Client"];
                    [clientPropertyDict setObject:@"SetProperties" forKey:@"__operation"];
                }
                
                NSMutableDictionary *rowUDFPropertyDict = nil;
                if([[_timeEntryObject rowUDFArray]count]>0)
                {
                    rowUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetRowUdfValues" forKey:@"__operation"];
                    for (int k=0; k<[[_timeEntryObject rowUDFArray]count]; k++) {
                        NSDictionary *fetchDict=[[_timeEntryObject rowUDFArray] objectAtIndex:k];
                        for (id key in fetchDict) {
                            [rowUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
                        }
                    }
                }
                
                NSMutableDictionary *cellUDFPropertyDict = nil;
                if([[_timeEntryObject cellUDFArray]count]>0)
                {
                    cellUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetCellUdfValues" forKey:@"__operation"];
                    for (int k=0; k<[[_timeEntryObject cellUDFArray]count]; k++) {
                        NSDictionary *fetchDict=[[_timeEntryObject cellUDFArray] objectAtIndex:k];
                        for (id key in fetchDict) {
                            [cellUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
                        }
                    }
                }
                
                NSMutableArray *subOperationsArray=[NSMutableArray array];
                if (propertiesOperationDict1) {
                    [subOperationsArray addObject:propertiesOperationDict1]; 
                }
                if (propertiesOperationDict) {
                    [subOperationsArray addObject:propertiesOperationDict]; 
                }
                
                if (rowUDFPropertyDict) {
                    [subOperationsArray addObject:rowUDFPropertyDict]; 
                }
                
                if (cellUDFPropertyDict) {
                    [subOperationsArray addObject:cellUDFPropertyDict]; 
                }
                
                if (billingOperationsDict) {
                    [subOperationsArray addObject:billingOperationsDict]; 
                }
                
                if (clientPropertyDict) {
                    [subOperationsArray addObject:clientPropertyDict]; 
                }
                
                
                
                NSDictionary *mainOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   @"CollectionAdd",@"__operation",
                                                   @"TimeEntries",@"Collection",
                                                   subOperationsArray,@"Operations",
                                                   nil];
                
                NSArray *mainOperationsArray = [NSArray arrayWithObject:mainOperationDict];
                
                NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                         @"Edit",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"Type",
                                         sheetIdentity,@"Identity",
                                         mainOperationsArray,@"Operations",
                                         nil];
                if (isEntryDateInTimeSheetPeriod)
                {
                    [jsonPayloadArray addObject:queryDict];
                }
                
            }

    }
    
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:jsonPayloadArray error:&err];
        DLog(@"TESTING QUERY:::::sendRequestToEditTheTimeEntryDetailsWithUserData:: %@",str);
        str=[str stringByReplacingOccurrencesOfString:@"{\"Identity\":null}" withString:@"null"];
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        [paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        
        [self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"EditTimeEntryForNewInOut"]];
        [self setServiceDelegate:self];
        [self executeRequest];
    
	
	
	
}





-(void)sendRequestToAddNewTimeEntryWithObject:(G2TimeSheetEntryObject *)entryObject {
  
    DLog(@"sendRequestToAddNewTimeEntryWithObject::::TimeSheetService");
	/*
	 [
	 {
	 "Action": "Edit",
	 "Type": "Replicon.Suite.Domain.EntryTimesheet",
	 "Identity": "11",
	 "Operations": [
     {
	 "__operation": "CollectionAdd",
	 "Collection": "TimeEntries",
	 "Operations": [
	 {
	 "__operation": "SetProperties",
	 "CalculationModeObject": {
	 "__type": "Replicon.TimeSheet.Domain.CalculationModeObject",
	 "Identity": "CalculateDuration"
	 },
	 "EntryDate": {
	 "__type": "Date",
	 "Year": 2011,
	 "Month": 5,
	 "Day": 3
	 },
	 "TimeIn": {
	 "__type": "Time",
	 "Hour": 8,
	 "Minute": 0
	 },
	 "TimeOut": {
	 "__type": "Time",
	 "Hour": 11,
	 "Minute": 0
	 },
	 "Comments": "hello 123",
	 "Task": {
	 "Identity": "1"
	 },
	 "Activity": {
	 "Identity": "1"
	 }
	 },
	 {
	 "__operation": "SetTimeEntryBilling",
	 "BillingType": {
	 "__type": "Replicon.Project.Domain.Timesheets.TimesheetBillingType",
	 "Identity": "ProjectRate"
	 },
	 "Project": {
	 "__type": "Replicon.Project.Domain.Project",
	 "Identity": "1"
	 }}]}]}]
	 */
    
    NSString *sheetIdentity = [entryObject sheetId];
	
	NSDate *entryDate = [entryObject entryDate];
	NSDictionary *entryDateDict = [G2Util convertDateToApiDateDictionary:entryDate];
 	NSMutableDictionary *propertiesOperationDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *propertiesOperationDict1 = [NSMutableDictionary dictionary];
    //US4006//Juhi
    BOOL doesUserHaveViewOrEditBilling   = [self checkForPermissionExistence:@"BillingTimesheet"];
    
    if([entryObject projectBillableStatus]!=nil && ![[entryObject projectBillableStatus] isKindOfClass:[NSNull class]])
    {
        if ([[entryObject projectBillableStatus] isEqualToString:@"AllowBillable"])
        {
            doesUserHaveViewOrEditBilling=TRUE;
        }
    }
    
    
	
	if (entryDateDict != nil && [entryDateDict isKindOfClass:[NSDictionary class]]) {
		[propertiesOperationDict setObject:entryDateDict forKey:@"EntryDate"];
	}
	
	
	NSString *comments = [entryObject comments];
	if (comments != nil && ![comments isKindOfClass:[NSNull class]] && ![comments isEqualToString:NULL_STRING]) {
		[propertiesOperationDict setObject:comments forKey:@"Comments"];
	}
	
	//NSString *taskIdentity = [entryObject taskIdentity];
	NSString *taskIdentity = [entryObject.taskObj taskIdentity];
	NSString *projectIdentity = [entryObject projectIdentity];
	if (taskIdentity != nil && ![taskIdentity isKindOfClass:[NSNull class]] && ![taskIdentity isEqualToString:NULL_STRING]) {
		NSDictionary *taskDict = [NSDictionary dictionaryWithObject:taskIdentity forKey:@"Identity"];
		[propertiesOperationDict setObject:taskDict forKey:@"Task"];
	}
	else if (taskIdentity == nil && projectIdentity != nil && ![projectIdentity isEqualToString:NO_CLIENT_ID]) {
		
		NSString *projectTaskIdentity = [supportDataModel getProjectRootTaskIdentity:projectIdentity]; 
		if (projectTaskIdentity != nil && ![projectTaskIdentity isKindOfClass:[NSNull class]]) {
			NSDictionary *taskDict = [NSDictionary dictionaryWithObject:projectTaskIdentity forKey:@"Identity"];
			[propertiesOperationDict setObject:taskDict forKey:@"Task"];
		}
	}
	NSString *activityIdentity = [entryObject activityIdentity];
	if (activityIdentity != nil && ![activityIdentity isKindOfClass:[NSNull class]] && ![activityIdentity isEqualToString:NULL_STRING] && ![activityIdentity isEqualToString:@""]) {
		NSDictionary *activityDict = [NSDictionary dictionaryWithObject:activityIdentity forKey:@"Identity"];
		[propertiesOperationDict setObject:activityDict forKey:@"Activity"];
	}
	
	[propertiesOperationDict setObject:@"SetProperties" forKey:@"__operation"];
	
	NSDictionary *calculationModeDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"Replicon.TimeSheet.Domain.CalculationModeObject",@"__type",
										 @"CalculateInOutTime",@"Identity",
										 nil];
	[propertiesOperationDict1 setObject:@"SetProperties" forKey:@"__operation"];
	[propertiesOperationDict1 setObject:calculationModeDict forKey:@"CalculationModeObject"];
	
	NSString *timeHours = [entryObject numberOfHours];
	if (timeHours != nil && ![timeHours isKindOfClass:[NSNull class]]) {
		DLog(@"String time is %@",timeHours);
		NSDictionary *timeDict = [G2Util convertDecimalHoursToApiTimeDict:timeHours];
		if (timeDict != nil && [timeDict isKindOfClass:[NSDictionary class]]) {
			[propertiesOperationDict setObject:timeDict forKey:@"Duration"];
		}
	}
	
	NSMutableDictionary *billingOperationsDict = [NSMutableDictionary dictionary];
	NSMutableDictionary *billingTypeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											@"Replicon.Project.Domain.Timesheets.TimesheetBillingType",@"__type",
											nil];
	
	NSString *billingIdentity = [entryObject billingIdentity];
	NSNumber *projectRoleId = [entryObject projectRoleId];
	DLog(@"billing Identity %@",billingIdentity);
	if (billingIdentity != nil && ![billingIdentity isKindOfClass:[NSNull class]] && ![billingIdentity isEqualToString:NULL_STRING]) {
		
		
		NSDictionary *projectRoleDict = nil;
		if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]
			&& ![billingIdentity isEqualToString:BILLING_NONBILLABLE]) {
			
			billingIdentity = BILLING_ROLE_RATE;
			projectRoleDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",projectRoleId]
														  forKey:@"Identity"];
		}
		else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
			projectRoleDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",projectRoleId]
														  forKey:@"Identity"];
		}
		
		[billingTypeDict setObject:billingIdentity forKey:@"Identity"];
		[billingOperationsDict setObject:billingTypeDict forKey:@"BillingType"];
        [billingOperationsDict setObject:@"SetTimeEntryBilling" forKey:@"__operation"];
		
		if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]
			&& ![billingIdentity isEqualToString:BILLING_NONBILLABLE]) {
			[billingOperationsDict setObject:projectRoleDict forKey:@"ProjectRole"];
		}
		else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
			[billingOperationsDict setObject:projectRoleDict forKey:@"BillingDepartment"];
		}
	}
	else {
        
       
        if (doesUserHaveViewOrEditBilling) 
        {
            [billingTypeDict setObject:BILLING_NONBILLABLE forKey:@"Identity"];//US4006 Ullas M L
            [billingOperationsDict setObject:billingTypeDict forKey:@"BillingType"];//US4006 Ullas M L
            [billingOperationsDict setObject:@"SetTimeEntryBilling" forKey:@"__operation"];//US4006 Ullas M L
        }
        //sending billing information if doesUserHaveViewOrEditBilling is yes else not sending
        //If user does not have "View/select billing options for projects/tasks" permission enabled, do not require the "Billing" field to be sent in the API request.
	}
	
	//NSString *projectIdentity = [entryObject projectIdentity];
	if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]] && ![projectIdentity isEqualToString:NO_CLIENT_ID]) {
		NSDictionary *projectDict = [NSDictionary dictionaryWithObjectsAndKeys:
									 projectIdentity,@"Identity",
									 @"Replicon.Project.Domain.Project",@"__type",
									 nil];
		[billingOperationsDict setObject:projectDict forKey:@"Project"];
	}
	
	
	
	NSMutableDictionary *clientPropertyDict = nil;
	if ([[entryObject clientAllocationId] isEqualToString:PROJECT_TYPE_BUCKET]) {
		NSString *clientId = [entryObject clientIdentity];
		NSMutableDictionary *clientDict = [NSMutableDictionary dictionaryWithObject:clientId forKey:@"Identity"];
		
		clientPropertyDict = [NSMutableDictionary dictionaryWithObject:clientDict forKey:@"Client"];
		[clientPropertyDict setObject:@"SetProperties" forKey:@"__operation"];
	}
    
    NSMutableDictionary *rowUDFPropertyDict = nil;
    if([[entryObject rowUDFArray]count]>0)
    {
        rowUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetRowUdfValues" forKey:@"__operation"];
        for (int k=0; k<[[entryObject rowUDFArray]count]; k++) {
            NSDictionary *fetchDict=[[entryObject rowUDFArray] objectAtIndex:k];
            for (id key in fetchDict) {
                [rowUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
            }
        }
    }
    
    NSMutableDictionary *cellUDFPropertyDict = nil;
    if([[entryObject cellUDFArray]count]>0)
    {
        cellUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetCellUdfValues" forKey:@"__operation"];
        for (int k=0; k<[[entryObject cellUDFArray]count]; k++) {
            NSDictionary *fetchDict=[[entryObject cellUDFArray] objectAtIndex:k];
            for (id key in fetchDict) {
                [cellUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
            }
        }
    }
    
    
    NSMutableArray *subOperationsArray=[NSMutableArray array];
    if (propertiesOperationDict1) {
        [subOperationsArray addObject:propertiesOperationDict1]; 
    }
    if (propertiesOperationDict) {
        [subOperationsArray addObject:propertiesOperationDict]; 
    }
    
    if (rowUDFPropertyDict) {
        [subOperationsArray addObject:rowUDFPropertyDict]; 
    }
    
    if (cellUDFPropertyDict) {
        [subOperationsArray addObject:cellUDFPropertyDict]; 
    }
    
    if (billingOperationsDict) {
        
        //US4006 Ullas M L
        //BOOL doesUserHaveViewOrEditBilling   = [self checkForPermissionExistence:@"BillingTimesheet"];//US4006//Juhi
        if (doesUserHaveViewOrEditBilling) 
        {
        [subOperationsArray addObject:billingOperationsDict]; 
        }
       
    }
    
    if (clientPropertyDict) {
        [subOperationsArray addObject:clientPropertyDict]; 
    }
    
    
	
	NSDictionary *mainOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   @"CollectionAdd",@"__operation",
									   @"TimeEntries",@"Collection",
									   subOperationsArray,@"Operations",
									   nil];
	
	NSArray *mainOperationsArray = [NSArray arrayWithObject:mainOperationDict];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Edit",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"Type",
							 sheetIdentity,@"Identity",
							 mainOperationsArray,@"Operations",
							 nil];
	
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    //    str=[str stringByReplacingOccurrencesOfString:@"\"null\"" withString:@"\"\""];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"SaveTimeEntryForSheet"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}

-(void)sendRequestToAddNewTimeOffWithObject:(G2TimeOffEntryObject *)entryObject 
{

	NSString *sheetIdentity = [entryObject sheetId];
	
	NSDate *entryDate = [entryObject timeOffDate];
	NSDictionary *entryDateDict = [G2Util convertDateToApiDateDictionary:entryDate];
 	NSMutableDictionary *propertiesOperationDict = [NSMutableDictionary dictionary];
   
	
    
    
	if (entryDateDict != nil && [entryDateDict isKindOfClass:[NSDictionary class]]) {
		[propertiesOperationDict setObject:entryDateDict forKey:@"EntryDate"];
	}
	
	
    NSDictionary *timeOffCodeDict = [NSDictionary dictionaryWithObject:[entryObject typeIdentity] forKey:@"Identity"];
    if (timeOffCodeDict != nil && [timeOffCodeDict isKindOfClass:[NSDictionary class]]) {
		[propertiesOperationDict setObject:timeOffCodeDict forKey:@"TimeOffCode"];
	}
    
	NSString *comments = [entryObject comments];
	if (comments != nil && ![comments isKindOfClass:[NSNull class]] && ![comments isEqualToString:NULL_STRING]) {
		[propertiesOperationDict setObject:comments forKey:@"Comments"];
	}
	
	
	[propertiesOperationDict setObject:@"SetProperties" forKey:@"__operation"];
	
	
	
	NSString *timeHours = [entryObject numberOfHours];
	if (timeHours != nil && ![timeHours isKindOfClass:[NSNull class]]) {
		DLog(@"String time is %@",timeHours);
		NSDictionary *timeDict = [G2Util convertDecimalHoursToApiTimeDict:timeHours];
		if (timeDict != nil && [timeDict isKindOfClass:[NSDictionary class]]) {
			[propertiesOperationDict setObject:timeDict forKey:@"Duration"];
		}
	}
	

	
	    
    NSMutableDictionary *uUDFPropertyDict = nil;
    if([[entryObject udfArray]count]>0)
    {
        uUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetUdfValues" forKey:@"__operation"];
        for (int k=0; k<[[entryObject udfArray]count]; k++) {
            NSDictionary *fetchDict=[[entryObject udfArray] objectAtIndex:k];
            for (id key in fetchDict) {
                [uUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
            }
        }
    }
    
       
    
    NSMutableArray *subOperationsArray=[NSMutableArray array];
    
    if (propertiesOperationDict) {
        [subOperationsArray addObject:propertiesOperationDict]; 
    }
    
    if (uUDFPropertyDict) {
        [subOperationsArray addObject:uUDFPropertyDict]; 
    }
    
        
    
	
	NSDictionary *mainOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   @"CollectionAdd",@"__operation",
									   @"TimeOffEntries",@"Collection",
									   subOperationsArray,@"Operations",
									   nil];
	
	NSArray *mainOperationsArray = [NSArray arrayWithObject:mainOperationDict];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Edit",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"Type",
							 sheetIdentity,@"Identity",
							 mainOperationsArray,@"Operations",
							 nil];
	
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    //    str=[str stringByReplacingOccurrencesOfString:@"\"null\"" withString:@"\"\""];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"SaveTimeOffEntryForSheet"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}

-(void)sendRequestToAddNewTimeEntryWithObjectForInOutTimesheets:(G2TimeSheetEntryObject *)entryObject {
    
	NSString *sheetIdentity = [entryObject sheetId];
	
	NSDate *entryDate = [entryObject entryDate];
	NSDictionary *entryDateDict = [G2Util convertDateToApiDateDictionary:entryDate];
 	NSMutableDictionary *propertiesOperationDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *propertiesOperationDict1 = [NSMutableDictionary dictionary];
	
	if (entryDateDict != nil && [entryDateDict isKindOfClass:[NSDictionary class]]) {
		[propertiesOperationDict setObject:entryDateDict forKey:@"EntryDate"];
	}
	
	
	NSString *comments = [entryObject comments];
	if (comments != nil && ![comments isKindOfClass:[NSNull class]] && ![comments isEqualToString:NULL_STRING]) {
		[propertiesOperationDict setObject:comments forKey:@"Comments"];
	}
	
	//NSString *taskIdentity = [entryObject taskIdentity];
	NSString *taskIdentity = [entryObject.taskObj taskIdentity];
	NSString *projectIdentity = [entryObject projectIdentity];
	if (taskIdentity != nil && ![taskIdentity isKindOfClass:[NSNull class]] && ![taskIdentity isEqualToString:NULL_STRING]) {
		NSDictionary *taskDict = [NSDictionary dictionaryWithObject:taskIdentity forKey:@"Identity"];
		[propertiesOperationDict setObject:taskDict forKey:@"Task"];
	}
	else if (taskIdentity == nil && projectIdentity != nil && ![projectIdentity isEqualToString:NO_CLIENT_ID]) {
		
		NSString *projectTaskIdentity = [supportDataModel getProjectRootTaskIdentity:projectIdentity]; 
		if (projectTaskIdentity != nil && ![projectTaskIdentity isKindOfClass:[NSNull class]]) {
			NSDictionary *taskDict = [NSDictionary dictionaryWithObject:projectTaskIdentity forKey:@"Identity"];
			[propertiesOperationDict setObject:taskDict forKey:@"Task"];
		}
	}
	NSString *activityIdentity = [entryObject activityIdentity];
	if (activityIdentity != nil && ![activityIdentity isKindOfClass:[NSNull class]] && ![activityIdentity isEqualToString:NULL_STRING] && ![activityIdentity isEqualToString:@""]) {
		NSDictionary *activityDict = [NSDictionary dictionaryWithObject:activityIdentity forKey:@"Identity"];
		[propertiesOperationDict setObject:activityDict forKey:@"Activity"];
	}
	
	[propertiesOperationDict setObject:@"SetProperties" forKey:@"__operation"];
	
	NSDictionary *calculationModeDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"Replicon.TimeSheet.Domain.CalculationModeObject",@"__type",
										 @"CalculateDuration",@"Identity",
										 nil];
	[propertiesOperationDict1 setObject:@"SetProperties" forKey:@"__operation"];
	[propertiesOperationDict1 setObject:calculationModeDict forKey:@"CalculationModeObject"];
	
    //	NSString *timeHours = [entryObject numberOfHours];
    //	if (timeHours != nil && ![timeHours isKindOfClass:[NSNull class]]) {
    //		DLog(@"String time is %@",timeHours);
    //		NSDictionary *timeDict = [Util convertDecimalHoursToApiTimeDict:timeHours];
    //		if (timeDict != nil && [timeDict isKindOfClass:[NSDictionary class]]) {
    //			[propertiesOperationDict setObject:timeDict forKey:@"Duration"];
    //		}
    //	}
    
    NSString *inTime=[entryObject inTime];
    if (inTime != nil && ![inTime isKindOfClass:[NSNull class]]) 
    {
        NSDictionary *inTimeDict = [G2Util convertTimeToHourMinutesSecondsFormat:inTime];
        if (inTimeDict != nil && [inTimeDict isKindOfClass:[NSDictionary class]]) 
        {
            [propertiesOperationDict setObject:inTimeDict forKey:@"TimeIn"];
        }
    }
    
    NSString *outTime=[entryObject outTime];
    if (outTime != nil && ![outTime isKindOfClass:[NSNull class]]) 
    {
        NSDictionary *outTimeDict = [G2Util convertTimeToHourMinutesSecondsFormat:outTime];
        if (outTimeDict != nil && [outTimeDict isKindOfClass:[NSDictionary class]]) 
        {
            [propertiesOperationDict setObject:outTimeDict forKey:@"TimeOut"];
        }
    }
	
	NSMutableDictionary *billingOperationsDict = [NSMutableDictionary dictionary];
	NSMutableDictionary *billingTypeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											@"Replicon.Project.Domain.Timesheets.TimesheetBillingType",@"__type",
											nil];
	
	NSString *billingIdentity = [entryObject billingIdentity];
	NSNumber *projectRoleId = [entryObject projectRoleId];
	DLog(@"billing Identity %@",billingIdentity);
    BOOL doesUserHaveViewOrEditBilling   = [self checkForPermissionExistence:@"BillingTimesheet"];//US4006//Juhi
    
    
    if([entryObject projectBillableStatus]!=nil && ![[entryObject projectBillableStatus] isKindOfClass:[NSNull class]])
    {
        if ([[entryObject projectBillableStatus] isEqualToString:@"AllowBillable"])
        {
            doesUserHaveViewOrEditBilling=TRUE;
        }
    }
    
	if (billingIdentity != nil && ![billingIdentity isKindOfClass:[NSNull class]] && ![billingIdentity isEqualToString:NULL_STRING]) {
		
		
		NSDictionary *projectRoleDict = nil;
		if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]
			&& ![billingIdentity isEqualToString:BILLING_NONBILLABLE]) {
			
			billingIdentity = BILLING_ROLE_RATE;
			projectRoleDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",projectRoleId]
														  forKey:@"Identity"];
		}
		else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
			projectRoleDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",projectRoleId]
														  forKey:@"Identity"];
		}
		
		[billingTypeDict setObject:billingIdentity forKey:@"Identity"];
		[billingOperationsDict setObject:billingTypeDict forKey:@"BillingType"];
        [billingOperationsDict setObject:@"SetTimeEntryBilling" forKey:@"__operation"];//DE6178//juhi
		
		if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]
			&& ![billingIdentity isEqualToString:BILLING_NONBILLABLE]) {
			[billingOperationsDict setObject:projectRoleDict forKey:@"ProjectRole"];
		}
		else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
			[billingOperationsDict setObject:projectRoleDict forKey:@"BillingDepartment"];
		}
	}
	else {
       
        if (doesUserHaveViewOrEditBilling) 
        {

            [billingTypeDict setObject:BILLING_NONBILLABLE forKey:@"Identity"];//US4006 Ullas M L
            [billingOperationsDict setObject:billingTypeDict forKey:@"BillingType"];//US4006 Ullas M L
            [billingOperationsDict setObject:@"SetTimeEntryBilling" forKey:@"__operation"];//US4006 Ullas M L
        }
        //sending billing information if doesUserHaveViewOrEditBilling is yes else not sending
        //If user does not have "View/select billing options for projects/tasks" permission enabled, do not require the "Billing" field to be sent in the API request.
	}
	
	//NSString *projectIdentity = [entryObject projectIdentity];
	if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]] && ![projectIdentity isEqualToString:NO_CLIENT_ID]) {
		NSDictionary *projectDict = [NSDictionary dictionaryWithObjectsAndKeys:
									 projectIdentity,@"Identity",
									 @"Replicon.Project.Domain.Project",@"__type",
									 nil];
		[billingOperationsDict setObject:projectDict forKey:@"Project"];
	}
	
	
	
	NSMutableDictionary *clientPropertyDict = nil;
	if ([[entryObject clientAllocationId] isEqualToString:PROJECT_TYPE_BUCKET]) {
		NSString *clientId = [entryObject clientIdentity];
		NSMutableDictionary *clientDict = [NSMutableDictionary dictionaryWithObject:clientId forKey:@"Identity"];
		
		clientPropertyDict = [NSMutableDictionary dictionaryWithObject:clientDict forKey:@"Client"];
		[clientPropertyDict setObject:@"SetProperties" forKey:@"__operation"];
	}
    
    NSMutableDictionary *rowUDFPropertyDict = nil;
    if([[entryObject rowUDFArray]count]>0)
    {
        rowUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetRowUdfValues" forKey:@"__operation"];
        for (int k=0; k<[[entryObject rowUDFArray]count]; k++) {
            NSDictionary *fetchDict=[[entryObject rowUDFArray] objectAtIndex:k];
            for (id key in fetchDict) {
                [rowUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
            }
        }
    }
    
    NSMutableDictionary *cellUDFPropertyDict = nil;
    if([[entryObject cellUDFArray]count]>0)
    {
        cellUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetCellUdfValues" forKey:@"__operation"];
        for (int k=0; k<[[entryObject cellUDFArray]count]; k++) {
            NSDictionary *fetchDict=[[entryObject cellUDFArray] objectAtIndex:k];
            for (id key in fetchDict) {
                [cellUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
            }
        }
    }
    
    NSMutableArray *subOperationsArray=[NSMutableArray array];
    if (propertiesOperationDict1) {
        [subOperationsArray addObject:propertiesOperationDict1]; 
    }
    if (propertiesOperationDict) {
        [subOperationsArray addObject:propertiesOperationDict]; 
    }
    
    if (rowUDFPropertyDict) {
        [subOperationsArray addObject:rowUDFPropertyDict]; 
    }
    
    if (cellUDFPropertyDict) {
        [subOperationsArray addObject:cellUDFPropertyDict]; 
    }
    
    if (billingOperationsDict) {
      //  BOOL doesUserHaveViewOrEditBilling   = [self checkForPermissionExistence:@"BillingTimesheet"];
        if (doesUserHaveViewOrEditBilling) 
        {
        [subOperationsArray addObject:billingOperationsDict];
        }
        
    }
    
    if (clientPropertyDict) {
        [subOperationsArray addObject:clientPropertyDict]; 
    }
	
    
	
	NSDictionary *mainOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   @"CollectionAdd",@"__operation",
									   @"TimeEntries",@"Collection",
									   subOperationsArray,@"Operations",
									   nil];
	
	NSArray *mainOperationsArray = [NSArray arrayWithObject:mainOperationDict];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Edit",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"Type",
							 sheetIdentity,@"Identity",
							 mainOperationsArray,@"Operations",
							 nil];
	
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    //str=[str stringByReplacingOccurrencesOfString:@"\"null\"" withString:@"\"\""];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"SaveTimeEntryForSheet"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}
//US4513 Ullas
-(void)sendRequestToAddNewTimeEntryWithObjectForNewInOutTimesheets:(NSMutableArray *)entryObjectArray{
    
    NSMutableArray *jsonPayloadArray=[NSMutableArray array];
    BOOL isEntryDateInTimeSheetPeriod=NO;
    for (int i=0; i<[entryObjectArray count]; i++) {
        G2TimeSheetEntryObject *entryObject=[entryObjectArray objectAtIndex:i];
        NSNumber *sheetIdentityNumber=[NSNumber numberWithInt:[[entryObject sheetId]intValue]];
         isEntryDateInTimeSheetPeriod=[timesheetModel checkWhetherEntryDateFalssInTimeSheetPeriod:[entryObject entryDate] :sheetIdentityNumber];
        
        NSString *sheetIdentity = [entryObject sheetId];
        
        NSDate *entryDate = [entryObject entryDate];
        NSDictionary *entryDateDict = [G2Util convertDateToApiDateDictionary:entryDate];
        NSMutableDictionary *propertiesOperationDict = [NSMutableDictionary dictionary];
        NSMutableDictionary *propertiesOperationDict1 = [NSMutableDictionary dictionary];
        
        if (entryDateDict != nil && [entryDateDict isKindOfClass:[NSDictionary class]]) {
            [propertiesOperationDict setObject:entryDateDict forKey:@"EntryDate"];
        }
        
        
        NSString *comments = [entryObject comments];
        if (comments != nil && ![comments isKindOfClass:[NSNull class]] && ![comments isEqualToString:NULL_STRING]) {
            [propertiesOperationDict setObject:comments forKey:@"Comments"];
        }
        
        //NSString *taskIdentity = [entryObject taskIdentity];
        NSString *taskIdentity = [entryObject.taskObj taskIdentity];
        NSString *projectIdentity = [entryObject projectIdentity];
        if (taskIdentity != nil && ![taskIdentity isKindOfClass:[NSNull class]] && ![taskIdentity isEqualToString:NULL_STRING]) {
            NSDictionary *taskDict = [NSDictionary dictionaryWithObject:taskIdentity forKey:@"Identity"];
            [propertiesOperationDict setObject:taskDict forKey:@"Task"];
        }
        else if (taskIdentity == nil && projectIdentity != nil && ![projectIdentity isEqualToString:NO_CLIENT_ID]) {
            
            NSString *projectTaskIdentity = [supportDataModel getProjectRootTaskIdentity:projectIdentity]; 
            if (projectTaskIdentity != nil && ![projectTaskIdentity isKindOfClass:[NSNull class]]) {
                NSDictionary *taskDict = [NSDictionary dictionaryWithObject:projectTaskIdentity forKey:@"Identity"];
                [propertiesOperationDict setObject:taskDict forKey:@"Task"];
            }
        }
        NSString *activityIdentity = [entryObject activityIdentity];
        if (activityIdentity != nil && ![activityIdentity isKindOfClass:[NSNull class]] && ![activityIdentity isEqualToString:NULL_STRING] && ![activityIdentity isEqualToString:@""]) {
            NSDictionary *activityDict = [NSDictionary dictionaryWithObject:activityIdentity forKey:@"Identity"];
            [propertiesOperationDict setObject:activityDict forKey:@"Activity"];
        }
        
        [propertiesOperationDict setObject:@"SetProperties" forKey:@"__operation"];
        
        NSDictionary *calculationModeDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"Replicon.TimeSheet.Domain.CalculationModeObject",@"__type",
                                             @"CalculateDuration",@"Identity",
                                             nil];
        [propertiesOperationDict1 setObject:@"SetProperties" forKey:@"__operation"];
        [propertiesOperationDict1 setObject:calculationModeDict forKey:@"CalculationModeObject"];
        
        //	NSString *timeHours = [entryObject numberOfHours];
        //	if (timeHours != nil && ![timeHours isKindOfClass:[NSNull class]]) {
        //		DLog(@"String time is %@",timeHours);
        //		NSDictionary *timeDict = [Util convertDecimalHoursToApiTimeDict:timeHours];
        //		if (timeDict != nil && [timeDict isKindOfClass:[NSDictionary class]]) {
        //			[propertiesOperationDict setObject:timeDict forKey:@"Duration"];
        //		}
        //	}
        
        NSString *inTime=[entryObject inTime];
        if (inTime != nil && ![inTime isKindOfClass:[NSNull class]]) 
        {
            NSDictionary *inTimeDict = [G2Util convertTimeToHourMinutesSecondsFormat:inTime];
            if (inTimeDict != nil && [inTimeDict isKindOfClass:[NSDictionary class]]) 
            {
                [propertiesOperationDict setObject:inTimeDict forKey:@"TimeIn"];
            }
        }
        
        NSString *outTime=[entryObject outTime];
        if (outTime != nil && ![outTime isKindOfClass:[NSNull class]]) 
        {
            NSDictionary *outTimeDict = [G2Util convertTimeToHourMinutesSecondsFormat:outTime];
            if (outTimeDict != nil && [outTimeDict isKindOfClass:[NSDictionary class]]) 
            {
                [propertiesOperationDict setObject:outTimeDict forKey:@"TimeOut"];
            }
        }
        
        NSMutableDictionary *billingOperationsDict = [NSMutableDictionary dictionary];
        NSMutableDictionary *billingTypeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                @"Replicon.Project.Domain.Timesheets.TimesheetBillingType",@"__type",
                                                nil];
        
        NSString *billingIdentity = [entryObject billingIdentity];
        NSNumber *projectRoleId = [entryObject projectRoleId];
        DLog(@"billing Identity %@",billingIdentity);
        if (billingIdentity != nil && ![billingIdentity isKindOfClass:[NSNull class]] && ![billingIdentity isEqualToString:NULL_STRING]) {
            
            
            NSDictionary *projectRoleDict = nil;
            if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]
                && ![billingIdentity isEqualToString:BILLING_NONBILLABLE]) {
                
                billingIdentity = BILLING_ROLE_RATE;
                projectRoleDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",projectRoleId]
                                                              forKey:@"Identity"];
            }
            else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
                projectRoleDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",projectRoleId]
                                                              forKey:@"Identity"];
            }
            
            [billingTypeDict setObject:billingIdentity forKey:@"Identity"];
            [billingOperationsDict setObject:billingTypeDict forKey:@"BillingType"];
            
            if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]
                && ![billingIdentity isEqualToString:BILLING_NONBILLABLE]) {
                [billingOperationsDict setObject:projectRoleDict forKey:@"ProjectRole"];
            }
            else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
                [billingOperationsDict setObject:projectRoleDict forKey:@"BillingDepartment"];
            }
        }
        else {
            [billingTypeDict setObject:BILLING_NONBILLABLE forKey:@"Identity"];
            [billingOperationsDict setObject:billingTypeDict forKey:@"BillingType"];
        }
        
        //NSString *projectIdentity = [entryObject projectIdentity];
        if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]] && ![projectIdentity isEqualToString:NO_CLIENT_ID]) {
            NSDictionary *projectDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                         projectIdentity,@"Identity",
                                         @"Replicon.Project.Domain.Project",@"__type",
                                         nil];
            [billingOperationsDict setObject:projectDict forKey:@"Project"];
        }
        
        [billingOperationsDict setObject:@"SetTimeEntryBilling" forKey:@"__operation"];
        
        NSMutableDictionary *clientPropertyDict = nil;
        if ([[entryObject clientAllocationId] isEqualToString:PROJECT_TYPE_BUCKET]) {
            NSString *clientId = [entryObject clientIdentity];
            NSMutableDictionary *clientDict = [NSMutableDictionary dictionaryWithObject:clientId forKey:@"Identity"];
            
            clientPropertyDict = [NSMutableDictionary dictionaryWithObject:clientDict forKey:@"Client"];
            [clientPropertyDict setObject:@"SetProperties" forKey:@"__operation"];
        }
        
        NSMutableDictionary *rowUDFPropertyDict = nil;
        if([[entryObject rowUDFArray]count]>0)
        {
            rowUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetRowUdfValues" forKey:@"__operation"];
            for (int k=0; k<[[entryObject rowUDFArray]count]; k++) {
                NSDictionary *fetchDict=[[entryObject rowUDFArray] objectAtIndex:k];
                for (id key in fetchDict) {
                    [rowUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
                }
            }
        }
        
        NSMutableDictionary *cellUDFPropertyDict = nil;
        if([[entryObject cellUDFArray]count]>0)
        {
            cellUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetCellUdfValues" forKey:@"__operation"];
            for (int k=0; k<[[entryObject cellUDFArray]count]; k++) {
                NSDictionary *fetchDict=[[entryObject cellUDFArray] objectAtIndex:k];
                for (id key in fetchDict) {
                    [cellUDFPropertyDict setObject:[fetchDict objectForKey:key] forKey:key];
                }
            }
        }
        
        NSMutableArray *subOperationsArray=[NSMutableArray array];
        if (propertiesOperationDict1) {
            [subOperationsArray addObject:propertiesOperationDict1]; 
        }
        if (propertiesOperationDict) {
            [subOperationsArray addObject:propertiesOperationDict]; 
        }
        
        if (rowUDFPropertyDict) {
            [subOperationsArray addObject:rowUDFPropertyDict]; 
        }
        
        if (cellUDFPropertyDict) {
            [subOperationsArray addObject:cellUDFPropertyDict]; 
        }
        
        if (billingOperationsDict) {
            [subOperationsArray addObject:billingOperationsDict]; 
        }
        
        if (clientPropertyDict) {
            [subOperationsArray addObject:clientPropertyDict]; 
        }
        
        
        
        NSDictionary *mainOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"CollectionAdd",@"__operation",
                                           @"TimeEntries",@"Collection",
                                           subOperationsArray,@"Operations",
                                           nil];
        
        NSArray *mainOperationsArray = [NSArray arrayWithObject:mainOperationDict];
        
        NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                 @"Edit",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"Type",
                                 sheetIdentity,@"Identity",
                                 mainOperationsArray,@"Operations",
                                 nil];
        
        
        if (isEntryDateInTimeSheetPeriod ) 
        {   
            if (i==0) 
            {
                [jsonPayloadArray addObject:queryDict];
                 
            }
            else
            {
                [jsonPayloadArray addObject:queryDict];
                 
            }
        }
    }
            
    
    NSError *err = nil;
    NSString *str=[JsonWrapper writeJson:jsonPayloadArray error:&err];
    DLog(@"TIME SHEET CHECK QUERY	%@",str);
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    
    [self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"SaveTimeEntryForSheet"]];
    [self setServiceDelegate:self];
    [self executeRequest]; 

            
}



-(void)sendRequestToFetchTimesheetByIdWithEntries:(NSString *)sheetIdentity {
	/*
	 {
	 "Action": "Query",
	 "DomainType": "Replicon.Suite.Domain.EntryTimesheet",
	 "QueryType": "EntryTimesheetById",
	 "Args": [
	 [
	 280
	 ]
	 ],
	 "Load": [
	 {
	 "Relationship": "TimeEntries",
	 "Load": [
	 {
	 "Relationship": "Activity"
	 },
	 {
	 "Relationship": "ProjectRole"
	 },
	 {
	 "Relationship": "Client"
	 },
	 {
	 "Relationship": "Task",
	 "Load": [
	 {
	 "Relationship": "Project",
	 "Load": [
	 {
	 "Relationship": "ProjectClients",
	 "Load": [
	 {
	 "Relationship": "Client"
	 }
	 ]
	 }
	 ]
	 }
	 ]
	 }
	 ]
	 },
	 {
	 "Relationship": "TimeOffEntries",
	 "Load" : [
	 {
	 "Relationship": "TimeOffCode"
	 }
	 ]
	 }
	 ]
	 }
	 */
	NSArray *identityArray = [NSArray arrayWithObject:sheetIdentity];
	NSArray *argsArray = [NSArray arrayWithObjects:identityArray,nil];
	
	NSMutableArray *loadArray = [NSMutableArray array];
	
	NSDictionary *activityDict    = [NSDictionary dictionaryWithObjectsAndKeys:@"Activity",@"Relationship",nil];
	NSDictionary *projectRoleDict = [NSDictionary dictionaryWithObjectsAndKeys:@"ProjectRole",@"Relationship",nil];
	NSDictionary *billingDepartmentDict = [NSDictionary dictionaryWithObjectsAndKeys:@"BillingRateDepartment",@"Relationship",nil];
	NSDictionary *clientDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
	NSDictionary *billingDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Billable",@"Relationship",nil];
	//NSDictionary *clientsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
	//load array for client relatonship in projectClient and add to projectclientDict
	NSArray *projectClientLoadArray = [NSArray arrayWithObjects:clientDict,nil];
	NSDictionary *projectClientDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   @"ProjectClients",@"Relationship",
									   projectClientLoadArray,@"Load",
									   nil];
	//load array for projectClients in project and add to projectDict
	NSArray *projectLoadArray = [NSArray arrayWithObjects:projectClientDict,nil];
	NSDictionary *projectDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Project",@"Relationship",
								 projectLoadArray,@"Load",
								 nil];
	NSDictionary *childTaskCountDict = [NSDictionary dictionaryWithObject:@"ChildTasks" forKey:@"CountOf"];
	NSDictionary *parentTaskDict = [NSDictionary dictionaryWithObject:@"ParentTask" forKey:@"Relationship"];
	//Load array for project in task and add to taskDict
	NSArray *taskLoadArray = [NSArray arrayWithObjects:projectDict,childTaskCountDict,parentTaskDict,nil];
	NSDictionary *taskDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Task",@"Relationship",
							  taskLoadArray,@"Load",
							  nil];
	
	//Load array for activity,projectrole,client, task to timeentries and add to TimeEntriesDict
	NSArray *timeEntriesLoadArray = [NSArray arrayWithObjects:activityDict,projectRoleDict,billingDepartmentDict,clientDict,taskDict,billingDict,nil];
	NSDictionary *timeEntriesDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeEntries",@"Relationship",
								   timeEntriesLoadArray,@"Load",
								   nil];
	NSDictionary *timeOffCodeDict = [NSDictionary dictionaryWithObjectsAndKeys:@"TimeOffCode",@"Relationship",nil];
	NSArray *timeOffEntriesLoadArray = [NSArray arrayWithObject:timeOffCodeDict];
	NSDictionary *timeOffEntriesDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeOffEntries",@"Relationship",
									  timeOffEntriesLoadArray,@"Load",
									  nil];
	NSDictionary *remainingApproversDict = [NSDictionary dictionaryWithObjectsAndKeys:
											@"RemainingApprovers",@"Relationship",
											nil];
	NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Type",@"Relationship",nil];
	NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
	NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"FilteredHistory",@"Relationship",
										 approvalLoadArray,@"Load",
										 nil];
    
    NSDictionary *languageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Language",@"Relationship",nil];
    NSArray *languageArray=[NSArray arrayWithObject:languageDict];
	NSDictionary *mealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BreakRuleViolationEntries",@"Relationship",languageArray,@"Load",nil];
    NSDictionary *finalmealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BreakRuleViolations",@"Relationship",[NSArray arrayWithObject:mealBreakViolationsDict],@"Load",nil];
    
	[loadArray addObject:timeEntriesDict];
	[loadArray addObject:timeOffEntriesDict];
	[loadArray addObject:remainingApproversDict];
	[loadArray addObject:filteredHistoryDict];
    [loadArray addObject:finalmealBreakViolationsDict];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:argsArray,@"Args",
							 @"Query",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
							 @"EntryTimesheetById",@"QueryType",
							 loadArray,@"Load",
							 nil];
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET CHECK QUERY:::FETCH	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"GetTimesheetForIdWithEntries"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}

-(void)sendRequestToSyncOfflineEditedEntriesForSheet:(NSMutableArray *)entryObjects sheetId:(NSString *)sheetIdentity
											delegate: (id)_delegate {
	if (entryObjects != nil && [entryObjects count] > 0) {
		
		NSMutableArray *mainOperationsArray = [NSMutableArray array];
		for (G2TimeSheetEntryObject *entryObject in entryObjects) {
			
			NSDate *entryDate = [entryObject entryDate];
			NSDictionary *entryDateDict = [G2Util convertDateToApiDateDictionary:entryDate];
			NSMutableDictionary *propertiesOperationDict = [NSMutableDictionary dictionary];
			
			if (entryDateDict != nil && [entryDateDict isKindOfClass:[NSDictionary class]]) {
				[propertiesOperationDict setObject:entryDateDict forKey:@"EntryDate"];
			}
			
			
			NSString *comments = [entryObject comments];
			if (comments != nil && ![comments isKindOfClass:[NSNull class]] && ![comments isEqualToString:NULL_STRING]) {
				[propertiesOperationDict setObject:comments forKey:@"Comments"];
			}
			
			//NSString *taskIdentity = [entryObject taskIdentity];
			NSString *taskIdentity = [entryObject.taskObj taskIdentity];
			if (taskIdentity != nil && ![taskIdentity isKindOfClass:[NSNull class]] && ![taskIdentity isEqualToString:NULL_STRING]) {
				NSDictionary *taskDict = [NSDictionary dictionaryWithObject:taskIdentity forKey:@"Identity"];
				[propertiesOperationDict setObject:taskDict forKey:@"Task"];
			}
			
			NSString *activityIdentity = [entryObject activityIdentity];
			if (activityIdentity != nil && ![activityIdentity isKindOfClass:[NSNull class]] && ![activityIdentity isEqualToString:NULL_STRING]) {
				NSDictionary *activityDict = [NSDictionary dictionaryWithObject:activityIdentity forKey:@"Identity"];
				[propertiesOperationDict setObject:activityDict forKey:@"Activity"];
			}
			
			[propertiesOperationDict setObject:@"SetProperties" forKey:@"__operation"];
			
			NSDictionary *calculationModeDict = [NSDictionary dictionaryWithObjectsAndKeys:
												 @"Replicon.TimeSheet.Domain.CalculationModeObject",@"__type",
												 @"CalculateInOutTime",@"Identity",
												 nil];
			[propertiesOperationDict setObject:calculationModeDict forKey:@"CalculationModeObject"];
			
			NSString *timeHours = [entryObject numberOfHours];
			if (timeHours != nil && ![timeHours isKindOfClass:[NSNull class]]) {
				DLog(@"String time is %@",timeHours);
				NSDictionary *timeDict = [G2Util convertDecimalHoursToApiTimeDict:timeHours];
				if (timeDict != nil && [timeDict isKindOfClass:[NSDictionary class]]) {
					[propertiesOperationDict setObject:timeDict forKey:@"Duration"];
				}
			}
			
			NSMutableDictionary *billingOperationsDict = [NSMutableDictionary dictionary];
			
			NSString *billingIdentity = [entryObject billingIdentity];
			NSNumber *projectRoleId = [entryObject projectRoleId];
			DLog(@"billing Identity %@",billingIdentity);
			if (billingIdentity != nil && ![billingIdentity isKindOfClass:[NSNull class]] && ![billingIdentity isEqualToString:NULL_STRING]) {
				
				NSMutableDictionary *billingTypeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
														@"Replicon.Project.Domain.Timesheets.TimesheetBillingType",@"__type",
														nil];
				NSDictionary *projectRoleDict = nil;
				if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
					
					billingIdentity = BILLING_ROLE_RATE;
					projectRoleDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",projectRoleId]
																  forKey:@"Identity"];
				}
				else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
					projectRoleDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",projectRoleId]
																  forKey:@"Identity"];
				}
				
				[billingTypeDict setObject:billingIdentity forKey:@"Identity"];//ullas
				[billingOperationsDict setObject:billingTypeDict forKey:@"BillingType"];//ullas
				
				if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
					[billingOperationsDict setObject:projectRoleDict forKey:@"ProjectRole"];
				}
				else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
					[billingOperationsDict setObject:projectRoleDict forKey:@"BillingDepartment"];
				}
			}
			
			NSString *projectIdentity = [entryObject projectIdentity];
			if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]] && ![projectIdentity isEqualToString:NULL_STRING]) {
				NSDictionary *projectDict = [NSDictionary dictionaryWithObjectsAndKeys:
											 projectIdentity,@"Identity",
											 @"Replicon.Project.Domain.Project",@"__type",
											 nil];
				[billingOperationsDict setObject:projectDict forKey:@"Project"];
			}
			
			[billingOperationsDict setObject:@"SetTimeEntryBilling" forKey:@"__operation"];
			
			NSArray *subOperationsArray = [NSArray arrayWithObjects:propertiesOperationDict,billingOperationsDict,nil];
			
			NSDictionary *mainOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
											   @"CollectionEdit",@"__operation",
											   @"TimeEntries",@"Collection",
											   [entryObject identity],@"Identity",
											   subOperationsArray,@"Operations",
											   nil];
			[mainOperationsArray addObject:mainOperationDict];
		}
		
		NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
								 @"Edit",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"Type",
								 sheetIdentity,@"Identity",
								 mainOperationsArray,@"Operations",
								 nil];
		//Send  request
		NSError *err = nil;
		NSString *str = [JsonWrapper writeJson:queryDict error:&err];
		DLog(@"TIME SHEET CHECK QUERY	%@",str);
		NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
		[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
		[paramDict setObject:str forKey:@"PayLoadStr"];
		
		[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
		[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"SyncOfflineEditedTimeEntries"]];
		[self setServiceDelegate:self];
		[self executeRequest];
	}
}
-(void)sendRequestToSyncOfflineCreatedEntriesForSheet:(NSMutableArray *)entryObjects sheetId:(NSString *)sheetIdentity
											 delegate: (id)_delegate {
	if (entryObjects != nil && [entryObjects count] > 0) {
		
		NSMutableArray *mainOperationsArray = [NSMutableArray array];
		for (G2TimeSheetEntryObject *entryObject in entryObjects) {
			
			
			NSDate *entryDate = [entryObject entryDate];
			NSDictionary *entryDateDict = [G2Util convertDateToApiDateDictionary:entryDate];
			NSMutableDictionary *propertiesOperationDict = [NSMutableDictionary dictionary];
			
			if (entryDateDict != nil && [entryDateDict isKindOfClass:[NSDictionary class]]) {
				[propertiesOperationDict setObject:entryDateDict forKey:@"EntryDate"];
			}
			
			
			NSString *comments = [entryObject comments];
			if (comments != nil && ![comments isKindOfClass:[NSNull class]] && ![comments isEqualToString:NULL_STRING]) {
				[propertiesOperationDict setObject:comments forKey:@"Comments"];
			}
			
			//NSString *taskIdentity = [entryObject taskIdentity];
			NSString *taskIdentity = [entryObject.taskObj taskIdentity];
			if (taskIdentity != nil && ![taskIdentity isKindOfClass:[NSNull class]] && ![taskIdentity isEqualToString:NULL_STRING]) {
				NSDictionary *taskDict = [NSDictionary dictionaryWithObject:taskIdentity forKey:@"Identity"];
				[propertiesOperationDict setObject:taskDict forKey:@"Task"];
			}
			
			NSString *activityIdentity = [entryObject activityIdentity];
			if (activityIdentity != nil && ![activityIdentity isKindOfClass:[NSNull class]] && ![activityIdentity isEqualToString:NULL_STRING]) {
				NSDictionary *activityDict = [NSDictionary dictionaryWithObject:activityIdentity forKey:@"Identity"];
				[propertiesOperationDict setObject:activityDict forKey:@"Activity"];
			}
			
			[propertiesOperationDict setObject:@"SetProperties" forKey:@"__operation"];
			
			NSDictionary *calculationModeDict = [NSDictionary dictionaryWithObjectsAndKeys:
												 @"Replicon.TimeSheet.Domain.CalculationModeObject",@"__type",
												 @"CalculateInOutTime",@"Identity",
												 nil];
			[propertiesOperationDict setObject:calculationModeDict forKey:@"CalculationModeObject"];
			
			NSString *timeHours = [entryObject numberOfHours];
			if (timeHours != nil && ![timeHours isKindOfClass:[NSNull class]]) {
				DLog(@"String time is %@",timeHours);
				NSDictionary *timeDict = [G2Util convertDecimalHoursToApiTimeDict:timeHours];
				if (timeDict != nil && [timeDict isKindOfClass:[NSDictionary class]]) {
					[propertiesOperationDict setObject:timeDict forKey:@"Duration"];
				}
			}
			
			NSMutableDictionary *billingOperationsDict = [NSMutableDictionary dictionary];
			
			NSString *billingIdentity = [entryObject billingIdentity];
			NSNumber *projectRoleId = [entryObject projectRoleId];
			DLog(@"billing Identity %@",billingIdentity);
			if (billingIdentity != nil && ![billingIdentity isKindOfClass:[NSNull class]] && ![billingIdentity isEqualToString:NULL_STRING]) {
				
				NSMutableDictionary *billingTypeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
														@"Replicon.Project.Domain.Timesheets.TimesheetBillingType",@"__type",
														nil];
				NSDictionary *projectRoleDict = nil;
				if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
					
					billingIdentity = BILLING_ROLE_RATE;
					projectRoleDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",projectRoleId]
																  forKey:@"Identity"];
				}
				else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
					projectRoleDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",projectRoleId]
																  forKey:@"Identity"];
				}
				
				[billingTypeDict setObject:billingIdentity forKey:@"Identity"];//ullas
				[billingOperationsDict setObject:billingTypeDict forKey:@"BillingType"];//ullas
				
				if (projectRoleId != nil && ![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
					[billingOperationsDict setObject:projectRoleDict forKey:@"ProjectRole"];
				}
				else if (projectRoleId != nil && [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
					[billingOperationsDict setObject:projectRoleDict forKey:@"BillingDepartment"];
				}
			}
			
			NSString *projectIdentity = [entryObject projectIdentity];
			if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]] && ![projectIdentity isEqualToString:NULL_STRING]) {
				NSDictionary *projectDict = [NSDictionary dictionaryWithObjectsAndKeys:
											 projectIdentity,@"Identity",
											 @"Replicon.Project.Domain.Project",@"__type",
											 nil];
				[billingOperationsDict setObject:projectDict forKey:@"Project"];
			}
			
			[billingOperationsDict setObject:@"SetTimeEntryBilling" forKey:@"__operation"];
			
			NSArray *subOperationsArray = [NSArray arrayWithObjects:propertiesOperationDict,billingOperationsDict,nil];
			
			NSDictionary *mainOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
											   @"CollectionAdd",@"__operation",
											   @"TimeEntries",@"Collection",
											   subOperationsArray,@"Operations",
											   nil];
			[mainOperationsArray addObject:mainOperationDict];
		}
		
		NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
								 @"Edit",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"Type",
								 sheetIdentity,@"Identity",
								 mainOperationsArray,@"Operations",
								 nil];
		//Send  request
		NSError *err = nil;
		NSString *str = [JsonWrapper writeJson:queryDict error:&err];
		DLog(@"TIME SHEET CHECK QUERY	%@",str);
		NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
		[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
		[paramDict setObject:str forKey:@"PayLoadStr"];
		
		[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
		[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"SyncOfflineCreatedTimeEntries"]];
		[self setServiceDelegate:self];
		[self executeRequest];
	}
}
/*Added:July 13th 2011
 *Method: To fetch Booked Time Off's
 *Swapna
 */

-(void)sendRequestToFetchBookedTimeOffForUser{
    
//    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
     //[NSThread sleepForTimeInterval:1];
	DLog(@"sendRequestToFetchBookedTimeOffForUser:::TimeSheetService");
	
	NSMutableArray *dateArray = [timesheetModel getTimeSheetsStartAndEndDates];
	//DLog(@"Dates Array count %d",[dateArray count]);
	
	if (dateArray != nil && [dateArray count]>0)
    {
        if ([dateArray count]==1)
        {
            NSDictionary *dateDict=[dateArray objectAtIndex:0];
            NSString *startDateString     = [dateDict objectForKey:@"endDate"];
			NSString *endDateString       = [dateDict objectForKey:@"startDate"];
			//NSString *sheetId			  = [dateDict objectForKey:@"identity"];
			NSDate *startDate			  = [G2Util convertStringToDate:startDateString];
			NSDate *endDate				  = [G2Util convertStringToDate:endDateString];
			NSDictionary *startDateDict   = [G2Util convertDateToApiDateDictionary:startDate];
			NSDictionary *endDateDict     = [G2Util convertDateToApiDateDictionary:endDate];
            [self sendRequestToFetchBookedTimeOffForUserwithStartDate:startDateDict withEndDate:endDateDict];
			//totalRequestsSent++;
        }
        else
        {
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate"  ascending:YES];
             NSArray *sortedArr =[dateArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
            
            
            NSDictionary *firstdateDict=[sortedArr objectAtIndex:0];
            NSDictionary *lastdateDict=[sortedArr objectAtIndex:[sortedArr count]-1];
            NSString *startDateString     = [firstdateDict objectForKey:@"startDate"];
			NSString *endDateString       = [lastdateDict objectForKey:@"endDate"];
			//NSString *sheetId			  = [dateDict objectForKey:@"identity"];
			NSDate *startDate			  = [G2Util convertStringToDate:startDateString];
			NSDate *endDate				  = [G2Util convertStringToDate:endDateString];
			NSDictionary *startDateDict   = [G2Util convertDateToApiDateDictionary:startDate];
			NSDictionary *endDateDict     = [G2Util convertDateToApiDateDictionary:endDate];
            [self sendRequestToFetchBookedTimeOffForUserwithStartDate:endDateDict withEndDate:startDateDict];
			//totalRequestsSent++;
        }
        
		
	}
    
//    [pool drain];
}


-(void)sendRequestToFetchBookedTimeOffForUserwithStartDate:(NSDictionary *)_startDateDict
											withEndDate:(NSDictionary *)_endDateDict{
	
	NSString *userId       = [[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
	NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"Replicon.Domain.User",@"__type",
							  userId,@"Identity",nil];
	NSArray *argsArray     = [NSArray arrayWithObjects:userDict,_endDateDict,_startDateDict,nil];
	NSDictionary *loadDict = [NSDictionary dictionaryWithObject:@"TimeOffCode" forKey:@"Relationship"];
	NSDictionary *entryDict = [NSDictionary dictionaryWithObject:@"Entries" forKey:@"Relationship"];
	//NSArray *loadArray     = [NSArray arrayWithObject:loadDict];
	NSArray *loadArray     = [NSArray arrayWithObjects:loadDict,entryDict,nil];
	NSDictionary *queryDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"Query",@"Action",
                               @"TimeOffBookingByUserDateRange",@"QueryType",
                               @"Replicon.TimeOff.Domain.TimeOffBooking",@"DomainType",
                               argsArray,@"Args",
                               loadArray,@"Load",nil];
	//Send  request
	NSError *error = nil;
	NSString *queryStr = [JsonWrapper writeJson:queryDict error:&error];
    
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryStr forKey:@"PayLoadStr"];
	
	
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"BookedTimeOff"]];
	[self setServiceDelegate:self];
	[self executeRequest:nil];
	
}

-(void)sendRequestToFetchBookedTimeOffForUserForNextRecentTimesheets:(NSMutableArray *)valueArray
{
//    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
    if([valueArray count] > 0){//DE4004
        
        if ([valueArray count]==1)
        {
            NSDictionary *firstDateDict = [valueArray objectAtIndex:0];
            NSString *startDateString = [G2Util convertApiDateDictToDateString:[[firstDateDict objectForKey:@"Properties"] objectForKey:@"StartDate"]];
            NSString *endDateString = [G2Util convertApiDateDictToDateString:[[firstDateDict objectForKey:@"Properties"] objectForKey:@"EndDate"]];
            
            NSDate *startDate			  = [G2Util convertStringToDate:startDateString];
            NSDate *endDate				  = [G2Util convertStringToDate:endDateString];
            NSDictionary *startDateDict   = [G2Util convertDateToApiDateDictionary:startDate];
            NSDictionary *endDateDict     = [G2Util convertDateToApiDateDictionary:endDate];
            
            [self sendRequestToFetchBookedTimeOffForUserwithStartDate:endDateDict withEndDate:startDateDict];
            //totalRequestsSent++;
        }
        
        else
        {
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate"  ascending:YES];
            NSArray *sortedArr =[valueArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        
            NSDictionary *firstDateDict = [sortedArr objectAtIndex:[sortedArr count]-1];
            NSDictionary *lastDateDict = [sortedArr objectAtIndex:0];
            NSString *startDateString = [G2Util convertApiDateDictToDateString:[[firstDateDict objectForKey:@"Properties"] objectForKey:@"StartDate"]];
            NSString *endDateString = [G2Util convertApiDateDictToDateString:[[lastDateDict objectForKey:@"Properties"] objectForKey:@"EndDate"]];
            
            NSDate *startDate			  = [G2Util convertStringToDate:startDateString];
            NSDate *endDate				  = [G2Util convertStringToDate:endDateString];
            NSDictionary *startDateDict   = [G2Util convertDateToApiDateDictionary:startDate];
            NSDictionary *endDateDict     = [G2Util convertDateToApiDateDictionary:endDate];
            
            [self sendRequestToFetchBookedTimeOffForUserwithStartDate:endDateDict withEndDate:startDateDict];
            // totalRequestsSent++;
        }
        
        
    }
    else{
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"NumberOfTimeSheets"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter]postNotificationName:NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION object:[NSDictionary dictionary]];//DE4004
    }
    
//    [pool drain];
}

-(void)sendRequestToGetProjectsAndClients {
	/*
	 {
	 "Action": "Query",
	 "Args": [
     {
     "__type": "Replicon.Domain.User",
     "Identity": "2"
     }
	 ],
	 "Load": [
	 {
	 "Relationship": "ProjectClients",
	 "Load": [
	 {
	 "Relationship": "Client"
	 }
	 ]
	 },
	 {
	 "Relationship": "UserBillingOptions"
	 },
	 {
	 "Relationship": "RootTask"
	 }
	 ],	 
	 "QueryType": "TimesheetProjects",
	 "DomainType": "Replicon.Project.Domain.Project"
	 }
	 */
	
	//DLog(@"in sendRequestToGetProjectsAndClients method ");
	
	NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
	NSDictionary *argsDict=[NSDictionary dictionaryWithObjectsAndKeys:userId,@"Identity",@"Replicon.Domain.User",@"__type",nil];
	NSArray *argsArray = [NSArray arrayWithObject:argsDict];
	
	NSDictionary *clientsLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"Client",@"Relationship",
									 nil];
	NSArray *clientsLoadArray = [NSArray arrayWithObject:clientsLoadDict];
	
	NSDictionary *taskCountLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   @"Tasks",@"CountOf",
									   nil];
	
	NSDictionary *projectClientsLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
											@"ProjectClients",@"Relationship",
											clientsLoadArray,@"Load",
											nil];
	NSDictionary *billingOptionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
										@"UserBillingOptions",@"Relationship",nil];
	NSDictionary *rootTaskDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"RootTask",@"Relationship",nil];
	NSArray *loadArray = [NSArray arrayWithObjects:taskCountLoadDict, projectClientsLoadDict,
                          billingOptionsDict,rootTaskDict,nil];
    
	NSMutableDictionary *queryDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
									 @"TimesheetProjects",@"QueryType",
									 @"Replicon.Project.Domain.Project",@"DomainType",
									 argsArray,@"Args",
									 loadArray,@"Load",nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"sendRequestToGetProjectsAndClients::SupportDataService %@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"UserProjectsAndClients"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}

-(void)sendRequestToGetAllClients
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
	NSDictionary *argsDict=[NSDictionary dictionaryWithObjectsAndKeys:userId,@"Identity",@"Replicon.Domain.User",@"__type",nil];
	NSArray *argsArray = [NSArray arrayWithObject:argsDict];

	NSMutableDictionary *queryDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
									 @"TimesheetClientsByUser",@"QueryType",
									 @"Replicon.Domain.Client",@"DomainType",
									 argsArray,@"Args",
									nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"sendRequestToGeTClients::SupportDataService %@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"FetchAllTimesheetClients"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}

-(void)sendRequestToGetAllProjectsByClientID:(NSString *)clientID
{
    
    int countInt= [[[G2AppProperties getInstance]getAppPropertyFor:@"PaginatedProjectsClients"]intValue];
    NSNumber *count= [NSNumber numberWithInt:countInt];
    int index=0;
    NSDictionary *clientTableDict=[timesheetModel fetchQueryHandlerAndStartIndexForClientID:clientID];
    if ([clientTableDict objectForKey:@"timesheets_StartIndex"]!=nil && ![[clientTableDict objectForKey:@"timesheets_StartIndex"]isKindOfClass:[NSNull class]]) {
        index=[[clientTableDict objectForKey:@"timesheets_StartIndex"]intValue];
        if (index>0)
        {
            index=index-1;
        }
    }
    
	NSNumber *startIndex=[NSNumber numberWithInt:index];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
	NSDictionary *userArgsDict=[NSDictionary dictionaryWithObjectsAndKeys:userId,@"Identity",@"Replicon.Domain.User",@"__type",nil];
    NSDictionary *clientArgsDict=nil;
    if (![clientID isEqualToString:@"null"])
    {
        clientArgsDict=[NSDictionary dictionaryWithObjectsAndKeys:clientID,@"Identity",@"Replicon.Domain.Client",@"__type",nil];

    }
    NSArray *argsArray = nil;
    
    if (clientArgsDict!=nil)
    {
        argsArray = [NSArray arrayWithObjects:userArgsDict,clientArgsDict, nil];
    }

    else
    {
        argsArray = [NSArray arrayWithObjects:userArgsDict,[NSNull null], nil];
    }
    
    
   
    
    NSDictionary *clientsLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"Client",@"Relationship",@"true",@"IdentityOnly",
									 nil];
	NSArray *clientsLoadArray = [NSArray arrayWithObject:clientsLoadDict];
	
	NSDictionary *taskCountLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   @"Tasks",@"CountOf",
									   nil];
	
	NSDictionary *projectClientsLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
											@"ProjectClients",@"Relationship",
											clientsLoadArray,@"Load",
											nil];
	
	NSDictionary *rootTaskDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"RootTask",@"Relationship",nil];
	NSArray *loadArray = [NSArray arrayWithObjects:taskCountLoadDict, projectClientsLoadDict,rootTaskDict,nil];
    
     NSMutableArray *sortArray=[NSMutableArray arrayWithObjects:@"Name", nil];
    
	NSMutableDictionary *queryDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:count,@"Count",@"Query",@"Action",
									 @"TimesheetProjectsByUserClient",@"QueryType",
									 @"Replicon.Project.Domain.Project",@"DomainType",
									 argsArray,@"Args",loadArray,@"Load",sortArray,@"SortBy",startIndex,@"StartIndex",
                                     nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"sendRequestToGetProjects::SupportDataService %@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"FetchAllTimesheetProjects"]];
	[self setServiceDelegate:self];
	[self executeRequest:[NSDictionary dictionaryWithObjectsAndKeys:clientID,@"ClientID",startIndex,@"startIndex", nil]];
}

-(void)sendRequestTogetTimesheetProjectswithProjectIds:(NSMutableArray *)projectIdsArr
{
	
	NSMutableArray *argsArray = [NSMutableArray array];
    if (projectIdsArr!=nil)
    {
        
        [argsArray addObject:projectIdsArr];
        
    }
   
    
    
    NSDictionary *clientsLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"Client",@"Relationship",@"true",@"IdentityOnly",
									 nil];
	NSArray *clientsLoadArray = [NSArray arrayWithObject:clientsLoadDict];
	
	NSDictionary *taskCountLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   @"Tasks",@"CountOf",
									   nil];
	
	NSDictionary *projectClientsLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
											@"ProjectClients",@"Relationship",
											clientsLoadArray,@"Load",
											nil];
	
	NSDictionary *rootTaskDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"RootTask",@"Relationship",nil];
	NSArray *loadArray = [NSArray arrayWithObjects:taskCountLoadDict, projectClientsLoadDict,rootTaskDict,nil];
    
    
    
	NSMutableDictionary *queryDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
									 @"ProjectByIds",@"QueryType",
									 @"Replicon.Project.Domain.Project",@"DomainType",
									 argsArray,@"Args",loadArray,@"Load",
                                     nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"sendRequestToGetProjectsByIds::SupportDataService %@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"FetchAllTimesheetProjectsByIds"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}

-(void)sendRequestToGetAllBillingOptionsByClientID:(NSString *)clientID
{

    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
	NSDictionary *userArgsDict=[NSDictionary dictionaryWithObjectsAndKeys:userId,@"Identity",@"Replicon.Domain.User",@"__type",nil];
    NSDictionary *clientArgsDict=nil;
    if (![clientID isEqualToString:@"null"] && clientID!=nil)
    {
        clientArgsDict=[NSDictionary dictionaryWithObjectsAndKeys:clientID,@"Identity",@"Replicon.Domain.Client",@"__type",nil];
        
    }
    NSArray *argsArray = nil;
    
    if (clientArgsDict!=nil)
    {
        argsArray = [NSArray arrayWithObjects:userArgsDict,clientArgsDict, nil];
    }
    
    else
    {
        argsArray = [NSArray arrayWithObjects:userArgsDict,[NSNull null], nil];
    }
    
	
	NSDictionary *billingOptionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
										@"UserBillingOptions",@"Relationship",nil];
    
	NSArray *loadArray = [NSArray arrayWithObjects:billingOptionsDict,nil];
   
    
	NSMutableDictionary *queryDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
									 @"TimesheetProjectsByUserClient",@"QueryType",
									 @"Replicon.Project.Domain.Project",@"DomainType",
									 argsArray,@"Args",loadArray,@"Load",
                                     nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"sendRequestToGetBillingOptions::SupportDataService %@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"FetchAllTimesheetUserBillingOptionsByProjectID"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}

-(void)sendRequestToDeleteTimeEntry:(NSString *)identity sheetIdentity:(NSString *)_sheetIdentity {
	
	/*
	 [
	 {
	 "Action": "Edit",
	 "Type": "Replicon.Suite.Domain.EntryTimesheet",
	 "Identity": "1",
	 "Operations":
	 [
	 {
	 "__operation": "SetProperties",
	 "User":
	 {
	 "__type": "Replicon.Domain.User",
	 "Identity": "2"
	 }
	 },
	 {
	 "__operation": "CollectionRemove",
	 "Collection": "TimeEntries",
	 "Identity": "1"
	 }
	 ]
	 }
	 ]*/
	
	NSDictionary *userDict;
	userDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.User",@"__type",[[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"],@"Identity",nil];
	
	NSDictionary *setPropertiesOperationsDict;
	setPropertiesOperationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"SetProperties",@"__operation",userDict,@"User",nil];
	
	NSMutableArray *mainOperationArray=[NSMutableArray array];
	[mainOperationArray addObject:setPropertiesOperationsDict];
	
    
	NSDictionary *collectionOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"CollectionRemove",@"__operation",
                                             @"TimeEntries",@"Collection",
                                             identity,@"Identity",
                                             nil];
	[mainOperationArray addObject:collectionOperationDict];
    
	NSDictionary *firstEditDict=[NSDictionary dictionaryWithObjectsAndKeys:
								 mainOperationArray,@"Operations",
								 _sheetIdentity,@"Identity",
								 @"Replicon.Suite.Domain.EntryTimesheet",@"Type",
								 @"Edit",@"Action",nil];
	NSMutableArray *queryArray=[NSMutableArray array];
	[queryArray addObject:firstEditDict];
	
	NSError *err = nil;
	NSString *queryString = [JsonWrapper writeJson:queryArray error:&err];
	
	//DLog(@"query str %@",queryString);
	NSMutableDictionary *otherParamsDict = [NSMutableDictionary dictionary];
	if (identity != nil && ![identity isKindOfClass:[NSNull class]]) {
		[otherParamsDict setObject:identity forKey:@"entryIdentity"];
		[otherParamsDict setObject:_sheetIdentity forKey:@"sheetIdentity"];
	}
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"DeleteTimeEntry"]];
	[self setServiceDelegate:self];
	[self executeRequest:otherParamsDict];
}

-(void)sendRequestToDeleteTimeOffEntry:(NSString *)identity sheetIdentity:(NSString *)_sheetIdentity
{
	

	
	NSDictionary *userDict;
	userDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.User",@"__type",[[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"],@"Identity",nil];
	
	NSDictionary *setPropertiesOperationsDict;
	setPropertiesOperationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"SetProperties",@"__operation",userDict,@"User",nil];
	
	NSMutableArray *mainOperationArray=[NSMutableArray array];
	[mainOperationArray addObject:setPropertiesOperationsDict];
	
    
	NSDictionary *collectionOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"CollectionRemove",@"__operation",
                                             @"TimeOffEntries",@"Collection",
                                             identity,@"Identity",
                                             nil];
	[mainOperationArray addObject:collectionOperationDict];
    
	NSDictionary *firstEditDict=[NSDictionary dictionaryWithObjectsAndKeys:
								 mainOperationArray,@"Operations",
								 _sheetIdentity,@"Identity",
								 @"Replicon.Suite.Domain.EntryTimesheet",@"Type",
								 @"Edit",@"Action",nil];
	NSMutableArray *queryArray=[NSMutableArray array];
	[queryArray addObject:firstEditDict];
	
	NSError *err = nil;
	NSString *queryString = [JsonWrapper writeJson:queryArray error:&err];
	
	//DLog(@"query str %@",queryString);
	NSMutableDictionary *otherParamsDict = [NSMutableDictionary dictionary];
	if (identity != nil && ![identity isKindOfClass:[NSNull class]]) {
		[otherParamsDict setObject:identity forKey:@"entryIdentity"];
		[otherParamsDict setObject:_sheetIdentity forKey:@"sheetIdentity"];
	}
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"DeleteTimeOffEntry"]];
	[self setServiceDelegate:self];
	[self executeRequest:otherParamsDict];
}

-(void)sendRequestToGetModifiedTimeSheetsFromLastUpdatedDate:(NSDate *)lastUpdatedDate {
	/*
	 {
	 "Action": "Query",
	 "QueryType": "TimesheetsByUserModifiedSince",
	 "DomainType": "Replicon.TimeSheet.Domain.Timesheet",
	 "Args": [
	 {
	 "Type": "Replicon.Domain.User",
	 "Identity": "2"
	 },
	 {
	 "Type": "DateTime",
	 "Year": 2011,
	 "Month": 7,
	 "Day": 19,
	 "Hour": 10,
	 "Minute": 12,
	 "Second": 49
	 }
	 ],
	 "Load": [
	 {
	 "Relationship": "TimeEntries",
	 "Load": [
	 {
	 "Relationship": "Activity"
	 },
	 {
	 "Relationship": "ProjectRole"
	 },
	 {
	 "Relationship": "Client"
	 },
	 {
	 "Relationship": "Task",
	 "Load": [
	 {
	 "CountOf": "ChildTasks"
	 },
	 {
	 "Relationship": "Project",
	 "Load": [
	 {
	 "Relationship": "ProjectClients",
	 "Load": [
	 {
	 "Relationship": "Client"
	 }]}]}]}]},
	 {
	 "Relationship": "TimeOffEntries",
	 "Load" : [
	 {
	 "Relationship": "TimeOffCode"
	 }]}]}
	 */
	
	NSMutableArray *argsArray = [NSMutableArray array];
	NSString *userId= [[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
	NSDictionary *argsDict=[NSDictionary dictionaryWithObjectsAndKeys:userId,@"Identity",@"Replicon.Domain.User",@"__type",nil];
	[argsArray addObject:argsDict];
	
	NSMutableDictionary *dateDetailsDict = [G2Util getDateDictionaryforTimeZoneWith:@"UTC" forDate:lastUpdatedDate];
	//DLog(@"Date details %@",dateDetailsDict);
	if (dateDetailsDict != nil) {
		[dateDetailsDict setObject:@"DateTime" forKey:@"__type"];
		[argsArray addObject:dateDetailsDict];
	}
	
	NSMutableArray *loadArray = [NSMutableArray array];
	
	NSDictionary *activityDict    = [NSDictionary dictionaryWithObjectsAndKeys:@"Activity",@"Relationship",nil];
	NSDictionary *projectRoleDict = [NSDictionary dictionaryWithObjectsAndKeys:@"ProjectRole",@"Relationship",nil];
	NSDictionary *billingDepartmentDict = [NSDictionary dictionaryWithObjectsAndKeys:@"BillingRateDepartment",@"Relationship",nil];
	NSDictionary *clientDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
	NSDictionary *billingDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Billable",@"Relationship",nil];
	//NSDictionary *clientsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
	//load array for client relatonship in projectClient and add to projectclientDict
	NSArray *projectClientLoadArray = [NSArray arrayWithObjects:clientDict,nil];
	NSDictionary *projectClientDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   @"ProjectClients",@"Relationship",
									   projectClientLoadArray,@"Load",
									   nil];
	//load array for projectClients in project and add to projectDict
	NSArray *projectLoadArray = [NSArray arrayWithObjects:projectClientDict,nil];
	NSDictionary *projectDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Project",@"Relationship",
								 projectLoadArray,@"Load",
								 nil];
	NSDictionary *childTaskCountDict = [NSDictionary dictionaryWithObject:@"ChildTasks" forKey:@"CountOf"];
	NSDictionary *parentTaskDict = [NSDictionary dictionaryWithObject:@"ParentTask" forKey:@"Relationship"];
	//Load array for project in task and add to taskDict
	NSArray *taskLoadArray = [NSArray arrayWithObjects:projectDict,childTaskCountDict,parentTaskDict,nil];
	NSDictionary *taskDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Task",@"Relationship",
							  taskLoadArray,@"Load",
							  nil];
	
	//Load array for activity,projectrole,client, task to timeentries and add to TimeEntriesDict
	NSArray *timeEntriesLoadArray = [NSArray arrayWithObjects:activityDict,projectRoleDict,billingDepartmentDict,clientDict,taskDict,billingDict,nil];
	NSDictionary *timeEntriesDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeEntries",@"Relationship",
								   timeEntriesLoadArray,@"Load",
								   nil];
	NSDictionary *timeOffCodeDict = [NSDictionary dictionaryWithObjectsAndKeys:@"TimeOffCode",@"Relationship",nil];
	NSArray *timeOffEntriesLoadArray = [NSArray arrayWithObject:timeOffCodeDict];
	NSDictionary *timeOffEntriesDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeOffEntries",@"Relationship",
									  timeOffEntriesLoadArray,@"Load",
									  nil];
	NSDictionary *remainingApproversDict = [NSDictionary dictionaryWithObjectsAndKeys:
											@"RemainingApprovers",@"Relationship",
											nil];
	NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Type",@"Relationship",nil];
	NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
	NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"FilteredHistory",@"Relationship",
										 approvalLoadArray,@"Load",
										 nil];
    
    NSDictionary *languageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Language",@"Relationship",nil];
    NSArray *languageArray=[NSArray arrayWithObject:languageDict];
	NSDictionary *mealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BreakRuleViolationEntries",@"Relationship",languageArray,@"Load",nil];
    NSDictionary *finalmealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BreakRuleViolations",@"Relationship",[NSArray arrayWithObject:mealBreakViolationsDict],@"Load",nil];
    
    
	[loadArray addObject:timeEntriesDict];
	[loadArray addObject:timeOffEntriesDict];
	[loadArray addObject:remainingApproversDict];
	[loadArray addObject:filteredHistoryDict];
    [loadArray addObject:finalmealBreakViolationsDict];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:argsArray,@"Args",
							 @"Query",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
							 @"EntryTimesheetByUserModifiedSince",@"QueryType",
							 loadArray,@"Load",
							 nil];
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET CHECK QUERY:::FETCH	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ModifiedTimesheets"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}
-(void)sendTimeSheetRequestToFetchSheetLevelUDFsWithPermissionSet:(NSMutableArray *)_permissionSet{
	/*
	 {
	 "Action": "Query",
	 "QueryType": "UdfGroupByName",
	 "DomainType": "Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
	 "Args": [
	 "TimeOffs"
	 ],
	 "Load": [
	 {
	 "Relationship": "Fields",
	 "Load": [
	 {
	 "Relationship": "DropDownOptions"
	 }
	 ]
	 }
	 ]
	 }
	 */
	//DLog(@"Permission Set %@",_permissionSet);
	BOOL rowlevel = 0;
	BOOL celllevel = 0;
	BOOL sheetlevel = 0;
	if (_permissionSet != nil && [_permissionSet count]>0) {
		for (NSDictionary *permission in _permissionSet) {
			if ([permission objectForKey:TaskTimesheet_RowLevel]) {
				DLog(@"Row");
				rowlevel = [[permission objectForKey:TaskTimesheet_RowLevel] intValue];
			}
			if ([permission objectForKey:ReportPeriod_SheetLevel]) {
				DLog(@"sheet");
				sheetlevel = [[permission objectForKey:ReportPeriod_SheetLevel] intValue];
			}
			if ([permission objectForKey:TimesheetEntry_CellLevel]) {
				DLog(@"cell");
				celllevel = [[permission objectForKey:TimesheetEntry_CellLevel] intValue];
			}
		}
	}
	NSArray *sheetArgsArray = [NSArray arrayWithObject:ReportPeriod_SheetLevel];
	NSArray *rowArgsArray   = [NSArray arrayWithObject:TaskTimesheet_RowLevel];
	NSArray *cellArgsArray  = [NSArray arrayWithObject:TimesheetEntry_CellLevel];
   
    NSArray *timeOffsArgsArray  = [NSArray arrayWithObject:TimeOffs_SheetLevel];//US4591//Juhi

   
	NSDictionary *dropDownOptionsRelationDict  = [NSDictionary dictionaryWithObject:
												  @"DropDownOptions" forKey:@"Relationship"];
	NSArray *fieldsLoadArray = [NSArray arrayWithObject:dropDownOptionsRelationDict];
	NSDictionary *fieldsRelationDict = [NSDictionary dictionaryWithObjectsAndKeys:
										@"Fields",@"Relationship",
										fieldsLoadArray,@"Load",
										nil
										];
	NSArray *loadArray = [NSArray arrayWithObject:fieldsRelationDict];
	NSMutableDictionary *sheetLevelDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
										  @"UdfGroupByName",@"QueryType",
										  @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
										  @"DomainType",
										  sheetArgsArray,@"Args",
										  loadArray,@"Load",
										  nil];
	NSMutableDictionary *rowLevelDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
										@"UdfGroupByName",@"QueryType",
										@"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
										@"DomainType",
										rowArgsArray,@"Args",
										loadArray,@"Load",
										nil];
	NSMutableDictionary *cellLevelDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
										 @"UdfGroupByName",@"QueryType",
										 @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
										 @"DomainType",
										 cellArgsArray,@"Args",
										 loadArray,@"Load",
										 nil];
    
    NSMutableDictionary *timeOffsLevelDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
										 @"UdfGroupByName",@"QueryType",
										 @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
										 @"DomainType",
										 timeOffsArgsArray,@"Args",
										 loadArray,@"Load",
										 nil];//US4591//Juhi
    
	NSMutableArray *query = [NSMutableArray array];
	
	
	if (sheetlevel) {
		[query addObject:sheetLevelDict];
	}
	if (rowlevel) {
		[query addObject:rowLevelDict];
	}
	if (timeOffsLevelDict) {
		[query addObject:timeOffsLevelDict];
	}
//    if (isFromNewPopUpForTimeOff)//US4591//Juhi
//    {
//        [query addObject:timeOffsLevelDict];
//    }
    
    if (celllevel) {
		[query addObject:cellLevelDict];
	}
	
	//DLog(@"Query Array %@",query);
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:query error:&err];
	DLog(@"Json String to fetch UDF's for Time Sheets %@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"TimesheetUDFs"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}
//US4591//Juhi
-(void)sendTimeSheetRequestToFetchTimeOffLevelUDFs{
	/*
	 {
	 "Action": "Query",
	 "QueryType": "UdfGroupByName",
	 "DomainType": "Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
	 "Args": [
	 "TimeOffs"
	 ],
	 "Load": [
	 {
	 "Relationship": "Fields",
	 "Load": [
	 {
	 "Relationship": "DropDownOptions"
	 }
	 ]
	 }
	 ]
	 }
	 */
    NSArray *timeOffsArgsArray  = [NSArray arrayWithObject:TimeOffs_SheetLevel];
	
	NSDictionary *dropDownOptionsRelationDict  = [NSDictionary dictionaryWithObject:
												  @"DropDownOptions" forKey:@"Relationship"];
	NSArray *fieldsLoadArray = [NSArray arrayWithObject:dropDownOptionsRelationDict];
	NSDictionary *fieldsRelationDict = [NSDictionary dictionaryWithObjectsAndKeys:
										@"Fields",@"Relationship",
										fieldsLoadArray,@"Load",
										nil
										];
	NSArray *loadArray = [NSArray arrayWithObject:fieldsRelationDict];
	
    NSMutableDictionary *timeOffsLevelDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
                                             @"UdfGroupByName",@"QueryType",
                                             @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
                                             @"DomainType",
                                             timeOffsArgsArray,@"Args",
                                             loadArray,@"Load",
                                             nil];
	NSMutableArray *query = [NSMutableArray array];
	[query addObject:timeOffsLevelDict];
	//DLog(@"Query Array %@",query);
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:query error:&err];
	DLog(@"Json String to fetch UDF's for Time Sheets %@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"TimesheetUDFs"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}
-(void)sendRequestToFetchSheetsExistanceInfo
{
	/*{
	 "Action": "Exists",
	 "Type": "Replicon.Suite.Domain.EntryTimesheet",
	 "Identities": [ "1", "2", "3" ]
	 }*/
	
    
	NSMutableArray *identitiesArray = [timesheetModel getAllSheetIdentitiesFromDB];
	
	NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Exists",@"Action",
									  @"Replicon.Suite.Domain.EntryTimesheet",@"Type",identitiesArray,@"Identities",nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	[self setRequest: [G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName: @"TimeSheetsExisted"]];
	[self setServiceDelegate: self];
	[self executeRequest];
	
}


-(void) sendRequestToUpdateDisclaimerAcceptanceDate: (NSString *)sheetIdentity disclaimerAcceptanceDate:(NSDate *)disclaimerAcceptanceDate{
    
    NSMutableDictionary *acceptanceDateDetailsDict =nil;
    
    if (disclaimerAcceptanceDate) {
        NSMutableDictionary *dateDetailsDict = [G2Util getDateDictionaryforTimeZoneWith:@"GMT" forDate:disclaimerAcceptanceDate];
        if (dateDetailsDict != nil) 
        {
            acceptanceDateDetailsDict=[NSMutableDictionary dictionaryWithDictionary:dateDetailsDict];
            [acceptanceDateDetailsDict setObject:@"DateTime" forKey:@"__type"];
        }
    }
    
    NSDictionary *operationDict=nil;
    if (acceptanceDateDetailsDict!=nil)
    {
         operationDict=[NSDictionary dictionaryWithObjectsAndKeys:@"SetProperties",@"__operation",acceptanceDateDetailsDict,@"DisclaimerAccepted", nil];
    }
    else
    {
         operationDict=[NSDictionary dictionaryWithObjectsAndKeys:@"SetProperties",@"__operation",[NSNull null],@"DisclaimerAccepted", nil];
    }
   
	NSArray *operationsArray=[NSArray arrayWithObject:operationDict];
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Edit",@"Action",@"True",@"ValidationAsWarnings",@"Replicon.Suite.Domain.EntryTimesheet",@"Type",
							 sheetIdentity,@"Identity",
							 operationsArray,@"Operations",
							 nil];
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"UpdateDisclaimerAcceptedDateForTimesheets"]];
	[self setServiceDelegate:self];
	[self executeRequest]; 
	
}

-(void)sendRequestForMergedTimesheetAPIWithDelegate:(id)delegate
{
    BOOL supportDataCanRun = [G2Util shallExecuteQuery:TIMESHEET_SUPPORT_DATA_SERVICE_SECTION];
    BOOL timeOffSupportDataCanRun=[G2Util shallExecuteQuery:TIMEOFF_SUPPORT_DATA_SERVICE_SECTION];
//	BOOL sheetDataCanRun = [Util shallExecuteQuery:TIMESHEET_DATA_SERVICE_SECTION];
	NSMutableArray *dbTimeSheets = [timesheetModel getTimesheetsFromDB];
	NSMutableArray *mergedRequestArr=[NSMutableArray array];

	
	    
    if ([dbTimeSheets count] == 0 ) {
		DLog(@"requestMostRecentTimeSheets");
		
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:TIMESHEET_DATA_CAN_RUN];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
		//clear out Tasks in DB for every 7 days - US1892.
		[timesheetModel deleteTasksFromDB];
		

        
               
		//MOST RECENT TIMESHEETS FOR USER
        
        NSNumber *count= [[G2AppProperties getInstance] getAppPropertyFor:@"MostRecentTimeSheetsCount"];
        NSNumber *startIndex=[NSNumber numberWithInt:0];
        NSString *userId=[[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
        NSMutableArray *argsArray=[NSMutableArray array];
        NSDictionary *argsDict=[NSDictionary dictionaryWithObjectsAndKeys:userId,@"Identity",@"Replicon.Domain.User",@"__type",nil];
        [argsArray addObject:argsDict];
        NSArray *enumArr = [NSArray arrayWithObjects:@"Approved",nil];
        NSDictionary *approveSortDict=[NSDictionary dictionaryWithObjectsAndKeys:@"ApprovalStatus",@"Property",
                                       enumArr,@"EnumOrder",
                                       [NSNumber numberWithBool:YES],@"Descending",nil];
        NSDictionary *endDateSortDict=[NSDictionary dictionaryWithObjectsAndKeys:@"EndDate",@"Property",
                                       [NSNumber numberWithBool:YES],@"Descending",nil];
        
        NSMutableArray *loadArray=[NSMutableArray array];
        
        NSMutableArray *sortArray=[NSMutableArray array];
        [sortArray addObject:approveSortDict];
        [sortArray addObject:endDateSortDict];
        
        NSDictionary *activityDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Activity",@"Relationship",nil];
        NSDictionary *projectRoleDict = [NSDictionary dictionaryWithObjectsAndKeys:@"ProjectRole",@"Relationship",nil];
        NSDictionary *billingDepartmentDict = [NSDictionary dictionaryWithObjectsAndKeys:@"BillingRateDepartment",@"Relationship",nil];
        NSDictionary *clientDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
        NSDictionary *billingDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Billable",@"Relationship",nil];
        
        //load array for client relatonship in projectClient and add to projectclientDict
        NSArray *projectClientLoadArray = [NSArray arrayWithObjects:clientDict,nil];
        NSDictionary *projectClientDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"ProjectClients",@"Relationship",
                                           projectClientLoadArray,@"Load",
                                           nil];
        //load array for projectClients in project and add to projectDict
        NSArray *projectLoadArray = [NSArray arrayWithObjects:projectClientDict,nil];
        NSDictionary *projectDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Project",@"Relationship",
                                     projectLoadArray,@"Load",
                                     nil];
        NSDictionary *childTaskCountDict = [NSDictionary dictionaryWithObject:@"ChildTasks" forKey:@"CountOf"];
        NSDictionary *parentTaskDict  = [NSDictionary dictionaryWithObject:@"ParentTask" forKey:@"Relationship"];
        //Load array for project in task and add to taskDict
        NSArray *taskLoadArray = [NSArray arrayWithObjects:projectDict,childTaskCountDict,parentTaskDict,nil];
        NSDictionary *taskDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Task",@"Relationship",
                                  taskLoadArray,@"Load",
                                  nil];
        
        //Load array for activity,project role,client, task to timeentries and add to TimeEntriesDict
        NSArray *timeEntriesLoadArray = [NSArray arrayWithObjects:activityDict,projectRoleDict,billingDepartmentDict,clientDict,taskDict,billingDict,nil];
        NSDictionary *timeEntriesDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeEntries",@"Relationship",
                                       timeEntriesLoadArray,@"Load",
                                       nil];
        NSDictionary *timeOffCodeDict = [NSDictionary dictionaryWithObjectsAndKeys:@"TimeOffCode",@"Relationship",nil];
        NSArray *timeOffEntriesLoadArray = [NSArray arrayWithObject:timeOffCodeDict];
        NSDictionary *timeOffEntriesDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeOffEntries",@"Relationship",
                                          timeOffEntriesLoadArray,@"Load",
                                          nil];
        NSDictionary *remainingApproversDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                @"RemainingApprovers",@"Relationship",
                                                nil];
        NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Type",@"Relationship",nil];
        NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
        NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"FilteredHistory",@"Relationship",
                                             approvalLoadArray,@"Load",
                                             nil];
        
        NSDictionary *languageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Language",@"Relationship",nil];
        NSArray *languageArray=[NSArray arrayWithObject:languageDict];
        NSDictionary *mealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BreakRuleViolationEntries",@"Relationship",languageArray,@"Load",nil];
        NSDictionary *finalmealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BreakRuleViolations",@"Relationship",[NSArray arrayWithObject:mealBreakViolationsDict],@"Load",nil];
        
        [loadArray addObject:timeEntriesDict];
        [loadArray addObject:timeOffEntriesDict];
        [loadArray addObject:remainingApproversDict];
        [loadArray addObject:filteredHistoryDict];
        [loadArray addObject:finalmealBreakViolationsDict];
        
        NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:count,@"Count",argsArray,@"Args",sortArray,@"SortBy",
                                 @"Query",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
                                 loadArray,@"Load",@"EntryTimesheetByUser",@"QueryType",startIndex,@"StartIndex",
                                 nil];
        
        [mergedRequestArr addObject:queryDict];
		
	}
    else if(dbTimeSheets != nil && [dbTimeSheets count] > 0)
    {
        NSDate *lastUpdatedDate =[NSDate date];
		id lastSyncDateSeconds = [G2SupportDataModel getLastSyncDateForServiceId:TIMESHEET_DATA_SERVICE_SECTION];
        if (lastSyncDateSeconds!=nil && ![lastSyncDateSeconds isKindOfClass:[NSNull class]]) {
           lastUpdatedDate = [NSDate dateWithTimeIntervalSince1970:[lastSyncDateSeconds longValue]];
        }
		
		
        //MODIFIED TIMESHEETS REQUEST
        NSMutableArray *argsArray = [NSMutableArray array];
        NSString *userId= [[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
        NSDictionary *argsDict=[NSDictionary dictionaryWithObjectsAndKeys:userId,@"Identity",@"Replicon.Domain.User",@"__type",nil];
        [argsArray addObject:argsDict];
        
        NSMutableDictionary *dateDetailsDict = [G2Util getDateDictionaryforTimeZoneWith:@"UTC" forDate:lastUpdatedDate];
        //DLog(@"Date details %@",dateDetailsDict);
        if (dateDetailsDict != nil) {
            [dateDetailsDict setObject:@"DateTime" forKey:@"__type"];
            [argsArray addObject:dateDetailsDict];
        }
        
        NSMutableArray *loadArray = [NSMutableArray array];
        
        NSDictionary *activityDict    = [NSDictionary dictionaryWithObjectsAndKeys:@"Activity",@"Relationship",nil];
        NSDictionary *projectRoleDict = [NSDictionary dictionaryWithObjectsAndKeys:@"ProjectRole",@"Relationship",nil];
        NSDictionary *billingDepartmentDict = [NSDictionary dictionaryWithObjectsAndKeys:@"BillingRateDepartment",@"Relationship",nil];
        NSDictionary *clientDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
        NSDictionary *billingDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Billable",@"Relationship",nil];
        //NSDictionary *clientsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
        //load array for client relatonship in projectClient and add to projectclientDict
        NSArray *projectClientLoadArray = [NSArray arrayWithObjects:clientDict,nil];
        NSDictionary *projectClientDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"ProjectClients",@"Relationship",
                                           projectClientLoadArray,@"Load",
                                           nil];
        //load array for projectClients in project and add to projectDict
        NSArray *projectLoadArray = [NSArray arrayWithObjects:projectClientDict,nil];
        NSDictionary *projectDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Project",@"Relationship",
                                     projectLoadArray,@"Load",
                                     nil];
        NSDictionary *childTaskCountDict = [NSDictionary dictionaryWithObject:@"ChildTasks" forKey:@"CountOf"];
        NSDictionary *parentTaskDict = [NSDictionary dictionaryWithObject:@"ParentTask" forKey:@"Relationship"];
        //Load array for project in task and add to taskDict
        NSArray *taskLoadArray = [NSArray arrayWithObjects:projectDict,childTaskCountDict,parentTaskDict,nil];
        NSDictionary *taskDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Task",@"Relationship",
                                  taskLoadArray,@"Load",
                                  nil];
        
        //Load array for activity,projectrole,client, task to timeentries and add to TimeEntriesDict
        NSArray *timeEntriesLoadArray = [NSArray arrayWithObjects:activityDict,projectRoleDict,billingDepartmentDict,clientDict,taskDict,billingDict,nil];
        NSDictionary *timeEntriesDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeEntries",@"Relationship",
                                       timeEntriesLoadArray,@"Load",
                                       nil];
        NSDictionary *timeOffCodeDict = [NSDictionary dictionaryWithObjectsAndKeys:@"TimeOffCode",@"Relationship",nil];
        NSArray *timeOffEntriesLoadArray = [NSArray arrayWithObject:timeOffCodeDict];
        NSDictionary *timeOffEntriesDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TimeOffEntries",@"Relationship",
                                          timeOffEntriesLoadArray,@"Load",
                                          nil];
        NSDictionary *remainingApproversDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                @"RemainingApprovers",@"Relationship",
                                                nil];
        NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Type",@"Relationship",nil];
        NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
        NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"FilteredHistory",@"Relationship",
                                             approvalLoadArray,@"Load",
                                             nil];
        
        NSDictionary *languageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Language",@"Relationship",nil];
        NSArray *languageArray=[NSArray arrayWithObject:languageDict];
        NSDictionary *mealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BreakRuleViolationEntries",@"Relationship",languageArray,@"Load",nil];
        NSDictionary *finalmealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BreakRuleViolations",@"Relationship",[NSArray arrayWithObject:mealBreakViolationsDict],@"Load",nil];
        
        
        [loadArray addObject:timeEntriesDict];
        [loadArray addObject:timeOffEntriesDict];
        [loadArray addObject:remainingApproversDict];
        [loadArray addObject:filteredHistoryDict];
        [loadArray addObject:finalmealBreakViolationsDict];
        
        NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:argsArray,@"Args",
                                 @"Query",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
                                 @"EntryTimesheetByUserModifiedSince",@"QueryType",
                                 loadArray,@"Load",
                                 nil];
        [mergedRequestArr addObject:queryDict];
		
	}
    
    
	if (supportDataCanRun) {
		DLog(@"support data can run");
		
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:TIMESHEET_SUPPORT_DATA_CAN_RUN];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //GET USER ACTIVITIES
        
        NSDictionary *activityDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"Activities",@"Relationship",nil];
        NSDictionary *timeOffCodesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"TimeOffCodeAssignments",@"Relationship",nil];
        
        NSMutableArray *loadArray1  = [NSMutableArray array];
        [loadArray1 addObject:activityDict];
        [loadArray1 addObject:timeOffCodesDict];
        
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
        NSMutableDictionary *queryDict1 =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"LoadIdentity",@"Action",
                                         @"Replicon.Domain.User",@"DomainType",
                                         userId,@"Identity",
                                         loadArray1,@"Load",nil];
        
        [mergedRequestArr addObject:queryDict1];
        

        
        //GET UDF"S WITH PERMISSION SET
        
        
        G2PermissionsModel *permissionsModel   = [[G2PermissionsModel alloc] init];
        NSMutableArray *enabledPermissionSet = [permissionsModel getEnabledUserPermissions];
        
        NSDictionary *cellUdfDict = nil;
        NSDictionary *rowUdfDict = nil;
        NSDictionary *entireUdfDict = nil;
        NSMutableArray *udfpermissions = [NSMutableArray array];
        NSMutableArray  *permissionSet = [NSMutableArray array];
        for (NSDictionary *permissionDict in enabledPermissionSet) {
            NSString * permission = [permissionDict objectForKey:@"permissionName"];
            NSString *shortString = nil;
            if (![permission isKindOfClass:[NSNull class] ])
            {
                if ([permission length]-4 > 0) {
                    NSRange stringRange = {0, MIN([permission length], [permission length]-4)};
                    stringRange = [permission rangeOfComposedCharacterSequencesForRange:stringRange];
                    shortString = [permission substringWithRange:stringRange];
                    //DLog(@"Short String:HomeViewController %@",shortString);
                }
            }
            
            [udfpermissions addObject:shortString];
        }
        if ([udfpermissions containsObject:TimesheetEntry_CellLevel]) {
            cellUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:TimesheetEntry_CellLevel];
        }
        if ([udfpermissions containsObject:TaskTimesheet_RowLevel]) {
            rowUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:TaskTimesheet_RowLevel];
        }
        if ([udfpermissions containsObject:ReportPeriod_SheetLevel]) {
            entireUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:ReportPeriod_SheetLevel];
        }
#ifdef DEV_DEBUG
        DLog(@"Permission array %@",udfpermissions);
        DLog(@"Cell Udf Dict %@",cellUdfDict);
        DLog(@"Row  Udf Dict %@",rowUdfDict);
        DLog(@"Entire Udf Dict %@",entireUdfDict);
#endif
        
        if (cellUdfDict != nil) {
            [permissionSet addObject:cellUdfDict];
        }
        if (rowUdfDict != nil) {
            [permissionSet addObject:rowUdfDict];
        }
        if (entireUdfDict != nil) {
            [permissionSet addObject:entireUdfDict];
        }

        
        BOOL rowlevel = 0;
        BOOL celllevel = 0;
        BOOL sheetlevel = 0;
        if (permissionSet != nil && [permissionSet count]>0) {
            for (NSDictionary *permission in permissionSet) {
                if ([permission objectForKey:TaskTimesheet_RowLevel]) {
                    DLog(@"Row");
                    rowlevel = [[permission objectForKey:TaskTimesheet_RowLevel] intValue];
                }
                if ([permission objectForKey:ReportPeriod_SheetLevel]) {
                    DLog(@"sheet");
                    sheetlevel = [[permission objectForKey:ReportPeriod_SheetLevel] intValue];
                }
                if ([permission objectForKey:TimesheetEntry_CellLevel]) {
                    DLog(@"cell");
                    celllevel = [[permission objectForKey:TimesheetEntry_CellLevel] intValue];
                }
            }
        }
        NSArray *sheetArgsArray = [NSArray arrayWithObject:ReportPeriod_SheetLevel];
        NSArray *rowArgsArray   = [NSArray arrayWithObject:TaskTimesheet_RowLevel];
        NSArray *cellArgsArray  = [NSArray arrayWithObject:TimesheetEntry_CellLevel];
        
        NSArray *timeOffsArgsArray  = [NSArray arrayWithObject:TimeOffs_SheetLevel];//US4591//Juhi
        
        
        NSDictionary *dropDownOptionsRelationDict  = [NSDictionary dictionaryWithObject:
                                                      @"DropDownOptions" forKey:@"Relationship"];
        NSArray *fieldsLoadArray = [NSArray arrayWithObject:dropDownOptionsRelationDict];
        NSDictionary *fieldsRelationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                            @"Fields",@"Relationship",
                                            fieldsLoadArray,@"Load",
                                            nil
                                            ];
        NSArray *loadArray = [NSArray arrayWithObject:fieldsRelationDict];
        NSMutableDictionary *sheetLevelDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
                                              @"UdfGroupByName",@"QueryType",
                                              @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
                                              @"DomainType",
                                              sheetArgsArray,@"Args",
                                              loadArray,@"Load",
                                              nil];
        NSMutableDictionary *rowLevelDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
                                            @"UdfGroupByName",@"QueryType",
                                            @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
                                            @"DomainType",
                                            rowArgsArray,@"Args",
                                            loadArray,@"Load",
                                            nil];
        NSMutableDictionary *cellLevelDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
                                             @"UdfGroupByName",@"QueryType",
                                             @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
                                             @"DomainType",
                                             cellArgsArray,@"Args",
                                             loadArray,@"Load",
                                             nil];
        
        NSMutableDictionary *timeOffsLevelDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
                                                 @"UdfGroupByName",@"QueryType",
                                                 @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
                                                 @"DomainType",
                                                 timeOffsArgsArray,@"Args",
                                                 loadArray,@"Load",
                                                 nil];//US4591//Juhi
        
        
        
        
        if (sheetlevel) {
            //[query addObject:sheetLevelDict];
            [mergedRequestArr addObject:sheetLevelDict];
        }
        if (rowlevel) {
            //[query addObject:rowLevelDict];
            [mergedRequestArr addObject:rowLevelDict];
        }
        if (timeOffsLevelDict) {
            //[query addObject:timeOffsLevelDict];
             [mergedRequestArr addObject:timeOffsLevelDict];
        }
        
        
        if (celllevel) {
            //[query addObject:cellLevelDict];
            [mergedRequestArr addObject:cellLevelDict];
        }

       
		
        
        
        
	}
    
    if (timeOffSupportDataCanRun)
    {
        //        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:TIMEOffs_SUPPORT_DATA_CAN_RUN];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        //        [[RepliconServiceManager timesheetService] sendTimeSheetRequestToFetchTimeOffLevelUDFs];
        //		totalRequestsSent++;
    }

    
    NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:mergedRequestArr error:&err];
	DLog(@"TIME SHEET MERGED REQUEST QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"MergedTimesheetsAPI"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}

#pragma mark -
#pragma mark Response Handler's
/*
 * This method handles response for fetching timesheets
 * Calling class self - serverDidRespondWithResponse
 */
-(void)handleTimeSheetsResponse:(NSMutableArray *)entryTimesheetResponseArray
{
	//DLog(@"HANDLING TIMESHEET RESPONE %@",response);
		  
		
		if(entryTimesheetResponseArray != nil) {
			
			//delete all timesheets which are not modified offline.
			[timesheetModel deleteUnmModifiedTimesheets];
			
			[[NSUserDefaults standardUserDefaults]setObject:[entryTimesheetResponseArray objectAtIndex:0] forKey:@"TimeSheetQueryHandler"];
			//DLog(@"Query Handler value %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"TimeSheetQueryHandler"]);
			[entryTimesheetResponseArray removeObjectAtIndex:0];
			[[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithUnsignedInteger:[entryTimesheetResponseArray count]] forKey:@"NumberOfTimeSheets"];
            [[NSUserDefaults standardUserDefaults] synchronize];
			[timesheetModel saveTimesheetsFromApiToDB:entryTimesheetResponseArray];
			//set the start index for next fetch
			NSNumber  *nextFetchStartIndex = [NSNumber numberWithUnsignedInteger:[entryTimesheetResponseArray count] -1];
			[[NSUserDefaults standardUserDefaults] setObject:nextFetchStartIndex forKey:TIMESHEET_FETCH_START_INDEX];
            [[NSUserDefaults standardUserDefaults] synchronize];
			//fetch TimeOffBokkings for sheets

            
            NSMutableArray  *sheetIdsArray=[timesheetModel getAllSheetIdentitiesFromDB];
            
            if ([sheetIdsArray count]>0)
            {
                float sheetTotalHrsDecimal=[timesheetModel getTotalBookedTimeOffHoursForSheetIdsFromTimeSheets:sheetIdsArray];
                float entriesTotalHrsDecimal=[timesheetModel getTotalBookedTimeOffHoursForSheetIdsFromTimeEntries:sheetIdsArray];
                if (sheetTotalHrsDecimal!=entriesTotalHrsDecimal)
                {
                     [self performSelector:@selector(sendRequestToFetchBookedTimeOffForUser) withObject:nil];
                }
            }
            
          

		}
        else
        {
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"NumberOfTimeSheets"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
		
	

}

-(void)handleTimesheetMergedResponseWithObject:(NSArray *)responseArray
{
    NSMutableArray *entryTimesheetByUserResponseArr=[NSMutableArray array];
    NSMutableArray *activitiesResponseArr=[NSMutableArray array];
     NSMutableArray *udfsResponseArr=[NSMutableArray array];
    
    for (int i=0; i<[responseArray count]; i++)
    {
        NSDictionary *responseDict=[responseArray objectAtIndex:i];
        NSString *responseType=[responseDict objectForKey:@"Type"];
        
        if ([responseType isEqualToString:@"Replicon.Suite.Domain.EntryTimesheet"] || [responseType isEqualToString:@"QueryHandle"])
        {
            [entryTimesheetByUserResponseArr addObject:responseDict];
        }
        else if ([responseType isEqualToString:@"Replicon.Domain.User"])
        {
            [activitiesResponseArr addObject:responseDict];
        }
        else if ([responseType isEqualToString:@"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup"])
        {
            [udfsResponseArr addObject:responseDict];
        }
               
    }
    
    if([udfsResponseArr count]>0)
    {
        [self performSelector:@selector(handlePermissionBasedTimesheetUDFsResponse:) withObject:udfsResponseArr];
    }
    
    NSMutableArray *dbTimeSheets = [timesheetModel getTimesheetsFromDB];
    if(dbTimeSheets != nil && [dbTimeSheets count] > 0)
       
    {
        
        
        [self performSelector:@selector(handleModifiedTimesheetsResponse:) withObject:entryTimesheetByUserResponseArr];
      
    }
    
  
    
	else
    {
               
        [self performSelector:@selector(handleTimeSheetsResponse:) withObject:entryTimesheetByUserResponseArr];
        // [[NSNotificationCenter defaultCenter] postNotificationName:@"allRequestsServed" object:nil];
        
//        [standardUserDefaults removeObjectForKey:TIMESHEET_DATA_CAN_RUN];
//        [standardUserDefaults synchronize];
        
    }
   
    if([activitiesResponseArr count]>0)
    {
        [self performSelector:@selector(handleUserActivitiesResponse:) withObject:activitiesResponseArr];
    }
    
        
   
    
}

-(void)handleNextRecentFetchTimeSheets:(id)response{
	if (response != nil) {
		//DLog(@"handleNextRecentFetchTimeSheets:::RESPONSE %@",response);
		NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		if (status!=nil && [status isEqualToString:@"OK"]) {		  
			NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
			if (valueArray!= nil && [valueArray count]>0) {
				[timesheetModel saveTimesheetsFromApiToDB:valueArray];
				
				[[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithUnsignedInteger:[valueArray count]] forKey:@"NumberOfTimeSheets"];
                [[NSUserDefaults standardUserDefaults] synchronize];
				int lastSheetIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:TIMESHEET_FETCH_START_INDEX]
									  intValue];
				NSNumber  *nextFetchStartIndex = [NSNumber numberWithUnsignedInteger:lastSheetIndex +[valueArray count]];
				[[NSUserDefaults standardUserDefaults] setObject:nextFetchStartIndex forKey:TIMESHEET_FETCH_START_INDEX];
                [[NSUserDefaults standardUserDefaults] synchronize];
			}
            
            NSMutableArray  *sheetIdsArray=[NSMutableArray array];
            
            for (int i = 0; i<[valueArray count]; i++)
            {
                
                NSDictionary *timesheetDict = [valueArray objectAtIndex:i];
                
                NSNumber *sheetIdentity = [timesheetDict objectForKey:@"Identity"];
                
                [sheetIdsArray addObject:sheetIdentity];
                
               
            }

            if ([sheetIdsArray count]>0)
            {
                float sheetTotalHrsDecimal=[timesheetModel getTotalBookedTimeOffHoursForSheetIdsFromTimeSheets:sheetIdsArray];
                float entriesTotalHrsDecimal=[timesheetModel getTotalBookedTimeOffHoursForSheetIdsFromTimeEntries:sheetIdsArray];
                if (sheetTotalHrsDecimal!=entriesTotalHrsDecimal)
                {
                     [self performSelector:@selector(sendRequestToFetchBookedTimeOffForUserForNextRecentTimesheets:) withObject:valueArray];
                }
            }
            
           
        
            
			//Added: Request to fetch booked time offs on "More" button Click
			/*[[RepliconServiceManager timesheetService]sendRequestToFetchBookedTimeOffForUser];*/
             
             [[NSNotificationCenter defaultCenter]postNotificationName:NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION object:nil];
             [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		}else {
			NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
			NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
			if (value!=nil) {
                //				[Util errorAlert:status errorMessage:value];
                [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
			}else {
                //				[Util errorAlert:status errorMessage:message];
                [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
			}
		}
	}
}


/*
 * This method handles response for fetching timesheet with entryDate.
 *
 */
-(void)handleGetTimesheetFromApiResponse:(id)response {
	
	//DLog(@"HANDLING GET TIMESHEET RESPONE %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
			NSString *sheetIdentity = [[valueArray objectAtIndex:0] objectForKey:@"Identity"];
            RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
            if (appDelegate.isLockedTimeSheet ) 
            {
                if (appDelegate.selectedTab>0) {
                    [timesheetModel saveTimesheetsFromApiToDB:valueArray];
                }
                
            }
            else
            {
                [timesheetModel saveTimesheetsFromApiToDB:valueArray];
            }


			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:FETCH_TIMESHEET_FOR_ENTRY_DATE object:sheetIdentity];
		}
		
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}

-(void)handleGetTimeOffFromApiResponse:(id)response {
	
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
			NSString *sheetIdentity = [[valueArray objectAtIndex:0] objectForKey:@"Identity"];
          
            
            [timesheetModel saveTimesheetsFromApiToDB:valueArray];
            
            
            
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:FETCH_TIMEOFF_FOR_ENTRY_DATE object:sheetIdentity];
		}
		
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}
-(void)handlePunchClockGetTimesheetFromApiResponse:(id)response {
	
	//DLog(@"HANDLING GET TIMESHEET RESPONE %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
			[timesheetModel saveTimesheetsFromApiToDBForPunchClock:valueArray];
			[[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_PUNCH_DETAILS object:nil];
		}
		
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}



-(void)handleSubmitTimesheetResponse: (id)response {
	
	//DLog(@"HANDLING SUBMIT TIMESHEET RESPONE %@",response);
			  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
			NSDictionary *infoDict = [valueArray objectAtIndex:0];
			NSString *sheetIdentity = [infoDict objectForKey:@"Identity"];
            
            //Fix for DE3433//juhi
            NSMutableArray *unsubmittedSheets = [[NSUserDefaults standardUserDefaults] objectForKey:UNSUBMITTED_TIME_SHEETS];
			if (unsubmittedSheets == nil) {
				unsubmittedSheets = [NSMutableArray array];
			}
			else {
				unsubmittedSheets = [NSMutableArray arrayWithArray:unsubmittedSheets];
			}
            [unsubmittedSheets addObject:sheetIdentity];
			[[NSUserDefaults standardUserDefaults] setObject:unsubmittedSheets forKey:UNSUBMITTED_TIME_SHEETS];
            [[NSUserDefaults standardUserDefaults] synchronize];
			[self getTimesheetFromApiWithIdentity:sheetIdentity];
		}
		
	
}



-(void)handleGetTimesheetWithIdentityResponse:(id)response {
	//DLog(@"HANDLING GET TIMESHEET WITH IDENTITY RESPONSE %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
 	    if (isNewTimeOffPopUp)
            {
                if ([[NSUserDefaults standardUserDefaults]objectForKey:TIMESHEET_DATA_CAN_RUN]) {
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:TIMESHEET_DATA_CAN_RUN];
                }
            }
			NSDictionary *timesheetDict = [valueArray objectAtIndex:0];
			[timesheetModel updateTimesheetApprovalStatusFromAPIToDB: timesheetDict];
			[[NSNotificationCenter defaultCenter]postNotificationName:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
		}
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}


-(void)handleUnsubmitTimesheetResponse: (id)response {
	
	//DLog(@"HANDLING UNSUBMIT TIMESHEET RESPONE %@",response);
			  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
   if (isNewTimeOffPopUp)
            {
                if ([[NSUserDefaults standardUserDefaults]objectForKey:TIMESHEET_DATA_CAN_RUN]) {
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:TIMESHEET_DATA_CAN_RUN];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
            }
			NSDictionary *infoDict = [valueArray objectAtIndex:0];
			NSString *sheetIdentity = [infoDict objectForKey:@"Identity"];
			NSMutableArray *unsubmittedSheets = [[NSUserDefaults standardUserDefaults] objectForKey:UNSUBMITTED_TIME_SHEETS];
			if (unsubmittedSheets == nil) {
				unsubmittedSheets = [NSMutableArray array];
			}
			else {
				unsubmittedSheets = [NSMutableArray arrayWithArray:unsubmittedSheets];
			}
            
			[unsubmittedSheets addObject:sheetIdentity];
			[[NSUserDefaults standardUserDefaults] setObject:unsubmittedSheets forKey:UNSUBMITTED_TIME_SHEETS];
            [[NSUserDefaults standardUserDefaults] synchronize];
 			[self getTimesheetFromApiWithIdentity:sheetIdentity];
		}
		
	
}

//US4660//Juhi
-(void)handleReopenTimesheetResponse: (id)response {
	
	//DLog(@"HANDLING REOPEN TIMESHEET RESPONE %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
            if (isNewTimeOffPopUp)
            {
                if ([[NSUserDefaults standardUserDefaults]objectForKey:TIMESHEET_DATA_CAN_RUN]) {
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:TIMESHEET_DATA_CAN_RUN];
                     [[NSUserDefaults standardUserDefaults]synchronize];
                }
            }
			NSDictionary *infoDict = [valueArray objectAtIndex:0];
			NSString *sheetIdentity = [infoDict objectForKey:@"Identity"];
			NSMutableArray *unsubmittedSheets = [[NSUserDefaults standardUserDefaults] objectForKey:UNSUBMITTED_TIME_SHEETS];
			if (unsubmittedSheets == nil) {
				unsubmittedSheets = [NSMutableArray array];
			}
			else {
				unsubmittedSheets = [NSMutableArray arrayWithArray:unsubmittedSheets];
			}
            
			[unsubmittedSheets addObject:sheetIdentity];
			[[NSUserDefaults standardUserDefaults] setObject:unsubmittedSheets forKey:UNSUBMITTED_TIME_SHEETS];
            [[NSUserDefaults standardUserDefaults] synchronize];
 			[self getTimesheetFromApiWithIdentity:sheetIdentity];
		}
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
        if ([[NSUserDefaults standardUserDefaults]objectForKey:TIMESHEET_DATA_CAN_RUN]) {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:TIMESHEET_DATA_CAN_RUN];
             [[NSUserDefaults standardUserDefaults]synchronize];
        }
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}


-(void)handleUpdateDisclaimerAcceptanceTimesheetResponse: (id)response {
	
	//DLog(@"HANDLING UNSUBMIT TIMESHEET RESPONE %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
			NSDictionary *infoDict = [valueArray objectAtIndex:0];
			NSString *sheetIdentity = [infoDict objectForKey:@"Identity"];
 			[self getTimesheetFromApiWithIdentity:sheetIdentity];
		}
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}



-(void)handleApprovalHistoryresponseForSheet: (id)response {
	//DLog(@"HANDLING TIMESHEET APPROVAL HISTORY RESPONSE %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
			NSMutableArray *approvalArray = [self parseApprovalHistoryResponse:valueArray];
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:APPROVAL_HISTORY_NOTIFICATION object:approvalArray];
		}
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}


-(void)handleProjectTasksResponse:(id)response :(NSString *)projectIdentity {
	//DLog(@"handleProjectTasksResponse::::TimeSheetService %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
			[supportDataModel saveTasksForProjectWithProjectIdentity: projectIdentity : valueArray];
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:TASKS_RECEIVED_NOTIFICATION object:nil];
		}
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}

-(void)handleProjectSubTasksResponse:(id)response :(NSString *)projectIdentity :(NSString *)parentTaskIdentity {
	
	//DLog(@"handleProjectSubTasksResponse %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
			[supportDataModel saveSubTasksForProjectWithParentTask: projectIdentity :parentTaskIdentity : valueArray];
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:SUB_TASKS_RECEIVED_NOTIFICATION object:nil];
		}
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}
-(void)handleEditedTimeEntryResponse:(id)response{
	DLog(@"handleEditedTimeEntryResponse :::TimeSheetService");
	//DLog(@"Time Entry Edited Response %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        if (appDelegate.isLockedTimeSheet ) 
        {
            if (appDelegate.selectedTab>0) {
               [[NSNotificationCenter defaultCenter] postNotificationName:TIME_ENTRY_EDITED_NOTIFICATION object:nil];  
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:LOCKED_TIME_ENTRY_EDITED_NOTIFICATION object:nil]; 
            }
            
        }
        else
        {
           [[NSNotificationCenter defaultCenter] postNotificationName:TIME_ENTRY_EDITED_NOTIFICATION object:nil]; 
        }
        

		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
	
}


-(void)handleEditedTimeOffEntryResponse:(id)response
{
	DLog(@"handleEditedTimeEntryResponse :::TimeSheetService");
	//DLog(@"Time Entry Edited Response %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {

    [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_ENTRY_EDITED_NOTIFICATION object:nil]; 
        
        
        
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
	
}

-(void)handleSaveNewTimeEntryResponse:(id)response {
	//DLog(@"handleSaveNewTimeEntryResponse :: %@",response);
	//DLog(@"handleProjectSubTasksResponse %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
            
            RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
            if (appDelegate.isLockedTimeSheet ) 
            {
                if (appDelegate.selectedTab>0) {
                   [[NSNotificationCenter defaultCenter] postNotificationName:TIME_ENTRY_SAVED_NOTIFICATION object:nil]; 
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOCKED_TIME_ENTRY_SAVED_NOTIFICATION object:nil]; 
                }
                
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:TIME_ENTRY_SAVED_NOTIFICATION object:nil]; 
            }

			
		}
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}

-(void)handleSaveNewTimeOffEntryResponse:(id)response {
	//DLog(@"handleSaveNewTimeEntryResponse :: %@",response);
	//DLog(@"handleProjectSubTasksResponse %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
            
           
          [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_ENTRY_SAVED_NOTIFICATION object:nil]; 
            
            
			
		}
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}


-(void)handleTimesheetByIdentityResponse:(id)response {
	//DLog(@"handleSaveNewTimeEntryResponse :: %@",response);
	//DLog(@"handleTimesheetByIdentityResponse:::: TimeSheetService %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
        
        
		if(valueArray != nil) {
            //DE6520//Juhi
            if (isNewTimeOffPopUp)
            {
                if ([[NSUserDefaults standardUserDefaults]objectForKey:TIMESHEET_DATA_CAN_RUN]) {
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:TIMESHEET_DATA_CAN_RUN];
                }
                isNewTimeOffPopUp=NO;
            }
			
            [timesheetModel saveTimesheetsFromApiToDB:valueArray];
			[[NSNotificationCenter defaultCenter] postNotificationName:FETCH_TIMESHEET_BY_IDENTITY object:nil]; 
		}
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}
//US4513 Ullas
-(void)handleNewInOutTimesheetResponse:(id)response 
{
    
    NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) 
    {
        
        NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
        if (valueArray!=nil) 
        {
            for (int i=0; i<[valueArray count]; i++) 
            {
                if (i==0) 
                {
                    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                    if (appDelegate.isLockedTimeSheet ) 
                    {
                        if (appDelegate.selectedTab>0) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:TIME_ENTRY_EDITED_NOTIFICATION object:nil]; 
                        }
                        else
                        {
                            [[NSNotificationCenter defaultCenter] postNotificationName:LOCKED_TIME_ENTRY_EDITED_NOTIFICATION object:nil]; 
                        }
                        
                    }
                    else
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:TIME_ENTRY_EDITED_NOTIFICATION object:nil]; 
                    }

                }
                else
                {
                    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                    if (appDelegate.isLockedTimeSheet ) 
                    {
                        if (appDelegate.selectedTab>0) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:TIME_ENTRY_EDITED_NOTIFICATION object:nil];  
                        }
                        else
                        {
                            [[NSNotificationCenter defaultCenter] postNotificationName:LOCKED_TIME_ENTRY_EDITED_NOTIFICATION object:nil]; 
                        }
                        
                    }
                    else
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:TIME_ENTRY_EDITED_NOTIFICATION object:nil]; 
                    }
  
                }
            }
        }
    }
    else
    {
        NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
        
		if (value!=nil) 
            [G2Util errorAlert:@"" errorMessage:value];
		else 
            [G2Util errorAlert:@"" errorMessage:message];
		
    }
    
}
-(void)handleTimesheetByIdentityResponseForUpdatedAcceptanceDisclaimer:(id)response {
		NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
			NSDictionary *timesheetDict = [valueArray objectAtIndex:0];
			[timesheetModel updateTimesheetDisclaimerStatusFromAPIToDB: timesheetDict];
			[[NSNotificationCenter defaultCenter]postNotificationName:TIMESHEET_DISCLAIMER_UPDATED_SUCCESS_NOTIFICATION object:nil];
		}
		
	}else {
        
        
        
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
         RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        if (appDelegate.isUpdatingDisclaimerAcceptanceDate)
        {
            
            NSArray   *viewCtrls = appDelegate.navController.viewControllers;
            for (int i=0; i<[viewCtrls count]; i++) {
                if ([[viewCtrls objectAtIndex:i] isKindOfClass:[G2RootTabBarController class]]) {
                    G2RootTabBarController *rootCtrl=(G2RootTabBarController *)[viewCtrls objectAtIndex:i];
                    NSArray *rootVCArray=[rootCtrl viewControllers ];
                    for (int j=0; j<[rootVCArray count]; j++) 
                    {
                        if ([[rootVCArray objectAtIndex:j] isKindOfClass:[G2TimesheetNavigationController class]]) 
                        {
                            
                            NSArray *navigationVCArray=[[rootVCArray objectAtIndex:j] viewControllers];
                            for (int k=0; k<[navigationVCArray count]; k++) 
                            {
                                if ([[navigationVCArray objectAtIndex:k] isKindOfClass:[G2ListOfTimeEntriesViewController class]]) 
                                {
                                    G2ListOfTimeEntriesViewController *listOfTimeEntriesCtrl=(G2ListOfTimeEntriesViewController *)[navigationVCArray objectAtIndex:k];
                                    [listOfTimeEntriesCtrl revertRadioButton];
                                    [listOfTimeEntriesCtrl disclaimerRequestServer];
                                    break;
                                }
                            }
                            
                            break;
                        }
                        
                        
                    }
                    break;
                }
            }
        }
	}
}


-(void)handleSyncOfflineCreatedEntriesResponse :(id)response {
#ifdef DEV_DEBUG
	DLog(@"handleSaveOfflineTimeEntryResponse :: %@",response);
#endif
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
			
			NSDictionary *sheetDict = [valueArray objectAtIndex:0];
			if (sheetDict != nil && [sheetDict isKindOfClass:[NSDictionary class]]) {
				NSString *sheetId = [sheetDict objectForKey:@"Identity"];
				[timesheetModel removeOfflineCreatedEntries:sheetId];
				[self sendRequestToFetchTimesheetByIdWithEntries:sheetId];
			}
		}
	}
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:FETCH_TIMESHEET_BY_IDENTITY object:nil]; 
	}
	
}
-(void)handleSyncOfflineEditedEntriesResponse :(id)response {
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
			NSDictionary *sheetDict = [valueArray objectAtIndex:0];
			if (sheetDict != nil && [sheetDict isKindOfClass:[NSDictionary class]]) {
				NSString *sheetId = [sheetDict objectForKey:@"Identity"];
				[timesheetModel updateSheetModifyStatus:sheetId status:NO];
				[timesheetModel resetEntriesModifyStatus:sheetId];
			}
		}
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:EDITED_TIMEENTRY_SYNCED_NOTIFICATION object:nil];
}
/*Added: July13th
 *Method: handles Booked Time Off fetch
 *
 */
-(void)handleBookedTimeOffResponse:(id)response{
#ifdef DEV_DEBUG
	DLog(@"\nSheet Id %@",_sheetId);
	DLog(@"\n\nResponse %@",response);
#endif
	
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status != nil && [status isEqualToString:@"OK"]) {
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		//if (valueArray != nil) {
        //DE4275
        if (valueArray != nil) {
			[timesheetModel saveBookedTimeOffEntriesIntoDB:valueArray];
            if (totalRequestsServed==totalRequestsSent) {
                [[NSNotificationCenter defaultCenter]postNotificationName:NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION object:[NSDictionary dictionary]];//Added by Dipta for loading screen stays on more action
            }
            
		}else{
            [[NSNotificationCenter defaultCenter]postNotificationName:NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION object:[NSDictionary dictionary]];//DE3418
            
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:BOOKED_TIME_OFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
        }
    }else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}
-(void)handleUserActivitiesResponse:(NSMutableArray *)activitiesArray
{
	
		NSDictionary *userDict = [activitiesArray objectAtIndex:0];
		NSArray *activityArray = [[userDict objectForKey:@"Relationships"] objectForKey:@"Activities"];
		        
		[supportDataModel saveUserActivitiesFromApiToDB:activityArray];
		
	
    
}

-(void)handleTimesheetUDFSettingsResponse : (id)response {
	
	NSString *responseStatus = [[response objectForKey:@"response"] objectForKey:@"Status"];
	
	if(responseStatus != nil && [responseStatus isEqualToString:@"OK"]) {
		NSArray *valueArray = [[response objectForKey:@"response"] objectForKey:@"Value"];
		if (valueArray != nil) {
			//[supportDataModel saveTimesheetUDFSettingsFromApiToDB:valueArray];
		}
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:responseStatus errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:responseStatus errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
	
}

-(void)handleProjectsAndClientsResponse: (id)response {
	//DLog(@"handleProjectsAndClientsResponse::: %@",response);
	NSString *responseStatus = [[response objectForKey:@"response"] objectForKey:@"Status"];
	if([responseStatus isEqualToString:@"OK"]) {
		NSArray *projectsArray = [[response objectForKey:@"response"] objectForKey:@"Value"];
		[supportDataModel saveUserProjectsAndClientsFromApiToDB:projectsArray];
		//TODO: Save Billing Options for the project:DONE
		NSArray *billingOptionsArray;
		for (int i=0; i<[projectsArray count]; i++) {
			billingOptionsArray=[[[projectsArray objectAtIndex:i] objectForKey:@"Relationships"] 
								 objectForKey:@"UserBillingOptions"];
			NSString *projectIdentity = [[projectsArray objectAtIndex:i] objectForKey:@"Identity"]; 
			for (int j=0; j<[billingOptionsArray count]; j++) {
				[supportDataModel saveProjectBillingOptionsFromApiToDB:
				 [billingOptionsArray objectAtIndex:j] :projectIdentity];
			}
		}
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:responseStatus errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:responseStatus errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}

-(void)handleClientsResponse: (id)response
{
    NSString *responseStatus = [[response objectForKey:@"response"] objectForKey:@"Status"];
	if([responseStatus isEqualToString:@"OK"])
    {
		NSArray *clientsArray = [[response objectForKey:@"response"] objectForKey:@"Value"];
        for (int i=0; i<[clientsArray count]; i++)
        {
            NSDictionary *clientDict=[clientsArray objectAtIndex:i];
           [supportDataModel insertClientFromApiToDB:clientDict];
            
        }
    }
    else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
           
            [G2Util errorAlert:@"" errorMessage:value];
		}else {
            
            [G2Util errorAlert:@"" errorMessage:message];
		}
	}
}

-(void)handleProjectsResponse: (id)response
{
    NSString *responseStatus = [[response objectForKey:@"response"] objectForKey:@"Status"];
	if([responseStatus isEqualToString:@"OK"])
    {
		NSMutableArray *projectsArray = [[response objectForKey:@"response"] objectForKey:@"Value"];
        
       
        if (projectsArray!=nil && [projectsArray count]!=0)
        {
            NSDictionary *responseDict=[projectsArray objectAtIndex:0];
            
            NSString *queryhandler=[NSString stringWithFormat:@"%@",[responseDict objectForKey:@"Identity"] ];
            
            NSString *clientID=nil;
            NSString *startIndex=nil;
            if (queryhandler!=nil)
            {
                [projectsArray removeObjectAtIndex:0];
                
                clientID=[NSString stringWithFormat:@"%@",[[[response objectForKey:@"refDict"]objectForKey:@"params"]objectForKey:@"ClientID"]];
                startIndex=[NSString stringWithFormat:@"%@",[[[response objectForKey:@"refDict"]objectForKey:@"params"]objectForKey:@"startIndex"]];
                
            }
            
            if (projectsArray!=nil && [projectsArray count]!=0)
            {
                [supportDataModel insertProjectsFromApiToDB:projectsArray forRecent:FALSE];
                [timesheetModel updateQueryHandleByClientId:clientID andQueryHandle:queryhandler andStartIndex:[NSString stringWithFormat:@"%lu",(unsigned long)[startIndex intValue]+[projectsArray count]]];
                
                if ([projectsArray count]<[[[G2AppProperties getInstance]getAppPropertyFor:@"PaginatedProjectsClients"]intValue])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEETSPROJECTS_FINSIHED_DOWNLOADING object:[NSNumber numberWithBool:TRUE]];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEETSPROJECTS_FINSIHED_DOWNLOADING object:[NSNumber numberWithBool:FALSE]];
                }
            }
            
            else
            {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEETSPROJECTS_FINSIHED_DOWNLOADING object:[NSNumber numberWithBool:TRUE]];
                
            }
        }
        
        
    }
    else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            
            [G2Util errorAlert:@"" errorMessage:value];
		}else {
            
            [G2Util errorAlert:@"" errorMessage:message];
		}
	}
}

-(void)handleRecentTimeSheetsProjectsResponse: (id)response
{
    NSString *responseStatus = [[response objectForKey:@"response"] objectForKey:@"Status"];
	if([responseStatus isEqualToString:@"OK"])
    {
		NSMutableArray *projectsArray = [[response objectForKey:@"response"] objectForKey:@"Value"];
        
        
        if (projectsArray!=nil && [projectsArray count]!=0)
        {
            [supportDataModel insertProjectsFromApiToDB:projectsArray forRecent:TRUE];
        }
        
        
    }
    else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            
            [G2Util errorAlert:@"" errorMessage:value];
		}else {
            
            [G2Util errorAlert:@"" errorMessage:message];
		}
	}
}

-(void)handleTimeSheetsUserBillingResponse: (id)response
{
    NSString *responseStatus = [[response objectForKey:@"response"] objectForKey:@"Status"];
	if([responseStatus isEqualToString:@"OK"]) {
		NSArray *projectsArray = [[response objectForKey:@"response"] objectForKey:@"Value"];
		
		//TODO: Save Billing Options for the project:DONE
		NSArray *billingOptionsArray;
		for (int i=0; i<[projectsArray count]; i++) {
			billingOptionsArray=[[[projectsArray objectAtIndex:i] objectForKey:@"Relationships"]
								 objectForKey:@"UserBillingOptions"];
			NSString *projectIdentity = [[projectsArray objectAtIndex:i] objectForKey:@"Identity"];
			for (int j=0; j<[billingOptionsArray count]; j++) {
				[supportDataModel saveProjectBillingOptionsFromApiToDB:
				 [billingOptionsArray objectAtIndex:j] :projectIdentity];
			}
		}
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:responseStatus errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:responseStatus errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}


-(void)handleDeleteTimeEntryResponse:(id)response :(id)otherParamsDict{
	
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status != nil && [status isEqualToString:@"OK"]) {
		if (otherParamsDict != nil) {
			NSString *entryIdentity = [otherParamsDict objectForKey:@"entryIdentity"];
			NSString *sheetIdentity = [otherParamsDict objectForKey:@"sheetIdentity"];
			[timesheetModel deleteTimeEntryWithIdentityForSheet: entryIdentity sheetId:sheetIdentity]; 
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:TIME_ENTRY_DELETE_NOTIFICATION object:nil];
		}
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}

-(void)handleDeleteTimeOffEntryResponse:(id)response :(id)otherParamsDict{
	
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status != nil && [status isEqualToString:@"OK"]) {
		if (otherParamsDict != nil) {
			NSString *entryIdentity = [otherParamsDict objectForKey:@"entryIdentity"];
			NSString *sheetIdentity = [otherParamsDict objectForKey:@"sheetIdentity"];
			[timesheetModel deleteTimeOffEntryWithIdentityForSheet: entryIdentity sheetId:sheetIdentity]; 
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:TIMEOFF_ENTRY_DELETE_NOTIFICATION object:nil];
		}
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
}

-(void)handleModifiedTimesheetsResponse:(NSMutableArray *)modifiedEntryTimesheetResponseArr {
	
	[self sendRequestToFetchSheetsExistanceInfo];
	totalRequestsSent++;
	
	//DLog(@"handleModifiedTimesheetsResponse:::TimesheetService %@",response);
	  
		
		if(modifiedEntryTimesheetResponseArr != nil && [modifiedEntryTimesheetResponseArr count] >0) {
			
			[timesheetModel saveTimesheetsFromApiToDB:modifiedEntryTimesheetResponseArr];
			
		}

    
    NSMutableArray  *sheetIdsArray=[timesheetModel getAllSheetIdentitiesFromDB];
    
    if ([sheetIdsArray count]>0)
    {
        float sheetTotalHrsDecimal=[timesheetModel getTotalBookedTimeOffHoursForSheetIdsFromTimeSheets:sheetIdsArray];
        float entriesTotalHrsDecimal=[timesheetModel getTotalBookedTimeOffHoursForSheetIdsFromTimeEntries:sheetIdsArray];
        if (sheetTotalHrsDecimal!=entriesTotalHrsDecimal)
        {
             [self performSelector:@selector(sendRequestToFetchBookedTimeOffForUser) withObject:nil];
        }
    }
    
    
       

}
-(void)handlePermissionBasedTimesheetUDFsResponse:(NSMutableArray *)udfsResponseArray{
	//DLog(@"Response:::handlePermissionBasedTimesheetUDFsResponse %@",response);
   
		if (udfsResponseArray != nil) {
			[timesheetModel savePermissionBasedTimesheetUDFsToDB:udfsResponseArray];
			
		}
	

}
-(void)handleExistedTimesheetsResponse:(id)response
{
	//DLog(@"Time sheet S RESPONSE %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil && [valueArray count] >0) {
			
			[timesheetModel removeWtsDeletedSheetsFromDB:valueArray];
		}
		
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            //			[Util errorAlert:status errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
	
}

#pragma mark general methods

-(NSMutableArray *)parseApprovalHistoryResponse:(NSArray *)valueArray {
	
	NSMutableArray *approvalArray=[NSMutableArray array];
	NSString *status=nil;
	for (int i=0; i<[valueArray count]; i++) {
		
		NSMutableDictionary *sheetInfoDict=[NSMutableDictionary dictionary];
		NSDictionary *sheetDict = [valueArray objectAtIndex:i];
		if (sheetDict != nil && ![sheetDict isKindOfClass:[NSNull class]]) {
			NSDictionary *approvalStatusDict = [[sheetDict objectForKey:@"Relationships"] 
												objectForKey:@"ApprovalStatus"];
			status = [[approvalStatusDict objectForKey:@"Properties"]objectForKey:@"Name"];
			if ([status isEqualToString:@"Open"]){
				status=NOT_SUBMITTED_STATUS;
			}
			[sheetInfoDict setObject:status forKey:@"status"];
			
			[approvalArray addObject:sheetInfoDict];
			
			NSString *approverIdentity=nil;
			NSArray *historyArray = [[sheetDict objectForKey:@"Relationships"]objectForKey:@"History"];
			if (historyArray != nil && ![historyArray isKindOfClass:[NSNull class]]) {
				for (int j=0; j<[historyArray count]; j++) {
					
					NSMutableDictionary *approvalsDictionary=[NSMutableDictionary dictionary];
					NSString *effectiveDate=nil;
					int month=0;
					NSDictionary *historyDictionary = [historyArray objectAtIndex:j];
					NSDictionary *historyPropertiesDict = [historyDictionary objectForKey:@"Properties"];
					NSDictionary *effectiveDateDict= [historyPropertiesDict objectForKey:@"EffectiveDate"];
					if(effectiveDateDict != nil && [effectiveDateDict isKindOfClass:[NSDictionary class]]){
						month = [[effectiveDateDict objectForKey:@"Month"]intValue];
						if ([[effectiveDateDict objectForKey:@"Hour"] intValue]>12) {
							
							effectiveDate =[NSString stringWithFormat:@"%@ %@, %@   %@:%@:%@  %@",[G2Util getMonthNameForMonthId:month],[effectiveDateDict objectForKey:@"Day"]
											,[effectiveDateDict objectForKey:@"Year"],[effectiveDateDict objectForKey:@"Hour"],[effectiveDateDict objectForKey:@"Minute"],
											[effectiveDateDict objectForKey:@"Second"],@"PM"];
						}else {
							effectiveDate =[NSString stringWithFormat:@"%@ %@, %@   %@:%@:%@  %@",[G2Util getMonthNameForMonthId:month],[effectiveDateDict objectForKey:@"Day"]
											,[effectiveDateDict objectForKey:@"Year"],[effectiveDateDict objectForKey:@"Hour"],[effectiveDateDict objectForKey:@"Minute"],
											[effectiveDateDict objectForKey:@"Second"],@"AM"];
						}
						
						[approvalsDictionary setObject:effectiveDate forKey:@"effectiveDate"];
					}else if([effectiveDateDict isKindOfClass:[NSNull class]]){
						[approvalsDictionary setObject:@"" forKey:@"effectiveDate"];
					}					
					
					NSString* comments=nil;
					comments=[historyPropertiesDict objectForKey:@"ApprovalComments"];
					
					if([comments isKindOfClass:[NSString class]]){
						[approvalsDictionary setObject:comments forKey:@"comments"];
					}else if([comments isKindOfClass:[NSNull class]]) {
						comments=@"";
						[approvalsDictionary setObject:comments forKey:@"comments"];
					}
					
					NSString *approverLoginName=nil;
					NSString *firstName=nil;
					NSString *lastName=nil;
					id approver = [[historyDictionary objectForKey:@"Relationships"]objectForKey:@"Approver"];
					if([approver isKindOfClass:[NSDictionary class]]){
						NSDictionary  *approverDict = (NSDictionary *)approver;
						approverIdentity=[approverDict objectForKey:@"Identity"];
						
						[approvalsDictionary setObject:approverIdentity forKey:@"identity"];
						
						approverLoginName=[[approverDict objectForKey:@"Properties"] objectForKey:@"LoginName"];	
						[approvalsDictionary setObject:approverLoginName forKey:@"loginName"];
						
						firstName=[[approverDict objectForKey:@"Properties"] objectForKey:@"FirstName"];
						[approvalsDictionary setObject:firstName forKey:@"firstName"];
						
						lastName=[[approverDict objectForKey:@"Properties"] objectForKey:@"LastName"];
						[approvalsDictionary setObject:lastName forKey:@"lastName"];
					}else if([approver isKindOfClass:[NSNull class]]) {
						DLog(@"APPROVER NULL");
						approverIdentity=@"";
						approverLoginName=@"";
						firstName=@"";
						lastName=@"";
						[approvalsDictionary setObject:approverIdentity forKey:@"identity"];
						[approvalsDictionary setObject:approverLoginName forKey:@"loginName"];
						[approvalsDictionary setObject:firstName forKey:@"firstName"];
						[approvalsDictionary setObject:lastName forKey:@"lastName"];
					}
					
					NSString *approverActionName =nil;
					id approvalAction = [[historyDictionary objectForKey:@"Relationships"]objectForKey:@"Type"];
					if([approvalAction isKindOfClass:[NSDictionary class]]){
						NSDictionary *approvalActionDict = (NSDictionary *)approvalAction;
						approverActionName=[[approvalActionDict objectForKey:@"Properties"]objectForKey:@"Name"];
						[approvalsDictionary setObject:approverActionName forKey:@"approverAction"];
					}else if([approvalAction isKindOfClass:[NSNull class]]){
						approverActionName=@"";
						[approvalsDictionary setObject:approverActionName forKey:@"approverAction"];
					}
					
					[approvalArray addObject:approvalsDictionary];
				}
			}
		}
	}
	//DLog(@"insertApprovalsDetailsIntoDbForUnsubmittedSheet %@",approvalArray);
	return approvalArray;
	
}

#pragma mark -
#pragma mark ServiceURL Response Handling

- (void) serverDidRespondWithResponse:(id) response
{
    NSNumber *serviceId=nil;
    BOOL isFromUpdateDisclaimerResponse=FALSE;
	if (response != nil) {
		serviceId=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
       
		if ([serviceId intValue] == EntryTimesheetByUser_38) {
			totalRequestsServed++;
			//[self handleTimeSheetsResponse:response];
		}
		else if ([serviceId intValue] == QueryAndCreateTimesheet_41) {
			[self handleGetTimesheetFromApiResponse : response];
		}
        else if ([serviceId intValue] == QueryAndCreateTimeOff_85) {
			[self handleGetTimeOffFromApiResponse : response];
		}
		else if ([serviceId intValue] == UserActivities_Service_Id_47) {//Request Name: UserActivities  Notification: USER_ACTIVITIES_TIME_OFF_CODES_RECEIVED_NOTIFICATION
			totalRequestsServed++;
			//[self handleUserActivitiesResponse:response];
		}
		else if ([serviceId intValue] == TimesheetUDFs_Service_id_51) {
			totalRequestsServed++;
			//[self handleTimesheetUDFSettingsResponse:response];//Request Name: TimeSheetUDFs Notification: N/A
            
            NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
            if (status!=nil && [status isEqualToString:@"OK"]) {
                 NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
                if(valueArray != nil) {
                    [self handlePermissionBasedTimesheetUDFsResponse:valueArray];
                }
               
                
            }
            else {
                NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
                NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
                if (value!=nil) {
                    [G2Util errorAlert:@"" errorMessage:value];
                }else {
                    [G2Util errorAlert:@"" errorMessage:message];
                }
            }

            
		}
		else if ([serviceId intValue] == SubmitTimesheet_Service_Id_43) {
            NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
            if (status!=nil && [status isEqualToString:@"OK"])
            {
                [self handleSubmitTimesheetResponse: response];
            }
            else
            {
                NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
                NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
                if (value!=nil)
                {
                    [G2Util errorAlert:@"" errorMessage:value];
                }
                else
                {
                    
                    [G2Util errorAlert:@"" errorMessage:message];
                }
                

            }
            return;
 		}
		else if ([serviceId intValue] == UnsubmitTimesheet_Service_Id_45) {
            NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
            if (status!=nil && [status isEqualToString:@"OK"])
            {
                [self handleUnsubmitTimesheetResponse: response];
            }
            else
            {
                NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
                NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
                if ([[NSUserDefaults standardUserDefaults]objectForKey:TIMESHEET_DATA_CAN_RUN]) {
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:TIMESHEET_DATA_CAN_RUN];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
                
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
                if (value!=nil)
                {
                    
                    [G2Util errorAlert:@"" errorMessage:value];
                }
                else
                {
                    
                    [G2Util errorAlert:@"" errorMessage:message];
                }
               
            }
            return;
 		}
		else if ([serviceId intValue] == GetTimesheetWithIdentity_Service_Id_44) {
			[self handleGetTimesheetWithIdentityResponse: response];
		} 
		else if ([serviceId intValue] == FetchNextRecentTimeSheets_46) {
			[self handleNextRecentFetchTimeSheets:response];
		}
		else if ([serviceId intValue] == TimesheetApprovalHistory_Service_id_49) {
			[self handleApprovalHistoryresponseForSheet:response];
		}
		else if ([serviceId intValue] ==TimesheetProjectTasks_Service_Id_52) {
			NSMutableDictionary *otherParamsDict = [[response objectForKey:@"refDict"]objectForKey:@"params"];
			NSString *projectIdentity = [otherParamsDict objectForKey:@"projectIdentity"];
			[self handleProjectTasksResponse:response :projectIdentity];
		}
		else if([serviceId intValue] ==TimesheetProjectSubTasks_Service_Id_53) {
			NSMutableDictionary *otherParamsDict = [[response objectForKey:@"refDict"]objectForKey:@"params"];
			NSString *projectIdentity = [otherParamsDict objectForKey:@"projectIdentity"];
			NSString *parentTaskIdentity = [otherParamsDict objectForKey:@"parentTaskIdentity"];
			[self handleProjectSubTasksResponse:response :projectIdentity :parentTaskIdentity];
		}
		else if ([serviceId intValue] == SaveTimeEntryForSheet_Service_Id_54) {
			[self handleSaveNewTimeEntryResponse:response];
		}
        else if ([serviceId intValue] == SaveTimeOffEntryForSheet_86) {
			[self handleSaveNewTimeOffEntryResponse:response];
		}
		else if ([serviceId intValue] == GetTimesheetForIdWithEntries_Service_Id_55) {
			[self handleTimesheetByIdentityResponse:response];
		}
		else if([serviceId intValue] ==EditTimeEntry_Service_Id_56) {
			//TODO: Handle the response after the time entry edit:DONE
			[self handleEditedTimeEntryResponse:response];
		}
        else if([serviceId intValue] ==EditTimeOffEntry_Service_Id_87) {
			//TODO: Handle the response after the time entry edit:DONE
			[self handleEditedTimeOffEntryResponse:response];
		}
		else if ([serviceId intValue] == SyncOfflineCreatedTimeEntries_Service_Id_57) {
			[self handleSyncOfflineCreatedEntriesResponse:response];
		}
		else if ([serviceId intValue] == SyncOfflineEditedTimeEntries_Service_Id_58) {
			[self handleSyncOfflineEditedEntriesResponse:response];
		}else if([serviceId intValue] == BookedTimeOff_Service_Id_61) {
            //totalRequestsServed++;
			[self handleBookedTimeOffResponse:response];
            return;
		}
		else if ([serviceId intValue] == UserProjectsAndClients_42) {
			totalRequestsServed++;
			[self handleProjectsAndClientsResponse:response];
		}
		else if ([serviceId intValue] == DeleteTimeEntry_Service_Id_62) {
			NSMutableDictionary *otherParamsDict = [[response objectForKey:@"refDict"]objectForKey:@"params"];
			[self handleDeleteTimeEntryResponse:response :otherParamsDict];
		}
        else if ([serviceId intValue] == DeleteTimeOffEntry_Service_Id_88) {
			NSMutableDictionary *otherParamsDict = [[response objectForKey:@"refDict"]objectForKey:@"params"];
			[self handleDeleteTimeOffEntryResponse:response :otherParamsDict];
		}
		else if ([serviceId intValue] == ModifiedTimesheets_Service_Id_63) {
         	totalRequestsServed++;
			//[self handleModifiedTimesheetsResponse:response];
		}else if ([serviceId intValue] == TimeSheetsExisted_Service_Id_65) {
           	totalRequestsServed++;
			[self handleExistedTimesheetsResponse:response];
		}

        else if ([serviceId intValue] == UpdateDisclaimerAcceptedDateForTimesheets_Service_Id_84) 
        {
           	isFromUpdateDisclaimerResponse=TRUE;
			[self handleTimesheetByIdentityResponseForUpdatedAcceptanceDisclaimer: response];
		}
        else if ([serviceId intValue] == EditTimesheetEntryForNewInOut_Service_Id_90)
        {
            [self handleNewInOutTimesheetResponse:response];//US4513 Ullas
        }
        

	 //US4660//Juhi
        else if ([serviceId intValue] == ReopenTimesheet_Service_Id_92)
        {
            [self handleReopenTimesheetResponse:response];
        }
        
        else if ([serviceId intValue] == FetchAllTimesheetClients_96)
        {
            [self handleClientsResponse:response];
             [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEETSCLIENTS_FINSIHED_DOWNLOADING object:nil];
            return;
        }
        
        else if ([serviceId intValue] == FetchAllTimesheetProjects_97)
        {
            [self handleProjectsResponse:response];
            [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEETSPROJECTS_FINSIHED_DOWNLOADING object:nil];
            return;
        }
        
        else if ([serviceId intValue] == FetchAllTimesheetUserBillingOptionsByProjectID_98)
        {
            [self handleTimeSheetsUserBillingResponse:response];
            [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEETS_USERBILLINGOPTIONS_FINSIHED_DOWNLOADING object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEETS_USERBILLINGOPTIONS_FINSIHED_DOWNLOADING_EDITING object:nil];
            return;
        }
        
        else if ([serviceId intValue] == FetchAllTimesheetProjectsByIds_99)
        {
            [self handleRecentTimeSheetsProjectsResponse:response];
            //[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
            return;
        }
        
        else if ([serviceId intValue] == MergedTimesheetsAPI_100)
        {
            totalRequestsServed++;
            NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
            if (status!=nil && [status isEqualToString:@"OK"])
            {
                NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
                
                [self handleTimesheetMergedResponseWithObject:valueArray];
                
            }
            else {
                NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
                NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
                                [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
                if (value!=nil) {
                    
                    [G2Util errorAlert:@"" errorMessage:value];
                }else {
                    
                    [G2Util errorAlert:@"" errorMessage:message];
                }
            }

            
          
        }
        
	}
	
	//added below condition to check if all requests are served
	DLog(@"TimeSheetService===> RequestsServed / Sent: %d / %d", totalRequestsServed, totalRequestsSent);
	if (totalRequestsServed == totalRequestsSent && !isFromUpdateDisclaimerResponse) 
    {
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        if (appDelegate.isLockedTimeSheet ) 
        {
            if (appDelegate.selectedTab>0) {
                //DONT DO THIS FOR ADHOC TIME OFFS
                if ([serviceId intValue] != QueryAndCreateTimeOff_85 && [serviceId intValue] != SaveTimeOffEntryForSheet_86)
                {
                    [self updateTimesheetLastUpdateTime];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"allTimesheetRequestsServed" object:nil];
                }
                
            }
            else
            {
                  
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"allTimesheetRequestsServed" object:nil];
                        
                               
            }
           
        }
        else
        {
            //DONT DO THIS FOR ADHOC TIME OFFS
            if ([serviceId intValue] != QueryAndCreateTimeOff_85 && [serviceId intValue] != SaveTimeOffEntryForSheet_86 )
            {
                [self updateTimesheetLastUpdateTime];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"allTimesheetRequestsServed" object:nil];
            }
           
        }
		
		
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"allTimesheetRequestsServed" object:];
	}
}

- (void) serverDidFailWithError:(NSError *) error
{
	totalRequestsServed++;
    //Need to revisit
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];	
	if (totalRequestsServed == totalRequestsSent)	{
		if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
			[G2Util showOfflineAlert];
			return;
		}
        
        [self showErrorAlert:error];
		return;
	}
    [self showErrorAlert:error];
    
	if ([[NSUserDefaults standardUserDefaults]objectForKey:@"isTimesheetsDataFailed"]!=nil) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:TIMESHEET_DATA_CAN_RUN];
        [[NSUserDefaults standardUserDefaults] synchronize];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isTimesheetsDataFailed"];
	}else {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:TIMESHEET_SUPPORT_DATA_CAN_RUN];
        [[NSUserDefaults standardUserDefaults] synchronize];
	}
    //US1132 Issue 4:
    return;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==-9998)
    {
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchWebViewController)];
    }
}

-(void)showErrorAlert:(NSError *) error
{
    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (!appdelegate.isAlertOn) 
    {
        if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED]) {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
            {
                UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED)
                                                                          delegate:self cancelButtonTitle:RPLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
                [confirmAlertView setDelegate:self];
                [confirmAlertView setTag:-9998];
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
    //US1132 Issue 4:
    if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED] ||  [appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) 
    {
        appdelegate.isAlertOn=TRUE;
    }
    else
    {
        appdelegate.isAlertOn=FALSE;
    }
    
    
}



-(void) fetchTimeSheetData:(id)_delegate
{
    //ravi - Reset the total requests sent and received before sending the new requests
	totalRequestsServed = 0;
	totalRequestsSent = 0;
    totalRequestsSent++;
	[[G2RepliconServiceManager timesheetService]sendRequestForMergedTimesheetAPIWithDelegate:self];
    
    
}


-(void) updateTimesheetLastUpdateTime
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

	if ([standardUserDefaults objectForKey:TIMESHEET_DATA_CAN_RUN]!=nil && [[standardUserDefaults objectForKey:TIMESHEET_DATA_CAN_RUN] intValue]==1) {
		[G2SupportDataModel updateLastSyncDateForServiceId:TIMESHEET_DATA_SERVICE_SECTION];
        //THIS LINE IS COMMENTED FOR MODIFIED TIMESHEET TIMESTAMP WAS NOT GETTING UPDATED
		//[standardUserDefaults removeObjectForKey:TIMESHEET_DATA_CAN_RUN];
	}
    else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:TIMESHEET_DATA_CAN_RUN];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
	
	if ([standardUserDefaults objectForKey:TIMESHEET_SUPPORT_DATA_CAN_RUN]!=nil && [[standardUserDefaults objectForKey:TIMESHEET_SUPPORT_DATA_CAN_RUN] intValue]==1) {
		[G2SupportDataModel updateLastSyncDateForServiceId:TIMESHEET_SUPPORT_DATA_SERVICE_SECTION];
		[standardUserDefaults removeObjectForKey:TIMESHEET_SUPPORT_DATA_CAN_RUN];
	}	
    if ([standardUserDefaults objectForKey:TIMEOffs_SUPPORT_DATA_CAN_RUN]!=nil && [[standardUserDefaults objectForKey:TIMEOffs_SUPPORT_DATA_CAN_RUN] intValue]==1) {
		[G2SupportDataModel updateLastSyncDateForServiceId:TIMEOFF_SUPPORT_DATA_SERVICE_SECTION];
		[standardUserDefaults removeObjectForKey:TIMEOffs_SUPPORT_DATA_CAN_RUN];
	}
}


-(void)requestToFetchBookedTimeOff{
	
}
//US4591//Juhi
-(void)fetchTimeOffUDFs
{
    totalRequestsServed = 0;
	totalRequestsSent = 0;
//     BOOL timeOffSupportDataCanRun=[Util shallExecuteQuery:TIMEOFF_SUPPORT_DATA_SERVICE_SECTION];
//    if (timeOffSupportDataCanRun) {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:TIMESHEET_DATA_CAN_RUN]) {
         [[NSUserDefaults standardUserDefaults]removeObjectForKey:TIMESHEET_DATA_CAN_RUN];
    }
       
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:TIMEOffs_SUPPORT_DATA_CAN_RUN];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[G2RepliconServiceManager timesheetService]sendTimeSheetRequestToFetchTimeOffLevelUDFs];
        totalRequestsSent++;
//    }
        
}
-(void) fetchClientsAndProject{//FIX FOR DE3601
    totalRequestsServed = 0;
	totalRequestsSent = 0;
    //DE6752//Juhi
    NSMutableArray	*clientsArr= [supportDataModel getAllClientNames];
     if (([clientsArr  containsObject:NONE_STRING] && ([clientsArr count] == 1))||[clientsArr count]==0) 
     {
         [[G2RepliconServiceManager timesheetService] sendRequestToGetProjectsAndClients];
         totalRequestsSent++;
     }

    
}
//US4006 Ullas M L
-(BOOL)checkForPermissionExistence:(NSString *)_permission{
	NSMutableArray *permissionlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPermissionSet"];
	if (_permission != nil) {
		for (int i=0; i<[permissionlist count]; i++) {
			if ([permissionlist containsObject:_permission]) {
				return YES;
			}
		}
	}
	return NO;
}



@end
