//
//  TimeSheetObject.m
//  Replicon
//
//  Created by Hepciba on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2TimeSheetObject.h"

@implementation G2TimeSheetObject
@synthesize startDate;
@synthesize projects;
@synthesize endDate;
@synthesize totalHrs;
@synthesize status;
@synthesize dueDate;
@synthesize timeEntriesArray;
@synthesize identity;
@synthesize activities;
@synthesize isModified;
@synthesize approversRemaining;
@synthesize userID;
@synthesize userFirstName;
@synthesize userLasttName;
@synthesize timeSheetType;
@synthesize effectiveDate;
@synthesize disclaimerAccepted;

- (id) init: (id) test
{
	self = [super init];
	if (self != nil) {
		projects = [NSMutableArray array];
		activities = [NSMutableArray array];
		
	}
	return self;
}



@end
