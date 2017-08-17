//
//  TimesheetObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 19/12/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimesheetObject : NSObject
{
    
    NSString                *timesheetStatus;
    NSDate					*timesheetStartDate;
	NSDate					*timesheetEndDate;
	NSDate					*timeSheetDueDate;
    NSString                *timesheetOvertimeHours;
    NSString                *timesheetOvertimeDecimal;
    NSString                *timesheetTimeoffHours;
    NSString                *timesheetTimeoffDecimal;
    NSString                *timesheetRegularHours;
    NSString                *timesheetRegularDecimal;
    NSString                *timesheetTotalHours;
    NSString                *timesheetTotalDecimal;
    NSString                *timesheetMealPenalties;
    NSString				*timesheetURI;
	NSString				*timesheetPeriod;
    NSString                *numberOfHours;
	NSString                *projectIdentity;
	NSString                *projectName;
    NSString                *billingIdentity;
	NSString                *billingName;
    NSString                 *entryDate;
    NSString                *payrollName;
    NSString                *payrollIdentity;
    NSString                *activityName;
    NSString                *activityIdentity;
    BOOL                    hasComments;
    BOOL                    hasTimeOff;
    BOOL                    isHolidayDayOff;
    BOOL                    isWeeklyDayOff;
    NSString                *clientName;
    NSString                *clientIdentity;
    
    NSString                *taskName;
    NSString                *taskIdentity;
    
    NSString                *userID;
    NSString                *userFirstName;
    NSString                *userLasttName;
    
    NSString                *TimeOffName;
    NSString                *TimeOffIdentity;
    NSString                *entryDateWithDesiredFormat;
    
    //Implentation for US8956//JUHI
    NSString *breakName;
    NSString *breakUri;
    
    //Implemtation For US8906_Shifts//Juhi
    BOOL                    hasEntry;
    
    NSString *rowNumber;

}

@property (nonatomic,strong)    NSString    *timesheetStatus;
@property (nonatomic,strong)	NSDate      *timesheetStartDate;
@property (nonatomic,strong)	NSDate      *timesheetEndDate;
@property (nonatomic,strong)	NSDate      *timeSheetDueDate;
@property (nonatomic,strong)	NSString    *timesheetOvertimeHours;
@property (nonatomic,strong)	NSString    *timesheetTimeoffHours;
@property (nonatomic,strong)	NSString    *timesheetRegularHours;
@property (nonatomic,strong)	NSString    *timesheetTotalHours;
@property (nonatomic,strong)    NSString    *timesheetMealPenalties;
@property (nonatomic,strong)	NSString    *timesheetURI;
@property (nonatomic,strong)	NSString	*timesheetPeriod;
@property (nonatomic,strong)	NSString	*timesheetOvertimeDecimal;
@property (nonatomic,strong)	NSString	*timesheetTimeoffDecimal;
@property (nonatomic,strong)	NSString	*timesheetRegularDecimal;
@property (nonatomic,strong)	NSString	*timesheetTotalDecimal;
@property (nonatomic,strong)    NSString    *numberOfHours;
@property(nonatomic,strong)     NSString    *projectIdentity;
@property(nonatomic,strong)     NSString    *projectName;
@property(nonatomic,strong)     NSString      *entryDate;
@property(nonatomic,strong)     NSString    *billingIdentity;
@property(nonatomic,strong)     NSString    *billingName;
@property(nonatomic,strong)     NSString    *payrollName;
@property(nonatomic,strong)     NSString    *payrollIdentity;
@property(nonatomic,strong)     NSString    *activityName;
@property(nonatomic,strong)     NSString    *activityIdentity;
@property(nonatomic,assign)     BOOL         hasComments;
@property(nonatomic,assign)     BOOL         hasTimeOff;
@property(nonatomic,assign)     BOOL         isHolidayDayOff;
@property(nonatomic,assign)     BOOL         isWeeklyDayOff;
@property(nonatomic,assign)     BOOL         isDayOff;

@property(nonatomic,strong)     NSString    *clientName;
@property(nonatomic,strong)     NSString    *clientIdentity;

@property(nonatomic,strong)     NSString    *taskName;
@property(nonatomic,strong)     NSString    *taskIdentity;

@property (nonatomic,strong)	NSString    *userID;
@property (nonatomic,strong)	NSString    *userFirstName;
@property (nonatomic,strong)	NSString    *userLasttName;

@property (nonatomic,strong)	NSString    *TimeOffName;
@property (nonatomic,strong)	NSString    *TimeOffIdentity;
@property(nonatomic,strong)     NSString    *entryDateWithDesiredFormat;

//Implentation for US8956//JUHI
@property(nonatomic,strong)NSString *breakName;
@property(nonatomic,strong)NSString *breakUri;

//Implemtation For US8906_Shifts//Juhi
@property(nonatomic,assign)BOOL hasEntry;

//MOBI-746
@property(nonatomic,strong)     NSString    *programName;
@property(nonatomic,strong)     NSString    *programIdentity;

@property(nonatomic,strong)NSString *rowNumber;

@end
