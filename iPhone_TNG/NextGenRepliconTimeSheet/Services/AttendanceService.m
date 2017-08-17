//
//  AttendanceService.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 3/10/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "AttendanceService.h"
#import "AppDelegate.h"
#import "TimesheetModel.h"
#import "LoginModel.h"
#import "NSString+Double_Float.h"
#import "RepliconServiceManager.h"


@implementation AttendanceService

@synthesize attendanceModel;
@synthesize timesheetModel;

- (id) init
{
	self = [super init];
	if (self != nil)
    {
		if(timesheetModel == nil) {
			timesheetModel = [[TimesheetModel alloc] init];
		}
        if(attendanceModel == nil) {
			attendanceModel = [[AttendanceModel alloc] init];
		}
        
        
	}
	return self;
}



-(void)sendRequestPunchDataToServiceForDataDict:(NSMutableDictionary *)dataDict actionType:(NSString *)punchType locationDict:(NSMutableDictionary *)locationDict withDelegate:(id)delegate
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
   
    
    NSString *projectUri=[dataDict objectForKey:@"projectUri"];
    NSString *taskUri=[dataDict objectForKey:@"taskUri"];
    NSString *activityUri=[dataDict objectForKey:@"activityUri"];;
    NSString *billingUri=[dataDict objectForKey:@"billingUri"];
    NSString *breakUri=[dataDict objectForKey:@"breakUri"];
    
    
    
    
    id projectId=nil;
    if (projectUri==nil||[projectUri isKindOfClass:[NSNull class]]||[projectUri isEqualToString:@""])
    {
        projectId=[NSNull null];
    }
    else
    {
        NSMutableDictionary *projectDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            projectUri,@"uri",
                                            [NSNull null],@"name",
                                            nil];
        projectId=projectDict;
    }
    
    id activityId=nil;
    if (activityUri==nil||[activityUri isKindOfClass:[NSNull class]]||[activityUri isEqualToString:@""])
    {
        activityId=[NSNull null];
    }
    else
    {
        NSMutableDictionary *activityDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             activityUri,@"uri",
                                             [NSNull null],@"name",
                                             nil];
        activityId=activityDict;
    }
    
    id taskId=nil;
    if (taskUri==nil||[taskUri isKindOfClass:[NSNull class]]||[taskUri isEqualToString:@""])
    {
        taskId=[NSNull null];
    }
    else
    {
        NSMutableDictionary *taskDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         taskUri,@"uri",
                                         [NSNull null],@"name",
                                         [NSNull null],@"parent",
                                         [NSNull null],@"parameterCorrelationId",
                                         nil];
        taskId=taskDict;
    }
    id billingId=nil;
    if (billingUri==nil||[billingUri isKindOfClass:[NSNull class]]||[billingUri isEqualToString:@""])
    {
        billingId=[NSNull null];
    }
    else
    {
        NSMutableDictionary *billingDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            billingUri,@"uri",
                                            [NSNull null],@"name",
                                            nil];
        billingId=billingDict;
    }
    
    id breakId=nil;
    if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:@""])
    {
        breakId=[NSNull null];
    }
    else
    {
        NSMutableDictionary *breakDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          breakUri,@"uri",
                                          [NSNull null],@"name",
                                          nil];
        breakId=breakDict;
    }
    
    
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     strUserURI,@"uri",
                                     [NSNull null],@"loginName",
                                     nil];
    
    BOOL  isLocationenabled = [[locationDict objectForKey:@"available"] boolValue];
    float latitude=[[[locationDict objectForKey:@"LOCATION_INFO_DICT"] objectForKey:@"lat"]newFloatValue];
    float longitude=[[[locationDict objectForKey:@"LOCATION_INFO_DICT"] objectForKey:@"lng"]newFloatValue];
    NSMutableDictionary *gpsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithFloat:latitude],@"latitudeInDegrees",
                                    [NSNumber numberWithFloat:longitude],@"longitudeInDegrees",
                                    [NSNumber numberWithFloat:100],@"accuracyInMeters",
                                    nil];
    
    id address=[NSNull null];
    if (isLocationenabled)
    {
        address=[locationDict objectForKey:@"LOCATION_INFO_STRING"];
        if (address!=nil && ![address isEqualToString:@""])
        {
            address=[locationDict objectForKey:@"LOCATION_INFO_STRING"];
        }
        else
        {
            address=[NSNull null];
        }
    }
    
    
    NSMutableDictionary *geolocationDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:gpsDict,@"gps",address,@"address",
                                            nil];
    
    
    
    id geoLocation=nil;
    if (isLocationenabled == true)
    {
        geoLocation=geolocationDict;
    }
    else
    {
        geoLocation=[NSNull null];
    }
    
    
    
    
    
    NSMutableDictionary *punchInAttributesDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  activityId,@"activity",
                                                  projectId,@"project",
                                                  taskId,@"task",
                                                  billingId,@"billingRate",
                                                  breakId,@"breakType",
                                                nil];
    
   
    
    
    NSString *userImageData=[dataDict objectForKey:@"imageData"];
    id auditImage=[NSNull null];
    if (userImageData!=nil && ![userImageData isKindOfClass:[NSNull class]])
    {
        NSMutableDictionary *receiptImageDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 userImageData,@"base64ImageData",
                                                 @"image/jpeg",@"mimeType",
                                                 nil];
        auditImage=receiptImageDict;
    }

    NSMutableDictionary *timePunchDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          userDict,@"user",
                                          geoLocation,@"geolocation",
                                          auditImage,@"auditImage",
                                          nil];
    
    if ([punchType isEqualToString:PUNCH_START_BREAK_URI])
    {
        [timePunchDict setObject:punchInAttributesDict forKey:@"punchStartBreakAttributes"];
    }
    else
    {
         [timePunchDict setObject:punchInAttributesDict forKey:@"punchInAttributes"];
    }
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timePunchDict,@"timePunch",
                                      [Util getRandomGUID],@"unitOfWorkId",
                                      nil];
    
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    
    NSString *serviceIDStr=nil;
    
    if ([punchType isEqualToString:PUNCH_IN_URI])
    {
        serviceIDStr=@"Attendance_TimePunchIn";
    }
    else if ([punchType isEqualToString:PUNCH_OUT_URI])
    {
        serviceIDStr=@"Attendance_TimePunchOut";
    }
    else if ([punchType isEqualToString:PUNCH_TRANSFER_URI])
    {
        serviceIDStr=@"Attendance_TimeTransfer";
    }
    else if ([punchType isEqualToString:PUNCH_START_BREAK_URI])
    {
        serviceIDStr=@"Attendance_PunchStartBreak";
    }
    
    
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:serviceIDStr]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"Attendance_PutTimePunch"]];
    [self setServiceDelegate:delegate];
    [self executeRequest];
}



/************************************************************************************************************
 @Function Name   : fetchFirstClientsAndProjectsForTimesheetUri
 @Purpose         : Called to get the clients and projects for timesheet with uri
 @param           : timesheetUri,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchFirstClientsAndProjectsWithClientSearchText:(NSString *)clientText withProjectSearchText:(NSString *)projectText andDelegate:(id)delegate
{
    [timesheetModel deleteAllClientsInfoFromDBForModuleName:@"Timesheet"];
    [timesheetModel deleteAllProjectsInfoFromDBForModuleName:@"Timesheet"];
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *timesheetsCount=[NSNumber numberWithInt:1];
    [defaults setObject:timesheetsCount forKey:@"NextClientDownloadPageNo"];
    [defaults setObject:timesheetsCount forKey:@"NextProjectDownloadPageNo"];
    [defaults synchronize];
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    
    NSMutableDictionary *queryDict=nil;
    if (clientText==nil && projectText==nil)
    {
        queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     [NSNull null],@"projectTextSearch",
                     [NSNull null],@"clientTextSearch",
                     pageSize,@"maximumResultCount",nil];
    }
    else
    {//Implementation for US8849//JUHI
        NSMutableDictionary *clientSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               clientText ,@"queryText",
                                               @"true",@"searchInDisplayText",
                                               @"false",@"searchInName",
                                               @"false",@"searchInComment",
                                               @"false",@"searchInCode",nil];
        NSMutableDictionary *projectSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                projectText ,@"queryText",
                                                @"true",@"searchInDisplayText",
                                                @"false",@"searchInName",
                                                @"false",@"searchInDescription",
                                                @"false",@"searchInCode",nil];
        
        queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     projectSearchDict,@"projectTextSearch",
                     clientSearchDict,@"clientTextSearch",
                     pageSize,@"maximumResultCount",nil];
    }
    
    
    
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Attendance_GetFirstClientsOrProjects"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetFirstClientsOrProjects"]];
    [self setServiceDelegate:self];
    if (clientText==nil) {
        clientText=@"";
    }
    [self executeRequest:clientText];
    
    
    
}

/************************************************************************************************************
 @Function Name   : fetchFirstClientsWithSearchText
 @Purpose         : Called to get the clients for timesheet with uri for search text
 @param           : timesheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchFirstClientsWithSearchText:(NSString *)textSearch andDelegate:(id)delegate
{
    [timesheetModel deleteAllClientsInfoFromDBForModuleName:@"Timesheet"];
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *pageNum=[NSNumber numberWithInt:1];
    int nextFetchPageNo=[pageNum intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo];
    [defaults setObject:nextFetchPageNumber forKey:@"NextClientDownloadPageNo"];
    [defaults synchronize];
    
    if (textSearch==nil||[textSearch isKindOfClass:[NSNull class]]||[textSearch isEqualToString:@""])
    {
        textSearch=@"";
    }
    //Implementation for US8849//JUHI
    NSMutableDictionary *textSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         textSearch ,@"queryText",
                                         @"true",@"searchInDisplayText",
                                         @"false",@"searchInName",
                                         @"false",@"searchInComment",
                                         @"false",@"searchInCode",nil];
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      pageNum,@"page",
                                      pageSize,@"pageSize",
                                      textSearchDict,@"textSearch",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Attendance_GetClients"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetFirstClients"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}



-(void)sendRequestToGetLastPunchDataToServiceForuserUri:(NSString *)userUri
{
    NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      userUri,@"uri",
                                      [NSNull null],@"loginName",
                                      [NSNull null],@"parameterCorrelationId",nil];

    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      userDict,@"user",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"LastPunchData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"LastPunchData"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}

/************************************************************************************************************
 @Function Name   : fetchFirstProjectsWithSearchText
 @Purpose         : Called to get the projects for timesheet with uri for search text
 @param           : timesheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchFirstProjectsWithSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate
{
    [timesheetModel deleteAllProjectsInfoFromDBForModuleName:@"Timesheet"];
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *timesheetsCount=[NSNumber numberWithInt:1];
    [defaults setObject:timesheetsCount forKey:@"NextProjectDownloadPageNo"];
    [defaults synchronize];
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    NSNumber *pageNum=[NSNumber numberWithInt:0];
    if (textSearch==nil||[textSearch isKindOfClass:[NSNull class]]||[textSearch isEqualToString:@""])
    {
        textSearch=@"";
    }
    //Implementation for US8849//JUHI
    NSMutableDictionary *textSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         textSearch ,@"queryText",
                                         @"true",@"searchInDisplayText",
                                         @"false",@"searchInName",
                                         @"false",@"searchInDescription",
                                         @"false",@"searchInCode",nil];
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      pageNum,@"page",
                                      pageSize,@"pageSize",
                                      [NSNull null],@"clientUri",
                                      textSearchDict,@"textSearch",
                                      pageSize,@"maximumResultCount",nil];
    
    
    
    
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Attendance_GetProjects"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetFirstProjects"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}


/************************************************************************************************************
 @Function Name   : fetchNextClientsForTimesheetUri
 @Purpose         : Called to get the clients for timesheet with uri for search text
 @param           : timesheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchNextClientsWithSearchText:(NSString *)textSearch andDelegate:(id)delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int nextFetchPageNo=[[defaults objectForKey:@"NextClientDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextClientDownloadPageNo"];
    [defaults synchronize];
    
    NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
    //Implementation for US8849//JUHI
    NSMutableDictionary *clientSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           textSearch ,@"queryText",
                                           @"true",@"searchInDisplayText",
                                           @"false",@"searchInName",
                                           @"false",@"searchInComment",
                                           @"false",@"searchInCode",nil];
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      pageNum,@"page",
                                      pageSize,@"pageSize",
                                      clientSearchDict,@"textSearch",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetNextClients"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextClients"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}

/************************************************************************************************************
 @Function Name   : fetchNextProjectsForTimesheetUri
 @Purpose         : Called to get the projects for timesheet with uri for search text
 @param           : timesheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchNextProjectsWithSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int nextFetchPageNo=[[defaults objectForKey:@"NextProjectDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextProjectDownloadPageNo"];
    [defaults synchronize];
    
    NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
    //Implementation for US8849//JUHI
    NSMutableDictionary *projectSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            textSearch ,@"queryText",
                                            @"true",@"searchInDisplayText",
                                            @"false",@"searchInName",
                                            @"false",@"searchInDescription",
                                            @"false",@"searchInCode",nil];
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      pageNum,@"page",
                                      pageSize,@"pageSize",
                                      projectSearchDict,@"textSearch",
                                      clientUri,@"clientUri",nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Attendance_GetProjects"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextProjects"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}

/************************************************************************************************************
 @Function Name   : fetchProjectsBasedOnclientsForTimesheetUri
 @Purpose         : Called to get the projects based on clients with client uri
 @param           : timesheetUri,textSearch,clientUri,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchNextProjectsBasedOnclientsWithSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int nextFetchPageNo=[[defaults objectForKey:@"NextProjectDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextProjectDownloadPageNo"];
    [defaults synchronize];
    //Implementation for US8849//JUHI
    NSMutableDictionary *projectSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            textSearch ,@"queryText",
                                            @"true",@"searchInDisplayText",
                                            @"false",@"searchInName",
                                            @"false",@"searchInDescription",
                                            @"false",@"searchInCode",nil];
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      nextFetchPageNumber,@"page",
                                      pageSize,@"pageSize",
                                      clientUri,@"clientUri",
                                      projectSearchDict,@"textSearch",nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetNextProjects"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextProjectsBasedOnClients"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}

/************************************************************************************************************
 @Function Name   : fetchProjectsBasedOnclientsForTimesheetUri
 @Purpose         : Called to get the projects based on clients with client uri
 @param           : timesheetUri,textSearch,clientUri,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchProjectsBasedOnclientsWithSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate
{
    [timesheetModel deleteAllProjectsInfoFromDBForModuleName:@"Timesheet"];
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    if (textSearch==nil) {
        textSearch=@"";
    }
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:1];
    //Implementation for US8849//JUHI
    NSMutableDictionary *projectSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            textSearch ,@"queryText",
                                            @"true",@"searchInDisplayText",
                                            @"false",@"searchInName",
                                            @"false",@"searchInDescription",
                                            @"false",@"searchInCode",nil];
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      nextFetchPageNumber,@"page",
                                      pageSize,@"pageSize",
                                      clientUri,@"clientUri",
                                      projectSearchDict,@"textSearch",nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Attendance_GetProjects"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetProjectsBasedOnClient"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}

/************************************************************************************************************
 @Function Name   : fetchTasksBasedOnProjectsForTimesheetUri
 @Purpose         : Called to get the tasks based on projects with project uri
 @param           : timesheetUri,textSearch,projectUri,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchTasksBasedOnProjectsWithSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri andDelegate:(id)delegate
{
    [timesheetModel deleteAllTasksInfoFromDBForModuleName:@"Timesheet"];
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    if (textSearch==nil) {
        textSearch=@"";
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *pageCount=[NSNumber numberWithInt:1];
    [defaults setObject:pageCount forKey:@"NextTaskDownloadPageNo"];
    [defaults synchronize];
    
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    //Implementation for US8849//JUHI
    NSMutableDictionary *taskSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         textSearch ,@"queryText",
                                         @"true",@"searchInDisplayText",
                                         @"false",@"searchInFullPathDisplayText",
                                         @"false",@"searchInName",
                                         @"false",@"searchInDescription",
                                         @"false",@"searchInCode",nil];
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      pageCount,@"page",
                                      pageSize,@"pageSize",
                                      projectUri,@"projectUri",
                                      taskSearchDict,@"textSearch",nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Attendance_GetTasks"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetFirstTasks"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}


/************************************************************************************************************
 @Function Name   : fetchNextTasksBasedOnProjectsForTimesheetUri
 @Purpose         : Called to get the tasks based on projects with project uri
 @param           : timesheetUri,textSearch,projectUri,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchNextTasksBasedOnProjectsWithSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri andDelegate:(id)delegate

{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    int nextFetchPageNo=[[defaults objectForKey:@"NextTaskDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextTaskDownloadPageNo"];
    [defaults synchronize];
    
    NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    //Implementation for US8849//JUHI
    NSMutableDictionary *taskSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         textSearch ,@"queryText",
                                         @"true",@"searchInDisplayText",
                                         @"false",@"searchInFullPathDisplayText",
                                         @"false",@"searchInName",
                                         @"false",@"searchInDescription",
                                         @"false",@"searchInCode",nil];
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      pageNum,@"page",
                                      pageSize,@"pageSize",
                                      projectUri,@"projectUri",
                                      taskSearchDict,@"textSearch",nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetNextTasks"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextTasks"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
    
}

/************************************************************************************************************
 @Function Name   : fetchBreakForTimesheetUri
 @Purpose         : Called to get the break
 @param           : timesheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchBreakWithSearchText:(NSString *)textSearch andDelegate:(id)delegate
{
    [timesheetModel deleteAllBreakInfoFromDB];
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    id searchStr;
    id searchdict;
    
    
    NSNumber *maximumResultCount=[[AppProperties getInstance] getAppPropertyFor:@"breakDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"NextBreakPageNo"];
    [defaults synchronize];
    if (textSearch!=nil && ![textSearch isKindOfClass:[NSNull class]])
    {
        searchStr=textSearch;
    }
    else
        searchStr=[NSNull null];
    if (searchStr!=nil && ![searchStr isKindOfClass:[NSNull class]]) {
        NSMutableDictionary *breakSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              searchStr ,@"queryText",
                                              @"true",@"searchInDisplayText",
                                              @"false",@"searchInName",nil];
        searchdict=breakSearchDict;
    }
    else
        searchdict=[NSNull null];
    
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [maximumResultCount stringValue],@"maximumResultCount",
                                      searchdict,@"textSearch",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetBreakData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetBreakData"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
    
}
/************************************************************************************************************
 @Function Name   : fetchNextBreakForTimesheetUri
 @Purpose         : Called to get next set of break
 @param           : timesheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchNextBreakWithSearchText:(NSString *)textSearch andDelegate:(id)delegate
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
    else
        searchStr=[NSNull null];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int nextFetchPageNo=[[defaults objectForKey:@"NextBreakPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextBreakPageNo"];
    [defaults synchronize];
    
    NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"breakDownloadCount"];
    
    if (searchStr!=nil && ![searchStr isKindOfClass:[NSNull class]]) {
        NSMutableDictionary *breakSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              searchStr ,@"queryText",
                                              @"true",@"searchInDisplayText",
                                              @"false",@"searchInName",nil];
        searchdict=breakSearchDict;
    }
    else
        searchdict=[NSNull null];
    
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [pageNum stringValue],@"page",
                                      [pageSize stringValue],@"pageSize",
                                      searchdict,@"textSearch",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetNextBreakData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextBreakData"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
    
}

/************************************************************************************************************
 @Function Name   : fetchBillingRateBasedOnProjectForTimesheetUri
 @Purpose         : Called to get the billing rate based on project with project uri
 @param           : timesheetUri,textSearch,projectUri,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchBillingRateBasedOnProjectWithSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri taskUri:(NSString*)taskUri andDelegate:(id)delegate
{
    [timesheetModel deleteAllBillingInfoFromDBForModuleName:@"Timesheet"];
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    id taskStr;
    id searchStr;
    id searchdict;
    
    if (taskUri!=nil && ![taskUri isKindOfClass:[NSNull class]]&&![taskUri isEqualToString:@"null"])
    {
        taskStr =taskUri;
    }
    else
        taskStr=[NSNull null];
    if (textSearch!=nil && ![textSearch isKindOfClass:[NSNull class]])
    {
        searchStr=textSearch;
    }
    else{
        textSearch=@"";
        searchStr=[NSNull null];
    }
    
    NSNumber *maximumResultCount=[[AppProperties getInstance] getAppPropertyFor:@"billingRateDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"NextBillingRatePageNo"];
    [defaults synchronize];
    
    if (searchStr!=nil && ![searchStr isKindOfClass:[NSNull class]]) {
        NSMutableDictionary *billingSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                searchStr ,@"queryText",
                                                @"true",@"searchInName",
                                                @"false",@"searchInDescription",nil];
        searchdict=billingSearchDict;
    }
    else
        searchdict=[NSNull null];
    
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [[NSNumber numberWithInt:1] stringValue],@"page",
                                      [maximumResultCount stringValue],@"pageSize",
                                      projectUri,@"projectUri",
                                      searchdict,@"textSearch",
                                      taskStr,@"taskUri",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Attendance_GetBilling"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetBillingData"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
    
}
/************************************************************************************************************
 @Function Name   : fetchNextBillingRateBasedOnProjectForTimesheetUri
 @Purpose         : Called to get next set of the billing rate based on project with project uri
 @param           : timesheetUri,textSearch,projectUri,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchNextBillingRateBasedOnProjectWithSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri taskUri:(NSString*)taskUri andDelegate:(id)delegate
{
    //[timesheetModel deleteAllTasksInfoFromDBForModuleName:@"Timesheet"];
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    id taskStr;
    id searchStr;
    id searchdict;
    
    if (taskUri!=nil && ![taskUri isKindOfClass:[NSNull class]]&&![taskUri isEqualToString:@"null"])
    {
        taskStr =taskUri;
    }
    else
        taskStr=[NSNull null];
    if (textSearch!=nil && ![textSearch isKindOfClass:[NSNull class]])
    {
        searchStr=textSearch;
    }
    else
        searchStr=[NSNull null];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int nextFetchPageNo=[[defaults objectForKey:@"NextBillingRatePageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextBillingRatePageNo"];
    [defaults synchronize];
    
    NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"billingRateDownloadCount"];
    
    if (searchStr!=nil && ![searchStr isKindOfClass:[NSNull class]]) {
        NSMutableDictionary *billingSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                searchStr ,@"queryText",
                                                @"true",@"searchInName",
                                                @"false",@"searchInDescription",nil];
        searchdict=billingSearchDict;
    }
    else
        searchdict=[NSNull null];
    
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [pageNum stringValue],@"page",
                                      [pageSize stringValue],@"pageSize",
                                      projectUri,@"projectUri",
                                      searchdict,@"textSearch",
                                      taskStr,@"taskUri",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Attendance_GetBilling"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextBillingData"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
    
}
/************************************************************************************************************
 @Function Name   : fetchActivityBasedOnTimesheetUri
 @Purpose         : Called to get the activity based on TimesheetUri
 @param           : timesheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchActivityWithSearchText:(NSString *)textSearch andDelegate:(id)delegate
{
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
    
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [[NSNumber numberWithInt:1] stringValue],@"page",
                                      [maximumResultCount stringValue],@"pageSize",
                                      searchdict,@"textSearch",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Attendance_GetActivity"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetActivityData"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
    
}
/************************************************************************************************************
 @Function Name   : fetchNextActivityBasedOnTimesheetUri
 @Purpose         : Called to get next set of activity based on TimesheetUri
 @param           : timesheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchNextActivityWithSearchText:(NSString *)textSearch andDelegate:(id)delegate
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
    
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [pageNum stringValue],@"page",
                                      [pageSize stringValue],@"pageSize",
                                      searchdict,@"textSearch",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Attendance_GetActivity"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextActivityData"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}


#pragma mark - ServiceURL Response Handling

- (void) serverDidRespondWithResponse:(id) response
{
    if (response!=nil)
    {
        NSDictionary *errorDict=[[response objectForKey:@"response"]objectForKey:@"error"];
        
        if (errorDict!=nil)
        {
            [Util errorAlert:@"" errorMessage:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE)];
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            NSString *serviceURL = [response objectForKey:@"serviceURL"];
            [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE) serviceURL:serviceURL];
        }
        else
        {
            totalRequestsServed++;
            id _serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
            if ([_serviceID intValue]== Attendance_PunchTime_Service_ID_97)
            {
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:PUNCH_TIME_NOTIFICATION object:nil];
                
                
                
            }

            else if ([_serviceID intValue]== FirstClientsAndProjectsSummaryDetails_Service_ID_13)
            {
                [self handleClientsAndProjectsDownload:response];
                return;
            }
            else if ([_serviceID intValue]== NextClientsSummaryDetails_Service_ID_14)
            {
                [self handleNextClientsDownload:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
            }
            else if ([_serviceID intValue]== NextProjectsSummaryDetails_Service_ID_15)
            {
                [self handleNextProjectsDownload:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
            }
            else if ([_serviceID intValue]== FirstTasksSummaryDetails_Service_ID_16)
            {
                [self handleTasksBasedOnProjectsResponse:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
            }
            else if ([_serviceID intValue]== GetProjectsBasedOnclient_Service_ID_18)
            {
                [self handleProjectsBasedOnClientsResponse:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
                
            }
            else if ([_serviceID intValue]== NextTasksBasedOnProject_Service_ID_17)
            {
                [self handleNextTasksBasedOnProjectsResponse:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
                
            }
            else if ([_serviceID intValue]== GetNextProjectsBasedOnClients_Service_ID_19)
            {
                [self handleNextProjectsBasedOnClientDownload:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
                
            }
            else if ([_serviceID intValue]== FirstClientsSummaryDetails_Service_ID_20)
            {
                [self handleFirstClientsDownload:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
                
            }
            else if ([_serviceID intValue]== FirstProjectsSummaryDetails_Service_ID_21)
            {
                [self handleFirstProjectsDownload:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
                
            }
            
            else if ([_serviceID intValue]== GetBillingData_Service_ID_22)
            {
                [self handleBillingRateBasedOnProjectDownload:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
                
            }
            else if ([_serviceID intValue]== GetNextBillingData_Service_ID_23)
            {
                [self handleNextBillingRateBasedOnProjectDownload:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
                
            }
            else if ([_serviceID intValue]== GetActivityData_Service_ID_24)
            {
                [self handleActivityBasedOnTimesheetDownload:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
                
            }
            else if ([_serviceID intValue]== GetNextActivityData_Service_ID_25)
            {
                [self handleNextActivityBasedOnTimesheetDownload:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
                
            }
            else if ([_serviceID intValue]== GetBreakData_Service_ID_90)
            {
                [self handleBreakDownload:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
                
            }
            else if ([_serviceID intValue]== GetNextBreakData_Service_ID_91)
            {
                [self handleNextBreakDownload:response];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
                
            }
            else if ([_serviceID intValue]== LastPunchData_Service_ID_130)
            {
                [self handleLastPunchData:response];
                return;
                
            }

            
        }
    }
}

#pragma mark - ServiceURL Error Handling
- (void)serverDidFailWithError:(NSError *) error applicationState:(ApplicateState)applicationState
{
    
    totalRequestsServed++;
    [[NSNotificationCenter defaultCenter]postNotificationName:LAST_PUNCH_DATA_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
    
}


/************************************************************************************************************
 @Function Name   : handleClientsAndProjectsDownload
 @Purpose         : To save clients and projects details into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleClientsAndProjectsDownload:(id)response
{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSMutableArray *clientsArray=[[responseDict objectForKey:@"clientsDetails"] objectForKey:@"clients"];
    NSMutableArray *projectsArray=[[responseDict objectForKey:@"projectsDetails"] objectForKey:@"projects"];
    NSNumber *totalClientCount=[[responseDict objectForKey:@"clientsDetails"] objectForKey:@"totalClientCount"];
    NSNumber *totalProjectCount=[[responseDict objectForKey:@"projectsDetails"] objectForKey:@"totalProjectCount"];
    if ([clientsArray count]!=0)
    {
        [timesheetModel saveClientDetailsDataToDB:clientsArray];
    }
    
    NSNumber *projectsCount=[NSNumber numberWithUnsignedInteger:[projectsArray count]];
    
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];
    
    BOOL isProjectAllowed = NO;
    BOOL isProjectRequired = NO;
    if ([userDetailsArray count]!=0)
    {
        NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
        isProjectAllowed =[[userDict objectForKey:@"hasTimepunchProjectAccess"] boolValue];
        isProjectRequired=[[userDict objectForKey:@"timepunchProjectTaskSelectionRequired"] boolValue];
    }
    if (isProjectAllowed==YES && isProjectRequired==NO)
    {
        
        NSDictionary *projectDict= [NSDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(NONE_STRING, NONE_STRING),@"displayText",[NSNull null],@"uri", nil];
        [projectsArray addObject: [NSDictionary dictionaryWithObjectsAndKeys:projectDict,@"project", nil]];
    }
    
    
    if ([projectsArray count]!=0)
    {
        [timesheetModel saveProjectDetailsDataToDB:projectsArray];
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *clientsCount=[NSNumber numberWithUnsignedInteger:[clientsArray count]];
    
    [defaults setObject:clientsCount forKey:@"clientsDownloadCount"];
    [defaults setObject:projectsCount forKey:@"projectssDownloadCount"];
    [defaults setObject:totalClientCount forKey:@"totalClientCount"];
    [defaults setObject:totalProjectCount forKey:@"totalProjectCount"];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
}
/************************************************************************************************************
 @Function Name   : handleFirstClientsDownload
 @Purpose         : To save first clients details into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleFirstClientsDownload:(id)response
{
    NSMutableArray *clientsArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([clientsArray count]!=0)
    {
        [timesheetModel saveClientDetailsDataToDB:clientsArray];
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *clientsCount=[NSNumber numberWithUnsignedInteger:[clientsArray count]];
    [defaults setObject:clientsCount forKey:@"clientsDownloadCount"];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
}
/************************************************************************************************************
 @Function Name   : handleFirstProjectsDownload
 @Purpose         : To save first projects details into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleFirstProjectsDownload:(id)response
{
    NSMutableArray *projectsArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSNumber *projectsCount=[NSNumber numberWithUnsignedInteger:[projectsArray count]];
    
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];
    
    BOOL isProjectAllowed = NO;
    BOOL isProjectRequired = NO;
    if ([userDetailsArray count]!=0)
    {
        NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
        isProjectAllowed =[[userDict objectForKey:@"hasTimepunchProjectAccess"] boolValue];
        isProjectRequired=[[userDict objectForKey:@"timepunchProjectTaskSelectionRequired"] boolValue];
    }
    if (isProjectAllowed==YES && isProjectRequired==NO)
    {
        
        NSDictionary *projectDict= [NSDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(NONE_STRING, NONE_STRING),@"displayText",[NSNull null],@"uri", nil];
        [projectsArray addObject: [NSDictionary dictionaryWithObjectsAndKeys:projectDict,@"project", nil]];
    }
    
    
    if ([projectsArray count]!=0)
    {
        [timesheetModel saveProjectDetailsDataToDB:projectsArray];
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    [defaults setObject:projectsCount forKey:@"projectssDownloadCount"];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
}



/************************************************************************************************************
 @Function Name   : handleClientsAndProjectsDownload
 @Purpose         : To save next clients details into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleNextClientsDownload:(id)response
{
    NSMutableArray *clientsArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([clientsArray count]!=0)
    {
        [timesheetModel saveClientDetailsDataToDB:clientsArray];
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *clientsCount=[NSNumber numberWithUnsignedInteger:[clientsArray count]];
    [defaults setObject:clientsCount forKey:@"clientsDownloadCount"];
    [defaults synchronize];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"isErrorOccured",
                              [NSNumber numberWithBool:YES],@"isClientMoreAction",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NEXT_RECENT_CLIENTS_OR_PROJECTS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}

/************************************************************************************************************
 @Function Name   : handleNextProjectsDownload
 @Purpose         : To save next projects details into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleNextProjectsDownload:(id)response
{
    NSMutableArray *projectsArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([projectsArray count]!=0)
    {
        [timesheetModel saveProjectDetailsDataToDB:projectsArray];
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *projectsCount=[NSNumber numberWithUnsignedInteger:[projectsArray count]];
    [defaults setObject:projectsCount forKey:@"projectssDownloadCount"];
    [defaults synchronize];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"isErrorOccured",
                              [NSNumber numberWithBool:NO],@"isClientMoreAction",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NEXT_RECENT_CLIENTS_OR_PROJECTS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}

/************************************************************************************************************
 @Function Name   : handleProjectsBasedOnClientsResponse
 @Purpose         : To save next projects basede on clients details into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleProjectsBasedOnClientsResponse:(id)response
{
    NSMutableArray *projectsArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([projectsArray count]!=0)
    {
        [timesheetModel saveProjectDetailsDataToDB:projectsArray];
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *projectsCount=[NSNumber numberWithUnsignedInteger:[projectsArray count]];
    [defaults setObject:projectsCount forKey:@"projectssDownloadCount"];
    [defaults synchronize];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}

/************************************************************************************************************
 @Function Name   : handleTasksBasedOnProjectsResponse
 @Purpose         : To save next tasks based on projects details into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleTasksBasedOnProjectsResponse:(id)response
{
    NSMutableArray *tasksArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    
    if ([tasksArray count]!=0)
    {
        [timesheetModel saveTaskDetailsDataToDB:tasksArray];
        
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *tasksCount=[NSNumber numberWithUnsignedInteger:[tasksArray count]];
    [defaults setObject:tasksCount forKey:@"tasksDownloadCount"];
    [defaults synchronize];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
    
}


-(void)handleNextTasksBasedOnProjectsResponse:(id)response
{
    NSMutableArray *tasksArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    
    if ([tasksArray count]!=0)
    {
        
        [timesheetModel saveTaskDetailsDataToDB:tasksArray];
        
        
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *tasksCount=[NSNumber numberWithUnsignedInteger:[tasksArray count]];
    [defaults setObject:tasksCount forKey:@"tasksDownloadCount"];
    [defaults synchronize];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
    
}

/************************************************************************************************************
 @Function Name   : handleNextProjectsBasedOnClientDownload
 @Purpose         : To save next projects details into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleNextProjectsBasedOnClientDownload:(id)response
{
    NSMutableArray *projectsArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([projectsArray count]!=0)
    {
        [timesheetModel saveProjectDetailsDataToDB:projectsArray];
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *projectsCount=[NSNumber numberWithUnsignedInteger:[projectsArray count]];
    [defaults setObject:projectsCount forKey:@"projectssDownloadCount"];
    [defaults synchronize];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"isErrorOccured",
                              [NSNumber numberWithBool:NO],@"isClientMoreAction",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}
/************************************************************************************************************
 @Function Name   : handleBillingRateBasedOnProjectDownload
 @Purpose         : To save billling details into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handleBillingRateBasedOnProjectDownload:(id)response
{
    //NSDictionary *billingDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    //BOOL isNonBillableTimeAllocationAllowed=[[billingDict objectForKey:@"isNonBillableTimeAllocationAllowed"]boolValue];
    BOOL isNonBillableTimeAllocationAllowed=NO;
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                         forKey:@"isErrorOccured"];
    
    NSMutableArray *billingArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    
    if (billingArray!=nil && ![billingArray isKindOfClass:[NSNull class]])
    {
        NSNumber *billingRatesCount=[NSNumber numberWithUnsignedInteger:[billingArray count]];
        
        if (isNonBillableTimeAllocationAllowed)
        {
            [billingArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(NOT_BILLABLE, NOT_BILLABLE),@"displayText",[NSNull null],@"uri", nil]];
        }
        
        if ([billingArray count]!=0)
        {
            
            [timesheetModel saveBillingDetailsDataToDB:billingArray withModuleName:@"Timesheet"];
        }
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:billingRatesCount forKey:@"billingDownloadCount"];
        [defaults synchronize];
        
       dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                             forKey:@"isErrorOccured"];

    }
    
    
       [[NSNotificationCenter defaultCenter] postNotificationName:BILLING_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}

-(void)handleNextBillingRateBasedOnProjectDownload:(id)response
{
    NSMutableArray *billingArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([billingArray count]!=0)
    {
        
        [timesheetModel saveBillingDetailsDataToDB:billingArray withModuleName:@"Timesheet"];
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *timesheetsCount=[NSNumber numberWithUnsignedInteger:[billingArray count]];
    [defaults setObject:timesheetsCount forKey:@"billingDownloadCount"];
    [defaults synchronize];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:BILLING_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}

/************************************************************************************************************
 @Function Name   : handleActivityBasedOnTimesheetDownload
 @Purpose         : To save activity details into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handleActivityBasedOnTimesheetDownload:(id)response
{
    
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

/************************************************************************************************************
 @Function Name   : handleBreakDownload
 @Purpose         : To save break details into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handleBreakDownload:(id)response
{
    
    NSDictionary *billingDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSMutableArray *breakArray=[billingDict objectForKey:@"breakTypes"];
    NSNumber *breakCount=[NSNumber numberWithUnsignedInteger:[breakArray count]];
    if ([breakArray count]!=0)
    {
        
        [timesheetModel saveBreakDetailsDataToDB:breakArray];
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:breakCount forKey:@"breakDataDownloadCount"];
    [defaults synchronize];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:BREAK_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}

-(void)handleNextBreakDownload:(id)response
{
    NSMutableArray *breakArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSNumber *breakCount=[NSNumber numberWithUnsignedInteger:[breakArray count]];
    if ([breakArray count]!=0)
    {
        
        [timesheetModel saveBreakDetailsDataToDB:breakArray];
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:breakCount forKey:@"breakDataDownloadCount"];
    [defaults synchronize];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:BREAK_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
    
}


-(void)handleLastPunchData:(id)response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LAST_PUNCH_DATA_NOTIFICATION object:nil userInfo:[[response objectForKey:@"response"]objectForKey:@"d"]];
}

@end
