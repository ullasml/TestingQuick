//
//  TimesheetObject.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 19/12/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "TimesheetObject.h"

@implementation TimesheetObject

@synthesize timesheetStatus;
@synthesize timesheetStartDate;
@synthesize timesheetEndDate;
@synthesize timeSheetDueDate;
@synthesize timesheetOvertimeHours;
@synthesize timesheetTimeoffHours;
@synthesize timesheetRegularHours;
@synthesize timesheetTotalHours;
@synthesize timesheetMealPenalties;
@synthesize timesheetOvertimeDecimal;
@synthesize timesheetTimeoffDecimal;
@synthesize timesheetRegularDecimal;
@synthesize timesheetTotalDecimal;
@synthesize timesheetURI;
@synthesize timesheetPeriod;
@synthesize numberOfHours;
@synthesize projectIdentity;
@synthesize projectName;
@synthesize entryDate;
@synthesize billingIdentity;
@synthesize billingName;
@synthesize payrollName;
@synthesize payrollIdentity;
@synthesize activityName;
@synthesize activityIdentity;
@synthesize hasComments;
@synthesize hasTimeOff;
@synthesize isHolidayDayOff;
@synthesize isWeeklyDayOff;
@synthesize isDayOff;
@synthesize clientName;
@synthesize clientIdentity;

@synthesize taskName;
@synthesize taskIdentity;

@synthesize userID;
@synthesize userFirstName;
@synthesize userLasttName;
@synthesize TimeOffName;
@synthesize TimeOffIdentity;
@synthesize entryDateWithDesiredFormat;
//Implemtation For US8906_Shifts//Juhi
@synthesize hasEntry;

//Implentation for US8956//JUHI
@synthesize breakName;
@synthesize breakUri;

@synthesize programName;
@synthesize programIdentity;
@synthesize rowNumber;

- (id) init
{
	self = [super init];
	if (self != nil)
    {
		
    }
	return self;
}




@end
