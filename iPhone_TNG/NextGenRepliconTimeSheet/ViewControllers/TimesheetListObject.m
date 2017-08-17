//
//  TimesheetListObject.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 09/01/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "TimesheetListObject.h"

@implementation TimesheetListObject

-(id)initWithDictionary:(NSDictionary *)timesheetDict {
    self = [super init];
    if (self!=nil) {
        NSString *timesheetStatus=[timesheetDict objectForKey:@"approvalStatus"];
        self.timesheetStatus= timesheetStatus;
        self.timesheetStartDate=[Util convertTimestampFromDBToDate:[[timesheetDict objectForKey:@"startDate"] stringValue]];
        self.timesheetEndDate=[Util convertTimestampFromDBToDate:[[timesheetDict objectForKey:@"endDate"] stringValue]];
        self.timeSheetDueDate=[Util convertTimestampFromDBToDate:[[timesheetDict objectForKey:@"dueDate"] stringValue]];
        self.timesheetOvertimeHours=[timesheetDict objectForKey:@"overtimeDurationHour"];
        self.timesheetRegularHours=[timesheetDict objectForKey:@"regularDurationHour"];
        self.timesheetTimeoffHours= [timesheetDict objectForKey:@"timeoffDurationHour"];
        self.timesheetTotalHours=[timesheetDict objectForKey:@"totalDurationHour"];
        if ([timesheetDict objectForKey:@"overtimeDurationDecimal"]!=nil && ![[timesheetDict objectForKey:@"overtimeDurationDecimal"] isKindOfClass:[NSNull class]])
        {
            self.timesheetOvertimeDecimal=[Util getRoundedValueFromDecimalPlaces:[[timesheetDict objectForKey:@"overtimeDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
        }
        if ([timesheetDict objectForKey:@"regularDurationDecimal"]!=nil && ![[timesheetDict objectForKey:@"regularDurationDecimal"] isKindOfClass:[NSNull class]])
        {
            self.timesheetRegularDecimal=[Util getRoundedValueFromDecimalPlaces:[[timesheetDict objectForKey:@"regularDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
        }
        if ([timesheetDict objectForKey:@"timeoffDurationDecimal"]!=nil && ![[timesheetDict objectForKey:@"timeoffDurationDecimal"] isKindOfClass:[NSNull class]])
        {
            self.timesheetTimeoffDecimal= [Util getRoundedValueFromDecimalPlaces:[[timesheetDict objectForKey:@"timeoffDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
        }
        if ([timesheetDict objectForKey:@"totalDurationDecimal"]!=nil && ![[timesheetDict objectForKey:@"totalDurationDecimal"] isKindOfClass:[NSNull class]])
        {
            self.timesheetTotalDecimal=[Util getRoundedValueFromDecimalPlaces:[[timesheetDict objectForKey:@"totalDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
        }
        
        self.timesheetMealPenalties=[timesheetDict objectForKey:@"mealBreakPenalties"];
        self.timesheetURI=[timesheetDict objectForKey:@"timesheetUri"];
        
        NSString *startDate=[Util convertPickerDateToStringShortStyle:
                             [Util convertTimestampFromDBToDate:[[timesheetDict objectForKey:@"startDate"] stringValue]]];
        NSString *endDate=[Util convertPickerDateToStringShortStyle:
                           [Util convertTimestampFromDBToDate:[[timesheetDict objectForKey:@"endDate"] stringValue]]];
        self.isCurrentTimesheetPeriod=[Util getCurrenTimeSheetPeriodFromTimesheetStartDate:self.timesheetStartDate andTimesheetEndDate:self.timesheetEndDate];
        self.timesheetPeriod = [NSString stringWithFormat:@"%@ - %@",startDate,endDate];
        self.timesheetFormat=[timesheetDict objectForKey:@"timesheetFormat"];
        if ([timesheetDict objectForKey:@"canEditTimesheet"]!=nil && ![[timesheetDict objectForKey:@"canEditTimesheet"] isKindOfClass:[NSNull class]])
        {
            self.isTimesheetEditable=[[timesheetDict objectForKey:@"canEditTimesheet"] boolValue];
        }

    }
    return self;
}


-(id) copyWithZone: (NSZone *) zone
{
    TimesheetListObject *copyObject = [[TimesheetListObject allocWithZone: zone] init];
    
    [copyObject setTimesheetStatus:[self.timesheetStatus copy]];
    [copyObject setTimesheetStartDate:[self.timesheetStartDate copy]];
    [copyObject setTimesheetEndDate:[self.timesheetEndDate copy]];
    [copyObject setTimeSheetDueDate:[self.timeSheetDueDate copy]];
    [copyObject setTimesheetOvertimeHours:[self.timesheetOvertimeHours copy]];
    [copyObject setTimesheetTimeoffHours:[self.timesheetTimeoffHours copy]];
    [copyObject setTimesheetRegularHours:[self.timesheetRegularHours copy]];
    [copyObject setTimesheetTotalHours:[self.timesheetTotalHours copy]];
    [copyObject setTimesheetMealPenalties:[self.timesheetMealPenalties copy]];
    [copyObject setTimesheetURI:[self.timesheetURI copy]];
    [copyObject setTimesheetPeriod:[self.timesheetPeriod copy]];
    [copyObject setTimesheetOvertimeDecimal:[self.timesheetOvertimeDecimal copy]];
    [copyObject setTimesheetTimeoffDecimal:[self.timesheetTimeoffDecimal copy]];
    [copyObject setTimesheetRegularDecimal:[self.timesheetRegularDecimal copy]];
    [copyObject setTimesheetTotalDecimal:[self.timesheetTotalDecimal copy]];
    [copyObject setTimesheetFormat:[self.timesheetFormat copy]];
    [copyObject setIsCurrentTimesheetPeriod:self.isCurrentTimesheetPeriod];
    [copyObject setIsTimesheetEditable:self.isTimesheetEditable];
    
    return copyObject;
}
@end
