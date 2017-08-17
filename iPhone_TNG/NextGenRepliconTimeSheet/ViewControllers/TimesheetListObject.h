//
//  TimesheetListObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 09/01/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimesheetListObject : NSObject<NSCopying>
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
@property (nonatomic,strong)    NSString    *timesheetFormat;
@property (nonatomic,assign)    BOOL        isCurrentTimesheetPeriod;
@property (nonatomic,assign)    BOOL        isTimesheetEditable;

-(id)initWithDictionary:(NSDictionary *)dict;
-(id) copyWithZone: (NSZone *) zone;

@end
