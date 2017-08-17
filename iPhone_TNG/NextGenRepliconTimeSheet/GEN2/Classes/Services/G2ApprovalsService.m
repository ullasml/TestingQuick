//
//  ApprovalsService.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/23/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2ApprovalsService.h"
#import "G2RepliconServiceManager.h"
#import "RepliconAppDelegate.h"
#import "G2Constants.h"
@implementation G2ApprovalsService
@synthesize  totalRequestsSent;
@synthesize  totalRequestsServed;
@synthesize userIDArray;
@synthesize filterUsersForPermissions;
@synthesize filterUsersForPreferences;

- (id) init
{
	self = [super init];
	if (self != nil) {
		if(approvalsModel == nil) {
			approvalsModel = [[G2ApprovalsModel alloc] init];
		}
		if(userIDArray == nil) {
			NSMutableArray *tempuserIDArray=[[NSMutableArray alloc]init];
            self.userIDArray=tempuserIDArray;
            
		}
        if(filterUsersForPermissions == nil) {
			NSMutableArray *tempfilterUsersForPermissions=[[NSMutableArray alloc]init];
            self.filterUsersForPermissions=tempfilterUsersForPermissions;
           
		}
        if(filterUsersForPreferences == nil) {
			NSMutableArray *tempfilterUsersForPreferences=[[NSMutableArray alloc]init];
            self.filterUsersForPreferences=tempfilterUsersForPreferences;
            
		}
	}
	return self;
}


-(void)sendRequestToFetchAllPendingTimesheetsForApprovals
{

	

	NSString *userId=[[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
	NSMutableArray *argsArray=[NSMutableArray array];
	NSDictionary *argsDict=[NSDictionary dictionaryWithObjectsAndKeys:userId,@"Identity",@"Replicon.Domain.User",@"__type",nil];
	[argsArray addObject:argsDict];
//   	NSArray *enumArr = [NSArray arrayWithObjects:@"Open",nil];
//	NSDictionary *approveSortDict=[NSDictionary dictionaryWithObjectsAndKeys:@"ApprovalStatus",@"Property",
//								   enumArr,@"EnumOrder",		  
//								   [NSNumber numberWithBool:YES],@"Descending",nil]; 
	NSDictionary *endDateSortDict=[NSDictionary dictionaryWithObjectsAndKeys:@"EndDate",@"Property",
								   [NSNumber numberWithBool:YES],@"Ascending",nil]; 
	
	NSMutableArray *loadArray=[NSMutableArray array];
	
	NSMutableArray *sortArray=[NSMutableArray array];
//	[sortArray addObject:approveSortDict];
	[sortArray addObject:endDateSortDict];
	

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


//	[loadArray addObject:remainingApproversDict];
	[loadArray addObject:filteredHistoryDict];
    [loadArray addObject:finalmealBreakViolationsDict];
    [loadArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"User",@"Relationship", nil]];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:argsArray,@"Args",sortArray,@"SortBy",
							 @"Query",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
							 loadArray,@"Load",@"EntryTimesheetWaitingApprovalByApprover",@"QueryType",
                             [[G2AppProperties getInstance]getAppPropertyFor:@"NextRecentApprovalsPendingSheetsCount"] ,@"Count",[NSNumber numberWithInt:0], @"StartIndex",
							 nil];
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	

	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDictForApprovals :paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"FetchAllPendingAprrovalsByApprover"]];
	[self setServiceDelegate: self];
	[self executeRequest];	 
}

-(void)sendRequestToFetchAllPendingTimesheetsEntriesForApprovalsBySheetIdentity:(NSString *)sheetIdentity

{
	NSArray *identityArray = [NSArray arrayWithObject:sheetIdentity];
	NSArray *argsArray = [NSArray arrayWithObject:identityArray];
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
    
    
//    NSDictionary *languageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Language",@"Relationship",nil];
//    NSArray *languageArray=[NSArray arrayWithObject:languageDict];
//	NSDictionary *mealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BreakRuleViolationEntries",@"Relationship",languageArray,@"Load",nil];
//    NSDictionary *finalmealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BreakRuleViolations",@"Relationship",[NSArray arrayWithObject:mealBreakViolationsDict],@"Load",nil];
    
	[loadArray addObject:timeEntriesDict];
	[loadArray addObject:timeOffEntriesDict];
	[loadArray addObject:remainingApproversDict];
	[loadArray addObject:filteredHistoryDict];
//     [loadArray addObject:finalmealBreakViolationsDict];
    [loadArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"User",@"Relationship", nil]];
    
    
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:argsArray,@"Args",
							 @"Query",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
							 @"EntryTimesheetById",@"QueryType",loadArray,@"Load",
							 argsArray,@"Args",
							 nil];
    
    //Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];

	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDictForApprovals:paramDict]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName:@"ApprovalsFetchTimesheetByID"]];//Service Id: 82 Notification: APPROVAL_TIMESHEETS_ENTRIES_RECEIVED_NOTIFICATION
	[self setServiceDelegate: self];
	[self executeRequest];	
}

-(void)sendRequestToFetchAllPendingTimesheetsEntriesForApprovals
{
    
	

	NSString *userId=[[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
	NSMutableArray *argsArray=[NSMutableArray array];
	NSDictionary *argsDict=[NSDictionary dictionaryWithObjectsAndKeys:userId,@"Identity",@"Replicon.Domain.User",@"__type",nil];
	[argsArray addObject:argsDict];
    /*POSSIBLE ENUM ORDERS 
     Approved
     Cancelled
     Open
     Rejected
     Waiting
     */
//	NSArray *enumArr = [NSArray arrayWithObjects:@"Open",nil];
//	NSDictionary *approveSortDict=[NSDictionary dictionaryWithObjectsAndKeys:@"ApprovalStatus",@"Property",
//								   enumArr,@"EnumOrder",		  
//								   [NSNumber numberWithBool:YES],@"Descending",nil]; 
//	NSDictionary *endDateSortDict=[NSDictionary dictionaryWithObjectsAndKeys:@"EndDate",@"Property",
//								   [NSNumber numberWithBool:YES],@"Descending",nil]; 
	
	NSMutableArray *loadArray=[NSMutableArray array];
	
//	NSMutableArray *sortArray=[NSMutableArray array];
//	[sortArray addObject:approveSortDict];
//	[sortArray addObject:endDateSortDict];
	
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
//	NSDictionary *remainingApproversDict = [NSDictionary dictionaryWithObjectsAndKeys:
//											@"RemainingApprovers",@"Relationship",
//											nil];
	NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Type",@"Relationship",nil];
	NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
	NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"FilteredHistory",@"Relationship",
										 approvalLoadArray,@"Load",
										 nil];
	[loadArray addObject:timeEntriesDict];
	[loadArray addObject:timeOffEntriesDict];
//	[loadArray addObject:remainingApproversDict];
	[loadArray addObject:filteredHistoryDict];
    [loadArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"User",@"Relationship", nil]];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:argsArray,@"Args",
							 @"Query",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
							 loadArray,@"Load",@"EntryTimesheetWaitingApprovalByApprover",@"QueryType",
							 nil];
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	
	//set the start index for next fetch
    //	[[NSUserDefaults standardUserDefaults] setObject:startIndex forKey:TIMESHEET_FETCH_START_INDEX];
    //	[[NSUserDefaults standardUserDefaults] synchronize];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDictForApprovals:paramDict]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName:@"FetchAllPendingAprrovalsTimesheetsEntriesByApprover"]];//Service Id: 79 Notification: APPROVAL_TIMESHEETS_ENTRIES_RECEIVED_NOTIFICATION
	[self setServiceDelegate: self];
	[self executeRequest];	 
}

-(void)sendRequestToGetModifiedPendingApprovalsTimeSheetsFromLastUpdatedDate:(NSDate *)lastUpdatedDate {
	
    
    
	NSMutableArray *argsArray = [NSMutableArray array];
	NSString *userId= [[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
	NSDictionary *argsDict=[NSDictionary dictionaryWithObjectsAndKeys:userId,@"Identity",@"Replicon.Domain.User",@"Type",nil];
	[argsArray addObject:argsDict];
	
	NSMutableDictionary *dateDetailsDict = [G2Util getDateDictionaryforTimeZoneWith:@"UTC" forDate:lastUpdatedDate];
	
	if (dateDetailsDict != nil) {
		[dateDetailsDict setObject:@"DateTime" forKey:@"Type"];
		[argsArray addObject:dateDetailsDict];
	}
	
	NSMutableArray *loadArray=[NSMutableArray array];
    
    NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"Type",@"Relationship",nil];
    
	NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
	NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"FilteredHistory",@"Relationship",
										 approvalLoadArray,@"Load",
										 nil];
    
    
    NSDictionary *languageDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"Language",@"Relationship",nil];
    
    NSArray *languageArray=[NSArray arrayWithObject:languageDict];
    
	NSDictionary *mealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                        @"BreakRuleViolationEntries",@"Relationship",
                                           languageArray,@"Load",nil];
    
    NSDictionary *finalmealBreakViolationsDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                @"BreakRuleViolations",@"Relationship",
                                                [NSArray arrayWithObject:mealBreakViolationsDict],
                                                @"Load",nil];
    
    
    
	[loadArray addObject:filteredHistoryDict];
    [loadArray addObject:finalmealBreakViolationsDict];
    [loadArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"User",@"Relationship", nil]];
	

	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:argsArray,@"Args",
							 @"Query",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
							 @"TimesheetWaitingApprovalByApproverModifiedSince",@"QueryType",
							 loadArray,@"Load",
							 nil];
    
    NSMutableArray *identitiesArray = [approvalsModel getAllSheetIdentitiesFromDB];
	
	NSMutableDictionary *queryDict2 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"ExistsForApproval",@"Action",
									  @"Replicon.TimeSheet.Domain.Timesheet",@"Type",identitiesArray,@"Identities",nil];
    
    NSMutableArray *requestArray=[NSMutableArray array];
    [requestArray addObject:queryDict];
    if ([identitiesArray count]>0)
    {
        [requestArray addObject:queryDict2];
    }
    
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:requestArray error:&err];
	DLog(@"APPROVAL MODIFIED SHEET CHECK QUERY:::FETCH	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDictForApprovals:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ApprovalModifiedPendingTimesheets"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}


-(void) fetchPendingApprovalsTimeSheetData:(id)_delegate
{

	NSMutableArray *dbTimeSheets = [approvalsModel getTimesheetsFromDB];
	
	totalRequestsServed = 0;
	totalRequestsSent = 0;
	
   
    
    if ([dbTimeSheets count] == 0)
    {
		[self sendRequestToFetchAllPendingTimesheetsForApprovals];
		totalRequestsSent++;
	}
    else if(dbTimeSheets != nil && [dbTimeSheets count] > 0)
    {
		id lastSyncDateSeconds = [G2SupportDataModel getLastSyncDateForServiceId:APPROVAL_TIMESHEET_DATA_SERVICE_SECTION];
		NSDate *lastUpdatedDate = [NSDate dateWithTimeIntervalSince1970:[lastSyncDateSeconds longValue]];
		[[G2RepliconServiceManager approvalsService] sendRequestToGetModifiedPendingApprovalsTimeSheetsFromLastUpdatedDate :lastUpdatedDate];
		totalRequestsSent++;
	}	
}

-(void) fetchPendingApprovalsTimeSheetEntriesData:(id)_delegate
{
//    [approvalsModel deleteAllRowsForApprovalTimesheetsTable];
    totalRequestsServed = 0;
	totalRequestsSent = 0;
    [self sendRequestToFetchAllPendingTimesheetsEntriesForApprovals];
    totalRequestsSent++;
}

-(void) fetchPendingApprovalsTimeSheetEntriesDataForSheetIdentity:(NSString *)sheeetIdentity andDelegate:(id)_delegate
{
    //    [approvalsModel deleteAllRowsForApprovalTimesheetsTable];
    totalRequestsServed = 0;
	totalRequestsSent = 0;
    [self sendRequestToFetchAllPendingTimesheetsEntriesForApprovalsBySheetIdentity:sheeetIdentity];
    totalRequestsSent++;
}
-(void) fetchPendingApprovalsTimeSheetEntriesDataForSheetIdentityWithUserpermissionsAndPreferencesAndUdf:(NSString *)sheeetIdentity andUserIdentity:(NSString *)userIdentity withDelegate:(id)_delegate
{
    
   
    totalRequestsServed = 0;
	totalRequestsSent = 0;
    NSMutableArray *mergedRequestArr=[NSMutableArray array];
    NSMutableDictionary *paramDictionaryIdentifier=[NSMutableDictionary dictionary];
    NSMutableArray *paramarray=[NSMutableArray array];
    
    /*******create querydict for fetch approval timesheet by userID*********/
    
        
    
    NSMutableArray *timeEntriesArr=[approvalsModel getTimeEntriesForSheetFromDB:sheeetIdentity ];
    NSMutableArray *timeOffEntriesArr=[approvalsModel getTimeOffsForSheetFromDB:sheeetIdentity];
    NSMutableArray *bookedTimeOffEntriesArr=[approvalsModel getBookedTimeOffEntryForSheetWithOnlySheetIdentity:sheeetIdentity];
    
    BOOL fetchPendingTimeSheet=NO;
    
    if (([timeEntriesArr count]>0 && timeEntriesArr!=nil) || ([timeOffEntriesArr count]>0  && timeOffEntriesArr!=nil) ||  ([bookedTimeOffEntriesArr count]>0  && bookedTimeOffEntriesArr!=nil) )
    {
        fetchPendingTimeSheet=NO;
        
    }
    else
    {
        fetchPendingTimeSheet=YES;
    }

    if (fetchPendingTimeSheet)
    {
        NSArray *identityArray = [NSArray arrayWithObject:sheeetIdentity];
        NSArray *argsArray = [NSArray arrayWithObject:identityArray];
        NSMutableArray *loadArray = [NSMutableArray array];
        
        NSDictionary *activityDict    = [NSDictionary dictionaryWithObjectsAndKeys:@"Activity",@"Relationship",nil];
        NSDictionary *projectRoleDict = [NSDictionary dictionaryWithObjectsAndKeys:@"ProjectRole",@"Relationship",nil];
        NSDictionary *billingDepartmentDict = [NSDictionary dictionaryWithObjectsAndKeys:@"BillingRateDepartment",@"Relationship",nil];
        NSDictionary *clientDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
        NSDictionary *billingDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Billable",@"Relationship",nil];
        
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
        
        
        [loadArray addObject:timeEntriesDict];
        [loadArray addObject:timeOffEntriesDict];
        [loadArray addObject:remainingApproversDict];
        [loadArray addObject:filteredHistoryDict];
        //[loadArray addObject:finalmealBreakViolationsDict];
        [loadArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"User",@"Relationship", nil]];
        
        
        NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:argsArray,@"Args",
                                 @"Query",@"Action",@"Replicon.Suite.Domain.EntryTimesheet",@"DomainType",
                                 @"EntryTimesheetById",@"QueryType",loadArray,@"Load",
                                 argsArray,@"Args",
                                 nil];
        
        
        [mergedRequestArr addObject:queryDict];
        [paramarray addObject:Approval_PendingTimesheet_identifier];
    }
    
    
    
        
     /*******create querydict for fetch permissions by userID*********/
    
    NSMutableArray *userPermissionsArr=[approvalsModel getUserPermissionsForUserID:userIdentity];
    
    if (userPermissionsArr==nil || [userPermissionsArr count]==0)
    {
        
        if (userIdentity!=nil)
        {
            [self.filterUsersForPermissions removeAllObjects];
            [self.filterUsersForPermissions addObject:userIdentity];
            NSMutableArray *permissionsArray = [NSMutableArray arrayWithObjects:
                                                @"UseTimesheet",
                                                @"ProjectExpense",
                                                @"ClassicTimesheet",
                                                @"LockedInOutTimesheet",
                                                @"InOutTimesheet",
                                                @"NewInOutTimesheet",
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
                                                @"AllowBlankResubmitExpenseComment",
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
                                                @"MobileLockedInOutTimesheet",nil];
            NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.User",@"Type"
                                      ,[NSString stringWithFormat:@"%@", userIdentity] ,@"Identity"
                                      ,nil];
            NSDictionary *permissionsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"CheckUserPermissions",@"Action",userDict,@"User",permissionsArray,@"Permissions"
                                             ,nil];
            [mergedRequestArr addObject:permissionsDict];
            [paramarray addObject:Approval_Permissions_identifier];
        }
        
    }
     /*******create querydict for fetch preferences by userID*********/
    
    NSMutableArray *userPreferencesArr=[approvalsModel getAllUserPreferencesForUserID:userIdentity];
    if (userPreferencesArr==nil || [userPreferencesArr count]==0)
    {
        
        if (userIdentity!=nil)
        {
            [self.filterUsersForPreferences removeAllObjects];
            [self.filterUsersForPreferences addObject:userIdentity];
            NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.User",@"Type"
                                      ,[NSString stringWithFormat:@"%@", userIdentity] ,@"Identity"
                                      ,nil];
            
            NSDictionary *userPreferenceDict=[NSDictionary dictionaryWithObjectsAndKeys:@"GetUserPreferences",@"Action",userDict,@"User",nil];
            [mergedRequestArr addObject:userPreferenceDict];
            [paramarray addObject:Approval_Preferences_identifier];
        }
        
    }
    /*******create querydict for approval UDF's *********/
    NSArray *allUDFDetailsArray=[approvalsModel getAllUdfDetails];
    if (allUDFDetailsArray==nil) {
        
        
        
        NSArray *sheetArgsArray = [NSArray arrayWithObject:ReportPeriod_SheetLevel];
        NSArray *rowArgsArray   = [NSArray arrayWithObject:TaskTimesheet_RowLevel];
        NSArray *cellArgsArray  = [NSArray arrayWithObject:TimesheetEntry_CellLevel];
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
                                                 nil];
       
        
        [mergedRequestArr addObject:sheetLevelDict];
        [mergedRequestArr addObject:rowLevelDict];
        [mergedRequestArr addObject:cellLevelDict];
        [mergedRequestArr addObject:timeOffsLevelDict];
        [paramarray addObject:Approval_sheetLevelUDF_identifier];
        [paramarray addObject:Approval_rowLevelUDF_identifier];
        [paramarray addObject:Approval_cellLevelUDF_identifier];
        [paramarray addObject:Approval_timeoffLevelUDF_identifier];
        
        
    }

    if ([paramarray count]==0)
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ALL_PENDING_APPROVAL_TIMESHEETS_ENTRIES_SERVED_NOTIFICATION object:nil];
        return;
    }

    //Send  request
    
    [paramDictionaryIdentifier setObject:paramarray forKey:@"requestIdentifier"];
    
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:mergedRequestArr error:&err];
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
    
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDictForApprovals:paramDict]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName:@"MergedApprovalsAPI"]];
	[self setServiceDelegate: self];
	[self executeRequest:paramDictionaryIdentifier];

    
    totalRequestsSent++;
}

- (void) serverDidRespondWithResponse:(id) response
{
    NSNumber *serviceId=nil;
    if (response != nil) 
    {
        
        NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		if ([status isEqualToString:@"OK"]) 
        {
            serviceId=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
            DLog(@"SERVICE ID::%@" ,serviceId);
            if ([serviceId intValue] == FetchPendingApprovalCountByApprover_69) {
                
            }
            else if ([serviceId intValue] == AprrovalsMergedAPI_101)
            {
                totalRequestsServed++;
                [self handleMergedApprovalsAPIResponse:response];
            }
            else if ([serviceId intValue] == AprrovalsFetchNextRecentTimesheets_102)
            {
                totalRequestsServed++;
                [self handleNextRecentApprovalTimesheets:response];
                //[self updateApprovalsLastUpdateTime];
            }
            else if ([serviceId intValue] == FetchAllPendingAprrovalsByApprover_70) {
                totalRequestsServed++;
                [self handleTimeSheetsResponse:response];
                 [self updateApprovalsLastUpdateTime];
            }
            else if([serviceId intValue] == Approvals_BookedTimeOff_Service_Id_71) {
                totalRequestsServed++;
                
                NSMutableDictionary *otherParamsDict = [[response objectForKey:@"refDict"]objectForKey:@"params"];
                
                NSString *sheetId = [otherParamsDict objectForKey:@"identity"];
                
                [self handleBookedTimeOffResponse:response forSheetId:sheetId];
                
            }
            else if ([serviceId intValue] == ModifiedTimesheets_Service_Id_72) {
                totalRequestsServed++;
                NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
                if (status!=nil && [status isEqualToString:@"OK"])
                {
                     [self handleModifiedTimesheetsResponse:response];
                    [self updateApprovalsLastUpdateTime];
                    
                    NSMutableArray *pendingTSArr=[approvalsModel getTimesheetsFromDBForApprovalStatus:G2WAITING_FOR_APRROVAL_STATUS];
                    
                   
                    NSNumber  *nextFetchStartIndex = [NSNumber numberWithUnsignedInteger:[pendingTSArr count]];
                    [[NSUserDefaults standardUserDefaults] setObject:nextFetchStartIndex forKey:APPROVAL_TIMESHEET_FETCH_START_INDEX];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    
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
                    return;
                }
               
            }
            else if ([serviceId intValue] == Approvals_TimeSheetsExisted_Service_Id_73) {
                totalRequestsServed++;
                [self handleExistedTimesheetsResponse:response];
            }
            else if ([serviceId intValue] == Approvals_UserActivities_Service_Id_74) {//Request Name: 
                totalRequestsServed++;
                //			[self handleUserActivitiesResponse:response];
            }
            else if ([serviceId intValue] == Approvals_TimesheetUDFs_Service_id_75) {
                totalRequestsServed++;
                
                [self handlePermissionBasedTimesheetUDFsResponse:response];
            }
            else if ([serviceId intValue] == Approvals_UserProjectsAndClients_76) {
                totalRequestsServed++;
                //			[self handleProjectsAndClientsResponse:response];
            }
            else if ([serviceId intValue] == Approvals_CheckUserPermissions_ServiceID_77) {
                totalRequestsServed++;
                               
                
                
            }
            
            else if ([serviceId intValue] == Approvals_GetUserPreferences_78) {
                totalRequestsServed++;
                //[self handleUserPreferencesResponse: response];
            }
            
            else if ([serviceId intValue] == Approvals_FetchAllPendingAprrovalsTimesheetsEntriesByApprover_79) {
                totalRequestsServed++;
                [self handleTimeSheetsEntriesResponse:response];
            }
            
            else if ([serviceId intValue] == ApprovalsFetchTimesheetByID_82) {
                totalRequestsServed++;
                [self handleTimeSheetsEntriesResponse:response];
            }
            
            else if ([serviceId intValue] == Approvals_Approve_80) {
                totalRequestsServed++;
                [self handleApprovedTimesheetResponse:response];
            }
            
            else if ([serviceId intValue] == Approvals_Reject_81) {
                totalRequestsServed++;
                [self handleRejectedTimesheetResponse:response];
            }
            else if ([serviceId intValue] == Approvals_UserByLoginName_1) {
                totalRequestsServed++;
                [self handleUserDownloadContent:response];
            }
        
        
        //added below condition to check if all requests are served
        DLog(@"ApprovalsService===> RequestsServed / Sent: %d / %d", totalRequestsServed, totalRequestsSent);
        if (totalRequestsServed == totalRequestsSent) {
            ;
            [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_TIMESHEETS_RECEIVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:ALL_PENDING_APPROVAL_TIMESHEETS_ENTRIES_SERVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_TIMESHEETS_APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
            
        }
        		
	}
    
      else 
       {
          totalRequestsServed++;
          [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
           NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
           [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
           [G2Util errorAlert:@"" errorMessage:message];
        
       }
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
    
    if (!appdelegate.isAlertOn) 
    {
        if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED]) {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
            {
                UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED)
                                                                          delegate:self cancelButtonTitle:RPLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
                [confirmAlertView setDelegate:self];
                [confirmAlertView setTag:SAML_SESSION_TIMEOUT_TAG];
                [confirmAlertView show];
                
            }
            else 
            {
               [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:SESSION_EXPIRED];
            }
            
        }
        else  if ([appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) {
            [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:G2PASSWORD_EXPIRED];
            [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
        }
        else
        {
            [G2Util errorAlert:RPLocalizedString( @"Connection failed",@"") errorMessage:[error localizedDescription]];
        }
        
    }
   
    if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED] ||  [appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) 
    {
        appdelegate.isAlertOn=TRUE;
    }
    else
    {
        appdelegate.isAlertOn=FALSE;
    }
    
    
}

-(void)handleUserActivitiesResponse:(id)response{
//	NSString *responseStatus = [[response objectForKey:@"response"] objectForKey:@"Status"];
	
//	if([responseStatus isEqualToString:@"OK"]) {
//		NSArray *valueArray = [[response objectForKey:@"response"] objectForKey:@"Value"];
//		NSDictionary *userDict = [valueArray objectAtIndex:0];
//		NSArray *activityArray = [[userDict objectForKey:@"Relationships"] objectForKey:@"Activities"];
//		NSArray *timeOffCodesArray = [[userDict objectForKey:@"Relationships"] objectForKey:@"TimeOffCodeAssignments"];
//		[supportDataModel saveUserActivitiesFromApiToDB:activityArray];
//		[supportDataModel saveTimeOffCodesFromApiToDB:timeOffCodesArray];
//		[[NSNotificationCenter defaultCenter] postNotificationName:USER_ACTIVITIES_TIME_OFF_CODES_RECEIVED_NOTIFICATION object:nil];
//	}else {
//		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
//		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
//		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
//		if (value!=nil) {
//            //			[Util errorAlert:responseStatus errorMessage:value];
//            [Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
//		}else {
//            //			[Util errorAlert:responseStatus errorMessage:message];
//            [Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
//		}
//	}
}


-(void)handlePermissionBasedTimesheetUDFsResponse:(id)response{
	//DLog(@"Response:::handlePermissionBasedTimesheetUDFsResponse %@",response);
	NSString *responseStatus = [[response objectForKey:@"response"] objectForKey:@"Status"];
	
	if(responseStatus != nil && [responseStatus isEqualToString:@"OK"]) {
        
        NSArray *responseArr= [[response objectForKey:@"response"] objectForKey:@"Value"];
        
        [approvalsModel deleteAllRowsForApprovalUserDefinedFieldsTable];
        
        for (int i=0; i<[responseArr count]; i++) 
        {
            
            NSDictionary *valueDict = [responseArr objectAtIndex:i];
            if ( valueDict != nil) {
                [approvalsModel savePermissionBasedTimesheetUDFsToDBForUserID:valueDict];
                //[[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEET_UDFs_RECEIVED_NOTIFICATION object:nil];
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

-(void)handleExistedTimesheetsResponse:(id)response
{
	//DLog(@"Time sheet S RESPONSE %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil && [valueArray count] >0) {
			
			[approvalsModel removeWtsDeletedSheetsFromDB:valueArray];
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

-(void)handleBookedTimeOffResponse:(id)response forSheetId:(NSString *)_sheetId
{
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
			[approvalsModel saveBookedTimeOffEntriesIntoDB:valueArray forSheetId:_sheetId];
//            if (totalRequestsServed==totalRequestsSent) {
//                [[NSNotificationCenter defaultCenter]postNotificationName:NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION object:[NSDictionary dictionary]];//Added by Dipta for loading screen stays on more action
//            }
            
		}else{
//            [[NSNotificationCenter defaultCenter]postNotificationName:NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION object:[NSDictionary dictionary]];//DE3418

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
-(void)handleMergedApprovalsAPIResponse:(id)response
{
    NSMutableArray *approvalTimesheetByUserResponseArr=[NSMutableArray array];
    NSMutableArray *approvalUserPermissionsResponseArr=[NSMutableArray array];
    NSMutableArray *approvalUserPreferencesResponseArr=[NSMutableArray array];
    NSMutableArray *approvalUserUDFResponseArr=[NSMutableArray array];
    
    NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status != nil && [status isEqualToString:@"OK"])
    {
		NSMutableArray *responseArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
        NSMutableArray *paramsArray = [[[response objectForKey:@"refDict"]objectForKey:@"params"] objectForKey:@"requestIdentifier"];
        for (int i=0; i<[paramsArray count]; i++)
        {
            NSDictionary *responseDict=[responseArray objectAtIndex:i];
            NSString *responseType=[paramsArray objectAtIndex:i];
            
            if ([responseType isEqualToString:Approval_PendingTimesheet_identifier])
            {
                [approvalTimesheetByUserResponseArr addObject:responseDict];
                if ([responseArray count]==0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_TIMESHEET_DELETED_NOT_WAITINGFORAPPROVAL object:nil];
                }
                else
                {
                    BOOL isFromTimesheets=FALSE;
                    [approvalsModel saveApprovalsTimesheetsFromApiToDB:approvalTimesheetByUserResponseArr:isFromTimesheets];
                }

            }
            else if ([responseType isEqualToString:Approval_Permissions_identifier])
            {
                [approvalUserPermissionsResponseArr addObject:responseDict];
                [approvalsModel insertUserPermissionsInToDataBase:approvalUserPermissionsResponseArr andUserIdArr:self.filterUsersForPermissions];
                for (int i=0; i<[self.filterUsersForPermissions count]; i++)
                {
                    NSString *userID=[self.filterUsersForPermissions objectAtIndex:i];
                    NSMutableArray   *enabledPermissions = [approvalsModel getAllEnabledUserPermissionsByUserID:userID];
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
                        [standardUserDefaults setObject:expensePermission forKey:@"approvalsexpensePermissionFlag"];
                        [standardUserDefaults synchronize];
                    }
                    NSString *permissionType  = @"";
                    
                    if (projectTimeSheet == YES && nonProjectTimeSheet == YES) {
                        permissionType = BOTH;
                    }else if(projectTimeSheet == YES && nonProjectTimeSheet == NO){
                        permissionType = AGAINSTPROJECT;
                    }else if(projectTimeSheet == NO && nonProjectTimeSheet == YES) {
                        permissionType = WITHOUT_REQUIRING_PROJECT;
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:permissionType
                                                              forKey:@"approvalsTimeSheetProjectPermissionType"];
                    [standardUserDefaults synchronize];
                    
                }
            }
            else if ([responseType isEqualToString:Approval_Preferences_identifier])
            {
                [approvalUserPreferencesResponseArr addObject:responseDict];
                [approvalsModel saveUserPreferencesFromApiToDB: approvalUserPreferencesResponseArr andUserIdArr:self.filterUsersForPreferences];
            }
            else 
            {
                
                [approvalUserUDFResponseArr addObject:responseDict];
            }
        }
        
        for (int i=0; i<[approvalUserUDFResponseArr count]; i++)
        {
            //save udf's data into database
            [approvalsModel savePermissionBasedTimesheetUDFsToDBForUserID:[approvalUserUDFResponseArr objectAtIndex:i]];
            
            
        }
        
        if ([approvalUserUDFResponseArr count]>0)
        {
             [self updateApprovalsSupportDataLastUpdateTime];
        }
        
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
}
-(void)handleNextRecentApprovalTimesheets:(id)response
{
    
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
			
            int lastSheetIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:APPROVAL_TIMESHEET_FETCH_START_INDEX]
                                  intValue];
            NSNumber  *nextFetchStartIndex = [NSNumber numberWithUnsignedInteger:lastSheetIndex +[valueArray count]];
            [[NSUserDefaults standardUserDefaults] setObject:nextFetchStartIndex forKey:APPROVAL_TIMESHEET_FETCH_START_INDEX];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
                        
            BOOL isFromTimesheets=TRUE;
			[approvalsModel saveApprovalsTimesheetsFromApiToDB:valueArray:isFromTimesheets];
            NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
            int lastCount=[[standardUserDefaults objectForKey:APPROVAL_LAST_DOWNLOADED_TIMESHEETS_COUNT] intValue];
            [standardUserDefaults setObject:[NSNumber numberWithUnsignedInteger:lastCount+[valueArray count]] forKey:APPROVAL_LAST_DOWNLOADED_TIMESHEETS_COUNT];
            [standardUserDefaults setObject:[NSNumber numberWithUnsignedInteger:[valueArray count]] forKey:APPROVAL_RECENT_DOWNLOADED_TIMESHEETS_COUNT];
			[standardUserDefaults synchronize];
            
            if ([valueArray count]==0)
            {
                NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                int badgeValue=[[defaults objectForKey:@"NumberOfTimesheetsPendingApproval"]intValue];
                [defaults setObject:[NSNumber numberWithInt:badgeValue] forKey:APPROVAL_LAST_DOWNLOADED_TIMESHEETS_COUNT];
                [defaults synchronize];
            }
            
            int recentTimesheetsCount=[[[NSUserDefaults standardUserDefaults] objectForKey:APPROVAL_RECENT_DOWNLOADED_TIMESHEETS_COUNT] intValue];
            
            if (recentTimesheetsCount<[[[G2AppProperties getInstance]getAppPropertyFor:@"NextRecentApprovalsPendingSheetsCount"] intValue])
            {
                id lastSyncDateSeconds = [G2SupportDataModel getLastSyncDateForServiceId:APPROVAL_TIMESHEET_DATA_SERVICE_SECTION];
                NSDate *lastUpdatedDate = [NSDate dateWithTimeIntervalSince1970:[lastSyncDateSeconds longValue]];
                [[G2RepliconServiceManager approvalsService] sendRequestToGetModifiedPendingApprovalsTimeSheetsFromLastUpdatedDate :lastUpdatedDate];
                totalRequestsSent++;
            }
            

            
		}
        		
	}
    else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil)
        {
           
            [G2Util errorAlert:@"" errorMessage:value];
		}else {
           
            [G2Util errorAlert:@"" errorMessage:message];
		}
	}

    
}
-(void)handleTimeSheetsResponse:(id)response
{
	
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
			
            if ([valueArray count] > 0)
            {
                NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
                [standardUserDefaults setObject:[valueArray objectAtIndex:0] forKey:APPROVAL_QUERY_HANDLE];
                [standardUserDefaults synchronize];
                [valueArray removeObjectAtIndex:0];
            }
            
            NSNumber  *nextFetchStartIndex = [NSNumber numberWithUnsignedInteger:[valueArray count]];
            [[NSUserDefaults standardUserDefaults] setObject:nextFetchStartIndex forKey:APPROVAL_TIMESHEET_FETCH_START_INDEX];
            [[NSUserDefaults standardUserDefaults] synchronize];
           
                        
            BOOL isFromTimesheets=TRUE;
			[approvalsModel saveApprovalsTimesheetsFromApiToDB:valueArray:isFromTimesheets];
            NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
            int lastCount=[[standardUserDefaults objectForKey:APPROVAL_LAST_DOWNLOADED_TIMESHEETS_COUNT] intValue];
            [standardUserDefaults setObject:[NSNumber numberWithUnsignedInteger:lastCount+[valueArray count]] forKey:APPROVAL_LAST_DOWNLOADED_TIMESHEETS_COUNT];
            [standardUserDefaults setObject:[NSNumber numberWithUnsignedInteger:[valueArray count]] forKey:APPROVAL_RECENT_DOWNLOADED_TIMESHEETS_COUNT];
			[standardUserDefaults synchronize];

		}
        
		
	}
    else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil)
        {
            
            [G2Util errorAlert:@"" errorMessage:value];
		}else {
            
            [G2Util errorAlert:@"" errorMessage:message];
		}
	}
}

-(void)handleTimeSheetsEntriesResponse:(id)response
{
	//DLog(@"HANDLING TIMESHEET RESPONE %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil) {
			
			//delete all timesheets which are not modified offline.
//			[approvalsModel deleteUnmModifiedTimesheets];
			
//            for (int i = 0; i<[valueArray count]; i++) 
//            {
//                
//                NSDictionary *timesheetDict = [valueArray objectAtIndex:i];
//                
//                NSNumber *sheetIdentity = [timesheetDict objectForKey:@"Identity"];
//                NSDictionary *endDateDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"EndDate"];
//                NSDictionary *startDateDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"StartDate"];
//                
//                
//                [[RepliconServiceManager approvalsService] sendRequestToFetchBookedTimeOffForUserForSheetId:[NSString stringWithFormat:@"%@",sheetIdentity] withStartDate:startDateDict withEndDate:endDateDict];
//                totalRequestsSent++;
//                
//                break;
//            }
             BOOL isFromTimesheets=FALSE;
            //DE5784 
            if ([valueArray count]==0)
            {
                 [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_TIMESHEET_DELETED_NOT_WAITINGFORAPPROVAL object:nil];
            }
            else {
                [approvalsModel saveApprovalsTimesheetsFromApiToDB:valueArray:isFromTimesheets];
            }
            
            			
		
			
		}
        else
        {
//            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"NumberOfTimeSheets"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
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

-(void)handleModifiedTimesheetsResponse:(id)response {
	

		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
		if(valueArray != nil && [valueArray count] >0)
        {
			
            
            
            NSMutableArray *modifiedSheetsArray=[NSMutableArray array];
            NSMutableArray *deletedSheetsArray=[NSMutableArray array];
            for (int i=0; i<[valueArray count]; i++)
            {
                NSDictionary *dict=[valueArray objectAtIndex:i];
                if ([dict objectForKey:@"Properties"]!=nil)
                {
                    [modifiedSheetsArray addObject:[valueArray objectAtIndex:i]];
                }
                else
                {
                    NSArray *keysArray = [dict allKeys];
                    if (keysArray != nil && [keysArray count] > 0) {
                        for (int i=0; i < [keysArray count]; i++) {
                            if ([[dict objectForKey:[keysArray objectAtIndex:i]]intValue] == 0)
                            {
                                [deletedSheetsArray addObject:[keysArray objectAtIndex:i]];
                            }
                        }
                   
                }
            }
            }
            
            if ([modifiedSheetsArray count]>0)
            {
                BOOL isFromTimesheets=TRUE;
                [approvalsModel saveApprovalsTimesheetsFromApiToDB:modifiedSheetsArray:isFromTimesheets];
            }
            
          
            for (int i=0; i<[deletedSheetsArray count]; i++)
            {
              
                    NSString *sheetID=[deletedSheetsArray objectAtIndex:i];
                    [approvalsModel deleteDeletedApprovalTimesheetWithSheetIdentity:sheetID];
                
            }
            
            
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            int badgeValue=[[defaults objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];
            
            NSUInteger calcBadgeValue= badgeValue-[deletedSheetsArray count];
            NSUInteger countPendingTS=[[approvalsModel getAllSheetIdentitiesFromDB]count];
            
            if (countPendingTS>calcBadgeValue)
            {
                 [defaults setObject:[NSString stringWithFormat:@"%lu", (unsigned long)countPendingTS] forKey:@"NumberOfTimesheetsPendingApproval"];
            }
            else
            {
                [defaults setObject:[NSString stringWithFormat:@"%lu", (unsigned long)calcBadgeValue] forKey:@"NumberOfTimesheetsPendingApproval"];
            }
            
           
            [defaults synchronize];
            
			
		}
		else
        {
            G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
            [myDB deleteFromTable:@"approvals_timesheets" inDatabase:@""];
            [myDB deleteFromTable:@"approvals_time_entries" inDatabase:@""];
            [myDB deleteFromTable:@"approvals_booked_time_off_entries" inDatabase:@""];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"NumberOfTimesheetsPendingApproval"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
       
	
}




-(void)handleApprovedTimesheetResponse: (id)response {
	
	//DLog(@"HANDLING SUBMIT TIMESHEET RESPONE %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
        for (int i=0; i<[valueArray count]; i++) 
        {
            
            if(valueArray != nil) {
                NSDictionary *infoDict = [valueArray objectAtIndex:i];
                NSString *sheetIdentity = [infoDict objectForKey:@"Identity"];
                
               
                if (sheetIdentity != nil) {
                    [approvalsModel updateTimesheetApprovalStatusFromAPIToDB:@"Approved" :sheetIdentity];
                    [approvalsModel deleteRowsForApprovalTimesheetsEntriesTableForSheetIdentity:sheetIdentity];
                    int lastSheetIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:APPROVAL_TIMESHEET_FETCH_START_INDEX]
                                          intValue];
                    NSNumber  *nextFetchStartIndex = [NSNumber numberWithInt:lastSheetIndex -1];
                    [[NSUserDefaults standardUserDefaults] setObject:nextFetchStartIndex forKey:APPROVAL_TIMESHEET_FETCH_START_INDEX];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
               
            }
        }
        
		int badgeValue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];
        NSUInteger count=badgeValue-[valueArray count];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu", (unsigned long)count] forKey:@"NumberOfTimesheetsPendingApproval"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSUInteger currentNumberOfPendingCount=[[defaults objectForKey:APPROVAL_LAST_DOWNLOADED_TIMESHEETS_COUNT] intValue];
        currentNumberOfPendingCount=currentNumberOfPendingCount-[valueArray count];
        [defaults setObject:[NSNumber numberWithUnsignedInteger:currentNumberOfPendingCount] forKey:APPROVAL_LAST_DOWNLOADED_TIMESHEETS_COUNT];
        
        NSMutableArray *timeSheetsArray=[approvalsModel getTimeEntriesFromDB];
        if (currentNumberOfPendingCount==0 && [timeSheetsArray count]==0)
        {
            NSDictionary *dict=[[NSUserDefaults standardUserDefaults]objectForKey:APPROVAL_QUERY_HANDLE];
            NSString *queryHandler=[dict objectForKey:@"Identity"];
            [self sendRequestToFetchNextRecentPendingTimesheetsWithStartIndex:[NSNumber numberWithInt:0] withLimitCount:[[G2AppProperties getInstance]getAppPropertyFor:@"NextRecentApprovalsPendingSheetsCount"] withQueryHandler:queryHandler withDelegate:self];
        }
        if (count==0)
        {
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSNumber numberWithInt:0] forKey:APPROVAL_LAST_DOWNLOADED_TIMESHEETS_COUNT];
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


-(void)handleRejectedTimesheetResponse: (id)response {
	
	//DLog(@"HANDLING SUBMIT TIMESHEET RESPONE %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {		  
		NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
        for (int i=0; i<[valueArray count]; i++) 
        {
            
            if(valueArray != nil) {
                NSDictionary *infoDict = [valueArray objectAtIndex:i];
                NSString *sheetIdentity = [infoDict objectForKey:@"Identity"];
                
                
                if (sheetIdentity != nil) {
                    [approvalsModel updateTimesheetApprovalStatusFromAPIToDB:@"Rejected" :sheetIdentity];
                    [approvalsModel deleteRowsForApprovalTimesheetsEntriesTableForSheetIdentity:sheetIdentity];
                    int lastSheetIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:APPROVAL_TIMESHEET_FETCH_START_INDEX]
                                          intValue];
                    NSNumber  *nextFetchStartIndex = [NSNumber numberWithInt:lastSheetIndex -1];
                    [[NSUserDefaults standardUserDefaults] setObject:nextFetchStartIndex forKey:APPROVAL_TIMESHEET_FETCH_START_INDEX];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
            }
        }
        
		int badgeValue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];
        NSUInteger count=badgeValue-[valueArray count];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu", (unsigned long)count] forKey:@"NumberOfTimesheetsPendingApproval"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSUInteger currentNumberOfPendingCount=[[defaults objectForKey:APPROVAL_LAST_DOWNLOADED_TIMESHEETS_COUNT] intValue];
        currentNumberOfPendingCount=currentNumberOfPendingCount-[valueArray count];
        [defaults setObject:[NSNumber numberWithUnsignedInteger:currentNumberOfPendingCount] forKey:APPROVAL_LAST_DOWNLOADED_TIMESHEETS_COUNT];
        [defaults synchronize];
        
        NSMutableArray *timeSheetsArray=[approvalsModel getTimeEntriesFromDB];
        if (currentNumberOfPendingCount==0 && [timeSheetsArray count]==0)
        {
            NSDictionary *dict=[[NSUserDefaults standardUserDefaults]objectForKey:APPROVAL_QUERY_HANDLE];
            NSString *queryHandler=[dict objectForKey:@"Identity"];
            [self sendRequestToFetchNextRecentPendingTimesheetsWithStartIndex:[NSNumber numberWithInt:0] withLimitCount:[[G2AppProperties getInstance]getAppPropertyFor:@"NextRecentApprovalsPendingSheetsCount"] withQueryHandler:queryHandler withDelegate:self];
        }
        if (count==0)
        {
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSNumber numberWithInt:0] forKey:APPROVAL_LAST_DOWNLOADED_TIMESHEETS_COUNT];
            [defaults synchronize];
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


-(void)handleUserDownloadContent:(NSDictionary *)response
{
    
    if (response!=nil)
    {
        NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
        if (status!=nil && [status isEqualToString:@"OK"]) {		  
            NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
            if(valueArray != nil) 
            {
                NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
                [standardUserDefaults setObject:[[[valueArray objectAtIndex:0] objectForKey:@"Properties"]objectForKey:@"NumberOfTimesheetsPendingApproval"] forKey:@"NumberOfTimesheetsPendingApproval"];
                [standardUserDefaults setObject:[[[valueArray objectAtIndex:0]  objectForKey:@"Properties"]objectForKey:@"NumberOfTimesheetsWithPreviousApprovalAction"] forKey:@"NumberOfTimesheetsWithPreviousApprovalAction"];
                [standardUserDefaults synchronize];
                
            }
            
            
        }
    }
   [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_TIMESHEETS_DOWNLOADING_TIMESHEETS_COUNT_NOTIFICATION object:nil];
}

-(void)sendRequestToFetchSheetsExistanceInfo
{

	
    
	NSMutableArray *identitiesArray = [approvalsModel getAllSheetIdentitiesFromDB];
	
	NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Exists",@"Action",
									  @"Replicon.Suite.Domain.EntryTimesheet",@"Type",identitiesArray,@"Identities",nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	[self setRequest: [G2RequestBuilder buildPOSTRequestWithParamDictForApprovals:paramDict]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName: @"ApprovalPendingTimeSheetsExisted"]];
	[self setServiceDelegate: self];
	[self executeRequest];
	
}

-(void)sendRequestToFetchBookedTimeOffForUser{
	DLog(@"sendRequestToFetchBookedTimeOffForUser:::TimeSheetService");
	
	NSMutableArray *dateArray = [approvalsModel getTimeSheetsStartAndEndDates];
	//DLog(@"Dates Array count %d",[dateArray count]);
	
	if (dateArray != nil && [dateArray count]>0) {
		for (NSDictionary *dateDict in dateArray ) {
			NSString *startDateString     = [dateDict objectForKey:@"endDate"];
			NSString *endDateString       = [dateDict objectForKey:@"startDate"];
			NSString *sheetId			  = [dateDict objectForKey:@"identity"];
			NSDate *startDate			  = [G2Util convertStringToDate:startDateString];
			NSDate *endDate				  = [G2Util convertStringToDate:endDateString];
			NSDictionary *startDateDict   = [G2Util convertDateToApiDateDictionary:startDate];
			NSDictionary *endDateDict     = [G2Util convertDateToApiDateDictionary:endDate];
			
			//Form the query to fetch Booked Time Off's
			[self sendRequestToFetchBookedTimeOffForUserForSheetId:sheetId withStartDate:startDateDict withEndDate:endDateDict];
			totalRequestsSent++;
		}
	}
}
-(void)sendRequestToFetchBookedTimeOffForUserForSheetId:(NSString *)_sheetIdentity 
										  withStartDate:(NSDictionary *)_startDateDict 
											withEndDate:(NSDictionary *)_endDateDict{

	NSString *userId       = [approvalsModel getUSerIDByTimeSheetID:_sheetIdentity];
	NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"Replicon.Domain.User",@"__type",
							  userId,@"Identity",nil];
	NSArray *argsArray     = [NSArray arrayWithObjects:userDict,_startDateDict,_endDateDict,nil];
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
	
	
	NSMutableDictionary *otherParamsDict = [[NSMutableDictionary alloc] init];
	if (_sheetIdentity != nil && ![_sheetIdentity isKindOfClass:[NSNull class]]) {
		[otherParamsDict setObject:_sheetIdentity forKey:@"identity"];
	}
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDictForApprovals:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ApprovalsBookedTimeOff"]];
	[self setServiceDelegate:self];
	[self executeRequest:otherParamsDict];
	
}

-(void) updateApprovalsLastUpdateTime
{

    [G2SupportDataModel updateLastSyncDateForServiceId:APPROVAL_TIMESHEET_DATA_SERVICE_SECTION];
}

-(void)updateApprovalsSupportDataLastUpdateTime
{
    [G2SupportDataModel updateLastSyncDateForServiceId:APPROVALS_SUPPORT_DATA_SERVICE_SECTION];
}

-(void)sendRequestToGetProjectsAndClientsforUserID:(NSArray *)userIdArr {
    if ([userIdArr count]>0) 
    {
        NSMutableArray *requestArr=[NSMutableArray arrayWithCapacity:[userIdArr count]];
        for (int i=0; i<[userIDArray count]; i++) 
        {
            NSArray *innerArgsArray = [NSArray arrayWithObject: [NSString stringWithFormat:@"%@", [userIdArr objectAtIndex:i]]];
            NSArray *argsArray = [NSArray arrayWithObject:innerArgsArray];
            
            NSDictionary *clientsLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"Client",@"Relationship",
                                             nil];
            NSArray *clientsLoadArray = [NSArray arrayWithObject:clientsLoadDict];
            
            NSDictionary *projectClientsLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    @"ProjectClients",@"Relationship",
                                                    clientsLoadArray,@"Load",
                                                    nil];
            NSDictionary *billingOptionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                @"UserBillingOptions",@"Relationship",nil];
            NSArray *projectClientsLoadArray = [NSArray arrayWithObjects:projectClientsLoadDict,
                                                billingOptionsDict,nil];
            
            NSDictionary *projectsLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              @"Projects",@"Relationship",
                                              projectClientsLoadArray,@"Load",
                                              nil];
            
            NSArray *loadArray = [NSArray arrayWithObject:projectsLoadDict];
            
            NSMutableDictionary *queryDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
                                             @"UserById",@"QueryType",
                                             @"Replicon.Domain.User",@"DomainType",
                                             argsArray,@"Args",
                                             loadArray,@"Load",nil];
            
            [requestArr addObject:queryDict];
        }
        
        
        
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:requestArr error:&err];
        DLog(@"Json String for projects %@",str);
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        [paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        
        [self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDictForApprovals:paramDict]];
        [self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ApprovalUserProjectsAndClients"]];
        [self setServiceDelegate:self];
        [self executeRequest];

    }
}


-(void)sendRequestToGetUserActivitiesforUserID:(NSArray *)userIdArr {
    
    if ([userIdArr count]>0) 
    {
        NSMutableArray *requestArr=[NSMutableArray arrayWithCapacity:[userIdArr count]];
        for (int i=0; i<[userIDArray count]; i++) 
        {
            NSDictionary *activityDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"Activities",@"Relationship",nil];
            NSDictionary *timeOffCodesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              @"TimeOffCodeAssignments",@"Relationship",nil];
            
            NSMutableArray *loadArray  = [NSMutableArray array];
            [loadArray addObject:activityDict];
            [loadArray addObject:timeOffCodesDict];
            
            
            NSMutableDictionary *queryDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"LoadIdentity",@"Action",
                                             @"Replicon.Domain.User",@"DomainType",
                                             [NSString stringWithFormat:@"%@", [userIdArr objectAtIndex:i]],@"Identity",
                                             loadArray,@"Load",nil];
            
            [requestArr addObject:queryDict];
        }
        
        
        
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:requestArr error:&err];
        
        //DLog(@"sendRequestToGetUserActivities::Json Str %@",str);
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        [paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        
        [self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDictForApprovals:paramDict]];
        //TODO: Need to provide service ID:DONE
        
        [self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ApprovalUserActivities"]]; // ID: 74
        [self setServiceDelegate:self];
        [self executeRequest];
    }
    

	
}

-(void)sendTimeSheetRequestToFetchSheetLevelUDFsWithPermissionSet{

		
	
	NSArray *sheetArgsArray = [NSArray arrayWithObject:ReportPeriod_SheetLevel];
	NSArray *rowArgsArray   = [NSArray arrayWithObject:TaskTimesheet_RowLevel];
	NSArray *cellArgsArray  = [NSArray arrayWithObject:TimesheetEntry_CellLevel];
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
                                             nil];
	NSMutableArray *query = [NSMutableArray array];
	
	
	
		[query addObject:sheetLevelDict];
	
		[query addObject:rowLevelDict];
	
		[query addObject:cellLevelDict];
	
	[query addObject:timeOffsLevelDict];
	//DLog(@"Query Array %@",query);
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:query error:&err];
	DLog(@"Json String to fetch UDF's for Time Sheets %@",str);

        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        [paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        
        [self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDictForApprovals:paramDict]];
        [self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ApprovalPendingTimesheetUDFs"]];
        [self setServiceDelegate:self];
        [self executeRequest];

    
    
}


-(void) approveTimesheetWithComments: (NSArray *)sheetIdentityArr comments:(NSString *)comments
{
    totalRequestsServed = 0;
	totalRequestsSent = 0;
    totalRequestsSent++;
    NSMutableArray *requestArr=[NSMutableArray arrayWithCapacity:[sheetIdentityArr count]];
    
    for (int i=0; i<[sheetIdentityArr count]; i++)
    
    {
        NSDictionary *submitOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"Approve",@"__operation",
                                             comments,@"Comment",
                                             nil];
        NSArray *operationsArray = [NSArray arrayWithObject:submitOperationDict];
        
        NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                 @"Edit",@"Action",@"True",@"ValidationAsWarnings",@"Replicon.Suite.Domain.EntryTimesheet",@"Type",
                                 [sheetIdentityArr objectAtIndex:i],@"Identity",
                                 operationsArray,@"Operations",
                                 nil];
        
        [requestArr addObject:queryDict];
        
    }


	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:requestArr error:&err];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDictForApprovals:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ApproveTimesheet"]];
	[self setServiceDelegate:self];
	[self executeRequest];
	
}


-(void) rejectTimesheetWithComments: (NSArray *)sheetIdentityArr comments:(NSString *)comments
{
    totalRequestsServed = 0;
	totalRequestsSent = 0;
    totalRequestsSent++;
    NSMutableArray *requestArr=[NSMutableArray arrayWithCapacity:[sheetIdentityArr count]];
    
    for (int i=0; i<[sheetIdentityArr count]; i++)
        
    {
        NSDictionary *submitOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"Reject",@"__operation",
                                             comments,@"Comment",
                                             nil];
        NSArray *operationsArray = [NSArray arrayWithObject:submitOperationDict];
        
        NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                 @"Edit",@"Action",@"True",@"ValidationAsWarnings",@"Replicon.Suite.Domain.EntryTimesheet",@"Type",
                                 [sheetIdentityArr objectAtIndex:i],@"Identity",
                                 operationsArray,@"Operations",
                                 nil];
        
        [requestArr addObject:queryDict];
        
    }
    
    
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:requestArr error:&err];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDictForApprovals:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"RejectTimesheet"]];
	[self setServiceDelegate:self];
	[self executeRequest];
	
}

-(void)sendRequestToLoadUser
{
    totalRequestsSent=0;
    totalRequestsServed=0;
    totalRequestsSent++;
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
    NSArray *array =nil;
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {     
        array = [NSArray arrayWithObjects:[dict objectForKey:@"userName"],nil];
    }
    else 
    {
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        if (version>=7.0)
        {
            array = [NSArray arrayWithObjects: [[NSUserDefaults standardUserDefaults] objectForKey:@"SSOLoginName"],nil];
        }
        else
        {
            array = [NSArray arrayWithObjects: [[NSUserDefaults standardUserDefaults] objectForKey:@"TempSSOLoginName"],nil];
        }

       
    }
    NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",@"UserByLoginName",@"QueryType",@"Replicon.Domain.User",@"DomainType",array,@"Args",nil];
    NSArray *arr = [NSArray arrayWithObject:dict1];
    NSError *error;
    NSString *str = [JsonWrapper writeJson:arr error:&error];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"UserByLoginName"]];
	[self setServiceDelegate: self];
	[self executeRequest];

}
-(void)sendRequestToFetchNextRecentPendingTimesheetsWithStartIndex:(NSNumber*)_startIndex withLimitCount:(NSNumber*)limitedCount withQueryHandler:(NSString *)handleIdentity withDelegate:(id)delegate
{
    totalRequestsSent=0;
    totalRequestsServed=0;
    if(handleIdentity == nil || [handleIdentity isEqualToString: @""])
	{
		//DLog(@"Error: handleIdentity is null");
		return;
	}
    	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Query",@"Action",
							 handleIdentity,@"QueryHandle",
                             limitedCount ,@"Count",
                             _startIndex, @"StartIndex",
							 nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	totalRequestsSent++;
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDictForApprovals :paramDict]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName:@"FetchNextRecentApprovalTimesheets"]];
	[self setServiceDelegate: self];
	[self executeRequest];	 

}


@end
