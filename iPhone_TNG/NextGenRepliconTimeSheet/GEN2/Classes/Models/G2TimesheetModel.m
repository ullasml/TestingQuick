//
//  TimesheetModel.m
//  Replicon
//
//  Created by enl4macbkpro on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2TimesheetModel.h"
#import "G2PermissionsModel.h"
#import "RepliconAppDelegate.h"

static NSString *timesheetsTable = @"timesheets";
static NSString *timeEntriesTable = @"time_entries";
static NSString *punchClocktimeEntriesTable = @"punchclock_time_entries";
static NSString *userDefinedFieldsTable = @"userDefinedFields";
static NSString *entryUDFSTable = @"entry_udfs";
static NSString *udfDropDownOptionsTable = @"udfDropDownOptions";
static NSString *projectTasksTable = @"project_tasks";
static NSString *bookedTimeOffTable = @"booked_time_off_entries";
static NSString *bookingsTable = @"timeOffBookings";
static NSString *mealbreaksTable = @"mealBreaks_entries";
static NSString *clientsTable = @"clients";

@implementation G2TimesheetModel

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		
	}
	return self;
}

/*This method saves the timesheets received from api to DB.
 *Calling class - TimesheetService - handleTimesheetsResponse
 */
-(void) saveTimesheetsFromApiToDB : (NSMutableArray *)responseArray {
	
	//DLog(@"In saveTimesheetsFromApiToDB method %@",responseArray);
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	 NSMutableArray *projectIdsArr=[[NSMutableArray alloc]init];
     NSNumber *decimalDuration=nil;
    
	for (int i = 0; i<[responseArray count]; i++) {
		
		NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
		NSString *approvalStatus=nil;
		NSDictionary *timesheetDict = [responseArray objectAtIndex:i];
		
		NSNumber *sheetIdentity = [timesheetDict objectForKey:@"Identity"];
		NSNumber *bankOvertime = [NSNumber numberWithBool:
								  [[[timesheetDict objectForKey:@"Properties"] objectForKey:@"BankOvertime"] boolValue]];
        NSDictionary *disclaimerAcceptedDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"DisclaimerAccepted"];
		NSDictionary *dueDateDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"DueDate"];
		NSDictionary *endDateDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"EndDate"];
		NSDictionary *startDateDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"StartDate"];
        NSDictionary *durationDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"TotalHours"];
		NSDictionary *savedOnDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"SavedOn"];
		NSDictionary *savedOnUtcDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"SavedOnUtc"];
        decimalDuration = [G2Util convertApiTimeDictToDecimal:durationDict];
        NSString *stringDuration = [G2Util convertApiTimeDictToString:durationDict];;
		NSNumber *isPaid = [NSNumber numberWithBool:
                            [[[timesheetDict objectForKey:@"Properties"] objectForKey:@"Paid"] boolValue]];
		
		NSDictionary *approvalStatusDict = [[timesheetDict objectForKey:@"Relationships"] 
											objectForKey:@"ApprovalStatus"];
		NSArray *remainingApproversArray = [[timesheetDict objectForKey:@"Relationships"]
											objectForKey:@"RemainingApprovers"];
		NSArray *filteredHistoryArray = [[timesheetDict objectForKey:@"Relationships"]
										 objectForKey:@"FilteredHistory"];
		
		approvalStatus = [G2Util getApprovalStatusBasedFromApiStatus:approvalStatusDict];
		
		//default values for offline editing status flags
		NSNumber *isModified = [NSNumber numberWithBool:FALSE];
		NSString *editStatus = @"";
		
        NSString *disclaimerAcceptedDate=nil;
        if (disclaimerAcceptedDict!=nil && ![disclaimerAcceptedDict isKindOfClass:[NSNull class]])
        {
            disclaimerAcceptedDate= [G2Util convertApiDateDictToDateString:disclaimerAcceptedDict];
        }
		NSString *dueDate = [G2Util convertApiDateDictToDateString:dueDateDict];
		NSString *endDate = [G2Util convertApiDateDictToDateString:endDateDict];
		NSString *startDate = [G2Util convertApiDateDictToDateString:startDateDict];
		NSString *savedOn = @"null";
		NSString *savedOnUtc = @"null";
		
		if(savedOnDict != nil && ![savedOnDict isKindOfClass:[NSNull class]]) {
			savedOn = [G2Util convertApiDateDictToDateString:savedOnDict];
		}
		if (savedOnUtcDict != nil && ![savedOnDict isKindOfClass:[NSNull class]]) {
			savedOnUtc = [G2Util convertApiDateDictToDateString:savedOnUtcDict];
		}
        
        if (decimalDuration != nil && ![decimalDuration isKindOfClass:[NSNull class]]
            &&[decimalDuration isKindOfClass:[NSNumber class]]) {
            [dataDictionary setObject:decimalDuration forKey:@"totalHoursDecimalFormat"];
        }
        if (stringDuration != nil && ![stringDuration isKindOfClass:[NSNull class]]
            && ![stringDuration isEqualToString:NULL_STRING]) {
            [dataDictionary setObject:stringDuration forKey:@"totalHoursFormat"];
        }
		
		[dataDictionary setObject:sheetIdentity forKey:@"identity"];
		[dataDictionary setObject:bankOvertime forKey:@"bankOvertime"];
        if (disclaimerAcceptedDate)
        {
            [dataDictionary setObject:disclaimerAcceptedDate forKey:@"disclaimerAccepted"];
        }
        else 
        {
            [dataDictionary setObject:@"[Null]" forKey:@"disclaimerAccepted"];
        }
		[dataDictionary setObject:dueDate forKey:@"dueDate"];
		[dataDictionary setObject:endDate forKey:@"endDate"];
		[dataDictionary setObject:startDate forKey:@"startDate"];
		[dataDictionary setObject:approvalStatus forKey:@"approvalStatus"];
		[dataDictionary setObject:isPaid forKey:@"isPaid"];
		[dataDictionary setObject:savedOn forKey:@"savedOn"];
		[dataDictionary setObject:savedOnUtc forKey:@"savedOnUtc"];
		[dataDictionary setObject:isModified forKey:@"isModified"];
		[dataDictionary setObject:editStatus forKey:@"editStatus"];
		//DLog(@"Saved a timesheet to DB");
		
		BOOL approversRemaining = [G2Util showUnsubmitButtonForSheet:filteredHistoryArray sheetStatus:approvalStatus remainingApprovers:remainingApproversArray];
                
		[dataDictionary setObject:[NSNumber numberWithBool:approversRemaining] forKey:@"approversRemaining"];
		
		//Add the sheet to list of unsubmitted sheets to show resubmit button.
		[G2Util addToUnsubmittedSheets:filteredHistoryArray sheetStatus:approvalStatus 
							 sheetId:[NSString stringWithFormat:@"%@",sheetIdentity] module: UNSUBMITTED_TIME_SHEETS];
        
		NSArray *timeSheetsArr = [self getTimeSheetInfoForSheetIdentity:sheetIdentity];
		if ([timeSheetsArr count]>0) {
			
			NSString *whereString=[NSString stringWithFormat:@"identity='%@'",sheetIdentity];
			[myDB updateTable:timesheetsTable data:dataDictionary where:whereString intoDatabase:@""];
			
		}else {
			
			[myDB insertIntoTable:timesheetsTable data:dataDictionary intoDatabase:@""];
		}
		
        
        
		
		//Delete existing Entries for Sheet.
		NSString *entriesDeleteString = [NSString stringWithFormat:@"sheetIdentity = '%@'",sheetIdentity];
		[myDB deleteFromTable:timeEntriesTable where:entriesDeleteString inDatabase:@""];
		//Save Timeentries for Timesheet
		
		NSArray *timeEntriesArray = [[timesheetDict objectForKey:@"Relationships"] objectForKey:@"TimeEntries"];
		
        if (![timeEntriesArray isKindOfClass:[NSNull class]] && [timeEntriesArray count] > 0) {
            
            [self saveTimeEntriesForSheetFromApiToDB:timeEntriesArray :sheetIdentity];
            for (NSDictionary *timeEntryDict in timeEntriesArray)
            {
                NSDictionary *projectDict = nil;
                NSDictionary *clientDict = [[timeEntryDict objectForKey:@"Relationships"] objectForKey:@"Client"];
                NSDictionary *taskDict = [[timeEntryDict objectForKey:@"Relationships"] objectForKey:@"Task"];
                if (![taskDict isKindOfClass:[NSNull class]]) {
                    projectDict = [[taskDict objectForKey:@"Relationships"] objectForKey:@"Project"];
                }
                
                if ([clientDict isKindOfClass:[NSNull class]] && projectDict != nil) {
                    NSString *projectIdentity = [projectDict objectForKey:@"Identity"];
                    [projectIdsArr addObject:projectIdentity];
                    
                }
                else if (projectDict != nil && [projectDict isKindOfClass:[NSDictionary class]]) {
                    NSString *projectIdentity = [projectDict objectForKey:@"Identity"];
                   [projectIdsArr addObject:projectIdentity];
                }
            }
        }
		NSArray *timeOffsArray = [[timesheetDict objectForKey:@"Relationships"] objectForKey:@"TimeOffEntries"];
		if (![timeOffsArray isKindOfClass:[NSNull class]] && [timeOffsArray count] > 0) {
			
			[self saveTimeOffEntriesForSheetFromApiToDB:timeOffsArray :sheetIdentity];
		}
        
        NSArray *breakRuleViolationsArray = [[timesheetDict objectForKey:@"Relationships"] objectForKey:@"BreakRuleViolations"];
//        if (![breakRuleViolationsArray isKindOfClass:[NSNull class]] && [breakRuleViolationsArray count] > 0) {
			
			[self savebreakRuleViolationsEntriesForSheetFromApiToDB:breakRuleViolationsArray :sheetIdentity];
//		}
        
	}
    
    if (projectIdsArr!=nil)
    {
        if ([projectIdsArr count]>0)
        {
            [[G2RepliconServiceManager timesheetService] sendRequestTogetTimesheetProjectswithProjectIds:projectIdsArr];
            //totalRequestsSent++;
        }
    }

}




/*This method saves the timesheets received from api to DB for Punch Clock.
 *Calling class - TimesheetService - handleTimesheetsResponse
 */
-(void) saveTimesheetsFromApiToDBForPunchClock : (NSMutableArray *)responseArray {
	
	//DLog(@"In saveTimesheetsFromApiToDB method %@",responseArray);
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	for (int i = 0; i<[responseArray count]; i++) {
		
        
		NSDictionary *timesheetDict = [responseArray objectAtIndex:i];
		
		NSNumber *sheetIdentity = [timesheetDict objectForKey:@"Identity"];
        
        
        NSDictionary *approvalStatusDict = [[timesheetDict objectForKey:@"Relationships"] 
											objectForKey:@"ApprovalStatus"];
        
        NSString *approvalStatus = [G2Util getApprovalStatusBasedFromApiStatus:approvalStatusDict];
        
        [[NSUserDefaults standardUserDefaults] setObject:approvalStatus forKey:PUNCHCLOCK_NOENTRIES_APPROVAL_STATUS];
        [[NSUserDefaults standardUserDefaults] synchronize];
		
		//Delete existing Entries for Sheet.
		NSString *entriesDeleteString = [NSString stringWithFormat:@"sheetIdentity = '%@'",sheetIdentity];
		[myDB deleteFromTable:punchClocktimeEntriesTable where:entriesDeleteString inDatabase:@""];
		//Save Timeentries for Timesheet
		
        NSDictionary *dict1=[timesheetDict objectForKey:@"Relationships"];
        NSMutableArray *arr1=[dict1 objectForKey:@"TimeEntries"];
        
		NSArray *timeEntriesArray = arr1;
		
        if (![timeEntriesArray isKindOfClass:[NSNull class]] && [timeEntriesArray count] > 0) {
            
            [self saveTimeEntriesForSheetFromApiToDBFForPunchClock:timeEntriesArray andSheetIdentity:sheetIdentity andStatus:approvalStatus];
        }
		
	}
}


-(NSMutableArray*)getTimeSheetInfoForSheetIdentity:(id)sheetIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSString *whereString=[NSString stringWithFormat:@"identity='%@'",sheetIdentity];
	NSMutableArray *timeSheetsArr = [myDB select:@"*" from:timesheetsTable where:whereString intoDatabase:@""];
	if ([timeSheetsArr count]!=0) {
		return timeSheetsArr;
	}
	return nil;
}


-(void) saveTimeEntriesForSheetFromApiToDBFForPunchClock:(NSArray *)timeEntriesArray andSheetIdentity:(NSNumber *)sheetIdentity andStatus:(NSString *)approvalStatus{
	
	//DLog(@"In saveTimeEntriesForSheetFromApiToDB method");
	//DLog(@"Time Entries ::::::::: %@",timeEntriesArray);
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	for (NSDictionary *timeEntryDict in timeEntriesArray) {
		NSMutableDictionary *entryDict = [NSMutableDictionary dictionary];
		NSString *entryIdentity = [timeEntryDict objectForKey:@"Identity"];
        
        
        
		NSDictionary *durationDict = [[timeEntryDict objectForKey:@"Properties"] objectForKey:@"Duration"];
		NSDictionary *entryDateDict = [[timeEntryDict objectForKey:@"Properties"] objectForKey:@"EntryDate"];
        NSDictionary *timeInDict = [[timeEntryDict objectForKey:@"Properties"] objectForKey:@"TimeIn"];
        NSDictionary *timeOutDict = [[timeEntryDict objectForKey:@"Properties"] objectForKey:@"TimeOut"];
        
		
        
		
		NSNumber *decimalDuration = [G2Util convertApiTimeDictToDecimal:durationDict];
		NSString *stringDuration = [G2Util convertApiTimeDictToString:durationDict];
		NSString *entryDateString = [G2Util convertApiDateDictToDateString:entryDateDict];
        NSString *timeInStr =nil;
        NSString *timeOutStr=nil;
        if (timeInDict!=nil && ![timeInDict isKindOfClass:[NSNull class] ]) {
            timeInStr =  [G2Util convertApiTimeDictTo12HourTimeString:timeInDict];
        }
        
        if (timeOutDict!=nil && ![timeOutDict isKindOfClass:[NSNull class]]) {
            timeOutStr =  [G2Util convertApiTimeDictTo12HourTimeString:timeOutDict];
        }
        
        if (timeInStr != nil && ![timeInStr isKindOfClass:[NSNull class]]
			&&[timeInStr isKindOfClass:[NSString class]]) {
			[entryDict setObject:timeInStr forKey:@"time_in"];
		}
		if (timeOutStr != nil && ![timeOutStr isKindOfClass:[NSNull class]]
			&&[timeOutStr isKindOfClass:[NSString class]]) {
			[entryDict setObject:timeOutStr forKey:@"time_out"];
		}		
		if (decimalDuration != nil && ![decimalDuration isKindOfClass:[NSNull class]]
			&&[decimalDuration isKindOfClass:[NSNumber class]]) {
			[entryDict setObject:decimalDuration forKey:@"durationDecimalFormat"];
		}
		if (stringDuration != nil && ![stringDuration isKindOfClass:[NSNull class]]
			&& ![stringDuration isEqualToString:NULL_STRING]) {
			[entryDict setObject:stringDuration forKey:@"durationHourFormat"];
		}
		if (entryDateString != nil && ![entryDateString isKindOfClass:[NSNull class]]
			&& ![entryDateString isEqualToString:NULL_STRING]) {
			[entryDict setObject:entryDateString forKey:@"entryDate"];
		}
		if (entryIdentity != nil && ![entryIdentity isKindOfClass:[NSNull class]]
			&& ![entryIdentity isEqualToString:NULL_STRING]) {
			[entryDict setObject:entryIdentity forKey:@"identity"];
		}
		if (sheetIdentity != nil && ![sheetIdentity isKindOfClass:[NSNull class]]
			&& ![entryDateString isEqualToString:NULL_STRING]) {
			[entryDict setObject:sheetIdentity forKey:@"sheetIdentity"];
		}
        if (approvalStatus != nil && ![approvalStatus isKindOfClass:[NSNull class]]
			&& ![approvalStatus isEqualToString:NULL_STRING]) {
			[entryDict setObject:approvalStatus forKey:@"approvalStatus"];
		}
		
		

			
			[myDB insertIntoTable:punchClocktimeEntriesTable data:entryDict intoDatabase:@""];
		
	}
}


-(void) saveTimeEntriesForSheetFromApiToDB:(NSArray *)timeEntriesArray :(NSNumber *)sheetIdentity {
	
	//DLog(@"In saveTimeEntriesForSheetFromApiToDB method");
	//DLog(@"Time Entries ::::::::: %@",timeEntriesArray);
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
   
    
	for (NSDictionary *timeEntryDict in timeEntriesArray) {
		NSString *activityIdentity = nil;
		NSString *activityName = nil;
		NSString *clientIdentity = nil;
		NSString *clientName = nil;
		NSString *projectIdentity = nil;
		NSString *projectName = nil;
		NSString *taskIdentity = nil;
		NSString *taskName = nil;
		NSString *billingIdentity = nil;
		NSString *billingName = nil;
		NSNumber *isModified = [NSNumber numberWithInt:0];
		NSString *editStatus = @"";
		NSMutableDictionary *entryDict = [NSMutableDictionary dictionary];
		NSString *entryIdentity = [timeEntryDict objectForKey:@"Identity"];
        
        NSDictionary *userRowDefinedFieldsDict = [timeEntryDict objectForKey:@"RowUserDefinedFields"];
        NSDictionary *userCellDefinedFieldsDict = [timeEntryDict objectForKey:@"CellUserDefinedFields"];
        
        //DE4274//Juhi
        NSString *deleteWhereString = [NSString stringWithFormat:@"entry_id = '%@' ",entryIdentity];
        [myDB deleteFromTable:entryUDFSTable where:deleteWhereString inDatabase:@""];
        
        //Save SheetLevel Udfs to DB
		if (userRowDefinedFieldsDict != nil && ![userRowDefinedFieldsDict isKindOfClass:[NSNull class]]) {
			//DLog(@"user  row defined fields present ");
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterNoStyle];
            NSNumber * entryIDNumber = [f numberFromString:entryIdentity];
            
			[self savetimesheetSheetUdfsFromApiToDB:userRowDefinedFieldsDict withSheetIdentity:entryIDNumber andModuleName:TaskTimesheet_RowLevel];
		}
        if (userCellDefinedFieldsDict != nil && ![userCellDefinedFieldsDict isKindOfClass:[NSNull class]]) {
			//DLog(@"user  cell defined fields present ");
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterNoStyle];
            NSNumber * entryIDNumber = [f numberFromString:entryIdentity];
            
			[self savetimesheetSheetUdfsFromApiToDB:userCellDefinedFieldsDict withSheetIdentity:entryIDNumber andModuleName:TimesheetEntry_CellLevel];
		}
        
		NSString *comments = [[timeEntryDict objectForKey:@"Properties"] objectForKey:@"Comments"];
		NSDictionary *durationDict = [[timeEntryDict objectForKey:@"Properties"] objectForKey:@"Duration"];
		NSDictionary *entryDateDict = [[timeEntryDict objectForKey:@"Properties"] objectForKey:@"EntryDate"];
        NSDictionary *timeInDict = [[timeEntryDict objectForKey:@"Properties"] objectForKey:@"TimeIn"];
        NSDictionary *timeOutDict = [[timeEntryDict objectForKey:@"Properties"] objectForKey:@"TimeOut"];
		NSDictionary *activityDict = [[timeEntryDict objectForKey:@"Relationships"] objectForKey:@"Activity"];
		NSDictionary *billableDict = [[timeEntryDict objectForKey:@"Relationships"] objectForKey:@"Billable"];
		NSDictionary *projectRoleDict = [[timeEntryDict objectForKey:@"Relationships"] objectForKey:@"ProjectRole"];
		NSDictionary *billingDepartmentDict = [[timeEntryDict objectForKey:@"Relationships"] objectForKey:@"BillingRateDepartment"];
		NSDictionary *clientDict = [[timeEntryDict objectForKey:@"Relationships"] objectForKey:@"Client"];
		NSDictionary *taskDict = [[timeEntryDict objectForKey:@"Relationships"] objectForKey:@"Task"];
		NSDictionary *projectDict = nil;
		NSDictionary *parentTaskDict = nil;
        NSString *role_billing_Identity=nil;
		
		//NSNumber *levelCount = nil;
		
		if (![taskDict isKindOfClass:[NSNull class]]) {
			taskIdentity = [taskDict objectForKey:@"Identity"];
			taskName = [[taskDict objectForKey:@"Properties"] objectForKey:@"Name"];
			projectDict = [[taskDict objectForKey:@"Relationships"] objectForKey:@"Project"];
		}
		if ([clientDict isKindOfClass:[NSNull class]] && projectDict != nil) {
			projectIdentity = [projectDict objectForKey:@"Identity"];
			projectName = [[projectDict objectForKey:@"Properties"] objectForKey:@"Name"];
			NSArray *projectClientsArray = [[projectDict objectForKey:@"Relationships"] objectForKey:@"ProjectClients"];
			if (projectClientsArray != nil && [projectClientsArray count] > 0) {
				clientDict = [[[projectClientsArray objectAtIndex:0] objectForKey:@"Relationships"] objectForKey:@"Client"];
			}
		}
		else if (projectDict != nil && [projectDict isKindOfClass:[NSDictionary class]]) {
			projectIdentity = [projectDict objectForKey:@"Identity"];
			projectName = [[projectDict objectForKey:@"Properties"] objectForKey:@"Name"];
		}
		if (![activityDict isKindOfClass:[NSNull class]]) {
			activityIdentity = [activityDict objectForKey:@"Identity"];
			activityName = [[activityDict objectForKey:@"Properties"] objectForKey:@"Name"];
		}
		if (![clientDict isKindOfClass:[NSNull class]]) {
			clientIdentity = [clientDict objectForKey:@"Identity"];
			clientName = [[clientDict objectForKey:@"Properties"] objectForKey:@"Name"];
		}
		
        if (projectRoleDict != nil && ![projectRoleDict isKindOfClass:[NSNull class]]) {
			NSString *projectRoleName = [[projectRoleDict objectForKey:@"Properties"] objectForKey:@"Name"];
			billingName = projectRoleName;
			billingIdentity = billingName;
            //billingIdentity = [projectRoleDict objectForKey:@"Identity"];
            role_billing_Identity=[projectRoleDict objectForKey:@"Identity"];
			
		}
		else if (billingDepartmentDict != nil && ![billingDepartmentDict isKindOfClass:[NSNull class]]) {
			NSString *departmentName = [[billingDepartmentDict objectForKey:@"Properties"] objectForKey:@"Name"];
			billingName = departmentName;
		    billingIdentity = departmentName;
            //billingIdentity = [billingDepartmentDict  objectForKey:@"Identity"];
            role_billing_Identity=[billingDepartmentDict  objectForKey:@"Identity"];	;
		}
		else {
			if (![billableDict isKindOfClass:[NSNull class]]){
				billingIdentity = [billableDict objectForKey:@"Identity"];
				billingName = [[billableDict objectForKey:@"Properties"] objectForKey:@"Name"];
			}
		}
		
		NSNumber *decimalDuration = [G2Util convertApiTimeDictToDecimal:durationDict];
		NSString *stringDuration = [G2Util convertApiTimeDictToString:durationDict];
		NSString *entryDateString = [G2Util convertApiDateDictToDateString:entryDateDict];
        NSString *timeInStr =nil;
        NSString *timeOutStr=nil;
        if (timeInDict!=nil && ![timeInDict isKindOfClass:[NSNull class] ]) {
            timeInStr =  [G2Util convertApiTimeDictTo12HourTimeString:timeInDict];
        }
        
        if (timeOutDict!=nil && ![timeOutDict isKindOfClass:[NSNull class]]) {
            timeOutStr =  [G2Util convertApiTimeDictTo12HourTimeString:timeOutDict];
        }
        
        if (timeInStr != nil && ![timeInStr isKindOfClass:[NSNull class]]
			&&[timeInStr isKindOfClass:[NSString class]]) {
			[entryDict setObject:timeInStr forKey:@"time_in"];
		}
		if (timeOutStr != nil && ![timeOutStr isKindOfClass:[NSNull class]]
			&&[timeOutStr isKindOfClass:[NSString class]]) {
			[entryDict setObject:timeOutStr forKey:@"time_out"];
		}		
		if (decimalDuration != nil && ![decimalDuration isKindOfClass:[NSNull class]]
			&&[decimalDuration isKindOfClass:[NSNumber class]]) {
			[entryDict setObject:decimalDuration forKey:@"durationDecimalFormat"];
		}
		if (stringDuration != nil && ![stringDuration isKindOfClass:[NSNull class]]
			&& ![stringDuration isEqualToString:NULL_STRING]) {
			[entryDict setObject:stringDuration forKey:@"durationHourFormat"];
		}
		if (entryDateString != nil && ![entryDateString isKindOfClass:[NSNull class]]
			&& ![entryDateString isEqualToString:NULL_STRING]) {
			[entryDict setObject:entryDateString forKey:@"entryDate"];
		}
		if (entryIdentity != nil && ![entryIdentity isKindOfClass:[NSNull class]]
			&& ![entryIdentity isEqualToString:NULL_STRING]) {
			[entryDict setObject:entryIdentity forKey:@"identity"];
		}
		if (sheetIdentity != nil && ![sheetIdentity isKindOfClass:[NSNull class]]
			&& ![entryDateString isEqualToString:NULL_STRING]) {
			[entryDict setObject:sheetIdentity forKey:@"sheetIdentity"];
		}
		if (clientIdentity != nil && ![clientIdentity isKindOfClass:[NSNull class]]
			&& ![entryDateString isEqualToString:NULL_STRING]) {
			[entryDict setObject:clientIdentity forKey:@"clientIdentity"];
		}
		if (clientName != nil && ![clientName isKindOfClass:[NSNull class]]
			&& ![clientName isEqualToString:NULL_STRING]) {
			[entryDict setObject:clientName forKey:@"clientName"];
		}
		if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]]
			&& ![projectIdentity isEqualToString:NULL_STRING]) {
			[entryDict setObject:projectIdentity forKey:@"projectIdentity"];
		}
		if (projectName != nil && ![projectName isKindOfClass:[NSNull class]]
			&& ![projectName isEqualToString:NULL_STRING]) {
			[entryDict setObject:projectName forKey:@"projectName"];
		}
		
		/*if (taskName != nil && ![taskName isKindOfClass:[NSNull class]]
		 && ![taskName isEqualToString:NULL_STRING]) {
		 [entryDict setObject:taskName forKey:@"taskName"];
		 }*///Commented & Added below code
		
		if (taskDict != nil && [taskDict isKindOfClass:[NSDictionary class]]) {
            
			NSDictionary *taskRelationDict = [taskDict objectForKey:@"Relationships"];
			if (taskRelationDict != nil && [taskRelationDict isKindOfClass:[NSDictionary class]]) {
				parentTaskDict = [taskRelationDict objectForKey:@"ParentTask"];
			}
			if (parentTaskDict != nil && ![parentTaskDict isKindOfClass:[NSNull class]]) {
				if (taskIdentity != nil && ![taskIdentity isKindOfClass:[NSNull class]]
					&& ![taskIdentity isEqualToString:NULL_STRING]) {
					
					[self saveTaskForTimeEntryWithProject:taskDict withProject:projectIdentity];
					[entryDict setObject:taskIdentity forKey:@"taskIdentity"];
				}
				if (taskName != nil && ![taskName isKindOfClass:[NSNull class]]
                    && ![taskName isEqualToString:NULL_STRING]) {
                    //if (![projectName isEqualToString:taskName]) {
                    [entryDict setObject:taskName forKey:@"taskName"];
                    //}	//Fix for DE3097//Juhi
				}
			}
		}//Added
        
		if (billingIdentity != nil && ![billingIdentity isKindOfClass:[NSNull class]]
			&& ![billingIdentity isEqualToString:NULL_STRING]) 
        {
			[entryDict setObject:billingIdentity forKey:@"billingIdentity"];
		}
		if (billingName != nil && ![billingName isKindOfClass:[NSNull class]]
			&& ![billingName isEqualToString:NULL_STRING]) {
			[entryDict setObject:billingName forKey:@"billingName"];
		}
		if (activityIdentity != nil && ![activityIdentity isKindOfClass:[NSNull class]]
			&& ![activityIdentity isEqualToString:NULL_STRING]) {
			[entryDict setObject:activityIdentity forKey:@"activityIdentity"];
		}
		if (activityName != nil && ![activityName isKindOfClass:[NSNull class]]
			&& ![activityName isEqualToString:NULL_STRING]) {
			[entryDict setObject:activityName forKey:@"activityName"];
		}
		if (comments != nil && ![comments isKindOfClass:[NSNull class]]
			&& ![comments isEqualToString:NULL_STRING]) {
			[entryDict setObject:comments forKey:@"comments"];
		}
		if (isModified != nil && ![isModified isKindOfClass:[NSNull class]]) {
			[entryDict setObject:isModified forKey:@"isModified"];
		}
		if (editStatus != nil && ![editStatus isKindOfClass:[NSNull class]]) {
			[entryDict setObject:editStatus forKey:@"editStatus"];
		}
		
		[entryDict setObject:TIMESHEET_TIMEENTRY_TYPE forKey:@"entryType"];
		//DLog(@"Dictionary sent to save:::::: %@",entryDict);
		
		//DLog(@"Save time entry details:::::::TimeSheetModel==========>  %@",entryDict);
		
		NSString *sheetId = [NSString stringWithFormat:@"%@",sheetIdentity];
		
		NSMutableArray *timeEntriesArr = [self getTimeEntryForSheetWithSheetIdentity:entryIdentity :sheetId];
		
        if (role_billing_Identity) {
            [entryDict setObject:role_billing_Identity forKey:@"role_billing_Identity"];
        }  
        
        RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        if (timeEntriesArr != nil && [timeEntriesArr  count]>0) {
             NSString *whereString=[NSString stringWithFormat:@"identity='%@'",entryIdentity];

            if (appdelegate.isInOutTimesheet) {
                if (([entryDict objectForKey:@"time_in"]!=nil && ![[entryDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"time_out"]!=nil && ![[entryDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"durationHourFormat"] !=nil && ![[entryDict objectForKey:@"durationHourFormat"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"durationHourFormat"] isEqualToString:@"0:0"] )  || ([entryDict objectForKey:@"comments"]!=nil && ![[entryDict objectForKey:@"comments"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"comments"] isEqualToString:@""] ) ) 
                {
                    [myDB updateTable:timeEntriesTable data:entryDict where:whereString intoDatabase:@""];
                }
                else
                {
                    [myDB deleteFromTable:timeEntriesTable where:whereString inDatabase:@""];
                }

            }
            else
            {
                 [myDB updateTable:timeEntriesTable data:entryDict where:whereString intoDatabase:@""];
            }
            			
		}else {
            if (appdelegate.isInOutTimesheet) {
                if (([entryDict objectForKey:@"time_in"]!=nil && ![[entryDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"time_out"]!=nil && ![[entryDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"durationHourFormat"] !=nil && ![[entryDict objectForKey:@"durationHourFormat"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"durationHourFormat"] isEqualToString:@"0:0"] )  || ([entryDict objectForKey:@"comments"]!=nil && ![[entryDict objectForKey:@"comments"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"comments"] isEqualToString:@""] ) ) 
                {
                    [myDB insertIntoTable:timeEntriesTable data:entryDict intoDatabase:@""];
                }

            }
            else
            {
                [myDB insertIntoTable:timeEntriesTable data:entryDict intoDatabase:@""];
            }
                      
			
		}
	}
    
    
    
}

-(void) saveTimeOffEntriesForSheetFromApiToDB: timeOffsArray :sheetIdentity {
	
	DLog(@"In saveTimeOffEntriesForSheetFromApiToDB method");
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	for (NSDictionary *timeOffDict in timeOffsArray) {
		NSString *identity = [timeOffDict objectForKey:@"Identity"];
		NSDictionary *propertiesDict = [timeOffDict objectForKey:@"Properties"];
		NSString *comments = [propertiesDict objectForKey:@"Comments"];
		NSDictionary *durationDict = [propertiesDict objectForKey:@"Duration"];
		NSDictionary *entryDateDict = [propertiesDict objectForKey:@"EntryDate"];
		NSDictionary *timeOffCodeDict = [[timeOffDict objectForKey:@"Relationships"] objectForKey:@"TimeOffCode"];
		NSString *timeOffCodeIdentity = @"";
		NSString *timeOffCodeName = @"";
		if (timeOffCodeDict != nil && ![timeOffCodeDict isKindOfClass:[NSNull class]]) {
			timeOffCodeIdentity = [timeOffCodeDict objectForKey:@"Identity"];
			timeOffCodeName = [[timeOffCodeDict objectForKey:@"Properties"] objectForKey:@"Name"];
            
        }
        NSDictionary *userDefinedFieldsDict = [timeOffDict objectForKey:@"UserDefinedFields"];
        
        NSString *deleteWhereString = [NSString stringWithFormat:@"entry_id = '%@' ",identity];
        [myDB deleteFromTable:entryUDFSTable where:deleteWhereString inDatabase:@""];
        
        if (userDefinedFieldsDict != nil && ![userDefinedFieldsDict isKindOfClass:[NSNull class]]) {
            //DLog(@"user  row defined fields present ");
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterNoStyle];
            NSNumber * entryIDNumber = [f numberFromString:identity];
           
            [self savetimesheetSheetUdfsFromApiToDB:userDefinedFieldsDict withSheetIdentity:entryIDNumber andModuleName:TimeOffs_SheetLevel];
        }

		
		NSNumber *decimalDuration = [G2Util convertApiTimeDictToDecimal:durationDict];
		NSString *stringDuration = [G2Util convertApiTimeDictToString:durationDict];
		NSString *entryDateString = [G2Util convertApiDateDictToDateString:entryDateDict];
		NSNumber *isModified = [NSNumber numberWithInt:0];
		NSString *editStatus = @"";
		
		if ([comments isKindOfClass:[NSNull class]]) {
			comments = @"";
		}
		
		NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
								  identity,@"identity",
								  sheetIdentity,@"sheetIdentity",
								  entryDateString,@"entryDate",
								  stringDuration,@"durationHourFormat",
								  decimalDuration,@"durationDecimalFormat",
								  comments,@"comments",
								  TIMESHEET_TIMEOFF_TYPE,@"entryType",
								  timeOffCodeIdentity,@"timeOffIdentity",
								  timeOffCodeName,@"timeOffTypeName",
								  isModified,@"isModified",
								  editStatus,@"editStatus",
								  nil];
		
		NSMutableArray *timeOffEntriesArr = [self getTimeOffEntryWithEntryIdentityForSheetWithSheetIdentity:identity :sheetIdentity];
        
        RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                       
		if (timeOffEntriesArr != nil && [timeOffEntriesArr  count]>0) {
             NSString *whereString=[NSString stringWithFormat:@"identity='%@'",identity];
            if (appdelegate.isInOutTimesheet) {
                if (([dataDict objectForKey:@"time_in"]!=nil && ![[dataDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) || ([dataDict objectForKey:@"time_out"]!=nil && ![[dataDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) || ([dataDict objectForKey:@"durationHourFormat"] !=nil && ![[dataDict objectForKey:@"durationHourFormat"] isKindOfClass:[NSNull class]] && ![[dataDict objectForKey:@"durationHourFormat"] isEqualToString:@"0:0"] )  || ([dataDict objectForKey:@"comments"]!=nil && ![[dataDict objectForKey:@"comments"] isKindOfClass:[NSNull class]] && ![[dataDict objectForKey:@"comments"] isEqualToString:@""] ) ) 
                {
                    
                    [myDB updateTable:timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                }
                else
                {
                    [myDB deleteFromTable:timeEntriesTable where:whereString inDatabase:@""];
                }

            }
            else
            {
                [myDB updateTable:timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
            }

			
		}else 
        {
              if (appdelegate.isInOutTimesheet) {
                  if (([dataDict objectForKey:@"time_in"]!=nil && ![[dataDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) || ([dataDict objectForKey:@"time_out"]!=nil && ![[dataDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) || ([dataDict objectForKey:@"durationHourFormat"] !=nil && ![[dataDict objectForKey:@"durationHourFormat"] isKindOfClass:[NSNull class]] && ![[dataDict objectForKey:@"durationHourFormat"] isEqualToString:@"0:0"] )  || ([dataDict objectForKey:@"comments"]!=nil && ![[dataDict objectForKey:@"comments"] isKindOfClass:[NSNull class]] && ![[dataDict objectForKey:@"comments"] isEqualToString:@""] ) ) 
                  {
                       [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
                  }
              }
            else
            {
                [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
            }
            			
		}		
	}
}

-(void) savebreakRuleViolationsEntriesForSheetFromApiToDB:(NSArray *) breakRuleViolationsArray : (NSNumber *)sheetIdentity {
	
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
    NSString *deleteWhereString = [NSString stringWithFormat:@"sheetIdentity = '%@' ",sheetIdentity];
    [myDB deleteFromTable:mealbreaksTable where:deleteWhereString inDatabase:@""];
    
	
	for (NSDictionary *breakRuleViolationsDict in breakRuleViolationsArray) 
    {
		NSString *parentIdentity = [breakRuleViolationsDict objectForKey:@"Identity"];
		NSDictionary *propertiesDict = [breakRuleViolationsDict objectForKey:@"Properties"];
		NSDictionary *violationDateDict = [propertiesDict objectForKey:@"ViolationDate"];
        NSString *violationDateString = [G2Util convertApiDateDictToDateString:violationDateDict];
		NSArray *breakRuleViolationEntriesArray = [[breakRuleViolationsDict objectForKey:@"Relationships"] objectForKey:@"BreakRuleViolationEntries"];
        NSString *identity =nil;
        NSString *text = nil;
        NSString *languageISOName = nil;
        NSString *languageName = nil;
        NSString *typeIdentity = nil;
        
       
        
        for (NSDictionary *breakRuleViolationsEntriesDict in breakRuleViolationEntriesArray) 
        {
            identity = [breakRuleViolationsEntriesDict objectForKey:@"Identity"];
            NSDictionary *propertiesEntriesDict = [breakRuleViolationsEntriesDict objectForKey:@"Properties"];
            text=[propertiesEntriesDict objectForKey:@"Text"];
           languageISOName=[[[[breakRuleViolationsEntriesDict objectForKey:@"Relationships"] objectForKey:@"Language"] objectForKey:@"Properties"]objectForKey:@"ISOName"];
          languageName=[[[[breakRuleViolationsEntriesDict objectForKey:@"Relationships"] objectForKey:@"Language"] objectForKey:@"Properties"]objectForKey:@"Name"];
            NSDictionary *breakRuleViolationTypesDict = [[breakRuleViolationsDict objectForKey:@"Relationships"] objectForKey:@"BreakRuleViolationType"];
            typeIdentity = [breakRuleViolationTypesDict objectForKey:@"Identity"];
            
            
            
            
            NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      identity,@"identity",
                                      text,@"text",
                                      languageISOName,@"ISOName",
                                      languageName,@"languageName",
                                      typeIdentity,@"identityType",
                                      parentIdentity,@"parentIdentity",
                                      sheetIdentity,@"sheetIdentity",
                                      violationDateString,@"violationDate",
                                      
                                      nil];
            
            
            
            
            
            
            [myDB insertIntoTable:mealbreaksTable data:dataDict intoDatabase:@""];


        }
        
            
            
			
	}
}

-(void) updateTimesheetApprovalStatusFromAPIToDB: (NSDictionary *)timeSheetDict {
	
	DLog(@"In saveTimeOffEntriesForSheetFromApiToDB method");
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	if (timeSheetDict != nil && [timeSheetDict isKindOfClass:[NSDictionary class]]) {
		
		NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
		NSString *sheetIdentity = [timeSheetDict objectForKey:@"Identity"];
		[dataDict setObject:sheetIdentity forKey:@"identity"];
        
        NSDictionary *disclaimerAcceptedDict = [[timeSheetDict objectForKey:@"Properties"] objectForKey:@"DisclaimerAccepted"];
        NSString *disclaimerAcceptedDate=nil;
        if (disclaimerAcceptedDict!=nil && ![disclaimerAcceptedDict isKindOfClass:[NSNull class]])
        {
            disclaimerAcceptedDate= [G2Util convertApiDateDictToDateString:disclaimerAcceptedDict];
        }
        
        if (disclaimerAcceptedDate)
        {
            [dataDict setObject:disclaimerAcceptedDate forKey:@"disclaimerAccepted"];
        }
        else
        {
            [dataDict setObject:@"[Null]" forKey:@"disclaimerAccepted"];
        }

        
		
		NSDictionary *relationsDict = [timeSheetDict objectForKey:@"Relationships"];
		if (relationsDict != nil && [relationsDict count] > 0) {
			NSDictionary *approvalStatusDict = [relationsDict objectForKey:@"ApprovalStatus"];
			NSString *status = [G2Util getApprovalStatusBasedFromApiStatus:approvalStatusDict];
			[dataDict setObject:status forKey:@"approvalStatus"];
            
            NSArray *remainingApproversArray = [relationsDict objectForKey:@"RemainingApprovers"];
            NSArray *filteredHistoryArray = [relationsDict objectForKey:@"FilteredHistory"];
            BOOL approversRemaining = [G2Util showUnsubmitButtonForSheet:filteredHistoryArray sheetStatus:status remainingApprovers:remainingApproversArray];
            [dataDict setObject:[NSNumber numberWithBool:approversRemaining] forKey:@"approversRemaining"];
		}
		NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",sheetIdentity];
		[myDB updateTable:timesheetsTable data:dataDict where:whereString intoDatabase:@""];
	}
}

-(void) updateTimesheetDisclaimerStatusFromAPIToDB: (NSDictionary *)timeSheetDict {
	
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	if (timeSheetDict != nil && [timeSheetDict isKindOfClass:[NSDictionary class]]) {
		
		NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
		NSString *sheetIdentity = [timeSheetDict objectForKey:@"Identity"];
		[dataDict setObject:sheetIdentity forKey:@"identity"];
		
        NSDictionary *disclaimerAcceptedDict = [[timeSheetDict objectForKey:@"Properties"] objectForKey:@"DisclaimerAccepted"];
        NSString *disclaimerAcceptedDate=nil;
        if (disclaimerAcceptedDict!=nil && ![disclaimerAcceptedDict isKindOfClass:[NSNull class]])
        {
            disclaimerAcceptedDate= [G2Util convertApiDateDictToDateString:disclaimerAcceptedDict];
        }
        
        if (disclaimerAcceptedDate)
        {
            [dataDict setObject:disclaimerAcceptedDate forKey:@"disclaimerAccepted"];
        }
        else
        {
            [dataDict setObject:@"[Null]" forKey:@"disclaimerAccepted"];
        }
        
        NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",sheetIdentity];
		[myDB updateTable:timesheetsTable data:dataDict where:whereString intoDatabase:@""];
	}
}


-(void) savetimesheetSheetUdfsFromApiToDB: (NSDictionary *)userDefinedFieldsDict withSheetIdentity: (NSNumber *)sheetIdentity andModuleName:(NSString *)moduleName {
	//DLog(@"savetimesheetSheetUdfsFromApiToDB");
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
   
	NSArray *udfNamesArray = [userDefinedFieldsDict allKeys];
	if (udfNamesArray != nil && [udfNamesArray count] > 0) {
		for (NSString *udfName in udfNamesArray) {
			NSMutableArray *udfDetailsArray = [self getUdfDetailsForName:udfName andModuleName:moduleName];
			if (udfDetailsArray != nil && [udfDetailsArray count] > 0) {
				//DLog(@"udfdetails for udf %@ \n %@",udfName,udfDetailsArray);
				NSDictionary *udfDict = [udfDetailsArray objectAtIndex:0];
				NSString *udfIdentity = [udfDict objectForKey:@"identity"];
                NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
				if (udfIdentity != nil && ![udfIdentity isKindOfClass:[NSNull class]]) {
					[dataDictionary setObject:udfIdentity forKey:@"udf_id"];
				}
				[dataDictionary setObject:udfName forKey:@"udf_name"];
				[dataDictionary setObject:moduleName forKey:@"entry_type"];
				[dataDictionary setObject:sheetIdentity forKey:@"entry_id"];
				
				id udfValue = [userDefinedFieldsDict objectForKey:udfName];
				if (udfValue != nil && [udfValue isKindOfClass:[NSString class]] && 
                    ![udfValue isEqualToString:NULL_STRING]) {
					[dataDictionary setObject:((NSString *)udfValue) forKey:@"udfValue"];
				}else if (udfValue != nil && [udfValue isKindOfClass :[NSDictionary class]]) {
					NSDictionary *udfDateDict = (NSDictionary *)udfValue;
					NSString *udfDateValue = [G2Util convertApiDateDictToDateString:udfDateDict];
					[dataDictionary setObject:udfDateValue forKey:@"udfValue"];
				}else if(udfValue != nil && [udfValue isKindOfClass :[NSNumber class]]) {
					[dataDictionary setObject:((NSNumber *)udfValue) forKey:@"udfValue"];
				}
                //                else if(udfValue != nil && [udfValue isKindOfClass :[NSNull class]]) {
                //					[dataDictionary setObject:[NSNull null] forKey:@"udfValue"];
                //				}
                
                NSString *keyStr=nil;
                for (id key in userDefinedFieldsDict) {
                    keyStr=key;
                }
                
				if ([self checkUDFExistsForSheet:sheetIdentity andModuleName:moduleName andUDFName:keyStr]) {
					NSString *whereString = [NSString stringWithFormat:@"entry_id = '%@' and entry_type = '%@' and udf_id = '%@'",
											 sheetIdentity,[ moduleName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ],udfIdentity];
					[myDB updateTable:entryUDFSTable data:dataDictionary where:whereString intoDatabase:@""];
				}else {
					[myDB insertIntoTable:entryUDFSTable data:dataDictionary intoDatabase:@""];
				}
                
			}
		}
	}
}


-(void) saveTaskForTimeEntryWithProject:(NSDictionary *)taskDict withProject:(NSString *)projectIdentity {
	DLog(@"In saveTimeOffEntriesForSheetFromApiToDB method");
	//DLog(@"In saveTimeOffEntriesForSheetFromApiToDB method:::taskDict:::::%@",taskDict);
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	if (taskDict != nil && [taskDict isKindOfClass:[NSDictionary class]]) {
		
		NSString *identity = [taskDict objectForKey:@"Identity"];
		NSDictionary *propertiesDict = [taskDict objectForKey:@"Properties"];
		NSDictionary *relationshipsDict = [taskDict objectForKey:@"Relationships"];
		NSDictionary *relationshipCountDict = [taskDict objectForKey:@"RelationshipCount"];
		NSString *description = nil;
		NSNumber *timeEntryAllowed = nil;
		NSNumber *assignedToUser = nil;
		NSNumber *childTasksExists = nil;
		NSNumber *closedStatus = nil;
		NSString *billingStatus = nil;
		NSString *parentTaskIdentity = nil;
		NSString *name = nil;
        //	NSNumber *levelCount = nil;		//fixed memory leak
		
		if (propertiesDict != nil && [propertiesDict isKindOfClass:[NSDictionary class]]) {
			
			description = [propertiesDict objectForKey:@"Description"];
			timeEntryAllowed = [propertiesDict objectForKey:@"TimeEntryAllowed"];
			assignedToUser = [propertiesDict objectForKey:@"AssignedToCurrentUser"];
			closedStatus = [propertiesDict objectForKey:@"ClosedStatus"];
			name = [propertiesDict objectForKey:@"Name"];
            //	levelCount = [propertiesDict objectForKey:@"LevelCount"];		//fixed memory leak
		}
		
		//do not save if task is project
		
		if (relationshipsDict != nil && [relationshipsDict isKindOfClass:[NSDictionary class]]) {
			NSDictionary *billingDict = [relationshipsDict objectForKey:@"Billable"];
			if (billingDict != nil && [billingDict isKindOfClass:[NSDictionary class]]) {
				billingStatus = [billingDict objectForKey:@"Identity"];
			}
			NSDictionary *parentTaskDict = [relationshipsDict objectForKey:@"ParentTask"];
			if (parentTaskDict != nil && [parentTaskDict isKindOfClass:[NSDictionary class]]) {
				parentTaskIdentity = [parentTaskDict objectForKey:@"Identity"];
			}
		}
		
		if (relationshipCountDict != nil && [relationshipCountDict isKindOfClass:[NSDictionary class]]) {
			childTasksExists = [relationshipCountDict objectForKey:@"ChildTasks"];
			if (childTasksExists != nil && ![childTasksExists isKindOfClass:[NSNull class]]
				&& [childTasksExists isKindOfClass:[NSNumber class]]) {
				
				if ([childTasksExists intValue] > 0) {
					childTasksExists = [NSNumber numberWithInt:1];
				}
				else {
					childTasksExists = [NSNumber numberWithInt:0];
				}
				
			}
		}
		
		NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
		
		if (identity != nil && ![identity isKindOfClass:[NSNull class]] 
			&& ![identity isEqualToString:NULL_STRING]) {
			[dataDict setObject:identity forKey:@"identity"];
		}
		if (description != nil && ![description isKindOfClass:[NSNull class]] 
			&& ![description isEqualToString:NULL_STRING]) {
			[dataDict setObject:description forKey:@"description"];
		}
		if (timeEntryAllowed != nil && ![timeEntryAllowed isKindOfClass:[NSNull class]] 
			&& [timeEntryAllowed isKindOfClass:[NSNumber class]]) {
			[dataDict setObject:timeEntryAllowed forKey:@"timeEntryAllowed"];
		}
		if (assignedToUser != nil && ![assignedToUser isKindOfClass:[NSNull class]] 
			&& [assignedToUser isKindOfClass:[NSNumber class]]) {
			[dataDict setObject:assignedToUser forKey:@"assignedToUser"];
		}
		if (childTasksExists != nil && ![childTasksExists isKindOfClass:[NSNull class]] 
			&& [childTasksExists isKindOfClass:[NSNumber class]]) {
			[dataDict setObject:childTasksExists forKey:@"childTasksExists"];
		}
		if (closedStatus != nil && ![closedStatus isKindOfClass:[NSNull class]] 
			&& [closedStatus isKindOfClass:[NSNumber class]]) {
			[dataDict setObject:closedStatus forKey:@"closedStatus"];
		}
		if (billingStatus != nil && ![billingStatus isKindOfClass:[NSNull class]] 
			&& ![billingStatus isEqualToString:NULL_STRING]) {
			[dataDict setObject:billingStatus forKey:@"billingStatus"];
		}
		if (name != nil && ![name isKindOfClass:[NSNull class]] 
			&& ![name isEqualToString:NULL_STRING]) {
			[dataDict setObject:name forKey:@"name"];
		}
		if (parentTaskIdentity != nil && ![parentTaskIdentity isKindOfClass:[NSNull class]] 
			&& ![parentTaskIdentity isEqualToString:NULL_STRING]) {
			[dataDict setObject:parentTaskIdentity forKey:@"parentTaskIdentity"];
		}
		if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]] 
			&& ![projectIdentity isEqualToString:NULL_STRING]) {
			[dataDict setObject:projectIdentity forKey:@"projectIdentity"];
		}
		
		if ([self checkTaskExistsForProjectAndParent:identity : projectIdentity :parentTaskIdentity]) {
			NSString *whereString = @"";
			if (parentTaskIdentity == nil) {
				whereString = [NSString stringWithFormat:@"identity = '%@' and projectIdentity = '%@' and parentTaskIdentity is null",
							   identity, projectIdentity];
			}
			else {
				whereString = [NSString stringWithFormat:@"identity = '%@' and projectIdentity = '%@' and parentTaskIdentity = '%@'",
							   identity, projectIdentity,parentTaskIdentity];
			}
			
			[myDB updateTable:projectTasksTable data:dataDict where:whereString intoDatabase:@""];
		}
		else {
			[myDB insertIntoTable:projectTasksTable data:dataDict intoDatabase:@""];
		}
		
	}
}


-(void)saveTimeEntryForSheetWithObject:(G2TimeSheetEntryObject *)_timeEntryObject editStatus:(NSString *)_editStatus {
	
	G2SQLiteDB *myDB				= [G2SQLiteDB getInstance];
	
	NSString *sheetIdentity		= [_timeEntryObject sheetId];
	NSDate   *entryDate			= [_timeEntryObject entryDate];
	//NSString *entryDateString	= [Util convertPickerDateToString:entryDate];
	NSString *entryDateString	= [G2Util getDateStringFromDate:entryDate];
	NSString *decimalDuration	= [_timeEntryObject numberOfHours];
	NSNumber *decimalHrs        = [G2Util convertDecimalStringToDecimalNumber:decimalDuration];
	NSString *stringDuration	= [G2Util convertDecimalTimeToHourFormat:decimalHrs];
    
	NSString *clientIdentity	= [_timeEntryObject clientIdentity];
	NSString *clientName		= [_timeEntryObject clientName];
	NSString *projectIdentity	= [_timeEntryObject projectIdentity];
	NSString *projectName		= [_timeEntryObject projectName];
	//NSString *taskIdentity		= [_timeEntryObject taskIdentity];
	//NSString *taskName			= [_timeEntryObject taskName];
	NSString *taskIdentity		= [_timeEntryObject.taskObj taskIdentity];
	NSString *taskName			= [_timeEntryObject.taskObj taskName];
	NSString *billingIdentity	= [_timeEntryObject billingIdentity];
	NSString *billingName		= [_timeEntryObject billingName];
	NSString *activityIdentity	= [_timeEntryObject activityIdentity];
	NSString *activityName		= [_timeEntryObject activityName];
	NSString *comments			= [_timeEntryObject comments];
	
	NSNumber *isModified		= [NSNumber numberWithBool:[_timeEntryObject isModified]];
	NSString *entryType			= TIMESHEET_TIMEENTRY_TYPE;	
	NSString *editStatus =		nil;
	if (_editStatus == nil) {
		editStatus		= @"";
	}
	else {
		editStatus = _editStatus;
	}
	
	NSMutableDictionary *entryDict = [NSMutableDictionary dictionary];
	
	if (entryDateString != nil && ![entryDateString isKindOfClass:[NSNull class]]) {
		[entryDict setObject:entryDateString forKey:@"entryDate"];
	}
	if (clientIdentity != nil && ![clientIdentity isKindOfClass:[NSNull class]]) {
		[entryDict setObject:clientIdentity forKey:@"clientIdentity"];
	}
	if (clientName != nil && ![clientName isKindOfClass:[NSNull class]]) {
		[entryDict setObject:clientName forKey:@"clientName"];
	}
	if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]]) {
		[entryDict setObject:projectIdentity forKey:@"projectIdentity"];
	}
	if (projectName != nil && ![projectName isKindOfClass:[NSNull class]]) {
		[entryDict setObject:projectName forKey:@"projectName"];
	}
	if (taskIdentity != nil && ![taskIdentity isKindOfClass:[NSNull class]]) {
		[entryDict setObject:taskIdentity forKey:@"taskIdentity"];
	}
	if (taskName != nil && ![taskName isKindOfClass:[NSNull class]]) {
		[entryDict setObject:taskName forKey:@"taskName"];
	}
	if (billingIdentity != nil && ![billingIdentity isKindOfClass:[NSNull class]]) {
		[entryDict setObject:billingIdentity forKey:@"billingIdentity"];
	}
	if (billingName != nil && ![billingName isKindOfClass:[NSNull class]]) {
		[entryDict setObject:billingName forKey:@"billingName"];
	}
	if (comments != nil && ![comments isKindOfClass:[NSNull class]]) {
		[entryDict setObject:comments forKey:@"comments"];
	}
	if (stringDuration != nil && ![stringDuration isKindOfClass:[NSNull class]]) {
		[entryDict setObject:stringDuration forKey:@"durationHourFormat"];
	}
	if (decimalDuration != nil && ![decimalDuration isKindOfClass:[NSNull class]]) {
		[entryDict setObject:decimalDuration forKey:@"durationDecimalFormat"];
	}
	if (activityIdentity != nil && ![activityIdentity isKindOfClass:[NSNull class]]) {
		[entryDict setObject:activityIdentity forKey:@"activityIdentity"];
	}
	if (activityName != nil && ![activityName isKindOfClass:[NSNull class]]) {
		[entryDict setObject:activityName forKey:@"activityName"];
	}
	if (sheetIdentity != nil && ![sheetIdentity isKindOfClass:[NSNull class]]) {
		[entryDict setObject:sheetIdentity forKey:@"sheetIdentity"];
	}
	[entryDict setObject:isModified forKey:@"isModified"];
	[entryDict setObject:editStatus forKey:@"editStatus"];
	[entryDict setObject:entryType	forKey:@"entryType"];
    
    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (appdelegate.isInOutTimesheet) {
        if (([entryDict objectForKey:@"time_in"]!=nil && ![[entryDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"time_out"]!=nil && ![[entryDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"durationHourFormat"] !=nil && ![[entryDict objectForKey:@"durationHourFormat"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"durationHourFormat"] isEqualToString:@"0:0"] )  || ([entryDict objectForKey:@"comments"]!=nil && ![[entryDict objectForKey:@"comments"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"comments"] isEqualToString:@""] ) ) 
        {
            
            [myDB insertIntoTable:timeEntriesTable data:entryDict intoDatabase:@""];
        }

    }
    else
    {
         [myDB insertIntoTable:timeEntriesTable data:entryDict intoDatabase:@""];
    }
        
} 

-(void)saveTimeOffEntryForSheetWithObject:(G2TimeOffEntryObject *)_timeOffEntryObject editStatus:(NSString *)_editStatus {
	
	G2SQLiteDB *myDB				= [G2SQLiteDB getInstance];
	
	NSString *sheetIdentity		= [_timeOffEntryObject sheetId];
	NSDate   *entryDate			= [_timeOffEntryObject timeOffDate];
	//NSString *entryDateString	= [Util convertPickerDateToString:entryDate];
	NSString *entryDateString	= [G2Util getDateStringFromDate:entryDate];
	NSString *decimalDuration	= [_timeOffEntryObject numberOfHours];
	NSNumber *decimalHrs        = [G2Util convertDecimalStringToDecimalNumber:decimalDuration];
	NSString *stringDuration	= [G2Util convertDecimalTimeToHourFormat:decimalHrs];
    
	
	NSString *comments			= [_timeOffEntryObject comments];
	
	NSNumber *isModified		= [NSNumber numberWithBool:[_timeOffEntryObject isModified]];
	NSString *entryType			= TIMESHEET_TIMEOFF_TYPE;	
	NSString *editStatus =		nil;
	if (_editStatus == nil) {
		editStatus		= @"";
	}
	else {
		editStatus = _editStatus;
	}
	
	NSMutableDictionary *entryDict = [NSMutableDictionary dictionary];
	
	if (entryDateString != nil && ![entryDateString isKindOfClass:[NSNull class]]) {
		[entryDict setObject:entryDateString forKey:@"entryDate"];
	}
	if (comments != nil && ![comments isKindOfClass:[NSNull class]]) {
		[entryDict setObject:comments forKey:@"comments"];
	}
	if (stringDuration != nil && ![stringDuration isKindOfClass:[NSNull class]]) {
		[entryDict setObject:stringDuration forKey:@"durationHourFormat"];
	}
	if (decimalDuration != nil && ![decimalDuration isKindOfClass:[NSNull class]]) {
		[entryDict setObject:decimalDuration forKey:@"durationDecimalFormat"];
	}
		if (sheetIdentity != nil && ![sheetIdentity isKindOfClass:[NSNull class]]) {
		[entryDict setObject:sheetIdentity forKey:@"sheetIdentity"];
	}
	[entryDict setObject:isModified forKey:@"isModified"];
	[entryDict setObject:editStatus forKey:@"editStatus"];
	[entryDict setObject:entryType	forKey:@"entryType"];
    
    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (appdelegate.isInOutTimesheet) {
        if (([entryDict objectForKey:@"time_in"]!=nil && ![[entryDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"time_out"]!=nil && ![[entryDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"durationHourFormat"] !=nil && ![[entryDict objectForKey:@"durationHourFormat"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"durationHourFormat"] isEqualToString:@"0:0"] )  || ([entryDict objectForKey:@"comments"]!=nil && ![[entryDict objectForKey:@"comments"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"comments"] isEqualToString:@""] ) ) 
        {
            
            [myDB insertIntoTable:timeEntriesTable data:entryDict intoDatabase:@""];
        }
        
    }
    else
    {
        [myDB insertIntoTable:timeEntriesTable data:entryDict intoDatabase:@""];
    }
    
} 

-(void)savePermissionBasedTimesheetUDFsToDB:(NSArray *)responseArray {
	//DLog(@"savePermissionBasedTimesheetUDFsToDB:::TimesheetModel %@",responseArray);
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
    int timesheetudfscount=0;
    int timeoffcount=0;
    for (int i=0; i<[responseArray count]; i++) {
        if ([[[[responseArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"Name"] isEqualToString:@"ReportPeriod"]) {
			timesheetudfscount++;
        }
        else if ([[[[responseArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"Name"] isEqualToString:@"TaskTimesheet"]) {
			timesheetudfscount++;
            
		}else if ([[[[responseArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"Name"] isEqualToString:@"TimesheetEntry"]) {
			timesheetudfscount++;
            
		}

        else 
            timeoffcount++;
    }
    
  //delete user defined fields for Timesheets
	NSString *deleteWhereString = nil;
    if (timesheetudfscount>0) {
        deleteWhereString=[NSString stringWithFormat:@"moduleName = '%@' or moduleName = '%@' or moduleName = '%@' or moduleName = '%@'",ReportPeriod_SheetLevel,TaskTimesheet_RowLevel,TimesheetEntry_CellLevel,TimeOffs_SheetLevel];
    }
   else if (timeoffcount>0)
    {
        deleteWhereString=[NSString stringWithFormat:@"moduleName = '%@' ",TimeOffs_SheetLevel];
    }
	
    [myDB deleteFromTable:userDefinedFieldsTable where:deleteWhereString inDatabase:@""];
	
//	G2PermissionsModel *permissionsModel = [[G2PermissionsModel alloc] init];
    
	
	for (int i=0; i<[responseArray count]; i++) {
        
        NSString *moduleName = @"";
        
        
		moduleName = [[[responseArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"Name"];
		if ([moduleName isEqualToString:@"ReportPeriod"]) {
			moduleName = ReportPeriod_SheetLevel;
            
		}else if ([moduleName isEqualToString:@"TaskTimesheet"]) {
			moduleName = TaskTimesheet_RowLevel;
           
		}else if ([moduleName isEqualToString:@"TimesheetEntry"]) {
			moduleName = TimesheetEntry_CellLevel;
            
		}
       
		NSArray *fieldsArray = [[[responseArray objectAtIndex:i]objectForKey:@"Relationships"]objectForKey:@"Fields"];
		for (int j=0 ; j<[fieldsArray count]; j++) {
            
            NSString *name = @"";
            NSString *textDefaultVal= @"";
            NSString *dateDefaultVal = @"";
            NSString *dateMinVal = @"";
            NSString *dateMaxVal = @"";
            //NSNumber *dateDefaultValIsToday=[NSNumber numberWithInt:0];
            NSNumber *textMaxVal;
            
            NSNumber *numericMinVal;
            NSNumber *numericMaxVal;
            NSNumber *numericDecimalPlaces=0;
            NSString *identity;
            NSString *udfType;
            
			NSMutableDictionary *infoDict=[NSMutableDictionary dictionary];
			int enabled=0,required=0,hidden=0;
			
			identity = [[fieldsArray objectAtIndex:j] objectForKey:@"Identity"];
			
			
			udfType = [[[[fieldsArray objectAtIndex:j] objectForKey:@"Relationships"]
						objectForKey:@"Type"]objectForKey:@"Identity" ];
			
			[infoDict setObject:udfType forKey:@"udfType"];
			[infoDict setObject:moduleName forKey:@"moduleName"];
			NSDictionary *propertiesDict = [[fieldsArray objectAtIndex:j]objectForKey:@"Properties"];
			
            //			NSString *udfOfTimesheet;
            //			if ([[infoDict objectForKey:@"moduleName"] isEqualToString:ReportPeriod_SheetLevel]) {
            //				udfOfTimesheet = [NSString stringWithFormat:@"%@%d",ReportPeriod_SheetLevel_Udf,j+1];
            //			}else if ([[infoDict objectForKey:@"moduleName"] isEqualToString:TimesheetEntry_CellLevel]) {
            //				udfOfTimesheet = [NSString stringWithFormat:@"%@%d",TimesheetEntry_CellLevel_Udf,j+1];
            //			}else {
            //				udfOfTimesheet = [NSString stringWithFormat:@"%@%d",TaskTimesheet_RowLevel,j+1];
            //			}
            
            //			BOOL available = NO;
            //			if ([namesArray containsObject:udfOfTimesheet]) {
            //				available = YES;
            //			}
			
            //			if ([[propertiesDict objectForKey:@"Enabled"] boolValue] == YES && available){
            //				enabled = 1;
            //			}
            
            if ([[propertiesDict objectForKey:@"Enabled"] boolValue] == YES ){
				enabled = 1;
			}
			
			if ([[propertiesDict objectForKey:@"Required"] boolValue]== YES){
				required = 1;
			}
			if ([[propertiesDict objectForKey:@"Hidden"] boolValue]== YES){
				hidden = 1;
			}
			if ([propertiesDict objectForKey:@"Name"]!= nil) {
				name = [propertiesDict objectForKey:@"Name"];
			}
			
			if ([[propertiesDict objectForKey:@"TextDefaultValue"]isKindOfClass:[NSNull class]]) {
				//textDefaultVal = @"null";
			}else {
				textDefaultVal=[propertiesDict objectForKey:@"TextDefaultValue"];
			}
			
			
			[infoDict setObject:textDefaultVal forKey:@"textDefaultValue"];
            
            if ([propertiesDict objectForKey:@"FieldIndex"]!= nil) {
                [infoDict setObject:[propertiesDict objectForKey:@"FieldIndex"] forKey:@"fieldIndex"];
			}
            
            
			
			if ([[propertiesDict objectForKey:@"TextMaximumLength"]isKindOfClass:[NSNull class]]) {
				//textMaxVal = [NSNumber numberWithInt:0];
			}else{
				textMaxVal =[NSNumber numberWithInt:[[propertiesDict objectForKey:@"TextMaximumLength"]intValue]];
				[infoDict setObject:textMaxVal forKey:@"textMaxValue"];
			}
			
			
			
			
			if ([[propertiesDict objectForKey:@"NumericMinimumValue"]isKindOfClass:[NSNull class]]) {
				//numericMinVal = [NSNumber numberWithInt:0];
			}else{
				numericMinVal =[NSNumber numberWithInt:[[propertiesDict objectForKey:@"NumericMinimumValue"]intValue]];
				[infoDict setObject:numericMinVal forKey:@"numericMinValue"];
			}
			
			if ([[propertiesDict objectForKey:@"NumericMaximumValue"]isKindOfClass:[NSNull class]]) {
				//numericMaxVal = [NSNumber numberWithInt:0];
			}else{
				numericMaxVal =[NSNumber numberWithInt:[[propertiesDict objectForKey:@"NumericMaximumValue"]intValue]];
				[infoDict setObject:numericMaxVal forKey:@"numericMaxvalue"];
			}
			if ([[propertiesDict objectForKey:@"NumericDecimalPlaces"]isKindOfClass:[NSNull class]]) {
				//numericDecimalPlaces = [NSNumber numberWithInt:0];
			}else{
				numericDecimalPlaces =[NSNumber numberWithInt:[[propertiesDict objectForKey:@"NumericDecimalPlaces"]intValue]];
				[infoDict setObject:numericDecimalPlaces forKey:@"numericDecimalPlaces"];
			}
            
            if ([[propertiesDict objectForKey:@"NumericDefaultValue"]isKindOfClass:[NSNull class]]) {
				//numericDefaultVal = [NSNumber numberWithInt:0];
		}
	   else{
                        
                                  
                //DE4012//Juhi
//                if ([[propertiesDict objectForKey:@"NumericDecimalPlaces"]intValue]>0) {
//                        
//                    //                    [infoDict setObject:[NSNumber numberWithFloat:[[propertiesDict objectForKey:@"NumericDefaultValue"]floatValue]] forKey:@"numericDefaultValue"];
//                    
//                    [infoDict setObject:[propertiesDict objectForKey:@"NumericDefaultValue"] forKey:@"numericDefaultValue"];
//                }  
                    
         
		// else
//                {
////                 numericDefaultVal =[NSNumber numberWithInt:[[propertiesDict objectForKey:@"NumericDefaultValue"]intValue]];
                    [infoDict setObject:[propertiesDict objectForKey:@"NumericDefaultValue"] forKey:@"numericDefaultValue"];
                    
//                }
                    
      
  }
			
			if([propertiesDict objectForKey:@"DateDefaultValue"]!= nil  && ![[propertiesDict objectForKey:@"DateDefaultValue"] isKindOfClass:[NSNull class]] ){
				id  dateDefaultDict = [propertiesDict objectForKey:@"DateDefaultValue"];
				
				if ([dateDefaultDict isKindOfClass:[NSDictionary class]]) {	
					int month = [[dateDefaultDict objectForKey:@"Month"]intValue];
					dateDefaultVal =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],
									 [dateDefaultDict objectForKey:@"Day"],[dateDefaultDict objectForKey:@"Year"]];					 
				}
				[infoDict setObject:dateDefaultVal forKey:@"dateDefaultValue"];
			}
			
			if ([[propertiesDict objectForKey:@"DateDefaultValueIsToday"] isKindOfClass:[NSNull class]]) {
				//dateDefaultValIsToday = [NSNumber numberWithInt:0];
				
			}else {
				if ([[propertiesDict objectForKey:@"DateDefaultValueIsToday"] boolValue] == YES){
					NSNumber *dateDefaultValIsToday = [NSNumber numberWithInt:1];
					[infoDict setObject:dateDefaultValIsToday forKey:@"isDateDefaultValueToday"];
				}
			}
			
			if ([propertiesDict objectForKey:@"DateMinimumValue"] != nil && ![[propertiesDict objectForKey:@"DateMinimumValue"] isKindOfClass:[NSNull class]]) {
				
				id  dateMinValDict = [propertiesDict objectForKey:@"DateMinimumValue"];
				if ([dateMinValDict isKindOfClass:[NSDictionary class]]) {
					
					int month = [[dateMinValDict objectForKey:@"Month"]intValue];
					dateMinVal =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],
								 [dateMinValDict objectForKey:@"Day"],[dateMinValDict objectForKey:@"Year"]];
					
				}
				[infoDict setObject:dateMinVal forKey:@"dateMinValue"];
			}
			
			if ([propertiesDict objectForKey:@"DateMaximumValue"] != nil && ![[propertiesDict objectForKey:@"DateMaximumValue"] isKindOfClass:[NSNull class]]) {
				id dateMaxValDict = [propertiesDict objectForKey:@"DateMaximumValue"];
				if ([dateMaxValDict isKindOfClass:[NSDictionary class]]) {
					int month = [[dateMaxValDict objectForKey:@"Month"]intValue];
					dateMaxVal =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],
								 [dateMaxValDict objectForKey:@"Day"],[dateMaxValDict objectForKey:@"Year"]];
				}
				[infoDict setObject:dateMaxVal forKey:@"dateMaxValue"];
			}
			
			//[infoDict setObject:[NSNumber numberWithInt:j+1] forKey:@"id"];
			[infoDict setObject:identity forKey:@"identity"];
			[infoDict setObject:[NSNumber numberWithInt:enabled] forKey:@"enabled"];
			[infoDict setObject:[NSNumber numberWithInt:required] forKey:@"required"];
			[infoDict setObject:[NSNumber numberWithInt:hidden] forKey:@"hidden"];
			[infoDict setObject:name forKey:@"name"];
//			//US4591//Juhi
//			NSArray *timeSheetsArr = [self getTimeOffUdfsWithIdentity:identity moduleName:moduleName];
//            if ([timeSheetsArr count]>0) {
//                
//                NSString *whereString=[NSString stringWithFormat:@"identity='%@'and moduleName='%@'",identity,moduleName];
//                [myDB updateTable:timesheetsTable data:infoDict where:whereString intoDatabase:@""];
//                
//            }else {
                
                [myDB insertIntoTable:userDefinedFieldsTable data:infoDict intoDatabase:@""];	
//            }			
			
			NSArray *dropDownOptionsArray = [[[fieldsArray objectAtIndex:j] objectForKey:@"Relationships"] 
											 objectForKey:@"DropDownOptions"];
			
			if (dropDownOptionsArray != nil && [dropDownOptionsArray count] > 0) {
				[self insertTimesheetDropDownOptionsToDatabase:dropDownOptionsArray : identity];
			}
		}	
	}

}
-(void)insertTimesheetDropDownOptionsToDatabase:(NSArray *)dropDownOptionsArray : (NSString *)udfIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSString *deleteWhereString = [NSString stringWithFormat:@"udfIdentity = '%@'",udfIdentity];
	[myDB deleteFromTable:udfDropDownOptionsTable where:deleteWhereString inDatabase:@""];
	
	
	for (NSDictionary *dropDownUdfDict in dropDownOptionsArray) {
		
		NSMutableDictionary *dropDownOptionsDict  = [NSMutableDictionary dictionary];
		[dropDownOptionsDict setObject:udfIdentity forKey:@"udfIdentity"];
		
		NSString *identity = [dropDownUdfDict objectForKey:@"Identity"];
		NSDictionary *propertiesDict = [dropDownUdfDict objectForKey:@"Properties"];
		NSString *udfValue = [propertiesDict objectForKey:@"Value"];
		NSNumber *enabled = [propertiesDict objectForKey:@"Enabled"];
		NSNumber *defaultOption = [propertiesDict objectForKey:@"DefaultOption"];
		
		if (udfValue != nil && ![udfValue isKindOfClass:[NSNull class]]) {
			[dropDownOptionsDict setObject:udfValue forKey:@"value"];
		}
        //		if (enabled != nil && [enabled isKindOfClass:[NSNull class]]) {
        //			[dropDownOptionsDict setObject:enabled forKey:@"enabled"];
        //		}
        if (enabled != nil ) {
			[dropDownOptionsDict setObject:enabled forKey:@"enabled"];
		}
        else {
			[dropDownOptionsDict setObject:[NSNumber numberWithInt:0] forKey:@"enabled"];
		}
		
		if (defaultOption != nil || ![defaultOption isKindOfClass:[NSNull class]]) {
			[dropDownOptionsDict setObject:defaultOption forKey:@"DefaultOption"];
		}else {
			[dropDownOptionsDict setObject:[NSNumber numberWithInt:0] forKey:@"DefaultOption"];
		}
		[dropDownOptionsDict setObject:identity forKey:@"identity"];
        
        [myDB insertIntoTable:udfDropDownOptionsTable data:dropDownOptionsDict intoDatabase:@""];	
	}
}
#pragma mark select methods

-(BOOL)checkTaskExistsForProjectAndParent:(NSString *)identity :
(NSString *) projectIdentity :(NSString *)parentTaskIdentity {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = @"";
	if (parentTaskIdentity == nil) {
		whereString = [NSString stringWithFormat:@"identity = '%@' and projectIdentity = '%@' and parentTaskIdentity is null",
					   identity, projectIdentity];
	}
	else {
		whereString = [NSString stringWithFormat:@"identity = '%@' and projectIdentity = '%@' and parentTaskIdentity = '%@'",
					   identity, projectIdentity,parentTaskIdentity];
	}
	
	NSMutableArray *taskArray = [myDB select:@"Identity" from:projectTasksTable where:whereString intoDatabase:@""];
	if (taskArray != nil && [taskArray count] > 0) {
		return YES;
	}
	
	return NO;
}

-(NSMutableArray *) getTimesheetsFromDB {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	//[myDB select:@"*" from:timesheetsTable where:@"" intoDatabase:@""];
	//NSString *sql = [NSString stringWithFormat:@"select * from %@ order by identity desc",timesheetsTable];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ order by startDate desc",timesheetsTable];//DE2529:fix
	NSMutableArray *timesheetsArray = [myDB executeQuery:sql];
	if ([timesheetsArray count]>0) {
		return timesheetsArray;
	}
	return nil;
}




-(NSMutableArray *) getTimeEntriesForSheetFromDB: (NSString *)sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entryType = 'timeEntry' and sheetIdentity = '%@' order by identity desc",sheetIdentity];
	NSMutableArray *timeEntriesArray = [myDB select:@"*" from:timeEntriesTable where:whereString intoDatabase:@""];
	if ([timeEntriesArray count]>0) 
    {
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        if (appDelegate.isInOutTimesheet ||appDelegate.isNewInOutTimesheetUser) 
        {
            if ([timeEntriesArray count]>1) 
            {
                return [G2Util sortArray:timeEntriesArray inAscending:YES usingKey:@"time_in"];
            }
            
        }
                
        return timeEntriesArray;
	}
	return nil;
}
//US4805
-(NSMutableArray *) getTimesheetsForSheetFromDB: (NSString *)sheetIdentity {
    
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",sheetIdentity];
	NSMutableArray *timeEntriesArray = [myDB select:@"*" from:timesheetsTable where:whereString intoDatabase:@""];
	if ([timeEntriesArray count]>0) {
		return timeEntriesArray;
	}
	return nil;

}
-(NSMutableArray *) getTimeEntryForWithDate:(id)entryDate  {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    NSString *dateToBeUsed =entryDate;
    if ([entryDate isKindOfClass:[NSDate class]]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormat setLocale:locale];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
       dateToBeUsed = [dateFormat stringFromDate:entryDate];
        
    }
    
    
    
	NSString *whereString = [NSString stringWithFormat:
							 @"entryDate = '%@'",
						dateToBeUsed];
	//DLog(@"WHERE String :Time entries%@",whereString);
	NSMutableArray *timeEntriesArray = [myDB select:@"*" from:punchClocktimeEntriesTable where:whereString intoDatabase:@""];
	//DLog(@"ENTRIES FROM DB:::Time Entries %d",[timeEntriesArray count]);
	if ([timeEntriesArray count]>0) {
		return timeEntriesArray;
	}
	return nil;
}

-(NSMutableArray *) getTimeEntryForSheetWithSheetIdentity:(NSString *)identity :(NSString *)sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:
							 @"entryType = 'timeEntry' and identity = '%@' and sheetIdentity = '%@'",
							 identity,sheetIdentity];
	//DLog(@"WHERE String :Time entries%@",whereString);
	NSMutableArray *timeEntriesArray = [myDB select:@"*" from:timeEntriesTable where:whereString intoDatabase:@""];
	//DLog(@"ENTRIES FROM DB:::Time Entries %d",[timeEntriesArray count]);
	if ([timeEntriesArray count]>0) {
		return timeEntriesArray;
	}
	return nil;
}

-(NSMutableArray *) getTimeOffEntryWithEntryIdentityForSheetWithSheetIdentity:(NSString *)timeOffEntryIdentity :(NSString *)sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
	NSString *whereString = [NSString stringWithFormat:@"entryType = 'timeOff' and identity = '%@' and sheetIdentity = '%@'",
							 timeOffEntryIdentity,sheetIdentity];
	//DLog(@"wheretring for timeoff %@",whereString);
	NSMutableArray *timeOffsArray = [myDB select:@"*" from:timeEntriesTable where:whereString intoDatabase:@""];
	if ([timeOffsArray count]>0) {
		return timeOffsArray;
	}
	return nil;
}
-(NSMutableArray *) getTimeOffsForSheetFromDB:(NSString *)sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entryType = 'timeOff' and sheetIdentity = '%@'",sheetIdentity];
	NSMutableArray *timeOffsArray = [myDB select:@"*" from:timeEntriesTable where:whereString intoDatabase:@""];
	if ([timeOffsArray count]>0) {
		return timeOffsArray;
	}
	return nil;
}

-(NSMutableArray *) getEntryProjectNamesForSheetFromDB: (NSString *)sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"sheetIdentity = '%@' and projectName <> ''",sheetIdentity];
	//NSString *whereString = [NSString stringWithFormat:@"sheetIdentity = '%@'",sheetIdentity];
	NSMutableArray *projectNamesArray = [myDB select:@"projectName" from:timeEntriesTable where:whereString intoDatabase:@""];
	if ([projectNamesArray count]>0) {
		return projectNamesArray;
	}
	return nil;
}

-(NSMutableArray *) getEntryActivitiesForSheetFromDB: (NSString *) sheetIdentity {
	//DLog(@"sheetIdentity %@",sheetIdentity);
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"sheetIdentity = '%@' and activityName <> ''",sheetIdentity];
	//NSString *whereString = [NSString stringWithFormat:@"sheetIdentity = '%@' ",sheetIdentity];
	NSMutableArray *activityArray = [myDB select:@"activityName" from:timeEntriesTable where:whereString intoDatabase:@""];
	if ([activityArray count]>0) {
		return activityArray;
	}
	return nil;
}

-(NSString*) getSheetTotalTimeHoursForSheetFromDB: (NSString *) sheetIdentity withFormat:(NSString *)format{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",sheetIdentity];
    
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.isLockedTimeSheet) {
        format=@"Decimal";
    }
    
    NSString *selectString  = nil;
    
    if ([format isEqualToString:@"Decimal"])
    {
        selectString  = @"totalHoursDecimalFormat";
    }
	else
    {
        selectString  = @"totalHoursFormat";
    }
	NSMutableArray *totalTimeArray = [myDB select:selectString from:timesheetsTable where:whereString intoDatabase:@""];
	//hardcoding format to decimal for realease 1.
	//format = @"Decimal";
	if (totalTimeArray != nil && [totalTimeArray count]>0) {
		if ([format isEqualToString:@"Decimal"]) {
			if (![[[totalTimeArray objectAtIndex:0] objectForKey:@"totalHoursDecimalFormat"] isKindOfClass:[NSNull class]]) {
				return [NSString stringWithFormat:@"%0.02f",[[[totalTimeArray objectAtIndex:0] objectForKey:@"totalHoursDecimalFormat"]floatValue]];
			}
            
		}else {
			if ([totalTimeArray count]>0)
            {
                int totalHrs=0;
                int totalMins=0;
                for (int k=0; k<[totalTimeArray count]; k++)
                {
                    NSString *durationHoursFormat=[[totalTimeArray objectAtIndex:k] objectForKey:@"totalHoursFormat"];
                    NSArray *compArr=[durationHoursFormat componentsSeparatedByString:@":"];
                    if ([compArr count] >1)
                    {
                        totalHrs=totalHrs + [[compArr objectAtIndex:0]intValue];
                        totalMins=totalMins + [[compArr objectAtIndex:1]intValue];
                    }
                    
                }
                if (totalMins>=60) {
                    int divHrs=totalMins/60;
                    totalHrs=totalHrs+divHrs;
                    int remMin=totalMins % 60;
                    totalMins=remMin;
                    
                }
                NSString *totalHrsStr=[NSString stringWithFormat:@"%d:",totalHrs];
                NSString *totalMinsStr = [NSString stringWithFormat:@"%d",totalMins] ;
                
                if (![totalMinsStr isKindOfClass:[NSNull class]])
                {
                    if ([totalMinsStr length]==1)
                    {
                        totalMinsStr=[@"0" stringByAppendingString:totalMinsStr];
                    }
                }
                
                
                return [totalHrsStr stringByAppendingString:totalMinsStr];
            }
            
            return @"0:00";
            
			
		}
	}
    if (![format isEqualToString:@"Decimal"])
    {
        return @"0:00";
    }
    else
    {
        return nil;
    }
	
}
-(NSString *)getTotalHoursforEntryWithDate:(NSString *)_entryDate withformat:(NSString *)format{
	//DLog(@"_entryDate %@",_entryDate);
	//DLog(@"Time format  %@",format);
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entryDate = '%@'",_entryDate];
	RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.isLockedTimeSheet) {
        format=@"Decimal";
    }
    
    NSString *selectString  = nil;
    
    if ([format isEqualToString:@"Decimal"]) 
    {
        selectString  = @"sum(durationDecimalFormat) as totalDecimalHours";
    }
	else
    {
        selectString  = @"durationHourFormat";
    }

	NSMutableArray *totalTimeArray = [myDB select:selectString from:timeEntriesTable where:whereString intoDatabase:@""];
	
	if (totalTimeArray != nil && [totalTimeArray count]>0) {
		if ([format isEqualToString:@"Decimal"]) {
			if (![[[totalTimeArray objectAtIndex:0] objectForKey:@"totalDecimalHours"] isKindOfClass:[NSNull class]]) {
				return [NSString stringWithFormat:@"%0.02f",[[[totalTimeArray objectAtIndex:0] objectForKey:@"totalDecimalHours"]floatValue]];
			}
			
		}
        else 
        {
            if ([totalTimeArray count]>0) 
            {
                int totalHrs=0;
                int totalMins=0;
                for (int k=0; k<[totalTimeArray count]; k++) 
                {
                    NSString *durationHoursFormat=[[totalTimeArray objectAtIndex:k] objectForKey:@"durationHourFormat"];
                    NSArray *compArr=[durationHoursFormat componentsSeparatedByString:@":"];
                    if ([compArr count] >1) 
                    {
                        totalHrs=totalHrs + [[compArr objectAtIndex:0]intValue];
                        totalMins=totalMins + [[compArr objectAtIndex:1]intValue];
                    }
                    
                }
                if (totalMins>=60) {
                    int divHrs=totalMins/60;
                    totalHrs=totalHrs+divHrs;
                    int remMin=totalMins % 60;
                    totalMins=remMin;
                    
                }
                NSString *totalHrsStr=[NSString stringWithFormat:@"%d:",totalHrs];
                NSString *totalMinsStr = [NSString stringWithFormat:@"%d",totalMins] ;
                if (![totalMinsStr isKindOfClass:[NSNull class] ])
                {
                    if ([totalMinsStr length]==1) 
                    {
                        totalMinsStr=[@"0" stringByAppendingString:totalMinsStr];
                    }
                }

                return [totalHrsStr stringByAppendingString:totalMinsStr];
            } 
            
            return @"0:00";

        }
	}
    
    if (![format isEqualToString:@"Decimal"])
    {
        return @"0:00";
    }
    else
    {
        return nil; 
    }

}
-(NSString *)getTotalHoursforBookedEntryWithDate:(NSString *)_entryDate withformat:(NSString *)format{
	//DLog(@"_entryDate %@",_entryDate);
	//DLog(@"Time format  %@",format);
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entryDate = '%@'",_entryDate];
    
	RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.isLockedTimeSheet) {
        format=@"Decimal";
    }
    
    NSString *selectString  = nil;
    if ([format isEqualToString:@"Decimal"]) 
    {
        selectString  =  @"sum(decimalDuration) as totalDecimalHours";
    }
	else
    {
        selectString  = @"hourDuration";
    }

	NSMutableArray *totalTimeArray = [myDB select:selectString from:bookedTimeOffTable where:whereString intoDatabase:@""];
	
	if (totalTimeArray != nil && [totalTimeArray count]>0) {
		if ([format isEqualToString:@"Decimal"]) {
			if (![[[totalTimeArray objectAtIndex:0] objectForKey:@"totalDecimalHours"] isKindOfClass:[NSNull class]]) {
				return [NSString stringWithFormat:@"%0.02f",[[[totalTimeArray objectAtIndex:0] objectForKey:@"totalDecimalHours"]floatValue]];
			}
			
		}
        else 
        {
            
			if ([totalTimeArray count]>0) 
            {
                int totalHrs=0;
                int totalMins=0;
                for (int k=0; k<[totalTimeArray count]; k++) 
                {
                    NSString *durationHoursFormat=[[totalTimeArray objectAtIndex:k] objectForKey:@"hourDuration"];
                    NSArray *compArr=[durationHoursFormat componentsSeparatedByString:@":"];
                    if ([compArr count] >1) 
                    {
                        totalHrs=totalHrs + [[compArr objectAtIndex:0]intValue];
                        totalMins=totalMins + [[compArr objectAtIndex:1]intValue];
                    }
                    
                }
                if (totalMins>=60) {
                    int divHrs=totalMins/60;
                    totalHrs=totalHrs+divHrs;
                    int remMin=totalMins % 60;
                    totalMins=remMin;
                    
                }
                NSString *totalHrsStr=[NSString stringWithFormat:@"%d:",totalHrs];
                NSString *totalMinsStr = [NSString stringWithFormat:@"%d",totalMins] ;
                if (![totalMinsStr isKindOfClass:[NSNull class] ])
                {
                    if ([totalMinsStr length]==1) 
                    {
                        totalMinsStr=[@"0" stringByAppendingString:totalMinsStr];
                    }
                }

                return [totalHrsStr stringByAppendingString:totalMinsStr];
            } 
            
            return @"0:00";
            
			
            
        }
	}
	if (![format isEqualToString:@"Decimal"])
    {
        return @"0:00";
    }
    else
    {
        return nil; 
    }
}
-(NSString *)getTotalBookedTimeOffHoursForSheetWith:(NSString *)_startDate endDate:(NSString *)_endDate withFormat:(NSString *)format{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entryDate between '%@' and '%@'",_startDate,_endDate];
    
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.isLockedTimeSheet) {
        format=@"Decimal";
    }
    
    NSString *selectString  = nil;
    if ([format isEqualToString:@"Decimal"]) 
    {
        selectString  =  @"sum(decimalDuration) as totalDecimalHours";
    }
	else
    {
        selectString  = @"hourDuration";
    }


	NSMutableArray *totalTimeArray = [myDB select:selectString from:bookedTimeOffTable where:whereString intoDatabase:@""];
	
	if (totalTimeArray != nil && [totalTimeArray count]>0) {
		if ([format isEqualToString:@"Decimal"]) {
			if (![[[totalTimeArray objectAtIndex:0] objectForKey:@"totalDecimalHours"] isKindOfClass:[NSNull class]]) {
				return [NSString stringWithFormat:@"%0.02f",[[[totalTimeArray objectAtIndex:0] objectForKey:@"totalDecimalHours"]floatValue]];
			}
			
		}
        else {
			if ([totalTimeArray count]>0) 
            {
                int totalHrs=0;
                int totalMins=0;
                for (int k=0; k<[totalTimeArray count]; k++) 
                {
                    NSString *durationHoursFormat=[[totalTimeArray objectAtIndex:k] objectForKey:@"hourDuration"];
                    NSArray *compArr=[durationHoursFormat componentsSeparatedByString:@":"];
                    if ([compArr count] >1) 
                    {
                        totalHrs=totalHrs + [[compArr objectAtIndex:0]intValue];
                        totalMins=totalMins + [[compArr objectAtIndex:1]intValue];
                    }
                    
                }
                if (totalMins>=60) {
                    int divHrs=totalMins/60;
                    totalHrs=totalHrs+divHrs;
                    int remMin=totalMins % 60;
                    totalMins=remMin;
                    
                }
                NSString *totalHrsStr=[NSString stringWithFormat:@"%d:",totalHrs];
                NSString *totalMinsStr = [NSString stringWithFormat:@"%d",totalMins] ;
                if (![totalMinsStr isKindOfClass:[NSNull class] ])
                {
                    if ([totalMinsStr length]==1) 
                    {
                        totalMinsStr=[@"0" stringByAppendingString:totalMinsStr];
                    }
                }

                return [totalHrsStr stringByAppendingString:totalMinsStr];
            } 
            
            return @"0:00";
            
			
		}
	}
    if (![format isEqualToString:@"Decimal"])
    {
        return @"0:00";
    }
    else
    {
        return nil; 
    }

}
-(NSMutableArray *)getDistinctEntryDatesForSheet:(NSString *)sheetidentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@" select distinct(entryDate) as entrydate from %@ where sheetIdentity ='%@' order by entrydate desc "
					 ,timeEntriesTable,sheetidentity];
	NSMutableArray *distiinctDateArr = [myDB executeQuery:sql];
	if (distiinctDateArr != nil && [distiinctDateArr count]>0) {
		return distiinctDateArr;
	}
	return nil;
}

-(NSMutableArray *)getAllMealViolationsbyDate:(NSString *)violationDate forISOName:(NSString *)isoName forSheetidentity:(NSString *)sheetIdentity
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@" select * from %@ where violationDate ='%@' and ISOName='%@' and sheetIdentity='%@' order by identity asc ",mealbreaksTable,violationDate,isoName,sheetIdentity];
	NSMutableArray *mealVilationsArr = [myDB executeQuery:sql];
	if (mealVilationsArr != nil && [mealVilationsArr count]>0) {
		return mealVilationsArr;
	}
	return nil;
}

-(NSMutableArray *)getUdfDetailsForName: (NSString *)udfName andModuleName:(NSString *)moduleName {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where moduleName = '%@' and name = '%@'",
					 userDefinedFieldsTable,[ moduleName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ],[udfName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSMutableArray *udfDetailsArray = [myDB executeQuery:sql];
	//DLog(@"udfDetailsArray %@",udfDetailsArray);
	if (udfDetailsArray != nil && [udfDetailsArray count]>0) {
		return udfDetailsArray;
	}
	return nil;
}


-(BOOL) checkUDFExistsForSheet: (NSNumber *)sheetIdentity andModuleName:(NSString *)moduleName andUDFName:(NSString *)udfName {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where entry_type = '%@' and entry_id = %@ and udf_name='%@' ",
					 entryUDFSTable,[ moduleName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ],sheetIdentity,[ udfName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSMutableArray *udfDetailsArray = [myDB executeQuery:sql];
	if (udfDetailsArray != nil && [udfDetailsArray count]>0) {
		return YES;
	}
	return NO;
}

/*-(NSMutableArray *)getEnabledAndRequiredSheetLevelUDFs {
 SQLiteDB *myDB = [SQLiteDB getInstance];
 NSString *sql = [NSString stringWithFormat:@"select * from %@ where moduleName = '%@' and enabled = 1 and required = 1",
 userDefinedFieldsTable,TIMESHEET_SHEET_LEVEL_UDF_KEY];
 NSMutableArray *udfDetailsArray = [myDB executeQuery:sql];
 if (udfDetailsArray != nil && [udfDetailsArray count]>0) {
 return udfDetailsArray;
 }
 return nil;
 }*/

-(NSMutableArray *)getUDFsforTimesheetEntry : (NSString *)entryId : (NSString *)moduleName {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where entry_type = '%@' and entry_id = '%@'",
					 entryUDFSTable,TIMESHEET_SHEET_LEVEL_UDF_KEY,entryId];
	NSMutableArray *udfDetailsArray = [myDB executeQuery:sql];
	if (udfDetailsArray != nil && [udfDetailsArray count]>0) {
		return udfDetailsArray;
	}
	return nil;
}

-(NSNumber *)getDefaultOptionForDropDownUDF:(NSString *)udfIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where udfIdentity = '%@'",
					 udfDropDownOptionsTable,udfIdentity];
	NSMutableArray *udfDetailsArray = [myDB executeQuery:sql];
	if (udfDetailsArray != nil && [udfDetailsArray count]>0) {
		return [[udfDetailsArray objectAtIndex:0] objectForKey:@"defaultOption"];
	}
	return [NSNumber numberWithInt:0];
}

-(NSMutableArray *)getTimeSheetForEntryDate:(NSDate *)entryDate {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sqlString = [NSString stringWithFormat:@"select * from timesheets where '%@' between startDate and endDate",
						   entryDate];
	NSMutableArray *timesheetArray = [myDB executeQuery:sqlString];
	if (timesheetArray != nil && [timesheetArray count] > 0) {
		return timesheetArray;
	}
	return nil;
}
-(BOOL)checkWhetherEntryDateFalssInTimeSheetPeriod:(NSDate *)entryDate :(NSNumber *)sheetIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *userEntryDate=@"";
    userEntryDate=[formatter stringFromDate:entryDate];
    
    
    NSString *startDateSql=[NSString stringWithFormat:@"select startDate,endDate from timesheets where identity='%@'",sheetIdentity];
    NSMutableArray *tsDateArray =[myDB executeQuery:startDateSql];
    NSDate *startDate=nil;
     NSDate *endDate=nil;
    if ([tsDateArray count]>0) {
        startDate=[[tsDateArray objectAtIndex:0] objectForKey:@"startDate"];
        endDate=[[tsDateArray objectAtIndex:0] objectForKey:@"endDate"];
    }
    
    
	NSString *sqlString = [NSString stringWithFormat:@"select * from timesheets where '%@' between '%@' and '%@' and identity='%@'",userEntryDate,startDate,endDate,sheetIdentity];
	NSMutableArray *timesheetArray = [myDB executeQuery:sqlString];
	if (timesheetArray != nil && [timesheetArray count] > 0) {
		return YES;
	}
    else
    {
        return NO;
    }
	return NO;
}

-(NSMutableArray*)getAllSheetIdentitiesFromDB
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sqlQuery = @"select identity from timesheets";
	NSMutableArray *identitiesArray = [myDB executeQueryToConvertUnicodeValues:sqlQuery];
	NSMutableArray *idsArry = [NSMutableArray array];
	if (identitiesArray != nil && [identitiesArray count] > 0) {
		for (NSDictionary *idDict in identitiesArray) {
			[idsArry addObject:[idDict objectForKey:@"identity"]];
		}
	}
	
	if (idsArry != nil && [idsArry count] > 0) {
		return idsArry;
	}
	return nil;
}
-(NSMutableArray *)getEnabledAndRequiredTimeSheetLevelUDFs {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql =[NSString stringWithFormat:@"select * from %@ where enabled = 1 and required = 1 and (moduleName = '%@' or moduleName = '%@'or moduleName = '%@')",
                    userDefinedFieldsTable,ReportPeriod_SheetLevel,TaskTimesheet_RowLevel,TimesheetEntry_CellLevel];
	NSMutableArray *udfDetailsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	//DLog(@"Udfs count %d",[udfDetailsArray count]);
	if (udfDetailsArray != nil && [udfDetailsArray count]>0) {
		return udfDetailsArray;
	}
	return nil;
}

-(NSMutableArray *)getEnabledAndRequiredTimeSheetLevelUDFsFieldIndexes:(NSString *)moduleName {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql =[NSString stringWithFormat:@"select fieldIndex from %@ where enabled = 1 and required = 1 and moduleName = '%@'",
                    userDefinedFieldsTable,[ moduleName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSMutableArray *udfDetailsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	//DLog(@"Udfs count %d",[udfDetailsArray count]);
	if (udfDetailsArray != nil && [udfDetailsArray count]>0) {
		return udfDetailsArray;
	}
	return nil;
}

-(NSMutableArray *)getEnabledOnlyTimeSheetLevelUDFsForCellAndRow {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sqlRowLevel =[NSString stringWithFormat:@"select * from %@ where enabled = 1 and hidden=0 and moduleName = '%@' order by fieldIndex ",
                    userDefinedFieldsTable,TaskTimesheet_RowLevel];
	NSMutableArray *rowLevelUdfDetailsArray = [myDB executeQueryToConvertUnicodeValues:sqlRowLevel];
    NSString *sqlCellLevel =[NSString stringWithFormat:@"select * from %@ where enabled = 1 and hidden=0 and  moduleName = '%@' order by fieldIndex ",
                    userDefinedFieldsTable,TimesheetEntry_CellLevel];
	NSMutableArray *cellLeveludfDetailsArray = [myDB executeQueryToConvertUnicodeValues:sqlCellLevel];
	NSMutableArray *udfDetailsArray=nil;
    if ((rowLevelUdfDetailsArray != nil && [rowLevelUdfDetailsArray count]>0) || (cellLeveludfDetailsArray != nil && [cellLeveludfDetailsArray count]>0) ) 
    {
        udfDetailsArray=[NSMutableArray array];
         if ((rowLevelUdfDetailsArray != nil && [rowLevelUdfDetailsArray count]>0))
         {
             [udfDetailsArray addObjectsFromArray:rowLevelUdfDetailsArray];
         }
        if ((cellLeveludfDetailsArray != nil && [cellLeveludfDetailsArray count]>0))
        {
            [udfDetailsArray addObjectsFromArray:cellLeveludfDetailsArray];
        }
    }
	if (udfDetailsArray != nil && [udfDetailsArray count]>0) {
		return udfDetailsArray;
	}
	return nil;
}

-(NSMutableArray *)getEnabledOnlyTimeOffsUDFsForCellAndRow {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql =[NSString stringWithFormat:@"select * from %@ where enabled = 1 and hidden=0 and moduleName = '%@' order by fieldIndex asc ",
                    userDefinedFieldsTable,TimeOffs_SheetLevel];
	NSMutableArray *udfDetailsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	//DLog(@"Udfs count %d",[udfDetailsArray count]);
	if (udfDetailsArray != nil && [udfDetailsArray count]>0) {
		return udfDetailsArray;
	}
	return nil;
}
-(NSArray *)getEnabledOnlyCellLevelUDFsForGPSTracking {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    NSString *sqlCellLevel =[NSString stringWithFormat:@"select * from %@ where enabled = 1 and hidden=1 and  moduleName = '%@' order by fieldIndex ",
                             userDefinedFieldsTable,TimesheetEntry_CellLevel];
	NSArray *cellLeveludfDetailsArray = [myDB executeQueryToConvertUnicodeValues:sqlCellLevel];
    if (cellLeveludfDetailsArray != nil && [cellLeveludfDetailsArray count]>0)
    {
        return cellLeveludfDetailsArray;
    }
	
	return nil;
}


#pragma mark -
#pragma mark Update Methods
-(void)updateEditedTimeEntry:(G2TimeSheetEntryObject *)_timeEntryObject andStatus:(NSString *)_status{
	DLog(@"updateEditedTimeEntry:::::TimeSheetModel");
	
	NSString *identity			= [_timeEntryObject identity];
	NSString *sheetIdentity		= [_timeEntryObject sheetId];
	NSDate   *entryDate			= [_timeEntryObject entryDate];
	//NSString *entryDateString	= [Util convertPickerDateToString:entryDate];
	
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *decimalDuration=nil;
//    NSNumber *decimalHrs=nil;
//    NSString *stringDuration=nil;
    if (!appDelegate.isLockedTimeSheet) {
        decimalDuration	= [_timeEntryObject numberOfHours];
//        decimalHrs        = [Util convertDecimalStringToDecimalNumber:decimalDuration];
//        stringDuration	= [Util convertDecimalTimeToHourFormat:decimalHrs];
    }
	else
    {
        //DO NOTHING FOR LOCKED IN/OUT
    }
	
	NSString *clientIdentity	= [_timeEntryObject clientIdentity];
	NSString *clientName		= [_timeEntryObject clientName];
	NSString *projectIdentity	= [_timeEntryObject projectIdentity];
	NSString *projectName		= [_timeEntryObject projectName];
	//NSString *taskIdentity		= [_timeEntryObject taskIdentity];
	//NSString *taskName			= [_timeEntryObject taskName];
	NSString *taskIdentity		= [_timeEntryObject.taskObj taskIdentity];
	NSString *taskName			= [_timeEntryObject.taskObj taskName];
	
	NSString *billingIdentity	= [_timeEntryObject billingIdentity];
	NSString *billingName		= [_timeEntryObject billingName];
	NSNumber *projectRoleId		= [_timeEntryObject projectRoleId];
	NSString *activityIdentity	= [_timeEntryObject activityIdentity];
	NSString *activityName		= [_timeEntryObject activityName];
	NSString *comments			= [_timeEntryObject comments];
    
    NSString *inTime			= [_timeEntryObject inTime];
    NSString *outTime			= [_timeEntryObject outTime];
	
	NSNumber *isModified		= [NSNumber numberWithInt:1];
	NSString *editStatus		= _status;
	NSString *entryType			= TIMESHEET_TIMEENTRY_TYPE;
	
	NSDictionary *entryDateDict    = [G2Util convertDateToApiDateDictionary:entryDate];
	NSString     *entryDateString  = [G2Util convertApiDateDictToDateString:entryDateDict];
    
	G2SQLiteDB *myDB				= [G2SQLiteDB getInstance];
	NSString *whereString		= [NSString stringWithFormat:@"identity='%@'",identity];
	
	NSMutableDictionary *entryDict = [NSMutableDictionary dictionary];
	
    
    if (inTime != nil && ![inTime isKindOfClass:[NSNull class]]) {
		[entryDict setObject:inTime forKey:@"time_in"];
	}
    if (outTime != nil && ![outTime isKindOfClass:[NSNull class]]) {
		[entryDict setObject:outTime forKey:@"time_out"];
	}
	if (entryDateString != nil && ![entryDateString isKindOfClass:[NSNull class]]) {
		[entryDict setObject:entryDateString forKey:@"entryDate"];
	}
	if (clientIdentity != nil && ![clientIdentity isKindOfClass:[NSNull class]]) {
		[entryDict setObject:clientIdentity forKey:@"clientIdentity"];
	}
	if (clientName != nil && ![clientName isKindOfClass:[NSNull class]]) {
		[entryDict setObject:clientName forKey:@"clientName"];
	}
	if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]]) {
		[entryDict setObject:projectIdentity forKey:@"projectIdentity"];
	}else {
		projectIdentity = @"";
		[entryDict setObject:projectIdentity forKey:@"projectIdentity"];
	}
    
	if (projectName != nil && ![projectName isKindOfClass:[NSNull class]]) {
		[entryDict setObject:projectName forKey:@"projectName"];
	}else {
		projectName = @"";
		[entryDict setObject:projectName forKey:@"projectName"];
	}
    
	if (taskIdentity != nil && ![taskIdentity isKindOfClass:[NSNull class]]) {
		[entryDict setObject:taskIdentity forKey:@"taskIdentity"];
	}else {
		taskIdentity = @"";
		[entryDict setObject:taskIdentity forKey:@"taskIdentity"];
	}
    
	if (taskName != nil && ![taskName isKindOfClass:[NSNull class]]) {
		[entryDict setObject:taskName forKey:@"taskName"];
	}else {
		taskName = @"";
		[entryDict setObject:taskName forKey:@"taskName"];
	}
    
	if (billingIdentity != nil && ![billingIdentity isKindOfClass:[NSNull class]]) {
		if (projectRoleId != nil && ![projectRoleId isKindOfClass:[NSNull class]]) {
			billingIdentity = billingName;
		}
		[entryDict setObject:billingIdentity forKey:@"billingIdentity"];
	}
	if (billingName != nil && ![billingName isKindOfClass:[NSNull class]]) {
		[entryDict setObject:billingName forKey:@"billingName"];
	}
	if (comments != nil && ![comments isKindOfClass:[NSNull class]]) {
		[entryDict setObject:comments forKey:@"comments"];
	}
//	if (stringDuration != nil && ![stringDuration isKindOfClass:[NSNull class]]) {
//		[entryDict setObject:stringDuration forKey:@"durationHourFormat"];
//	}
	if (decimalDuration != nil && ![decimalDuration isKindOfClass:[NSNull class]]) {
		[entryDict setObject:decimalDuration forKey:@"durationDecimalFormat"];
	}
	if (activityIdentity != nil && ![activityIdentity isKindOfClass:[NSNull class]]) {
		[entryDict setObject:activityIdentity forKey:@"activityIdentity"];
	}
	if (activityName != nil && ![activityName isKindOfClass:[NSNull class]]) {
		[entryDict setObject:activityName forKey:@"activityName"];
	}
	if (sheetIdentity != nil && ![sheetIdentity isKindOfClass:[NSNull class]]) {
		[entryDict setObject:sheetIdentity forKey:@"sheetIdentity"];
	}
	[entryDict setObject:isModified forKey:@"isModified"];
	[entryDict setObject:editStatus forKey:@"editStatus"];
	[entryDict setObject:entryType	forKey:@"entryType"];
	
    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (appdelegate.isInOutTimesheet) {
        if (([entryDict objectForKey:@"time_in"]!=nil && ![[entryDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"time_out"]!=nil && ![[entryDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"durationHourFormat"] !=nil && ![[entryDict objectForKey:@"durationHourFormat"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"durationHourFormat"] isEqualToString:@"0:0"] )  || ([entryDict objectForKey:@"comments"]!=nil && ![[entryDict objectForKey:@"comments"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"comments"] isEqualToString:@""] ) ) 
        {
            [myDB updateTable:timeEntriesTable data:entryDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB deleteFromTable:timeEntriesTable where:whereString inDatabase:@""];
        }

    }
    else
    {
        [myDB updateTable:timeEntriesTable data:entryDict where:whereString intoDatabase:@""];
    }
   
    //DE4274//Juhi
    NSString *deleteWhereString = [NSString stringWithFormat:@"entry_id = '%@' ",identity];
    [myDB deleteFromTable:entryUDFSTable where:deleteWhereString inDatabase:@""];
    
    NSMutableArray *rowUDFArr=[_timeEntryObject rowUDFArray];
    for (int k=0; k<[rowUDFArr count]; k++) {
        NSDictionary *rowUDFDict=[rowUDFArr objectAtIndex:k];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterNoStyle];
        NSNumber * entryIDNumber = [f numberFromString:[_timeEntryObject identity]];
        
        [self savetimesheetSheetUdfsFromApiToDB:rowUDFDict withSheetIdentity:entryIDNumber andModuleName:TaskTimesheet_RowLevel];
    }
    NSMutableArray *cellUDFArr=[_timeEntryObject cellUDFArray];
    for (int k=0; k<[cellUDFArr count]; k++) {
        NSDictionary *cellUDFDict=[cellUDFArr objectAtIndex:k];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterNoStyle];
        NSNumber * entryIDNumber = [f numberFromString:[_timeEntryObject identity]];
        
        [self savetimesheetSheetUdfsFromApiToDB:cellUDFDict withSheetIdentity:entryIDNumber andModuleName:TimesheetEntry_CellLevel];
    }
    
    
    
    
    
	
}

-(void)updateEditedTimeOffEntry:(G2TimeOffEntryObject *)_timeOffEntryObject andStatus:(NSString *)_status
{
	DLog(@"updateEditedTimeEntry:::::TimeSheetModel");
	
	NSString *identity			= [_timeOffEntryObject identity];
	NSString *sheetIdentity		= [_timeOffEntryObject sheetId];
	NSDate   *entryDate			= [_timeOffEntryObject timeOffDate];
	NSString *typeIdentity      = [_timeOffEntryObject typeIdentity];
    
    
    NSString *decimalDuration=nil;
        NSNumber *decimalHrs=nil;
        NSString *stringDuration=nil;
    
        decimalDuration	= [_timeOffEntryObject numberOfHours];
        decimalHrs        = [G2Util convertDecimalStringToDecimalNumber:decimalDuration];
        stringDuration	= [G2Util convertDecimalTimeToHourFormat:decimalHrs];
   
	
    NSString *comments			= [_timeOffEntryObject comments];
    
    NSString *timeOffTypeName  =[_timeOffEntryObject timeOffCodeType];
	
	NSNumber *isModified		= [NSNumber numberWithInt:1];
	NSString *editStatus		= _status;
	NSString *entryType			= TIMESHEET_TIMEOFF_TYPE;
	
	NSDictionary *entryDateDict    = [G2Util convertDateToApiDateDictionary:entryDate];
	NSString     *entryDateString  = [G2Util convertApiDateDictToDateString:entryDateDict];
    
	G2SQLiteDB *myDB				= [G2SQLiteDB getInstance];
	NSString *whereString		= [NSString stringWithFormat:@"identity='%@' and sheetIdentity='%@' and entryType='%@'",identity,sheetIdentity,entryType];
	
	NSMutableDictionary *entryDict = [NSMutableDictionary dictionary];
	
    

	if (entryDateString != nil && ![entryDateString isKindOfClass:[NSNull class]]) {
		[entryDict setObject:entryDateString forKey:@"entryDate"];
	}
	
	if (comments != nil && ![comments isKindOfClass:[NSNull class]]) {
		[entryDict setObject:comments forKey:@"comments"];
	}
    //	if (stringDuration != nil && ![stringDuration isKindOfClass:[NSNull class]]) {
    //		[entryDict setObject:stringDuration forKey:@"durationHourFormat"];
    //	}
	if (decimalDuration != nil && ![decimalDuration isKindOfClass:[NSNull class]]) {
		[entryDict setObject:decimalDuration forKey:@"durationDecimalFormat"];
        [entryDict setObject:stringDuration forKey:@"durationHourFormat"];
	}
	
	if (sheetIdentity != nil && ![sheetIdentity isKindOfClass:[NSNull class]]) {
		[entryDict setObject:sheetIdentity forKey:@"sheetIdentity"];
	}
    
    
    if (typeIdentity != nil && ![typeIdentity isKindOfClass:[NSNull class]]) {
		[entryDict setObject:typeIdentity forKey:@"timeOffIdentity"];
	}
    
	[entryDict setObject:isModified forKey:@"isModified"];
	[entryDict setObject:editStatus forKey:@"editStatus"];
	[entryDict setObject:entryType	forKey:@"entryType"];
    [entryDict setObject:timeOffTypeName	forKey:@"timeOffTypeName"];
	
    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (appdelegate.isInOutTimesheet) {
        if (([entryDict objectForKey:@"time_in"]!=nil && ![[entryDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"time_out"]!=nil && ![[entryDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"durationHourFormat"] !=nil && ![[entryDict objectForKey:@"durationHourFormat"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"durationHourFormat"] isEqualToString:@"0:0"] )  || ([entryDict objectForKey:@"comments"]!=nil && ![[entryDict objectForKey:@"comments"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"comments"] isEqualToString:@""] ) ) 
        {
            [myDB updateTable:timeEntriesTable data:entryDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB deleteFromTable:timeEntriesTable where:whereString inDatabase:@""];
        }
        
    }
    else
    {
        [myDB updateTable:timeEntriesTable data:entryDict where:whereString intoDatabase:@""];
    }
    
    //DE4274//Juhi
    NSString *deleteWhereString = [NSString stringWithFormat:@"entry_id = '%@' ",identity];
    [myDB deleteFromTable:entryUDFSTable where:deleteWhereString inDatabase:@""];
    
    NSMutableArray *uUDFArr=[_timeOffEntryObject udfArray];
    for (int k=0; k<[uUDFArr count]; k++) {
        NSDictionary *rowUDFDict=[uUDFArr objectAtIndex:k];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterNoStyle];
        NSNumber * entryIDNumber = [f numberFromString:[_timeOffEntryObject identity]];
       
        [self savetimesheetSheetUdfsFromApiToDB:rowUDFDict withSheetIdentity:entryIDNumber andModuleName:TimeOffs_SheetLevel];
    }
    
}

-(void)updateSheetModifyStatus:(NSString *)sheetIdentity status:(BOOL)_status {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:_status] forKey:@"isModified"];
	NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",sheetIdentity];
	[myDB updateTable:timesheetsTable data:dataDict where:whereString intoDatabase:@""];
}

-(void)updatePunchClockPunchData:(NSString *)sheetIdentity andEntryIdentity:(NSString *)entryIdentity status:(BOOL)_status {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:_status] forKey:@"isEnabled"];
	NSString *whereString = [NSString stringWithFormat:@"identity = '%@' and sheetIdentity= '%@' " ,entryIdentity ,sheetIdentity];
	[myDB updateTable:punchClocktimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
}

-(NSMutableArray *)getModifiedTimesheets {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = @"isModified = 1";
	NSMutableArray *timeSheetArray = [myDB select:@"*" from:timesheetsTable where:whereString intoDatabase:@""];
	if (timeSheetArray != nil && [timeSheetArray count] >0) {
		return timeSheetArray;
	}
	return nil;
}

-(NSMutableArray *)getPunchClockTimeentries {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = @"isEnabled = 1";
	NSMutableArray *timeSheetArray = [myDB select:@"*" from:punchClocktimeEntriesTable where:whereString intoDatabase:@""];
	if (timeSheetArray != nil && [timeSheetArray count] >0) {
		return timeSheetArray;
	}
	return nil;
}


-(NSMutableArray *)getOfflineCreatedTimeEntries:(NSString *)sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entryType = 'timeEntry' and editStatus = 'create' and sheetIdentity = '%@'",sheetIdentity];
	NSMutableArray *entriesArr = [myDB select:@"*" from:timeEntriesTable where:whereString intoDatabase:@""];
	if (entriesArr != nil && [entriesArr count]!=0) {
		return entriesArr;
	}
	return nil;
}
-(NSMutableArray *)getOfflineEditedTimeEntries:(NSString *)sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entryType = 'timeEntry' and editStatus = 'edit' and sheetIdentity = '%@'",sheetIdentity];
	NSMutableArray *entriesArr = [myDB select:@"*" from:timeEntriesTable where:whereString intoDatabase:@""];
	if (entriesArr != nil && [entriesArr count]!=0) {
		return entriesArr;
	}
	return nil;
}
-(NSMutableArray *)getOfflineDeletedTimeEntries:(NSString *)sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entryType = 'timeEntry' and editStatus = 'delete' and sheetIdentity = '%@'",sheetIdentity];
	NSMutableArray *entriesArr = [myDB select:@"*" from:timeEntriesTable where:whereString intoDatabase:@""];
	if (entriesArr != nil && [entriesArr count]!=0) {
		return entriesArr;
	}
	return nil;
}

-(NSMutableArray *)getOfflineCreatedTimeEntriesWithoutSheet {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entryType = 'timeEntry' and editStatus = 'create' and sheetIdentity is null"];
	NSMutableArray *entriesArr = [myDB select:@"*" from:timeEntriesTable where:whereString intoDatabase:@""];
	if (entriesArr != nil && [entriesArr count]!=0) {
		return entriesArr;
	}
	return nil;
}

- (void) removeOfflineCreatedEntries: (NSString *)sheetId {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"editStatus = 'create' and sheetIdentity = '%@'",sheetId];
	[myDB deleteFromTable:timeEntriesTable where:whereString inDatabase:@""];
}

-(void)resetEntriesModifyStatus:(NSString *)sheetId {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSDictionary *entriesModifiedDict = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"editStatus",[NSNumber numberWithInt:0],@"isModified",nil];
	NSString *entryWhereString = [NSString stringWithFormat:@"sheetIdentity = '%@'",sheetId];
	[myDB updateTable:timeEntriesTable data:entriesModifiedDict where:entryWhereString intoDatabase:@""];
}

-(void)deleteUnmModifiedTimesheets {
	G2SQLiteDB *myDB =[G2SQLiteDB getInstance];
	
	
	NSString *queryUdfs=[NSString stringWithFormat:@"delete from entry_udfs where entry_id not in(select identity from time_entries where isModified=1) and entry_type = 'TimesheetLevel'  "];
	[myDB executeQuery:queryUdfs];
	
	NSString *queryEntries=[NSString stringWithFormat:@"delete from time_entries where sheetIdentity in(select identity from timesheets where isModified = 0)"];
	[myDB executeQuery:queryEntries];
	
	NSString *query=[NSString stringWithFormat:@"delete from timesheets where isModified = 0 "];
	[myDB executeQuery:query];
}

-(NSMutableArray *)getTimeSheetsStartAndEndDates{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select identity,startDate,endDate from %@ order by startDate asc"
					 ,timesheetsTable];
	NSMutableArray *dateArray = [myDB executeQuery:sql];
	
	if (dateArray != nil && [dateArray count]>0) {
		return dateArray;
	}
	return nil;
}
-(void)saveBookedTimeOffEntriesIntoDB:(NSMutableArray *)timeOffEntries{
	//DLog(@"timeOffEntries count %d",[timeOffEntries count]);
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *_sheetId=nil;
    if (timeOffEntries != nil & [timeOffEntries count]>0) {
		for (int i =0; i <[timeOffEntries count];i++ )
        {
            NSDictionary *timeOffDict        = [timeOffEntries objectAtIndex:i];
            NSDictionary *startDateDict      = [[timeOffDict objectForKey:@"Properties"] objectForKey:@"StartDate"];
            NSString *startDate      = nil;
            if (startDateDict != nil && ![startDateDict isKindOfClass:[NSNull class]]) {
				startDate  = [G2Util convertApiDateDictToDateString:startDateDict];
				if (startDate != nil && ![startDate isKindOfClass:[NSNull class]]) {
                    NSString *sql=[NSString stringWithFormat:@"select identity from timesheets where '%@' BETWEEN startDate and endDate",startDate];
                    NSArray *sheetIdArr=[myDB executeQuery:sql];
                    if (sheetIdArr!=nil && [sheetIdArr count]>0)
                    {
                        _sheetId=[[sheetIdArr objectAtIndex:0]objectForKey:@"identity"];
                        
                        NSString *entriesDeleteString = [NSString stringWithFormat:@"sheetId = '%@'",_sheetId];
                        [myDB deleteFromTable:bookingsTable where:entriesDeleteString inDatabase:@""];
                        
                        //Fix for 3051//Juhi
                        NSString *deleteString = [NSString stringWithFormat:@"sheetIdentity = '%@'",_sheetId];
                        [myDB deleteFromTable:bookedTimeOffTable where:deleteString inDatabase:@""];
                    }
				}
				
			}
        }
    }
    
	
	
	if (timeOffEntries != nil & [timeOffEntries count]>0) {
		for (int i =0; i <[timeOffEntries count];i++ ) {
			NSString *approvalStatus = nil;
			NSString *startDate      = nil;
			NSString *endDate        = nil;
			NSString *modifiedOn     = nil;
			NSString *modifiedOnUtc  = nil;
			NSString *submittedDate  = nil;
			NSString *timeOffType    = nil;
			NSString *typeIdentity	 = nil;
			
			NSMutableDictionary *bookingDetailsDict = [NSMutableDictionary dictionary];
			NSDictionary *timeOffDict        = [timeOffEntries objectAtIndex:i];
			NSString *bookingId              = [timeOffDict objectForKey:@"Identity"];
			NSString *comments               = [[timeOffDict objectForKey:@"Properties"] objectForKey:@"Comments"];
			NSDictionary *startDateDict      = [[timeOffDict objectForKey:@"Properties"] objectForKey:@"StartDate"];
			NSDictionary *endDateDict        = [[timeOffDict objectForKey:@"Properties"] objectForKey:@"EndDate"];
			NSDictionary *submittedDateDict  = [[timeOffDict objectForKey:@"Properties"] objectForKey:@"TimeOffSubmittedOn"]; 
			NSDictionary *approvalStatusDict = [[timeOffDict objectForKey:@"Relationships"]objectForKey:@"ApprovalStatus"];
			NSDictionary *timeOffCodeDict    = [[[timeOffDict objectForKey:@"Relationships"]objectForKey:@"TimeOffCode"]objectForKey:@"Properties"];
			NSDictionary *modifiedOnDict     = [[timeOffDict objectForKey:@"Properties"] objectForKey:@"ModifiedOn"];
			NSDictionary *modifiedOnUtcDict  = [[timeOffDict objectForKey:@"Properties"] objectForKey:@"ModifiedOnUtc"];
			NSDictionary *durationDict       = [[timeOffDict objectForKey:@"Properties"]objectForKey:@"TotalDuration"];
			
			NSMutableArray  *bookedEntriesArray			 = [[[timeOffEntries objectAtIndex:i]objectForKey:@"Relationships"] objectForKey:@"Entries"];
			NSMutableDictionary *timeOffAttributesDict = [NSMutableDictionary dictionary];
			
			
			typeIdentity  = [[[timeOffDict objectForKey:@"Relationships"]objectForKey:@"TimeOffCode"]objectForKey:@"Identity"];
			
			if (startDateDict != nil && ![startDateDict isKindOfClass:[NSNull class]]) {
				startDate  = [G2Util convertApiDateDictToDateString:startDateDict];
				if (startDate != nil && ![startDate isKindOfClass:[NSNull class]]) {
					[bookingDetailsDict setObject:startDate       forKey:@"startDate"];
                    NSString *sql=[NSString stringWithFormat:@"select identity from timesheets where '%@' BETWEEN startDate and endDate",startDate];
                    NSArray *sheetIdArr=[myDB executeQuery:sql];
                    if (sheetIdArr!=nil && [sheetIdArr count]>0)
                    {
                        _sheetId=[[sheetIdArr objectAtIndex:0]objectForKey:@"identity"];
                    }
                }
				
			}
			if (endDateDict != nil && ![endDateDict isKindOfClass:[NSNull class]]) {
				endDate     = [G2Util convertApiDateDictToDateString:endDateDict];
				if (endDate != nil && ![endDate isKindOfClass:[NSNull class]])
					[bookingDetailsDict setObject:endDate         forKey:@"endDate"];
			}
			if (submittedDateDict != nil && ![submittedDateDict isKindOfClass:[NSNull class]]) {
				submittedDate = [G2Util convertApiDateDictToDateString:submittedDateDict];
				if (submittedDate != nil && ![submittedDate isKindOfClass:[NSNull class]])
					[bookingDetailsDict setObject:submittedDate   forKey:@"submittedOn"];
			}
			if (approvalStatusDict != nil && ![approvalStatusDict isKindOfClass:[NSNull class]]) {
				approvalStatus = [G2Util getApprovalStatusBasedFromApiStatus:approvalStatusDict];
				if (approvalStatus != nil && ![approvalStatus isKindOfClass:[NSNull class]])
                    [timeOffAttributesDict setObject:approvalStatus   forKey:@"approvalStatus"];
			}
			
			if (timeOffCodeDict != nil && ![timeOffCodeDict isKindOfClass:[NSNull class]]) {
				timeOffType = [timeOffCodeDict objectForKey:@"Name"];
				if (timeOffType != nil && ![timeOffType isKindOfClass:[NSNull class]])
					[timeOffAttributesDict setObject:timeOffType	  forKey:@"typeName"];
			}
			if(modifiedOnDict != nil && ![modifiedOnDict isKindOfClass:[NSNull class]]) {
				modifiedOn = [G2Util convertApiDateDictToDateString:modifiedOnDict];
				if(modifiedOn != nil && ![modifiedOn isKindOfClass:[NSNull class]]) 
					[bookingDetailsDict setObject:modifiedOn      forKey:@"modifiedOn"];
                
			}
			if (modifiedOnUtcDict != nil && ![modifiedOnUtcDict isKindOfClass:[NSNull class]]) {
				modifiedOnUtc = [G2Util convertApiDateDictToDateString:modifiedOnUtcDict];
				if (modifiedOnUtc != nil && ![modifiedOnUtc isKindOfClass:[NSNull class]]) 
					[bookingDetailsDict setObject:modifiedOnUtc   forKey:@"modifiedOnUtc"];
			}
			
			if (durationDict != nil && ![durationDict isKindOfClass:[NSNull class]]) {
				NSNumber *decimalDuration  = [G2Util convertApiTimeDictToDecimal:durationDict];
				NSString *hoursDuration    = [G2Util convertApiTimeDictToString:durationDict];
				[bookingDetailsDict setObject:decimalDuration forKey:@"totalBookingDecimalDuration"];
				[bookingDetailsDict setObject:hoursDuration   forKey:@"totalBookingHourDuration"];
			}
			
			if ([comments isKindOfClass:[NSNull class]]) {
				comments = @"";
			}
			
			if (typeIdentity != nil && ![typeIdentity isKindOfClass:[NSNull class]]) {
				[timeOffAttributesDict setObject:typeIdentity forKey:@"typeIdentity"];
			}
			
			[timeOffAttributesDict setObject:comments         forKey:@"comments"];
            
			if (_sheetId != nil && ![_sheetId isKindOfClass:[NSNull class]])
                [timeOffAttributesDict setObject:_sheetId		  forKey:@"sheetIdentity"];
			
			if (bookingId != nil && ![bookingId isKindOfClass:[NSNull class]]) 
				[timeOffAttributesDict setObject:bookingId		  forKey:@"bookingIdentity"];
			
			if (bookingId != nil && ![bookingId isKindOfClass:[NSNull class]]) {
				[bookingDetailsDict setObject:bookingId forKey:@"bookingId"];
			}
			
			
			
			
			if (_sheetId != nil && ![_sheetId isKindOfClass:[NSNull class]])
				[bookingDetailsDict setObject:_sheetId		  forKey:@"sheetId"];
			
			//Save Bookings
			
			NSMutableArray *bookings = [self getTimeOffBookingsForBookingId:bookingId];
			if (bookings != nil && [bookings count]>0) {
				//DLog(@"update bookings::TimeSheetModel");
				NSString *whereString=[NSString stringWithFormat:@"bookingId='%@'",bookingId];
				[myDB updateTable:bookingsTable data:bookingDetailsDict where:whereString intoDatabase:@""];
			}else {
				//DLog(@"insert bookings::TimeSheetModel");
				[myDB insertIntoTable:bookingsTable data:bookingDetailsDict intoDatabase:@""];
			}
			
			
			//Save Booking Entries
			[self saveBookingsForEachBooking:bookedEntriesArray attributes:timeOffAttributesDict];
			
		}
        //DE4275//Juhi
//	 [[NSNotificationCenter defaultCenter]postNotificationName:NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION object:[NSDictionary dictionary]];//DE4004
    }
    
//    else{
//        [[NSNotificationCenter defaultCenter]postNotificationName:NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION object:[NSDictionary dictionary]];//DE4004
//    }
}
-(void)saveBookingsForEachBooking:(NSMutableArray *)entriesArray attributes:(NSMutableDictionary *)detailsDict{
	DLog(@"saveBookingsForEachBooking::TimeSheetModel");
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
   	if (entriesArray != nil && [entriesArray count]>0) {
		for (int i= 0; i<[entriesArray count]; i++) {
			
			NSString *entryDate						= nil;
			NSString *entryType						= TIMESHEET_BOOKED_TIMEOFF;
			NSDictionary *entryDetailsDict			= [entriesArray objectAtIndex:i];
			NSDictionary *entryDateDict				= [[entryDetailsDict objectForKey:@"Properties"] objectForKey:@"EntryDate"];
			NSDictionary *entryDurationDict			= [[entryDetailsDict objectForKey:@"Properties"] objectForKey:@"Duration"];
			NSString *identity						= [entryDetailsDict objectForKey:@"Identity"];
			NSString *sheetId						= nil;
			NSString *bookingId						= nil;
			if (detailsDict != nil) {
				if (entryDateDict != nil && ![entryDateDict isKindOfClass:[NSNull class]]) {
					entryDate  = [G2Util convertApiDateDictToDateString:entryDateDict];
					[detailsDict setObject:entryDate forKey:@"entryDate"];
				}
				if (identity != nil && ![identity isKindOfClass:[NSNull class]]) {
					[detailsDict setObject:identity forKey:@"identity"];
				}
				if (entryDurationDict != nil && ![entryDurationDict isKindOfClass:[NSNull class]]) {
					NSNumber *decimalDuration  = [G2Util convertApiTimeDictToDecimal:entryDurationDict];
					NSString *hoursDuration    = [G2Util convertApiTimeDictToString:entryDurationDict];
					[detailsDict setObject:decimalDuration forKey:@"decimalDuration"];
					[detailsDict setObject:hoursDuration   forKey:@"hourDuration"];
				}
				sheetId   = [detailsDict objectForKey:@"sheetIdentity"];
				bookingId = [detailsDict objectForKey:@"bookingIdentity"];
				[detailsDict setObject:entryType forKey:@"entryType"];
			}
			
			
			//NSMutableArray *bookedtimeoffs = [self getBookedTimeOffEntryForSheetWithSheetIdentity:sheetId entryId:identity bookingId:bookingId];
			NSMutableArray *bookedtimeoffs = [self getBookedTimeOffEntryForSheetWithSheetIdentity:sheetId entryId:identity bookingId:bookingId];
			if (bookedtimeoffs != nil && [bookedtimeoffs  count]>0) {
				//DLog(@"update booked time off entries::TimeSheetModel");
				NSString *whereString=[NSString stringWithFormat:@"identity ='%@'",identity];
				[myDB updateTable:bookedTimeOffTable data:detailsDict where:whereString intoDatabase:@""];
			}else {
				//DLog(@"insert booked time off entries::TimeSheetModel");
				[myDB insertIntoTable:bookedTimeOffTable data:detailsDict intoDatabase:@""];
			}
			
		}
        // [[NSNotificationCenter defaultCenter]postNotificationName:NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION object:nil];//DE3418
	}
//    [[NSNotificationCenter defaultCenter]postNotificationName:NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION object:[NSDictionary dictionary]];//DE4004
}

-(NSMutableArray *)getBookedTimeOffEntryForSheetWithSheetIdentity:(NSString *)_sheetId 
														  entryId:(NSString *)_entryIdentity bookingId:(NSString *)_bookingId{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:
							 @"entryType = 'bookedtimeOff' and identity = '%@'",
							 _entryIdentity];
	NSMutableArray *bookedtimeoffEntriesArray = [myDB select:@"*" from:bookedTimeOffTable where:whereString intoDatabase:@""];
	if (bookedtimeoffEntriesArray != nil && [bookedtimeoffEntriesArray count]>0) {
		return bookedtimeoffEntriesArray;
	}
	return nil;
}
-(NSMutableArray *)getBookedTimeOffEntryWithIdentity:(NSString *)_entryIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:
							 @"entryType = 'bookedtimeOff' and identity = '%@'",
							 _entryIdentity];
	NSMutableArray *bookedtimeoffEntriesArray = [myDB select:@"*" from:bookedTimeOffTable where:whereString intoDatabase:@""];
	if (bookedtimeoffEntriesArray != nil && [bookedtimeoffEntriesArray count]>0) {
		return bookedtimeoffEntriesArray;
	}
	return nil;
}


-(NSMutableArray*)getTimeOffBookingsForBookingId:(id)bookingIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSString *whereString=[NSString stringWithFormat:@"bookingId='%@'",bookingIdentity];
	NSMutableArray *bookingsArr = [myDB select:@"*" from:bookingsTable where:whereString intoDatabase:@""];
	if (bookingsArr != nil && [bookingsArr count]> 0) {
		return bookingsArr;
	}
	return nil;
}

-(NSMutableArray *)getBookedTimeOffsForSheetId:(NSString *)_sheetIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entryType = 'bookedtimeOff' and sheetIdentity = '%@'",_sheetIdentity];
	NSMutableArray *bookedtimeoffarray = [myDB select:@"*" from:bookedTimeOffTable where:whereString intoDatabase:@""];
	if (bookedtimeoffarray != nil && [bookedtimeoffarray count]>0) {
		return bookedtimeoffarray;
	}
	return nil;
}
-(NSMutableArray *)getAllBookedTimeOffEntries{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *bookedTimeOffArray = [myDB select:@"*" from:bookedTimeOffTable where:@"" intoDatabase:@""];
	if (bookedTimeOffArray != nil && [bookedTimeOffArray count]>0) {
		return bookedTimeOffArray;
	}
	return nil;
	
}
-(NSDictionary *)getTimeSheetPeriodforSheetId:(NSString *)sheetIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select startDate,endDate from %@ where identity = '%@' "
					 ,timesheetsTable,sheetIdentity];
	NSMutableArray *startendDateArr = [myDB executeQuery:sql];
	if (startendDateArr != nil && [startendDateArr count]>0) {
		return [startendDateArr objectAtIndex:0];
	}
	return nil;
}
-(NSMutableArray *)getBookedTimeOffforTimeSheetPeriod:(NSString *)_startDate _endDate:(NSString *)endDate{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where entryDate between '%@' and '%@'order by entryDate desc"
					 ,bookedTimeOffTable,_startDate,endDate];
	NSMutableArray *bookedEntriesArray = [myDB executeQueryToConvertUnicodeValues:sql];//DE6283//Juhi
	if (bookedEntriesArray != nil && [bookedEntriesArray count]>0) {
		return bookedEntriesArray;
	}
	return nil;
}
/*-(NSMutableArray *)getBookedTimeOffDistinctDatesForSheet:(NSString *)sheetidentity{
 SQLiteDB *myDB = [SQLiteDB getInstance];
 NSString *sql = [NSString stringWithFormat:@" select distinct(entryDate) as entrydate from %@ where sheetIdentity ='%@' order by entrydate desc "
 ,bookedTimeOffTable,sheetidentity];
 NSMutableArray *distinctDateArr = [myDB executeQuery:sql];
 if (distinctDateArr != nil && [distinctDateArr count]>0) {
 return distinctDateArr;
 }
 return nil;
 }*/

-(void)deleteTimeEntryWithIdentityForSheet: (NSString *)entryIdentity sheetId: (NSString *)sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
/*    NSString *query = [NSString stringWithFormat:
					   @"select totalHoursDecimalFormat from timesheets where identity = '%@' ",sheetIdentity];
    NSArray *timeArr=[myDB executeQuery:query];
    NSNumber *decimaltime=[NSNumber numberWithFloat:0.0];
    
    if ([timeArr count]>0)
    {
        if (![[[timeArr objectAtIndex:0] objectForKey:@"totalHoursDecimalFormat"] isKindOfClass:[NSNull class]])
        {
            decimaltime=[NSNumber numberWithFloat:[[[timeArr objectAtIndex:0] objectForKey:@"totalHoursDecimalFormat"] floatValue]];
        }
    }
    
    query = [NSString stringWithFormat:
             @"select durationDecimalFormat from time_entries where entryType = 'timeEntry' and identity = '%@' and sheetIdentity = '%@'",entryIdentity,sheetIdentity];
    
    NSArray *deletedTimeArr=[myDB executeQuery:query];
    NSNumber *deletedDecimalTime=[NSNumber numberWithFloat:0.0];
    
    if ([deletedTimeArr count]>0)
    {
        if (![[[deletedTimeArr objectAtIndex:0] objectForKey:@"durationDecimalFormat"] isKindOfClass:[NSNull class]])
        {
            deletedDecimalTime=[NSNumber numberWithFloat:[[[deletedTimeArr objectAtIndex:0] objectForKey:@"durationDecimalFormat"] floatValue]];
        }
    }
    
    NSNumber *calculatedDecimalTime=[NSNumber numberWithFloat:0.0];
    
    if ([decimaltime floatValue]>[deletedDecimalTime floatValue])  {
        calculatedDecimalTime=[NSNumber numberWithFloat:[decimaltime floatValue]-[deletedDecimalTime floatValue]];
    }
    else
    {
        calculatedDecimalTime=[NSNumber numberWithFloat:[deletedDecimalTime floatValue]-[decimaltime floatValue]];
    }
    
    NSString *stringDuration = [Util convertDecimalTimeToHourFormat:calculatedDecimalTime];
    
    NSDictionary *dataDict=[NSDictionary dictionaryWithObjectsAndKeys:stringDuration,@"totalHoursFormat",calculatedDecimalTime,@"totalHoursDecimalFormat", nil];
    
    [myDB updateTable:timesheetsTable data:dataDict where:[NSString stringWithFormat:
                                                           @" identity = '%@'",sheetIdentity] intoDatabase:@""];
    */
    
	 NSString *query = [NSString stringWithFormat:
					   @"delete from time_entries where entryType = 'timeEntry' and identity = '%@' and sheetIdentity = '%@'",entryIdentity,sheetIdentity];
	[myDB executeQuery:query];
}

-(void)deleteTimeOffEntryWithIdentityForSheet: (NSString *)entryIdentity sheetId: (NSString *)sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
/*    NSString *query = [NSString stringWithFormat:
					   @"select totalHoursDecimalFormat from timesheets where identity = '%@'" ,sheetIdentity];
    NSArray *timeArr=[myDB executeQuery:query];
    NSNumber *decimaltime=[NSNumber numberWithFloat:0.0];
    
    if ([timeArr count]>0)
    {
        if (![[[timeArr objectAtIndex:0] objectForKey:@"totalHoursDecimalFormat"] isKindOfClass:[NSNull class]])
        {
            decimaltime=[NSNumber numberWithFloat:[[[timeArr objectAtIndex:0] objectForKey:@"totalHoursDecimalFormat"] floatValue]];
        }
    }
    
    query = [NSString stringWithFormat:
             @"select durationDecimalFormat from time_entries where entryType = 'timeOff' and identity = '%@' and sheetIdentity = '%@'",entryIdentity,sheetIdentity];
    
    NSArray *deletedTimeArr=[myDB executeQuery:query];
    NSNumber *deletedDecimalTime=[NSNumber numberWithFloat:0.0];
    
    if ([deletedTimeArr count]>0)
    {
        if (![[[deletedTimeArr objectAtIndex:0] objectForKey:@"durationDecimalFormat"] isKindOfClass:[NSNull class]])
        {
            deletedDecimalTime=[NSNumber numberWithFloat:[[[deletedTimeArr objectAtIndex:0] objectForKey:@"durationDecimalFormat"] floatValue]];
        }
    }
    
    NSNumber *calculatedDecimalTime=[NSNumber numberWithFloat:0.0];
    
    if ([decimaltime floatValue]>[deletedDecimalTime floatValue]) {
        calculatedDecimalTime=[NSNumber numberWithFloat:[decimaltime floatValue]-[deletedDecimalTime floatValue]];
    }
    else
    {
        calculatedDecimalTime=[NSNumber numberWithFloat:[deletedDecimalTime floatValue]-[decimaltime floatValue]];
    }
    
    NSString *stringDuration = [Util convertDecimalTimeToHourFormat:calculatedDecimalTime];
    
    NSDictionary *dataDict=[NSDictionary dictionaryWithObjectsAndKeys:stringDuration,@"totalHoursFormat",calculatedDecimalTime,@"totalHoursDecimalFormat", nil];
    
    [myDB updateTable:timesheetsTable data:dataDict where:[NSString stringWithFormat:
                                                           @" identity = '%@'",sheetIdentity] intoDatabase:@""];
 
 */
    
	 NSString *query = [NSString stringWithFormat:
					   @"delete from time_entries where entryType = 'timeOff' and identity = '%@' and sheetIdentity = '%@'",entryIdentity,sheetIdentity];
	[myDB executeQuery:query];
}

-(void)removeWtsDeletedSheetsFromDB:(id)responseArray
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	if (responseArray != nil && [(NSMutableArray *)responseArray count] > 0) {
		NSDictionary *respDict = [responseArray objectAtIndex:0];
		NSArray *keysArray = [respDict allKeys];
		if (keysArray != nil && [keysArray count] > 0) {
			for (int i=0; i < [keysArray count]; i++) {
				if ([[respDict objectForKey:[keysArray objectAtIndex:i]]intValue] == 0) {
					NSString *sqlQuer = [NSString stringWithFormat:@"delete from timesheets where identity = '%@'",[keysArray objectAtIndex:i]];
                    NSString *sqlQuery = [NSString stringWithFormat:@"delete from time_entries where sheetIdentity = '%@'",[keysArray objectAtIndex:i]];//DE7719 Ullas M L
					[myDB executeQuery:sqlQuer];
                    [myDB executeQuery:sqlQuery];//DE7719 Ullas M L
				}
			}
			
		}
	}
}

-(void)deleteTasksFromDB {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	[myDB deleteFromTable:projectTasksTable inDatabase:@""];
}

-(NSMutableDictionary*) getSelectedUdfsForEntry:(NSString *)entryId andType:(NSString*)entryType andUDFName:(NSString *)udfName {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *where =[NSString stringWithFormat:@"entry_id ='%@' and entry_type='%@' and udf_name='%@'",entryId,entryType, [udfName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSMutableArray *udfArray = [myDB select:@"*" from:entryUDFSTable where:where intoDatabase:@""];
	if ([udfArray count] > 0) {
        //		NSMutableDictionary *selectedUdfDict=[NSMutableDictionary dictionary];
        //		for (NSDictionary *udf  in udfArray) {
        //			NSDictionary *udfDict=[NSDictionary dictionaryWithObjectsAndKeys:[udf objectForKey:@"udf_name"],@"udf_name",
        //								   [udf objectForKey:@"udf_id"],@"udf_id",
        //								   [udf objectForKey:@"udfValue"],@"udfValue",
        //								   nil];
        //			[selectedUdfDict setObject: udfDict forKey: [udf objectForKey:@"udf_id"]];
        //		}
		return  [udfArray objectAtIndex:0];
	}
	return nil;
}
//US4591//Juhi
-(NSMutableArray*)getTimeOffUdfsWithIdentity:(id)identity moduleName:(NSString *)module{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSString *whereString=[NSString stringWithFormat:@"identity='%@' and moduleName='%@'",identity ,module];
	NSMutableArray *bookingsArr = [myDB select:@"*" from:userDefinedFieldsTable where:whereString intoDatabase:@""];
	if (bookingsArr != nil && [bookingsArr count]> 0) {
		return bookingsArr;
	}
	return nil;
}

-(NSDictionary *)fetchQueryHandlerAndStartIndexForClientID:(NSString *)clientId
{
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    NSMutableArray *returnArr=[myDB select:@"timesheets_queryHandler,timesheets_StartIndex" from:clientsTable where:[NSString stringWithFormat: @"identity='%@'",clientId] intoDatabase:@""];
    if ([returnArr count]>0) {
        return [returnArr objectAtIndex:0];
    }
    return nil;
}

- (void) updateQueryHandleByClientId:(NSString*)clientId andQueryHandle:(NSString *)queryHandle  andStartIndex:(NSString *)startIndex
{
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
    [myDB updateTable:clientsTable data:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",queryHandle],@"timesheets_queryHandler",startIndex,@"timesheets_StartIndex", nil] where:[NSString stringWithFormat: @"identity='%@'",clientId] intoDatabase:@""];
}

-(float)getTotalBookedTimeOffHoursForSheetIdsFromTimeEntries:(NSMutableArray *)sheetIds{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select sum(durationDecimalFormat) from %@ where sheetIdentity='%@'",timeEntriesTable,[sheetIds objectAtIndex:0]];
    for (int i=1; i<[sheetIds count]; i++)
    {
        sql=[sql stringByAppendingString:[NSString stringWithFormat:@" OR sheetIdentity='%@'",[sheetIds objectAtIndex:i]]];
    }
    NSMutableArray *hoursArray = [myDB executeQuery:sql];
	if ([hoursArray count]>0) {
        if([[[hoursArray objectAtIndex:0]objectForKey:@"sum(durationDecimalFormat)"] isKindOfClass:[NSNull class] ])
        {
            return 0.0;
        }
		return [[[hoursArray objectAtIndex:0]objectForKey:@"sum(durationDecimalFormat)"]floatValue];
	}
   return 0.0;
}

-(float)getTotalBookedTimeOffHoursForSheetIdsFromTimeSheets:(NSMutableArray *)sheetIds{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select sum(totalHoursDecimalFormat) from %@ where identity='%@'",timesheetsTable,[sheetIds objectAtIndex:0]];
    for (int i=1; i<[sheetIds count]; i++)
    {
        sql=[sql stringByAppendingString:[NSString stringWithFormat:@" OR identity='%@'",[sheetIds objectAtIndex:i]]];
    }
    NSMutableArray *hoursArray = [myDB executeQuery:sql];
	if ([hoursArray count]>0) {
        if([[[hoursArray objectAtIndex:0]objectForKey:@"sum(durationDecimalFormat)"] isKindOfClass:[NSNull class] ])
        {
            return 0.0;
        }
		return [[[hoursArray objectAtIndex:0]objectForKey:@"sum(totalHoursDecimalFormat)"]floatValue];
	}
    return 0.0;
}

@end
