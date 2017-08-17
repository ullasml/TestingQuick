//
//  PunchHistoryService.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 5/10/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "PunchHistoryService.h"
#import "AppDelegate.h"
#import "TimesheetModel.h"
#import "LoginModel.h"
#import "RepliconServiceManager.h"
#import "SupervisorDashboardNavigationController.h"

@implementation PunchHistoryService
@synthesize punchHistoryModel;

- (id) init
{
	self = [super init];
	if (self != nil)
    {
		if(punchHistoryModel == nil)
        {
			punchHistoryModel = [[PunchHistoryModel alloc] init];
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


-(void)fetchPunchHistoryDataForDate:(NSDate *)date
{
    NSDictionary *dateDict=[Util convertDateToApiDateDictionary:date];
    
    
    NSNumber *pageNum=[NSNumber numberWithInt:1];
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"teamTimeDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:pageNum forKey:@"NextTeamTimePageNo"];
    [defaults synchronize];
    
    NSDictionary *textSearchDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],@"queryText",@"false",@"searchInAddressText",@"false",@"searchInAgentDisplayText",@"true",@"searchInOwnerDisplayText", nil];
    
    NSDictionary *timeSegmentSearchDict=[NSDictionary dictionaryWithObjectsAndKeys:textSearchDict,@"textSearch",@"urn:replicon:time-punch-data-access-level:user",@"inDataAccessLevelUri",@"urn:replicon:time-punch-time-segment-user-filter-option:all-users",@"timePunchTimeSegmentUserFilterOption", nil];
    
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

//Implementation for PUNCH-492//JUHI
/************************************************************************************************************
 @Function Name   : sendRequestToGetAllTimeSegmentsForTimesheet
 @Purpose         : Called to get the timesheet Segments data for timesheetUri
 @param           : timesheetUri,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)sendRequestToGetAllTimeSegmentsForTimesheet:(NSString *)timesheetUri WithStartDate:(NSDate *)startDate withDelegate:(id)_delegate andApprovalsModelName:(NSString *)approvalsModuleName
{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     strUserURI ,@"uri",
                                     [NSNull null],@"loginName",
                                     [NSNull null],@"parameterCorrelationId",
                                     nil];
    NSMutableDictionary *targetDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       timesheetUri ,@"uri",
                                       userDict,@"user",
                                       [NSNull null],@"date",
                                       nil];
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      targetDict ,@"target",
                                      nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Gen4GetPunchesForTimesheet"]];;
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"Gen4GetPunchesForTimesheet"]];
    [self setServiceDelegate:self];
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       timesheetUri ,@"timesheetUri",_delegate,@"navigation_type",approvalsModuleName,@"approvalsModuleName",
                                       nil];
    [self executeRequest:paramsDict];
    
    
        
}




-(void)sendEditOrAddPunchRequestServiceForDataDict:(TeamTimePunchObject *)obj editType:(NSString*)BtnClicked fromMode:(NSString *)fromMode  andTimesheetURI:(NSString *)timesheetURI
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
    
    
    NSMutableDictionary  *punchInAttributesDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   activityId,@"activity",
                                                   nil];
    
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
        if([obj.PunchInLatitude isKindOfClass:[NSNull class]] || [obj.PunchInLongitude isKindOfClass:[NSNull class]] || obj.PunchInLatitude==nil || obj.PunchInLongitude==nil)
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
    
    if (obj.punchInFullSizeImageUri!=nil||![obj.punchInFullSizeImageUri isKindOfClass:[NSNull class]]) {
        imageUri = [NSNull null];
    }
    else
    {
        imageUri = obj.punchInFullSizeImageUri;
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
            if ([BtnClicked isEqualToString:@"Out"])
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
        if ([BtnClicked isEqualToString:@"Out"])
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
        else
        {
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
            else if([_serviceID intValue]== GetAllPunchTimeSegmentsForTimesheet_Service_ID_138)
            {
                [self handleTimeSegmentsForTimesheetData:response];
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
        [punchHistoryModel deleteAllTeamPunchesInfoFromDBIsFromWidgetTimesheet:NO approvalsModule:nil];
        [punchHistoryModel savepunchHistoryDataFromApiToDB:responseDict isFromWidget:NO approvalsModule:nil andTimeSheetUri:nil];
        
    }
    else
    {
        [punchHistoryModel deleteAllTeamPunchesInfoFromDBIsFromWidgetTimesheet:NO approvalsModule:nil];
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
-(void)handleTimeSegmentsForTimesheetData:(id)response
{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableDictionary *paramsDict=[[response objectForKey:@"refDict"] objectForKey:@"params"];
        PunchHistoryModel *punchModel=[[PunchHistoryModel alloc]init];
        
        NSString *timesheetUri=nil;
        if ([paramsDict objectForKey:@"timesheetUri"]!=nil && ![[paramsDict objectForKey:@"timesheetUri"] isKindOfClass:[NSNull class]])
        {
            timesheetUri=[paramsDict objectForKey:@"timesheetUri"];
        }
        id navigationType = [paramsDict objectForKey:@"navigation_type"];
        id approvalsModelName = [paramsDict objectForKey:@"approvalsModuleName"];

        NSArray *timesheetArr = nil;

        if ([navigationType isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
             [punchModel deleteAllTeamPunchesInfoFromDBIsFromWidgetTimesheet:YES approvalsModule:approvalsModelName andtimesheetUri:timesheetUri];
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if ([approvalsModelName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                timesheetArr = [approvalsModel getTimeSheetInfoSheetIdentityForPending:timesheetUri];
            }
            else
            {
                timesheetArr = [approvalsModel getTimeSheetInfoSheetIdentityForPrevious:timesheetUri];
            }

        }
        else
        {
            [punchModel deleteAllTeamPunchesInfoFromDBIsFromWidgetTimesheet:YES approvalsModule:nil andtimesheetUri:timesheetUri];
            TimesheetModel *tsModel=[[TimesheetModel alloc]init];
            timesheetArr = [tsModel getTimeSheetInfoSheetIdentity:timesheetUri];
        }



        if (timesheetArr.count>0)
        {
            NSDictionary *timesheetDict=timesheetArr[0];

            NSDate *startDate=[Util convertTimestampFromDBToDate:[[timesheetDict objectForKey:@"startDate"] stringValue]];
            NSDate *endDate=[Util convertTimestampFromDBToDate:[[timesheetDict objectForKey:@"endDate"] stringValue]];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [df setDateFormat:@"YYYY-MM-dd"];
            NSString *timesheetStartDateStr=[df stringFromDate:startDate];
            NSString *timesheetEndDateStr=[df stringFromDate:endDate];
            [punchModel savepunchHistoryDataFromApiToDB:[responseDict objectForKey:@"timeSegments"] isFromWidget:YES approvalsModule:approvalsModelName andTimeSheetUri:timesheetUri];

            NSMutableDictionary *dict=[punchModel getSumOfTimesheetBreakHoursAndWorkHoursisFromWidgetTimesheet:YES approvalsModule:approvalsModelName startDateStr:timesheetStartDateStr endDateStr:timesheetEndDateStr];
            NSString *totalTimePunchWorkHours=[dict objectForKey:@"regularHours"];
            NSString *totalTimePunchBreakHours=[dict objectForKey:@"breakHours"];
            NSString *regularHoursChanged=nil;
            NSString *breakHoursChanged=nil;
            if ([totalTimePunchWorkHours floatValue]>=60)
            {
                int hrs=(int)[totalTimePunchWorkHours floatValue]/60;
                int mins=(int)[totalTimePunchWorkHours floatValue]%60;
                NSString *minsStr=nil;
                if (mins<10)
                {
                    minsStr=[NSString stringWithFormat:@"0%d",mins];
                }
                else
                {
                    minsStr=[NSString stringWithFormat:@"%d",mins];
                }
                float minsInDecimal=([minsStr floatValue]/60)*100;
                minsStr=[Util getRoundedValueFromDecimalPlaces:minsInDecimal withDecimalPlaces:0];
                if (minsStr.length==1)
                {
                    minsStr=[NSString stringWithFormat:@"0%@",minsStr];
                }
                regularHoursChanged=[NSString stringWithFormat:@"%d.%@",hrs,minsStr];
            }
            else
            {

                if ([totalTimePunchWorkHours floatValue]==0)
                {
                    regularHoursChanged=[NSString stringWithFormat:@"0.00"];
                }
                else
                {
                    NSString *minsStr=nil;
                    if ([totalTimePunchWorkHours floatValue]<10)
                    {
                        minsStr=[NSString stringWithFormat:@"0%d",[totalTimePunchWorkHours intValue]];
                    }
                    else
                    {
                        minsStr=[NSString stringWithFormat:@"%d",[totalTimePunchWorkHours intValue]];
                    }
                    float minsInDecimal=([totalTimePunchWorkHours floatValue]/60)*100;
                    minsStr=[Util getRoundedValueFromDecimalPlaces:minsInDecimal withDecimalPlaces:0];;
                    if (minsStr.length==1)
                    {
                        minsStr=[NSString stringWithFormat:@"0%@",minsStr];
                    }
                    regularHoursChanged=[NSString stringWithFormat:@"0.%@",minsStr];
                }

            }
            if ([totalTimePunchBreakHours floatValue]>=60)
            {
                int hrs=(int)[totalTimePunchBreakHours floatValue]/60;
                int mins=(int)[totalTimePunchBreakHours floatValue]%60;
                NSString *minsStr=nil;
                if (mins<10)
                {
                    minsStr=[NSString stringWithFormat:@"0%d",mins];
                }
                else
                {
                    minsStr=[NSString stringWithFormat:@"%d",mins];
                }
                float minsInDecimal=([minsStr floatValue]/60)*100;
                minsStr=[Util getRoundedValueFromDecimalPlaces:minsInDecimal withDecimalPlaces:0];
                if (minsStr.length==1)
                {
                    minsStr=[NSString stringWithFormat:@"0%@",minsStr];
                }
                breakHoursChanged=[NSString stringWithFormat:@"%d.%@",hrs,minsStr];
            }
            else
            {

                if ([totalTimePunchBreakHours floatValue]==0)
                {
                    breakHoursChanged=[NSString stringWithFormat:@"0.00"];
                }
                else
                {
                    NSString *minsStr=nil;
                    if ([totalTimePunchBreakHours floatValue]<10)
                    {
                        minsStr=[NSString stringWithFormat:@"0%d",[totalTimePunchBreakHours intValue]];
                    }
                    else
                    {
                        minsStr=[NSString stringWithFormat:@"%d",[totalTimePunchBreakHours intValue]];
                    }
                    float minsInDecimal=([totalTimePunchBreakHours floatValue]/60)*100;
                    minsStr=[Util getRoundedValueFromDecimalPlaces:minsInDecimal withDecimalPlaces:0];
                    if (minsStr.length==1)
                    {
                        minsStr=[NSString stringWithFormat:@"0%@",minsStr];
                    }
                    breakHoursChanged=[NSString stringWithFormat:@"0.%@",minsStr];
                }

            }
            NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
            [dataDict setObject:regularHoursChanged forKey:@"totalTimePunchWorkHours"];
            [dataDict setObject:breakHoursChanged forKey:@"totalTimePunchBreakHours"];

            NSMutableDictionary *widgetSummaryDict = nil;
            NSString *tsTableName = @"timesheets";

            if ([navigationType isKindOfClass:[SupervisorDashboardNavigationController class]])
            {
                
                ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                if ([approvalsModelName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {

                   [approvalsModel updateSummaryDataForTimesheetUri:timesheetUri withDataDict:dataDict andIsPending:TRUE];
                   widgetSummaryDict = [approvalsModel getWidgetSummaryForTimesheetUri:timesheetUri isPending:YES];
                    tsTableName = @"PendingApprovalTimesheets";
                }
                else
                {
                   [approvalsModel updateSummaryDataForTimesheetUri:timesheetUri withDataDict:dataDict andIsPending:FALSE];
                   widgetSummaryDict = [approvalsModel getWidgetSummaryForTimesheetUri:timesheetUri isPending:NO];
                     tsTableName = @"PreviousApprovalTimesheets";
                }


            }
            else
            {

                TimesheetModel *tsModel=[[TimesheetModel alloc]init];
                [tsModel updateSummaryDataForTimesheetUri:timesheetUri withDataDict:dataDict];
                widgetSummaryDict = [tsModel getWidgetSummaryForTimesheetUri:timesheetUri];
            }





            NSString *totalInOutWorkHours=[widgetSummaryDict objectForKey:@"totalInOutWorkHours"];
            NSString *totalStandardWorkHours=[widgetSummaryDict objectForKey:@"totalStandardWorkHours"];
            NSString *totaltimeOffHours=[widgetSummaryDict objectForKey:@"totalTimePunchTimeOffHours"];

            NSNumber *maxNumber = [NSNumber numberWithDouble:MAX(MAX([totalInOutWorkHours doubleValue],[regularHoursChanged doubleValue]), [totalStandardWorkHours doubleValue])];

            NSMutableDictionary *timesheetDataDict=[NSMutableDictionary dictionary];

            NSString *totalHoursInDecimalFormat=[NSString stringWithFormat:@"%f",[maxNumber newFloatValue]+[totaltimeOffHours newFloatValue]];
            NSString *hoursValue=@"";
            NSString *minsValue=@"";
            NSArray *componentsArr=[totalHoursInDecimalFormat componentsSeparatedByString:@"."];
            if ([componentsArr count]==2)
            {
                hoursValue = [componentsArr objectAtIndex:0];
                minsValue =[componentsArr objectAtIndex:1];
            }
            NSString *totalHoursStr=[NSString stringWithFormat:@"%d:%d",[hoursValue intValue],[minsValue intValue]];


            [timesheetDataDict setObject:totalHoursInDecimalFormat      forKey:@"totalDurationDecimal"];
            [timesheetDataDict setObject:totalHoursStr   forKey:@"totalDurationHour"];
            [timesheetDataDict setObject:maxNumber      forKey:@"regularDurationDecimal"];
            hoursValue=@"";
            minsValue=@"";
            componentsArr=[[NSString stringWithFormat:@"%@",maxNumber] componentsSeparatedByString:@"."];
            if ([componentsArr count]==2)
            {
                hoursValue = [componentsArr objectAtIndex:0];
                minsValue =[componentsArr objectAtIndex:1];
            }
            NSString *workingTimeHoursStr=[NSString stringWithFormat:@"%d:%d",[hoursValue intValue],[minsValue intValue]];
            [timesheetDataDict setObject:workingTimeHoursStr   forKey:@"regularDurationHour"];

            [timesheetDataDict setObject:totaltimeOffHours   forKey:@"timeoffDurationDecimal"];
            hoursValue=@"";
            minsValue=@"";
            componentsArr=[[NSString stringWithFormat:@"%@",totaltimeOffHours] componentsSeparatedByString:@"."];
            if ([componentsArr count]==2)
            {
                hoursValue = [componentsArr objectAtIndex:0];
                minsValue =[componentsArr objectAtIndex:1];
            }
            NSString *totalTimeOffHoursInHourFormat=[NSString stringWithFormat:@"%d:%d",[hoursValue intValue],[minsValue intValue]];
            [timesheetDataDict setObject:totalTimeOffHoursInHourFormat   forKey:@"timeoffDurationHour"];
            
            NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
            SQLiteDB *myDB = [SQLiteDB getInstance];
            [myDB updateTable: tsTableName data:timesheetDataDict where:whereString intoDatabase:@""];
        }


        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AllTeamTimeRequestsServed object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_UPDATED_RECIEVED_NOTIFICATION object:nil];

}

@end
