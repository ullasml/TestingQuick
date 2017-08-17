//
//  SyncTimesheets.m
//  Replicon
//
//  Created by vijaysai on 7/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2SyncTimesheets.h"


@implementation G2SyncTimesheets

static int syncFinishedEntriesCount = 0;
static int totalEntriesModifiedCount = 0;

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		if(timesheetModel == nil) {
			timesheetModel = [[G2TimesheetModel alloc]init];
		}
		if (supportDataModel == nil) {
			supportDataModel = [[G2SupportDataModel alloc] init];
		}
		
	}
	return self;
}

-(void) syncModifiedTimesheets :(id)_delegate {
	@autoreleasepool {
	
	
		NSMutableArray *modifiedSheets = [timesheetModel getModifiedTimesheets];
		
		if(modifiedSheets != nil && [modifiedSheets count] > 0) {
			
			
			
			[[NSNotificationCenter defaultCenter] 
			 addObserver:self selector:@selector(checkAndStopSync) name:FETCH_TIMESHEET_BY_IDENTITY object:nil];
			
			[[NSNotificationCenter defaultCenter] 
			 addObserver:self selector:@selector(checkAndStopSync) name:EDITED_TIMEENTRY_SYNCED_NOTIFICATION object:nil];
			
			for (NSDictionary *timeSheetDict in modifiedSheets) {
				
				NSString *sheetIdentity = [timeSheetDict objectForKey:@"identity"];
				
				NSMutableArray *createdEntries = [timesheetModel getOfflineCreatedTimeEntries: sheetIdentity];
				NSMutableArray *editedEntries = [timesheetModel getOfflineEditedTimeEntries: sheetIdentity];
				//NSMutableArray *deletedEntries = [timesheetModel getOfflineDeletedTimeEntries: sheetIdentity];
				
				
				if (editedEntries != nil && [editedEntries count] > 0) {
					totalEntriesModifiedCount += 1;
					
					[[G2RepliconServiceManager timesheetService] sendRequestToSyncOfflineEditedEntriesForSheet:
															[self buildEntryObjects: editedEntries] 
															sheetId:sheetIdentity delegate:self];
					
				}
				
				if (createdEntries != nil && [createdEntries count] > 0) {
					totalEntriesModifiedCount += 1;
					
					[[G2RepliconServiceManager timesheetService] sendRequestToSyncOfflineCreatedEntriesForSheet:
																[self buildEntryObjects: createdEntries] 
																sheetId:sheetIdentity delegate:self];
					
				}
			}
			
			CFRunLoopRun(); // Avoid thread exiting
		}
	}	
}


-(NSMutableArray *) buildEntryObjects: (NSMutableArray *) editedEntries {
	
	NSMutableArray *entriesArray = [NSMutableArray array];
	for (NSDictionary *entryDict in editedEntries) {
		
		G2TimeSheetEntryObject *timeSheetEntryObject=[[G2TimeSheetEntryObject alloc]init];
		
		[timeSheetEntryObject setIdentity:[entryDict objectForKey:@"identity"]];
		[timeSheetEntryObject setSheetId:[entryDict objectForKey:@"sheetIdentity"]];
		NSDate *entryDate = [G2Util convertStringToDate:[entryDict objectForKey:@"entryDate"]];
		[timeSheetEntryObject setEntryDate:entryDate];
		[timeSheetEntryObject setNumberOfHours:[entryDict objectForKey:@"durationDecimalFormat"]];
		[timeSheetEntryObject setClientIdentity:[entryDict objectForKey:@"clientIdentity"]];
		[timeSheetEntryObject setProjectIdentity:[entryDict objectForKey:@"projectIdentity"]];
		//[timeSheetEntryObject setTaskIdentity:[entryDict objectForKey:@"taskIdentity"]];
		[timeSheetEntryObject.taskObj setTaskIdentity:[entryDict objectForKey:@"taskIdentity"]];
		[timeSheetEntryObject setBillingIdentity:[entryDict objectForKey:@"billingIdentity"]];
		[timeSheetEntryObject setComments:[entryDict objectForKey:@"comments"]];
		
		NSNumber *projectRoleId = [self getBillingRoleIdentity:
								   [entryDict objectForKey:@"billingIdentity"] :[entryDict objectForKey:@"projectIdentity"]];
		if (projectRoleId != nil && ![projectRoleId isKindOfClass:[NSNull class]]) {
			[timeSheetEntryObject setProjectRoleId:projectRoleId];
		}
		
		[entriesArray addObject:timeSheetEntryObject];
       
	}
	return entriesArray;
}

-(void)checkAndStopSync {
	
	syncFinishedEntriesCount++;
	if (syncFinishedEntriesCount == totalEntriesModifiedCount) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:FETCH_TIMESHEET_BY_IDENTITY object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:EDITED_TIMEENTRY_SYNCED_NOTIFICATION object:nil];
		CFRunLoopStop(CFRunLoopGetCurrent()); // Exit Thread
	}
}

-(NSNumber *)getBillingRoleIdentity:(NSString *)billingIdentity :(NSString *)_projectIdentity {
	DLog(@"getBillingRoleIdentity :%@",billingIdentity);
	NSString *projectIdentity = _projectIdentity;
	
	if (billingIdentity != nil &&  ![billingIdentity isKindOfClass:[NSNull class]]
		&& projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]]) {
		
		DLog(@"billing identity not null & project not nil");
		if (![billingIdentity isEqualToString:BILLING_BILLABLE] &&
			![billingIdentity isEqualToString:BILLING_NONBILLABLE] &&
			![billingIdentity isEqualToString:BILLING_PROJECT_RATE] &&
			![billingIdentity isEqualToString:BILLING_USER_RATE] &&
			![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
			DLog(@"billing idenity is rolerate");
			NSNumber *projectRoleId = [supportDataModel getProjectRoleIdForBilling:billingIdentity : projectIdentity];
			DLog(@"projectRoleId %@",projectRoleId);
			if (projectRoleId != nil && ![projectRoleId isKindOfClass:[NSNull class]] ) {
				return projectRoleId;
			}
		}
		else if ([billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
			DLog(@"biling is department");
			NSNumber *projectDeptId = [supportDataModel getDepartmentIdForBilling: billingIdentity : projectIdentity];
			//DLog(@"projectdept id", projectDeptId);
			if (projectDeptId != nil && ![projectDeptId isKindOfClass:[NSNull class]] ) {
				return projectDeptId;
			}
		}
	}
	return nil;
}


@end
