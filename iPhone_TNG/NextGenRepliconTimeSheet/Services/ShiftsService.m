//
//  ShiftsService.m
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 20/02/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "ShiftsService.h"
#import "AppDelegate.h"
#import "RepliconServiceManager.h"
#import "TimeoffModel.h"


@implementation ShiftsService



-(void)sendRequestShiftToServiceForDataDict:(NSMutableDictionary *)dataDict
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSString *startDateString = [dataDict valueForKey:@"startDate"];
    NSString *lastDateString = [dataDict valueForKey:@"endDate"];
    NSDate *startDate = [dateFormat  dateFromString:startDateString];
    NSDate *endDate = [dateFormat  dateFromString:lastDateString];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];

    NSDateComponents *startDateComponents = [calendar components:( NSCalendarUnitYear |
                                                             NSCalendarUnitMonth |
                                                             NSCalendarUnitDay   |
                                                             NSCalendarUnitHour |
                                                             NSCalendarUnitMinute |
                                                             NSCalendarUnitSecond)
                                                   fromDate:startDate];
    
    
    NSMutableDictionary *startDateDict=[NSMutableDictionary dictionary];
    [startDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[startDateComponents day]] forKey:@"day"];
    [startDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[startDateComponents month]] forKey:@"month"];
    [startDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[startDateComponents year]] forKey:@"year"];
    
    NSDateComponents *endDateComponents = [calendar components:( NSCalendarUnitYear |
                                                             NSCalendarUnitMonth |
                                                             NSCalendarUnitDay   |
                                                             NSCalendarUnitHour |
                                                             NSCalendarUnitMinute |
                                                             NSCalendarUnitSecond)
                                                   fromDate:endDate];
    
    
    NSMutableDictionary *endDateDict=[NSMutableDictionary dictionary];
    [endDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[endDateComponents day]] forKey:@"day"];
    [endDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[endDateComponents month]] forKey:@"month"];
    [endDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[endDateComponents year]] forKey:@"year"];
    
    NSMutableDictionary *dateRangeDict=[NSMutableDictionary dictionary];
    [dateRangeDict setObject:startDateDict forKey:@"startDate"];
    [dateRangeDict setObject:endDateDict forKey:@"endDate"];
    [dateRangeDict setObject:[NSNull null] forKey:@"relativeDateRangeUri"];
    [dateRangeDict setObject:[NSNull null] forKey:@"relativeDateRangeAsOfDate"];
    

    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      dateRangeDict,@"dateRange",
                                      strUserURI,@"userUri",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetShiftSummarySeries"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetShiftSummarySeries"]];
    [self setServiceDelegate:self];
    [self executeRequest];
    
    
    
}


-(void)fetchTimeoffDataForStartDate:(NSDate*)startDate andEndDate:(NSDate *)endDate andShiftId:(NSString *)shiftId
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    //Implemented as per US7646
    NSDictionary *leftExpressionLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNull null],@"leftExpression",
                                                    [NSNull null],@"operatorUri",
                                                    [NSNull null],@"rightExpression",
                                                    [NSNull null],@"value",
                                                    @"urn:replicon:time-off-list-filter:time-off-owner",@"filterDefinitionUri",
                                                    nil];
    
    
    
    NSDictionary *leftExpressionRightExpressionValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
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
    
    NSDictionary *leftExpressionRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNull null],@"leftExpression",
                                                     [NSNull null],@"operatorUri",
                                                     [NSNull null],@"rightExpression",
                                                     leftExpressionRightExpressionValueDict,@"value",
                                                     [NSNull null],@"filterDefinitionUri",
                                                     nil];

    
    NSDictionary *leftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                      leftExpressionLeftExpressionDict,@"leftExpression",
                                      @"urn:replicon:filter-operator:equal",@"operatorUri",
                                      leftExpressionRightExpressionDict,@"rightExpression",
                                      [NSNull null],@"value",
                                      @"urn:replicon:time-off-list-filter:time-off-date-range",@"filterDefinitionUri",
                                      nil];
    
    
    
    NSDictionary *rightExpressionLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNull null],@"leftExpression",
                                                     [NSNull null],@"operatorUri",
                                                     [NSNull null],@"rightExpression",
                                                     [NSNull null],@"value",
                                                     @"urn:replicon:time-off-list-filter:time-off-date-range",@"filterDefinitionUri",
                                                     nil];
    
    NSDictionary *rightExpressionDateRangeDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                [Util convertDateToApiDateDictionary:startDate],@"startDate",
                                                [Util convertDateToApiDateDictionary:endDate],@"endDate",
                                                [NSNull null],@"relativeDateRangeAsOfDate",
                                                [NSNull null],@"relativeDateRangeUri",
                                                nil];
    
    
    
    NSDictionary *rightExpressionRightExpressionValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNull null],@"uri",
                                                           [NSNull null],@"uris",
                                                           [NSNull null],@"bool",
                                                           [NSNull null],@"date",
                                                           [NSNull null],@"money",
                                                           [NSNull null],@"number",
                                                           [NSNull null],@"text",
                                                           [NSNull null],@"time",
                                                           [NSNull null],@"calendarDayDurationValue",
                                                           [NSNull null],@"workdayDurationValue",
                                                           rightExpressionDateRangeDict,@"dateRange", nil];
    
    NSDictionary *rightExpressionRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNull null],@"leftExpression",
                                                      [NSNull null],@"operatorUri",
                                                      [NSNull null],@"rightExpression",
                                                      rightExpressionRightExpressionValueDict,@"value",
                                                      [NSNull null],@"filterDefinitionUri",
                                                      nil];
    
    

    
    

   
    
    
    NSDictionary *rightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                       rightExpressionLeftExpressionDict,@"leftExpression",
                                       @"urn:replicon:filter-operator:in",@"operatorUri",
                                       rightExpressionRightExpressionDict,@"rightExpression",
                                       [NSNull null],@"filterDefinitionUri",
                                       [NSNull null],@"value",
                                       nil];
    
    
    
    
    NSDictionary *filterExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                        leftExpressionDict,@"leftExpression",
                                        @"urn:replicon:filter-operator:and",@"operatorUri",
                                        rightExpressionDict,@"rightExpression",
                                        [NSNull null],@"value",
                                        [NSNull null],@"filterDefinitionUri",
                                        nil];
    
    
    
    
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getTimeOffColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        if ([columnName isEqualToString:@"Start Date"]||
            [columnName isEqualToString:@"End Date"]||
            [columnName isEqualToString:@"Time Off Approval Status"]||
            [columnName isEqualToString:@"Time Off"]||
            [columnName isEqualToString:@"Time Off Type"]||
            [columnName isEqualToString:@"Start Day Duration"]||
            [columnName isEqualToString:@"End Day Duration"] ||
            [columnName isEqualToString:@"Total Duration"])
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    
    
        
//        NSNumber *pageNum=[NSNumber numberWithInt:1];
        NSNumber *pageSize=[NSNumber numberWithInt:100];
    
    
    
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDateComponents *startDateComponents = [calendar components:( NSCalendarUnitYear |
                                                                  NSCalendarUnitMonth |
                                                                  NSCalendarUnitDay   |
                                                                  NSCalendarUnitHour |
                                                                  NSCalendarUnitMinute |
                                                                  NSCalendarUnitSecond)
                                                        fromDate:startDate];
    
    
    NSMutableDictionary *startDateDict=[NSMutableDictionary dictionary];
    [startDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[startDateComponents day]] forKey:@"day"];
    [startDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[startDateComponents month]] forKey:@"month"];
    [startDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[startDateComponents year]] forKey:@"year"];
    
    NSDateComponents *endDateComponents = [calendar components:( NSCalendarUnitYear |
                                                                NSCalendarUnitMonth |
                                                                NSCalendarUnitDay   |
                                                                NSCalendarUnitHour |
                                                                NSCalendarUnitMinute |
                          
                                                                NSCalendarUnitSecond)
                                                      fromDate:endDate];
    
    
    NSMutableDictionary *endDateDict=[NSMutableDictionary dictionary];
    [endDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[endDateComponents day]] forKey:@"day"];
    [endDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[endDateComponents month]] forKey:@"month"];
    [endDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[endDateComponents year]] forKey:@"year"];
    
    NSMutableDictionary *timeOffCalendarDateRangeDict=[NSMutableDictionary dictionary];
    [timeOffCalendarDateRangeDict setObject:startDateDict forKey:@"startDate"];
    [timeOffCalendarDateRangeDict setObject:endDateDict forKey:@"endDate"];
    [timeOffCalendarDateRangeDict setObject:[NSNull null] forKey:@"relativeDateRangeUri"];
    [timeOffCalendarDateRangeDict setObject:[NSNull null] forKey:@"relativeDateRangeAsOfDate"];
    
    
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          //pageNum ,@"page",
                                          pageSize,@"timeOffPagesize",
                                          requestColumnUriArray,@"timeOffColumnUris",
                                          filterExpressionDict,@"timeOffFilterExpression",
                                          [NSArray array],@"timeOffSort",
                                          timeOffCalendarDateRangeDict,@"timeOffCalendarDateRange",
                                          nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"ShiftFetchTimeOffList"]];
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"ShiftFetchTimeOffList"]];
        [self setServiceDelegate:self];
        [self executeRequest:shiftId];
        
    
}

-(void)fetchOnlyBulkGetUserHolidaySeriesForStartDate:(NSDate*)startDate andEndDate:(NSDate *)endDate andShiftId:(NSString *)shiftId
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    
    
   
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDateComponents *startDateComponents = [calendar components:( NSCalendarUnitYear |
                                                                  NSCalendarUnitMonth |
                                                                  NSCalendarUnitDay   |
                                                                  NSCalendarUnitHour |
                                                                  NSCalendarUnitMinute |
                                                                  NSCalendarUnitSecond)
                                                        fromDate:startDate];
    
    
    NSMutableDictionary *startDateDict=[NSMutableDictionary dictionary];
    [startDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[startDateComponents day]] forKey:@"day"];
    [startDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[startDateComponents month]] forKey:@"month"];
    [startDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[startDateComponents year]] forKey:@"year"];
    
    NSDateComponents *endDateComponents = [calendar components:( NSCalendarUnitYear |
                                                                NSCalendarUnitMonth |
                                                                NSCalendarUnitDay   |
                                                                NSCalendarUnitHour |
                                                                NSCalendarUnitMinute |
                                                                NSCalendarUnitSecond)
                                                      fromDate:endDate];
    
    
    NSMutableDictionary *endDateDict=[NSMutableDictionary dictionary];
    [endDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[endDateComponents day]] forKey:@"day"];
    [endDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[endDateComponents month]] forKey:@"month"];
    [endDateDict setObject:[NSString stringWithFormat:@"%ld",(long)[endDateComponents year]] forKey:@"year"];
    
    NSMutableDictionary *dateRangeDict=[NSMutableDictionary dictionary];
    [dateRangeDict setObject:startDateDict forKey:@"startDate"];
    [dateRangeDict setObject:endDateDict forKey:@"endDate"];
    [dateRangeDict setObject:[NSNull null] forKey:@"relativeDateRangeUri"];
    [dateRangeDict setObject:[NSNull null] forKey:@"relativeDateRangeAsOfDate"];
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSArray arrayWithObject:strUserURI],@"userUris",
                                      dateRangeDict,@"dateRange",
                                      nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"BulkGetUserHolidaySeries"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"BulkGetUserHolidaySeries"]];
    [self setServiceDelegate:self];
    [self executeRequest:shiftId];

    
    

}

#pragma mark - ServiceURL Response Handling

- (void) serverDidRespondWithResponse:(id) response
{
    if (response!=nil)
    {
        NSDictionary *errorDict=[[response objectForKey:@"response"]objectForKey:@"error"];
        
        id _serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
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
            
            if ([_serviceID intValue]== GetShiftSummarySeries_ID_96)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:SHIFT_CHECK_TIMEOFF_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"]];
            }
            else if ([_serviceID intValue]== ShiftFetchTimeOffList_144)
            {
                 [[NSNotificationCenter defaultCenter] postNotificationName:SHIFT_SUMMARY_RECIEVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"]];
            }
            
            
            
            
        }
        else
        {
            
            if ([_serviceID intValue]== GetShiftSummarySeries_ID_96)
            {
                [self handleShiftentryData:response];
               
                return;
            }
            else if ([_serviceID intValue]== ShiftFetchTimeOffList_144)
            {
                [self handleTimeOffFetchData:response];
                
                return;
            }
            else if ([_serviceID intValue]== BulkGetUserHolidaySeries_157)
            {
                [self handleBulkGetUserHolidaySeriesData:response];
                
                return;
            }
        }
    }

}

#pragma mark - ServiceURL Error Handling
- (void)serverDidFailWithError:(NSError *) error applicationState:(ApplicateState)applicationState
{
    
    totalRequestsServed++;
    
    
}

#pragma mark - Data handle Method

-(void)handleShiftentryData : (NSMutableDictionary*)response
{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if (responseDict!=nil)
    {
        ShiftsModel *shiftsModel = [[ShiftsModel alloc] init];
        [shiftsModel saveShiftEntryDataFromApiToDB:responseDict];
       
    }
    
     [[NSNotificationCenter defaultCenter] postNotificationName:SHIFT_CHECK_TIMEOFF_NOTIFICATION object:nil];
    
    
}

-(void)handleTimeOffFetchData : (NSMutableDictionary*)response
{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if (responseDict!=nil)
    {
        NSMutableArray *timeOffTypeDetails=[responseDict objectForKey:@"timeOffTypeDetails"];
        
        if (timeOffTypeDetails!=nil && ![timeOffTypeDetails isKindOfClass:[NSNull class]])
        {
            TimeoffModel *timeoffModel = [[TimeoffModel alloc] init];
            [timeoffModel saveTimeoffTypeDetailDataToDB:timeOffTypeDetails];
        }

        
         ShiftsModel *shiftsModel = [[ShiftsModel alloc] init];
        [shiftsModel saveTimeoffs:[responseDict objectForKey:@"timeOff"] forShiftId:[[response objectForKey:@"refDict"]objectForKey:@"params"]];
        
        NSMutableArray *companyHolidaysArray=[responseDict objectForKey:@"holidays"];
        
        if (companyHolidaysArray!=nil && ![companyHolidaysArray isKindOfClass:[NSNull class]])
        {
            if ([companyHolidaysArray count]>0)
            {
                [shiftsModel saveTimeoffCompanyHolidaysDataFromApiToDB:companyHolidaysArray forShiftId:[[response objectForKey:@"refDict"]objectForKey:@"params"]];
            }
        }
        
      

        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHIFT_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
}

-(void)handleBulkGetUserHolidaySeriesData : (NSMutableDictionary*)response
{
    NSMutableArray *responseArr=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseArr count]>0 && responseArr!=nil)
    {
        
        NSMutableArray *companyHolidaysArray=[[responseArr objectAtIndex:0] objectForKey:@"holidays"];
        if (companyHolidaysArray!=nil && ![companyHolidaysArray isKindOfClass:[NSNull class]])
        {
            if ([companyHolidaysArray count]>0)
            {
                ShiftsModel *shiftsModel = [[ShiftsModel alloc] init];
                [shiftsModel saveTimeoffCompanyHolidaysDataFromApiToDB:companyHolidaysArray forShiftId:[[response objectForKey:@"refDict"]objectForKey:@"params"]];
            }

        }
        
       
        
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHIFT_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
}

@end
