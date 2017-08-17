//
//  TeamTimeService.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 18/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "TeamTimeService.h"
#import "AppDelegate.h"
#import "TimesheetModel.h"
#import "LoginModel.h"
#import "RepliconServiceManager.h"

@implementation TeamTimeService
@synthesize teamTimeModel;

- (id) init
{
	self = [super init];
	if (self != nil)
    {
		if(teamTimeModel == nil)
        {
			teamTimeModel = [[TeamTimeModel alloc] init];
		}
	}
	return self;
}

#pragma mark -
#pragma mark Request Methods

/************************************************************************************************************
 @Function Name   : fetchTeamTimeSheetData
 @Purpose         : Called to get the user’s team timessheet data
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/


-(void)fetchTeamTimeSheetDataForDate:(NSDate *)date
{
    NSDictionary *dateDict=[Util convertDateToApiDateDictionary:date];
    
    NSNumber *pageNum=[NSNumber numberWithInt:1];
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"teamTimeDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:pageNum forKey:@"NextTeamTimePageNo"];
    [defaults synchronize];
    

    
     NSDictionary *textSearchDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],@"queryText",@"false",@"searchInAddressText",@"false",@"searchInAgentDisplayText",@"true",@"searchInOwnerDisplayText", nil];
    
    NSDictionary *timeSegmentSearchDict=[NSDictionary dictionaryWithObjectsAndKeys:textSearchDict,@"textSearch",@"urn:replicon:time-punch-data-access-level:supervisor",@"inDataAccessLevelUri",@"urn:replicon:time-punch-time-segment-user-filter-option:all-users",@"timePunchTimeSegmentUserFilterOption",
 nil];
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      pageNum,@"page",
                                      pageSize,@"pageSize",
                                      dateDict,@"date",
                                      timeSegmentSearchDict,@"timeSegmentSearch",
                                      nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetFirstTeamTimeData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetFirstTeamTimeData"]];
    [self setServiceDelegate:self];
    [self executeRequest];


    
    
    


}


-(void)sendEditOrAddPunchRequestServiceForDataDict:(TeamTimePunchObject *)obj editType:(NSString*)BtnClicked fromMode:(NSString *)fromMode andTimesheetURI:(NSString *)timesheetURI
{

    NSDate *dateExpires = nil;
   
    
    if ([fromMode isEqualToString:@"In"] || fromMode==nil)
    {
        dateExpires = [Util convertTimestampFromDBToDate:obj.PunchInDateTimestamp];
    }
    else if ([fromMode isEqualToString:@"Out"])
    {
        dateExpires = [Util convertTimestampFromDBToDate:obj.PunchOutDateTimestamp];
    }
    
   
    
    
    NSDateComponents *dateComponents ;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    dateComponents = [calendar components:( NSCalendarUnitYear |
                                               NSCalendarUnitMonth |
                                               NSCalendarUnitDay   |
                                               NSCalendarUnitHour |
                                               NSCalendarUnitMinute |
                                               NSCalendarUnitSecond)
                                     fromDate:dateExpires];

    
    
    NSInteger day= [dateComponents day];
    NSInteger month=[dateComponents month];
    NSInteger year=[dateComponents year];
    NSInteger hour=[dateComponents hour];
    NSInteger minute=[dateComponents minute];
    NSInteger second=[dateComponents second];
    


    
    
    NSString *activityUri = obj.activityUri;
    NSString *breakUri=obj.breakUri;
    
    id activityId=nil;
    if (activityUri==nil||[activityUri isKindOfClass:[NSNull class]]||[activityUri isEqualToString:@""] || [obj.activityName isEqualToString:RPLocalizedString(NONE_STRING, NONE_STRING)])
    {
        activityId=[NSNull null];
    }
    else
    {
        NSMutableDictionary *activityDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             obj.activityUri,@"uri",
                                             obj.activityName,@"name",
                                             nil];
        activityId=activityDict;
    }
    
    
    id breakId=nil;
    if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:@""])
    {
        breakId=[NSNull null];
    }
    else
    {
        NSMutableDictionary *breakDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             obj.breakUri,@"uri",
                                             obj.breakName,@"name",
                                             nil];
        breakId=breakDict;
    }



    id punchUri = nil;
    NSString *punchinuri = obj.punchInUri;
    NSString *punchouturi = obj.punchOutUri;
    BOOL isAddType = false;
    
    
    if ([BtnClicked isEqualToString:@"In"])
    {
        if (punchinuri!=nil && ![punchinuri isKindOfClass:[NSNull class]]) {
            punchUri = obj.punchInUri;
            
        }
        else
        {
            punchUri = [NSNull null];
            isAddType = TRUE;
        }

    }
    else if ([BtnClicked isEqualToString:@"Out"])
    {
        if(punchouturi!=nil && ![punchouturi isKindOfClass:[NSNull class]]){
            punchUri = obj.punchOutUri;
        }
        else
        {
            punchUri = [NSNull null];
            isAddType = TRUE;
        }

    }
    else if (punchinuri==nil && punchouturi==nil)
    {
        punchUri = [NSNull null];
        isAddType = TRUE;
    }
    
   
    NSString *actionUri=@"";
    if ([BtnClicked isEqualToString:@"In"])
    {
        if (obj.punchInActionUri!=nil && ![obj.punchInActionUri isKindOfClass:[NSNull class]])
        {
            actionUri=obj.punchInActionUri;
        }
        else
        {
            actionUri = PUNCH_IN_URI;
        }
        
        
    }
    else if ([BtnClicked isEqualToString:@"Out"])
    {
        if (obj.punchOutActionUri!=nil && ![obj.punchOutActionUri isKindOfClass:[NSNull class]])
        {
            actionUri=obj.punchOutActionUri;
            
        }
        else
        {
            actionUri = PUNCH_OUT_URI;
        }
        
    }
    else if ([BtnClicked isEqualToString:@"Break"])
    {
        actionUri = PUNCH_START_BREAK_URI;
    }
    else if ([BtnClicked isEqualToString:@"Transfer"])
    {
        actionUri = PUNCH_TRANSFER_URI;
    }


    
    if([actionUri isEqualToString:PUNCH_OUT_URI])
    {
        activityId = [NSNull null];
    }

    
    
    
    NSMutableDictionary *targetDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
     [NSNull null],@"parameterCorrelationId",
     punchUri,@"uri",
     [NSNull null],@"slug",
     nil];
    
    NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     obj.punchUserUri,@"uri",
                                     [NSNull null],@"loginName",
                                     [NSNull null],@"parameterCorrelationId",
                                     nil];
    
    NSMutableDictionary *punchTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:year],@"year",
                                          [NSNumber numberWithInteger:month],@"month",
                                          [NSNumber numberWithInteger:day],@"day",
                                          [NSNumber numberWithInteger:hour],@"hour",
                                          [NSNumber numberWithInteger:minute],@"minute",
                                          [NSNumber numberWithInteger:second],@"second",
                                          [NSNull null],@"timeZoneUri",
                                          nil];
    
   /* NSMutableDictionary *peojectDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNull null],@"uri",
                                     [NSNull null],@"name",
                                     nil];
    
    NSMutableDictionary *taskDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNull null],@"uri",
                                     [NSNull null],@"name",
                                     [NSNull null],@"parent",
                                     [NSNull null],@"parameterCorrelationId",
                                     nil];
    
    NSMutableDictionary *billingDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNull null],@"uri",
                                     [NSNull null],@"name",
                                     nil];*/
    
    
    id punchInAttributesDict = [NSNull null];
    
    if (activityId!=nil && ![activityId isEqual:[NSNull null]])
    {
        punchInAttributesDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 activityId,@"activity",
                                 nil];
    }
    
   
    
    bool isBreak = false;
    if (breakId!=nil &&![breakId isKindOfClass:[NSNull class]])
    {
        activityId=[NSNull null];
        isBreak = true;
    }

    
//    NSString *agentTypeUri = @"";
//    if ([obj.punchInAgent isEqualToString:@"Mobile"]) {
//        agentTypeUri = PUNCH_IN_AGENT_MOBILE_URI;
//    }
    
    
    NSString *agentURI=PUNCH_AGENT_MOBILE_URI;
    
    id cloudClockUri=[NSNull null];
    id cloudClockName=[NSNull null];
    
    if ([BtnClicked isEqualToString:@"In"])
    {
        
        if (obj.punchInAgentUri!=nil && ![obj.punchInAgentUri isKindOfClass:[NSNull class]])
        {
            agentURI=obj.punchInAgentUri;
            
            if ([obj.punchInAgentUri isEqualToString:PUNCH_AGENT_CC_URI])
            {
                if (obj.punchInAgent!=nil && ![obj.punchInAgent isKindOfClass:[NSNull class]])
                {
                    cloudClockName=obj.punchInAgent;
                }
                if (obj.punchInCloudClockUri!=nil && ![obj.punchInCloudClockUri isKindOfClass:[NSNull class]])
                {
                    cloudClockUri=obj.punchInCloudClockUri;
                }
            }
        }
    }
    
    else if ([BtnClicked isEqualToString:@"Out"])
    {
        if (obj.punchOutAgentUri!=nil && ![obj.punchOutAgentUri isKindOfClass:[NSNull class]])
        {
             agentURI=obj.punchOutAgentUri;
            
            if ([obj.punchOutAgentUri isEqualToString:PUNCH_AGENT_CC_URI])
            {
                if (obj.punchOutAgent!=nil && ![obj.punchOutAgent isKindOfClass:[NSNull class]])
                {
                    cloudClockName=obj.punchOutAgent;
                }
                if (obj.punchOutCloudClockUri!=nil && ![obj.punchOutCloudClockUri isKindOfClass:[NSNull class]])
                {
                    cloudClockUri=obj.punchOutCloudClockUri;
                }
            }
        }
    }
        
    
    
    NSMutableDictionary *timePunchAgentDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               agentURI,@"agentTypeUri",
                                               cloudClockUri,@"cloudClockUri",
                                               cloudClockName,@"cloudClockName",
                                               nil];
    
    
    
    NSMutableDictionary *punchStartBreakAttributesDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          breakId,@"breakType",
                                          nil];
    
    if (breakId==nil||[breakId isKindOfClass:[NSNull class]] || [actionUri isEqualToString:PUNCH_OUT_URI])
    {
        breakId= [NSNull null];
    }
    else
    {
        actionUri=PUNCH_START_BREAK_URI;
        breakId = punchStartBreakAttributesDict;
    }

    id latitude=@"0";
    id longitude=@"0";
    id accuracyInMetres=@"0";
    
    if ([BtnClicked isEqualToString:@"In"])
    {
//        if (obj.PunchInLatitude==nil || obj.PunchInLongitude==nil ) {
//            latitude = @"0";
//            longitude = @"0";
//        }
        if([obj.PunchInLatitude isKindOfClass:[NSNull class]] || [obj.PunchInLongitude isKindOfClass:[NSNull class]] || obj.PunchInLatitude==nil || obj.PunchInLongitude==nil )
        {
            latitude = [NSNull null];
            longitude = [NSNull null];
            accuracyInMetres = [NSNull null];
        }
        else
        {
            latitude = obj.PunchInLatitude;
            longitude = obj.PunchInLongitude;
            accuracyInMetres=obj.punchInAccuracyInMeters;
        }
    }
    else if ([BtnClicked isEqualToString:@"Out"])
    {
//        if (obj.PunchOutLatitude==nil || obj.PunchOutLongitude==nil) {
//            latitude = @"0";
//            longitude = @"0";
//        }
        if([obj.PunchOutLatitude isKindOfClass:[NSNull class]] || [obj.PunchOutLatitude isKindOfClass:[NSNull class]] || obj.PunchOutLatitude==nil || obj.PunchOutLongitude==nil)
        {
            latitude = [NSNull null];
            longitude = [NSNull null];
            accuracyInMetres = [NSNull null];
        }
        else
        {
            latitude = obj.PunchOutLatitude;
            longitude = obj.PunchOutLongitude;
            accuracyInMetres=obj.punchOutAccuracyInMeters;
        }
    }
    else
    {
        latitude =@"0";
        longitude = @"0";
        accuracyInMetres = @"0";
    }
    
    
    
    NSMutableDictionary *gpsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    latitude,@"latitudeInDegrees",
                                    longitude,@"longitudeInDegrees",
                                    accuracyInMetres,@"accuracyInMeters",
                                    nil];
    
    id geolocationDict = [NSNull null];
    
    if (![latitude isKindOfClass:[NSNull class]] && ![longitude isKindOfClass:[NSNull class]])
    {
        
        if ([BtnClicked isEqualToString:@"Out"])
        {
            geolocationDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:gpsDict,@"gps",obj.PunchOutAddress, @"address",
                               nil];
        }
        else
        {
            geolocationDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:gpsDict,@"gps",obj.PunchInAddress, @"address",
                               nil];
        }
        
    }
    
    
    
    id imageUri= nil;
    
    if ([BtnClicked isEqualToString:@"In"])
    {
        if ( obj.punchInFullSizeImageUri!=nil && ![obj.punchInFullSizeImageUri isKindOfClass:[NSNull class]]) {
            imageUri = obj.punchInFullSizeImageUri;
        }
        else
        {
            imageUri = [NSNull null];
        }
    }
    if ([BtnClicked isEqualToString:@"Out"])
    {
        if ( obj.punchOutFullSizeImageUri!=nil && ![obj.punchOutFullSizeImageUri isKindOfClass:[NSNull class]]) {
           imageUri = obj.punchOutFullSizeImageUri;
        }
        else
        {
             imageUri = [NSNull null];
        }
    }
    else
    {
         imageUri = [NSNull null];
    }
    
    
    NSMutableDictionary *imageDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           imageUri,@"imageUri",
                                           [NSNull null],@"image",
                                           nil];

    

    
    
    
    
    NSMutableDictionary *timePunchDict ;
    
    if (isAddType) {
        if (isBreak)
        {
            timePunchDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [NSNull null],@"target",
                             userDict,@"user",
                             punchTimeDict,@"punchTime",
                             actionUri,@"actionUri",
                             breakId,@"punchStartBreakAttributes",
                             timePunchAgentDict,@"timePunchAgent",
                             geolocationDict,@"geolocation",
                             imageDict,@"auditImage"
                             ,nil];
        }
        else
        {
            timePunchDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [NSNull null],@"target",
                             userDict,@"user",
                             punchTimeDict,@"punchTime",
                             actionUri,@"actionUri",
                             punchInAttributesDict,@"punchInAttributes",
                             breakId,@"punchStartBreakAttributes",
                             timePunchAgentDict,@"timePunchAgent",
                             geolocationDict,@"geolocation",
                             imageDict,@"auditImage"
                             ,nil];
        }
    }
    else if (isBreak)
    {
        timePunchDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         targetDict,@"target",
                         userDict,@"user",
                         punchTimeDict,@"punchTime",
                         actionUri,@"actionUri",
                         breakId,@"punchStartBreakAttributes",
                         timePunchAgentDict,@"timePunchAgent",
                         geolocationDict,@"geolocation",
                         imageDict,@"auditImage"
                         ,nil];
    }
    else {
        timePunchDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         targetDict,@"target",
                         userDict,@"user",
                         punchTimeDict,@"punchTime",
                         actionUri,@"actionUri",
                         punchInAttributesDict,@"punchInAttributes",
                         breakId,@"punchStartBreakAttributes",
                         timePunchAgentDict,@"timePunchAgent",
                         geolocationDict,@"geolocation",
                         imageDict,@"auditImage"
                         ,nil];
    }

    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timePunchDict,@"timePunch",
                                      [Util getRandomGUID],@"unitOfWorkId",
                                      nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"SubmitEditOrNewPunchData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"SubmitEditOrNewPunchData"]];
    [self setServiceDelegate:self];
    if (timesheetURI!=nil && ![timesheetURI isKindOfClass:[NSNull class]])
    {
        [self executeRequest:[NSDictionary dictionaryWithObject:timesheetURI forKey:@"timesheetURI"]];
    }
    else
    {
        [self executeRequest];
    }
}


-(void)deletePunchRequestServiceForPunchUri:(NSString *)uri
{
    NSMutableArray *punchUriArray = [NSMutableArray array];
    [punchUriArray addObject:uri];
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      punchUriArray,@"timePunchUris",
                                      nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"DeletePunch"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"DeletePunch"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}
/************************************************************************************************************
 @Function Name   : fetchActivityBasedOnTimesheetUri
 @Purpose         : Called to get the activity based on TimesheetUri
 @param           : timesheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchActivityWithSearchText:(NSString *)textSearch forUser:(NSString*)userUri andDelegate:(id)delegate
{
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    [timesheetModel deleteAllActivityInfoFromDBForModuleName:@"Timesheet"];
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    id searchStr;
    id searchdict;
    
    if (textSearch!=nil && ![textSearch isKindOfClass:[NSNull class]])
    {
        searchStr=textSearch;
    }
    else{
        textSearch=@"";
        searchStr=[NSNull null];
    }
    
    NSNumber *maximumResultCount=[[AppProperties getInstance] getAppPropertyFor:@"activityDownlaodCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"NextActivityPageNo"];
    [defaults synchronize];
    
    
    
    if (searchStr!=nil && ![searchStr isKindOfClass:[NSNull class]]) {
        //Implementation for US8849//JUHI
        NSMutableDictionary *activitySearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 searchStr ,@"queryText",
                                                 @"true",@"searchInDisplayText",
                                                 @"false",@"searchInName",
                                                 @"false",@"searchInDescription",
                                                 @"false",@"searchInCode",nil];
        searchdict=activitySearchDict;
    }
    else
        searchdict=[NSNull null];
    
    id userIdUri=userUri;
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [[NSNumber numberWithInt:1] stringValue],@"page",
                                      [maximumResultCount stringValue],@"pageSize",
                                      userIdUri,@"userUri",
                                      searchdict,@"textSearch",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetActivitiesForUser"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetActivitiesForUser"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
    
}
/************************************************************************************************************
 @Function Name   : fetchNextActivityBasedOnTimesheetUri
 @Purpose         : Called to get next set of activity based on TimesheetUri
 @param           : timesheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchNextActivityWithSearchText:(NSString *)textSearch forUser:(NSString*)userUri andDelegate:(id)delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    id searchStr;
    id searchdict;
    
    if (textSearch!=nil && ![textSearch isKindOfClass:[NSNull class]])
    {
        searchStr=textSearch;
    }
    else{
        textSearch=@"";
        searchStr=[NSNull null];
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int nextFetchPageNo=[[defaults objectForKey:@"NextActivityPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextActivityPageNo"];
    [defaults synchronize];
    
    NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"activityDownlaodCount"];
    
    if (searchStr!=nil && ![searchStr isKindOfClass:[NSNull class]]) {
        //Implementation for US8849//JUHI
        NSMutableDictionary *activitySearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 searchStr ,@"queryText",
                                                 @"true",@"searchInDisplayText",
                                                 @"false",@"searchInName",
                                                 @"false",@"searchInDescription",
                                                 @"false",@"searchInCode",nil];
        searchdict=activitySearchDict;
    }
    else
        searchdict=[NSNull null];
    
    
     id userIdUri=userUri;
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [pageNum stringValue],@"page",
                                      [pageSize stringValue],@"pageSize",
                                      userIdUri,@"userUri",
                                      searchdict,@"textSearch",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetActivitiesForUser"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextActivitiesForUser"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}


-(void)sendRequestToGetAuditTrialDataForUserUri:(NSString *)uri andDate:(NSDictionary *)dateDict
{
    NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     uri,@"uri",
                                     [NSNull null],@"loginName",
                                     [NSNull null],@"parameterCorrelationId",
                                     nil];
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      userDict,@"user",
                                      dateDict,@"date",
                                      nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTimePunchAuditDetailsForUserAndDate"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetTimePunchAuditDetailsForUserAndDate"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}

-(void)sendRequestToGetAuditTrialDataForPunchWithUri:(NSString *)uri 
{
    NSMutableDictionary *timePunchDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     uri,@"uri",
                                     [NSNull null],@"slug",
                                     [NSNull null],@"parameterCorrelationId",
                                     nil];
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timePunchDict,@"timePunch",
                                      nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTimePunchAuditRecordDetails"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetTimePunchAuditRecordDetails"]];
    [self setServiceDelegate:self];
    [self executeRequest];

}


#pragma mark -
#pragma mark ServiceURL Response Handling

- (void) serverDidRespondWithResponse:(id) response
{
    if (response!=nil)
    {
        
        NSDictionary *errorDict=[[response objectForKey:@"response"]objectForKey:@"error"];
        //US8906//JUHI
        if (errorDict!=nil)
        {
            BOOL isErrorThrown=FALSE;
            
            
            NSArray *notificationsArr=[[errorDict objectForKey:@"details"] objectForKey:@"notifications"];
            NSString *errorMsg=@"";
            if (notificationsArr!=nil && ![notificationsArr isKindOfClass:[NSNull class]])
            {
                for (int i=0; i<[notificationsArr count]; i++)
                {
                    
                    NSDictionary *notificationDict=[notificationsArr objectAtIndex:i];
                    if (![errorMsg isEqualToString:@""])
                    {
                        errorMsg=[NSString stringWithFormat:@"%@\n%@",errorMsg,[notificationDict objectForKey:@"displayText"]];
                        isErrorThrown=TRUE;
                    }
                    else
                    {
                        errorMsg=[NSString stringWithFormat:@"%@",[notificationDict objectForKey:@"displayText"]];
                        isErrorThrown=TRUE;
                        
                    }
                }
                
            }
            
            if (!isErrorThrown)
            {
                errorMsg=[[errorDict objectForKey:@"details"] objectForKey:@"displayText"];
                
            }
            if (errorMsg!=nil && ![errorMsg isKindOfClass:[NSNull class]])
            {
                [Util errorAlert:@"" errorMessage:errorMsg];
            }
            else
            {
                [Util errorAlert:@"" errorMessage:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE)];
                NSString *serviceURL = [response objectForKey:@"serviceURL"];
                [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE) serviceURL:serviceURL];
            }
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:AllTeamTimeRequestsServed object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:DATA_UPDATED_RECIEVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
            [[NSNotificationCenter defaultCenter]postNotificationName:EDIT_OR_ADD_DATA_RECIEVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
            [[NSNotificationCenter defaultCenter]postNotificationName:DELETE_DATA_RECIEVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
            [[NSNotificationCenter defaultCenter] postNotificationName:POST_TEAM_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"]];

        }
        else
        {
            id _serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
            if ([_serviceID intValue]== GetFirstTeamTimeData_Service_ID_101)
            {
                [self handleFirstTeamTimeServiceResponse:response];
            }
            else if ([_serviceID intValue]== SubmitEditOrNewPunchData_Service_ID_104)
            {
                [self handleEditOrNewPunchServiceResponse:response];
            }
            else if ([_serviceID intValue]== DeletePunchData_Service_ID_105)
            {
                [self handleDeletePunchServiceResponse:response];
            }
            else if ([_serviceID intValue]==GetActivitiesForUser_Service_ID_106 )
            {
                [self handleActivityBasedOnTimesheetDownload:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
                
            }
            else if ([_serviceID intValue]== GetNextActivitiesForUser_Service_ID_107)
            {
                [self handleNextActivityBasedOnTimesheetDownload:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
                
            }
            else if ([_serviceID intValue]== GetTimePunchAuditDetailsForUserAndDate_Service_ID_132)
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:AUDIT_TRIAL_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:response forKey:@"DataResponse"] ];
                
                return;
                
            }
            else if ([_serviceID intValue]== GetTimePunchAuditDetailsForPunch_Service_ID_133)
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:AUDIT_TRIAL_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:response forKey:@"DataResponse"] ];
                
                return;
                
            }
        }
        
    }
}
#pragma mark -
#pragma mark ServiceURL Error Handling
- (void) serverDidFailWithError:(NSError *) error applicationState:(ApplicateState)applicationState
{
    totalRequestsServed++;

    [[NSNotificationCenter defaultCenter] postNotificationName:AllTeamTimeRequestsServed object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:DATA_UPDATED_RECIEVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
    [[NSNotificationCenter defaultCenter]postNotificationName:EDIT_OR_ADD_DATA_RECIEVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
    [[NSNotificationCenter defaultCenter]postNotificationName:DELETE_DATA_RECIEVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    
    
}

#pragma mark -
#pragma mark Response Methods

/************************************************************************************************************
 @Function Name   : handleFirstTeamTimeServiceResponse
 @Purpose         : To save user's team time data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleFirstTeamTimeServiceResponse:(id)response
{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    NSMutableArray *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        [teamTimeModel deleteAllTeamPunchesInfoFromDB];
        [teamTimeModel deleteAllteamViewUserCapabilities];
        [teamTimeModel saveTeamTimesheetDataFromApiToDB:responseDict];
        
    }
    else  {
        [teamTimeModel deleteAllTeamPunchesInfoFromDB];
        [teamTimeModel deleteAllteamViewUserCapabilities];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:AllTeamTimeRequestsServed object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_UPDATED_RECIEVED_NOTIFICATION object:nil];
    
}

-(void)handleEditOrNewPunchServiceResponse:(id)response
{
    NSMutableArray *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EDIT_OR_ADD_DATA_RECIEVED_NOTIFICATION object:nil];
}

-(void)handleDeletePunchServiceResponse:(id)response
{
    NSMutableArray *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        //[self fetchTeamTimeSheetDataForDate:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DELETE_DATA_RECIEVED_NOTIFICATION object:nil];
}

/************************************************************************************************************
 @Function Name   : handleActivityBasedOnTimesheetDownload
 @Purpose         : To save activity details into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handleActivityBasedOnTimesheetDownload:(id)response
{
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                         forKey:@"isErrorOccured"];
    NSMutableArray *activityArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    if (activityArray!=nil && ![activityArray isKindOfClass:[NSNull class]])
    {
        
        
        NSNumber *activitiesCount=[NSNumber numberWithUnsignedInteger:[activityArray count]];
        
        LoginModel *loginModel=[[LoginModel alloc]init];
        NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];
        
        BOOL isActivitySelectionRequired = NO;
        
        if ([userDetailsArray count]!=0)
        {
            NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
            isActivitySelectionRequired =[[userDict objectForKey:@"timepunchActivitySelectionRequired"] boolValue];
        }
        if (isActivitySelectionRequired==NO)
        {
            
            NSDictionary *activitytDict= [NSDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(NONE_STRING, NONE_STRING),@"displayText",[NSNull null],@"uri", nil];
            [activityArray addObject: activitytDict];
        }
        
        if ([activityArray count]!=0)
        {
            
            [timesheetModel saveActivityDetailsDataToDB:activityArray withModuleName:@"Timesheet"];
        }
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        
        [defaults setObject:activitiesCount forKey:@"activityDataDownloadCount"];
        [defaults synchronize];
        
        dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                               forKey:@"isErrorOccured"];
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACTIVITY_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}

-(void)handleNextActivityBasedOnTimesheetDownload:(id)response
{
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    NSMutableArray *activtyArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([activtyArray count]!=0)
    {
        
        [timesheetModel saveActivityDetailsDataToDB:activtyArray withModuleName:@"Timesheet"];
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *timesheetsCount=[NSNumber numberWithUnsignedInteger:[activtyArray count]];
    [defaults setObject:timesheetsCount forKey:@"activityDataDownloadCount"];
    [defaults synchronize];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:ACTIVITY_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}




@end
