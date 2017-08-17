//
//  LockedInOutTimesheetService.m
//  Replicon
//
//  Created by Dipta Rakshit on 5/7/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2LockedInOutTimesheetService.h"

#import "G2RepliconServiceManager.h"
#import "RepliconAppDelegate.h"

@implementation G2LockedInOutTimesheetService

@synthesize timesheetModel;
@synthesize totalRequestsSent;
@synthesize totalRequestsServed;
//@synthesize isFromNewPopUpForTimeOff;
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




-(void)sendRequestToEditTheTimeEntryDetailsWithUserDataForLockedInOutTimesheets:(G2TimeSheetEntryObject *)_timeEntryObject
{
	DLog(@"sendRequestToEditTheTimeEntryDetailsWithUserData::::TimeSheetService");
	
	NSDate		 *entryDate				= [_timeEntryObject entryDate];
	NSString	 *sheetIdentity			= [_timeEntryObject sheetId];
	
	NSString	 *entryIdentity         = [_timeEntryObject identity];
	
	NSDictionary *entryDateDict			= [G2Util convertDateToApiDateDictionary:entryDate];
	
	NSMutableDictionary *propertiesDictionary     = [NSMutableDictionary dictionary];
    NSMutableDictionary *propertiesDictionary1     = [NSMutableDictionary dictionary]; 
	
	NSMutableDictionary *calculationModeDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      @"Replicon.TimeSheet.Domain.CalculationModeObject",@"__type",
                                                      @"CalculateDuration",@"Identity",nil];
	[propertiesDictionary1 setObject:@"SetProperties" forKey:@"__operation"];
	[propertiesDictionary1 setObject:calculationModeDictionary forKey:@"CalculationModeObject"];
	
    
	[propertiesDictionary setObject:@"SetProperties" forKey:@"__operation"];
	
	if (entryDateDict != nil && [entryDateDict isKindOfClass:[NSDictionary class]]) {
		[propertiesDictionary setObject:entryDateDict forKey:@"EntryDate"];
	}
    
	
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
    
     NSMutableDictionary *cellUDFPropertyDict = nil;
    NSArray *cellLevelUDFarray=[timesheetModel getEnabledOnlyCellLevelUDFsForGPSTracking];
    for (int i=0;  i < [cellLevelUDFarray count];  i++)
    {
        NSDictionary *udfDict = [cellLevelUDFarray objectAtIndex: i];
        NSString *moduleNameStr=nil;
        moduleNameStr=[NSString stringWithFormat:@"%@UDF%d",[udfDict objectForKey:@"moduleName"],[[udfDict objectForKey:@"fieldIndex"]intValue]+1];
        BOOL hasPermissionForUDF=FALSE;
        G2PermissionsModel *permissionsModel = [[G2PermissionsModel alloc] init];
        hasPermissionForUDF=[permissionsModel checkUserPermissionWithPermissionName: moduleNameStr];
        
        if ([[udfDict objectForKey:@"udfType"] isEqualToString:@"Text"] && [[udfDict objectForKey:@"name"] isEqualToString:@"GPSCoordinatesForPunchOut"] && hasPermissionForUDF )
        {
            RepliconAppDelegate *appDelegate=(RepliconAppDelegate *)[[UIApplication sharedApplication] delegate];
            CLLocationCoordinate2D coordinate=appDelegate.locationController.locationManager.location.coordinate;
            float longitude=coordinate.longitude;
            float latitude=coordinate.latitude;
            
            NSString *latLongStr=[NSString stringWithFormat:@"%f;%f",latitude,longitude];
           
            cellUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetCellUdfValues" forKey:@"__operation"];
            if (latLongStr!=nil && ![latLongStr isKindOfClass:[NSNull class]])
            {
                [cellUDFPropertyDict setObject:latLongStr forKey:@"GPSCoordinatesForPunchOut"];
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
    if (cellUDFPropertyDict) {
        [innerOperationsArray addObject:cellUDFPropertyDict];
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
	
	totalRequestsSent ++;
}





-(void)sendRequestToAddNewTimeEntryWithObjectForLockedInOutTimesheets:(G2TimeSheetEntryObject *)entryObject {
    
	NSString *sheetIdentity = [entryObject sheetId];
	
	NSDate *entryDate = [entryObject entryDate];
	NSDictionary *entryDateDict = [G2Util convertDateToApiDateDictionary:entryDate];
 	NSMutableDictionary *propertiesOperationDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *propertiesOperationDict1 = [NSMutableDictionary dictionary];
	
	if (entryDateDict != nil && [entryDateDict isKindOfClass:[NSDictionary class]]) {
		[propertiesOperationDict setObject:entryDateDict forKey:@"EntryDate"];
	}
	
    
	[propertiesOperationDict setObject:@"SetProperties" forKey:@"__operation"];
	
	NSDictionary *calculationModeDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"Replicon.TimeSheet.Domain.CalculationModeObject",@"__type",
										 @"CalculateDuration",@"Identity",
										 nil];
	[propertiesOperationDict1 setObject:@"SetProperties" forKey:@"__operation"];
	[propertiesOperationDict1 setObject:calculationModeDict forKey:@"CalculationModeObject"];
	
    
    NSString *inTime=[entryObject inTime];
    if (inTime != nil && ![inTime isKindOfClass:[NSNull class]]) 
    {
        NSDictionary *inTimeDict = [G2Util convertTimeToHourMinutesSecondsFormat:inTime];
        if (inTimeDict != nil && [inTimeDict isKindOfClass:[NSDictionary class]]) 
        {
            [propertiesOperationDict setObject:inTimeDict forKey:@"TimeIn"];
        }
    }
    NSMutableDictionary *cellUDFPropertyDict = nil;
    NSArray *cellLevelUDFarray=[timesheetModel getEnabledOnlyCellLevelUDFsForGPSTracking];
    for (int i=0;  i < [cellLevelUDFarray count];  i++)
    {
        NSDictionary *udfDict = [cellLevelUDFarray objectAtIndex: i];
        NSString *moduleNameStr=nil;
        moduleNameStr=[NSString stringWithFormat:@"%@UDF%d",[udfDict objectForKey:@"moduleName"],[[udfDict objectForKey:@"fieldIndex"]intValue]+1];
        BOOL hasPermissionForUDF=FALSE;
        G2PermissionsModel *permissionsModel = [[G2PermissionsModel alloc] init];
        hasPermissionForUDF=[permissionsModel checkUserPermissionWithPermissionName: moduleNameStr];
       
        if ([[udfDict objectForKey:@"udfType"] isEqualToString:@"Text"] && [[udfDict objectForKey:@"name"] isEqualToString:@"GPSCoordinatesForPunchIn"] && hasPermissionForUDF )
        {
            RepliconAppDelegate *appDelegate=(RepliconAppDelegate *)[[UIApplication sharedApplication] delegate];
            CLLocationCoordinate2D coordinate=appDelegate.locationController.locationManager.location.coordinate;
            float longitude=coordinate.longitude;
            float latitude=coordinate.latitude;
            
            
            NSString *latLongStr=[NSString stringWithFormat:@"%f;%f",latitude,longitude];
            cellUDFPropertyDict=[NSMutableDictionary dictionaryWithObject:@"SetCellUdfValues" forKey:@"__operation"];
            if (latLongStr!=nil && ![latLongStr isKindOfClass:[NSNull class]])
            {
                [cellUDFPropertyDict setObject:latLongStr forKey:@"GPSCoordinatesForPunchIn"];
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
    if (cellUDFPropertyDict) {
        [subOperationsArray addObject:cellUDFPropertyDict];
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
    totalRequestsSent ++;
}








#pragma mark -
#pragma mark Response Handler's
/*
 * This method handles response for fetching timesheets
 * Calling class self - serverDidRespondWithResponse
 */



/*
 * This method handles response for fetching timesheet with entryDate.
 *
 */

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














-(void)handleEditedTimeEntryResponse:(id)response{
	DLog(@"handleEditedTimeEntryResponse :::TimeSheetService");
	//DLog(@"Time Entry Edited Response %@",response);
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (status!=nil && [status isEqualToString:@"OK"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LOCKED_TIME_ENTRY_EDITED_NOTIFICATION object:nil]; 
                   
		
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
            
          
            
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOCKED_TIME_ENTRY_SAVED_NOTIFICATION object:nil]; 
                          
			
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














#pragma mark -
#pragma mark ServiceURL Response Handling

- (void) serverDidRespondWithResponse:(id) response
{
    NSNumber *serviceId=nil;
   
	if (response != nil) {
		serviceId=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
        
		 if ([serviceId intValue] == QueryAndCreateTimesheet_41) {
			[self handleGetTimesheetFromApiResponse : response];
             totalRequestsServed++;
		}
        
         else if ([serviceId intValue] == SaveTimeEntryForSheet_Service_Id_54) {
             [self handleSaveNewTimeEntryResponse:response];
               totalRequestsServed++;
         }
        
		else if([serviceId intValue] ==EditTimeEntry_Service_Id_56) {
			//TODO: Handle the response after the time entry edit:DONE
			[self handleEditedTimeEntryResponse:response];
              totalRequestsServed++;
		}
        
        else if ([serviceId intValue] == GetTimesheetWithDate) {
           	totalRequestsServed++;
            [self handlePunchClockGetTimesheetFromApiResponse:response];
			
		}
      
        
	}
	
	//added below condition to check if all requests are served
	DLog(@"Locked In Out TimeSheetService===> RequestsServed / Sent: %d / %d", totalRequestsServed, totalRequestsSent);
	if (totalRequestsServed == totalRequestsSent) 
    {

      [[NSNotificationCenter defaultCenter] postNotificationName:@"allLockedTimesheetRequestsServed" object:nil];
//        [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];	
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

-(void) fetchTimeSheetUSerDataForDate:(id)_delegate andDate:(NSDate *)date
{

        [self sendRequestToFetchTimeSheetByDate:date];
        totalRequestsSent++;
   
    
    
}


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
			 postNotificationName:FETCH_LOCKEDINOUT_TIMESHEET_FOR_ENTRY_DATE object:sheetIdentity];
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
    totalRequestsSent ++;
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






@end
