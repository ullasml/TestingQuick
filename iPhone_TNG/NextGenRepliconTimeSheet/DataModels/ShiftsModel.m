//
//  ShiftsModel.m
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 20/02/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "ShiftsModel.h"
#import "TimeoffModel.h"

static NSString *shiftsTable=@"Shifts";
static NSString *shiftDetailsTable=@"ShiftDetails";
static NSString *shiftEntryTable=@"ShiftEntry";
static NSString *shiftObjectExtensionFieldsTable=@"ShiftObjectExtensionFields";

@implementation ShiftsModel


#pragma mark - save methods

-(void)saveShiftDataToDB:(NSMutableDictionary *)responseDictionary
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    [myDB insertIntoTable:shiftsTable data:responseDictionary intoDatabase:@""];
}

-(void)saveShiftDetailsDataFromApiToDB:(NSMutableDictionary *)response
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *idString = [[NSUserDefaults standardUserDefaults] valueForKey:@"id"];
    NSString  *typeString= @"";
    
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    NSMutableArray  *dataArray = [NSMutableArray array];
    dataArray = [response objectForKey:@"dataPoints"];
    for (int i= 0; i<[dataArray count]; i++) {
        NSMutableDictionary  *dayDataDict = [NSMutableDictionary dictionary];
        dayDataDict = [[dataArray objectAtIndex:i] objectForKey:@"date"];
        
        NSDate *dueDate=[Util convertApiDateDictToDateFormat:dayDataDict];
        
        [dataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"date"];

        
        NSMutableArray  *shiftArray = [NSMutableArray array];
        NSString  *shiftName= @"";
        NSString  *shiftUri= @"";
        NSString  *colorCode= @"";
        NSString  *noteString= @"";
        NSString  *breakType = @"";
        NSString  *breakUri= @"";
        
        if ([[dataArray objectAtIndex:i] objectForKey:@"assignments"]!=nil &&![[[dataArray objectAtIndex:i] objectForKey:@"assignments"] isKindOfClass:[NSNull class]])
        {
            shiftArray = [[dataArray objectAtIndex:i] objectForKey:@"assignments"];
            
            if ([shiftArray count]>0)
            {
                for (int k = 0; k<[shiftArray  count]; k++) {
                    
                    
                    NSString  *shiftDurationString= @"";
                    NSString  *startTimeStamp = @"";
                    NSString  *endTimeStamp= @"";
                    NSMutableDictionary *shiftDurationDict =[NSMutableDictionary dictionary];
                    shiftDurationDict = [shiftArray objectAtIndex:k];
                    
                    if ([shiftDurationDict objectForKey:@"note"]!=nil ||![[shiftDurationDict objectForKey:@"note"] isKindOfClass:[NSNull class]]) {
                        noteString = [shiftDurationDict objectForKey:@"note"];
                        
                    }
                    shiftName = [[shiftDurationDict objectForKey:@"shift"] objectForKey:@"displayText"];
                    shiftUri = [[shiftDurationDict objectForKey:@"shift"] objectForKey:@"uri"];
                    
                    
                    
                    NSMutableDictionary *colorCodeDict =[NSMutableDictionary dictionary];
                    if ([shiftDurationDict objectForKey:@"color"]!=nil &&![[shiftDurationDict objectForKey:@"color"] isKindOfClass:[NSNull class]]) {
                        colorCodeDict = [shiftDurationDict objectForKey:@"color"];
                        NSInteger blue = [[colorCodeDict objectForKey:@"blue"] longValue];
                        NSInteger green = [[colorCodeDict objectForKey:@"green"] longValue];
                        NSInteger red = [[colorCodeDict  objectForKey:@"red"]longValue ];
                        
                        colorCode = [self hexStringFromColor:[UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:1]];
                    }
                   
                    NSMutableDictionary *inTimeDict = [NSMutableDictionary dictionary];
                    NSMutableDictionary *outTimeDict = [NSMutableDictionary dictionary];
                    
                    
                    
                    if (([shiftDurationDict objectForKey:@"inTime"]!=nil && ![[shiftDurationDict objectForKey:@"inTime"] isKindOfClass:[NSNull class]]) && ([shiftDurationDict objectForKey:@"outTime"]!=nil && ![[shiftDurationDict objectForKey:@"outTime"] isKindOfClass:[NSNull class]]))
                    {
                        if ([shiftDurationDict objectForKey:@"inTime"]!=nil && ![[shiftDurationDict objectForKey:@"inTime"] isKindOfClass:[NSNull class]]) {
                            int hours=[[[shiftDurationDict objectForKey:@"inTime"] objectForKey:@"hour"] intValue];
                            int dayoffset=[[[shiftDurationDict objectForKey:@"inTime"] objectForKey:@"dayOffset"] intValue];
                            if (dayoffset>0)
                            {
                                hours=hours+(24*dayoffset);
                            }
                            [inTimeDict setObject:[NSNumber numberWithInt:hours] forKey:@"hour"];
                            [inTimeDict setObject:[[shiftDurationDict objectForKey:@"inTime"] objectForKey:@"hour"] forKey:@"hour"];
                            [inTimeDict setObject:[[shiftDurationDict objectForKey:@"inTime"] objectForKey:@"minute"] forKey:@"minute"];
                        }
                        if ([shiftDurationDict objectForKey:@"outTime"]!=nil && ![[shiftDurationDict objectForKey:@"outTime"] isKindOfClass:[NSNull class]]) {
                            int hours=[[[shiftDurationDict objectForKey:@"outTime"] objectForKey:@"hour"] intValue];
                            int dayoffset=[[[shiftDurationDict objectForKey:@"outTime"] objectForKey:@"dayOffset"] intValue];
                            if (dayoffset>0)
                            {
                                hours=hours+(24*dayoffset);
                            }
                            [outTimeDict setObject:[NSNumber numberWithInt:hours] forKey:@"hour"];
                            [outTimeDict setObject:[[shiftDurationDict objectForKey:@"outTime"] objectForKey:@"minute"] forKey:@"minute"];
                        }
                        
                        typeString = SHIFT_ENTRY;
                        NSMutableDictionary *workEntryDataDict = [NSMutableDictionary dictionary];
                        startTimeStamp=[Util convertApiTimeDictTo12HourTimeString:inTimeDict];
                        endTimeStamp=[Util convertApiTimeDictTo12HourTimeString:outTimeDict];
                        NSString *startTime=nil;
                        NSString *endTime=nil;
                        if ([startTimeStamp isEqualToString:@"0:00 AM"])
                        {
                            startTime=@"12:00 AM";
                            
                        }
                        else
                            startTime=startTimeStamp;
                        if ([endTimeStamp isEqualToString:@"0:00 AM"]) {
                            endTime=@"12:00 AM";
                        }
                        else
                            endTime=endTimeStamp;
                        shiftDurationString = [NSString stringWithFormat:@" %@ - %@ ",startTime ,endTime ];
                        
                        NSDateComponents *startDatecomps = [[NSCalendar currentCalendar]
                                                            components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth
                                                            fromDate:[NSDate date]];
                        [startDatecomps setDay:[[dayDataDict objectForKey:@"day"] longValue]];
                        [startDatecomps setMonth:[[dayDataDict objectForKey:@"month"] longValue]];
                        [startDatecomps setYear:[[dayDataDict objectForKey:@"year"] longValue]];
                        [startDatecomps setHour:[[inTimeDict objectForKey:@"hour"] longValue]];
                        [startDatecomps setMinute:[[inTimeDict objectForKey:@"minute"] longValue]];
                        
                        NSDateComponents *endDatecomps = [[NSCalendar currentCalendar]
                                                          components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth
                                                          fromDate:[NSDate date]];
                        [endDatecomps setDay:[[dayDataDict objectForKey:@"day"] longValue]];
                        [endDatecomps setMonth:[[dayDataDict objectForKey:@"month"] longValue]];
                        [endDatecomps setYear:[[dayDataDict objectForKey:@"year"] longValue]];
                        [endDatecomps setHour:[[outTimeDict objectForKey:@"hour"] longValue]];
                        [endDatecomps setMinute:[[outTimeDict objectForKey:@"minute"] longValue]];
                        
                        
                        [workEntryDataDict setValue:typeString forKey:@"type"];
                        [workEntryDataDict setValue:shiftUri   forKey:@"shiftUri"];
                        [workEntryDataDict setValue:shiftName  forKey:@"shiftName"];
                        [workEntryDataDict setValue:shiftDurationString forKey:@"shiftDuration"];
                        //[workEntryDataDict setValue:holidatString forKey:@"holiday"];
                        [workEntryDataDict setValue:noteString forKey:@"note"];
                        [workEntryDataDict setValue:idString forKey:@"id"];
                        [workEntryDataDict setValue:colorCode forKey:@"colorCode"];
                        [workEntryDataDict setObject:startTimeStamp forKey:@"in_time"];
                        [workEntryDataDict setObject:endTimeStamp forKey:@"out_time"];
                        [workEntryDataDict setObject:[NSNumber numberWithDouble:[[[NSCalendar currentCalendar] dateFromComponents:startDatecomps] timeIntervalSince1970]] forKey:@"in_time_stamp"];
                        [workEntryDataDict setObject:[NSNumber numberWithDouble:[[[NSCalendar currentCalendar] dateFromComponents:endDatecomps] timeIntervalSince1970]] forKey:@"out_time_stamp"];
                        [workEntryDataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"date"];
                        [workEntryDataDict setObject:[NSNumber numberWithInt:k] forKey:@"shiftIndex"];
                        [myDB insertIntoTable:shiftDetailsTable data:workEntryDataDict intoDatabase:@""];
                    }
                    
                    
                    if ([shiftDurationDict objectForKey:@"breakSegments"] != nil && ![[shiftDurationDict objectForKey:@"breakSegments"] isKindOfClass:[NSNull class]])
                    {
                        
                        if ([[shiftDurationDict objectForKey:@"breakSegments"] objectForKey:@"breakEntries"] != nil && ![[[shiftDurationDict objectForKey:@"breakSegments"] objectForKey:@"breakEntries"] isKindOfClass:[NSNull class]])
                        {
                            NSMutableArray *shiftDurationArray = [[shiftDurationDict objectForKey:@"breakSegments"] objectForKey:@"breakEntries"];
                            if ([shiftDurationArray count]>0)
                            {
                                for (int shiftIndex = 0; shiftIndex < [shiftDurationArray count]; shiftIndex++) {
                                    typeString = BREAK_ENTRY;
                                    NSMutableDictionary *entryDict = [shiftDurationArray objectAtIndex:shiftIndex];
                                    NSMutableDictionary *breakDataDict = [NSMutableDictionary dictionary];
                                    NSString  *breakDurationString= @"";
                                    NSString  *startBreakTimeStamp = @"";
                                    NSString  *endBreakTimeStamp= @"";
                                    NSMutableDictionary *inTimeBreakDict = [NSMutableDictionary dictionary];
                                    NSMutableDictionary *outTimeBreakDict = [NSMutableDictionary dictionary];
                                    if (entryDict != nil && ![entryDict isKindOfClass:[NSNull class]]) {
                                        typeString = BREAK_ENTRY;
                                        
                                        if ([entryDict objectForKey:@"inTime"]!=nil && ![[entryDict objectForKey:@"inTime"] isKindOfClass:[NSNull class]]) {
                                            int hours=[[[entryDict objectForKey:@"inTime"] objectForKey:@"hour"] intValue];
                                            int dayoffset=[[[entryDict objectForKey:@"inTime"] objectForKey:@"dayOffset"] intValue];
                                            if (dayoffset>0)
                                            {
                                                hours=hours+(24*dayoffset);
                                            }
                                            [inTimeBreakDict setObject:[NSNumber numberWithInt:hours] forKey:@"hour"];
                                            [inTimeBreakDict setObject:[[entryDict objectForKey:@"inTime"] objectForKey:@"minute"] forKey:@"minute"];
                                        }
                                        if (([entryDict objectForKey:@"inTime"]!=nil && ![[entryDict objectForKey:@"inTime"] isKindOfClass:[NSNull class]]) && ([entryDict objectForKey:@"duration"]!=nil && ![[entryDict objectForKey:@"duration"] isKindOfClass:[NSNull class]]))
                                        {
                                            
                                            int inTimeHours =[[inTimeBreakDict objectForKey:@"hour"] intValue];
                                            int inTimeMinutes = [[inTimeBreakDict objectForKey:@"minute"] intValue];
                                            int durationHour=[[[entryDict objectForKey:@"duration"] objectForKey:@"hours"] intValue];
                                            int durationMinute=[[[entryDict objectForKey:@"duration"] objectForKey:@"minutes"] intValue];
                                            
                                            int outHour=inTimeHours+durationHour;
                                            int outMintute=inTimeMinutes+durationMinute;
                                            [outTimeBreakDict setObject:[NSNumber numberWithInt:outHour] forKey:@"hour"];
                                            [outTimeBreakDict setObject:[NSNumber numberWithInt:outMintute] forKey:@"minute"];
                                        }
                                        
                                        startBreakTimeStamp=[Util convertApiTimeDictTo12HourTimeString:inTimeBreakDict];
                                        endBreakTimeStamp=[Util convertApiTimeDictTo12HourTimeString:outTimeBreakDict];
                                        breakType = [[entryDict objectForKey:@"breakType"] objectForKey:@"displayText"];
                                        breakUri = [[entryDict objectForKey:@"breakType"] objectForKey:@"uri"];
                                        NSString *startTime=nil;
                                        NSString *endTime=nil;
                                        if ([startBreakTimeStamp isEqualToString:@"0:00 AM"])
                                        {
                                            startTime=@"12:00 AM";
                                            
                                        }
                                        else
                                            startTime=startBreakTimeStamp;
                                        if ([endTimeStamp isEqualToString:@"0:00 AM"]) {
                                            endTime=@"12:00 AM";
                                        }
                                        else
                                            endTime=endBreakTimeStamp;
                                        breakDurationString = [NSString stringWithFormat:@" %@ - %@ ",startTime ,endTime ];
                                        
                                        NSDateComponents *startBreakDatecomps = [[NSCalendar currentCalendar]
                                                                                 components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth
                                                                                 fromDate:[NSDate date]];
                                        [startBreakDatecomps setDay:[[dayDataDict objectForKey:@"day"] longValue]];
                                        [startBreakDatecomps setMonth:[[dayDataDict objectForKey:@"month"] longValue]];
                                        [startBreakDatecomps setYear:[[dayDataDict objectForKey:@"year"] longValue]];
                                        [startBreakDatecomps setHour:[[inTimeBreakDict objectForKey:@"hour"] longValue]];
                                        [startBreakDatecomps setMinute:[[inTimeBreakDict objectForKey:@"minute"] longValue]];
                                        
                                        NSDateComponents *endBreakDatecomps = [[NSCalendar currentCalendar]
                                                                               components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth
                                                                               fromDate:[NSDate date]];
                                        [endBreakDatecomps setDay:[[dayDataDict objectForKey:@"day"] longValue]];
                                        [endBreakDatecomps setMonth:[[dayDataDict objectForKey:@"month"] longValue]];
                                        [endBreakDatecomps setYear:[[dayDataDict objectForKey:@"year"] longValue]];
                                        [endBreakDatecomps setHour:[[outTimeBreakDict objectForKey:@"hour"] longValue]];
                                        [endBreakDatecomps setMinute:[[outTimeBreakDict objectForKey:@"minute"] longValue]];
                                        
                                        [breakDataDict setValue:typeString forKey:@"type"];
                                        [breakDataDict setValue:shiftUri   forKey:@"shiftUri"];
                                        [breakDataDict setValue:breakType  forKey:@"breakType"];
                                        [breakDataDict setValue:breakType  forKey:@"breakUri"];
                                        [breakDataDict setValue:colorCode forKey:@"colorCode"];
                                        [breakDataDict setValue:idString forKey:@"id"];
                                        [breakDataDict setValue:shiftName  forKey:@"shiftName"];
                                        [breakDataDict setObject:startBreakTimeStamp forKey:@"in_time"];
                                        [breakDataDict setObject:endBreakTimeStamp forKey:@"out_time"];
                                        [breakDataDict setObject:[NSNumber numberWithDouble:[[[NSCalendar currentCalendar] dateFromComponents:startBreakDatecomps] timeIntervalSince1970]] forKey:@"in_time_stamp"];
                                        [breakDataDict setObject:[NSNumber numberWithDouble:[[[NSCalendar currentCalendar] dateFromComponents:endBreakDatecomps] timeIntervalSince1970]] forKey:@"out_time_stamp"];
                                        [breakDataDict setValue:noteString forKey:@"note"];
                                        [breakDataDict setValue:breakDurationString forKey:@"shiftDuration"];
                                        [breakDataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"date"];
                                        [breakDataDict setObject:[NSNumber numberWithInt:k] forKey:@"shiftIndex"];
                                        [myDB insertIntoTable:shiftDetailsTable data:breakDataDict intoDatabase:@""];
                                    }
                                    
                                    
                                    
                                }
                            }
                        }
                        
                        
                    }
                    else{
                        typeString = SHIFT_ENTRY;
                        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
                        [dataDict setValue:typeString forKey:@"type"];
                        [dataDict setValue:shiftUri   forKey:@"shiftUri"];
                        [dataDict setValue:shiftName  forKey:@"shiftName"];
                        [dataDict setValue:noteString forKey:@"note"];
                        [dataDict setValue:idString forKey:@"id"];
                        [dataDict setValue:colorCode forKey:@"colorCode"];
                        [dataDict setValue:shiftDurationString forKey:@"shiftDuration"];
                        [dataDict setObject:startTimeStamp forKey:@"in_time"];
                        [dataDict setObject:endTimeStamp forKey:@"out_time"];
                        
                        [dataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"date"];
                        [dataDict setObject:[NSNumber numberWithInt:k] forKey:@"shiftIndex"];
                        [myDB insertIntoTable:shiftDetailsTable data:dataDict intoDatabase:@""];
                    }
                    
                    //Implemtation for Sched-114//JUHI
//                    NSString *whereStr=[NSString stringWithFormat:@"shiftUri = '%@' and in_time_stamp='%d'",shiftUri,[[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] integerValue]];
//                    [myDB deleteFromTable:shiftObjectExtensionFieldsTable where:whereStr inDatabase:@""];
                    if ([shiftDurationDict objectForKey:@"extensionFieldValues"]!=nil && ![[shiftDurationDict objectForKey:@"extensionFieldValues"] isKindOfClass:[NSNull class]]) {
                        NSMutableArray *extensionArray=[shiftDurationDict objectForKey:@"extensionFieldValues"];
                        if ([extensionArray count]>0)
                        {
                            [self saveShiftObjectExtensionFieldsDataFromApiToDB:extensionArray forShiftUri:shiftUri andTimeStamp:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] andIndex:[NSNumber numberWithInt:k]];
                        }
                    }
                    
                    
                }
                
            }
        }
        
        
        
        /*
        
        NSMutableArray *timeOffArray = [NSMutableArray array];
        timeOffArray = [[dataArray objectAtIndex:i] objectForKey:@"timeOffs"];
        if ([timeOffArray count]>0)
        {
            for (int j = 0; j< [timeOffArray count]; j++) {
                NSMutableDictionary *timeOffDataDict = [NSMutableDictionary dictionary];
                typeString = TIME_OFF_ENTRY;
                NSMutableDictionary *timeOffDict = [NSMutableDictionary dictionary];
                timeOffDict = [timeOffArray objectAtIndex:j];
                NSString  *timeOffName = [[timeOffDict objectForKey:@"timeOffType"] objectForKey:@"name"];
                NSString  *timeOffUri = [[timeOffDict objectForKey:@"timeOffType"] objectForKey:@"uri"] ;
                NSString  *approvalStatusUri = [[timeOffDict objectForKey:@"approvalStatus"] objectForKey:@"uri"] ;
                NSString  *timeOffDayDuration = [[timeOffDict objectForKey:@"timeOffDuration"] objectForKey:@"decimalWorkdays"];
                [timeOffDataDict setValue:typeString forKey:@"type"];
                [timeOffDataDict setValue:timeOffUri forKey:@"timeOffUri"];
                [timeOffDataDict setValue:idString forKey:@"id"];
                [timeOffDataDict setValue:timeOffName forKey:@"TimeOffName"];
                if ([approvalStatusUri isEqualToString:APPROVED_STATUS_URI])
                {
                    [timeOffDataDict setValue:APPROVED_STATUS   forKey:@"approvalStatus"];
                    
                }
                else if ([approvalStatusUri isEqualToString:NOT_SUBMITTED_STATUS_URI])
                {
                    [timeOffDataDict setValue:NOT_SUBMITTED_STATUS   forKey:@"approvalStatus"];
                }
                else if ([approvalStatusUri isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
                {
                    [timeOffDataDict setValue:WAITING_FOR_APRROVAL_STATUS   forKey:@"approvalStatus"];
                }
                else if ([approvalStatusUri isEqualToString:REJECTED_STATUS_URI])
                {
                    [timeOffDataDict setValue:REJECTED_STATUS   forKey:@"approvalStatus"];
                }
                else
                {
                    [timeOffDataDict setValue:[NSNull null]   forKey:@"approvalStatus"];
                }
                
             
                [timeOffDataDict setValue:timeOffDayDuration   forKey:@"timeOffDuration"];
                [timeOffDataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"date"];
                double decimalHours = [[Util convertApiTimeDictToDecimal:[[timeOffDict objectForKey:@"timeOffDuration"] objectForKey:@"calendarDayDuration"]] newDoubleValue];
                [timeOffDataDict setObject:[NSNumber numberWithDouble:decimalHours] forKey:@"timeOffHourDuration"];
                [myDB insertIntoTable:shiftDetailsTable data:timeOffDataDict intoDatabase:@""];
                
            }
        }
        
         */
        
    }
}

-(void)saveShiftEntryDataFromApiToDB:(NSMutableDictionary *)response
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *idString = [[NSUserDefaults standardUserDefaults] valueForKey:@"id"];
    NSString  *typeString= @"";
    [self deleteAllShiftsEntriesFromDB];
    [self deleteAllShiftsDetailsFromDB];
    [self deleteAllShiftsObjectExtensionFieldsFromDB];
   [self saveShiftDetailsDataFromApiToDB:response];
   
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    NSMutableArray  *dataArray = [NSMutableArray array];
    dataArray = [response objectForKey:@"dataPoints"];
    for (int i= 0; i<[dataArray count]; i++) {
        NSMutableDictionary  *dayDataDict = [NSMutableDictionary dictionary];
        dayDataDict = [[dataArray objectAtIndex:i] objectForKey:@"date"];
        
        NSDate *dueDate=[Util convertApiDateDictToDateFormat:dayDataDict];
        
        [dataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"date"];
        

       
        NSMutableArray  *shiftArray = [NSMutableArray array];
        NSString  *shiftName= @"";
        NSString  *shiftUri= @"";
        NSString  *colorCode= @"";
        NSString  *noteString= @"";
       
        
        //Implentation for Sched-114//JUHI
        if ([[dataArray objectAtIndex:i] objectForKey:@"assignments"]!=nil &&![[[dataArray objectAtIndex:i] objectForKey:@"assignments"] isKindOfClass:[NSNull class]]) {
            shiftArray = [[dataArray objectAtIndex:i] objectForKey:@"assignments"];
            
            if ([shiftArray count]>0)
            {
                for (int k = 0; k<[shiftArray  count]; k++) {
                    NSString  *shiftDurationString= @"";
                    NSString  *startTimeStamp = @"";
                    NSString  *endTimeStamp= @"";
                    NSMutableDictionary *shiftDurationDict =[NSMutableDictionary dictionary];
                    shiftDurationDict = [shiftArray objectAtIndex:k];
                    if (shiftDurationDict!=nil &&![shiftDurationDict isKindOfClass:[NSNull class]]) {
                        if ([shiftDurationDict objectForKey:@"note"]!=nil ||![[shiftDurationDict objectForKey:@"note"] isKindOfClass:[NSNull class]]) {
                            noteString = [shiftDurationDict objectForKey:@"note"];
                            
                        }
                        
                        shiftName = [[shiftDurationDict objectForKey:@"shift"] objectForKey:@"displayText"];
                        shiftUri = [[shiftDurationDict objectForKey:@"shift"] objectForKey:@"uri"];
                        NSMutableDictionary *colorCodeDict =[NSMutableDictionary dictionary];
                        if ([shiftDurationDict objectForKey:@"color"]!=nil &&![[shiftDurationDict objectForKey:@"color"] isKindOfClass:[NSNull class]]) {
                            colorCodeDict = [shiftDurationDict objectForKey:@"color"];
                            NSInteger blue = [[colorCodeDict objectForKey:@"blue"] longValue];
                            NSInteger green = [[colorCodeDict objectForKey:@"green"] longValue];
                            NSInteger red = [[colorCodeDict  objectForKey:@"red"]longValue ];
                            
                            colorCode = [self hexStringFromColor:[UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:1]];
                        }
                        
                       
                        //Implentation for Sched-114//JUHI
                        NSMutableDictionary *inTimeDict =[NSMutableDictionary dictionary];
                        NSMutableDictionary *outTimeDict =[NSMutableDictionary dictionary];
                        if ([shiftDurationDict objectForKey:@"inTime"]!=nil && ![[shiftDurationDict objectForKey:@"inTime"] isKindOfClass:[NSNull class]]) {
                            [inTimeDict setObject:[[shiftDurationDict objectForKey:@"inTime"] objectForKey:@"hour"] forKey:@"hour"];
                            [inTimeDict setObject:[[shiftDurationDict objectForKey:@"inTime"] objectForKey:@"minute"] forKey:@"minute"];
                        }
                        if ([shiftDurationDict objectForKey:@"outTime"]!=nil && ![[shiftDurationDict objectForKey:@"outTime"] isKindOfClass:[NSNull class]]) {
                            int hours=[[[shiftDurationDict objectForKey:@"outTime"] objectForKey:@"hour"] intValue];
                            int dayoffset=[[[shiftDurationDict objectForKey:@"outTime"] objectForKey:@"dayOffset"] intValue];
                            
                            if (dayoffset>0)
                            {
                                hours=hours+(24*dayoffset);
                            }
                            [outTimeDict setObject:[NSNumber numberWithInt:hours] forKey:@"hour"];
                            [outTimeDict setObject:[[shiftDurationDict objectForKey:@"outTime"] objectForKey:@"minute"] forKey:@"minute"];
                        }
                        
                        typeString = SHIFT_ENTRY;
                        
                        
                        
                        startTimeStamp=[Util convertApiTimeDictTo12HourTimeString:inTimeDict];
                        endTimeStamp=[Util convertApiTimeDictTo12HourTimeString:outTimeDict];
                        NSString *startTime=nil;
                        NSString *endTime=nil;
                        if ([startTimeStamp isEqualToString:@"0:00 AM"])
                        {
                            startTime=@"12:00 AM";
                            
                        }
                        else
                            startTime=startTimeStamp;
                        if ([endTimeStamp isEqualToString:@"0:00 AM"]) {
                            endTime=@"12:00 AM";
                        }
                        else
                            endTime=endTimeStamp;
                        shiftDurationString = [NSString stringWithFormat:@" %@ - %@ ",startTime ,endTime ];
                        
                        NSDateComponents *startDatecomps = [[NSCalendar currentCalendar]
                                                            components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth
                                                            fromDate:[NSDate date]];
                        [startDatecomps setDay:[[dayDataDict objectForKey:@"day"] longValue]];
                        [startDatecomps setMonth:[[dayDataDict objectForKey:@"month"] longValue]];
                        [startDatecomps setYear:[[dayDataDict objectForKey:@"year"] longValue]];
                        [startDatecomps setHour:[[inTimeDict objectForKey:@"hour"] longValue]];
                        [startDatecomps setMinute:[[inTimeDict objectForKey:@"minute"] longValue]];
                        
                        NSDateComponents *endDatecomps = [[NSCalendar currentCalendar]
                                                          components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth
                                                          fromDate:[NSDate date]];
                        [endDatecomps setDay:[[dayDataDict objectForKey:@"day"] longValue]];
                        [endDatecomps setMonth:[[dayDataDict objectForKey:@"month"] longValue]];
                        [endDatecomps setYear:[[dayDataDict objectForKey:@"year"] longValue]];
                        [endDatecomps setHour:[[outTimeDict objectForKey:@"hour"] longValue]];
                        [endDatecomps setMinute:[[outTimeDict objectForKey:@"minute"] longValue]];
                        
                        [dataDict setObject:[NSNumber numberWithDouble:[[[NSCalendar currentCalendar] dateFromComponents:startDatecomps] timeIntervalSince1970]] forKey:@"in_time_stamp"];
                        [dataDict setObject:[NSNumber numberWithDouble:[[[NSCalendar currentCalendar] dateFromComponents:endDatecomps] timeIntervalSince1970]] forKey:@"out_time_stamp"];
                        /* REMOVE THIS AS PART OF SCHED-114//JUHI
                         //                if ([shiftDurationDict objectForKey:@"shiftSegments"] != nil && ![[shiftDurationDict objectForKey:@"shiftSegments"] isKindOfClass:[NSNull class]])
                         //                {
                         //                     NSMutableArray *shiftDurationArray = [shiftDurationDict objectForKey:@"shiftSegments"];
                         //
                         //                    REMOVE THIS AS PART OF MOBI-492/ SCHED-114
                         //                    if ([shiftDurationArray count]>1) {
                         //
                         //                        NSMutableDictionary *startEntryDict = [shiftDurationArray objectAtIndex:0];
                         //                        NSMutableDictionary *endEntryDict = [shiftDurationArray objectAtIndex:[shiftDurationArray count]-1];
                         //                        if ([startEntryDict objectForKey:@"breakEntry"] != [NSNull null]) {
                         //                            inTimeDict =[[startEntryDict objectForKey:@"breakEntry"] objectForKey:@"inTimeOffset"];
                         //
                         //                        }
                         //                        else if ([startEntryDict objectForKey:@"workEntry"] != [NSNull null]) {
                         //                            inTimeDict =[[startEntryDict objectForKey:@"workEntry"] objectForKey:@"inTimeOffset"];
                         //
                         //                        }
                         //                        if ([endEntryDict objectForKey:@"workEntry"] != [NSNull null]) {
                         //                            outTimeDict =[[endEntryDict objectForKey:@"workEntry"] objectForKey:@"outTimeOffset"];
                         //                        }
                         //                        else if ([endEntryDict objectForKey:@"breakEntry"] != [NSNull null]){
                         //                            outTimeDict =[[endEntryDict objectForKey:@"breakEntry"] objectForKey:@"outTimeOffset"];
                         //                        }
                         //
                         //                    }
                         //                    else if ([shiftDurationArray count] == 1){
                         //                        NSMutableDictionary *entryDict = [shiftDurationArray objectAtIndex:0];
                         //                        if ([entryDict objectForKey:@"breakEntry"] != [NSNull null]) {
                         //                            inTimeDict =[[entryDict objectForKey:@"breakEntry"] objectForKey:@"inTimeOffset"];
                         //                            outTimeDict =[[entryDict objectForKey:@"breakEntry"] objectForKey:@"outTimeOffset"];
                         //                        }
                         //                        else  {
                         //                            inTimeDict =[[entryDict objectForKey:@"workEntry"] objectForKey:@"inTimeOffset"];
                         //                            outTimeDict =[[entryDict objectForKey:@"workEntry"] objectForKey:@"outTimeOffset"];
                         //                        }
                         //                    }
                         //                    */
                        //
                        //                    ///ADD THIS AS PART OF MOBI-492/ SCHED-114
                        //
                        //                    for (NSDictionary *entryDict in shiftDurationArray)
                        //                    {
                        //                        if ([entryDict objectForKey:@"workEntry"] != [NSNull null]) {
                        //                            inTimeDict =[[entryDict objectForKey:@"workEntry"] objectForKey:@"inTimeOffset"];
                        //                            outTimeDict =[[entryDict objectForKey:@"workEntry"] objectForKey:@"outTimeOffset"];
                        //                        }
                        //                    }
                        //                    //-------------------
                        //
                        //
                        //
                        //
                        //
                        //                }
                        
                        [dataDict setValue:shiftDurationString forKey:@"shiftDuration"];
                        [dataDict setObject:startTimeStamp forKey:@"startTime"];
                        [dataDict setObject:endTimeStamp forKey:@"endTime"];
                        
                        [dataDict setValue:typeString forKey:@"type"];
                        //[dataDict setValue:dateString forKey:@"date"];
                        
                        [dataDict setValue:shiftUri   forKey:@"uri"];
                        [dataDict setValue:shiftName  forKey:@"shiftName"];
                        
                        //[dataDict setValue:holidatString forKey:@"holiday"];
                        [dataDict setValue:noteString forKey:@"note"];
                        [dataDict setValue:idString forKey:@"id"];
                        [dataDict setValue:colorCode forKey:@"color"];
                        
//                        NSArray *array=[ self getShiftinfoForEntryDate:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] andEntryUri:shiftUri];
//                        if ([array count]>0)
//                        {
//                            NSString *whereString=[NSString stringWithFormat:@"date = '%@' and uri='%@'",[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]],shiftUri];
//                            [myDB updateTable: shiftEntryTable data:dataDict where:whereString intoDatabase:@""];
//                            
//                        }
//                        else
                            [myDB insertIntoTable:shiftEntryTable data:dataDict intoDatabase:@""];
                    }
                    
                    
                }
            }
        }
        
        
        


    }
    
}


#pragma mark - get data methods

-(NSMutableArray *)getShiftByDateFromDB
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query = [NSString stringWithFormat:@" select * from %@",shiftsTable];
	NSMutableArray *shiftDetails = [myDB executeQueryToConvertUnicodeValues:query];
	NSMutableArray *array=[NSMutableArray array];
    for (int i=0; i<[shiftDetails count]; i++)
    {
        [array addObject:[shiftDetails objectAtIndex:i]];
    }
	return array;
}


-(NSMutableArray *)getShiftByIDFromDB:(NSString *)shiftID
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query = [NSString stringWithFormat:@" select * from %@ where id='%@'",shiftsTable,shiftID];
	NSMutableArray *shiftDetails = [myDB executeQueryToConvertUnicodeValues:query];
	NSMutableArray *array=[NSMutableArray array];
    for (int i=0; i<[shiftDetails count]; i++)
    {
        [array addObject:[shiftDetails objectAtIndex:i]];
    }
	return array;
}

-(NSMutableArray *)getShiftDetailsFromDBForID:(NSString *)id
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where id='%@'",shiftDetailsTable,id];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}

-(NSMutableArray *)getAllShiftEntryGroupedByDateForId:(NSString *)shiftid
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *groupedShiftEntrysArr=[NSMutableArray array];
    NSString *whereString = [NSString stringWithFormat:@"id = '%@' order by date asc",shiftid];
    
    NSMutableArray *datesArray = [myDB select:@"distinct(date) " from:shiftEntryTable where:whereString  intoDatabase:@""];
    if (datesArray != nil && [datesArray count]>0)
    {
        
        for (int i=0; i<[datesArray count]; i++)
        {
            NSMutableArray *groupedtsArray = [myDB select:@" * " from:shiftEntryTable where:[NSString stringWithFormat: @"date = '%@' order by in_time_stamp asc",[[datesArray objectAtIndex:i] objectForKey:@"date" ]] intoDatabase:@""];
            
            
            NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
            
            NSDate *nowDateFromLong = [Util convertTimestampFromDBToDate:[[[datesArray objectAtIndex:i] objectForKey:@"date" ] stringValue]];
            
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            
            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            myDateFormatter.dateFormat = @"EEEE, MMM dd, yyyy";
            [dataDict setObject:groupedtsArray forKey:[myDateFormatter stringFromDate:nowDateFromLong]] ;
            [groupedShiftEntrysArr addObject:dataDict];
        }
    }
    
    if (groupedShiftEntrysArr != nil && [groupedShiftEntrysArr count]>0)
    {
        return groupedShiftEntrysArr;
    }
    return nil;
}

-(NSMutableArray *)getAllShiftEntryForId:(NSString *)shiftid
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"id = '%@' order by date asc",shiftid];
    NSMutableArray *resultArray = [myDB select:@" * " from:shiftEntryTable where:whereString intoDatabase:@""];
    if ([resultArray count]>0)
    {
        return resultArray;
    }
    return nil;
}

-(NSArray *)getShiftinfoForEntryDate:(NSNumber *)entryDate andEntryUri:(NSString *)uri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where date = '%@' and uri='%@'",shiftEntryTable,entryDate,uri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getShiftinfoForEntryDate:(NSInteger)entryDate {
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where date = '%ld' ",shiftEntryTable,(long)entryDate];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getShiftinfoForEntryDate:(NSNumber *)entryDate andEntryUri:(NSString *)uri entryType:(NSString*)type
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=@"";
    if ([type isEqualToString:HOLIDAY_ENTRY])
    {
        query=[NSString stringWithFormat:@" select * from %@ where date = '%@' and holidayUri='%@'",shiftDetailsTable,entryDate,uri];
    }
    else if ([type isEqualToString:TIME_OFF_ENTRY])
        query=[NSString stringWithFormat:@" select * from %@ where date = '%@' and timeOffUri='%@'",shiftDetailsTable,entryDate,uri];
    else
        query=[NSString stringWithFormat:@" select * from %@ where date = '%@' and shiftUri='%@'",shiftDetailsTable,entryDate,uri];
    
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSMutableArray *)getShiftEntryFromDBForID:(NSString *)id
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where id='%@'",shiftEntryTable,id];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *)getShiftDetailsFromDBForDate:(NSInteger)date
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray  *finalDetailArray = [NSMutableArray array];
    NSMutableArray  *uriArray = [NSMutableArray array];

	NSString *query = [NSString stringWithFormat:@" select * from %@ where date='%ld'  order by in_time_stamp asc",shiftDetailsTable,(long)date];
	NSMutableArray *shiftDetails = [myDB executeQueryToConvertUnicodeValues:query];
    
    for (int i = 0; i<[shiftDetails count]; i++) {
        NSMutableDictionary  *dataDict = [NSMutableDictionary dictionary];
        dataDict = [shiftDetails objectAtIndex:i];
        NSString * shiftUri = [dataDict objectForKey:@"shiftUri"];
        if (shiftUri != (id)[NSNull null]) {
            
            NSString *type=[dataDict objectForKey:@"type"];
            if (![uriArray containsObject:dataDict] && ![type isEqualToString:BREAK_ENTRY])
            {
                [uriArray addObject:dataDict];
            }
            
        }
        else{
            [finalDetailArray addObject:dataDict];
        }
    }
    
    for (int uriIndex = 0; uriIndex< [uriArray count]; uriIndex++) {
        NSString  *uriString = [[uriArray objectAtIndex:uriIndex] objectForKey:@"shiftUri"];
        NSString *index=[[uriArray objectAtIndex:uriIndex] objectForKey:@"shiftIndex"];
        
        NSString *uriQuery = [NSString stringWithFormat:@" select * from %@ where date='%ld' and shiftUri='%@' and shiftIndex='%@'",shiftDetailsTable,(long)date, uriString,index];
        NSMutableArray *Details = [myDB executeQueryToConvertUnicodeValues:uriQuery];
        [finalDetailArray addObject:Details];
    }
    
	
    if ([finalDetailArray count]>0)
    {
        return finalDetailArray;
    }
    else{
        [finalDetailArray addObject:NO_SHIFT];
    }
    
	return finalDetailArray;
}


-(NSMutableDictionary *)getTimeoffInfoSheetIdentity:(NSString *)timeOffUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
	NSString *query = [NSString stringWithFormat:@" select * from %@ where uri='%@'",shiftEntryTable,timeOffUri];
	NSMutableArray *shiftDetails = [myDB executeQueryToConvertUnicodeValues:query];
    
    if ([shiftDetails count]>0)
    {
        return [shiftDetails objectAtIndex:0];
    }
    
    
    return nil;

}

#pragma mark - delete data methods

-(void)deleteAllShiftsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:shiftsTable inDatabase:@""];
}

-(void)deleteAllShiftsEntriesFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:shiftEntryTable inDatabase:@""];
}

-(void)deleteAllShiftsDetailsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:shiftDetailsTable inDatabase:@""];
}

-(void)deleteAllShiftsObjectExtensionFieldsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:shiftObjectExtensionFieldsTable inDatabase:@""];
}

-(void)deleteAllShiftEntryDetailsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:shiftEntryTable inDatabase:@""];
}

- (NSString *)hexStringFromColor:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}


-(void)saveTimeoffs:(NSDictionary *)responseDict forShiftId:(NSString *)shiftID
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *headerArray=[responseDict objectForKey:@"header"];
    NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
    
    
    
    for (int i=0; i<[rowsArray count]; i++)
    {
        NSString *timeoffURI=@"";
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSArray *array=[[rowsArray objectAtIndex:i] objectForKey:@"cells"];
        BOOL hasTimeOff = TRUE;
        NSDate *startDate=nil;
        NSDate *endDate=nil;
        NSNumber *startTotalHours=[NSNumber numberWithInt:0];
        NSString *startTotalTimeoffDaysStr=@"0";
        NSNumber *endTotalHours=[NSNumber numberWithInt:0];
        NSString *endTotalTimeoffDaysStr=@"0";
        
        for (int k=0; k<[array count]; k++)
        {
            
            NSString *refrenceHeaderUri=[[headerArray objectAtIndex:k] objectForKey:@"uri"];
            NSMutableArray *columnUriArray=nil;
            columnUriArray=[[AppProperties getInstance] getTimeOffColumnURIFromPlist];
            NSString *refrenceHeader=nil;
            for (int i=0; i<[columnUriArray count]; i++)
            {
                NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
                NSString *uri=[columnDict objectForKey:@"uri"];
                
                if ([refrenceHeaderUri isEqualToString:uri])
                {
                    refrenceHeader=[columnDict objectForKey:@"name"];
                    break;
                }
            }
            NSMutableDictionary *responseDict=[array objectAtIndex:k];
            
            if ([refrenceHeader isEqualToString:@"Time Off Approval Status"])
            {
                NSString *statusStr=[responseDict objectForKey:@"uri"];
                
                if ([statusStr isEqualToString:APPROVED_STATUS_URI])
                {
                    [dataDict setObject:APPROVED_STATUS forKey:@"timeOffApprovalStatus"];
                }
                else if ([statusStr isEqualToString:NOT_SUBMITTED_STATUS_URI])
                {
                    [dataDict setObject:NOT_SUBMITTED_STATUS forKey:@"timeOffApprovalStatus"];
                }
                else if ([statusStr isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
                {
                    [dataDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"timeOffApprovalStatus"];
                }
                else if ([statusStr isEqualToString:REJECTED_STATUS_URI])
                {
                    [dataDict setObject:REJECTED_STATUS forKey:@"timeOffApprovalStatus"];
                }
                else
                {
                    [dataDict setObject:[NSNull null] forKey:@"timeOffApprovalStatus"];
                }
            }
            else if ([refrenceHeader isEqualToString:@"End Date"])
            {
                NSDictionary *endDateDict=[responseDict objectForKey:@"dateValue"];
                endDate=[Util convertApiDateDictToDateFormat:endDateDict];
                //[dataDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]] forKey:@"endTime"];
                
                
            }
            else if ([refrenceHeader isEqualToString:@"Start Date"])
            {
                NSDictionary *startDateDict=[responseDict objectForKey:@"dateValue"];
                startDate=[Util convertApiDateDictToDateFormat:startDateDict];
                //[dataDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"startTime"];
            }
            else if ([refrenceHeader isEqualToString:@"Start Day Duration"])
            {
                if ([responseDict objectForKey:@"calendarDayDurationValue"] != nil && [responseDict objectForKey:@"calendarDayDurationValue"]  != [NSNull class]) {
                    NSDictionary *totalHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                    startTotalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                }
                else
                {
                    hasTimeOff = false;
                    //break;
                }
                // NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                //[dataDict setObject:totalHours      forKey:@"timeOffHourDuration"];
                //[dataDict setObject:totalHoursStr  forKey:@"timeOffHourDuration"];
                if ([responseDict objectForKey:@"workdayDurationValue"] != nil && [responseDict objectForKey:@"workdayDurationValue"] != [NSNull class]) {
                    NSDictionary *totalWorkdaysDict=[responseDict objectForKey:@"workdayDurationValue"];
                    startTotalTimeoffDaysStr=[totalWorkdaysDict objectForKey:@"decimalWorkdays"];
                }
                else
                {
                    hasTimeOff = false;
                    //break;
                }
                
            }
            else if ([refrenceHeader isEqualToString:@"End Day Duration"])
            {
                if ([responseDict objectForKey:@"calendarDayDurationValue"] != nil && [responseDict objectForKey:@"calendarDayDurationValue"]  != [NSNull class]) {
                    NSDictionary *totalHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                    endTotalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                }
                else
                {
                    hasTimeOff = false;
                    //break;
                }
                // NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                //[dataDict setObject:totalHours      forKey:@"timeOffHourDuration"];
                //[dataDict setObject:totalHoursStr  forKey:@"timeOffHourDuration"];
                if ([responseDict objectForKey:@"workdayDurationValue"] != nil && [responseDict objectForKey:@"workdayDurationValue"] != [NSNull class]) {
                    NSDictionary *totalWorkdaysDict=[responseDict objectForKey:@"workdayDurationValue"];
                    endTotalTimeoffDaysStr=[totalWorkdaysDict objectForKey:@"decimalWorkdays"];
                }
                else
                {
                    hasTimeOff = false;
                    //break;
                }
                //[dataDict setObject:totalTimeoffDaysStr  forKey:@"timeOffDayDuration"];
                
            }
            
            else if ([refrenceHeader isEqualToString:@"Time Off"])
            {
                timeoffURI=[responseDict objectForKey:@"uri"];
                [dataDict setObject:timeoffURI forKey:@"uri"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Time Off Type"])
            {
               
                NSString *timeoffTypeName=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:timeoffTypeName forKey:@"timeOffName"];
              
                
                TimeoffModel *timeoffModel = [[TimeoffModel alloc] init];
                NSString *timeOffDisplayFormatUri = @"";
                NSArray *timeOffDisplayFormatUriArray = [timeoffModel getTimeoffTypeInfoSheetIdentity:responseDict[@"uri"]];
                if (timeOffDisplayFormatUriArray!= nil && ![timeOffDisplayFormatUriArray isKindOfClass:[NSNull class]] )
                {
                    timeOffDisplayFormatUri = timeOffDisplayFormatUriArray[0][@"timeOffDisplayFormatUri"];
                    if (timeOffDisplayFormatUri!= nil && ![timeOffDisplayFormatUri isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:timeOffDisplayFormatUri   forKey:@"timeOffDisplayFormatUri"];
                    }
                }

            }
            else if ([refrenceHeader isEqualToString:@"Total Duration"])
            {
                if (hasTimeOff == false) {
                    if ([responseDict objectForKey:@"calendarDayDurationValue"] != nil && [responseDict objectForKey:@"calendarDayDurationValue"]  != [NSNull class]) {
                        NSDictionary *totalHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                        endTotalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                        startTotalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                    }
                    if ([responseDict objectForKey:@"workdayDurationValue"] != nil && [responseDict objectForKey:@"workdayDurationValue"] != [NSNull class]) {
                        NSDictionary *totalWorkdaysDict=[responseDict objectForKey:@"workdayDurationValue"];
                        startTotalTimeoffDaysStr=[totalWorkdaysDict objectForKey:@"decimalWorkdays"];
                        endTotalTimeoffDaysStr=[totalWorkdaysDict objectForKey:@"decimalWorkdays"];
                    }
                }
            }
            
            [dataDict setObject:shiftID forKey:@"id"];
            [dataDict setObject:@"TimeOff" forKey:@"type"];
            
            
        }
        
        
        if (startDate!=nil && ![startDate isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"date"];
            [dataDict setObject:startTotalHours forKey:@"timeOffHourDuration"];
            [dataDict setObject:startTotalTimeoffDaysStr  forKey:@"timeOffDayDuration"];
            [myDB insertIntoTable:shiftEntryTable data:dataDict intoDatabase:@""];
            
            NSDictionary *detailsDataDict=[NSDictionary dictionaryWithObjectsAndKeys:[dataDict objectForKey:@"id"],@"id",[dataDict objectForKey:@"timeOffName"],@"TimeOffName",[dataDict objectForKey:@"type"],@"type",[dataDict objectForKey:@"timeOffDayDuration"],@"timeOffDayDuration",[dataDict objectForKey:@"timeOffApprovalStatus"],@"approvalStatus",[dataDict objectForKey:@"uri"],@"timeOffUri",[dataDict objectForKey:@"date"],@"date",[dataDict objectForKey:@"timeOffHourDuration"],@"timeOffHourDuration",[dataDict objectForKey:@"timeOffDisplayFormatUri"],@"timeOffDisplayFormatUri", nil];
            
             [myDB insertIntoTable:shiftDetailsTable data:detailsDataDict intoDatabase:@""];
        }
        
        if (endDate!=nil && ![endDate isKindOfClass:[NSNull class]])
        {
            if ([startDate compare:endDate] != NSOrderedSame)
            {
                [dataDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]] forKey:@"date"];
                [dataDict setObject:endTotalHours forKey:@"timeOffHourDuration"];
                [dataDict setObject:endTotalTimeoffDaysStr  forKey:@"timeOffDayDuration"];
                [myDB insertIntoTable:shiftEntryTable data:dataDict intoDatabase:@""];
                
                NSDictionary *detailsDataDict=[NSDictionary dictionaryWithObjectsAndKeys:[dataDict objectForKey:@"id"],@"id",[dataDict objectForKey:@"timeOffName"],@"TimeOffName",[dataDict objectForKey:@"type"],@"type",[dataDict objectForKey:@"timeOffDayDuration"],@"timeOffDayDuration",[dataDict objectForKey:@"timeOffApprovalStatus"],@"approvalStatus",[dataDict objectForKey:@"uri"],@"timeOffUri",[dataDict objectForKey:@"date"],@"date",[dataDict objectForKey:@"timeOffHourDuration"],@"timeOffHourDuration",[dataDict objectForKey:@"timeOffDisplayFormatUri"],@"timeOffDisplayFormatUri",nil];
                
                [myDB insertIntoTable:shiftDetailsTable data:detailsDataDict intoDatabase:@""];
            }
            
            
        }
        
		
        if (startDate!=nil && ![startDate isKindOfClass:[NSNull class]] && endDate!=nil && ![endDate isKindOfClass:[NSNull class]])
        {
            if ([startDate compare:endDate] != NSOrderedSame)
            {
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                                    fromDate:startDate
                                                                      toDate:endDate
                                                                     options:0];
                
                for (int i = 1; i < components.day; ++i) {
                    NSDateComponents *newComponents = [NSDateComponents new];
                    newComponents.day = i;
                    
                    NSDate *date = [gregorianCalendar dateByAddingComponents:newComponents
                                                                      toDate:startDate
                                                                     options:0];
                    [dataDict setObject:[NSNumber numberWithDouble:[date timeIntervalSince1970]] forKey:@"date"];
                    [dataDict setObject:@"All Day"  forKey:@"timeOffDayDuration"];
                    [dataDict setObject:@"All Day"  forKey:@"timeOffHourDuration"];
                    [myDB insertIntoTable:shiftEntryTable data:dataDict intoDatabase:@""];
                    
                    
                    NSDictionary *detailsDataDict=[NSDictionary dictionaryWithObjectsAndKeys:[dataDict objectForKey:@"id"],@"id",[dataDict objectForKey:@"timeOffName"],@"TimeOffName",[dataDict objectForKey:@"type"],@"type",[dataDict objectForKey:@"timeOffDayDuration"],@"timeOffDayDuration",[dataDict objectForKey:@"timeOffApprovalStatus"],@"approvalStatus",[dataDict objectForKey:@"uri"],@"timeOffUri",[dataDict objectForKey:@"date"],@"date",[dataDict objectForKey:@"timeOffDisplayFormatUri"],@"timeOffDisplayFormatUri",nil];
                    [dataDict removeObjectForKey:@"timeOffHourDuration"];
                    [dataDict setObject:@"All Day"  forKey:@"timeOffDayDuration"];
                    [dataDict setObject:@"All Day"  forKey:@"timeOffHourDuration"];
                    [myDB insertIntoTable:shiftDetailsTable data:detailsDataDict intoDatabase:@""];
                }

            }
        }
			
		
        
        
    }
}


-(void)saveTimeoffCompanyHolidaysDataFromApiToDB:(NSMutableArray *)companyHolidaysArr forShiftId:(NSString *)shiftID
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    
    for (int i=0; i<[companyHolidaysArr count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSMutableDictionary *detailDict=[companyHolidaysArr objectAtIndex:i];
        
        NSString *holidayName=[detailDict objectForKey:@"name"];
        NSString *holidayUri=[detailDict objectForKey:@"uri"];
        
        if (holidayName!=nil)
        {
            [dataDict setObject:holidayName forKey:@"holiday"];
        }
        if (holidayUri!=nil)
        {
            [dataDict setObject:holidayUri forKey:@"uri"];
        }
        
        [dataDict setObject:shiftID forKey:@"id"];
        [dataDict setObject:HOLIDAY_ENTRY forKey:@"type"];
        
        NSDictionary *holidayDateDict=[detailDict objectForKey:@"date"];
        NSDate *holidayDate=[Util convertApiDateDictToDateFormat:holidayDateDict];
        [dataDict setObject:[NSNumber numberWithDouble:[holidayDate timeIntervalSince1970]] forKey:@"date"];
        
        [myDB insertIntoTable:shiftEntryTable data:dataDict intoDatabase:@""];
        
        NSDictionary *detailsDataDict=[NSDictionary dictionaryWithObjectsAndKeys:[dataDict objectForKey:@"id"],@"id",[dataDict objectForKey:@"holiday"],@"holiday",[dataDict objectForKey:@"type"],@"type",[dataDict objectForKey:@"uri"],@"holidayUri",[dataDict objectForKey:@"date"],@"date",nil];
        
        [myDB insertIntoTable:shiftDetailsTable data:detailsDataDict intoDatabase:@""];
        
        
        
        
    }

}

//Implemtation for Sched-114//JUHI
-(void)saveShiftObjectExtensionFieldsDataFromApiToDB:(NSMutableArray *)udfArray forShiftUri:(NSString*)shiftUri andTimeStamp:(NSNumber*)timestamp andIndex:(NSNumber *)index
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
//    NSString *whereStr=[NSString stringWithFormat:@"shiftUri = '%@' and in_time_stamp='%d'",shiftUri,[timestamp integerValue]];
//    [myDB deleteFromTable:shiftObjectExtensionFieldsTable where:whereStr inDatabase:@""];
    for (int i=0; i<[udfArray count]; i++)
    {
        NSMutableDictionary *udfDataDict=[NSMutableDictionary dictionary];
        [udfDataDict setObject:shiftUri forKey:@"shiftUri"];
        [udfDataDict setObject:timestamp forKey:@"in_time_stamp"];
        NSString *udfName=@"";
        NSString *udfNameUri=@"";
        NSString *udfValue=@"";
        NSString *udfValueUri=@"";
        NSDictionary *dict=[udfArray objectAtIndex:i];
        if ([dict objectForKey:@"tag"] !=nil && ![[dict objectForKey:@"tag"]isKindOfClass:[NSNull class]]) {
            if ([[dict objectForKey:@"tag"] objectForKey:@"definition"]!=nil && ![[[dict objectForKey:@"tag"] objectForKey:@"definition"]isKindOfClass:[NSNull class]])
            {
                udfName=[[[dict objectForKey:@"tag"] objectForKey:@"definition"]objectForKey:@"displayText"];
                udfNameUri=[[[dict objectForKey:@"tag"] objectForKey:@"definition"]objectForKey:@"uri"];
            }
            if ([[dict objectForKey:@"tag"] objectForKey:@"displayText"] !=nil && ![[[dict objectForKey:@"tag"] objectForKey:@"displayText"]isKindOfClass:[NSNull class]]) {
                 udfValue=[[dict objectForKey:@"tag"] objectForKey:@"displayText"];
            }
            if ([[dict objectForKey:@"tag"] objectForKey:@"uri"] !=nil && ![[[dict objectForKey:@"tag"] objectForKey:@"uri"]isKindOfClass:[NSNull class]]) {
                udfValueUri=[[dict objectForKey:@"tag"] objectForKey:@"uri"];
            }
           
           
        }
        [udfDataDict setObject:udfName forKey:@"udf_name"];
        [udfDataDict setObject:udfNameUri forKey:@"udf_uri"];
        [udfDataDict setObject:udfValue forKey:@"udfValue"];
        [udfDataDict setObject:udfValueUri forKey:@"udfValue_uri"];
        [udfDataDict setObject:index forKey:@"shiftIndex"];
        
//        NSArray *array=[self getShiftObjectExtensionFieldsForShiftUri:shiftUri andUdfURI:udfNameUri andTimestamp:[timestamp integerValue]];
//        if ([array count]>0)
//        {
//            NSString *whereStr=[NSString stringWithFormat:@"shiftUri = '%@' and udf_uri='%@' and in_time_stamp='%d'",shiftUri,udfNameUri,[timestamp integerValue]];
//            
//            [myDB updateTable:shiftObjectExtensionFieldsTable data:udfDataDict where:whereStr intoDatabase:@""];
//        }
//        else
         [myDB insertIntoTable:shiftObjectExtensionFieldsTable data:udfDataDict intoDatabase:@""];
    }
}
-(NSArray *)getShiftObjectExtensionFieldsForShiftUri:(NSString *)shiftUri andUdfURI:(NSString *)udfUri andTimestamp:(NSInteger)date
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where shiftUri = '%@' and udf_uri='%@' and in_time_stamp='%ld'",shiftObjectExtensionFieldsTable,shiftUri,udfUri,(long)date];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getAllShiftObjectExtensionFieldsForShiftUri:(NSString *)shiftUri forTimeStamp:(NSInteger)timestamp forIndex:(NSString*)shiftIndex
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where shiftUri = '%@' and in_time_stamp='%ld' and shiftIndex='%@'",shiftObjectExtensionFieldsTable,shiftUri,(long)timestamp,shiftIndex];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
@end
