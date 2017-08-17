//
//  TimesheetApprovalHistoryObject.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 12/04/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "TimesheetApprovalHistoryObject.h"

@implementation TimesheetApprovalHistoryObject
@synthesize approvalActionStatus;
@synthesize approvalActionDate;
@synthesize approvalTimesheetURI;
//Implementation for MOBI-261//JUHI
@synthesize approvalActingForUser;
@synthesize approvalActingUser;
@synthesize approvalComments;
@synthesize approvalActionStatusUri;

- (id) init
{
	self = [super init];
	if (self != nil)
    {
		
    }
	return self;
}



@end
