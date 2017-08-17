//
//  TimesheetRequest.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 03/02/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "TimesheetRequest.h"

#import "TimesheetModel.h"
#import "RequestBuilder.h"
#import "ServiceUtil.h"
#import "JsonWrapper.h"
#import "TimesheetEntryObject.h"


#import "Util.h"
#import "OEFObject.h"
@interface TimesheetRequest ()
@property (nonatomic,strong) TimesheetModel *timesheetModel;
@property (nonatomic,assign) int serviceID;

@end
@implementation TimesheetRequest

- (id) init
{
    self = [super init];
    if (self != nil)
    {
        if(self.timesheetModel == nil) {
            self.timesheetModel = [[TimesheetModel alloc] init];
        }
    }
    return self;
}

-(AFHTTPRequestOperation *)constructOperation:(NSDictionary *)queryDict withServiceName:(NSString *)serviceName
{
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:serviceName]];
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    NSLog(@"--------------");
    NSLog(@"%@",str);
     NSLog(@"--------------");
    
    CLS_LOG(@"fetchTimeSheetSummaryDataForTimesheet:isFreshDataDownload REQUEST ::::: %@",paramDict);
    
    self.serviceID = [[ServiceUtil getServiceIDForServiceName:serviceName] intValue];
    NSURLRequest *urlRequest = [RequestBuilder buildPOSTRequestWithParamDict:paramDict];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    // FOR SWIMLANES
    operation.securityPolicy.allowInvalidCertificates = YES;
    //[operation setName:serviceName];
    
    return operation;
}

-(NSURLRequest *)constructOperationForURLRequest:(NSDictionary *)queryDict withServiceName:(NSString *)serviceName
{
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:serviceName]];
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    NSLog(@"--------------");
    NSLog(@"%@",str);
    NSLog(@"--------------");
    self.serviceID = [[ServiceUtil getServiceIDForServiceName:serviceName] intValue];
    NSURLRequest *urlRequest = [RequestBuilder buildPOSTRequestWithParamDict:paramDict];
    return urlRequest;
}

- (AFHTTPRequestOperation *)fetchTimeSheetSummaryDataForTimesheet:(NSString *)timesheetUri isFreshDataDownload:(BOOL)isFreshDataDownload {
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:timesheetUri ,@"timesheetUri",nil];
    NSString *serviceName = @"GetTimesheetSummaryData";

    
    return [self constructOperation:queryDict withServiceName:serviceName];
}


-(AFHTTPRequestOperation *)saveWidgetTimeSheetData:(NSMutableArray *)timesheetDataArray andHybridWidgetTimeSheetData:(NSMutableArray *)hybridTimesheetDataArray andTimesheetUri:(NSString *)timesheetUri
{

    NSMutableDictionary *queryDict=[self widgetTimesheetSaveRequestProvider:timesheetDataArray andHybridWidgetTimeSheetData:hybridTimesheetDataArray andTimesheetUri:timesheetUri andTimesheetFormat:nil];

     NSString *serviceName = @"SaveWidgetTimesheetData";
    return [self constructOperation:queryDict withServiceName:serviceName];

}

-(NSMutableDictionary *)constructWidgetTimeSheetTimeEntries:(NSMutableArray *)timesheetDataArray andHybridWidgetTimeSheetData:(NSMutableArray *)hybridTimesheetDataArray andTimesheetUri:(NSString *)timesheetUri andTimeSheetFormat:(NSString *)timesheetFormat
{

    NSMutableDictionary *queryDict=[self widgetTimesheetSaveRequestProvider:timesheetDataArray andHybridWidgetTimeSheetData:hybridTimesheetDataArray andTimesheetUri:timesheetUri andTimesheetFormat:timesheetFormat];


    return queryDict;
    
}

-(AFHTTPRequestOperation *)saveWidgetTimeSheetData:(NSMutableDictionary *)queryDict
{

    NSString *serviceName = @"SaveWidgetTimesheetData";
    return [self constructOperation:queryDict withServiceName:serviceName];
    
}


-(NSMutableArray *)constructTimeEntriesArrForSavingWidgetTimesheet:(NSMutableArray *)timesheetDataArray andTimeSheetFormat:(NSString *)timesheetFormat andIsHybridTimesheet:(BOOL)isHybridTimesheet
{
    NSString *strUserURI=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserUri"];
    NSDictionary *userDict=[NSDictionary dictionaryWithObjectsAndKeys:strUserURI,@"uri", nil];
    NSMutableArray *timeEntriesArray=[NSMutableArray array];

    NSArray *timeAllocationTypeUrisArray=nil;
    
    if(isHybridTimesheet && [timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
    {
        timeAllocationTypeUrisArray=[NSArray arrayWithObjects:
                                     @"urn:replicon:time-allocation-type:project",
                                     nil
                                     ];
    }
    else if(isHybridTimesheet && ([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET]))
    {
        timeAllocationTypeUrisArray=[NSArray arrayWithObjects:
                                     @"urn:replicon:time-allocation-type:attendance",
                                     nil
                                     ];
    }
    else if([timesheetFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET])
    {
        timeAllocationTypeUrisArray=[NSArray arrayWithObjects:
                                     @"urn:replicon:time-allocation-type:attendance",
                                     nil
                                     ];
    }
    else
    {
        timeAllocationTypeUrisArray=[NSArray arrayWithObjects:
                                     @"urn:replicon:time-allocation-type:attendance",
                                     @"urn:replicon:time-allocation-type:project",nil
                                     ];
    }
    
    
    for (NSMutableArray *timeSheetEntryObjArr in timesheetDataArray)
    {
        for (TimesheetEntryObject *timeSheetEntryObj in timeSheetEntryObjArr)
        {
            
            NSDictionary *entryDateDict=[Util convertDateToApiDateDictionary:timeSheetEntryObj.timeEntryDate];
            
            
            if (![timeSheetEntryObj.entryType isEqualToString:Time_Off_Key])
            {
                
                
                NSMutableDictionary *timePairDict=[NSMutableDictionary dictionary];
                NSDictionary *hoursDict=nil;
                id timeEntryUri=[NSNull null];
                
                NSDictionary *targetDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:timeEntryUri,@"uri",nil];
                
                if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    hoursDict=[Util convertDecimalHoursToApiTimeDict:timeSheetEntryObj.timeEntryHoursInDecimalFormat];
                }
                else if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                {
                    NSDictionary *multiDayInoutDict=timeSheetEntryObj.multiDayInOutEntry;
                    
                    NSDictionary *startTimeDict=[Util getApiTimeDictForTime:[multiDayInoutDict objectForKey:@"in_time"]];
                    if (startTimeDict!=nil) {
                        [timePairDict setObject:startTimeDict forKey:@"startTime"];
                    }
                    NSDictionary *endTimeWithoutSecDict = [Util getApiTimeDictForTime:[multiDayInoutDict objectForKey:@"out_time"]];
                    if (endTimeWithoutSecDict!=nil)
                    {
                        NSMutableDictionary *endTimeDict=[NSMutableDictionary dictionaryWithDictionary:endTimeWithoutSecDict];
                        if (endTimeDict!=nil) {
                            if (multiDayInoutDict[@"isMidnightCrossover"]!=nil && ![multiDayInoutDict[@"isMidnightCrossover"] isKindOfClass:[NSNull class]])
                            {
                                if([multiDayInoutDict[@"isMidnightCrossover"]boolValue])
                                {
                                    [endTimeDict setObject:@"59" forKey:@"second"];
                                }
                            }
                            [timePairDict setObject:endTimeDict forKey:@"endTime"];
                        }
                    }

                }
                
                
                
                
                NSString *comments=timeSheetEntryObj.timeEntryComments;
                if (comments==nil||[comments isKindOfClass:[NSNull class]]||[comments isEqualToString:@""]) {
                    comments=@"";
                }
                
                NSString *breakUri=timeSheetEntryObj.breakUri;
                BOOL isbreakRow=(breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]]&&![breakUri isEqualToString:@""]);
                NSMutableArray *customMetaDataArray=[NSMutableArray array];
                if (isbreakRow)
                {
                    NSDictionary *valueDictDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                 breakUri, @"uri",nil];
                    NSDictionary *customMetaDataDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"urn:replicon:time-entry-metadata-key:break-type", @"keyUri",
                                                      valueDictDict,@"value",nil];
                    [customMetaDataArray addObject:customMetaDataDict];
                }
                
                if ([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                {
                    NSString *taskUri=timeSheetEntryObj.timeEntryTaskUri;
                    BOOL isTaskRow=(taskUri!=nil && ![taskUri isKindOfClass:[NSNull class]]&&![taskUri isEqualToString:@""]);
                    if (isTaskRow)
                    {
                        NSDictionary *valueDictDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                     taskUri, @"uri",nil];
                        NSDictionary *customMetaDataDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                          @"urn:replicon:time-entry-metadata-key:task", @"keyUri",
                                                          valueDictDict,@"value",nil];
                        [customMetaDataArray addObject:customMetaDataDict];
                    }
                    
                    NSString *activityUri=timeSheetEntryObj.timeEntryActivityUri;
                    BOOL isActivityRow=(activityUri!=nil && ![activityUri isKindOfClass:[NSNull class]]&&![activityUri isEqualToString:@""]);
                    if (isActivityRow)
                    {
                        NSDictionary *valueDictDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                     activityUri, @"uri",nil];
                        NSDictionary *customMetaDataDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                          @"urn:replicon:time-entry-metadata-key:activity", @"keyUri",
                                                          valueDictDict,@"value",nil];
                        [customMetaDataArray addObject:customMetaDataDict];
                    }
                    
                    NSString *projectUri=timeSheetEntryObj.timeEntryProjectUri;
                    BOOL isProjectRow=(projectUri!=nil && ![projectUri isKindOfClass:[NSNull class]]&&![projectUri isEqualToString:@""]);
                    if (isProjectRow)
                    {
                        NSDictionary *valueDictDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                     projectUri, @"uri",nil];
                        NSDictionary *customMetaDataDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                          @"urn:replicon:time-entry-metadata-key:project", @"keyUri",
                                                          valueDictDict,@"value",nil];
                        [customMetaDataArray addObject:customMetaDataDict];
                    }
                    
                    NSString *billingUri=timeSheetEntryObj.timeEntryBillingUri;
                    BOOL isBillingRow=(billingUri!=nil && ![billingUri isKindOfClass:[NSNull class]]&&![billingUri isEqualToString:@""]);
                    if (isBillingRow)
                    {
                        NSDictionary *valueDictDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                     billingUri, @"uri",nil];
                        NSDictionary *customMetaDataDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                          @"urn:replicon:time-entry-metadata-key:billing-rate", @"keyUri",
                                                          valueDictDict,@"value",nil];
                        [customMetaDataArray addObject:customMetaDataDict];
                    }

                    if ([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET] )
                    {
                        NSString *rowNumber=timeSheetEntryObj.rownumber;
                        BOOL isRowNumberPresent=(rowNumber!=nil && ![rowNumber isKindOfClass:[NSNull class]]&&![rowNumber isEqualToString:@""] &&![rowNumber containsString:@"-"]);
                        if (isRowNumberPresent)
                        {
                            NSDictionary *valueDictDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                         rowNumber, @"number",nil];
                            NSDictionary *customMetaDataDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                              @"urn:replicon:widget-ui-metadata-key:row-number", @"keyUri",
                                                              valueDictDict,@"value",nil];
                            [customMetaDataArray addObject:customMetaDataDict];
                        }
                    }

                }
                else if ([timesheetFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET])
                {
                    NSDictionary *customMetaDataDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"urn:replicon:widget-ui-metadata-key:entry-source", @"keyUri",
                                                      [NSDictionary dictionaryWithObjectsAndKeys:
                                                       @"urn:replicon:policy:timesheet:widget-timesheet:daily-fields", @"uri",nil],@"value",nil];
                    [customMetaDataArray addObject:customMetaDataDict];
                }
                

                if (![timesheetFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET])
                {
                    NSDictionary *valueDictDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                 comments, @"text",nil];
                    NSDictionary *customMetaDataDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"urn:replicon:time-entry-metadata-key:comments", @"keyUri",
                                                      valueDictDict,@"value",nil];
                    [customMetaDataArray addObject:customMetaDataDict];
                }
                

                
                
                NSDictionary *intervalDict=[NSDictionary dictionary];
                if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    BOOL hasTimeEntryValue = timeSheetEntryObj.hasTimeEntryValue;

                    if (hasTimeEntryValue) {
                        ////We are not sending the time entry if user has not entered any time for time and row in time distribution widget/// As per Time Capture for negative time entry implementation
                        intervalDict=[NSDictionary dictionaryWithObjectsAndKeys:hoursDict,@"hours",nil];
                    }
                }
                else if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                {
                    intervalDict=[NSDictionary dictionaryWithObjectsAndKeys:timePairDict,@"timePair",nil];
                }



                
                NSMutableDictionary *timeEntryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             targetDict,@"target",
                                             userDict,@"user",
                                             entryDateDict,@"entryDate",
                                             timeAllocationTypeUrisArray,@"timeAllocationTypeUris",
                                             intervalDict,@"interval",
                                             customMetaDataArray,@"customMetadata", nil];

                if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                   NSMutableArray *extensionFieldValuesArr=[NSMutableArray array];
                    for (OEFObject *oefObj in timeSheetEntryObj.timeEntryCellOEFArray)
                    {

                        NSMutableDictionary *extensionFieldValuesDict=[self constructOEFNodesFromOEFObject:oefObj];
                        if (extensionFieldValuesDict!=nil)
                        {
                            [extensionFieldValuesArr addObject:extensionFieldValuesDict];
                        }

                    }

                    if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                    {
                        for (OEFObject *oefObj in timeSheetEntryObj.timeEntryRowOEFArray)
                        {

                            NSMutableDictionary *extensionFieldValuesDict=[self constructOEFNodesFromOEFObject:oefObj];
                            if (extensionFieldValuesDict!=nil)
                            {
                                [extensionFieldValuesArr addObject:extensionFieldValuesDict];
                            }
                            
                        }
                    }

                    if ([extensionFieldValuesArr count]>0)
                    {
                        [timeEntryDict setObject:extensionFieldValuesArr forKey:@"extensionFieldValues"];
                    }
                   [timeEntriesArray addObject:timeEntryDict];
                    NSDictionary *multiDayInoutDict=timeSheetEntryObj.multiDayInOutEntry;
                    if([multiDayInoutDict objectForKey:SplitTimeEntryForNextTimesheetPeriod] != nil && [multiDayInoutDict objectForKey:SplitTimeEntryForNextTimesheetPeriod] != (id)[NSNull null]){
                        NSMutableDictionary *nextTimesheetPeriodSplitData = [self constructSplitValueForNextTimesheetObject:timeSheetEntryObj timeSheetFormat:timesheetFormat];
                        if(nextTimesheetPeriodSplitData !=nil && nextTimesheetPeriodSplitData != (id)[NSNull null]){
                            [nextTimesheetPeriodSplitData setObject:targetDict forKey:@"target"];
                            [nextTimesheetPeriodSplitData setObject:userDict forKey:@"user"];
                            [nextTimesheetPeriodSplitData setObject:timeAllocationTypeUrisArray forKey:@"timeAllocationTypeUris"];
                            [nextTimesheetPeriodSplitData setObject:customMetaDataArray forKey:@"customMetadata"];
                            [timeEntriesArray addObject:nextTimesheetPeriodSplitData];
                        }
                    }
                }
                else if([timesheetFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET] )
                {
                    NSMutableArray *extensionFieldValuesArr=[NSMutableArray array];
                    for (OEFObject *oefObj in timeSheetEntryObj.timeEntryDailyFieldOEFArray)
                    {

                        NSMutableDictionary *extensionFieldValuesDict=[self constructOEFNodesFromOEFObject:oefObj];
                        if (extensionFieldValuesDict!=nil)
                        {
                            [extensionFieldValuesArr addObject:extensionFieldValuesDict];
                        }

                    }
                    if ([extensionFieldValuesArr count]>0)
                    {
                        [timeEntryDict setObject:extensionFieldValuesArr forKey:@"extensionFieldValues"];
                        [timeEntriesArray addObject:timeEntryDict];
                    }
                }
                else if ([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                {
                    [timeEntriesArray addObject:timeEntryDict];
                }

//                NSDictionary *multiDayInoutDict=timeSheetEntryObj.multiDayInOutEntry;
//                if(multiDayInoutDict[@"splitNextDayData"] != nil && multiDayInoutDict[@"splitNextDayData"] != (id)[NSNull null]){
//                    
//                }
            }
        }
    }
    
    return timeEntriesArray;
}

-(NSMutableDictionary *)constructSplitValueForNextTimesheetObject:(TimesheetEntryObject *)timesheetEntryObject timeSheetFormat:(NSString *)timesheetFormat{
    
    NSMutableDictionary *splitEntryDictionary = timesheetEntryObject.multiDayInOutEntry;
    if(splitEntryDictionary != nil && splitEntryDictionary != (id)[NSNull null] && splitEntryDictionary.allValues.count >0){
        NSDate *entryDate = [Util getNextDateFromCurrentDate:timesheetEntryObject.timeEntryDate];
        NSDictionary *entryDateDictionary = [Util convertDateToApiDateDictionary:entryDate];
        NSDictionary *endTime = [Util getApiTimeDictForTime:[[splitEntryDictionary objectForKey:SplitTimeEntryForNextTimesheetPeriod] objectForKey:@"out_time"]];
        NSDictionary *startTime = [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"hour",@"0",@"minute",@"0",@"second", nil];
        NSDictionary *timepairDictionary = [NSDictionary dictionaryWithObjectsAndKeys:startTime,@"startTime",endTime,@"endTime", nil];
        NSDictionary *interval = [NSDictionary dictionaryWithObjectsAndKeys:timepairDictionary,@"timePair", nil];
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:entryDateDictionary, @"entryDate", interval, @"interval", nil];
        return dataDict;
    }
    else return nil;
}


-(void)saveTimeEntryDetailsWithNoTime:(TimesheetEntryObject *)timesheetObj andTimesheetformat:(NSString *)timesheetFormat
{
    [self.timesheetModel saveTimeEntryDataForEmptyTimeValue:timesheetObj :timesheetFormat];
}

-(void)deleteAnyEmptyTimeEntryAvailable:(TimesheetEntryObject *)timesheetObj andTimesheetformat:(NSString *)timesheetFormat
{
    [self.timesheetModel deleteEmptyTimeEntryValue:timesheetObj withTimesheetFormat:timesheetFormat];
}

-(AFHTTPRequestOperation *)sendRequestToSubmitWidgetTimesheetWithTimesheetURI:(NSString *)timesheetURI comments:(NSString*)comment hasAttestationPermission:(BOOL)hasAttestationPermission andAttestationStatus:(BOOL)isAttestationStatus
{
    id tempComment=[NSNull null];;
    if (comment!=nil && ![comment isKindOfClass:[NSNull class]]&&![comment isEqualToString:@""])
        tempComment=comment;
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timesheetURI ,@"timesheetUri",
                                      [Util getRandomGUID],@"unitOfWorkId",
                                      tempComment,@"comments",
                                      [NSNull null],@"changeReason",
                                      nil];
    
    if (hasAttestationPermission)
    {
        if (isAttestationStatus)
        {
            [queryDict setObject:@"true" forKey:@"attestationStatus"];
        }
        else
        {
            [queryDict setObject:@"false" forKey:@"attestationStatus"];
        }
    }
    
    NSString *serviceName =@"Gen4SubmitTimesheetData";
    return [self constructOperation:queryDict withServiceName:serviceName];
}

-(AFHTTPRequestOperation *)sendRequestToReopenWidgetTimesheetWithTimesheetURI:(NSString *)timesheetURI comments:(NSString *)comments
{
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timesheetURI ,@"timesheetUri",
                                      [Util getRandomGUID],@"unitOfWorkId",
                                      nil];

    if (comments!=nil && ![comments isKindOfClass:[NSNull class]])
    {
        [queryDict setObject:comments forKey:@"comments"];
    }
    
    NSString *serviceName =@"Gen4UnSubmitTimesheetData";
    return [self constructOperation:queryDict withServiceName:serviceName];
}


-(AFHTTPRequestOperation *)sendRequestToFetchBreaksWithTimesheetURI:(NSString *)timesheetURI
{
    NSNumber *maximumResultCount=[NSNumber numberWithInt:100];
        
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [maximumResultCount stringValue],@"maximumResultCount",
                                      timesheetURI ,@"timesheetUri",
                                      [NSNull null],@"textSearch",
                                      nil];

    
    NSString *serviceName =@"GetBreakData";
    return [self constructOperation:queryDict withServiceName:serviceName];
}

-(AFHTTPRequestOperation *)fetchTimeSheetUpdateData
{

    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];

    NSDictionary *leftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNull null],@"leftExpression",
                                      [NSNull null],@"operatorUri",
                                      [NSNull null],@"rightExpression",
                                      [NSNull null],@"value",
                                      @"urn:replicon:timesheet-list-filter:timesheet-owner",@"filterDefinitionUri",
                                      nil];



    NSDictionary *valueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                             strUserURI,@"uri",
                             [NSNull null],@"uris",
                             [NSNull null],@"bool",
                             [NSNull null],@"date",
                             [NSNull null],@"money",
                             [NSNull null],@"number",
                             [NSNull null],@"text",
                             [NSNull null],@"time",
                             [NSNull null],@"calendarDayDurationValue",
                             [NSNull null],@"workdayDurationValue",
                             [NSNull null],@"dateRange", nil];



    NSDictionary *rightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNull null],@"leftExpression",
                                       [NSNull null],@"operatorUri",
                                       [NSNull null],@"rightExpression",
                                       valueDict,@"value",
                                       [NSNull null],@"filterDefinitionUri",
                                       nil];

    NSDictionary *finalLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                           leftExpressionDict,@"leftExpression",
                                           @"urn:replicon:filter-operator:equal",@"operatorUri",
                                           rightExpressionDict,@"rightExpression",
                                           [NSNull null],@"value",
                                           [NSNull null],@"filterDefinitionUri",
                                           nil];


    NSDictionary *rightExpressionsLeftDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNull null],@"leftExpression",
                                            [NSNull null],@"operatorUri",
                                            [NSNull null],@"rightExpression",
                                            [NSNull null],@"value",
                                            @"urn:replicon:timesheet-list-filter:timesheet-period-date-range",@"filterDefinitionUri",
                                            nil];


    NSDictionary *todayDateDict=[Util convertDateToApiDateDictionaryOnLocalTimeZone:[NSDate date]];
    NSDictionary *currentDateDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                   [todayDateDict objectForKey:@"day"],@"day",
                                   [todayDateDict objectForKey:@"month"],@"month",
                                   [todayDateDict objectForKey:@"year"],@"year",
                                   nil];

    NSDictionary *dateRangeDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNull null],@"relativeDateRangeAsOfDate",
                                 [NSNull null],@"relativeDateRangeUri",
                                 [NSNull null],@"startDate",
                                 currentDateDict,@"endDate",
                                 nil];

    NSDictionary *rightExpressionsValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNull null],@"bool",
                                             [NSNull null],@"calendarDayDurationValue",
                                             [NSNull null],@"date",
                                             [NSNull null],@"money",
                                             [NSNull null],@"number",
                                             [NSNull null],@"text",
                                             [NSNull null],@"time",
                                             [NSNull null],@"uri",
                                             [NSNull null],@"uris",
                                             [NSNull null],@"workdayDurationValue",
                                             dateRangeDict,@"dateRange", nil];

    NSDictionary *rightExpressionsRightDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNull null],@"leftExpression",
                                             [NSNull null],@"operatorUri",
                                             [NSNull null],@"rightExpression",
                                             rightExpressionsValueDict,@"value",
                                             [NSNull null],@"filterDefinitionUri",
                                             nil];


    NSDictionary *finalRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            rightExpressionsLeftDict,@"leftExpression",
                                            @"urn:replicon:filter-operator:in",@"operatorUri",
                                            rightExpressionsRightDict,@"rightExpression",
                                            [NSNull null],@"value",
                                            [NSNull null],@"filterDefinitionUri",
                                            nil];


    NSDictionary *filterDict=[NSDictionary dictionaryWithObjectsAndKeys:
                              finalLeftExpressionDict,@"leftExpression",
                              @"urn:replicon:filter-operator:and",@"operatorUri",
                              finalRightExpressionDict,@"rightExpression",
                              [NSNull null],@"value",
                              [NSNull null],@"filterDefinitionUri",
                              nil];




    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getTimesheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];

        if ([columnName isEqualToString:@"Timesheet Period"]||
            [columnName isEqualToString:@"Regular Hours"]||
            [columnName isEqualToString:@"Overtime Hours"]||
            [columnName isEqualToString:@"Time Off Hours"]||
            [columnName isEqualToString:@"Total Hours"]||
            [columnName isEqualToString:@"Due Date"]||
            [columnName isEqualToString:@"Meal Penalties"]||
            [columnName isEqualToString:@"Timesheet"]||
            [columnName isEqualToString:@"Approval Status"]||
            [columnName isEqualToString:@"Total Hours Excluding Break"])
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }

    NSMutableDictionary *queryDict = nil;
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"timesheetDownloadCount"];

        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                          @"urn:replicon:timesheet-list-column:timesheet-period",@"columnUri",
                                          @"false",@"isAscending",
                                          nil];
        [sortArray addObject:sortExpressionDict];


        NSMutableDictionary *lastUpdatedDateTimeDict = nil;
        id lastUpdatedDateTime;

        NSUserDefaults *userdefaults=[NSUserDefaults standardUserDefaults];
        NSString *lastUpdateDateStr=(NSString*)[userdefaults objectForKey:@"TimeSheetLastModifiedTime"];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];

        NSDate *lastUpdateDate=[dateFormatter dateFromString:lastUpdateDateStr];




        unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
        NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDateComponents *comps = [calendar components:unitFlags fromDate:lastUpdateDate];
        if(comps != nil) {
            lastUpdatedDateTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInteger:[comps year]],@"year",
                                       [NSNumber numberWithInteger:[comps month]],@"month",
                                       [NSNumber numberWithInteger:[comps day]], @"day",
                                       [NSNumber numberWithInteger:[comps hour]],@"hour",
                                       [NSNumber numberWithInteger:[comps minute]],@"minute",
                                       [NSNumber numberWithInteger:[comps second]],@"second",
                                       UTC_TIMEZONE,@"timeZoneUri",
                                       nil];
            lastUpdatedDateTime=lastUpdatedDateTimeDict;
        }
        else{
            lastUpdatedDateTime=[NSNull null];
        }


        queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageSize,@"pageSize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",filterDict,@"filterExpression",
                                          lastUpdatedDateTime,@"lastUpdatedDateTime",nil];



    }

    NSString *serviceName =@"GetTimesheetUpdateData";
    return [self constructOperation:queryDict withServiceName:serviceName];

}

-(AFHTTPRequestOperation *)fetchNextRecentTimeSheetData
{

    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];

    NSString *strUserURI=[defaults objectForKey:@"UserUri"];

    NSDictionary *leftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNull null],@"leftExpression",
                                      [NSNull null],@"operatorUri",
                                      [NSNull null],@"rightExpression",
                                      [NSNull null],@"value",
                                      @"urn:replicon:timesheet-list-filter:timesheet-owner",@"filterDefinitionUri",
                                      nil];



    NSDictionary *valueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                             strUserURI,@"uri",
                             [NSNull null],@"uris",
                             [NSNull null],@"bool",
                             [NSNull null],@"date",
                             [NSNull null],@"money",
                             [NSNull null],@"number",
                             [NSNull null],@"text",
                             [NSNull null],@"time",
                             [NSNull null],@"calendarDayDurationValue",
                             [NSNull null],@"workdayDurationValue",
                             [NSNull null],@"dateRange", nil];



    NSDictionary *rightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNull null],@"leftExpression",
                                       [NSNull null],@"operatorUri",
                                       [NSNull null],@"rightExpression",
                                       valueDict,@"value",
                                       [NSNull null],@"filterDefinitionUri",
                                       nil];

    NSDictionary *finalLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                           leftExpressionDict,@"leftExpression",
                                           @"urn:replicon:filter-operator:equal",@"operatorUri",
                                           rightExpressionDict,@"rightExpression",
                                           [NSNull null],@"value",
                                           [NSNull null],@"filterDefinitionUri",
                                           nil];


    NSDictionary *rightExpressionsLeftDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNull null],@"leftExpression",
                                            [NSNull null],@"operatorUri",
                                            [NSNull null],@"rightExpression",
                                            [NSNull null],@"value",
                                            @"urn:replicon:timesheet-list-filter:timesheet-period-date-range",@"filterDefinitionUri",
                                            nil];

    NSDictionary *todayDateDict=[Util convertDateToApiDateDictionaryOnLocalTimeZone:[NSDate date]];
    NSDictionary *currentDateDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                   [todayDateDict objectForKey:@"day"],@"day",
                                   [todayDateDict objectForKey:@"month"],@"month",
                                   [todayDateDict objectForKey:@"year"],@"year",
                                   nil];

    NSDictionary *dateRangeDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNull null],@"relativeDateRangeAsOfDate",
                                 [NSNull null],@"relativeDateRangeUri",
                                 [NSNull null],@"startDate",
                                 currentDateDict,@"endDate",
                                 nil];

    NSDictionary *rightExpressionsValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNull null],@"bool",
                                             [NSNull null],@"calendarDayDurationValue",
                                             [NSNull null],@"date",
                                             [NSNull null],@"money",
                                             [NSNull null],@"number",
                                             [NSNull null],@"text",
                                             [NSNull null],@"time",
                                             [NSNull null],@"uri",
                                             [NSNull null],@"uris",
                                             [NSNull null],@"workdayDurationValue",
                                             dateRangeDict,@"dateRange", nil];

    NSDictionary *rightExpressionsRightDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNull null],@"leftExpression",
                                             [NSNull null],@"operatorUri",
                                             [NSNull null],@"rightExpression",
                                             rightExpressionsValueDict,@"value",
                                             [NSNull null],@"filterDefinitionUri",
                                             nil];


    NSDictionary *finalRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            rightExpressionsLeftDict,@"leftExpression",
                                            @"urn:replicon:filter-operator:in",@"operatorUri",
                                            rightExpressionsRightDict,@"rightExpression",
                                            [NSNull null],@"value",
                                            [NSNull null],@"filterDefinitionUri",
                                            nil];


    NSDictionary *filterDict=[NSDictionary dictionaryWithObjectsAndKeys:
                              finalLeftExpressionDict,@"leftExpression",
                              @"urn:replicon:filter-operator:and",@"operatorUri",
                              finalRightExpressionDict,@"rightExpression",
                              [NSNull null],@"value",
                              [NSNull null],@"filterDefinitionUri",
                              nil];



    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getTimesheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];

        if ([columnName isEqualToString:@"Timesheet Period"]||
            [columnName isEqualToString:@"Regular Hours"]||
            [columnName isEqualToString:@"Overtime Hours"]||
            [columnName isEqualToString:@"Time Off Hours"]||
            [columnName isEqualToString:@"Total Hours"]||
            [columnName isEqualToString:@"Due Date"]||
            [columnName isEqualToString:@"Meal Penalties"]||
            [columnName isEqualToString:@"Timesheet"]||
            [columnName isEqualToString:@"Approval Status"]||
            [columnName isEqualToString:@"Total Hours Excluding Break"]
            )
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }

    NSMutableDictionary *queryDict = nil;
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        int nextFetchPageNo=[[defaults objectForKey:@"NextTimeSheetPageNo"] intValue];
        NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:nextFetchPageNo+1];
        [defaults setObject:nextFetchPageNumber forKey:@"NextTimeSheetPageNo"];
        [defaults synchronize];

        NSNumber *pageNum=[NSNumber numberWithInteger:nextFetchPageNo+1];
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"timesheetDownloadCount"];
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                          @"urn:replicon:timesheet-list-column:timesheet-period",@"columnUri",
                                          @"false",@"isAscending",
                                          nil];
        [sortArray addObject:sortExpressionDict];


        queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageNum ,@"page",
                                          pageSize,@"pagesize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",filterDict,@"filterExpression",nil];

    }

    NSString *serviceName =@"GetTimesheetData";
    return [self constructOperation:queryDict withServiceName:serviceName];
}



-(NSMutableDictionary *)constructOEFNodesFromOEFObject:(OEFObject *)oefObj
{
    NSDictionary *definitionDict=@{@"uri":oefObj.oefUri};
    NSMutableDictionary *extensionFieldValuesDict=[NSMutableDictionary dictionary];
    [extensionFieldValuesDict setObject:definitionDict forKey:@"definition"];

    if ([oefObj.oefDefinitionTypeUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
    {
        if (oefObj.oefTextValue!=nil && ![oefObj.oefTextValue isKindOfClass:[NSNull class]]) {
            if (![oefObj.oefTextValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")] && ![oefObj.oefTextValue isEqualToString:RPLocalizedString(ADD_STRING, @"")] && ![oefObj.oefTextValue isEqualToString:RPLocalizedString(NULL_STRING, @"")])
            {
                [extensionFieldValuesDict setObject:oefObj.oefTextValue forKey:@"textValue"];
                return extensionFieldValuesDict;
            }


        }

    }
    else if ([oefObj.oefDefinitionTypeUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
    {
        if (oefObj.oefNumericValue!=nil && ![oefObj.oefNumericValue isKindOfClass:[NSNull class]]) {
            if (![oefObj.oefNumericValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")] && ![oefObj.oefNumericValue isEqualToString:RPLocalizedString(ADD_STRING, @"")] && ![oefObj.oefNumericValue isEqualToString:RPLocalizedString(NULL_STRING, @"")])
            {
                [extensionFieldValuesDict setObject:[NSNumber numberWithDouble:[oefObj.oefNumericValue newDoubleValue]] forKey:@"numericValue"];
                return extensionFieldValuesDict;

            }

        }

    }
    else if ([oefObj.oefDefinitionTypeUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
    {
        if (oefObj.oefDropdownOptionValue!=nil && ![oefObj.oefDropdownOptionValue isKindOfClass:[NSNull class]]) {
            if (![oefObj.oefDropdownOptionValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")] && ![oefObj.oefDropdownOptionValue isEqualToString:RPLocalizedString(ADD_STRING, @"")] && ![oefObj.oefDropdownOptionValue isEqualToString:RPLocalizedString(NULL_STRING, @"")])
            {
                NSDictionary *tagDict=@{@"uri":oefObj.oefDropdownOptionUri};
                [extensionFieldValuesDict setObject:tagDict forKey:@"tag"];
                return extensionFieldValuesDict;
                
            }
            
        }
        
        
    }
    
    return nil;
    
}

-(NSMutableDictionary *)widgetTimesheetSaveRequestProvider:(NSMutableArray *)timesheetDataArray andHybridWidgetTimeSheetData:(NSMutableArray *)hybridTimesheetDataArray andTimesheetUri:(NSString *)timesheetUri andTimesheetFormat:(NSString *)timesheetFormat
{
    NSMutableArray *enableWidgetsArr=[self.timesheetModel getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
    if (!timesheetFormat)
    {
        timesheetFormat=[self.timesheetModel getTimesheetFormatforTimesheetUri:timesheetUri];
    }


    BOOL isHybridTimesheet=NO;
    BOOL hasStandardWidget=NO;
    BOOL hasInOutWidget=NO;
    BOOL hasPunchWidget=NO;

    for(NSDictionary *widgetUriDict in enableWidgetsArr)
    {

        if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
        {
            hasStandardWidget=YES;
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
        {
            hasInOutWidget=YES;

        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
        {
            hasPunchWidget=YES;

        }
    }

    if (hasInOutWidget && hasStandardWidget)
    {
        isHybridTimesheet=YES;
    }

    if (hasPunchWidget && hasStandardWidget)
    {
        isHybridTimesheet=YES;
    }


    NSMutableArray *timeEntriesArray=nil;

    if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
    {
        if ([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            timeEntriesArray=[self constructTimeEntriesArrForSavingWidgetTimesheet:timesheetDataArray andTimeSheetFormat:timesheetFormat andIsHybridTimesheet:isHybridTimesheet];
            if (hasInOutWidget)
            {
                [timeEntriesArray addObjectsFromArray:[self constructTimeEntriesArrForSavingWidgetTimesheet:hybridTimesheetDataArray andTimeSheetFormat:GEN4_INOUT_TIMESHEET andIsHybridTimesheet:isHybridTimesheet]];
            }
        }
        else if ([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
        {
            timeEntriesArray=[self constructTimeEntriesArrForSavingWidgetTimesheet:timesheetDataArray andTimeSheetFormat:timesheetFormat andIsHybridTimesheet:isHybridTimesheet];
            if (hasStandardWidget)
            {
                [timeEntriesArray addObjectsFromArray:[self constructTimeEntriesArrForSavingWidgetTimesheet:hybridTimesheetDataArray andTimeSheetFormat:GEN4_STANDARD_TIMESHEET andIsHybridTimesheet:isHybridTimesheet]];
            }
            
        }
    }




    //    NSMutableArray *deleteTimeEntriesArray=[NSMutableArray array];
    //    for (NSDictionary *deletedTimeSheetDict in  deletedObjectsArray)
    //    {
    //        if ([deletedTimeSheetDict objectForKey:@"timePunchesUri"]!=nil && ![[deletedTimeSheetDict objectForKey:@"timePunchesUri"] isKindOfClass:[NSNull class]])
    //        {
    //            if(![[deletedTimeSheetDict objectForKey:@"timePunchesUri"] isEqualToString:@"" ])
    //            {
    //                [deleteTimeEntriesArray addObject:[NSDictionary dictionaryWithObject:[deletedTimeSheetDict objectForKey:@"timePunchesUri"] forKey:@"uri"]];
    //            }
    //        }
    //
    //    }

    //    NSMutableDictionary *updateTimeEntriesParameterDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
    //                                                         timeEntriesArray,@"newAndUpdatedTimeEntries",
    //                                                         deleteTimeEntriesArray,@"deletedTimeEntries",
    //                                                         nil];

    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:timesheetUri,@"timesheetUri",
                                      [Util getRandomGUID],@"unitOfWorkId",
                                      nil];
    if (timeEntriesArray)
    {
        [queryDict setObject:timeEntriesArray forKey:@"timeEntries"];
    }

   
    return queryDict;
}

-(AFHTTPRequestOperation *)GetOrCreateFirstTimesheets
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];


    NSString *strUserURI=[defaults objectForKey:@"UserUri"];

    NSDictionary *leftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNull null],@"leftExpression",
                                      [NSNull null],@"operatorUri",
                                      [NSNull null],@"rightExpression",
                                      [NSNull null],@"value",
                                      @"urn:replicon:timesheet-list-filter:timesheet-owner",@"filterDefinitionUri",
                                      nil];



    NSDictionary *valueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                             strUserURI,@"uri",
                             [NSNull null],@"uris",
                             [NSNull null],@"bool",
                             [NSNull null],@"date",
                             [NSNull null],@"money",
                             [NSNull null],@"number",
                             [NSNull null],@"text",
                             [NSNull null],@"time",
                             [NSNull null],@"calendarDayDurationValue",
                             [NSNull null],@"workdayDurationValue",
                             [NSNull null],@"dateRange", nil];



    NSDictionary *rightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNull null],@"leftExpression",
                                       [NSNull null],@"operatorUri",
                                       [NSNull null],@"rightExpression",
                                       valueDict,@"value",
                                       [NSNull null],@"filterDefinitionUri",
                                       nil];

    NSDictionary *finalLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                           leftExpressionDict,@"leftExpression",
                                           @"urn:replicon:filter-operator:equal",@"operatorUri",
                                           rightExpressionDict,@"rightExpression",
                                           [NSNull null],@"value",
                                           [NSNull null],@"filterDefinitionUri",
                                           nil];


    NSDictionary *rightExpressionsLeftDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNull null],@"leftExpression",
                                            [NSNull null],@"operatorUri",
                                            [NSNull null],@"rightExpression",
                                            [NSNull null],@"value",
                                            @"urn:replicon:timesheet-list-filter:timesheet-period-date-range",@"filterDefinitionUri",
                                            nil];


    NSDictionary *todayDateDict=[Util convertDateToApiDateDictionaryOnLocalTimeZone:[NSDate date]];
    NSDictionary *currentDateDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                   [todayDateDict objectForKey:@"day"],@"day",
                                   [todayDateDict objectForKey:@"month"],@"month",
                                   [todayDateDict objectForKey:@"year"],@"year",
                                   nil];

    NSDictionary *dateRangeDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNull null],@"relativeDateRangeAsOfDate",
                                 [NSNull null],@"relativeDateRangeUri",
                                 currentDateDict,@"startDate",
                                 currentDateDict,@"endDate",
                                 nil];

    NSDictionary *rightExpressionsValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNull null],@"bool",
                                             [NSNull null],@"calendarDayDurationValue",
                                             [NSNull null],@"date",
                                             [NSNull null],@"money",
                                             [NSNull null],@"number",
                                             [NSNull null],@"text",
                                             [NSNull null],@"time",
                                             [NSNull null],@"uri",
                                             [NSNull null],@"uris",
                                             [NSNull null],@"workdayDurationValue",
                                             dateRangeDict,@"dateRange", nil];

    NSDictionary *rightExpressionsRightDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNull null],@"leftExpression",
                                             [NSNull null],@"operatorUri",
                                             [NSNull null],@"rightExpression",
                                             rightExpressionsValueDict,@"value",
                                             [NSNull null],@"filterDefinitionUri",
                                             nil];


    NSDictionary *finalRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            rightExpressionsLeftDict,@"leftExpression",
                                            @"urn:replicon:filter-operator:in",@"operatorUri",
                                            rightExpressionsRightDict,@"rightExpression",
                                            [NSNull null],@"value",
                                            [NSNull null],@"filterDefinitionUri",
                                            nil];


    NSDictionary *filterDict=[NSDictionary dictionaryWithObjectsAndKeys:
                              finalLeftExpressionDict,@"leftExpression",
                              @"urn:replicon:filter-operator:and",@"operatorUri",
                              finalRightExpressionDict,@"rightExpression",
                              [NSNull null],@"value",
                              [NSNull null],@"filterDefinitionUri",
                              nil];




    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getTimesheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];

        if ([columnName isEqualToString:@"Timesheet Period"]||
            [columnName isEqualToString:@"Regular Hours"]||
            [columnName isEqualToString:@"Overtime Hours"]||
            [columnName isEqualToString:@"Time Off Hours"]||
            [columnName isEqualToString:@"Total Hours"]||
            [columnName isEqualToString:@"Due Date"]||
            [columnName isEqualToString:@"Meal Penalties"]||
            [columnName isEqualToString:@"Timesheet"]||
            [columnName isEqualToString:@"Approval Status"]||
            [columnName isEqualToString:@"Total Hours Excluding Break"])
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }

        NSNumber *pageSize=[NSNumber numberWithInteger:1];


        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                          @"urn:replicon:timesheet-list-column:timesheet-period",@"columnUri",
                                          @"false",@"isAscending",
                                          nil];
        [sortArray addObject:sortExpressionDict];
        //Implementation as per US9331//JUHI
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageSize,@"pageSize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",filterDict,@"filterExpression",nil];
    NSString *serviceName =@"GetFirstTimesheets";
    return [self constructOperation:queryDict withServiceName:serviceName];
}

@end
