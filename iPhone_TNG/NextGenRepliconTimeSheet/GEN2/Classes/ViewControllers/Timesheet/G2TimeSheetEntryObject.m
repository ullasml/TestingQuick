//
//  TimeSheetDetailsObject.m
//  Replicon
//
//  Created by Hepciba on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2TimeSheetEntryObject.h"

@implementation G2TimeSheetEntryObject

@synthesize clientArray;
@synthesize projectArray;
@synthesize activityArray;
@synthesize numberOfHours;
@synthesize comments;
@synthesize sheetId;
@synthesize identity;
@synthesize clientIdentity;
@synthesize clientName;
@synthesize projectIdentity;
@synthesize projectName;
//@synthesize taskIdentity;
//@synthesize taskName;
@synthesize billingIdentity;
@synthesize billingName;
@synthesize activityIdentity;
@synthesize activityName;
@synthesize entryDate;
@synthesize isModified;
@synthesize entryType;
@synthesize timeDefaultValue;
@synthesize dateDefaultValue;
@synthesize billingDefaultValue;
@synthesize missingFields;
@synthesize availableFields;
@synthesize projectRoleId;
@synthesize clientAllocationId;
@synthesize taskObj;
@synthesize projectRemoved;
@synthesize userID;
@synthesize clientProjectTask;
@synthesize rowUDFArray,cellUDFArray;
@synthesize inTime,outTime;
@synthesize numberOfHoursInDouble;
@synthesize timeCodeType ;
@synthesize typeIdentity;
@synthesize projectBillableStatus;

- (id) init
{
	self = [super init];
	if (self != nil) {
		taskObj = [[G2TaskObject alloc] init];
	}
	return self;
}


+(G2TimeSheetEntryObject *)createObjectWithDefaultValues{


	G2TimeSheetEntryObject *timeSheetEntryObject = [[G2TimeSheetEntryObject alloc] init]; 
	[timeSheetEntryObject setClientProjectTask:@"Select"];
//	[timeSheetEntryObject setDateDefaultValue:[NSDate date]];
	[timeSheetEntryObject setNumberOfHours:@"0.00"];
	[timeSheetEntryObject setEntryDate:[NSDate date]];
	[timeSheetEntryObject setActivityName:ACTIVITIES_DEFAULT_NONE];
	
	return timeSheetEntryObject;
}


@end
