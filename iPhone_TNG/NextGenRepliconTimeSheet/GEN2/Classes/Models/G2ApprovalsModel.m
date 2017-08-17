//
//  ApprovalsModel.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/23/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2ApprovalsModel.h"
#import "RepliconAppDelegate.h"


#define approvalTimesheetsTable @"approvals_timesheets"
#define approvalEntryUDFtable   @"approvals_entry_udfs"
#define approvalTimeEntries     @"approvals_time_entries"
#define approvals_bookingsTable           @"timeOffBookings"
#define approvals_bookedTimeOffTable      @"approvals_booked_time_off_entries"
#define userPermissionsTable    @"approvals_userPermissions"
#define approvals_userDefinedFieldsTable    @"approvals_userDefinedFields"
#define approvals_udfDropDownOptions    @"approvals_udfDropDownOptions"
#define approvals_userPreferences  @"approvals_userPreferences"
#define approvals_MealbreaksTable  @"approvals_mealBreaks_entries"
@implementation G2ApprovalsModel


- (id) init
{
	self = [super init];
	if (self != nil) {
		
		
	}
	return self;
}



-(NSMutableArray *) getTimesheetsFromDB {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ order by startDate desc",approvalTimesheetsTable];
	NSMutableArray *timesheetsArray = [myDB executeQuery:sql];
	if ([timesheetsArray count]>0) {
		return timesheetsArray;
	}
	return nil;
}
-(NSMutableArray *) getTimesheetsFromDBForApprovalStatus:(NSString *)statusString {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where approvalStatus='%@'",approvalTimesheetsTable,statusString];
	NSMutableArray *timesheetsArray = [myDB executeQuery:sql];
	if ([timesheetsArray count]>0) {
		return timesheetsArray;
	}
	return nil;
}



-(NSMutableArray *) getTimesheetsFromDBForUserID:(NSString *)userID forApprovalDueDate:(NSString *)approvalDueDate {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where user_identity='%@' and approval_dueDate='%@'  order by startDate desc",approvalTimesheetsTable,userID,approvalDueDate];
	NSMutableArray *timesheetsArray = [myDB executeQuery:sql];
	if ([timesheetsArray count]>0) {
		return timesheetsArray;
	}
	return nil;
}

-(void) saveApprovalsTimesheetsFromApiToDB : (NSMutableArray *)responseArray : (BOOL)isFromTimesheets{
	
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSNumber *sheetIdentity =nil;
    NSNumber *decimalDuration=nil;
    NSNumber *decimalTimeOffDuration=nil;
    NSNumber *decimalOverTimeDuration=nil;
    NSDictionary *endDateDict=nil;
    NSDictionary *startDateDict=nil;
    NSArray *timeEntriesArray=nil;
    NSArray *timeOffsArray=nil;
	for (int i = 0; i<[responseArray count]; i++) {
		
		NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
		NSString *approvalStatus=nil;
		NSDictionary *timesheetDict = [responseArray objectAtIndex:i];
		
		sheetIdentity = [timesheetDict objectForKey:@"Identity"];
		NSNumber *bankOvertime = [NSNumber numberWithBool:
								  [[[timesheetDict objectForKey:@"Properties"] objectForKey:@"BankOvertime"] boolValue]];
		NSDictionary *dueDateDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"DueDate"];
		endDateDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"EndDate"];
		startDateDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"StartDate"];
        NSDictionary *durationDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"TotalHours"];
        NSNumber * timesheetMealBreakPenaltiesCount=[[timesheetDict objectForKey:@"Properties"] objectForKey:@"TimesheetMealBreakPenalties"];
        NSDictionary *durationTimeOffDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"TotalTimeOffHours"];
        NSDictionary *durationOverTimeDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"TotalOvertimeHours"];
		NSDictionary *savedOnDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"SavedOn"];
		NSDictionary *savedOnUtcDict = [[timesheetDict objectForKey:@"Properties"] objectForKey:@"SavedOnUtc"];
		NSNumber *isPaid = [NSNumber numberWithBool:
                            [[[timesheetDict objectForKey:@"Properties"] objectForKey:@"Paid"] boolValue]];
		
		NSDictionary *approvalStatusDict = [[timesheetDict objectForKey:@"Relationships"] 
											objectForKey:@"ApprovalStatus"];
		NSArray *remainingApproversArray = [[timesheetDict objectForKey:@"Relationships"]
											objectForKey:@"RemainingApprovers"];
		NSArray *filteredHistoryArray = [[timesheetDict objectForKey:@"Relationships"]
										 objectForKey:@"FilteredHistory"];
		
		approvalStatus = [G2Util getApprovalStatusBasedFromApiStatus:approvalStatusDict];
        
        if ([approvalStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]) 
        {
            //default values for offline editing status flags
            NSNumber *isModified = [NSNumber numberWithBool:FALSE];
            NSString *editStatus = @"";
            
            NSString *dueDate = [G2Util convertApiDateDictToDateString:dueDateDict];
            NSString *endDate = [G2Util convertApiDateDictToDateString:endDateDict];
            NSString *startDate = [G2Util convertApiDateDictToDateString:startDateDict];
            decimalDuration = [G2Util convertApiTimeDictToDecimal:durationDict];
            NSString *stringDuration = [G2Util convertApiTimeDictToString:durationDict];
            decimalTimeOffDuration = [G2Util convertApiTimeDictToDecimal:durationTimeOffDict];
            NSString *stringTimeoffDuration = [G2Util convertApiTimeDictToString:durationTimeOffDict];
            decimalOverTimeDuration = [G2Util convertApiTimeDictToDecimal:durationOverTimeDict];
            NSString *stringOverTimeDuration = [G2Util convertApiTimeDictToString:durationOverTimeDict];
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
            
            if (decimalTimeOffDuration != nil && ![decimalTimeOffDuration isKindOfClass:[NSNull class]]
                &&[decimalTimeOffDuration isKindOfClass:[NSNumber class]]) {
                [dataDictionary setObject:decimalTimeOffDuration forKey:@"totalTimeOffDecimalFormat"];
            }
            if (stringTimeoffDuration != nil && ![stringTimeoffDuration isKindOfClass:[NSNull class]]
                && ![stringTimeoffDuration isEqualToString:NULL_STRING]) {
                [dataDictionary setObject:stringTimeoffDuration forKey:@"totalTimeOffHoursFormat"];
            }
            
            if (decimalOverTimeDuration != nil && ![decimalOverTimeDuration isKindOfClass:[NSNull class]]
                &&[decimalOverTimeDuration isKindOfClass:[NSNumber class]]) {
                [dataDictionary setObject:decimalOverTimeDuration forKey:@"totalOvertimeDecimalFormat"];
            }
            if (stringOverTimeDuration != nil && ![stringOverTimeDuration isKindOfClass:[NSNull class]]
                && ![stringOverTimeDuration isEqualToString:NULL_STRING]) {
                [dataDictionary setObject:stringOverTimeDuration forKey:@"totalOvertimeHoursFormat"];
            }
            
            if (timesheetMealBreakPenaltiesCount != nil && ![timesheetMealBreakPenaltiesCount isKindOfClass:[NSNull class]]
               ) {
                 [dataDictionary setObject:timesheetMealBreakPenaltiesCount forKey:@"timesheetMealBreakPenaltiesCount"];
            }
          
            
            [dataDictionary setObject:sheetIdentity forKey:@"identity"];
            [dataDictionary setObject:bankOvertime forKey:@"bankOvertime"];
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
            
            NSString *sheetEffectiveDate=[G2Util getEffectiveDate:filteredHistoryArray];
            if (sheetEffectiveDate) {
                [dataDictionary setObject:sheetEffectiveDate forKey:@"effectiveDate"];
            }
            
            
            
            
            //Add the sheet to list of unsubmitted sheets to show resubmit button.
            [G2Util addToUnsubmittedSheets:filteredHistoryArray sheetStatus:approvalStatus 
                                 sheetId:[NSString stringWithFormat:@"%@",sheetIdentity] module: UNSUBMITTED_TIME_SHEETS];
            NSDictionary *userDict = [[timesheetDict objectForKey:@"Relationships"] objectForKey:@"User"];
            NSDictionary *userPropertiesDict = [userDict objectForKey:@"Properties"];
            [dataDictionary setObject:[userPropertiesDict objectForKey:@"FirstName"] forKey:@"user_fname"];
            [dataDictionary setObject:[userPropertiesDict objectForKey:@"LastName"] forKey:@"user_lname"];
            [dataDictionary setObject:[userPropertiesDict objectForKey:@"Id"] forKey:@"user_identity"];
            
            
            NSMutableArray  *approvalDueDateOffsetArray=[self getSystemPreferencesApprovalDueDate];
            
            if (approvalDueDateOffsetArray !=nil && [approvalDueDateOffsetArray count]>0) 
            {
                NSDictionary *approvalDueDateOffsetDict=[approvalDueDateOffsetArray objectAtIndex:0];
                int approvalDueDateOffset=[[approvalDueDateOffsetDict objectForKey:@"status"]intValue];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                [dateFormatter setLocale:locale];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDateComponents *todayComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[dateFormatter dateFromString:dueDate]];
                
                NSInteger theDay = [todayComponents day];
                NSInteger theMonth = [todayComponents month];
                NSInteger theYear = [todayComponents year];
                
                // now build a NSDate object for yourDate using these components
                NSDateComponents *components = [[NSDateComponents alloc] init];
                [components setDay:theDay]; 
                [components setMonth:theMonth]; 
                [components setYear:theYear];
                NSDate *thisDate = [gregorian dateFromComponents:components];
                
                
                // now build a NSDate object for the next day
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setDay:approvalDueDateOffset];
                NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
                [dataDictionary setObject:[dateFormatter stringFromDate:nextDate] forKey:@"approval_dueDate" ];
                
                
            }
            
            
            
            
            
            NSArray *timeSheetsArr = [self getTimeSheetInfoForSheetIdentityAndUser:sheetIdentity andUserIdentity:[NSString stringWithFormat:@"%@",[userPropertiesDict objectForKey:@"Id"]]];
            if ([timeSheetsArr count]>0)
            {
               
                NSString *whereString=[NSString stringWithFormat:@"identity='%@' and user_identity='%@' ",sheetIdentity,[NSString stringWithFormat:@"%@",[userPropertiesDict objectForKey:@"Id"]]];
                [myDB updateTable:approvalTimesheetsTable data:dataDictionary where:whereString intoDatabase:@""];
            			
            }
            else 
            {
			   
			   [myDB insertIntoTable:approvalTimesheetsTable data:dataDictionary intoDatabase:@""];
            }
            
            
            [myDB deleteFromTable:approvalTimeEntries where:[NSString stringWithFormat:@"sheetidentity='%@'",sheetIdentity] inDatabase:@""];
             [myDB deleteFromTable:approvals_bookedTimeOffTable where:[NSString stringWithFormat:@"sheetidentity='%@'",sheetIdentity] inDatabase:@""];
            
            //Delete existing Entries for Sheet.
            //		NSString *entriesDeleteString = [NSString stringWithFormat:@"sheetIdentity = '%@'",sheetIdentity];
            
            //Save Timeentries for Timesheet
            
           timeEntriesArray = [[timesheetDict objectForKey:@"Relationships"] objectForKey:@"TimeEntries"];
            
            if (![timeEntriesArray isKindOfClass:[NSNull class]] && [timeEntriesArray count] > 0) {
                
                [self saveTimeEntriesForSheetFromApiToDB:timeEntriesArray :sheetIdentity];
            }
            timeOffsArray = [[timesheetDict objectForKey:@"Relationships"] objectForKey:@"TimeOffEntries"];
            if (![timeOffsArray isKindOfClass:[NSNull class]] && [timeOffsArray count] > 0) {
                
                [self saveTimeOffEntriesForSheetFromApiToDB:timeOffsArray :sheetIdentity];
            }
            
            if (isFromTimesheets) {
                 NSArray *breakRuleViolationsArray = [[timesheetDict objectForKey:@"Relationships"] objectForKey:@"BreakRuleViolations"];
                 [self savebreakRuleViolationsEntriesForSheetFromApiToDB:breakRuleViolationsArray :sheetIdentity];
            }
            
           
          
           
//            if (![breakRuleViolationsArray isKindOfClass:[NSNull class]] && [breakRuleViolationsArray count] > 0 && breakRuleViolationsArray!=nil) {
                
               
//            }

            
        }
		else {
            NSArray *timeSheetsArr = [self getTimeSheetInfoForSheetIdentity:sheetIdentity];
            if ([timeSheetsArr count]>0)
            {
                [self updateTimesheetApprovalStatusFromAPIToDB:approvalStatus :[NSString stringWithFormat:@"%@",sheetIdentity ]];
                
            }
        }

	}
    
    if (sheetIdentity && ((timeEntriesArray!=nil && ![timeEntriesArray isKindOfClass:[NSNull class]] ) || (timeOffsArray!=nil && ![timeOffsArray isKindOfClass:[NSNull class]])) ) 
    {
        NSNumber *sumTotalHour=[self getSumTimeEntriesDuration:[NSString stringWithFormat:@"%@", sheetIdentity]];
        if (decimalDuration==nil || [startDateDict isKindOfClass:[NSNull class]]) 
        {
            decimalDuration=0;
        }
        if (sumTotalHour==nil || [sumTotalHour isKindOfClass:[NSNull class]]) 
        {
            sumTotalHour=0;
        }
        if ([sumTotalHour intValue]<[decimalDuration intValue] && startDateDict!=nil && endDateDict!=nil && ![startDateDict isKindOfClass:[NSNull class]] && ![endDateDict isKindOfClass:[NSNull class]] ) 
        {
            [[G2RepliconServiceManager approvalsService] sendRequestToFetchBookedTimeOffForUserForSheetId:[NSString stringWithFormat:@"%@",sheetIdentity] withStartDate:startDateDict withEndDate:endDateDict];
            [G2RepliconServiceManager approvalsService].totalRequestsSent++;
        }
                
                                
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
        [myDB deleteFromTable:approvalEntryUDFtable where:deleteWhereString inDatabase:@""];
        
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
					
//					[self saveTaskForTimeEntryWithProject:taskDict withProject:projectIdentity];
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
        
      
        if (timeEntriesArr != nil && [timeEntriesArr  count]>0) {
            NSString *whereString=[NSString stringWithFormat:@"identity='%@'",entryIdentity];
            
//            if (appdelegate.isInOutTimesheet) {
//                if (([entryDict objectForKey:@"time_in"]!=nil && ![[entryDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"time_out"]!=nil && ![[entryDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"durationHourFormat"] !=nil && ![[entryDict objectForKey:@"durationHourFormat"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"durationHourFormat"] isEqualToString:@"0:0"] )  || ([entryDict objectForKey:@"comments"]!=nil && ![[entryDict objectForKey:@"comments"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"comments"] isEqualToString:@""] ) ) 
//                {
//                    [myDB updateTable:timeEntriesTable data:entryDict where:whereString intoDatabase:@""];
//                }
//                else
//                {
//                    [myDB deleteFromTable:timeEntriesTable where:whereString inDatabase:@""];
//                }
//                
//            } 
//            else
//            {   
                [myDB updateTable:approvalTimeEntries data:entryDict where:whereString intoDatabase:@""];
//            }
            
		}
        
        else {
//            if (appdelegate.isInOutTimesheet) {
//                if (([entryDict objectForKey:@"time_in"]!=nil && ![[entryDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"time_out"]!=nil && ![[entryDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) || ([entryDict objectForKey:@"durationHourFormat"] !=nil && ![[entryDict objectForKey:@"durationHourFormat"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"durationHourFormat"] isEqualToString:@"0:0"] )  || ([entryDict objectForKey:@"comments"]!=nil && ![[entryDict objectForKey:@"comments"] isKindOfClass:[NSNull class]] && ![[entryDict objectForKey:@"comments"] isEqualToString:@""] ) ) 
//                {
//                    [myDB insertIntoTable:timeEntriesTable data:entryDict intoDatabase:@""];
//                }
//                
//            }
//            else
//            {
                [myDB insertIntoTable:approvalTimeEntries data:entryDict intoDatabase:@""];
//            }
            
			
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
        [myDB deleteFromTable:approvalEntryUDFtable where:deleteWhereString inDatabase:@""];
        
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
        
        
        
		if (timeOffEntriesArr != nil && [timeOffEntriesArr  count]>0) {
            NSString *whereString=[NSString stringWithFormat:@"identity='%@'",identity];
//            if (appdelegate.isInOutTimesheet) {
//                if (([dataDict objectForKey:@"time_in"]!=nil && ![[dataDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) || ([dataDict objectForKey:@"time_out"]!=nil && ![[dataDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) || ([dataDict objectForKey:@"durationHourFormat"] !=nil && ![[dataDict objectForKey:@"durationHourFormat"] isKindOfClass:[NSNull class]] && ![[dataDict objectForKey:@"durationHourFormat"] isEqualToString:@"0:0"] )  || ([dataDict objectForKey:@"comments"]!=nil && ![[dataDict objectForKey:@"comments"] isKindOfClass:[NSNull class]] && ![[dataDict objectForKey:@"comments"] isEqualToString:@""] ) ) 
//                {
//                    
//                    [myDB updateTable:timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
//                }
//                else
//                {
//                    [myDB deleteFromTable:timeEntriesTable where:whereString inDatabase:@""];
//                }
//                
//            }
//            else
//            {
                [myDB updateTable:approvalTimeEntries data:dataDict where:whereString intoDatabase:@""];
//            }
            
			
		}else 
        {
//            if (appdelegate.isInOutTimesheet) {
//                if (([dataDict objectForKey:@"time_in"]!=nil && ![[dataDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) || ([dataDict objectForKey:@"time_out"]!=nil && ![[dataDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) || ([dataDict objectForKey:@"durationHourFormat"] !=nil && ![[dataDict objectForKey:@"durationHourFormat"] isKindOfClass:[NSNull class]] && ![[dataDict objectForKey:@"durationHourFormat"] isEqualToString:@"0:0"] )  || ([dataDict objectForKey:@"comments"]!=nil && ![[dataDict objectForKey:@"comments"] isKindOfClass:[NSNull class]] && ![[dataDict objectForKey:@"comments"] isEqualToString:@""] ) ) 
//                {
//                    [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
//                }
//            }
//            else
//            {
                [myDB insertIntoTable:approvalTimeEntries data:dataDict intoDatabase:@""];
//            }
            
		}		
	}
}

-(void) savebreakRuleViolationsEntriesForSheetFromApiToDB:(NSArray *) breakRuleViolationsArray : (NSNumber *)sheetIdentity {
	
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
    NSString *deleteWhereString = [NSString stringWithFormat:@"sheetIdentity = '%@' ",sheetIdentity];
    [myDB deleteFromTable:approvals_MealbreaksTable where:deleteWhereString inDatabase:@""];

	
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
            
            
            
            
            
            
            [myDB insertIntoTable:approvals_MealbreaksTable data:dataDict intoDatabase:@""];
            
            
        }
        
        
        
        
	}
}

-(void)savePermissionBasedTimesheetUDFsToDBForUserID:(NSDictionary *)responseDict {
	//DLog(@"savePermissionBasedTimesheetUDFsToDB:::TimesheetModel %@",responseArray);
	
	
	    
	 G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];

        
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
        NSString *moduleName = @"";
        
        
		moduleName = [[responseDict objectForKey:@"Properties"]objectForKey:@"Name"];
		if ([moduleName isEqualToString:@"ReportPeriod"]) {
			moduleName = ReportPeriod_SheetLevel;
		}else if ([moduleName isEqualToString:@"TaskTimesheet"]) {
			moduleName = TaskTimesheet_RowLevel;
		}else if ([moduleName isEqualToString:@"TimesheetEntry"]) {
			moduleName = TimesheetEntry_CellLevel;
		}
		NSArray *fieldsArray = [[responseDict objectForKey:@"Relationships"]objectForKey:@"Fields"];
		for (int j=0 ; j<[fieldsArray count]; j++) {
			NSMutableDictionary *infoDict=[NSMutableDictionary dictionary];
			int enabled=0,required=0,hidden=0;
			
			identity = [[fieldsArray objectAtIndex:j] objectForKey:@"Identity"];
			
			
			udfType = [[[[fieldsArray objectAtIndex:j] objectForKey:@"Relationships"]
						objectForKey:@"Type"]objectForKey:@"Identity" ];
			
			[infoDict setObject:udfType forKey:@"udfType"];
			[infoDict setObject:moduleName forKey:@"moduleName"];
			NSDictionary *propertiesDict = [[fieldsArray objectAtIndex:j]objectForKey:@"Properties"];
			

            
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
                
                
               
                [infoDict setObject:[propertiesDict objectForKey:@"NumericDefaultValue"] forKey:@"numericDefaultValue"];
                
               
                
                
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
            
			
			[myDB insertIntoTable:approvals_userDefinedFieldsTable data:infoDict intoDatabase:@""];			
			
			NSArray *dropDownOptionsArray = [[[fieldsArray objectAtIndex:j] objectForKey:@"Relationships"] 
											 objectForKey:@"DropDownOptions"];
			
			if (dropDownOptionsArray != nil && [dropDownOptionsArray count] > 0) {
				[self insertTimesheetDropDownOptionsToDatabase:dropDownOptionsArray : identity];
			}
		}	
	
	
}

-(void)insertTimesheetDropDownOptionsToDatabase:(NSArray *)dropDownOptionsArray : (NSString *)udfIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSString *deleteWhereString = [NSString stringWithFormat:@"udfIdentity = '%@'  ",udfIdentity];
	[myDB deleteFromTable:approvals_udfDropDownOptions where:deleteWhereString inDatabase:@""];
	
	
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
       
        
        [myDB insertIntoTable:approvals_udfDropDownOptions data:dropDownOptionsDict intoDatabase:@""];	
	}
}

-(void) savetimesheetSheetUdfsFromApiToDB: (NSDictionary *)userDefinedFieldsDict withSheetIdentity: (NSNumber *)sheetIdentity andModuleName:(NSString *)moduleName {
	//DLog(@"savetimesheetSheetUdfsFromApiToDB");
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
	NSArray *udfNamesArray = [userDefinedFieldsDict allKeys];
	if (udfNamesArray != nil && [udfNamesArray count] > 0) {
		for (NSString *udfName in udfNamesArray) {
//			NSMutableArray *udfDetailsArray = [self getUdfDetailsForName:udfName andModuleName:moduleName];
//			if (udfDetailsArray != nil && [udfDetailsArray count] > 0) {
				//DLog(@"udfdetails for udf %@ \n %@",udfName,udfDetailsArray);
//				NSDictionary *udfDict = [udfDetailsArray objectAtIndex:0];
//				NSString *udfIdentity = [udfDict objectForKey:@"identity"];
               NSString *udfIdentity =nil;
                NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
//				if (udfIdentity != nil && ![udfIdentity isKindOfClass:[NSNull class]]) {
//					[dataDictionary setObject:udfIdentity forKey:@"udf_id"];
//				}
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
					[myDB updateTable:approvalEntryUDFtable data:dataDictionary where:whereString intoDatabase:@""];
				}else {
					[myDB insertIntoTable:approvalEntryUDFtable data:dataDictionary intoDatabase:@""];
				}
                
//			}
		}
	}
}



/*-(void) saveTaskForTimeEntryWithProject:(NSDictionary *)taskDict withProject:(NSString *)projectIdentity {
	DLog(@"In saveTimeOffEntriesForSheetFromApiToDB method");
	//DLog(@"In saveTimeOffEntriesForSheetFromApiToDB method:::taskDict:::::%@",taskDict);
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
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
}*/


- (void) insertUserPermissionsInToDataBase:(NSArray *) permissionsArr andUserIdArr:(NSArray *)userIDArr{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *userID=nil;
    for (int i=0; i<[permissionsArr count]; i++) {
        userID=[userIDArr objectAtIndex:i];
        if ([[self getUserPermissionsForUserID:userID]count]>0) {
            [myDB deleteFromTable:userPermissionsTable where:[NSString stringWithFormat: @" user_identity= '%@' ",userID]  inDatabase:@""];
        }
        NSArray *keys = [[permissionsArr objectAtIndex:i] allKeys];
        NSArray *values = [[permissionsArr objectAtIndex:i] allValues];
        
        for (int i=0; i<[keys count]; i++) {
            
            NSDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:i+1],@"id",
                                      [keys objectAtIndex:i],@"permissionName",
                                      [[values objectAtIndex:i]stringValue],@"status",
                                      userID,@"user_identity",
                                      nil];
            [myDB insertIntoTable:userPermissionsTable data:infoDict intoDatabase:@""];
        }

    }
    
    
}


-(NSMutableArray *)getUserPermissionsForUserID:(NSString *)userID{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *permissionArr = [myDB select:@"*" from:userPermissionsTable where:[NSString stringWithFormat: @" user_identity= '%@' ",userID] intoDatabase:@""];
	if ([permissionArr count]!=0) {
		return permissionArr;
	}
	return nil;
}

-(NSMutableArray *)getAllUserPreferencesForUserID:(NSString *)userID{
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *selectString = @"*";
	NSMutableArray *preferencesArr = [myDB select:selectString from:approvals_userPreferences where:[NSString stringWithFormat:@"user_identity='%@' ",userID]  intoDatabase:@""];
	if (preferencesArr != nil && [preferencesArr count]>0) {
		
		return preferencesArr;
	}
	
	return nil;
}


-(void)saveBookedTimeOffEntriesIntoDB:(NSMutableArray *)timeOffEntries forSheetId:(NSString *)_sheetId{
	//DLog(@"timeOffEntries count %d",[timeOffEntries count]);
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSString *entriesDeleteString = [NSString stringWithFormat:@"sheetId = '%@'",_sheetId];
	[myDB deleteFromTable:approvals_bookingsTable where:entriesDeleteString inDatabase:@""];
    
    //Fix for 3051//Juhi
    NSString *deleteString = [NSString stringWithFormat:@"sheetIdentity = '%@'",_sheetId];
	[myDB deleteFromTable:approvals_bookedTimeOffTable where:deleteString inDatabase:@""];
	
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
				[myDB updateTable:approvals_bookingsTable data:bookingDetailsDict where:whereString intoDatabase:@""];
			}else {
				//DLog(@"insert bookings::TimeSheetModel");
				[myDB insertIntoTable:approvals_bookingsTable data:bookingDetailsDict intoDatabase:@""];
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
				[myDB updateTable:approvals_bookedTimeOffTable data:detailsDict where:whereString intoDatabase:@""];
			}else {
				//DLog(@"insert booked time off entries::TimeSheetModel");
				[myDB insertIntoTable:approvals_bookedTimeOffTable data:detailsDict intoDatabase:@""];
			}
			
		}
        // [[NSNotificationCenter defaultCenter]postNotificationName:NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION object:nil];//DE3418
	}
    //    [[NSNotificationCenter defaultCenter]postNotificationName:NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION object:[NSDictionary dictionary]];//DE4004
}

-(NSMutableArray *) getTimeEntryForSheetWithSheetIdentity:(NSString *)identity :(NSString *)sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:
							 @"entryType = 'timeEntry' and identity = '%@' and sheetIdentity = '%@'",
							 identity,sheetIdentity];
	//DLog(@"WHERE String :Time entries%@",whereString);
	NSMutableArray *timeEntriesArray = [myDB select:@"*" from:approvalTimeEntries where:whereString intoDatabase:@""];
	//DLog(@"ENTRIES FROM DB:::Time Entries %d",[timeEntriesArray count]);
	if ([timeEntriesArray count]>0) {
		return timeEntriesArray;
	}
	return nil;
}

-(NSNumber *) getSumTimeEntriesDuration:(NSString *)sheetIdentity 
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:
							 @" sheetIdentity = '%@' ",sheetIdentity];
	//DLog(@"WHERE String :Time entries%@",whereString);
	NSMutableArray *timeEntriesArray = [myDB select:@"sum(durationDecimalFormat)" from:approvalTimeEntries where:whereString intoDatabase:@""];
	//DLog(@"ENTRIES FROM DB:::Time Entries %d",[timeEntriesArray count]);
	if ([timeEntriesArray count]>0) {
		return [[timeEntriesArray objectAtIndex:0]objectForKey:@"sum(durationDecimalFormat)"];
	}
	return 0;
}

-(NSMutableArray *) getTimeOffEntryWithEntryIdentityForSheetWithSheetIdentity:(NSString *)timeOffEntryIdentity :(NSString *)sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
	NSString *whereString = [NSString stringWithFormat:@"entryType = 'timeOff' and identity = '%@' and sheetIdentity = '%@'",
							 timeOffEntryIdentity,sheetIdentity];
	//DLog(@"wheretring for timeoff %@",whereString);
	NSMutableArray *timeOffsArray = [myDB select:@"*" from:approvalTimeEntries where:whereString intoDatabase:@""];
	if ([timeOffsArray count]>0) {
		return timeOffsArray;
	}
	return nil;
}

-(NSMutableArray *)getUdfDetailsForName: (NSString *)udfName andModuleName:(NSString *)moduleName {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where moduleName = '%@' and name = '%@'",
					 approvals_userDefinedFieldsTable,[ moduleName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ],[udfName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSMutableArray *udfDetailsArray = [myDB executeQuery:sql];
	//DLog(@"udfDetailsArray %@",udfDetailsArray);
	if (udfDetailsArray != nil && [udfDetailsArray count]>0) {
		return udfDetailsArray;
	}
	return nil;
}

-(NSMutableArray *)getAllUdfDetails {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ ",approvals_userDefinedFieldsTable];
	NSMutableArray *udfDetailsArray = [myDB executeQuery:sql];
	//DLog(@"udfDetailsArray %@",udfDetailsArray);
	if (udfDetailsArray != nil && [udfDetailsArray count]>0) {
		return udfDetailsArray;
	}
	return nil;
}

-(NSMutableArray*)getTimeSheetInfoForSheetIdentity:(id)sheetIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSString *whereString=[NSString stringWithFormat:@"identity='%@'",sheetIdentity];
	NSMutableArray *timeSheetsArr = [myDB select:@"*" from:approvalTimesheetsTable where:whereString intoDatabase:@""];
	if ([timeSheetsArr count]!=0) {
		return timeSheetsArr;
	}
	return nil;
}

-(NSMutableArray*)getTimeSheetInfoForSheetIdentityAndUser:(id)sheetIdentity andUserIdentity:(NSString *)userIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSString *whereString=[NSString stringWithFormat:@"identity='%@' AND user_identity='%@' ",sheetIdentity,userIdentity];
	NSMutableArray *timeSheetsArr = [myDB select:@"*" from:approvalTimesheetsTable where:whereString intoDatabase:@""];
	if ([timeSheetsArr count]!=0) {
		return timeSheetsArr;
	}
	return nil;
}


-(BOOL) checkUDFExistsForSheet: (NSNumber *)sheetIdentity andModuleName:(NSString *)moduleName andUDFName:(NSString *)udfName {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where entry_type = '%@' and entry_id = %@ and udf_name='%@' ",
					 approvalEntryUDFtable,[ moduleName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ],sheetIdentity,[ udfName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSMutableArray *udfDetailsArray = [myDB executeQuery:sql];
	if (udfDetailsArray != nil && [udfDetailsArray count]>0) {
		return YES;
	}
	return NO;
}

-(NSMutableArray*)getAllSheetIdentitiesFromDB
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sqlQuery = @"select identity from approvals_timesheets where approvalStatus='Waiting For Approval'";
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

-(NSMutableArray *)getTimeSheetsStartAndEndDates{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select identity,startDate,endDate from %@ order by startDate asc"
					 ,approvalTimesheetsTable];
	NSMutableArray *dateArray = [myDB executeQuery:sql];
    if (dateArray != nil && [dateArray count]>0) {
		return dateArray;
	}
	return nil;
}

-(NSMutableArray *)getTimeSheetsStartAndEndDates:(NSString *)sheetID{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *dateArray = [myDB select:@"identity,startDate,endDate" from:approvalTimesheetsTable where:[NSString stringWithFormat: @" identity='%@' ",sheetID] intoDatabase:@""];
	if (dateArray != nil && [dateArray count]>0) {
		return dateArray;
	}
	return nil;
}

-(NSString *)getUSerIDByTimeSheetID:(NSString *)sheetID{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *userArray = [myDB select:@" user_identity " from:approvalTimesheetsTable where:[NSString stringWithFormat: @" identity='%@' ",sheetID] intoDatabase:@""];
	if (userArray != nil && [userArray count]>0) {
		return [[userArray objectAtIndex:0] objectForKey:@"user_identity" ];
	}
	return nil;
}


-(NSMutableArray *)getAllEnabledUserPermissionsByUserID:(NSString *)userID{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *selectString = @"permissionName";
	NSMutableArray *permissionArr = [myDB select:selectString from:userPermissionsTable where:[NSString stringWithFormat:@"status=1 and user_identity='%@'",userID] intoDatabase:@""];
	if (permissionArr != nil && [permissionArr count]>0) {
		NSMutableArray *permissionList = [NSMutableArray array];
		for (NSDictionary *permissionDict in permissionArr ) 
        {
			[permissionList addObject:[permissionDict objectForKey:selectString]];
		}
		return permissionList;
	}
	return nil;
}


-(NSMutableArray *)getAllMealViolationsbyDate:(NSString *)violationDate forISOName:(NSString *)isoName forSheetidentity:(NSString *)sheetIdentity
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@" select * from %@ where violationDate ='%@' and ISOName='%@' and sheetIdentity='%@' order by identity asc ",approvals_MealbreaksTable,violationDate,isoName,sheetIdentity];
	NSMutableArray *mealVilationsArr = [myDB executeQuery:sql];
	if (mealVilationsArr != nil && [mealVilationsArr count]>0) {
		return mealVilationsArr;
	}
	return nil;
}
                                             
-(NSMutableArray *)getAllMealViolationsforSheetidentity:(NSNumber *)sheetIdentity
{
   	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@" select * from %@ where sheetIdentity='%@' order by identity asc ",approvals_MealbreaksTable,sheetIdentity];
	NSMutableArray *mealVilationsArr = [myDB executeQuery:sql];
	if (mealVilationsArr != nil && [mealVilationsArr count]>0) {
		return mealVilationsArr;
	}
	return nil;                                              
}

-(NSMutableArray *)getAllTimeSheetsGroupedByDueDates{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    

       
        
        NSMutableArray *groupedTimesheetsArr=[NSMutableArray array];
        NSMutableArray *dueDatesArray = [myDB select:@"distinct(approval_dueDate) " from:approvalTimesheetsTable where:@" approvalStatus='Waiting For Approval' order by duedate asc" intoDatabase:@""];
        if (dueDatesArray != nil && [dueDatesArray count]>0) {
            
            for (int i=0; i<[dueDatesArray count]; i++) {
                NSMutableArray *groupedtsArray = [myDB select:@" * " from:approvalTimesheetsTable where:[NSString stringWithFormat: @" approval_dueDate = '%@' AND approvalStatus='Waiting For Approval'  order by user_fname asc",[[dueDatesArray objectAtIndex:i] objectForKey:@"approval_dueDate" ]] intoDatabase:@""];
                for (int j=0; j<[groupedtsArray count]; j++) {
                    NSMutableDictionary *groupedtsDict=[groupedtsArray objectAtIndex:j];
                    [groupedtsDict setObject:[NSNumber numberWithBool:FALSE] forKey:@"IsSelected"];
                    
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                    [dateFormatter setLocale:locale];
                    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                    
                    NSString *headerTitleStr=[dateFormatter stringFromDate:[G2Util convertStringToDate:[groupedtsDict objectForKey:@"approval_dueDate"]]];
                    [groupedtsDict setObject:headerTitleStr forKey:@"approval_dueDate"];
                    
                   
                    
                    
//                     [groupedtsDict setObject:[NSString stringWithFormat:@"%@",@"2"] forKey:@"timesheetMealBreakPenaltiesCount"]; 
                    
                    
                    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                    NSString *hourFormat=nil;
                    
                    hourFormat = @"Decimal";
                    
                    NSDictionary *hoursDict=[self getSheetVariousHoursForSheetFromDB:[groupedtsDict objectForKey:@"identity"] withFormat:hourFormat];
                    
                    NSString *timeEntrytotalHrs = nil;;
                    NSString *timeOfftotalHrs = nil;;
                    NSString *overTimetotalHrs = nil;
                    NSString *regulartotalHrs = nil;
                    
                    if (hoursDict!=nil)
                    {
                        timeEntrytotalHrs =[hoursDict objectForKey:@"totalHours"];
                        timeOfftotalHrs =[hoursDict objectForKey:@"totalTimeOff"];
                        overTimetotalHrs =[hoursDict objectForKey:@"totalOvertime"];
                        regulartotalHrs =[hoursDict objectForKey:@"totalRegular"];
                    }
                    
                    if (!appDelegate.isLockedTimeSheet) {
                        [groupedtsDict setObject:[NSString stringWithFormat:@"%0.2f",[timeEntrytotalHrs floatValue]] forKey:@"TotalTime"]; 
                        [groupedtsDict setObject:[NSString stringWithFormat:@"%0.2f",[timeOfftotalHrs floatValue]] forKey:@"TotalTimeOff"]; 
                        [groupedtsDict setObject:[NSString stringWithFormat:@"%0.2f",[overTimetotalHrs floatValue]] forKey:@"TotalOverTime"]; 
                        [groupedtsDict setObject:[NSString stringWithFormat:@"%0.2f",[regulartotalHrs floatValue]] forKey:@"TotalRegularTime"]; 
                    }
                    else
                    {
                        if ([hourFormat isEqualToString:@"Decimal"]) {
                            [groupedtsDict setObject:[NSString stringWithFormat:@"%0.2f",[timeEntrytotalHrs floatValue]] forKey:@"TotalTime"]; 
                            [groupedtsDict setObject:[NSString stringWithFormat:@"%0.2f",[timeOfftotalHrs floatValue]] forKey:@"TotalTimeOff"]; 
                            [groupedtsDict setObject:[NSString stringWithFormat:@"%0.2f",[overTimetotalHrs floatValue]] forKey:@"TotalOverTime"]; 
                            [groupedtsDict setObject:[NSString stringWithFormat:@"%0.2f",[regulartotalHrs floatValue]] forKey:@"TotalRegularTime"]; 
                            
                        }
                        else
                        {
                            [groupedtsDict setObject:timeEntrytotalHrs forKey:@"TotalTime"] ;
                            [groupedtsDict setObject:timeOfftotalHrs forKey:@"TotalTimeOff"] ;
                            [groupedtsDict setObject:overTimetotalHrs forKey:@"TotalOverTime"] ;
                            [groupedtsDict setObject:regulartotalHrs forKey:@"TotalRegularTime"] ;
                            
                        }
                    }
                    
                    [groupedtsArray replaceObjectAtIndex:j withObject:groupedtsDict];
                }
                [groupedTimesheetsArr addObject:groupedtsArray];
            }
            
        }
        
        if (groupedTimesheetsArr != nil && [groupedTimesheetsArr count]>0) {
            return groupedTimesheetsArr;
        }

    
    
    
    
    
	return nil;
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
					[myDB executeQuery:sqlQuer];
				}
			}
			
		}
	}
}

-(void)deleteDeletedApprovalTimesheetWithSheetIdentity:(NSString *)sheetIdentity {
    
	G2SQLiteDB *myDB =[G2SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from approvals_timesheets where identity = '%@'", sheetIdentity];
    NSString *query1=[NSString stringWithFormat:@"delete from approvals_time_entries where sheetIdentity = '%@'", sheetIdentity];
    NSString *query2=[NSString stringWithFormat:@"delete from approvals_booked_time_off_entries where sheetIdentity = '%@'", sheetIdentity];
	[myDB executeQuery:query];
    [myDB executeQuery:query1];
    [myDB executeQuery:query2];
    
    
}


-(void)deleteUnmModifiedTimesheets {
	G2SQLiteDB *myDB =[G2SQLiteDB getInstance];
	
	
	NSString *queryUdfs=[NSString stringWithFormat:@"delete from approvals_entry_udfs where entry_id not in(select identity from time_entries where isModified=1) and entry_type = 'TimesheetLevel'  "];
	[myDB executeQuery:queryUdfs];
	
	NSString *queryEntries=[NSString stringWithFormat:@"delete from approvals_time_entries where sheetIdentity in(select identity from timesheets where isModified = 0)"];
	[myDB executeQuery:queryEntries];
	
	NSString *query=[NSString stringWithFormat:@"delete from approvals_timesheets where isModified = 0 "];
	[myDB executeQuery:query];
}

-(NSMutableArray*)getTimeOffBookingsForBookingId:(id)bookingIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSString *whereString=[NSString stringWithFormat:@"bookingId='%@'",bookingIdentity];
	NSMutableArray *bookingsArr = [myDB select:@"*" from:approvals_bookingsTable where:whereString intoDatabase:@""];
	if (bookingsArr != nil && [bookingsArr count]> 0) {
		return bookingsArr;
	}
	return nil;
}

-(NSMutableArray *)getBookedTimeOffEntryForSheetWithSheetIdentity:(NSString *)_sheetId 
														  entryId:(NSString *)_entryIdentity bookingId:(NSString *)_bookingId{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:
							 @"entryType = 'bookedtimeOff' and identity = '%@'",
							 _entryIdentity];
	NSMutableArray *bookedtimeoffEntriesArray = [myDB select:@"*" from:approvals_bookedTimeOffTable where:whereString intoDatabase:@""];
	if (bookedtimeoffEntriesArray != nil && [bookedtimeoffEntriesArray count]>0) {
		return bookedtimeoffEntriesArray;
	}
	return nil;
}

-(NSMutableArray *)getBookedTimeOffEntryForSheetWithOnlySheetIdentity:(NSString *)_sheetId 
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:
							 @"entryType = 'bookedtimeOff' and sheetIdentity = '%@'",
							 _sheetId];
	NSMutableArray *bookedtimeoffEntriesArray = [myDB select:@"*" from:approvals_bookedTimeOffTable where:whereString intoDatabase:@""];
	if (bookedtimeoffEntriesArray != nil && [bookedtimeoffEntriesArray count]>0) {
		return bookedtimeoffEntriesArray;
	}
	return nil;
}

-(NSDictionary*) getSheetVariousHoursForSheetFromDB: (NSString *) sheetIdentity withFormat:(NSString *)format{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",sheetIdentity];
    
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.isLockedTimeSheet) {
        format=@"Decimal";
    }
    
    NSString *selectString  = nil;
    
    if ([format isEqualToString:@"Decimal"]) 
    {
        selectString  = @" totalHoursDecimalFormat,totalTimeOffDecimalFormat,totalOvertimeDecimalFormat ";
    }
	else
    {
        selectString  = @" totalHoursFormat,totalTimeOffHoursFormat,totalOvertimeHoursFormat ";
    }
	NSMutableArray *totalTimesArray = [myDB select:selectString from:approvalTimesheetsTable where:whereString intoDatabase:@""];
	//hardcoding format to decimal for realease 1.
	//format = @"Decimal";
	if (totalTimesArray != nil && [totalTimesArray count]>0) {
		if ([format isEqualToString:@"Decimal"]) 
        {
            float totalHour=0.0;
            float timeoffHour=0.0;
            float overtimeHour=0.0;
            float regularHour=0.0;
            
			if (![[[totalTimesArray objectAtIndex:0] objectForKey:@"totalHoursDecimalFormat"] isKindOfClass:[NSNull class]]) 
            {
                totalHour=[[[totalTimesArray objectAtIndex:0] objectForKey:@"totalHoursDecimalFormat"]floatValue];
				
			}
            if (![[[totalTimesArray objectAtIndex:0] objectForKey:@"totalTimeOffDecimalFormat"] isKindOfClass:[NSNull class]]) 
            {
                timeoffHour=[[[totalTimesArray objectAtIndex:0] objectForKey:@"totalTimeOffDecimalFormat"]floatValue];
				
			}
            if (![[[totalTimesArray objectAtIndex:0] objectForKey:@"totalOvertimeDecimalFormat"] isKindOfClass:[NSNull class]]) 
            {
                overtimeHour=[[[totalTimesArray objectAtIndex:0] objectForKey:@"totalOvertimeDecimalFormat"]floatValue];
				
			}
            
            regularHour=totalHour-timeoffHour-overtimeHour;
            
             return [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%0.02f",totalHour],@"totalHours",[NSString stringWithFormat:@"%0.02f",timeoffHour],@"totalTimeOff",[NSString stringWithFormat:@"%0.02f",overtimeHour],@"totalOvertime",[NSString stringWithFormat:@"%0.02f",regularHour],@"totalRegular", nil];
            
		}
        else {
			if ([totalTimesArray count]>0) 
            {
              NSString *durationTotalHoursFormat=[[totalTimesArray objectAtIndex:0] objectForKey:@"totalHoursFormat"];
              NSString *durationTotalTimeOffHoursFormat=[[totalTimesArray objectAtIndex:0] objectForKey:@"totalTimeOffHoursFormat"];
              NSString *durationOverTimeHoursFormat=[[totalTimesArray objectAtIndex:0] objectForKey:@"totalOvertimeHoursFormat"];
                
                NSString *sumDuration_Total_TimeOff=[G2Util mergeTwoHourFormat:durationTotalHoursFormat andHour2:durationTotalTimeOffHoursFormat];
                NSString *sumDuration_Total_TimeOff_Overtime=[G2Util mergeTwoHourFormat:sumDuration_Total_TimeOff andHour2:durationOverTimeHoursFormat];
                
                NSString *durationTotalRegularHoursFormat=[G2Util differenceTwoHourFormat:durationTotalHoursFormat andHour2:sumDuration_Total_TimeOff_Overtime];
                
                 return [NSDictionary dictionaryWithObjectsAndKeys:durationTotalHoursFormat,@"totalHours",durationTotalTimeOffHoursFormat,@"totalTimeOff",durationOverTimeHoursFormat,@"totalOvertime",durationTotalRegularHoursFormat,@"totalRegular", nil];
            } 
            
            return [NSDictionary dictionaryWithObjectsAndKeys:@"0.00",@"totalHours",@"0.00",@"totalTimeOff",@"0.00",@"totalOvertime",@"0.00",@"totalRegular", nil];
            
			
		}
	}
    if (![format isEqualToString:@"Decimal"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"0.00",@"totalHours",@"0.00",@"totalTimeOff",@"0.00",@"totalOvertime",@"0.00",@"totalRegular", nil];
    }
    else
    {
        return nil; 
    }
	
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
	NSMutableArray *totalTimeArray = [myDB select:selectString from:approvalTimesheetsTable where:whereString intoDatabase:@""];
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

-(NSString*) getSheetTotalTimeOffHoursForSheetFromDB: (NSString *) sheetIdentity withFormat:(NSString *)format{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",sheetIdentity];
    
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.isLockedTimeSheet) {
        format=@"Decimal";
    }
    NSString *selectString  = nil;
    
    if ([format isEqualToString:@"Decimal"]) 
    {
        selectString  = @"totalTimeOffDecimalFormat";
    }
	else
    {
        selectString  = @"totalTimeOffHoursFormat";
    }
	NSMutableArray *totalTimeArray = [myDB select:selectString from:approvalTimesheetsTable where:whereString intoDatabase:@""];
	//hardcoding format to decimal for realease 1.
	//format = @"Decimal";
	if (totalTimeArray != nil && [totalTimeArray count]>0) {
		if ([format isEqualToString:@"Decimal"]) {
			if (![[[totalTimeArray objectAtIndex:0] objectForKey:@"totalTimeOffDecimalFormat"] isKindOfClass:[NSNull class]]) {
				return [NSString stringWithFormat:@"%0.02f",[[[totalTimeArray objectAtIndex:0] objectForKey:@"totalTimeOffDecimalFormat"]floatValue]];
			}
            
		}else {
			if ([totalTimeArray count]>0) 
            {
                int totalHrs=0;
                int totalMins=0;
                for (int k=0; k<[totalTimeArray count]; k++) 
                {
                    NSString *durationHoursFormat=[[totalTimeArray objectAtIndex:k] objectForKey:@"totalTimeOffHoursFormat"];
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

-(NSString*) getSheetTotalOverTimeHoursForSheetFromDB: (NSString *) sheetIdentity withFormat:(NSString *)format{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",sheetIdentity];
    
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.isLockedTimeSheet) {
        format=@"Decimal";
    }  
    NSString *selectString  = nil;
    
    if ([format isEqualToString:@"Decimal"]) 
    {
        selectString  = @"totalOvertimeDecimalFormat";
    }
	else
    {
        selectString  = @"totalOvertimeHoursFormat";
    }
	NSMutableArray *totalTimeArray = [myDB select:selectString from:approvalTimesheetsTable where:whereString intoDatabase:@""];
	//hardcoding format to decimal for realease 1.
	//format = @"Decimal";
	if (totalTimeArray != nil && [totalTimeArray count]>0) {
		if ([format isEqualToString:@"Decimal"]) {
			if (![[[totalTimeArray objectAtIndex:0] objectForKey:@"totalOvertimeDecimalFormat"] isKindOfClass:[NSNull class]]) {
				return [NSString stringWithFormat:@"%0.02f",[[[totalTimeArray objectAtIndex:0] objectForKey:@"totalOvertimeDecimalFormat"]floatValue]];
			}
            
		}else {
			if ([totalTimeArray count]>0) 
            {
                int totalHrs=0;
                int totalMins=0;
                for (int k=0; k<[totalTimeArray count]; k++) 
                {
                    NSString *durationHoursFormat=[[totalTimeArray objectAtIndex:k] objectForKey:@"totalOvertimeHoursFormat"];
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


-(NSDictionary *)getTimeSheetPeriodforSheetId:(NSString *)sheetIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select startDate,endDate from %@ where identity = '%@' "
					 ,approvalTimesheetsTable,sheetIdentity];
	NSMutableArray *startendDateArr = [myDB executeQuery:sql];
	if (startendDateArr != nil && [startendDateArr count]>0) {
		return [startendDateArr objectAtIndex:0];
	}
	return nil;
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
    
    
	NSMutableArray *totalTimeArray = [myDB select:selectString from:approvals_bookedTimeOffTable where:whereString intoDatabase:@""];
	
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

-(NSString *)getTotalHoursforBookedEntryWithDate:(NSString *)_entryDate withformat:(NSString *)format withSheetIdentity:(NSString *)sheetIdentity
{
	//DLog(@"_entryDate %@",_entryDate);
	//DLog(@"Time format  %@",format);
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entryDate = '%@' AND sheetidentity='%@' ",_entryDate,sheetIdentity];
    
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
    
	NSMutableArray *totalTimeArray = [myDB select:selectString from:approvals_bookedTimeOffTable where:whereString intoDatabase:@""];
	
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

-(NSMutableArray *) getTimeEntriesForSheetFromDB: (NSString *)sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entryType = 'timeEntry' and sheetIdentity = '%@'order by identity desc",sheetIdentity];
	NSMutableArray *timeEntriesArray = [myDB select:@"*" from:approvalTimeEntries where:whereString intoDatabase:@""];
	if ([timeEntriesArray count]>0) {
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        if ([appDelegate.userType isEqualToString:APPROVAL_TIMESHEET_TYPE_INOUT]) 
        {
            if ([timeEntriesArray count]>1) 
            {
                return [G2Util sortArray:timeEntriesArray inAscending:NO usingKey:@"time_in"];
            }
        }
		return timeEntriesArray;
	}
	return nil;
}

-(NSMutableArray *) getTimeEntriesFromDB {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSMutableArray *timeEntriesArray = [myDB select:@"*" from:approvalTimeEntries where:@"" intoDatabase:@""];
	if ([timeEntriesArray count]>0) {
		return timeEntriesArray;
	}
	return nil;
}


-(NSMutableArray *) getTimeOffsForSheetFromDB:(NSString *)sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entryType = 'timeOff' and sheetIdentity = '%@'",sheetIdentity];
	NSMutableArray *timeOffsArray = [myDB select:@"*" from:approvalTimeEntries where:whereString intoDatabase:@""];
	if ([timeOffsArray count]>0) {
		return timeOffsArray;
	}
	return nil;
}

-(NSMutableArray *)getDistinctEntryDatesForSheet:(NSString *)sheetidentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@" select distinct(entryDate) as entrydate from %@ where sheetIdentity ='%@' order by entrydate desc "
					 ,approvalTimeEntries,sheetidentity];
	NSMutableArray *distiinctDateArr = [myDB executeQuery:sql];
	if (distiinctDateArr != nil && [distiinctDateArr count]>0) {
		return distiinctDateArr;
	}
	return nil;
}

-(NSMutableArray *)getBookedTimeOffforTimeSheetPeriod:(NSString *)_startDate _endDate:(NSString *)endDate andSheetIdentity:(NSString *)sheetIdentity
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where sheetIdentity='%@' and entryDate between '%@' and '%@'order by entryDate desc"
                    ,approvals_bookedTimeOffTable,sheetIdentity,_startDate,endDate];
	NSMutableArray *bookedEntriesArray = [myDB executeQueryToConvertUnicodeValues:sql];//DE6283//Juhi
	if (bookedEntriesArray != nil && [bookedEntriesArray count]>0) {
		return bookedEntriesArray;
	}
	return nil;
}

-(NSString *)getTotalHoursforEntryWithDate:(NSString *)_entryDate withformat:(NSString *)format withSheetIdentity:(NSString *)sheetIdentity
{
	//DLog(@"_entryDate %@",_entryDate);
	//DLog(@"Time format  %@",format);
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entryDate = '%@' and sheetIdentity='%@'  ",_entryDate,sheetIdentity];
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
    
	NSMutableArray *totalTimeArray = [myDB select:selectString from:approvalTimeEntries where:whereString intoDatabase:@""];
	
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

-(void)deleteAllRowsForApprovalTimesheetsTable
{
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    [myDB deleteFromTable:approvalTimesheetsTable inDatabase:@""];
}
-(void)deleteAllRowsForApprovalTimesheetsEntriesTable
{
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    [myDB deleteFromTable:approvalTimeEntries inDatabase:@""];
}
-(void)deleteAllRowsForApprovalBookedTimeOffEntriesTable
{
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    [myDB deleteFromTable:approvals_bookedTimeOffTable inDatabase:@""];
}

-(void)deleteRowsForApprovalTimesheetsEntriesTableForSheetIdentity:(NSString *)sheetIdentity
{
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    [myDB deleteFromTable:approvalTimeEntries  where:[NSString stringWithFormat: @" sheetIdentity='%@' ",sheetIdentity] inDatabase:@""];
}
//DE5784
-(void)deleteRowsForApprovalTimesheetsTableForSheetIdentity:(NSString *)sheetIdentity
{
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    [myDB deleteFromTable:approvalTimesheetsTable  where:[NSString stringWithFormat: @" identity='%@' ",sheetIdentity] inDatabase:@""];
}
-(void)deleteAllRowsForApprovalUserDefinedFieldsTable
{
    G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
    
    //delete user defined fields for Timesheets
    
    [myDB deleteFromTable:approvals_userDefinedFieldsTable inDatabase:@""];
}
-(void)deleteAllRowsForApprovalUserPermissionsTable
{
    G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
    
    //delete user defined fields for Timesheets
    
    [myDB deleteFromTable:userPermissionsTable inDatabase:@""];
}
-(void)deleteAllRowsForApprovalPreferencesTable
{
    G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
    
    //delete user defined fields for Timesheets
    
    [myDB deleteFromTable:approvals_userPreferences inDatabase:@""];
}




-(void)saveUserPreferencesFromApiToDB: (NSArray *)preferencesMainArray andUserIdArr:(NSArray *)userIDsArray{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
    for (int i=0; i<[preferencesMainArray count]; i++) 
    {
        
        if ([[self getAllUserPreferencesForUserID:[userIDsArray objectAtIndex:i]]count]>0) {
            [myDB deleteFromTable:userPermissionsTable where:[NSString stringWithFormat: @" user_identity= '%@' ",[userIDsArray objectAtIndex:i]]  inDatabase:@""];
        }
        
        NSDictionary *preferenceDict=[preferencesMainArray objectAtIndex:i];
     
       
        
        NSString *timesheetFormat = nil;
        NSString *hourFormat      = nil;
        
        NSString *dateFormat      = nil;
        NSDictionary *hourformatDict = [preferenceDict objectForKey:@"Timesheet.HourFormat"];
        if (hourformatDict != nil && ![hourformatDict isKindOfClass:[NSNull class]]) {
            hourFormat = [hourformatDict objectForKey:@"Identity"];
        }
        
        
        
        
        NSDictionary *timeSheetformatDict = [preferenceDict objectForKey:@"Timesheet.Format"];
        if (timeSheetformatDict != nil && ![timeSheetformatDict isKindOfClass:[NSNull class]]) {
            timesheetFormat = [timeSheetformatDict objectForKey:@"Identity"];
        }
        
        NSDictionary *hourformatDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              hourFormat,@"preferenceValue",
                                              @"Timesheet.HourFormat",@"preferenceName",[NSString stringWithFormat:@"%@",[userIDsArray objectAtIndex:i]],@"user_identity",
                                              nil];
       
        NSDictionary *timeformatDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [preferenceDict objectForKey:@"Timesheet.TimeFormat"],@"preferenceValue",
                                              @"Timesheet.TimeFormat",@"preferenceName",[NSString stringWithFormat:@"%@",[userIDsArray objectAtIndex:i]],@"user_identity",
                                              nil];
        
//        if ([ [[preferencesArray objectAtIndex:0] objectForKey:@"Timesheet.TimeFormat"]  isEqualToString:@"%#H:%M"]) {
//            [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"AM_PM" ];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//        else if ([ [[preferencesArray objectAtIndex:0] objectForKey:@"Timesheet.TimeFormat"]  isEqualToString:@"%#I:%M %P"]) {
//            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"AM_PM" ];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
        
        NSDictionary *timesheetformatDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   timesheetFormat,@"preferenceValue",
                                                   @"Timesheet.Format",@"preferenceName",[NSString stringWithFormat:@"%@",[userIDsArray objectAtIndex:i]],@"user_identity",
                                                   nil];
       
        NSDictionary *dateFormatDict   = [preferenceDict objectForKey:@"Timesheet.DateFormat"];
        if (dateFormatDict != nil && ![dateFormatDict isKindOfClass:[NSNull class]]) {
            dateFormat = [preferenceDict objectForKey:@"Timesheet.DateFormat"];
        }
      
        NSDictionary *dateformatDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              dateFormat,@"preferenceValue",
                                              @"Timesheet.DateFormat",@"preferenceName",[NSString stringWithFormat:@"%@",[userIDsArray objectAtIndex:i]],@"user_identity",
                                              nil];
       
        NSArray *detailsArray = [NSArray arrayWithObjects:hourformatDictionary,timeformatDictionary,
                                 timesheetformatDictionary,dateformatDictionary,nil];
        for (int i =0; i<[detailsArray count]; i++) {
            [myDB insertIntoTable:approvals_userPreferences data:[detailsArray objectAtIndex:i] intoDatabase:@""];
        }

    }
    
	
}

-(NSMutableArray *)getDropDownOptionsForUDFIdentityForApprovals:(NSString *)udfIdentity
{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSString *sql = nil;
	sql = [NSString stringWithFormat:@"select * from '%@' where udfIdentity  = '%@' and enabled = 1  order by value asc",@"approvals_udfDropDownOptions",udfIdentity];	
	
	NSMutableArray *dropDownOptionsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([dropDownOptionsArr count]!=0) {
		return dropDownOptionsArr;
	}
	return nil;
    
}


-(NSMutableArray *)getEnabledOnlyTimeSheetLevelUDFsForCellAndRow {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
    NSString *sqlRowLevel =[NSString stringWithFormat:@"select * from %@ where enabled = 1 and hidden=0 and moduleName = '%@' order by fieldIndex ",
                            approvals_userDefinedFieldsTable,TaskTimesheet_RowLevel];
	NSMutableArray *rowLevelUdfDetailsArray = [myDB executeQueryToConvertUnicodeValues:sqlRowLevel];
    NSString *sqlCellLevel =[NSString stringWithFormat:@"select * from %@ where enabled = 1 and hidden=0 and  moduleName = '%@' order by fieldIndex ",
                             approvals_userDefinedFieldsTable,TimesheetEntry_CellLevel];
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
                    approvals_userDefinedFieldsTable,TimeOffs_SheetLevel];
	NSMutableArray *udfDetailsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	//DLog(@"Udfs count %d",[udfDetailsArray count]);
	if (udfDetailsArray != nil && [udfDetailsArray count]>0) {
		return udfDetailsArray;
	}
	return nil;
}

-(NSMutableDictionary*) getSelectedUdfsForEntry:(NSString *)entryId andType:(NSString*)entryType andUDFName:(NSString *)udfName {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *where =[NSString stringWithFormat:@"entry_id ='%@' and entry_type='%@' and udf_name='%@'",entryId,entryType,[udfName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSMutableArray *udfArray = [myDB select:@"*" from:approvalEntryUDFtable where:where intoDatabase:@""];
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

-(void) updateTimesheetApprovalStatusFromAPIToDB: (NSString *)status : (NSString *)sheetIdentity {
	
	DLog(@"In saveTimeOffEntriesForSheetFromApiToDB method");
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	if (sheetIdentity != nil && [sheetIdentity isKindOfClass:[NSString class]]) {
		

		NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",sheetIdentity];
        NSMutableDictionary *updateDict=[NSMutableDictionary dictionaryWithObject:status forKey:@"approvalStatus"];
		[myDB updateTable:approvalTimesheetsTable data:updateDict where:whereString intoDatabase:@""];
	}
}


-(BOOL)checkUserPermissionWithPermissionName:(NSString*)permissionName andUserId:(NSString *)userID{
    
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *permissionArr = [myDB select:@"*" from:userPermissionsTable where:[NSString stringWithFormat:@"permissionName = '%@' and user_identity='%@' ",permissionName,userID] intoDatabase:@""];
	//DLog(@"PERMISSIONS ARRAY FOR EXPENSES %@",permissionArr);
	if ([permissionArr count] != 0) {
		if([[[permissionArr objectAtIndex: 0] objectForKey: @"status"] isEqualToString: @"1"]) {
			return YES;
		}
	}
	return NO;
}


-(NSMutableArray*)getSystemPreferencesApprovalDueDate
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *systemPreferencesArr = [myDB select:@"*" from:@"systemPreferences" where:[NSString stringWithFormat: @" name='%@' ",@"TimesheetApprovalDueDays" ]intoDatabase:@""];
	if (systemPreferencesArr != nil && [systemPreferencesArr count]!=0) {
		return systemPreferencesArr;
	}
	return nil;
}


@end
