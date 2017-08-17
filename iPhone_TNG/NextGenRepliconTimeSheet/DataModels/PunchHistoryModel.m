//
//  PunchHistoryModel.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 5/10/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "PunchHistoryModel.h"

@implementation PunchHistoryModel

static NSString *punchesHistoryTable=@"PunchHistory";
static NSString *widgetPunchesHistoryTable=@"WidgetPunchHistory";
static NSString *widgetPendingPunchesHistoryTable=@"WidgetPendingPunchHistory";
static NSString *widgetPreviousPunchesHistoryTable=@"WidgetPreviousPunchHistory";
//MOBI-854//JUHI
static NSString *userDetailsTable = @"userDetails";
static NSString *newUserDetailsTable = @"newuserDetails";
#define ActivityUri @"urn:replicon:time-punch-list-column:activity"
#define AuditImageUri @"urn:replicon:time-punch-list-column:audit-image"
#define BreakTypeUri @"urn:replicon:time-punch-list-column:break-type"
#define DateTimeUri @"urn:replicon:time-punch-list-column:date-time"
#define DateTimeUtcUri @"urn:replicon:time-punch-list-column:date-time-utc"
#define GeolocationUri @"urn:replicon:time-punch-list-column:geolocation-data"
#define ProjectUri @"urn:replicon:time-punch-list-column:project"
#define TimePunchUri @"urn:replicon:time-punch-list-column:time-punch"
#define TaskUri @"urn:replicon:time-punch-list-column:task"
#define TimePunchActionUri @"urn:replicon:time-punch-list-column:time-punch-action"
#define TimePunchAgentUri @"urn:replicon:time-punch-list-column:time-punch-agent"
#define TimePunchUserUri @"urn:replicon:time-punch-list-column:user"

-(void)savepunchHistoryDataFromApiToDB:(NSMutableArray *)responseArray isFromWidget:(BOOL)isFromWidget approvalsModule:(NSString *)approvalsModule andTimeSheetUri:(NSString *)timesheetUri
{
    
    
    if (isFromWidget)
    {
        int canTransferTimePunchToTimesheet=0;//Gen4
        int canEditTimePunch=0;//Gen4
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            canEditTimePunch=1;
        }
        else
        {
            canEditTimePunch=0;
        }
        [self saveTimePunchEntryIntoDBwithCanEditTimePunch:canEditTimePunch withCanTransferTimePunchToTimesheet:canTransferTimePunchToTimesheet isWidget:YES andResponseArray:responseArray approvalsModule:approvalsModule andtimesheetUri:timesheetUri];

    }
    else
    {
        for (int k=0; k<[responseArray count]; k++)
        {
            NSMutableDictionary *responseDict=[responseArray objectAtIndex:k];
            
            NSMutableDictionary *timePunchCapabilities=[responseDict objectForKey:@"timePunchCapabilities"];
            NSMutableArray *timeSegmentsArray=[responseDict objectForKey:@"timeSegments"];
//            int canTransferTimePunchToTimesheet=[[timePunchCapabilities objectForKey:@"canTransferTimePunchToTimesheet"] intValue];
//            int canEditTimePunch=[[timePunchCapabilities objectForKey:@"canEditTimePunch"] intValue];
            
            //MOBI-854//JUHI
            
            int canEditTimePunch=0;
            
            int canTransferTimePunch=0;
            
            int canViewTimePunch=0;
            
            int activitySelectionRequired=0;
            
            int hasActivityAccess=0;
            
            int hasBreakAccess=0;
            
            
            
            if([[timePunchCapabilities objectForKey:@"activitySelectionRequired"] boolValue]==YES)
                
            {
                
                activitySelectionRequired=1;
                
            }
            
            if([[timePunchCapabilities objectForKey:@"canEditTimePunch"] boolValue]==YES)
                
            {
                
                canEditTimePunch=1;
                
            }
            
            if([[timePunchCapabilities objectForKey:@"canTransferTimePunchToTimesheet"] boolValue]==YES)
                
            {
                
                canTransferTimePunch=1;
                
            }
            
            if([[timePunchCapabilities objectForKey:@"canViewTimePunch"] boolValue]==YES)
                
            {
                
                canViewTimePunch=1;
                
            }
            
            if([[timePunchCapabilities objectForKey:@"hasActivityAccess"] boolValue]==YES)
                
            {
                
                hasActivityAccess=1;
                
            }
            
            if([[timePunchCapabilities objectForKey:@"hasBreakAccess"] boolValue]==YES)
                
            {
                
                hasBreakAccess=1;
                
            }
            
            //NSMutableDictionary *timePunchPermissionsDict=[NSMutableDictionary dictionary];
            
           
            
            
            
            NSArray *expArr = [self getUserDetailsFromDatabase];
            if ([expArr count]>0)
            {
                NSMutableDictionary *dataDict=[NSMutableDictionary dictionaryWithDictionary:[expArr objectAtIndex:0]];
                NSString *userUri=[dataDict objectForKey:@"uri"];
                [dataDict removeObjectForKey:@"timepunchActivitySelectionRequired"];
                [dataDict setObject:[NSNumber numberWithInt:activitySelectionRequired] forKey:@"timepunchActivitySelectionRequired"];
                
                
                [dataDict removeObjectForKey:@"canEditTimePunch"];
                [dataDict setObject:[NSNumber numberWithInt:canEditTimePunch] forKey:@"canEditTimePunch"];
                
                
                [dataDict removeObjectForKey:@"canTransferTimePunchToTimesheet"];
                [dataDict setObject:[NSNumber numberWithInt:canTransferTimePunch] forKey:@"canTransferTimePunchToTimesheet"];
                
                [dataDict removeObjectForKey:@"canViewTimePunch"];
                [dataDict setObject:[NSNumber numberWithInt:canViewTimePunch] forKey:@"canViewTimePunch"];
                
                [dataDict removeObjectForKey:@"hasTimepunchActivityAccess"];
                [dataDict setObject:[NSNumber numberWithInt:hasActivityAccess] forKey:@"hasTimepunchActivityAccess"];
                
                [dataDict removeObjectForKey:@"hasTimepunchBreakAccess"];
                [dataDict setObject:[NSNumber numberWithInt:hasBreakAccess] forKey:@"hasTimepunchBreakAccess"];
                
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSString *whereString=[NSString stringWithFormat:@"uri='%@'",userUri];
                [myDB updateTable:userDetailsTable data:dataDict where:whereString intoDatabase:@""];
                
                [myDB updateTable:newUserDetailsTable data:[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:canViewTimePunch] forKey:@"canViewTimePunch"] where:whereString intoDatabase:@""];
            }
            
            
            
            
            [self saveTimePunchEntryIntoDBwithCanEditTimePunch:canEditTimePunch withCanTransferTimePunchToTimesheet:canTransferTimePunch isWidget:NO andResponseArray:timeSegmentsArray approvalsModule:nil  andtimesheetUri:timesheetUri];
            
        }

    }
    
    
    
    
}
-(NSMutableArray *) getAllPunchesFromDBIsFromWidgetTimesheet:(BOOL)isWidgetTimesheet forDate:(NSString *)date approvalsModule:(NSString *)approvalsModule
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql=nil;
    if (isWidgetTimesheet)
    {
        NSString *tableName=nil;
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;
                
            }
        }
        sql = [NSString stringWithFormat:@"select * from %@ where punchDate='%@'",tableName,date];
    }
    else
    {
        sql = [NSString stringWithFormat:@"select * from %@",punchesHistoryTable];
    }
	
	NSMutableArray *timesheetsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([timesheetsArray count]>0)
    {
		return timesheetsArray;
	}
	return nil;
}

-(NSDictionary *) getPunchFromDBWithUri:(NSString *)punchURI forActionURI:(NSString *)actionURI isFromWidgetTimesheet:(BOOL)isWidgetTimesheet forDate:(NSString *)date approvalsModule:(NSString *)approvalsModule;
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql=nil;
    if (isWidgetTimesheet)
    {
        NSString *tableName=nil;
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;
                
            }
        }
        sql = [NSString stringWithFormat:@"select * from %@ where punchInUri='%@' and punchDate='%@'",tableName,punchURI,date];
    }
    else
    {
        sql = [NSString stringWithFormat:@"select * from %@ where punchInUri='%@'",punchesHistoryTable,punchURI];
    }
    
    NSMutableArray *getPunchesFromDB = [myDB executeQueryToConvertUnicodeValues:sql];
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
	if ([getPunchesFromDB count]>0)
    {
		for (NSDictionary *dict in getPunchesFromDB)
        {
            if ([actionURI isEqualToString:PUNCH_TRANSFER_URI])
            {
                if ([dict objectForKey:@"activityUri" ]!=nil && ![[dict objectForKey:@"activityUri" ] isKindOfClass:[NSNull class]])
                {
                    if (![[dict objectForKey:@"activityUri" ] isEqualToString:@""])
                    {
                        [dataDict setObject:[dict objectForKey:@"activityUri" ] forKey:@"activityUri"];
                        [dataDict setObject:[dict objectForKey:@"activityName" ] forKey:@"activityName"];
                    }
                }
            }
            if ([actionURI isEqualToString:PUNCH_START_BREAK_URI])
            {
                if ([dict objectForKey:@"breakUri" ]!=nil && ![[dict objectForKey:@"breakUri" ] isKindOfClass:[NSNull class]])
                {
                    if (![[dict objectForKey:@"breakUri" ] isEqualToString:@""])
                    {
                        [dataDict setObject:[dict objectForKey:@"breakUri" ] forKey:@"breakUri"];
                        [dataDict setObject:[dict objectForKey:@"breakName" ] forKey:@"breakName"];
                    }
                }
            }
            
            
            
        }
        
        return dataDict;
	}
	return nil;
}

-(void)deleteAllTeamPunchesInfoFromDBIsFromWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *tableName=nil;
    if (isWidgetTimesheet)
    {
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;
                
            }
        }
        
        
    }
    else
    {
        tableName=punchesHistoryTable;
       
    }
	
     NSString *query=[NSString stringWithFormat:@"delete from %@ ",tableName];
	[myDB executeQuery:query];
}

-(void)deleteAllTeamPunchesInfoFromDBIsFromWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule andtimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *tableName=nil;
    NSString *query=nil;
    if (isWidgetTimesheet)
    {
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;
                
            }
        }
        query=[NSString stringWithFormat:@"delete from %@ where timesheetUri='%@'",tableName,timesheetUri];
    }
    else
    {
        tableName=punchesHistoryTable;
        query=[NSString stringWithFormat:@"delete from %@ ",tableName];
    }
    
    [myDB executeQuery:query];
}

-(NSMutableArray *) getGroupedPunchesInfoFromDBIsFromWidgetTimesheet:(BOOL)isWidgetTimesheet forDate:(NSString *)date approvalsModule:(NSString *)approvalsModule
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *disntinctsql=nil;
    NSString *tableName=nil;
    if (isWidgetTimesheet)
    {
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;
                
            }
        }

        disntinctsql = [NSString stringWithFormat:@"select distinct(punchUserUri) from %@ where punchDate='%@'",tableName,date];
    }
    else
    {
        tableName=punchesHistoryTable;
        disntinctsql = [NSString stringWithFormat:@"select distinct(punchUserUri) from %@",punchesHistoryTable];
    }
    
    NSMutableArray *groupedArray=[NSMutableArray array];
    NSMutableArray *distinctUserUriArray = [myDB executeQueryToConvertUnicodeValues:disntinctsql];
    for (int i=0; i<[distinctUserUriArray count]; i++)
    {
        
        NSString *punchUserUri=[[distinctUserUriArray objectAtIndex:i] objectForKey:@"punchUserUri" ];
        NSString *whereString=nil;
        if (isWidgetTimesheet)
        {
            whereString=[NSString stringWithFormat: @" punchUserUri = '%@' and punchDate='%@'",punchUserUri,date];
        }
        else
        {
            whereString=[NSString stringWithFormat: @" punchUserUri = '%@'",punchUserUri];
        }
        NSMutableArray *groupedInfoArray = [myDB select:@" * " from:tableName where:whereString intoDatabase:@""];
        
        [groupedArray addObject:groupedInfoArray];
        
    }
	if ([groupedArray count]>0)
    {
		return groupedArray;
	}
	return nil;
}

-(NSMutableArray *) getDistinctUsersFromDBISFromWidgetTimesheet:(BOOL)isWidgetTimesheet forDate:(NSString *)date approvalsModule:(NSString *)approvalsModule
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *disntinctsql=nil;
    if (isWidgetTimesheet)
    {
        NSString *tableName=nil;
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;
                
            }
        }
        disntinctsql = [NSString stringWithFormat:@"select distinct(punchUserUri),punchUserName from %@ where punchDate='%@'",tableName,date];
    }
    else
    {
        disntinctsql = [NSString stringWithFormat:@"select distinct(punchUserUri),punchUserName from %@",punchesHistoryTable];
    }
    
    NSMutableArray *getDistinctUsersFromDB = [myDB executeQueryToConvertUnicodeValues:disntinctsql];
    
	if ([getDistinctUsersFromDB count]>0)
    {
		return getDistinctUsersFromDB;
	}
	return nil;
}


-(NSString *)getSumOfTotalHoursForUser:(NSString *)punchUserUri isFromWidgetTimesheet:(BOOL)isWidgetTimesheet forDate:(NSString *)date approvalsModule:(NSString *)approvalsModule
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *disntinctsql=nil;
    if (isWidgetTimesheet)
    {
        NSString *tableName=nil;
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;
                
            }
        }
        disntinctsql = [NSString stringWithFormat:@"select sum(totalHours) from %@ where punchUserUri='%@' and breakUri ='%@' and punchDate='%@'",tableName,punchUserUri,@"",date];
    }
    else
    {
        
        disntinctsql = [NSString stringWithFormat:@"select sum(totalHours) from %@ where punchUserUri='%@' and breakUri ='%@'",punchesHistoryTable,punchUserUri,@""];
    }
    
    
    NSMutableArray *totalHoursUsersFromDB =[myDB executeQueryToConvertUnicodeValues:disntinctsql];
    if ([totalHoursUsersFromDB count]>0)
    {
        NSString *totalHrs=[[totalHoursUsersFromDB objectAtIndex:0] objectForKey:@"sum(totalHours)"];
        if (totalHrs==nil || [totalHrs isKindOfClass:[NSNull class]])
        {
            totalHrs=@"0.00";
        }
        double value=[totalHrs doubleValue] ;

        
        
        return [Util getRoundedValueFromDecimalPlaces:value withDecimalPlaces:2];
    }
    
    return nil;
}
-(NSMutableDictionary *)getSumOfBreakHoursAndWorkHoursForUser:(NSString *)punchUserUri isFromWidgetTimesheet:(BOOL)isWidgetTimesheet forDate:(NSString *)date approvalsModule:(NSString *)approvalsModule
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *disntinctsql=nil;
    if (isWidgetTimesheet)
    {
        NSString *tableName=nil;
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;
                
            }
        }
        disntinctsql = [NSString stringWithFormat:@"select * from %@ where punchUserUri='%@' and punchDate='%@'",tableName,punchUserUri,date];
    }
    else
    {
        
        disntinctsql = [NSString stringWithFormat:@"select * from %@ where punchUserUri='%@'",punchesHistoryTable,punchUserUri];
    }
    
    
    NSMutableArray *allEntriesUsersFromDB =[myDB executeQueryToConvertUnicodeValues:disntinctsql];
    
    float breakHours=0;
    float regularHours=0;
    for (int n=0; n<[allEntriesUsersFromDB count]; n++)
    {
        NSMutableDictionary *dataDict=[allEntriesUsersFromDB objectAtIndex:n];
        NSString *breakUri=[dataDict objectForKey:@"breakUri"];
        
        if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:@""])
        {
            
            regularHours=regularHours+[[dataDict objectForKey:@"totalHours"] floatValue];
        }
        else
        {
            breakHours=breakHours+[[dataDict objectForKey:@"totalHours"] floatValue];
        }
    }

    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%.2f",regularHours],@"regularHours",[NSString stringWithFormat:@"%.2f",breakHours],@"breakHours", nil];
    
    
    return dict;
}


-(NSMutableArray *) getDistinctActivitiesFromDBForPunchUser:(NSString *)punchUserUri isFromWidgetTimesheet:(BOOL)isWidgetTimesheet forDate:(NSString *)date approvalsModule:(NSString *)approvalsModule
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *disntinctsql=nil;
    if (isWidgetTimesheet)
    {
        NSString *tableName=nil;
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;
                
            }
        }
         disntinctsql = [NSString stringWithFormat:@"select distinct(activityUri),activityName from %@ where punchUserUri='%@' and punchDate='%@'",tableName,punchUserUri,date];
    }
    else
    {
        disntinctsql = [NSString stringWithFormat:@"select distinct(activityUri),activityName from %@ where punchUserUri='%@'",punchesHistoryTable,punchUserUri];
    }
    
   
    NSMutableArray *getDistinctUsersFromDB = [myDB executeQueryToConvertUnicodeValues:disntinctsql];
    
	if ([getDistinctUsersFromDB count]>0)
    {
		return getDistinctUsersFromDB;
	}
	return nil;
}

-(NSMutableArray *)getPunchesForPunchUserUriGroupedByActivity:(NSString *)punchUserUri forDateStr:(NSString *)dateStr isFromWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *punchessql=nil;
    if (isWidgetTimesheet)
    {
        NSString *tableName=nil;
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;
                
            }
        }
        punchessql = [NSString stringWithFormat:@"select * from %@ where punchUserUri='%@' and punchDate='%@' order by PunchInDateTimestamp asc",tableName,punchUserUri,dateStr];
    }
    else
    {
        
        punchessql = [NSString stringWithFormat:@"select * from %@ where punchUserUri='%@' order by PunchInDateTimestamp asc",punchesHistoryTable,punchUserUri];
    }
    
    
    NSMutableArray *allPunchesForUserFromDB = [myDB executeQueryToConvertUnicodeValues:punchessql];
    NSString *previousEntryUri=nil;
    NSMutableArray *userPunchGroupedByActivity=[NSMutableArray array];
    NSMutableArray *activityArray=[NSMutableArray array];
    NSMutableArray *previousActivityArray=[NSMutableArray array];
    for (int i=0; i<[allPunchesForUserFromDB count]; i++)
    {
        NSMutableDictionary *dict=[allPunchesForUserFromDB objectAtIndex:i];
        NSString *entryActivityUri=[dict objectForKey:@"activityUri"];
        NSString *entryBreakUri=[dict objectForKey:@"breakUri"];
        NSString *entryUri=@"";
        if (entryActivityUri!=nil&&![entryActivityUri isKindOfClass:[NSNull class]]&&![entryActivityUri isEqualToString:@""])
        {
            entryUri=entryActivityUri;
        }
        else if (entryBreakUri!=nil&&![entryBreakUri isKindOfClass:[NSNull class]]&&![entryBreakUri isEqualToString:@""])
        {
            entryUri=entryBreakUri;
        }
        else
        {
            entryUri=@"";//No Activity //no break //Simple Punch
        }
        
        if ([allPunchesForUserFromDB count]>1)
        {
            if (i==[allPunchesForUserFromDB count]-1)
            {
                if ([previousEntryUri isEqualToString:entryUri])
                {
                    [activityArray removeAllObjects];
                    [activityArray addObject:[allPunchesForUserFromDB objectAtIndex:i]];
                    NSMutableArray *tempArray=[NSMutableArray array];
                    [tempArray addObjectsFromArray:previousActivityArray];
                    [tempArray addObjectsFromArray:activityArray];
                    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                    [dict setObject:[NSMutableArray arrayWithArray:tempArray] forKey:@"DataArray"];
                    
                    NSString *entryUri=@"";
                    NSString *entryName=@"";
                    NSDictionary *dataDict=[tempArray objectAtIndex:0];
                    NSString *entryTmpActivityUri=[dataDict objectForKey:@"activityUri"];
                    NSString *entryTmpActivityName=[dataDict objectForKey:@"activityName"];
                    NSString *entryTmpBreakUri=[dataDict objectForKey:@"breakUri"];
                    NSString *entryTmpBreakName=[dataDict objectForKey:@"breakName"];
                    BOOL isBreak=NO;
                    if (entryTmpActivityUri!=nil&&![entryTmpActivityUri isKindOfClass:[NSNull class]]&&![entryTmpActivityUri isEqualToString:@""])
                    {
                        entryUri=entryTmpActivityUri;
                        entryName=entryTmpActivityName;
                        isBreak=NO;
                    }
                    if (entryTmpBreakUri!=nil&&![entryTmpBreakUri isKindOfClass:[NSNull class]]&&![entryTmpBreakUri isEqualToString:@""])
                    {
                        entryUri=entryTmpBreakUri;
                        entryName=entryTmpBreakName;
                        isBreak=YES;
                    }
                    [dict setObject:entryUri forKey:@"entryUri"];
                    [dict setObject:entryName forKey:@"entryName"];
                    [dict setObject:[NSNumber numberWithBool:isBreak] forKey:@"isBreak"];
                    [userPunchGroupedByActivity addObject:dict];
                }
                else
                {
                    
                    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                    [dict setObject:[NSMutableArray arrayWithArray:activityArray] forKey:@"DataArray"];
                    
                    NSString *entryUri=@"";
                    NSString *entryName=@"";
                    NSDictionary *dataDict=[activityArray objectAtIndex:0];
                    NSString *entryTmpActivityUri=[dataDict objectForKey:@"activityUri"];
                    NSString *entryTmpActivityName=[dataDict objectForKey:@"activityName"];
                    NSString *entryTmpBreakUri=[dataDict objectForKey:@"breakUri"];
                    NSString *entryTmpBreakName=[dataDict objectForKey:@"breakName"];
                    BOOL isBreak=NO;
                    if (entryTmpActivityUri!=nil&&![entryTmpActivityUri isKindOfClass:[NSNull class]]&&![entryTmpActivityUri isEqualToString:@""])
                    {
                        entryUri=entryTmpActivityUri;
                        entryName=entryTmpActivityName;
                        isBreak=NO;
                    }
                    if (entryTmpBreakUri!=nil&&![entryTmpBreakUri isKindOfClass:[NSNull class]]&&![entryTmpBreakUri isEqualToString:@""])
                    {
                        entryUri=entryTmpBreakUri;
                        entryName=entryTmpBreakName;
                        isBreak=YES;
                    }
                    [dict setObject:entryUri forKey:@"entryUri"];
                    [dict setObject:entryName forKey:@"entryName"];
                    [dict setObject:[NSNumber numberWithBool:isBreak] forKey:@"isBreak"];
                    [userPunchGroupedByActivity addObject:dict];
                    
                    NSMutableArray *tmpArray=[NSMutableArray array];
                    [tmpArray addObject:[allPunchesForUserFromDB objectAtIndex:i]];
                    
                    NSMutableDictionary *dict1=[NSMutableDictionary dictionary];
                    [dict1 setObject:[NSMutableArray arrayWithArray:tmpArray] forKey:@"DataArray"];
                    
                    NSString *entryUri2=@"";
                    NSString *entryName2=@"";
                    
                    NSDictionary *dataDict2=[tmpArray objectAtIndex:0];
                    NSString *entryTmpActivityUri2=[dataDict2 objectForKey:@"activityUri"];
                    NSString *entryTmpActivityName2=[dataDict2 objectForKey:@"activityName"];
                    NSString *entryTmpBreakUri2=[dataDict2 objectForKey:@"breakUri"];
                    NSString *entryTmpBreakName2=[dataDict2 objectForKey:@"breakName"];
                    BOOL isBreak2=NO;
                    if (entryTmpActivityUri2!=nil&&![entryTmpActivityUri2 isKindOfClass:[NSNull class]]&&![entryTmpActivityUri2 isEqualToString:@""])
                    {
                        entryUri2=entryTmpActivityUri2;
                        entryName2=entryTmpActivityName2;
                        isBreak2=NO;
                    }
                    if (entryTmpBreakUri2!=nil&&![entryTmpBreakUri2 isKindOfClass:[NSNull class]]&&![entryTmpBreakUri2 isEqualToString:@""])
                    {
                        entryUri2=entryTmpBreakUri2;
                        entryName2=entryTmpBreakName2;
                        isBreak2=YES;
                    }
                    
                    [dict1 setObject:entryUri2 forKey:@"entryUri"];
                    [dict1 setObject:entryName2 forKey:@"entryName"];
                    [dict1 setObject:[NSNumber numberWithBool:isBreak2] forKey:@"isBreak"];
                    [userPunchGroupedByActivity addObject:dict1];
                }
                
            }
            else
            {
                if ([previousEntryUri isEqualToString:entryUri])
                {
                    [activityArray addObject:[allPunchesForUserFromDB objectAtIndex:i]];
                    previousActivityArray=[NSMutableArray arrayWithArray:activityArray];
                }
                else
                {
                    if (i==0)
                    {
                        [activityArray addObject:[allPunchesForUserFromDB objectAtIndex:i]];
                        previousActivityArray=[NSMutableArray arrayWithArray:activityArray];
                    }
                    else
                    {
                        
                        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                        [dict setObject:[NSMutableArray arrayWithArray:activityArray] forKey:@"DataArray"];
                        
                        NSString *entryUri=@"";
                        NSString *entryName=@"";
                        NSDictionary *dataDict=[activityArray objectAtIndex:0];
                        NSString *entryTmpActivityUri=[dataDict objectForKey:@"activityUri"];
                        NSString *entryTmpActivityName=[dataDict objectForKey:@"activityName"];
                        NSString *entryTmpBreakUri=[dataDict objectForKey:@"breakUri"];
                        NSString *entryTmpBreakName=[dataDict objectForKey:@"breakName"];
                        BOOL isBreak=NO;
                        if (entryTmpActivityUri!=nil&&![entryTmpActivityUri isKindOfClass:[NSNull class]]&&![entryTmpActivityUri isEqualToString:@""])
                        {
                            entryUri=entryTmpActivityUri;
                            entryName=entryTmpActivityName;
                            isBreak=NO;
                        }
                        if (entryTmpBreakUri!=nil&&![entryTmpBreakUri isKindOfClass:[NSNull class]]&&![entryTmpBreakUri isEqualToString:@""])
                        {
                            entryUri=entryTmpBreakUri;
                            entryName=entryTmpBreakName;
                            isBreak=YES;
                        }
                        [dict setObject:entryUri forKey:@"entryUri"];
                        [dict setObject:entryName forKey:@"entryName"];
                        [dict setObject:[NSNumber numberWithBool:isBreak] forKey:@"isBreak"];
                        [userPunchGroupedByActivity addObject:dict];
                        [activityArray removeAllObjects];
                        
                        [activityArray addObject:[allPunchesForUserFromDB objectAtIndex:i]];
                        previousActivityArray=[NSMutableArray arrayWithArray:activityArray];
                    }
                    
                    
                }
                
            }
            
            previousEntryUri=entryUri;
        }
        else
        {
            NSMutableDictionary *dict=[NSMutableDictionary dictionary];
            NSMutableArray *tmpArray=[NSMutableArray array];
            [tmpArray addObject:[allPunchesForUserFromDB objectAtIndex:i]];
            [dict setObject:[NSMutableArray arrayWithArray:tmpArray] forKey:@"DataArray"];
            
            NSString *entryUri=@"";
            NSString *entryName=@"";
            NSDictionary *dataDict=[tmpArray objectAtIndex:0];
            NSString *entryTmpActivityUri=[dataDict objectForKey:@"activityUri"];
            NSString *entryTmpActivityName=[dataDict objectForKey:@"activityName"];
            NSString *entryTmpBreakUri=[dataDict objectForKey:@"breakUri"];
            NSString *entryTmpBreakName=[dataDict objectForKey:@"breakName"];
            BOOL isBreak=NO;
            if (entryTmpActivityUri!=nil&&![entryTmpActivityUri isKindOfClass:[NSNull class]]&&![entryTmpActivityUri isEqualToString:@""])
            {
                entryUri=entryTmpActivityUri;
                entryName=entryTmpActivityName;
                isBreak=NO;
            }
            if (entryTmpBreakUri!=nil&&![entryTmpBreakUri isKindOfClass:[NSNull class]]&&![entryTmpBreakUri isEqualToString:@""])
            {
                entryUri=entryTmpBreakUri;
                entryName=entryTmpBreakName;
                isBreak=YES;
            }
            [dict setObject:entryUri forKey:@"entryUri"];
            [dict setObject:entryName forKey:@"entryName"];
            [dict setObject:[NSNumber numberWithBool:isBreak] forKey:@"isBreak"];
            [userPunchGroupedByActivity addObject:dict];
        }
        
        
    }
    
    return userPunchGroupedByActivity;
}

-(NSMutableArray *)getAllPunchesFromDBForUser:(NSString *)punchUserUri andDate:(NSString *)dateStr isFromWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *punchessql=nil;
    if (isWidgetTimesheet)
    {
        NSString *tableName=nil;
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;
                
            }
        }

        punchessql = [NSString stringWithFormat:@"select * from %@ where punchUserUri='%@' and punchDate='%@' order by PunchInDateTimestamp asc",tableName,punchUserUri,dateStr];
        
    }
    else
    {
        punchessql = [NSString stringWithFormat:@"select * from %@ where punchUserUri='%@' order by PunchInDateTimestamp asc",punchesHistoryTable,punchUserUri];
        
    }
    
    
    NSMutableArray *allPunchesForUserFromDB = [myDB executeQueryToConvertUnicodeValues:punchessql];
    if ([allPunchesForUserFromDB count]>0)
    {
		return allPunchesForUserFromDB;
	}
	return nil;
}


-(NSMutableArray *)getAll_In_Out_PunchesUriFromDbforDate:(NSString *)dateStr isFromWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule

{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *punchessql=nil;
    if (isWidgetTimesheet)
    {
        NSString *tableName=nil;
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;
                
            }
        }

        punchessql = [NSString stringWithFormat:@"select punchInUri,punchOutUri from %@ where punchDate='%@'",tableName,dateStr];
    }
    else
    {
        punchessql = [NSString stringWithFormat:@"select punchInUri,punchOutUri from %@",punchesHistoryTable];
    }
    
    NSMutableArray *allPunchesFromDB = [myDB executeQueryToConvertUnicodeValues:punchessql];
    if ([allPunchesFromDB count]>0)
    {
        NSMutableArray *returnedPunchesAray=[NSMutableArray array];
		for (NSDictionary *punchDict in allPunchesFromDB)
        {
            if ([punchDict objectForKey:@"punchInUri"]!=nil && ![[punchDict objectForKey:@"punchInUri"] isKindOfClass:[NSNull class]])
            {
                if (![returnedPunchesAray containsObject:[punchDict objectForKey:@"punchInUri"]])
                {
                    [returnedPunchesAray addObject:[punchDict objectForKey:@"punchInUri"]];
                }
                
            }
            
            if ([punchDict objectForKey:@"punchOutUri"]!=nil && ![[punchDict objectForKey:@"punchOutUri"] isKindOfClass:[NSNull class]])
            {
                if (![returnedPunchesAray containsObject:[punchDict objectForKey:@"punchOutUri"]])
                {
                    [returnedPunchesAray addObject:[punchDict objectForKey:@"punchOutUri"]];
                }
                
            }
        }
        
        if ([returnedPunchesAray count]>0)
        {
            return returnedPunchesAray;
        }
	}
	return nil;
}



-(void)saveTimePunchEntryIntoDBwithCanEditTimePunch:(int)canEditTimePunch withCanTransferTimePunchToTimesheet:(int)canTransferTimePunchToTimesheet isWidget:(BOOL)isFromWidget andResponseArray:(NSMutableArray *)responseArray approvalsModule:(NSString *)approvalsModule andtimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    for (int j=0; j<[responseArray count]; j++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSMutableDictionary *dbDict=[responseArray objectAtIndex:j];
        
        //activity
        
        NSMutableDictionary *activityDict=[dbDict objectForKey:@"activity"];
        if (activityDict!=nil && ![activityDict isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:[activityDict objectForKey:@"name"] forKey:@"activityName"];
            [dataDict setObject:[activityDict objectForKey:@"uri"] forKey:@"activityUri"];
            
        }
        else
        {
            [dataDict setObject:@"" forKey:@"activityName"];
            [dataDict setObject:@"" forKey:@"activityUri"];
        }
        NSMutableDictionary *breakDict=[dbDict objectForKey:@"breakType"];
        if (breakDict!=nil && ![breakDict isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:[breakDict objectForKey:@"displayText"] forKey:@"breakName"];
            [dataDict setObject:[breakDict objectForKey:@"uri"] forKey:@"breakUri"];
            
        }
        else
        {
            [dataDict setObject:@"" forKey:@"breakName"];
            [dataDict setObject:@"" forKey:@"breakUri"];
        }
        //punchInGeolocation
        NSMutableDictionary *punchInGeolocation=[dbDict objectForKey:@"startPunchGeolocation"];
        
        if (punchInGeolocation!=nil && ![punchInGeolocation isKindOfClass:[NSNull class]])
        {
            NSMutableDictionary *gpsDict=[punchInGeolocation objectForKey:@"gps"];
            if (gpsDict!=nil && ![gpsDict isKindOfClass:[NSNull class]])
            {
                
                
                if ([gpsDict objectForKey:@"latitudeInDegrees"]!=nil && ![[gpsDict objectForKey:@"latitudeInDegrees"] isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[gpsDict objectForKey:@"latitudeInDegrees"] forKey:@"PunchInLatitude"];
                }
                
                if ([gpsDict objectForKey:@"longitudeInDegrees"]!=nil && ![[gpsDict objectForKey:@"longitudeInDegrees"] isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[gpsDict objectForKey:@"longitudeInDegrees"]  forKey:@"PunchInLongitude"];
                }
                
                if ([gpsDict objectForKey:@"accuracyInMeters"]!=nil && ![[gpsDict objectForKey:@"accuracyInMeters"] isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[gpsDict objectForKey:@"accuracyInMeters"]  forKey:@"PunchInaccuracyInMeters"];
                }
                
                
            }
            NSString *geoAddress=[punchInGeolocation objectForKey:@"address"];
            if (geoAddress!=nil && ![geoAddress isKindOfClass:[NSNull class]] && ![geoAddress isEqualToString:@""])
            {
                [dataDict setObject:geoAddress forKey:@"PunchInAddress"];
            }
            
            
        }
        
        //punchOutGeolocation
        
        NSMutableDictionary *punchOutGeolocation=[dbDict objectForKey:@"endPunchGeolocation"];
        
        if (punchOutGeolocation!=nil && ![punchOutGeolocation isKindOfClass:[NSNull class]])
        {
            NSMutableDictionary *gpsDict=[punchOutGeolocation objectForKey:@"gps"];
            if (gpsDict!=nil && ![gpsDict isKindOfClass:[NSNull class]])
            {
                
                
                if ([gpsDict objectForKey:@"latitudeInDegrees"]!=nil && ![[gpsDict objectForKey:@"latitudeInDegrees"] isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[gpsDict objectForKey:@"latitudeInDegrees"] forKey:@"PunchOutLatitude"];
                }
                
                if ([gpsDict objectForKey:@"longitudeInDegrees"]!=nil && ![[gpsDict objectForKey:@"longitudeInDegrees"] isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[gpsDict objectForKey:@"longitudeInDegrees"]  forKey:@"PunchOutLongitude"];
                }
                
                if ([gpsDict objectForKey:@"accuracyInMeters"]!=nil && ![[gpsDict objectForKey:@"accuracyInMeters"] isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[gpsDict objectForKey:@"accuracyInMeters"]  forKey:@"PunchOutaccuracyInMeters"];
                }
                
            }
            NSString *geoAddress=[punchOutGeolocation objectForKey:@"address"];
            if (geoAddress!=nil && ![geoAddress isKindOfClass:[NSNull class]] && ![geoAddress isEqualToString:@""])
            {
                [dataDict setObject:geoAddress forKey:@"PunchOutAddress"];
            }
            
            
        }
        
        //punchInTime
         NSString *punchInDateStr=nil;
        NSMutableDictionary *punchInTime=[dbDict objectForKey:@"startPunchTime"];
        if (punchInTime!=nil && ![punchInTime isKindOfClass:[NSNull class]])
        {
            NSDate *dateValue=[Util convertApiDictToDateFormat:punchInTime];
            [dataDict setObject:[NSNumber numberWithDouble:[dateValue timeIntervalSince1970]] forKey:@"PunchInDateTimestamp"];
            
            NSString *dateStr=[Util convertApiTimeDictToDateStringWithDesiredFormat:punchInTime];
            [dataDict setObject:dateStr forKey:@"PunchInDate"];
            punchInDateStr=dateStr;
            NSString *timeValue=[Util convertApiTimeDictTo12HourTimeString:punchInTime];
            [dataDict setObject:timeValue forKey:@"PunchInTime"];
        }
        
        
        
        
        //punchOutTime
        NSString *punchOutDateStr=nil;
        NSMutableDictionary *punchOutTime=[dbDict objectForKey:@"endPunchTime"];
        if (punchOutTime!=nil && ![punchOutTime isKindOfClass:[NSNull class]])
        {
            NSDate *dateValue=[Util convertApiDictToDateFormat:punchOutTime];
            [dataDict setObject:[NSNumber numberWithDouble:[dateValue timeIntervalSince1970]] forKey:@"PunchOutDateTimestamp"];
            
            NSString *dateStr=[Util convertApiTimeDictToDateStringWithDesiredFormat:punchOutTime];
            [dataDict setObject:dateStr forKey:@"PunchOutDate"];
            punchOutDateStr=dateStr;
            NSString *timeValue=[Util convertApiTimeDictTo12HourTimeString:punchOutTime];
            [dataDict setObject:timeValue forKey:@"PunchOutTime"];
        }
        
        //punchInUri
        NSString *punchInUri=[dbDict objectForKey:@"startPunchUri"];
        if (punchInUri!=nil && ![punchInUri isKindOfClass:[NSNull class]] && ![punchInUri isEqualToString:@""])
        {
            [dataDict setObject:punchInUri forKey:@"punchInUri"];
        }
        
        //punchOutUri
        NSString *punchOutUri=[dbDict objectForKey:@"endPunchUri"];
        if (punchOutUri!=nil && ![punchOutUri isKindOfClass:[NSNull class]] && ![punchOutUri isEqualToString:@""])
        {
            [dataDict setObject:punchOutUri forKey:@"punchOutUri"];
        }
        
        //punchInAuditImages
        
        NSMutableArray *punchInAuditImagesArray=[dbDict objectForKey:@"startPunchAuditImages"];
        if (punchInAuditImagesArray!=nil && ![punchInAuditImagesArray isKindOfClass:[NSNull class]])
        {
            for (int i=0; i<[punchInAuditImagesArray count]; i++)
            {
                NSDictionary *imageLinkDict=[[punchInAuditImagesArray objectAtIndex:i] objectForKey:@"imageLink"] ;
                NSString *imageLink=@"";
                if (imageLinkDict!=nil && ![imageLinkDict isKindOfClass:[NSNull class]])
                {
                    imageLink=[imageLinkDict objectForKey:@"href"];
                }
                NSString *imageUri=[[punchInAuditImagesArray objectAtIndex:i] objectForKey:@"imageUri"] ;
                if (imageLink!=nil && ![imageLink isKindOfClass:[NSNull class]] && ![imageLink isEqualToString:@""]
                    &&imageUri!=nil && ![imageUri isKindOfClass:[NSNull class]] && ![imageUri isEqualToString:@""])
                {
                    if (i==0)
                    {
                        [dataDict setObject:imageLink forKey:@"punchInFullSizeImageLink"];
                        [dataDict setObject:imageUri forKey:@"punchInFullSizeImageUri"];
                    }
                    else
                    {
                        [dataDict setObject:imageLink forKey:@"punchInThumbnailSizeImageLink"];
                        [dataDict setObject:imageUri forKey:@"punchInThumbnailSizeImageUri"];
                    }
                }
                
            }
        }
        
        
        //punchOutAuditImages
        NSMutableArray *punchOutAuditImagesArray=[dbDict objectForKey:@"endPunchAuditImages"];
        if (punchOutAuditImagesArray!=nil && ![punchOutAuditImagesArray isKindOfClass:[NSNull class]])
        {
            for (int i=0; i<[punchOutAuditImagesArray count]; i++)
            {
                NSDictionary *imageLinkDict=[[punchOutAuditImagesArray objectAtIndex:i] objectForKey:@"imageLink"] ;
                NSString *imageUri=[[punchOutAuditImagesArray objectAtIndex:i] objectForKey:@"imageUri"] ;
                NSString *imageLink=@"";
                if (imageLinkDict!=nil && ![imageLinkDict isKindOfClass:[NSNull class]])
                {
                    imageLink=[imageLinkDict objectForKey:@"href"];
                }
                if (imageLink!=nil && ![imageLink isKindOfClass:[NSNull class]] && ![imageLink isEqualToString:@""]
                    &&imageUri!=nil && ![imageUri isKindOfClass:[NSNull class]] && ![imageUri isEqualToString:@""])
                {
                    if (i==0)
                    {
                        [dataDict setObject:imageLink forKey:@"punchOutFullSizeImageLink"];
                        [dataDict setObject:imageUri forKey:@"punchOutFullSizeImageUri"];
                    }
                    else
                    {
                        [dataDict setObject:imageLink forKey:@"punchOutThumbnailSizeImageLink"];
                        [dataDict setObject:imageUri forKey:@"punchOutThumbnailSizeImageUri"];
                    }
                }
                
            }
        }
        
        //MOBI- 595 JUHI
        if (punchInTime!=nil && ![punchInTime isKindOfClass:[NSNull class]]  && punchOutTime!=nil && ![punchOutTime isKindOfClass:[NSNull class]] )
        {
            NSString *hoursText=nil;
            NSDate *punchIndateValue=[Util convertApiDictToDateFormat:punchInTime];
            NSDate *punchOutdateValue=[Util convertApiDictToDateFormat:punchOutTime];
            
            NSDictionary *diffDict=[Util getDifferenceDictionaryForInTimeDate:punchIndateValue outTimeDate:punchOutdateValue];
            int hours=[[diffDict objectForKey:@"hour"] intValue];
            int minutes=[[diffDict objectForKey:@"minute"] intValue];
            
            float tmp=hours*60+minutes;
            hoursText=[NSString stringWithFormat:@"%.2f",tmp];
            [dataDict setObject:hoursText forKey:@"totalHours"];
            
        }
        else
        {
            [dataDict setObject:@"0.00" forKey:@"totalHours"];
        }
        
        
        
        
        NSString *userName=[[dbDict objectForKey:@"owner"] objectForKey:@"displayText"];
        if (userName!=nil && ![userName isKindOfClass:[NSNull class]] && ![userName isEqualToString:@""])
        {
            [dataDict setObject:userName forKey:@"punchUserName"];
        }
        NSString *userUri=[[dbDict objectForKey:@"owner"] objectForKey:@"uri"];
        if (userUri!=nil && ![userUri isKindOfClass:[NSNull class]] && ![userUri isEqualToString:@""])
        {
            [dataDict setObject:userUri forKey:@"punchUserUri"];
        }
        
        NSDictionary *punchInAgentDict=[dbDict objectForKey:@"startPunchAgent"];
        if (punchInAgentDict!=nil && ![punchInAgentDict isKindOfClass:[NSNull class]])
        {
            NSString *punchInAgent=[punchInAgentDict objectForKey:@"displayText"];
            NSString *punchInAgentURI=[punchInAgentDict objectForKey:@"agentTypeUri"];
            NSString *cloudClockUri=[punchInAgentDict objectForKey:@"uri"];
            if (punchInAgent!=nil && ![punchInAgent isKindOfClass:[NSNull class]] && ![punchInAgent isEqualToString:@""])
            {
                [dataDict setObject:punchInAgent forKey:@"punchInAgent"];
            }
            if (punchInAgentURI!=nil && ![punchInAgentURI isKindOfClass:[NSNull class]] && ![punchInAgentURI isEqualToString:@""])
            {
                [dataDict setObject:punchInAgentURI forKey:@"punchInAgentUri"];
            }
            if (cloudClockUri!=nil && ![cloudClockUri isKindOfClass:[NSNull class]] && ![cloudClockUri isEqualToString:@""])
            {
                [dataDict setObject:cloudClockUri forKey:@"cloudClockInUri"];
            }
        }
        NSDictionary *punchOutAgentDict=[dbDict objectForKey:@"endPunchAgent"];
        if (punchOutAgentDict!=nil && ![punchOutAgentDict isKindOfClass:[NSNull class]])
        {
            NSString *punchOutAgent=[punchOutAgentDict objectForKey:@"displayText"];
            NSString *punchOutAgentURI=[punchOutAgentDict objectForKey:@"agentTypeUri"];
            NSString *cloudClockUri=[punchOutAgentDict objectForKey:@"uri"];
            if (punchOutAgent!=nil && ![punchOutAgent isKindOfClass:[NSNull class]] && ![punchOutAgent isEqualToString:@""])
            {
                [dataDict setObject:punchOutAgent forKey:@"punchOutAgent"];
            }
            if (punchOutAgentURI!=nil && ![punchOutAgentURI isKindOfClass:[NSNull class]] && ![punchOutAgentURI isEqualToString:@""])
            {
                [dataDict setObject:punchOutAgentURI forKey:@"punchOutAgentUri"];
            }
            if (cloudClockUri!=nil && ![cloudClockUri isKindOfClass:[NSNull class]] && ![cloudClockUri isEqualToString:@""])
            {
                [dataDict setObject:cloudClockUri forKey:@"cloudClockOutUri"];
            }
        }
        
        if ([dbDict objectForKey:@"startPunchActionUri"]!=nil && ![[dbDict objectForKey:@"startPunchActionUri"] isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:[dbDict objectForKey:@"startPunchActionUri"] forKey:@"punchInActionUri"];
        }
        
        if ([dbDict objectForKey:@"endPunchActionUri"]!=nil && ![[dbDict objectForKey:@"endPunchActionUri"] isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:[dbDict objectForKey:@"endPunchActionUri"] forKey:@"punchOutActionUri"];
        }
        
        
        
        NSString *transferStatusUri=[dbDict objectForKey:@"timesheetTransferStatusUri"];
        if (transferStatusUri!=nil && ![transferStatusUri isKindOfClass:[NSNull class]] && ![transferStatusUri isEqualToString:@""])
        {
            
            [dataDict setObject:transferStatusUri forKey:@"timesheetTransferStatus"];
        }
        [dataDict setObject:[NSNumber numberWithInt:canTransferTimePunchToTimesheet] forKey:@"canTransferTimePunchToTimesheet"];
        [dataDict setObject:[NSNumber numberWithInt:canEditTimePunch] forKey:@"canEditTimePunch"];
        NSString *endPunchLastModificationTypeUri=[dbDict objectForKey:@"endPunchLastModificationTypeUri"];
        if (endPunchLastModificationTypeUri!=nil && ![endPunchLastModificationTypeUri isKindOfClass:[NSNull class]] && ![endPunchLastModificationTypeUri isEqualToString:@""])
        {
            
            [dataDict setObject:endPunchLastModificationTypeUri forKey:@"endPunchLastModificationTypeUri"];
        }
        NSString *startPunchLastModificationTypeUri=[dbDict objectForKey:@"startPunchLastModificationTypeUri"];
        if (startPunchLastModificationTypeUri!=nil && ![startPunchLastModificationTypeUri isKindOfClass:[NSNull class]] && ![startPunchLastModificationTypeUri isEqualToString:@""])
        {
            
            [dataDict setObject:startPunchLastModificationTypeUri forKey:@"startPunchLastModificationTypeUri"];
        }
        if (isFromWidget)
        {
            BOOL punchInDatePresent=YES;
            if (punchInDateStr==nil||[punchInDateStr isKindOfClass:[NSNull class]]||[punchInDateStr isEqualToString:@""])
            {
                punchInDatePresent=NO;
            }
            BOOL punchOutDatePresent=YES;
            if (punchOutDateStr==nil||[punchOutDateStr isKindOfClass:[NSNull class]]||[punchOutDateStr isEqualToString:@""])
            {
                punchOutDatePresent=NO;
            }
            if (punchInDatePresent)
            {
                [dataDict setObject:punchInDateStr forKey:@"punchDate"];
            }
            else if (punchOutDatePresent)
            {
                [dataDict setObject:punchOutDateStr forKey:@"punchDate"];
            }
            NSString *tableName=nil;
            if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
            {
                tableName=widgetPunchesHistoryTable;
            }
            else
            {
                if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    tableName=widgetPendingPunchesHistoryTable;
                }
                else
                {
                    tableName=widgetPreviousPunchesHistoryTable;
                    
                }
            }
            
            if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
            }

            
            
            [myDB insertIntoTable:tableName data:dataDict intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:punchesHistoryTable data:dataDict intoDatabase:@""];
        }
        
    }
}

-(NSMutableDictionary *)getSumOfTimesheetBreakHoursAndWorkHoursisFromWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule startDateStr:(NSString *)startDateStr endDateStr:(NSString *)endDateStr
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *disntinctsql=nil;
    if (isWidgetTimesheet)
    {
        NSString *tableName=nil;
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;
                
            }
        }
        disntinctsql = [NSString stringWithFormat:@"select * from %@ where punchDate BETWEEN '%@' AND '%@'",tableName,startDateStr,endDateStr];
    }
    else
    {
        
        disntinctsql = [NSString stringWithFormat:@"select * from %@ where punchDate BETWEEN '%@' AND '%@'",punchesHistoryTable,startDateStr,endDateStr];
    }
    
    
    NSMutableArray *allEntriesUsersFromDB =[myDB executeQueryToConvertUnicodeValues:disntinctsql];
    
    float breakHours=0;
    float regularHours=0;
    for (int n=0; n<[allEntriesUsersFromDB count]; n++)
    {
        NSMutableDictionary *dataDict=[allEntriesUsersFromDB objectAtIndex:n];
        NSString *breakUri=[dataDict objectForKey:@"breakUri"];
        
        if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:@""])
        {
            
            regularHours=regularHours+[[dataDict objectForKey:@"totalHours"] floatValue];
        }
        else
        {
            breakHours=breakHours+[[dataDict objectForKey:@"totalHours"] floatValue];
        }
    }
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%.2f",regularHours],@"regularHours",[NSString stringWithFormat:@"%.2f",breakHours],@"breakHours", nil];
    
    
    return dict;
}

-(void)updateTimesheetHoursInTimesheetTableWithTimesheetUri:(NSString *)timesheetUri approvalsModule:(NSString *)moduleName
{
    NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    NSString *timesheetsTableName=nil;
    NSString *punchTableName=nil;
    SQLiteDB *myDB = [SQLiteDB getInstance];
	if (moduleName==nil||[moduleName isKindOfClass:[NSNull class]]||[moduleName isEqualToString:@""])
    {
        timesheetsTableName=@"Timesheets";
        punchTableName=widgetPunchesHistoryTable;
    }
    else
    {
        if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            timesheetsTableName=@"PendingApprovalTimesheets";
            punchTableName=widgetPendingPunchesHistoryTable;
            
        }
        else
        {
            timesheetsTableName=@"PreviousApprovalTimesheets";
            punchTableName=widgetPreviousPunchesHistoryTable;
        }
        
    }
    
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@'",timesheetsTableName,timesheetUri];
    
	NSMutableArray *timeSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeSheetsArr count]!=0)
    {
        //float totalHours=[[[timeSheetsArr objectAtIndex:0] objectForKey:@"totalDurationDecimal"] newFloatValue];
        NSString *disntinctsql = [NSString stringWithFormat:@"select * from %@",punchTableName];
        NSMutableArray *allEntriesUsersFromDB =[myDB executeQueryToConvertUnicodeValues:disntinctsql];
        float punchTotalHours=0;
        for (int n=0; n<[allEntriesUsersFromDB count]; n++)
        {
            NSMutableDictionary *dataDict=[allEntriesUsersFromDB objectAtIndex:n];
            NSString *breakUri=[dataDict objectForKey:@"breakUri"];
            
            if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:@""])
            {
                
                punchTotalHours=punchTotalHours+[[dataDict objectForKey:@"totalHours"] newFloatValue];
            }
            else
            {
                //Do not add break Hours to total
            }
        }
        NSString *punchTotalINHours=[NSString stringWithFormat:@"%f",punchTotalHours/60];
        NSMutableDictionary *timesheetDataDict=[NSMutableDictionary dictionary];
        [timesheetDataDict setObject:[NSNumber numberWithDouble:[punchTotalINHours newFloatValue]] forKey:@"totalDurationDecimal"];
        [myDB updateTable:timesheetsTableName data:timesheetDataDict where:whereString intoDatabase:@""];
		
	}

    
}
//MOBI-854//JUHI
-(NSMutableArray *)getUserDetailsFromDatabase
{
    SQLiteDB *myDB  = [SQLiteDB getInstance];
    NSMutableArray *userDetailsArr = [myDB select:@"*" from:userDetailsTable where:@"" intoDatabase:@""];
    
    if (userDetailsArr != nil && [userDetailsArr count]!=0)
    {
        return userDetailsArr;
    }
    return nil;
}

-(NSMutableArray *) getAllPunchesFromDBIsFromWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql=nil;
    if (isWidgetTimesheet)
    {
        NSString *tableName=nil;
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;
                
            }
        }
        sql = [NSString stringWithFormat:@"select * from %@",tableName];
    }
    else
    {
        sql = [NSString stringWithFormat:@"select * from %@",punchesHistoryTable];
    }
    
    NSMutableArray *timesheetsArray = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([timesheetsArray count]>0)
    {
        return timesheetsArray;
    }
    return nil;
}

-(NSMutableArray *)getAllPunchesForWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule startDateStr:(NSString *)startDateStr endDateStr:(NSString *)endDateStr
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *disntinctsql=nil;
    if (isWidgetTimesheet)
    {
        NSString *tableName=nil;
        if (approvalsModule==nil||[approvalsModule isKindOfClass:[NSNull class]]||[approvalsModule isEqualToString:@""])
        {
            tableName=widgetPunchesHistoryTable;
        }
        else
        {
            if ([approvalsModule isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tableName=widgetPendingPunchesHistoryTable;
            }
            else
            {
                tableName=widgetPreviousPunchesHistoryTable;

            }
        }
        disntinctsql = [NSString stringWithFormat:@"select * from %@ where punchDate BETWEEN '%@' AND '%@'",tableName,startDateStr,endDateStr];
    }
    else
    {

        disntinctsql = [NSString stringWithFormat:@"select * from %@ where punchDate BETWEEN '%@' AND '%@'",punchesHistoryTable,startDateStr,endDateStr];
    }


    NSMutableArray *allEntriesUsersFromDB =[myDB executeQueryToConvertUnicodeValues:disntinctsql];
    if ([allEntriesUsersFromDB count]>0)
    {
        return allEntriesUsersFromDB;
    }
    return nil;
}

@end
