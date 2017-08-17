//
//  TimeoffModel.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 15/04/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "TimeoffModel.h"
#import "LoginModel.h"

static NSString *timeoffTable=@"Timeoff";
static NSString *timeoffTypeBalanceSummaryTable=@"TimeoffTypeBalanceSummary";
static NSString *companyHolidaysTable=@"CompanyHolidays";
static NSString *bookedTimeoffTypesTable=@"BookedTimeoffTypes";
static NSString *defaultTimeoffTypesTable=@"default_timeoff_type_table";

static NSString *timeOffCustomFieldsTable=@"TimeoffCustomFields";
static NSString *timeOffApprovalHistoryTable=@"TimeOffApprovalHistory";
static NSString *userDeFinedFieldsTable=@"userDefinedFields";
static NSString *udfTimeoffPreferencesTable=@"udfTimeoffPreferences";
static NSString *timeOffBalanceSummaryMultiDayBooking=@"TimeOffBalanceSummaryMultiDayBooking";
static NSString *userDetails = @"userDetails";
static NSString *multiDayTimeOffEntries = @"multiday_timeoff_entries";
static NSString *timeoffBookingScheduledDuration = @"multiday_timeoff_bookingOptionByScheduledDuration";

@implementation TimeoffModel

-(void)deleteAllTimeoffsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:timeoffTable inDatabase:@""];
    
}

-(void)saveTimeoffDataFromApiToDB:(NSMutableDictionary *)responseDictionary
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *headerArray=[[responseDictionary objectForKey:@"timeOff"] objectForKey:@"header"];
    NSMutableArray *rowsArray=[[responseDictionary objectForKey:@"timeOff"] objectForKey:@"rows"];
    NSNumber *shiftDurationDecimal=nil;
    NSString *shiftDurationHourStr=nil;
    [self saveDefaultTimeoffTypeDetailDataToDB:responseDictionary];
    
    if ([responseDictionary objectForKey:@"hoursPerWorkday"]!=nil && ![[responseDictionary objectForKey:@"hoursPerWorkday"] isKindOfClass:[NSNull class]] )
    {
        NSDictionary *shiftDurationDict=[responseDictionary objectForKey:@"hoursPerWorkday"];
        [[NSUserDefaults standardUserDefaults] setObject:shiftDurationDict forKey:@"hoursPerWorkday"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        shiftDurationDecimal=[Util convertApiTimeDictToDecimal:shiftDurationDict];
        shiftDurationHourStr=[Util convertApiTimeDictToString:shiftDurationDict];
    }
    if ([responseDictionary objectForKey:@"timeOffTypeDetails"]!=nil && ![[responseDictionary objectForKey:@"timeOffTypeDetails"] isKindOfClass:[NSNull class]] )
    {
        [self saveTimeoffTypeDetailDataToDB:[responseDictionary objectForKey:@"timeOffTypeDetails"]];
    }

    
    for (int i=0; i<[rowsArray count]; i++)
    {
        NSString *timeoffURI=@"";
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSArray *array=[[rowsArray objectAtIndex:i] objectForKey:@"cells"];
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
                    [dataDict setObject:APPROVED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:NOT_SUBMITTED_STATUS_URI])
                {
                    [dataDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
                {
                    [dataDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:REJECTED_STATUS_URI])
                {
                    [dataDict setObject:REJECTED_STATUS forKey:@"approvalStatus"];
                }
                else
                {
                    [dataDict setObject:[NSNull null] forKey:@"approvalStatus"];
                }
            }
            else if ([refrenceHeader isEqualToString:@"End Date"])
            {
               NSDictionary *endDateDict=[responseDict objectForKey:@"dateValue"];
               NSDate *endDate=[Util convertApiDateDictToDateFormat:endDateDict];
               [dataDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]] forKey:@"endDate"];
                
                
            }
            else if ([refrenceHeader isEqualToString:@"Start Date"])
            {
                NSDictionary *startDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *startDate=[Util convertApiDateDictToDateFormat:startDateDict];
                [dataDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"startDate"];
            }
            else if ([refrenceHeader isEqualToString:@"Total Duration"])
            {
                NSDictionary *totalHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                [dataDict setObject:totalHoursStr   forKey:@"totalDurationHour"];

            }
            else if ([refrenceHeader isEqualToString:@"Time Off"])
            {
                timeoffURI=[responseDict objectForKey:@"uri"];
                [dataDict setObject:timeoffURI forKey:@"timeoffUri"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Time Off Type"])
            {
                NSString *timeoffTypeURI=[responseDict objectForKey:@"uri"];
                NSString *timeoffTypeName=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:timeoffTypeName forKey:@"timeoffTypeName"];
                [dataDict setObject:timeoffTypeURI forKey:@"timeoffTypeUri"];
                
            }

            else if ([refrenceHeader isEqualToString:@"Total Effective Hours"])
            {

                NSString *totalHoursTextValue = [responseDict objectForKey:@"numberValue"];
                [dataDict setObject:totalHoursTextValue   forKey:@"totalDurationDecimal"];
            }

            else if ([refrenceHeader isEqualToString:@"Total Effective Workdays"])
            {

                NSString *totalWorkingDaysTextValue = [responseDict objectForKey:@"textValue"];
                [dataDict setObject:totalWorkingDaysTextValue      forKey:@"totalTimeoffDays"];
            }
            
            else if ([refrenceHeader isEqualToString:@"Time Off Type Display Format"])
            {
                if([responseDict objectForKey:@"uri"] != nil && [responseDict objectForKey:@"uri"] != (id)[NSNull null]) {
                    [dataDict setObject:[responseDict objectForKey:@"uri"] forKey:@"timeOffDisplayFormatUri"];
                }
            }
        }
        
        if (shiftDurationDecimal!=nil && ![shiftDurationDecimal isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:shiftDurationDecimal      forKey:@"shiftDurationDecimal"];
        }
        if (shiftDurationHourStr!=nil && ![shiftDurationHourStr isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:shiftDurationHourStr   forKey:@"shiftDurationHour"];
        }

        NSArray *expArr = [self getTimeoffInfoSheetIdentity:timeoffURI];
        if ([expArr count]>0)
        {
			NSString *whereString=[NSString stringWithFormat:@"timeoffUri='%@'",timeoffURI];
			[myDB updateTable: timeoffTable data:dataDict where:whereString intoDatabase:@""];
		}
        else
        {
			[myDB insertIntoTable:timeoffTable data:dataDict intoDatabase:@""];
		}
        
        
    }

}
-(void)saveNextTimeoffDataFromApiToDB:(NSMutableDictionary *)responseDictionary
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *headerArray=[responseDictionary objectForKey:@"header"];
    NSMutableArray *rowsArray=[responseDictionary objectForKey:@"rows"];
    NSNumber *shiftDurationDecimal=nil;
    NSString *shiftDurationHourStr=nil;
    
    NSDictionary *shiftDurationDict=[[NSUserDefaults standardUserDefaults]objectForKey:@"hoursPerWorkday"];
    if (shiftDurationDict!=nil && ![shiftDurationDict isKindOfClass:[NSNull class]])
    {
        shiftDurationDecimal=[Util convertApiTimeDictToDecimal:shiftDurationDict];
        shiftDurationHourStr=[Util convertApiTimeDictToString:shiftDurationDict];
    }
    
    
    for (int i=0; i<[rowsArray count]; i++)
    {
        NSString *timeoffURI=@"";
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSArray *array=[[rowsArray objectAtIndex:i] objectForKey:@"cells"];
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
                if(statusStr != nil && statusStr != (id)[NSNull null]){
                    [dataDict setObject:statusStr forKey:@"approvalStatusUri"];
                }
                if ([statusStr isEqualToString:APPROVED_STATUS_URI])
                {
                    [dataDict setObject:APPROVED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:NOT_SUBMITTED_STATUS_URI])
                {
                    [dataDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
                {
                    [dataDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:REJECTED_STATUS_URI])
                {
                    [dataDict setObject:REJECTED_STATUS forKey:@"approvalStatus"];
                }
                else
                {
                    [dataDict setObject:[NSNull null] forKey:@"approvalStatus"];
                }
            }
            else if ([refrenceHeader isEqualToString:@"End Date"])
            {
                NSDictionary *endDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *endDate=[Util convertApiDateDictToDateFormat:endDateDict];
                [dataDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]] forKey:@"endDate"];
                
                
            }
            else if ([refrenceHeader isEqualToString:@"Start Date"])
            {
                NSDictionary *startDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *startDate=[Util convertApiDateDictToDateFormat:startDateDict];
                [dataDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"startDate"];
            }
            else if ([refrenceHeader isEqualToString:@"Total Duration"])
            {
                NSDictionary *totalHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                NSNumber *totalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                [dataDict setObject:totalHours      forKey:@"totalDurationDecimal"];
                [dataDict setObject:totalHoursStr   forKey:@"totalDurationHour"];
                
                NSDictionary *totalWorkdaysDict=[responseDict objectForKey:@"workdayDurationValue"];
                NSString *totalTimeoffDaysStr=[totalWorkdaysDict objectForKey:@"decimalWorkdays"];
                [dataDict setObject:totalTimeoffDaysStr  forKey:@"totalTimeoffDays"];
                
                
            }
            else if ([refrenceHeader isEqualToString:@"Time Off"])
            {
                timeoffURI=[responseDict objectForKey:@"uri"];
                [dataDict setObject:timeoffURI forKey:@"timeoffUri"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Time Off Type"])
            {
                NSString *timeoffTypeURI=[responseDict objectForKey:@"uri"];
                NSString *timeoffTypeName=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:timeoffTypeName forKey:@"timeoffTypeName"];
                [dataDict setObject:timeoffTypeURI forKey:@"timeoffTypeUri"];
            }
            
            else if ([refrenceHeader isEqualToString:@"Total Effective Hours"])
            {
                NSString *totalHoursTextValue = [responseDict objectForKey:@"numberValue"];
                [dataDict setObject:totalHoursTextValue   forKey:@"totalDurationDecimal"];
            }
            
            else if ([refrenceHeader isEqualToString:@"Total Effective Workdays"])
            {
                NSString *totalWorkingDaysTextValue = [responseDict objectForKey:@"textValue"];
                [dataDict setObject:totalWorkingDaysTextValue      forKey:@"totalTimeoffDays"];
            }

            else if ([refrenceHeader isEqualToString:@"Time Off Type Display Format"])
            {
                if([responseDict objectForKey:@"uri"] != nil && [responseDict objectForKey:@"uri"] != (id)[NSNull null]) {
                    [dataDict setObject:[responseDict objectForKey:@"uri"] forKey:@"timeOffDisplayFormatUri"];
                }
            }
        }
        if (shiftDurationDecimal!=nil && ![shiftDurationDecimal isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:shiftDurationDecimal      forKey:@"shiftDurationDecimal"];
        }
        if (shiftDurationHourStr!=nil && ![shiftDurationHourStr isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:shiftDurationHourStr   forKey:@"shiftDurationHour"];
        }
        
        NSArray *expArr = [self getTimeoffInfoSheetIdentity:timeoffURI];
        if ([expArr count]>0)
        {
			NSString *whereString=[NSString stringWithFormat:@"timeoffUri='%@'",timeoffURI];
			[myDB updateTable: timeoffTable data:dataDict where:whereString intoDatabase:@""];
		}
        else
        {
			[myDB insertIntoTable:timeoffTable data:dataDict intoDatabase:@""];
		}
        
        
    }
    
}
-(void)saveTimeoffTypeBalanceSummaryDataFromApiToDB:(NSMutableArray *)balanceSummaryArray
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    for (int i=0; i<[balanceSummaryArray count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSMutableDictionary *detailDict=[balanceSummaryArray objectAtIndex:i];
        NSDictionary *timeOffTypeDict=[detailDict objectForKey:@"timeOffType"];
        NSDictionary *timeTakenOrRemainingDict=[detailDict objectForKey:@"timeTakenOrRemaining"];
        NSDictionary *timeTrackingOptionDict=[detailDict objectForKey:@"timeTrackingOption"];
        
        if (timeOffTypeDict!=nil)
        {
            NSString *timeOffTypeName=[timeOffTypeDict objectForKey:@"name"];
            NSString *timeOffTypeUri=[timeOffTypeDict objectForKey:@"uri"];
            if (timeOffTypeName!=nil)
            {
                [dataDict setObject:timeOffTypeName forKey:@"timeOffTypeName"];
            }
            if (timeOffTypeUri!=nil)
            {
                [dataDict setObject:timeOffTypeUri forKey:@"timeOffTypeUri"];
            }
        }
        
        if (timeTakenOrRemainingDict!=nil && ![timeTakenOrRemainingDict isKindOfClass:[NSNull class]])
        {
            NSDictionary *totalHoursDict=[timeTakenOrRemainingDict objectForKey:@"calendarDayDuration"];
            if (totalHoursDict!=nil)
            {
                NSNumber *totalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                if (totalHours!=nil)
                {
                    [dataDict setObject:totalHours      forKey:@"timeTakenOrRemainingDurationDecimal"];
                }
                if (totalHoursStr!=nil)
                {
                    [dataDict setObject:totalHoursStr   forKey:@"timeTakenOrRemainingDurationHour"];
                }

            }
            
            
            NSString *totalTimeoffDaysStr=[timeTakenOrRemainingDict objectForKey:@"decimalWorkdays"];
            if (totalTimeoffDaysStr!=nil)
            {
                [dataDict setObject:totalTimeoffDaysStr  forKey:@"timeTakenOrRemainingDurationDays"];
            }

        }
        
        if (timeTrackingOptionDict!=nil)
        {
            NSString *timeTrackingOptionUri=[timeTrackingOptionDict objectForKey:@"uri"];
            
            if (timeTrackingOptionUri!=nil)
            {
                [dataDict setObject:timeTrackingOptionUri   forKey:@"timeTrackingOptionUri"];
            }

        }
        NSString *timeOffDisplayFormatUri = @"";
        NSArray *timeOffDisplayFormatUriArray = [self getTimeoffTypeInfoSheetIdentity:dataDict[@"timeOffTypeUri"]];
        if (timeOffDisplayFormatUriArray!= nil && ![timeOffDisplayFormatUriArray isKindOfClass:[NSNull class]] ) {
           timeOffDisplayFormatUri = timeOffDisplayFormatUriArray[0][@"timeOffDisplayFormatUri"];
            if (timeOffDisplayFormatUri!= nil && ![timeOffDisplayFormatUri isKindOfClass:[NSNull class]]) {
                [dataDict setObject:timeOffDisplayFormatUri   forKey:@"timeOffDisplayFormatUri"];
            }
        }
        [myDB insertIntoTable:timeoffTypeBalanceSummaryTable data:dataDict intoDatabase:@""];
        
    }
}
-(void)saveTimeoffCompanyHolidaysDataFromApiToDB:(NSMutableArray *)holidaysArray
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Fix for multiple entry for company holiday calender
    [myDB deleteFromTable:companyHolidaysTable inDatabase:@""];
    
    for (int i=0; i<[holidaysArray count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSMutableDictionary *detailDict=[holidaysArray objectAtIndex:i];
        
        NSString *holidayName=[detailDict objectForKey:@"name"];
        NSString *holidayUri=[detailDict objectForKey:@"uri"];
        
        if (holidayName!=nil)
        {
            [dataDict setObject:holidayName forKey:@"holidayName"];
        }
        if (holidayUri!=nil)
        {
            [dataDict setObject:holidayUri forKey:@"holidayUri"];
        }
        
        NSDictionary *holidayDateDict=[detailDict objectForKey:@"date"];
        NSDate *holidayDate=[Util convertApiDateDictToDateFormat:holidayDateDict];
        [dataDict setObject:[NSNumber numberWithDouble:[holidayDate timeIntervalSince1970]] forKey:@"holidayDate"];
        
        //Fix for multiple entry for company holiday calender
		[myDB insertIntoTable:companyHolidaysTable data:dataDict intoDatabase:@""];
    }
}

-(void)saveTimeoffBalanceSummaryForMultiDayTimeOffBooking:(NSDictionary *)timeOffBalanceDictionary withTimeOffUri:(NSString *)timeOffUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableDictionary *balanceResponseDict=[NSMutableDictionary dictionary];
    
    if ([timeOffBalanceDictionary[@"isMultiDayTimeOff"] boolValue]){
        NSDictionary *timeOffBalanceInfo = timeOffBalanceDictionary[@"timeOffBalanceInfo"];
        if(timeOffBalanceInfo != nil && ![timeOffBalanceInfo isKindOfClass:[NSNull class]]){
            NSString *timeOffDisplayFormatUri = timeOffBalanceDictionary[@"timeOffDisplayFormatUri"];
            if([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI]){
                balanceResponseDict[@"balanceRemainingDays"] = timeOffBalanceInfo[@"timeRemaining"];
                balanceResponseDict[@"requestedDays"] = timeOffBalanceInfo[@"timeTaken"];
            }else if([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_HOURS_FORMAT_URI]){
                balanceResponseDict[@"balanceRemainingHours"] = timeOffBalanceInfo[@"timeRemaining"];
                balanceResponseDict[@"requestedHours"] = timeOffBalanceInfo[@"timeTaken"];
            }
            
            balanceResponseDict[@"timeOffDisplayFormatUri"] = timeOffDisplayFormatUri;
        }
    }else{
        
        NSString *balanceTotalDays=nil;
        NSString *requestedTotalDays=nil;
        NSString *balanceTotalHour=nil;
        NSString *requestedTotalHour=nil;
        if ([timeOffBalanceDictionary objectForKey:@"balanceSummaryAfterTimeOff"]!=nil && ![[timeOffBalanceDictionary objectForKey:@"balanceSummaryAfterTimeOff"]isKindOfClass:[NSNull class]])
        {
            NSString *timeOffDisplayFormatUri=timeOffBalanceDictionary[@"balanceSummaryAfterTimeOff"][@"timeOffDisplayFormatUri"];
            
            [balanceResponseDict setObject:timeOffDisplayFormatUri forKey:@"timeOffDisplayFormatUri"];
            
            if ([[timeOffBalanceDictionary objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]!=nil &&![[[timeOffBalanceDictionary objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]isKindOfClass:[NSNull class]])
            {
                balanceTotalDays=[[[timeOffBalanceDictionary objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]objectForKey:@"decimalWorkdays"];
                NSDictionary *hoursDict=[[[timeOffBalanceDictionary objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]objectForKey:@"calendarDayDuration"];
                balanceTotalHour=[Util getRoundedValueFromDecimalPlaces:[[Util convertApiTimeDictToDecimal:hoursDict] newDoubleValue]withDecimalPlaces:2];
            }
        }
        if ([timeOffBalanceDictionary objectForKey:@"totalDurationOfTimeOff"]!=nil && ![[timeOffBalanceDictionary objectForKey:@"totalDurationOfTimeOff"]isKindOfClass:[NSNull class]])
        {
            if ([timeOffBalanceDictionary objectForKey:@"totalDurationOfTimeOff"]!=nil &&![[timeOffBalanceDictionary objectForKey:@"totalDurationOfTimeOff"]isKindOfClass:[NSNull class]]) {
                requestedTotalDays=[[timeOffBalanceDictionary objectForKey:@"totalDurationOfTimeOff"] objectForKey:@"decimalWorkdays"];
                NSDictionary *hoursDict=[[timeOffBalanceDictionary objectForKey:@"totalDurationOfTimeOff"]objectForKey:@"calendarDayDuration"];
                requestedTotalHour=[Util getRoundedValueFromDecimalPlaces:[[Util convertApiTimeDictToDecimal:hoursDict] newDoubleValue]withDecimalPlaces:2];
            }
        }
        
        if (balanceTotalDays!=nil &&![balanceTotalDays isKindOfClass:[NSNull class]]) {
            [balanceResponseDict setObject:balanceTotalDays forKey:@"balanceRemainingDays"];
        }
        if (requestedTotalDays!=nil &&![requestedTotalDays isKindOfClass:[NSNull class]]) {
            [balanceResponseDict setObject:requestedTotalDays forKey:@"requestedDays"];
        }
        if (balanceTotalHour!=nil &&![balanceTotalHour isKindOfClass:[NSNull class]]) {
            [balanceResponseDict setObject:balanceTotalHour forKey:@"balanceRemainingHours"];
        }
        if (requestedTotalHour!=nil &&![requestedTotalHour isKindOfClass:[NSNull class]]) {
            [balanceResponseDict setObject:requestedTotalHour forKey:@"requestedHours"];
        }
    }
    if(timeOffUri!=nil && timeOffUri!=(id)[NSNull null])
    {
        [balanceResponseDict setObject:timeOffUri forKey:@"timeOffURI"];
    }
    [self deleteTimeOffBalanceSummaryForMultiday:timeOffUri];
    [myDB insertIntoTable:timeOffBalanceSummaryMultiDayBooking data:balanceResponseDict intoDatabase:@""];

}

-(void)saveMultiDayTimeOffUserExplicitEntryDetails:(NSArray *)userExplicitEntryDetails timeOffUri:(NSString *)timeOffUri{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString=[NSString stringWithFormat:@"timeoffUri = '%@'",timeOffUri];
    [myDB deleteFromTable:multiDayTimeOffEntries where:whereString inDatabase:@""];
    
    for(NSDictionary *timeOffEntry in userExplicitEntryDetails){
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
        if(timeOffEntry[@"date"] != nil && timeOffEntry[@"date"] != (id)[NSNull null]){
            NSDate *entryDate=[Util convertApiDateDictToDateFormat:timeOffEntry[@"date"]];
            NSNumber *timeOffDate=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
            [dataDictionary setObject:timeOffDate forKey:@"date"];
        }
        if(timeOffEntry[@"relativeDurationUri"] != nil && timeOffEntry[@"relativeDurationUri"] != (id)[NSNull null]){
            [dataDictionary setObject:timeOffEntry[@"relativeDurationUri"] forKey:@"relativeDurationUri"];
        }
        if(timeOffEntry[@"specificDuration"] != nil && timeOffEntry[@"specificDuration"] != (id)[NSNull null]){
            [dataDictionary setObject:timeOffEntry[@"specificDuration"] forKey:@"specificDuration"];
        }
        if(timeOffEntry[@"scheduleDuration"] != nil && timeOffEntry[@"scheduleDuration"] != (id)[NSNull null]){
            [dataDictionary setObject:timeOffEntry[@"scheduleDuration"] forKey:@"scheduledDuration"];
        }
        if(timeOffEntry[@"timeEnded"] != nil && timeOffEntry[@"timeEnded"] != (id)[NSNull null]){
//            [dataDictionary setObject:timeOffEntry[@"timeEnded"] forKey:@"timeEnded"];
            NSString *timeEnded = [Util convertApiTimeDictTo12HourTimeString:timeOffEntry[@"timeEnded"]];
            if(timeEnded !=nil && timeEnded != (id)[NSNull null]){
                [dataDictionary setObject:[NSString stringWithFormat:@"%@",timeEnded] forKey:@"timeEnded"];
            }
        }
        if(timeOffEntry[@"timeStarted"] != nil && timeOffEntry[@"timeStarted"] != (id)[NSNull null]){
            NSString *timeStarted = [Util convertApiTimeDictTo12HourTimeString:timeOffEntry[@"timeStarted"]];
            if(timeStarted !=nil && timeStarted != (id)[NSNull null]){
                [dataDictionary setObject:[NSString stringWithFormat:@"%@",timeStarted] forKey:@"timeStarted"];
            }
        }
        [dataDictionary setObject:timeOffUri forKey:@"timeOffUri"];
       [myDB insertIntoTable:multiDayTimeOffEntries data:dataDictionary intoDatabase:@""];
    }
}

-(void)saveBookingOptionsByScheduleDuration:(NSArray *)bookingOptionsByScheduleDuration timeOffUri:(NSString *)timeOffUri{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString=[NSString stringWithFormat:@"timeoffUri = '%@'",timeOffUri];
    [myDB deleteFromTable:timeoffBookingScheduledDuration where:whereString inDatabase:@""];
    
    for(NSDictionary *scheduleDuration in bookingOptionsByScheduleDuration){
        
        NSArray *bookingOptionsArray = scheduleDuration[@"bookingOptions"];
        if(bookingOptionsArray != nil && bookingOptionsArray != (id)[NSNull null] && bookingOptionsArray.count > 0){
            for(NSDictionary *bookingOptionsDict in bookingOptionsArray){
                
                NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
                if(scheduleDuration[@"scheduleDuration"] != nil && scheduleDuration[@"scheduleDuration"] != (id)[NSNull null]){
                    [dataDictionary setObject:scheduleDuration[@"scheduleDuration"] forKey:@"scheduledDuration"];
                }else{
                    [dataDictionary setObject:@"0" forKey:@"scheduledDuration"];
                }
                [dataDictionary setObject:timeOffUri forKey:@"timeOffUri"];
                [dataDictionary setObject:bookingOptionsDict[@"displayText"] forKey:@"displayText"];
                if([Util isNonNullObject:bookingOptionsDict[@"duration"]]) {
                    [dataDictionary setObject:bookingOptionsDict[@"duration"] forKey:@"duration"];
                }
                [dataDictionary setObject:bookingOptionsDict[@"uri"] forKey:@"uri"];
                [myDB insertIntoTable:timeoffBookingScheduledDuration data:dataDictionary intoDatabase:@""];
            }
        }
    }
}


-(void)saveTimeOffEntryDataFromApiToDB:(NSMutableDictionary *)responseDict andTimesheetUri:(NSString *)timesheetUri
{
    NSMutableDictionary *timeOffDetailsDict=[responseDict objectForKey:@"timeOffDetails"];
    NSArray *userExplicitEntryDetails = timeOffDetailsDict[@"userExplicitEntryDetails"];
    NSArray *bookingOptionsByScheduleDuration = responseDict[@"bookingOptionsByScheduleDuration"];
    NSString *timeoffUri=[timeOffDetailsDict objectForKey:@"uri"];
    
    NSString *timeOffTypeUri = nil;
    if(timeOffDetailsDict[@"timeOffType"] != nil && timeOffDetailsDict[@"timeOffType"] != (id)[NSNull null]){
        NSDictionary *timeOffTypeDictionary = timeOffDetailsDict[@"timeOffType"];
        timeOffTypeUri = timeOffTypeDictionary[@"uri"];
    }
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *whereString=[NSString stringWithFormat:@"timeoffUri = '%@'",timeoffUri];
    if(userExplicitEntryDetails != nil && userExplicitEntryDetails != (id)[NSNull null] && userExplicitEntryDetails.count > 0){
        [self saveMultiDayTimeOffUserExplicitEntryDetails:userExplicitEntryDetails timeOffUri:timeoffUri];
    }
    
    if(bookingOptionsByScheduleDuration != nil && bookingOptionsByScheduleDuration != (id)[NSNull null] && bookingOptionsByScheduleDuration.count >0 ){
        [self saveBookingOptionsByScheduleDuration:bookingOptionsByScheduleDuration timeOffUri:timeoffUri];
    }
    
    [myDB deleteFromTable:timeOffCustomFieldsTable where:whereString inDatabase:@""];
    
    
    
    NSNumber *shiftDurationDecimal=nil;
    NSString *shiftDurationHourStr=nil;
    NSDictionary *timeoffCapabilities=[responseDict objectForKey:@"capabilities"];
    //US9453 to address DE17320 Ullas M L
    NSMutableArray *enabledCustomFieldUris=[timeoffCapabilities objectForKey:@"enabledCustomFieldUris"];
    
    //Implemented as per US7660
    int hasTimeOffEditAcess     =0;
    int hasTimeOffDeletetAcess  =0;
    int isDeviceSupportedEntryConfiguration = 0;
    NSNumber *isMultidayTimeOff;
    if (timeoffCapabilities!=nil && ![timeoffCapabilities isKindOfClass:[NSNull class]]) {
        if (([timeoffCapabilities objectForKey:@"canDeleteTimeOff"]!=nil && ![[timeoffCapabilities objectForKey:@"canDeleteTimeOff"] isKindOfClass:[NSNull class]])&&[[timeoffCapabilities objectForKey:@"canDeleteTimeOff"] boolValue] == YES )
        {
            hasTimeOffDeletetAcess = 1;
        }
        if (([timeoffCapabilities objectForKey:@"canEditTimeOff"]!=nil && ![[timeoffCapabilities objectForKey:@"canEditTimeOff"] isKindOfClass:[NSNull class]])&&[[timeoffCapabilities objectForKey:@"canEditTimeOff"] boolValue] == YES )
        {
            hasTimeOffEditAcess = 1;
        }
    }
    
    if ([responseDict objectForKey:@"isDeviceSupportedEntryConfiguration"]!=nil && ![[responseDict objectForKey:@"isDeviceSupportedEntryConfiguration"] isKindOfClass:[NSNull class]])
    {
        if([[responseDict objectForKey:@"isDeviceSupportedEntryConfiguration"] boolValue] == YES)
        {
            isDeviceSupportedEntryConfiguration = 1;
        }
    }
    if ([responseDict objectForKey:@"isMultiDayTimeOff"] != nil && [responseDict objectForKey:@"isMultiDayTimeOff"] != (id)[NSNull null])
    {
         isMultidayTimeOff = [responseDict objectForKey:@"isMultiDayTimeOff"];
    }
    
    
    if ([isMultidayTimeOff boolValue]){
        NSDictionary *timeOffBalanceInfo = responseDict[@"timeOffBalanceInfo"];
        if (timeOffBalanceInfo!=nil && ![timeOffBalanceInfo isKindOfClass:[NSNull class]])
        {
            NSString *measurementUnitUri = responseDict[@"timeOffTypeDetails"][@"measurementUnitUri"];
            if (measurementUnitUri==nil || [measurementUnitUri isKindOfClass:[NSNull class]])
            {
                measurementUnitUri = @"";
            }

            NSDictionary *balanceInfo = @{@"isMultiDayTimeOff" : isMultidayTimeOff, @"timeOffBalanceInfo" :  timeOffBalanceInfo, @"timeOffDisplayFormatUri" : measurementUnitUri};
            [self saveTimeoffBalanceSummaryForMultiDayTimeOffBooking:balanceInfo withTimeOffUri:timeoffUri];
        }
    }else{
        if ([responseDict objectForKey:@"timeOffBalanceSummary"]!=nil && ![[responseDict objectForKey:@"timeOffBalanceSummary"]isKindOfClass:[NSNull class]])
        {
            [self saveTimeoffBalanceSummaryForMultiDayTimeOffBooking:[responseDict objectForKey:@"timeOffBalanceSummary"] withTimeOffUri:timeoffUri];
        }
    }
    NSDictionary *shiftDurationDict=[[NSUserDefaults standardUserDefaults]objectForKey:@"hoursPerWorkday"];
    if (shiftDurationDict!=nil && ![shiftDurationDict isKindOfClass:[NSNull class]])
    {
        shiftDurationDecimal=[Util convertApiTimeDictToDecimal:shiftDurationDict];
        shiftDurationHourStr=[Util convertApiTimeDictToString:shiftDurationDict];
    }
    NSString*status=nil;
    
    NSString* statusUri=[[responseDict objectForKey:@"approvalStatus"]objectForKey:@"uri"];
    
    if ([statusUri isEqualToString:APPROVED_STATUS_URI])
    {
        status=APPROVED_STATUS;
    }
    else if ([statusUri isEqualToString:NOT_SUBMITTED_STATUS_URI])
    {
        status=NOT_SUBMITTED_STATUS;
    }
    else if ([statusUri isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
    {
        status=WAITING_FOR_APRROVAL_STATUS;
    }
    else if ([statusUri isEqualToString:REJECTED_STATUS_URI])
    {
        status=REJECTED_STATUS;
    }
    
    [self deleteTimeOffFromDBForAllTimeSheetUri];

    
    NSArray *timeoffArr = [self getTimeoffInfoSheetIdentity:timeoffUri];
    if ([timeoffArr count]>0)
    {
        NSMutableDictionary *timeoffDict=[NSMutableDictionary dictionaryWithDictionary:[timeoffArr objectAtIndex:0]];
        
        if (status!=nil && ![status isKindOfClass:[NSNull class]]) {
            [timeoffDict removeObjectForKey:@"approvalStatus"];
            [timeoffDict setObject:status      forKey:@"approvalStatus"];
        }
        if (statusUri!=nil && ![statusUri isKindOfClass:[NSNull class]]) {
            [timeoffDict removeObjectForKey:@"approvalStatusUri"];
            [timeoffDict setObject:statusUri      forKey:@"approvalStatusUri"];
        }
        //Implemented as per US7660
        [timeoffDict setObject:[NSNumber numberWithInt:hasTimeOffDeletetAcess] forKey:@"hasTimeOffDeletetAcess"];
        [timeoffDict setObject:[NSNumber numberWithInt:hasTimeOffEditAcess] forKey:@"hasTimeOffEditAcess"];
        [timeoffDict setObject:[NSNumber numberWithInt:isDeviceSupportedEntryConfiguration] forKey:@"isDeviceSupportedEntryConfiguration"];
        [timeoffDict setObject:isMultidayTimeOff!=nil && isMultidayTimeOff!=(id)[NSNull null] ? isMultidayTimeOff:@0 forKey:@"isMultiDayTimeOff"];
       // [timeoffDict setObject:[NSNumber numberWithInt:isMultiDayTimeOff] forKey:@"isMultiDayTimeOff"];
        
        NSString *comments=[timeOffDetailsDict objectForKey:@"comments"];
        [timeoffDict removeObjectForKey:@"comments"];

        [timeoffDict setObject:comments forKey:@"comments"];
        if ([timeOffDetailsDict objectForKey:@"endDateDetails"]!=nil && ![[timeOffDetailsDict objectForKey:@"endDateDetails"] isKindOfClass:[NSNull class]])
        {
            NSDictionary *endDateDict=[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"date"];
            NSDate *endDate=[Util convertApiDateDictToDateFormat:endDateDict];
            [timeoffDict removeObjectForKey:@"endDate"];
            [timeoffDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]] forKey:@"endDate"];
            
            NSString *endEntryType=nil;
            if ([[timeOffDetailsDict objectForKey:@"endDateDetails"]objectForKey:@"relativeDurationUri"]!=nil&&![[[timeOffDetailsDict objectForKey:@"endDateDetails"]objectForKey:@"relativeDurationUri"] isKindOfClass:[NSNull class]])
            {
                endEntryType=[[timeOffDetailsDict objectForKey:@"endDateDetails"]objectForKey:@"relativeDurationUri"];
            }
            else
                endEntryType=PARTIAL;
            [timeoffDict removeObjectForKey:@"endEntryDurationUri"];
            [timeoffDict setObject:endEntryType forKey:@"endEntryDurationUri"];
            
            if ([[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"timeOfDay"]!=nil && ![[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"timeOfDay"] isKindOfClass:[NSNull class]]) {
                NSDictionary *tempDict=[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"timeOfDay"];
                NSMutableDictionary *endDateTimeDict=[NSMutableDictionary dictionary];
                [endDateTimeDict setObject:[tempDict objectForKey:@"hour"] forKey:@"Hour"];
                [endDateTimeDict setObject:[tempDict objectForKey:@"minute"] forKey:@"Minute"];
                NSString *endDateTime =  [Util convertApiTimeDictTo12HourTimeString:endDateTimeDict];
                [timeoffDict removeObjectForKey:@"endDateTime"];
                [timeoffDict setObject:endDateTime   forKey:@"endDateTime"];
            }
            
            
            if ([[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"totalDuration"]!=nil && ![[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"totalDuration"] isKindOfClass:[NSNull class]]) {
                NSDictionary *totalHoursDict=[[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"totalDuration"]objectForKey:@"calendarDayDuration"];
                NSNumber *endDatetotalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                NSString *endDatetotalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                
                [timeoffDict removeObjectForKey:@"endDateDurationDecimal"];
                [timeoffDict removeObjectForKey:@"endDateDurationHour"];
                [timeoffDict setObject:endDatetotalHours      forKey:@"endDateDurationDecimal"];
                [timeoffDict setObject:endDatetotalHoursStr   forKey:@"endDateDurationHour"];

            }
            
        }
        if ([timeOffDetailsDict objectForKey:@"startDateDetails"]!=nil && ![[timeOffDetailsDict objectForKey:@"startDateDetails"] isKindOfClass:[NSNull class]])
        {
            NSDictionary *startDateDict=[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"date"];
            NSDate *startDate=[Util convertApiDateDictToDateFormat:startDateDict];
            [timeoffDict removeObjectForKey:@"startDate"];
            [timeoffDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"startDate"];
            NSString *startEntryType=nil;
            if ([[timeOffDetailsDict objectForKey:@"startDateDetails"]objectForKey:@"relativeDurationUri"]!=nil&&![[[timeOffDetailsDict objectForKey:@"startDateDetails"]objectForKey:@"relativeDurationUri"] isKindOfClass:[NSNull class]])
            {
                startEntryType=[[timeOffDetailsDict objectForKey:@"startDateDetails"]objectForKey:@"relativeDurationUri"];
            }
            else
                startEntryType=PARTIAL;
            [timeoffDict removeObjectForKey:@"startEntryDurationUri"];
            [timeoffDict setObject:startEntryType forKey:@"startEntryDurationUri"];
            
            if ([[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"timeOfDay"]!=nil && ![[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"timeOfDay"] isKindOfClass:[NSNull class]])
            {
                NSDictionary *tempDict=[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"timeOfDay"];
                NSMutableDictionary *startDateTimeDict=[NSMutableDictionary dictionary];
                [startDateTimeDict setObject:[tempDict objectForKey:@"hour"] forKey:@"Hour"];
                [startDateTimeDict setObject:[tempDict objectForKey:@"minute"] forKey:@"Minute"];
                NSString *startDateTime =  [Util convertApiTimeDictTo12HourTimeString:startDateTimeDict];
                [timeoffDict removeObjectForKey:@"startDateTime"];
                [timeoffDict setObject:startDateTime   forKey:@"startDateTime"];
                
            }
            
            
            if ([[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"totalDuration"]!=nil && ![[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"totalDuration"] isKindOfClass:[NSNull class]]) {
                NSDictionary *totalHoursDict=[[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"totalDuration"]objectForKey:@"calendarDayDuration"];
                NSNumber *endDatetotalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                NSString *endDatetotalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                
                [timeoffDict removeObjectForKey:@"startDateDurationDecimal"];
                [timeoffDict removeObjectForKey:@"startDateDurationHour"];
                [timeoffDict setObject:endDatetotalHours      forKey:@"startDateDurationDecimal"];
                [timeoffDict setObject:endDatetotalHoursStr   forKey:@"startDateDurationHour"];
                
            }
            
            
        }
        
        if ([timeOffDetailsDict objectForKey:@"timeOffType"]!=nil && ![[timeOffDetailsDict objectForKey:@"timeOffType"] isKindOfClass:[NSNull class]])
        {
            NSString *timeoffTypeURI=[[timeOffDetailsDict objectForKey:@"timeOffType"] objectForKey:@"uri"];
            NSString *timeoffTypeName=[[timeOffDetailsDict objectForKey:@"timeOffType"] objectForKey:@"name"];
            [timeoffDict removeObjectForKey:@"timeoffTypeName"];
            [timeoffDict removeObjectForKey:@"timeoffTypeUri"];
            [timeoffDict setObject:timeoffTypeName forKey:@"timeoffTypeName"];
            [timeoffDict setObject:timeoffTypeURI forKey:@"timeoffTypeUri"];
            
        }
        
        if ([timeOffDetailsDict objectForKey:@"totalDuration"]!=nil && ![[timeOffDetailsDict objectForKey:@"totalDuration"] isKindOfClass:[NSNull class]])
        {
            NSDictionary *totalHoursDict=[[timeOffDetailsDict objectForKey:@"totalDuration"] objectForKey:@"calendarDayDuration"];
            NSNumber *totalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
            NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
            [timeoffDict removeObjectForKey:@"totalDurationDecimal"];
            [timeoffDict removeObjectForKey:@"totalDurationHour"];
            [timeoffDict setObject:totalHours      forKey:@"totalDurationDecimal"];
            [timeoffDict setObject:totalHoursStr   forKey:@"totalDurationHour"];
            
            NSString *totalTimeoffDaysStr=[[timeOffDetailsDict objectForKey:@"totalDuration"] objectForKey:@"decimalWorkdays"];
            [timeoffDict removeObjectForKey:@"totalTimeoffDays"];
            [timeoffDict setObject:totalTimeoffDaysStr  forKey:@"totalTimeoffDays"];
        }
        
        if (shiftDurationDecimal!=nil && ![shiftDurationDecimal isKindOfClass:[NSNull class]])
        {
            [timeoffDict setObject:shiftDurationDecimal      forKey:@"shiftDurationDecimal"];
        }
        if (shiftDurationHourStr!=nil && ![shiftDurationHourStr isKindOfClass:[NSNull class]])
        {
            [timeoffDict setObject:shiftDurationHourStr   forKey:@"shiftDurationHour"];
        }
        if ([isMultidayTimeOff boolValue]){
            NSString *measurementUnitUri = responseDict[@"timeOffTypeDetails"][@"measurementUnitUri"];
            if (measurementUnitUri==nil || [measurementUnitUri isKindOfClass:[NSNull class]])
            {
                measurementUnitUri = @"";
            }
            [timeoffDict setObject:measurementUnitUri   forKey:@"timeOffDisplayFormatUri"];
        }
        else{
            if(timeOffTypeUri != nil && timeOffTypeUri != (id)[NSNull null]){
                NSString *timeOffDisplayFormatUri = [self getTimeOffTypeDisplayFormat:timeOffTypeUri];
                if(timeOffDisplayFormatUri != nil && timeOffDisplayFormatUri != (id)[NSNull null]){
                    [timeoffDict setObject:timeOffDisplayFormatUri   forKey:@"timeOffDisplayFormatUri"];
                }
            }
        }
        NSString *whereString=[NSString stringWithFormat:@"timeoffUri='%@'",timeoffUri];
        [myDB updateTable: timeoffTable data:timeoffDict where:whereString intoDatabase:@""];
    }
    else
    {
        NSMutableDictionary *timeoffDict=[NSMutableDictionary dictionary];
       
        if (shiftDurationDecimal!=nil && ![shiftDurationDecimal isKindOfClass:[NSNull class]])
        {
            [timeoffDict setObject:shiftDurationDecimal      forKey:@"shiftDurationDecimal"];
        }
        if (shiftDurationHourStr!=nil && ![shiftDurationHourStr isKindOfClass:[NSNull class]])
        {
            [timeoffDict setObject:shiftDurationHourStr   forKey:@"shiftDurationHour"];
        }
        
      
        [timeoffDict setObject:timeoffUri forKey:@"timeoffUri"];
        
        if (status!=nil && ![status isKindOfClass:[NSNull class]]) {
            [timeoffDict setObject:status      forKey:@"approvalStatus"];
        }
        if (statusUri!=nil && ![statusUri isKindOfClass:[NSNull class]]) {
            [timeoffDict setObject:statusUri      forKey:@"approvalStatusUri"];
        }

        //Implemented as per US7660
        [timeoffDict setObject:[NSNumber numberWithInt:hasTimeOffDeletetAcess] forKey:@"hasTimeOffDeletetAcess"];
        [timeoffDict setObject:[NSNumber numberWithInt:hasTimeOffEditAcess] forKey:@"hasTimeOffEditAcess"];
        [timeoffDict setObject:[NSNumber numberWithInt:isDeviceSupportedEntryConfiguration] forKey:@"isDeviceSupportedEntryConfiguration"];
        [timeoffDict setObject:isMultidayTimeOff!=nil && isMultidayTimeOff!=(id)[NSNull null] ? isMultidayTimeOff:@0 forKey:@"isMultiDayTimeOff"];
        
        if([timeOffDetailsDict objectForKey:@"comments"] != nil && [timeOffDetailsDict objectForKey:@"comments"] != (id)[NSNull null]) {
            NSString *comments=[timeOffDetailsDict objectForKey:@"comments"];
            [timeoffDict setObject:comments forKey:@"comments"];
        }
        
        if ([timeOffDetailsDict objectForKey:@"endDateDetails"]!=nil && ![[timeOffDetailsDict objectForKey:@"endDateDetails"] isKindOfClass:[NSNull class]])
        {
            NSDictionary *endDateDict=[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"date"];
            NSDate *endDate=[Util convertApiDateDictToDateFormat:endDateDict];
            [timeoffDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]] forKey:@"endDate"];
            
            NSString *endEntryType=nil;
            if ([[timeOffDetailsDict objectForKey:@"endDateDetails"]objectForKey:@"relativeDurationUri"]!=nil&&![[[timeOffDetailsDict objectForKey:@"endDateDetails"]objectForKey:@"relativeDurationUri"] isKindOfClass:[NSNull class]])
            {
                endEntryType=[[timeOffDetailsDict objectForKey:@"endDateDetails"]objectForKey:@"relativeDurationUri"];
            }
            else
                endEntryType=PARTIAL;
            [timeoffDict setObject:endEntryType forKey:@"endEntryDurationUri"];
            
            if ([[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"timeOfDay"]!=nil && ![[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"timeOfDay"] isKindOfClass:[NSNull class]]) {
                NSDictionary *tempDict=[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"timeOfDay"];
                NSMutableDictionary *endDateTimeDict=[NSMutableDictionary dictionary];
                [endDateTimeDict setObject:[tempDict objectForKey:@"hour"] forKey:@"Hour"];
                [endDateTimeDict setObject:[tempDict objectForKey:@"minute"] forKey:@"Minute"];
                NSString *endDateTime =  [Util convertApiTimeDictTo12HourTimeString:endDateTimeDict];
                [timeoffDict setObject:endDateTime   forKey:@"endDateTime"];
            }
            
            
            if ([[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"totalDuration"]!=nil && ![[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"totalDuration"] isKindOfClass:[NSNull class]]) {
                NSDictionary *totalHoursDict=[[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"totalDuration"]objectForKey:@"calendarDayDuration"];
                NSNumber *endDatetotalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                NSString *endDatetotalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                [timeoffDict setObject:endDatetotalHours      forKey:@"endDateDurationDecimal"];
                [timeoffDict setObject:endDatetotalHoursStr   forKey:@"endDateDurationHour"];
                
            }
            
        }
        if ([timeOffDetailsDict objectForKey:@"startDateDetails"]!=nil && ![[timeOffDetailsDict objectForKey:@"startDateDetails"] isKindOfClass:[NSNull class]])
        {
            NSDictionary *startDateDict=[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"date"];
            NSDate *startDate=[Util convertApiDateDictToDateFormat:startDateDict];
            [timeoffDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"startDate"];
            NSString *startEntryType=nil;
            if ([[timeOffDetailsDict objectForKey:@"startDateDetails"]objectForKey:@"relativeDurationUri"]!=nil&&![[[timeOffDetailsDict objectForKey:@"startDateDetails"]objectForKey:@"relativeDurationUri"] isKindOfClass:[NSNull class]])
            {
                startEntryType=[[timeOffDetailsDict objectForKey:@"startDateDetails"]objectForKey:@"relativeDurationUri"];
            }
            else
                startEntryType=PARTIAL;
            [timeoffDict setObject:startEntryType forKey:@"startEntryDurationUri"];
            
            if ([[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"timeOfDay"]!=nil && ![[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"timeOfDay"] isKindOfClass:[NSNull class]])
            {
                NSDictionary *tempDict=[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"timeOfDay"];
                NSMutableDictionary *startDateTimeDict=[NSMutableDictionary dictionary];
                [startDateTimeDict setObject:[tempDict objectForKey:@"hour"] forKey:@"Hour"];
                [startDateTimeDict setObject:[tempDict objectForKey:@"minute"] forKey:@"Minute"];
                NSString *startDateTime =  [Util convertApiTimeDictTo12HourTimeString:startDateTimeDict];
                [timeoffDict setObject:startDateTime   forKey:@"startDateTime"];
                
            }
            
            
            if ([[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"totalDuration"]!=nil && ![[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"totalDuration"] isKindOfClass:[NSNull class]]) {
                NSDictionary *totalHoursDict=[[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"totalDuration"]objectForKey:@"calendarDayDuration"];
                NSNumber *endDatetotalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                NSString *endDatetotalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                [timeoffDict setObject:endDatetotalHours      forKey:@"startDateDurationDecimal"];
                [timeoffDict setObject:endDatetotalHoursStr   forKey:@"startDateDurationHour"];
                
            }
            
            
        }
        
        if ([timeOffDetailsDict objectForKey:@"timeOffType"]!=nil && ![[timeOffDetailsDict objectForKey:@"timeOffType"] isKindOfClass:[NSNull class]])
        {
            NSString *timeoffTypeURI=[[timeOffDetailsDict objectForKey:@"timeOffType"] objectForKey:@"uri"];
            NSString *timeoffTypeName=[[timeOffDetailsDict objectForKey:@"timeOffType"] objectForKey:@"name"];
            [timeoffDict setObject:timeoffTypeName forKey:@"timeoffTypeName"];
            [timeoffDict setObject:timeoffTypeURI forKey:@"timeoffTypeUri"];
            
        }
        
        if ([timeOffDetailsDict objectForKey:@"totalDuration"]!=nil && ![[timeOffDetailsDict objectForKey:@"totalDuration"] isKindOfClass:[NSNull class]])
        {
            NSDictionary *totalHoursDict=[[timeOffDetailsDict objectForKey:@"totalDuration"] objectForKey:@"calendarDayDuration"];
            NSNumber *totalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
            NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
            [timeoffDict setObject:totalHours      forKey:@"totalDurationDecimal"];
            [timeoffDict setObject:totalHoursStr   forKey:@"totalDurationHour"];
            
            NSString *totalTimeoffDaysStr=[[timeOffDetailsDict objectForKey:@"totalDuration"] objectForKey:@"decimalWorkdays"];
            [timeoffDict setObject:totalTimeoffDaysStr  forKey:@"totalTimeoffDays"];
        }
        
        if (shiftDurationDecimal!=nil && ![shiftDurationDecimal isKindOfClass:[NSNull class]])
        {
            [timeoffDict setObject:shiftDurationDecimal      forKey:@"shiftDurationDecimal"];
        }
        if (shiftDurationHourStr!=nil && ![shiftDurationHourStr isKindOfClass:[NSNull class]])
        {
            [timeoffDict setObject:shiftDurationHourStr   forKey:@"shiftDurationHour"];
        }
        
        if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
        {
            [timeoffDict setObject:timesheetUri forKey:@"timesheetUri"];
        }
        if ([isMultidayTimeOff boolValue]){
            NSString *measurementUnitUri = responseDict[@"timeOffTypeDetails"][@"measurementUnitUri"];
            if (measurementUnitUri==nil || [measurementUnitUri isKindOfClass:[NSNull class]])
            {
                measurementUnitUri = @"";
            }
            [timeoffDict setObject:measurementUnitUri   forKey:@"timeOffDisplayFormatUri"];
        }
        else{
            if(timeOffTypeUri != nil && timeOffTypeUri != (id)[NSNull null]){
                NSString *timeOffDisplayFormatUri = [self getTimeOffTypeDisplayFormat:timeOffTypeUri];
                if(timeOffDisplayFormatUri != nil && timeOffDisplayFormatUri != (id)[NSNull null]){
                    [timeoffDict setObject:timeOffDisplayFormatUri   forKey:@"timeOffDisplayFormatUri"];
                }
            }
        }
        [myDB insertIntoTable:timeoffTable data:timeoffDict intoDatabase:@""];
    }
    
    [self saveEnableOnlyCustomFieldUriIntoDBWithUriArray:enabledCustomFieldUris forTimeoffUri:timeoffUri];
    [self updateCustomFieldTableFor:TIMEOFF_UDF enableUdfuriArray:enabledCustomFieldUris];
    if (![timeOffDetailsDict isKindOfClass:[NSNull class]] && timeOffDetailsDict!=nil )
    {
        NSArray *sheetCustomFieldsArray=[timeOffDetailsDict objectForKey:@"customFields"];
        [self saveCustomFieldswithData:sheetCustomFieldsArray forSheetURI:timeoffUri andModuleName:TIMEOFF_UDF andEntryURI:nil];
    }
    //Implementation for MOBI-261//JUHI
    NSArray *approvalDetailsArray=[[responseDict objectForKey:@"approvalDetails"] objectForKey:@"entries"];
    NSMutableArray *approvalDtlsDataArray=[NSMutableArray array];
    
    for (NSDictionary *dict in approvalDetailsArray)
    {
        
        NSString *actingForUser=nil;
        NSString *actingUser=nil;
        NSString *comments=nil;
        NSMutableDictionary *approvalDetailDataDict=[NSMutableDictionary dictionary];
        [approvalDetailDataDict setObject:timeoffUri forKey:@"timeoffUri"];
        
        NSString *action=[[dict objectForKey:@"action"]objectForKey:@"uri"];
        if ([dict objectForKey:@"timeStamp"]!=nil && ![[dict objectForKey:@"timeStamp"] isKindOfClass:[NSNull class]])
        {
            NSDate *entryDate=[Util convertApiDateDictToDateTimeFormat:[dict objectForKey:@"timeStamp"]];
            NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
            [approvalDetailDataDict setObject:entryDateToStore forKey:@"timestamp"];
           
        }
        
        if ([dict objectForKey:@"authority"]!=nil && ![[dict objectForKey:@"authority"] isKindOfClass:[NSNull class]])
        {
            if ([[dict objectForKey:@"authority"] objectForKey:@"actingForUser"]!=nil && ![[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] isKindOfClass:[NSNull class]])
            {
                if ([[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"]!=nil && ![[[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"] isKindOfClass:[NSNull class]])
                {
                    actingForUser=[[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"];
                }
                
            }
            if ([[dict objectForKey:@"authority"] objectForKey:@"actingUser"]!=nil && ![[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] isKindOfClass:[NSNull class]])
            {
                if ([[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"]!=nil && ![[[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"] isKindOfClass:[NSNull class]])
                {
                    actingUser=[[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"];
                }
                
            }
        }
        if ([dict objectForKey:@"comments"]!=nil && ![[dict objectForKey:@"comments"] isKindOfClass:[NSNull class]])
        {
            comments=[dict objectForKey:@"comments"];
        }
        
        
        if (actingForUser!=nil)
        {
            [approvalDetailDataDict setObject:actingForUser                      forKey:@"actingForUser"];
        }
        if (comments!=nil)
        {
            [approvalDetailDataDict setObject:comments                      forKey:@"comments"];
        }
        if (actingUser!=nil)
        {
            [approvalDetailDataDict setObject:actingUser                      forKey:@"actingUser"];
        }
        
        
        
        
        [approvalDetailDataDict setObject:action forKey:@"actionUri"];
        
        
        [approvalDtlsDataArray addObject:approvalDetailDataDict];
    }
    
    [self saveTimeoffApprovalDetailsDataToDatabase:approvalDtlsDataArray];
}

-(NSString *)getTimeOffTypeDisplayFormat:(NSString *)timeoffTypeUri{
    NSString *timeOffDisplayFormatUri = nil;
    NSArray *timeOffDisplayFormatUriArray = [self getTimeoffTypeInfoSheetIdentity:timeoffTypeUri];
    if (timeOffDisplayFormatUriArray!= nil && timeOffDisplayFormatUriArray != (id)[NSNull null] && timeOffDisplayFormatUriArray.count >0) {
        timeOffDisplayFormatUri = timeOffDisplayFormatUriArray[0][@"timeOffDisplayFormatUri"];
    }
    return timeOffDisplayFormatUri;
}

-(void)saveDefaultTimeoffTypeDetailDataToDB:(NSDictionary *)response{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    if (response[@"defaultTimeOffTypeForBookings"]!=nil && response[@"defaultTimeOffTypeForBookings"]!= (id)[NSNull null]) {
        NSDictionary *defaultTimeOffTypeForBookings = [NSDictionary dictionaryWithDictionary:response[@"defaultTimeOffTypeForBookings"]];
        if (defaultTimeOffTypeForBookings!=nil && defaultTimeOffTypeForBookings != (id)[NSNull null]) {
            NSDictionary *dictionary = @{@"name":defaultTimeOffTypeForBookings[@"name"],
                                         @"uri":defaultTimeOffTypeForBookings[@"uri"]
                                         };
            [myDB deleteFromTable:defaultTimeoffTypesTable inDatabase:@""];
            [myDB insertIntoTable:defaultTimeoffTypesTable data:dictionary intoDatabase:@""];
        }
    }
}
-(void)saveTimeoffTypeDetailDataToDB:(NSMutableArray *)array{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    for (int i=0; i<[array count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSMutableDictionary *detailDict=[array objectAtIndex:i];
        id timeoffTypeName=[detailDict objectForKey:@"displayText"];
        NSString *timeoffTypeNamestr=[NSString stringWithFormat:@"%@",timeoffTypeName];
        NSString *timeoffTypeUri=[detailDict objectForKey:@"uri"];
        NSString *minTimeoffIncrementPolicyUri=[detailDict objectForKey:@"minimumTimeOffIncrementPolicyUri"];
        NSString *timeoffBalanceTrackingOptionUri=[detailDict objectForKey:@"timeOffBalanceTrackingOptionUri"];
        NSString *startEndTimeSpecRequirementUri=[detailDict objectForKey:@"startEndTimeSpecificationRequirementUri"];
        //Implemented as per US8705//JUHI
        int isEnabled  =0;
        
        if (([detailDict objectForKey:@"enabled"]!=nil&&![[detailDict objectForKey:@"enabled"] isKindOfClass:[NSNull class]])&&[[detailDict objectForKey:@"enabled"] boolValue] == YES )
        {
            isEnabled = 1;
        }
        if (timeoffTypeNamestr!=nil)
        {
            [dataDict setObject:timeoffTypeNamestr forKey:@"timeoffTypeName"];
        }
        if (timeoffTypeUri!=nil)
        {
            [dataDict setObject:timeoffTypeUri forKey:@"timeoffTypeUri"];
        }
        if (minTimeoffIncrementPolicyUri!=nil)
        {
            [dataDict setObject:minTimeoffIncrementPolicyUri forKey:@"minTimeoffIncrementPolicyUri"];
        }
        if (timeoffBalanceTrackingOptionUri!=nil)
        {
            [dataDict setObject:timeoffBalanceTrackingOptionUri forKey:@"timeoffBalanceTrackingOptionUri"];
        }
        if (startEndTimeSpecRequirementUri!=nil)
        {
            [dataDict setObject:startEndTimeSpecRequirementUri forKey:@"startEndTimeSpecRequirementUri"];
        }
        //Implemented as per US8705//JUHI timeOffDisplayFormatUri
        [dataDict setObject:[NSNumber numberWithInt:isEnabled] forKey:@"enabled"];
        NSString *timeOffDisplayFormatUri = detailDict[@"timeOffDisplayFormatUri"];
        if (timeOffDisplayFormatUri!=nil && ![timeOffDisplayFormatUri isKindOfClass:[NSNull class]]) {
            [dataDict setObject:detailDict[@"timeOffDisplayFormatUri"] forKey:@"timeOffDisplayFormatUri"];
        }
        NSArray *expArr = [self getTimeoffTypeInfoSheetIdentity:timeoffTypeUri];
        if ([expArr count]>0)
        {
			NSString *whereString=[NSString stringWithFormat:@"timeoffTypeUri='%@'",timeoffTypeUri];
			[myDB updateTable: bookedTimeoffTypesTable data:dataDict where:whereString intoDatabase:@""];
		}
        else
        {
			[myDB insertIntoTable:bookedTimeoffTypesTable data:dataDict intoDatabase:@""];
		}
        
        
        
    }
}

-(void)saveCustomFieldswithData:(NSArray *)sheetCustomFieldsArray forSheetURI:(NSString *)sheetUri andModuleName:(NSString *)moduleName andEntryURI:(NSString *)entryURI
{
    for (int i=0; i<[sheetCustomFieldsArray count]; i++)
    {
        NSMutableDictionary *udfDataDict=[NSMutableDictionary dictionary];
        NSDictionary *udfDict=[sheetCustomFieldsArray objectAtIndex:i];
        NSString *name=[[udfDict objectForKey:@"customField"]objectForKey:@"displayText"];
        if (name!=nil && ![name isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:name forKey:@"udf_name"];
        }
        NSString *uri=[[udfDict objectForKey:@"customField"]objectForKey:@"uri"];
        if (uri!=nil && ![uri isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:uri forKey:@"udf_uri"];
        }
        NSString *type=[[udfDict objectForKey:@"customFieldType"]objectForKey:@"uri"];
        if (type!=nil && ![type isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:type forKey:@"entry_type"];
            
            if ([type isEqualToString:DROPDOWN_UDF_TYPE])
            {
                NSString *dropDownOptionURI=[udfDict objectForKey:@"dropDownOption"];
                if (dropDownOptionURI!=nil && ![dropDownOptionURI isKindOfClass:[NSNull class]])
                {
                    [udfDataDict setObject:dropDownOptionURI forKey:@"dropDownOptionURI"];
                }
            }
        }
        
        if (entryURI!=nil && ![entryURI isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:entryURI forKey:@"entryUri"];
        }
        NSString *value;
        if([type isEqualToString:NUMERIC_UDF_TYPE]) {
            value = [udfDict objectForKey:@"number"];
        } else {
            value = [udfDict objectForKey:@"text"];
        }
        
        if ([type isEqualToString:DATE_UDF_TYPE])
        {
            NSString *tmpValue=[udfDict objectForKey:@"date"];
            if (tmpValue!=nil && ![tmpValue isKindOfClass:[NSNull class]])
            {
                value=[Util convertApiTimeDictToDateStringWithDesiredFormat:[udfDict objectForKey:@"date"]];//DE18243 DE18690 DE18728 Ullas M L
            }
        }
        if (value!=nil && ![value isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:value forKey:@"udfValue"];
        }
        
        if (sheetUri!=nil && ![sheetUri isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:sheetUri forKey:@"timeoffUri"];
        }
        
        if (moduleName!=nil && ![moduleName isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:moduleName forKey:@"moduleName"];
        }
        
        SQLiteDB *myDB = [SQLiteDB getInstance];
        NSArray *udfsArr = [self getTimeOffCustomFieldsForURI:sheetUri moduleName:moduleName entryURI:entryURI andUdfURI:uri];
        if ([udfsArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"timeoffUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",sheetUri,moduleName,entryURI,uri];
            [myDB updateTable:timeOffCustomFieldsTable data:udfDataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:timeOffCustomFieldsTable data:udfDataDict intoDatabase:@""];
        }
        
        
    }
}

-(NSMutableDictionary *)getCompanyHolidayInfoDict
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [NSDate date];
    NSDateComponents *todaydateComponents = [calendar components:unitFlags fromDate:date];
    
    NSInteger year = [todaydateComponents year];
    
    NSDateComponents *datecomponents = [[NSDateComponents alloc] init];
    
    [datecomponents setYear:year-1]; //Previous Year
    [datecomponents setMonth:1];
    [datecomponents setDay:1];
    [datecomponents setHour:0];
    [datecomponents setMinute:0];
    [datecomponents setSecond:0];
    
    
    NSDate *previousStartDate = [calendar dateFromComponents:datecomponents];
    
    [datecomponents setYear:year-1]; //Previous Year
    [datecomponents setMonth:12];
    [datecomponents setDay:31];
    [datecomponents setHour:0];
    [datecomponents setMinute:0];
    [datecomponents setSecond:0];
    
    NSDate *previousEndDate = [calendar dateFromComponents:datecomponents];
    
    
    [datecomponents setYear:year]; //Current Year
    [datecomponents setMonth:1];
    [datecomponents setDay:1];
    [datecomponents setHour:0];
    [datecomponents setMinute:0];
    [datecomponents setSecond:0];
    
    
    NSDate *currentStartDate = [calendar dateFromComponents:datecomponents];
    
    [datecomponents setYear:year]; //Current Year
    [datecomponents setMonth:12];
    [datecomponents setDay:31];
    [datecomponents setHour:0];
    [datecomponents setMinute:0];
    [datecomponents setSecond:0];
    
    NSDate *currentEndDate = [calendar dateFromComponents:datecomponents];
    
    
    [datecomponents setYear:year+1]; //Next Year
    [datecomponents setMonth:1];
    [datecomponents setDay:1];
    [datecomponents setHour:0];
    [datecomponents setMinute:0];
    [datecomponents setSecond:0];
    
    
    NSDate *nextStartDate = [calendar dateFromComponents:datecomponents];
    
    [datecomponents setYear:year+1]; //Current Year
    [datecomponents setMonth:12];
    [datecomponents setDay:31];
    [datecomponents setHour:0];
    [datecomponents setMinute:0];
    [datecomponents setSecond:0];
    
    NSDate *nextEndDate = [calendar dateFromComponents:datecomponents];
    
    
    
    
    NSMutableDictionary *timeOffsDict=[NSMutableDictionary dictionaryWithCapacity:3];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where holidayDate BETWEEN %f AND %f order by holidayDate asc",companyHolidaysTable,[Util convertDateToTimestamp:previousStartDate],[Util convertDateToTimestamp:previousEndDate]];
	NSMutableArray *timeOffsArr = [myDB executeQueryToConvertUnicodeValues:query];
    NSInteger timeOffpreviousYear = year -1;

	if ([timeOffsArr count]!=0)
    {
		[timeOffsDict setObject:timeOffsArr forKey:[NSString stringWithFormat:@"%d",(int)timeOffpreviousYear]];
	}
    else
    {
        [timeOffsDict setObject:[NSNull null] forKey:[NSString stringWithFormat:@"%d",(int)timeOffpreviousYear]];
    }
    
    
    NSString *query1=[NSString stringWithFormat:@" select * from %@ where holidayDate BETWEEN %f AND %f order by holidayDate asc",companyHolidaysTable,[Util convertDateToTimestamp:currentStartDate],[Util convertDateToTimestamp:currentEndDate]];
	NSMutableArray *timeOffsArr1 = [myDB executeQueryToConvertUnicodeValues:query1];
	if ([timeOffsArr1 count]!=0)
    {
		[timeOffsDict setObject:timeOffsArr1 forKey:[NSString stringWithFormat:@"%ld",(long)year]];
	}
    else
    {
        [timeOffsDict setObject:[NSNull null] forKey:[NSString stringWithFormat:@"%ld",(long)year]];
    }
    
    NSString *query2=[NSString stringWithFormat:@" select * from %@ where holidayDate BETWEEN %f AND %f order by holidayDate asc",companyHolidaysTable,[Util convertDateToTimestamp:nextStartDate],[Util convertDateToTimestamp:nextEndDate]];
	NSMutableArray *timeOffsArr2 = [myDB executeQueryToConvertUnicodeValues:query2];
    NSInteger timeOffNextYear = year +1;
	if ([timeOffsArr2 count]!=0)
    {
		[timeOffsDict setObject:timeOffsArr2 forKey:[NSString stringWithFormat:@"%d",(int)timeOffNextYear]];
	}
    else
    {
        [timeOffsDict setObject:[NSNull null] forKey:[NSString stringWithFormat:@"%d",(int)timeOffNextYear]];
    }
    
    
	return timeOffsDict;
    
}
-(NSArray *)getTimeoffTypeInfoSheetIdentity:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timeoffTypeUri = '%@' ",bookedTimeoffTypesTable,sheetIdentity];
	NSMutableArray *timeOffsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeOffsArr count]!=0)
    {
		return timeOffsArr;
	}
	return nil;
    
}

-(NSDictionary *)getDefaultTimeoffType
{

    SQLiteDB *myDB = [SQLiteDB getInstance];

    NSString *query=[NSString stringWithFormat:@" select * from %@",defaultTimeoffTypesTable];
    NSMutableArray *timeOffsArr = [myDB executeQueryToConvertUnicodeValues:query];
    if ([timeOffsArr count]!=0)
    {
        return timeOffsArr.firstObject;
    }
    return nil;
    
}


-(NSDictionary *)getTimeoffBalanceForMultidayBooking:(NSString *)timeOffUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query=[NSString stringWithFormat:@" select * from %@ where timeoffUri = '%@'",timeOffBalanceSummaryMultiDayBooking,timeOffUri];
    NSMutableArray *timeOffBalanceValue = [myDB executeQueryToConvertUnicodeValues:query];
    if ([timeOffBalanceValue count]>0) {
        return [timeOffBalanceValue objectAtIndex:0];
    }
    return nil;
    
}

-(NSArray *)getTimeoffInfoSheetIdentity:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timeoffUri = '%@' ",timeoffTable,sheetIdentity];
	NSMutableArray *timeOffsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeOffsArr count]!=0)
    {
		return timeOffsArr;
	}
	return nil;
    
}

-(NSArray *)getTimeoffUserExplicitEntries:(NSString *)timeOffUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query=[NSString stringWithFormat:@" select * from %@ where timeoffUri = '%@' ",multiDayTimeOffEntries,timeOffUri];
    NSMutableArray *timeOffsArr = [myDB executeQueryToConvertUnicodeValues:query];
    if ([timeOffsArr count]!=0)
    {
        return timeOffsArr;
    }
    return nil;
}

-(NSArray *)getTimeoffScheduledDurations:(NSString *)timeOffUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query=[NSString stringWithFormat:@" select * from %@ where timeoffUri = '%@' ",timeoffBookingScheduledDuration,timeOffUri];
    NSMutableArray *timeOffsArr = [myDB executeQueryToConvertUnicodeValues:query];
    if ([timeOffsArr count]!=0)
    {
        return timeOffsArr;
    }
    return nil;
    
}

-(BOOL) isMultiDayTimeOff:(NSString *)timeoffUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select isMultiDayTimeOff from %@ where timeoffUri='%@'",timeoffTable,timeoffUri];
    NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([permissionArr count]>0)
    {
        id hasPermission =  [[permissionArr objectAtIndex:0] objectForKey:@"isMultiDayTimeOff"];
        if(hasPermission!= nil && hasPermission != (id)[NSNull null])
        {
            return [hasPermission boolValue];
        }
    }
    return NO;
}

-(BOOL)hasMultiDayTimeOffBooking:(NSString *)userUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select isMultiDayTimeOffOptionAvailable from %@ where uri='%@'",userDetails,userUri];
    NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([permissionArr count]>0)
    {
        id hasPermission =  [[permissionArr objectAtIndex:0] objectForKey:@"isMultiDayTimeOffOptionAvailable"];
        if(hasPermission!= nil && hasPermission != (id)[NSNull null])
        {
            return [hasPermission boolValue];
        }
    }
    return NO;
}


-(NSMutableArray *)getAllTimeoffsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    [self deleteTimeOffFromDBForAllTimeSheetUri];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ order by startDate desc",timeoffTable];
	NSMutableArray *timeoffArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([timeoffArray count]>0)
    {
		return timeoffArray;
	}
	return nil;
}
-(void)deleteAllTypeBalanceSummaryFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:timeoffTypeBalanceSummaryTable inDatabase:@""];
    
}

-(NSMutableArray *)getAllCompanyHolidaysFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ order by holidayDate asc",companyHolidaysTable];
	NSMutableArray *timeoffArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([timeoffArray count]>0)
    {
		return timeoffArray;
	}
	return nil;
}

-(void)deleteAllCompanyHolidaysFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:companyHolidaysTable inDatabase:@""];
}

-(NSMutableDictionary *)getAllTypeBalanceSummaryFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableDictionary *summaryDict=[NSMutableDictionary dictionary];
    NSMutableArray *availableArray=[NSMutableArray array];
    NSMutableArray *usedArray=[NSMutableArray array];
    NSMutableArray *untrackedArray=[NSMutableArray array];
	NSString *sql = [NSString stringWithFormat:@"select * from %@",timeoffTypeBalanceSummaryTable];
	NSMutableArray *sumarryArray = [myDB executeQueryToConvertUnicodeValues:sql];
	for (int i=0; i<[sumarryArray count]; i++)
    {
        NSString *timeTrackingOptionUri=[[sumarryArray objectAtIndex:i] objectForKey:@"timeTrackingOptionUri"];

        if ([timeTrackingOptionUri isEqualToString:TIME_OFF_AVAILABLE_KEY])
        {
            [availableArray addObject:[sumarryArray objectAtIndex:i]];
        }
        else if ([timeTrackingOptionUri isEqualToString:TIME_OFF_USED_KEY])
        {
            [usedArray addObject:[sumarryArray objectAtIndex:i]];
        }
        else if ([timeTrackingOptionUri isEqualToString:TIME_OFF_UNTRACKED_KEY])
        {
            [untrackedArray addObject:[sumarryArray objectAtIndex:i]];
        }
        
        
        
    }
    if ([availableArray count]!=0)
    {
        [summaryDict setObject:availableArray forKey:TIME_OFF_AVAILABLE_KEY];
    }
    if ([usedArray count]!=0)
    {
        [summaryDict setObject:usedArray forKey:TIME_OFF_USED_KEY];
    }
    if ([untrackedArray count]!=0)
    {
        [summaryDict setObject:untrackedArray forKey:TIME_OFF_UNTRACKED_KEY];
    }
    
    return summaryDict;
}
-(NSDictionary *)getTotalShiftHoursInfoForTimeoffUri:(NSString *)timeoffUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select shiftDurationDecimal from %@ where timeoffUri = '%@'",timeoffTable,timeoffUri];
	NSMutableArray *timeSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeSheetsArr count]!=0) {
		return [timeSheetsArr objectAtIndex:0];
	}
	return nil;
    
}
-(NSMutableArray *)getAllTimeOffTypesFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implemented as per US8705//JUHI
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where enabled=1 order by timeoffTypeName asc",bookedTimeoffTypesTable];
	NSMutableArray *timeoffArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([timeoffArray count]>0)
    {
		return timeoffArray;
	}
	return nil;
}

-(NSArray *)getTimeOffCustomFieldsForURI:(NSString *)Uri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri andUdfURI:(NSString *)udfUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timeoffUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",timeOffCustomFieldsTable,Uri,moduleName,entryUri,udfUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(void)deleteTimeOffFromDBForSheetUri:(NSString *)timeOffURI
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where timeoffUri = '%@'",timeoffTable,timeOffURI];
	[myDB executeQuery:query];
}

-(void)deleteTimeOffFromDBForAllTimeSheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query=[NSString stringWithFormat:@"delete from %@ where timesheetUri IS NOT NULL",timeoffTable];
    [myDB executeQuery:query];
}
-(void)deleteTimeOffBalanceSummaryForMultiday:(NSString *)timeOffUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query=[NSString stringWithFormat:@"delete from %@ where timeOffURI = '%@'",timeOffBalanceSummaryMultiDayBooking,timeOffUri];
    [myDB executeQuery:query];
}
-(NSArray *)getTimeOffCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timeoffUri = '%@' and moduleName='%@' and udf_uri='%@' ",timeOffCustomFieldsTable,sheetUri,moduleName,udfUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
//Implemented as per US7660
-(BOOL)getStatusForGivenPermissions:(NSString*)permissionName forSheetUri:(NSString *)timeOffURI
{
	
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select %@ from %@ where timeoffUri = '%@'",permissionName, timeoffTable,timeOffURI];
	NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:query];
    if(permissionArr!=nil && ![permissionArr isKindOfClass:[NSNull class]] && [permissionArr count]>0)
    {
        if([[[permissionArr objectAtIndex:0] objectForKey:permissionName] intValue]==1)
        {
            return YES;
        }
    }

    return NO;
    
}
//Implementation for MOBI-261//JUHI
-(void)saveTimeoffApprovalDetailsDataToDatabase:(NSArray *) timeoffDetailsArray{
    
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
	for (int i=0; i<[timeoffDetailsArray count]; i++) {
		NSDictionary *dict=[timeoffDetailsArray objectAtIndex:i];
		[myDB insertIntoTable:timeOffApprovalHistoryTable data:dict intoDatabase:@""];
		
	}
	
}
-(NSMutableArray*)getAllApprovalHistoryForTimeoffUri:(NSString *)timeoffUri
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timeoffUri='%@'",timeOffApprovalHistoryTable,timeoffUri];
	NSMutableArray *timeoffHistoryDetailsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if (timeoffHistoryDetailsArr != nil && [timeoffHistoryDetailsArr count]!=0) {
        return timeoffHistoryDetailsArr;
	}
	return nil;
}

-(void)updateCustomFieldTableFor:(NSString *)udfModuleName enableUdfuriArray:(NSMutableArray *)enabledOnlyUdfUriArray
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where moduleName='%@'",userDeFinedFieldsTable,udfModuleName];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	for (int k=0; k<[array count]; k++)
    {
        NSString *uri=[[array objectAtIndex:k] objectForKey:@"uri"];
        LoginModel *loginModel=[[LoginModel alloc]init];
        NSMutableDictionary *udfInfoDict=[loginModel getDataforUDFWithIdentity:uri];
        BOOL isUdfEnabled=[[udfInfoDict objectForKey:@"enabled"] boolValue];
        NSString *moduleName=[udfInfoDict objectForKey:@"moduleName"];
        if ([moduleName isEqualToString:TIMEOFF_UDF])
        {
            if ([enabledOnlyUdfUriArray containsObject:uri] && isUdfEnabled)
            {
                NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET enabled='%@' where moduleName='%@' and uri='%@' ",userDeFinedFieldsTable,[NSNumber numberWithInt:1],udfModuleName,uri];
                [myDB executeQuery:sql];
            }
            else
            {
                NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET enabled='%@' where moduleName='%@' and uri='%@' ",userDeFinedFieldsTable,[NSNumber numberWithInt:0],udfModuleName,uri];
                [myDB executeQuery:sql];
                
            }
        }
      
        
    }
	
}
-(void)saveEnableOnlyCustomFieldUriIntoDBWithUriArray:(NSMutableArray *)array1  forTimeoffUri:(NSString *)timesheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    
    for (int i=0; i<[array1 count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSString *udfUri=[array1 objectAtIndex:i];
        if (udfUri==nil ||[udfUri isKindOfClass:[NSNull class]])
        {
            udfUri=@"";
        }
        [dataDict setObject:udfUri forKey:@"udfUri"];
        [dataDict setObject:timesheetUri forKey:@"timeoffUri"];
        
        [myDB insertIntoTable:udfTimeoffPreferencesTable data:dataDict intoDatabase:@""];
    }
    
    
}
-(NSMutableArray *)getEnabledOnlyUdfArrayForTimeoffUri:(NSString *)timeoffUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timeoffUri='%@'",udfTimeoffPreferencesTable,timeoffUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
@end
