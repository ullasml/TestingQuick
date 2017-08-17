//
//  TeamTimeModel.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 18/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "TeamTimeModel.h"

@implementation TeamTimeModel

static NSString *teamViewPunchesTable=@"TeamTimePunches";
static NSString *teamViewUserCapabilities=@"TeamTimeUserCapabilities";

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

-(void)saveTeamTimesheetDataFromApiToDB:(NSMutableArray *)responseArray
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    
    
        for (int k=0; k<[responseArray count]; k++)
        {
            NSMutableDictionary *responseDict=[responseArray objectAtIndex:k];
            
            
            NSMutableArray *timeSegmentsArray=[responseDict objectForKey:@"timeSegments"];
            //NSMutableDictionary *userDict=[responseDict objectForKey:@"user"];
            if([timeSegmentsArray count] > 0)
            {

            for (int j=0; j<[timeSegmentsArray count]; j++)
            {
                NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                NSMutableDictionary *dbDict=[timeSegmentsArray objectAtIndex:j];
                
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
                
                NSMutableDictionary *punchInTime=[dbDict objectForKey:@"startPunchTime"];
                if (punchInTime!=nil && ![punchInTime isKindOfClass:[NSNull class]])
                {
                    NSDate *dateValue=[Util convertApiDictToDateFormat:punchInTime];
                    [dataDict setObject:[NSNumber numberWithDouble:[dateValue timeIntervalSince1970]] forKey:@"PunchInDateTimestamp"];
                    
                    NSString *dateStr=[Util convertApiTimeDictToDateStringWithDesiredFormat:punchInTime];
                    [dataDict setObject:dateStr forKey:@"PunchInDate"];
                    
                    NSString *timeValue=[Util convertApiTimeDictTo12HourTimeString:punchInTime];
                    [dataDict setObject:timeValue forKey:@"PunchInTime"];
                }
                
                
                
                
                //punchOutTime
                
                NSMutableDictionary *punchOutTime=[dbDict objectForKey:@"endPunchTime"];
                if (punchOutTime!=nil && ![punchOutTime isKindOfClass:[NSNull class]])
                {
                    NSDate *dateValue=[Util convertApiDictToDateFormat:punchOutTime];
                    [dataDict setObject:[NSNumber numberWithDouble:[dateValue timeIntervalSince1970]] forKey:@"PunchOutDateTimestamp"];
                    
                    NSString *dateStr=[Util convertApiTimeDictToDateStringWithDesiredFormat:punchOutTime];
                    [dataDict setObject:dateStr forKey:@"PunchOutDate"];
                    
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
                
                
                
                [myDB insertIntoTable:teamViewPunchesTable data:dataDict intoDatabase:@""];
            }
                NSMutableDictionary *timePunchCapabilitiesDict=[responseDict objectForKey:@"timePunchCapabilities"];
                NSMutableDictionary *userDict=[responseDict objectForKey:@"user"];
                
                [self saveTeamTimeUserCapabilitiesFromApiToDB:timePunchCapabilitiesDict forUserUri:[userDict objectForKey:@"uri"]];

            }
            else
            {
                NSMutableDictionary *userDict=[responseDict objectForKey:@"user"];
                NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];

                [dataDict setObject:[userDict objectForKey:@"displayText"] forKey:@"punchUserName"];
                [dataDict setObject:[userDict objectForKey:@"uri"] forKey:@"punchUserUri"];
                [myDB insertIntoTable:teamViewPunchesTable data:dataDict intoDatabase:@""];
            }
            NSMutableDictionary *timePunchCapabilitiesDict=[responseDict objectForKey:@"timePunchCapabilities"];
            NSMutableDictionary *userDict=[responseDict objectForKey:@"user"];
            
            [self saveTeamTimeUserCapabilitiesFromApiToDB:timePunchCapabilitiesDict forUserUri:[userDict objectForKey:@"uri"]];
            
        }

}


-(void)saveTeamTimeUserCapabilitiesFromApiToDB:(NSMutableDictionary *)timePunchCapabilitiesDict forUserUri:(NSString *)userUri
{
    if (timePunchCapabilitiesDict!=nil && ![timePunchCapabilitiesDict isKindOfClass:[NSNull class]])
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary  dictionary];
        
        BOOL isActivitySelectionRequired = NO;
        if ([timePunchCapabilitiesDict objectForKey:@"activitySelectionRequired"]!=nil && ![[timePunchCapabilitiesDict objectForKey:@"activitySelectionRequired"] isKindOfClass:[NSNull class]])
        {
            isActivitySelectionRequired =[[timePunchCapabilitiesDict objectForKey:@"activitySelectionRequired"] boolValue];
        }
        
        BOOL isAuditImageRequired = NO;
        if ([timePunchCapabilitiesDict objectForKey:@"auditImageRequired"]!=nil && ![[timePunchCapabilitiesDict objectForKey:@"auditImageRequired"] isKindOfClass:[NSNull class]])
        {
            isAuditImageRequired =[[timePunchCapabilitiesDict objectForKey:@"auditImageRequired"] boolValue];
        }
        
        BOOL isCanEditTimePunch = NO;
        if ([timePunchCapabilitiesDict objectForKey:@"canEditTimePunch"]!=nil && ![[timePunchCapabilitiesDict objectForKey:@"canEditTimePunch"] isKindOfClass:[NSNull class]])
        {
            isCanEditTimePunch =[[timePunchCapabilitiesDict objectForKey:@"canEditTimePunch"] boolValue];
        }
        
        BOOL isGeolocationRequired = NO;
        if ([timePunchCapabilitiesDict objectForKey:@"geolocationRequired"]!=nil && ![[timePunchCapabilitiesDict objectForKey:@"geolocationRequired"] isKindOfClass:[NSNull class]])
        {
            isGeolocationRequired =[[timePunchCapabilitiesDict objectForKey:@"geolocationRequired"] boolValue];
        }
        
        BOOL isHasActivityAccess = NO;
        if ([timePunchCapabilitiesDict objectForKey:@"hasActivityAccess"]!=nil && ![[timePunchCapabilitiesDict objectForKey:@"hasActivityAccess"] isKindOfClass:[NSNull class]])
        {
            isHasActivityAccess =[[timePunchCapabilitiesDict objectForKey:@"hasActivityAccess"] boolValue];
        }
        
        BOOL isHasBillingAccess = NO;
        if ([timePunchCapabilitiesDict objectForKey:@"hasBillingAccess"]!=nil && ![[timePunchCapabilitiesDict objectForKey:@"hasBillingAccess"] isKindOfClass:[NSNull class]])
        {
            isHasBillingAccess =[[timePunchCapabilitiesDict objectForKey:@"hasBillingAccess"] boolValue];
        }
        
        BOOL isHasBreakAccess = NO;
        if ([timePunchCapabilitiesDict objectForKey:@"hasBreakAccess"]!=nil && ![[timePunchCapabilitiesDict objectForKey:@"hasBreakAccess"] isKindOfClass:[NSNull class]])
        {
            isHasBreakAccess =[[timePunchCapabilitiesDict objectForKey:@"hasBreakAccess"] boolValue];
        }
        
        BOOL isHasClientAccess = NO;
        if ([timePunchCapabilitiesDict objectForKey:@"hasClientAccess"]!=nil && ![[timePunchCapabilitiesDict objectForKey:@"hasClientAccess"] isKindOfClass:[NSNull class]])
        {
            isHasClientAccess =[[timePunchCapabilitiesDict objectForKey:@"hasClientAccess"] boolValue];
        }
        
        BOOL isHasProjectAccess = NO;
        if ([timePunchCapabilitiesDict objectForKey:@"hasProjectAccess"]!=nil && ![[timePunchCapabilitiesDict objectForKey:@"hasProjectAccess"] isKindOfClass:[NSNull class]])
        {
            isHasProjectAccess =[[timePunchCapabilitiesDict objectForKey:@"hasProjectAccess"] boolValue];
        }
        
        BOOL isHasTimePunchAccess = NO;
        if ([timePunchCapabilitiesDict objectForKey:@"hasTimePunchAccess"]!=nil && ![[timePunchCapabilitiesDict objectForKey:@"hasTimePunchAccess"] isKindOfClass:[NSNull class]])
        {
            isHasTimePunchAccess =[[timePunchCapabilitiesDict objectForKey:@"hasTimePunchAccess"] boolValue];
        }
        
        BOOL isProjectTaskSelectionRequired = NO;
        if ([timePunchCapabilitiesDict objectForKey:@"projectTaskSelectionRequired"]!=nil && ![[timePunchCapabilitiesDict objectForKey:@"projectTaskSelectionRequired"] isKindOfClass:[NSNull class]])
        {
            isProjectTaskSelectionRequired =[[timePunchCapabilitiesDict objectForKey:@"projectTaskSelectionRequired"] boolValue];
        }
        BOOL canTransferTimePunchToTimesheet=NO;
        if ([timePunchCapabilitiesDict objectForKey:@"canTransferTimePunchToTimesheet"]!=nil && ![[timePunchCapabilitiesDict objectForKey:@"canTransferTimePunchToTimesheet"] isKindOfClass:[NSNull class]])
        {
            canTransferTimePunchToTimesheet =[[timePunchCapabilitiesDict objectForKey:@"canTransferTimePunchToTimesheet"] boolValue];
        }
        
        
        [dataDict setObject:[NSNumber numberWithBool:isActivitySelectionRequired] forKey:@"activitySelectionRequired"];
        [dataDict setObject:[NSNumber numberWithBool:isAuditImageRequired] forKey:@"auditImageRequired"];
        [dataDict setObject:[NSNumber numberWithBool:isCanEditTimePunch] forKey:@"canEditTimePunch"];
        [dataDict setObject:[NSNumber numberWithBool:isGeolocationRequired] forKey:@"geolocationRequired"];
        [dataDict setObject:[NSNumber numberWithBool:isHasActivityAccess] forKey:@"hasActivityAccess"];
        [dataDict setObject:[NSNumber numberWithBool:isHasBillingAccess] forKey:@"hasBillingAccess"];
        [dataDict setObject:[NSNumber numberWithBool:isHasBreakAccess] forKey:@"hasBreakAccess"];
        [dataDict setObject:[NSNumber numberWithBool:isHasClientAccess] forKey:@"hasClientAccess"];
        [dataDict setObject:[NSNumber numberWithBool:isHasProjectAccess] forKey:@"hasProjectAccess"];
        [dataDict setObject:[NSNumber numberWithBool:isHasTimePunchAccess] forKey:@"hasTimePunchAccess"];
        [dataDict setObject:[NSNumber numberWithBool:isProjectTaskSelectionRequired] forKey:@"projectTaskSelectionRequired"];
        [dataDict setObject:userUri forKey:@"uri"];
        [dataDict setObject:[NSNumber numberWithBool:canTransferTimePunchToTimesheet] forKey:@"canTransferTimePunchToTimesheet"];
        
        SQLiteDB *myDB = [SQLiteDB getInstance];
        NSString *whereString=[NSString stringWithFormat:@"uri = '%@' ",userUri];
        [myDB deleteFromTable:teamViewUserCapabilities where:whereString inDatabase:@""];
        [myDB insertIntoTable:teamViewUserCapabilities data:dataDict intoDatabase:@""];
    }
}


-(NSMutableArray *) getAllPunchesFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@",teamViewPunchesTable];
	NSMutableArray *timesheetsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([timesheetsArray count]>0)
    {
		return timesheetsArray;
	}
	return nil;
}

-(void)deleteAllTeamPunchesInfoFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ ",teamViewPunchesTable];
	[myDB executeQuery:query];
}

-(void)deleteAllteamViewUserCapabilities
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ ",teamViewUserCapabilities];
	[myDB executeQuery:query];
}


-(NSMutableArray *) getGroupedPunchesInfoFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *disntinctsql = [NSString stringWithFormat:@"select distinct(punchUserUri) from %@",teamViewPunchesTable];
    NSMutableArray *groupedArray=[NSMutableArray array];
    NSMutableArray *distinctUserUriArray = [myDB executeQueryToConvertUnicodeValues:disntinctsql];
    for (int i=0; i<[distinctUserUriArray count]; i++)
    {
        
        NSString *punchUserUri=[[distinctUserUriArray objectAtIndex:i] objectForKey:@"punchUserUri" ];
        
        NSMutableArray *groupedInfoArray = [myDB select:@" * " from:teamViewPunchesTable where:[NSString stringWithFormat: @" punchUserUri = '%@'",punchUserUri] intoDatabase:@""];
        
        [groupedArray addObject:groupedInfoArray];
        
    }
	if ([groupedArray count]>0)
    {
		return groupedArray;
	}
	return nil;
}

-(NSMutableArray *) getDistinctUsersFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *disntinctsql = [NSString stringWithFormat:@"select distinct(punchUserUri),punchUserName from %@",teamViewPunchesTable];
    NSMutableArray *getDistinctUsersFromDB = [myDB executeQueryToConvertUnicodeValues:disntinctsql];
    
	if ([getDistinctUsersFromDB count]>0)
    {
		return getDistinctUsersFromDB;
	}
	return nil;
}
-(NSMutableArray *) getAllTeamPunchesFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *disntinctsql = [NSString stringWithFormat:@"select * from %@",teamViewPunchesTable];
    NSMutableArray *getDistinctUsersFromDB = [myDB executeQueryToConvertUnicodeValues:disntinctsql];
    
	if ([getDistinctUsersFromDB count]>0)
    {
		return getDistinctUsersFromDB;
	}
	return nil;
}

-(NSDictionary *) getPunchFromDBWithUri:(NSString *)punchURI forActionURI:(NSString *)actionURI
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
//    NSString *sql = [NSString stringWithFormat:@"select * from %@ where punchInUri='%@' OR punchOutUri='%@'",teamViewPunchesTable,punchURI,punchURI];
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where punchInUri='%@'",teamViewPunchesTable,punchURI];
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


-(NSString *)getSumOfTotalHoursForUser:(NSString *)punchUserUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *disntinctsql = [NSString stringWithFormat:@"select sum(totalHours) from %@ where punchUserUri='%@' and breakUri ='%@'",teamViewPunchesTable,punchUserUri,@""];
    NSMutableArray *totalHoursUsersFromDB =[myDB executeQueryToConvertUnicodeValues:disntinctsql];
    if ([totalHoursUsersFromDB count]>0)
    {
        NSString *totalHrs=[[totalHoursUsersFromDB objectAtIndex:0] objectForKey:@"sum(totalHours)"];
        if (totalHrs==nil || [totalHrs isKindOfClass:[NSNull class]])
        {
            totalHrs=@"0.00";
        }
        double value=[totalHrs newDoubleValue] ;
        
       return [Util getRoundedValueFromDecimalPlaces:value withDecimalPlaces:2];
        
    }
    
    return nil;
}

-(NSMutableArray *) getDistinctActivitiesFromDBForPunchUser:(NSString *)punchUserUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *disntinctsql = [NSString stringWithFormat:@"select distinct(activityUri),activityName from %@ where punchUserUri='%@'",teamViewPunchesTable,punchUserUri];
    NSMutableArray *getDistinctUsersFromDB = [myDB executeQueryToConvertUnicodeValues:disntinctsql];
    
	if ([getDistinctUsersFromDB count]>0)
    {
		return getDistinctUsersFromDB;
	}
	return nil;
}

-(NSMutableArray *)getPunchesForPunchUserUriGroupedByActivity:(NSString *)punchUserUri forDateStr:(NSString *)dateStr
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
//    NSString *punchessql = [NSString stringWithFormat:@"select * from %@ where punchUserUri='%@' and PunchInDate='%@' and PunchOutDate='%@'order by PunchInDateTimestamp desc",teamViewPunchesTable,punchUserUri,dateStr,dateStr];
        NSString *punchessql = [NSString stringWithFormat:@"select * from %@ where punchUserUri='%@' order by PunchInDateTimestamp asc",teamViewPunchesTable,punchUserUri];//Change Ullas M L
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

-(NSMutableArray *)getAllPunchesFromDBForUser:(NSString *)punchUserUri andDate:(NSString *)dateStr
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
//    NSString *punchessql = [NSString stringWithFormat:@"select * from %@ where punchUserUri='%@' and PunchInDate='%@' and PunchOutDate='%@'order by PunchInDateTimestamp desc",teamViewPunchesTable,punchUserUri,dateStr,dateStr];
        NSString *punchessql = [NSString stringWithFormat:@"select * from %@ where punchUserUri='%@' order by PunchInDateTimestamp asc",teamViewPunchesTable,punchUserUri];//change Ullas M L
    NSMutableArray *allPunchesForUserFromDB = [myDB executeQueryToConvertUnicodeValues:punchessql];
    if ([allPunchesForUserFromDB count]>0)
    {
		return allPunchesForUserFromDB;
	}
	return nil;
}

-(NSMutableArray *)getAll_In_Out_PunchesUriFromDbforDate:(NSString *)dateStr
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *punchessql = [NSString stringWithFormat:@"select punchInUri,punchOutUri from %@",teamViewPunchesTable];
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

-(NSMutableDictionary *)getUserCapabilitiesForUserUri:(NSString *)userUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *userCapabilitiesArr= [myDB select:@" * " from:teamViewUserCapabilities where:[NSString stringWithFormat: @" uri = '%@'",userUri] intoDatabase:@""];
    if ([userCapabilitiesArr count]>0)
    {
        return [userCapabilitiesArr objectAtIndex:0];
    }
    return nil;
}

@end
