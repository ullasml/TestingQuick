//
//  TimeoffService.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 15/04/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "TimeoffService.h"
#import "RepliconServiceManager.h"
#import "AppDelegate.h"
#import "Util.h"
#import "Constants.h"
#import "BookedTimeOffEntry.h"
#import "TimesheetMainPageController.h"
#import "TimeOffDetailsObject.h"
#import "UdfObject.h"

@interface TimeoffService ()
@property(nonatomic, strong) id <SpinnerDelegate> spinnerDelegate;
@end

@implementation TimeoffService
@synthesize timeoffModel;

- (instancetype) init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark -

- (id)initWithSpinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate {
    if (self = [super init])
    {
        if(timeoffModel == nil) {
            timeoffModel = [[TimeoffModel alloc] init];
        }
        self.spinnerDelegate = spinnerDelegate;
    }
    return self;
}

#pragma mark Request Methods

/************************************************************************************************************
 @Function Name   : fetchTimeoffData
 @Purpose         : Called to get the user’s timeoff data ie timeoff date period,approval status etc
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchTimeoffData:(id)_delegate isPullToRefresh:(BOOL)isPullToRefresh
{
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.isShowTimeOffSheetPlaceHolder=FALSE;
    
    self.didSuccessfullyFetchTimeoff = NO;
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
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
                                             [NSNull null],@"filterDefinitionUri",
                                             nil];
    
    
    NSDictionary *rightExpressionLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNull null],@"leftExpression",
                                                           [NSNull null],@"operatorUri",
                                                           [NSNull null],@"rightExpression",
                                                           [NSNull null],@"value",
                                                           @"urn:replicon:time-off-list-filter:has-associated-timesheet",@"filterDefinitionUri",
                                                           nil];
    
    
  
   
    NSDictionary *rightExpressionRightExpressionValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [NSNull null],@"uri",
                                                          [NSNull null],@"uris",
                                                          @"false",@"bool",
                                                          [NSNull null],@"date",
                                                          [NSNull null],@"money",
                                                          [NSNull null],@"number",
                                                          [NSNull null],@"text",
                                                          [NSNull null],@"time",
                                                          [NSNull null],@"calendarDayDurationValue",
                                                          [NSNull null],@"workdayDurationValue",
                                                          [NSNull null],@"dateRange", nil];
   
    NSDictionary *rightExpressionRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [NSNull null],@"leftExpression",
                                                            [NSNull null],@"operatorUri",
                                                            [NSNull null],@"rightExpression",
                                                            rightExpressionRightExpressionValueDict,@"value",
                                                            [NSNull null],@"filterDefinitionUri",
                                                            nil];

    
    
    NSDictionary *rightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                       rightExpressionLeftExpressionDict,@"leftExpression",
                                       @"urn:replicon:filter-operator:equal",@"operatorUri",
                                       rightExpressionRightExpressionDict,@"rightExpression",
                                       [NSNull null],@"value",
                                       [NSNull null],@"filterDefinitionUri",
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
            [columnName isEqualToString:@"Total Duration"]||
            [columnName isEqualToString:@"Time Off Approval Status"]||
            [columnName isEqualToString:@"Time Off"]||
            [columnName isEqualToString:@"Time Off Type"] ||
            [columnName isEqualToString:@"Total Effective Workdays"] ||
            [columnName isEqualToString:@"Total Effective Hours"] ||
            [columnName isEqualToString:@"Time Off Type Display Format"]
            )
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        
        NSNumber *pageNum=[NSNumber numberWithInt:1];
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"timeoffDownloadCount"];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:pageNum forKey:@"NextTimeoffPageNo"];
        [defaults synchronize];
        
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                          @"urn:replicon:time-off-list-column:start-date",@"columnUri",
                                          @"false",@"isAscending",
                                          nil];
        [sortArray addObject:sortExpressionDict];
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageSize,@"timeOffPagesize",
                                          requestColumnUriArray,@"timeOffColumnUris",
                                          sortArray,@"timeOffSort",
                                          filterExpressionDict,@"timeOffFilterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTimeoffData"]];
            

        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        if (isPullToRefresh)
        {
            [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetRefreshedTimeoffData"]];
        }
        else
        {
            [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetTimeoffData"]];
        }
        
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }


}


/************************************************************************************************************
 @Function Name   : fetchNextRecentTimeoffData
 @Purpose         : Called to get the user’s next set of timeoff data
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchNextRecentTimeoffData:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
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
                                             [NSNull null],@"filterDefinitionUri",
                                             nil];
    
    
    NSDictionary *rightExpressionLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [NSNull null],@"leftExpression",
                                                            [NSNull null],@"operatorUri",
                                                            [NSNull null],@"rightExpression",
                                                            [NSNull null],@"value",
                                                            @"urn:replicon:time-off-list-filter:has-associated-timesheet",@"filterDefinitionUri",
                                                            nil];
    
    
    
    
    NSDictionary *rightExpressionRightExpressionValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNull null],@"uri",
                                                           [NSNull null],@"uris",
                                                            @"false",@"bool",
                                                           [NSNull null],@"date",
                                                           [NSNull null],@"money",
                                                           [NSNull null],@"number",
                                                           [NSNull null],@"text",
                                                           [NSNull null],@"time",
                                                           [NSNull null],@"calendarDayDurationValue",
                                                           [NSNull null],@"workdayDurationValue",
                                                           [NSNull null],@"dateRange", nil];
    
    NSDictionary *rightExpressionRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [NSNull null],@"leftExpression",
                                                             [NSNull null],@"operatorUri",
                                                             [NSNull null],@"rightExpression",
                                                             rightExpressionRightExpressionValueDict,@"value",
                                                             [NSNull null],@"filterDefinitionUri",
                                                             nil];
    
    
    
    NSDictionary *rightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                       rightExpressionLeftExpressionDict,@"leftExpression",
                                       @"urn:replicon:filter-operator:equal",@"operatorUri",
                                       rightExpressionRightExpressionDict,@"rightExpression",
                                       [NSNull null],@"value",
                                       [NSNull null],@"filterDefinitionUri",
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
            [columnName isEqualToString:@"Total Duration"]||
            [columnName isEqualToString:@"Time Off Approval Status"]||
            [columnName isEqualToString:@"Time Off"]||
            [columnName isEqualToString:@"Time Off Type"] ||
            [columnName isEqualToString:@"Total Effective Workdays"] ||
            [columnName isEqualToString:@"Total Effective Hours"] ||
            [columnName isEqualToString:@"Time Off Type Display Format"]
            )
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {

        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        int nextFetchPageNo=[[defaults objectForKey:@"NextTimeoffPageNo"] intValue];
        NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
        [defaults setObject:nextFetchPageNumber forKey:@"NextTimeoffPageNo"];
        [defaults synchronize];
        
        NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"timeoffDownloadCount"];
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                          @"urn:replicon:time-off-list-column:start-date",@"columnUri",
                                          @"false",@"isAscending",
                                          nil];
        [sortArray addObject:sortExpressionDict];
        
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageNum ,@"page",
                                          pageSize,@"pagesize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",
                                          filterExpressionDict,@"filterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetNextTimeoffData"]];
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextTimeoffData"]];
        [self setServiceDelegate:self];
        [self executeRequest];

    }
}


/************************************************************************************************************
 @Function Name   : fetchTimeoffCompanyHolidaysData
 @Purpose         : Called to get company holidays
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchTimeoffCompanyHolidaysData:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
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
    
    
    NSDate *startDate = [calendar dateFromComponents:datecomponents];
    
    [datecomponents setYear:year+1]; //Next Year
    [datecomponents setMonth:12];
    [datecomponents setDay:31];
    [datecomponents setHour:0];
    [datecomponents setMinute:0];
    [datecomponents setSecond:0];
    
    NSDate *endDate = [calendar dateFromComponents:datecomponents];
    


    
    NSMutableDictionary *dateRangeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [Util convertDateToApiDateDictionary:startDate],@"startDate",
                                      [Util convertDateToApiDateDictionary:endDate],@"endDate",
                                      [NSNull null],@"relativeDateRangeUri",
                                      [NSNull null],@"relativeDateRangeAsOfDate",nil];
    
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *holidayCalendarUri=[defaults objectForKey:@"holidayCalendarURI"];

    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      holidayCalendarUri,@"holidayCalendarUri",
                                      dateRangeDict,@"dateRange",
                                      nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetCompanyHolidays"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetCompanyHolidays"]];
    [self setServiceDelegate:self];
    [self executeRequest];

}
/************************************************************************************************************
 @Function Name   : fetchTimeoffEntryDataForBookedTimeoff
 @Purpose         : Called to get the timeoff entry data for timeoffUri
 @param           : timeoffUri,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchTimeoffEntryDataForBookedTimeoff:(NSString *)timeoffUri withTimeSheetUri:(NSString *)timesheetUri
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timeoffUri ,@"timeOffUri",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTimeoffEntryData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetTimeoffEntryData"]];
    [self setServiceDelegate:self];
    [self executeRequest];
    
}
-(void)sendRequestToSaveBookedTimeOffDataForTimeoffURI:(NSString *)timesheetURI withEntryArray:(NSMutableArray *)timeoffEntryObjectArray andUdfArray:(NSMutableArray *)udfArray withDelegate:(id)delegate{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    NSMutableDictionary *owner=[NSMutableDictionary dictionaryWithObjectsAndKeys:strUserURI,@"uri",[NSNull null],@"loginName",nil];
    id comments=@"";
    
    id customField=[NSNull null];
    NSMutableArray *customFieldArray=[NSMutableArray array];
    if (udfArray!=nil&&[udfArray count]>0)
    {
        for (int i=0; i<[udfArray count]; i++)
        {
            NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
            
            UdfObject *udfObj = [udfArray objectAtIndex:i];
                        NSString *udfUri=udfObj.udfUri;
            if (udfObj.udfType == UDF_TYPE_TEXT)
            {
                NSString *defaultValue=udfObj.defaultValue;
                if (defaultValue!=nil && (![defaultValue isEqualToString:@""] && ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                {
                    [dataDict setObject:defaultValue forKey:@"text"];
                }
                else
                {
                    [dataDict setObject:[NSNull null] forKey:@"text"];
                }
                
                [dataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                [dataDict setObject:[NSNull null] forKey:@"date"];
                [dataDict setObject:[NSNull null] forKey:@"number"];
                
            }
            else if (udfObj.udfType == UDF_TYPE_NUMERIC)
            {
                NSString *defaultValue=udfObj.defaultValue;
                
                if (defaultValue!=nil && (![defaultValue isEqualToString:RPLocalizedString(ADD, @"")] && ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                {
                    [dataDict setObject:[NSNumber numberWithDouble:[defaultValue newDoubleValue]] forKey:@"number"];
                }
                else
                {
                    [dataDict setObject:[NSNull null] forKey:@"number"];
                }
                [dataDict setObject:[NSNull null] forKey:@"text"];
                [dataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                [dataDict setObject:[NSNull null] forKey:@"date"];
                
            }
            else if (udfObj.udfType == UDF_TYPE_DATE)
            {
                
                NSString *defaultValue=udfObj.defaultValue;
                
                
                if (defaultValue!=nil && (![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")] && ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    
                    NSLocale *locale=[NSLocale currentLocale];
                    [dateFormatter setLocale:locale];
                    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
                    NSDate *dropdownDateValue	=[dateFormatter dateFromString:defaultValue];
                    
                    if (dropdownDateValue!=nil )
                    {
                        NSDictionary *dateDict=[Util convertDateToApiDateDictionary:dropdownDateValue];
                        [dataDict setObject:dateDict      forKey:@"date"];
                    }
                    else
                    {
                        [dataDict setObject:[NSNull null]      forKey:@"date"];
                    }
                    
                }
                else
                {
                    [dataDict setObject:[NSNull null]      forKey:@"date"];
                }
                
                
                [dataDict setObject:[NSNull null] forKey:@"text"];
                [dataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                [dataDict setObject:[NSNull null] forKey:@"number"];
            }
            else if (udfObj.udfType == UDF_TYPE_DROPDOWN)
            {
               NSString *defaultValue=udfObj.dropDownOptionUri;;
                //Implemetation For MOBI-300//JUHI
                if (defaultValue!=nil && ![defaultValue isKindOfClass:[NSNull class]])
                {
                    if (![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")] && ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
                    {
                        NSMutableDictionary *dropDownOptionDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                 defaultValue,@"uri",
                                                                 [NSNull null],@"name",
                                                                 nil];
                        [dataDict setObject:dropDownOptionDict  forKey:@"dropDownOption"];
                    }
                }
                else
                {
                    [dataDict setObject:[NSNull null]  forKey:@"dropDownOption"];
                }
                
                [dataDict setObject:[NSNull null]  forKey:@"text"];
                [dataDict setObject:[NSNull null]  forKey:@"date"];
                [dataDict setObject:[NSNull null]  forKey:@"number"];
            }
            NSMutableDictionary *customFieldDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  udfUri,@"uri",
                                                  [NSNull null],@"name",
                                                  [NSNull null],@"groupUri",
                                                  nil];
            [dataDict setObject:customFieldDict        forKey:@"customField"];
            
            [customFieldArray addObject:dataDict];
        }
        customField=customFieldArray;
    }
    
    
    NSMutableDictionary *entryDict=[NSMutableDictionary dictionary];
    
    id resubmitComments=[NSNull null];
    
    for (int i=0;i<[timeoffEntryObjectArray count]; i++)
    {
        BookedTimeOffEntry *timeOffEntryObject=(BookedTimeOffEntry *)[timeoffEntryObjectArray objectAtIndex:i];
        
        if ([timeOffEntryObject resubmitComments]!=nil)
        {
            resubmitComments=[timeOffEntryObject resubmitComments];
        }
        
        
        comments=[timeOffEntryObject comments];
        if (comments==nil||[comments isKindOfClass:[NSNull class]])
        {
            comments=@"";
        }
        NSString *timeoffTypeUri=nil;
        NSString *timeoffTypeName=nil;
        
        if ([timeOffEntryObject typeIdentity]!=nil && ![[timeOffEntryObject typeIdentity] isKindOfClass:[NSNull class]])
        {
            timeoffTypeUri=[timeOffEntryObject typeIdentity];
            timeoffTypeName=[timeOffEntryObject typeName];
        }
        
        NSMutableDictionary *timeoffTypeDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeoffTypeUri,@"uri",timeoffTypeName,@"name",nil];
        
        NSDateFormatter *temp = [[NSDateFormatter alloc] init];
        [temp setDateFormat:@"yyyy-MM-dd"];
        
        NSLocale *locale=[NSLocale currentLocale];
        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [temp setTimeZone:timeZone];
        [temp setLocale:locale];
       
        NSDate *stDt = [temp dateFromString:[temp stringFromDate:[timeOffEntryObject bookedStartDate]]];
        NSDate *endDt =  [temp dateFromString:[temp stringFromDate:[timeOffEntryObject bookedEndDate]]];
        
        
        
        if ((stDt!=nil && endDt!=nil) && [stDt compare:endDt]==NSOrderedSame)
        {
            NSDictionary *dict=[Util convertDateToApiDateDictionary:[timeOffEntryObject bookedStartDate]];
            int year=[[dict objectForKey:@"year"] intValue];
            int month=[[dict objectForKey:@"month"]intValue];
            int day=[[dict objectForKey:@"day"]intValue];;
            
            NSMutableDictionary *dateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"%d",year],@"year",
                                           [NSString stringWithFormat:@"%d",month],@"month",
                                           [NSString stringWithFormat:@"%d",day],@"day",
                                           nil];
            
            
            
            NSString *startTime=[timeOffEntryObject startTime];
            id startTimeOfDay;
            if (startTime!=nil && ![startTime isEqualToString:RPLocalizedString(START_AT, START_AT)])
            {
                startTime = [Util convert12HourTimeStringTo24HourTimeString:[startTime lowercaseString]];
                NSArray *inTimeComponentsArray=[startTime componentsSeparatedByString:@":"];
                int inHours=0;
                int inMinutes=0;
                int inSeconds=0;
                if ([inTimeComponentsArray count]>1)
                {
                    inHours=[[inTimeComponentsArray objectAtIndex:0] intValue];
                    inMinutes=[[inTimeComponentsArray objectAtIndex:1] intValue];
                }
                
                NSMutableDictionary *startTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      [NSString stringWithFormat:@"%d",inHours],@"hour",
                                                      [NSString stringWithFormat:@"%d",inMinutes],@"minute",
                                                      [NSString stringWithFormat:@"%d",inSeconds],@"second",
                                                      nil];
                startTimeOfDay=startTimeDict;
                
            }
            
            else
                startTimeOfDay=[NSNull null];
            
            NSString *entryHours=[timeOffEntryObject startNumberOfHours];
            id startSpecficDuration;
            if (entryHours!=nil) {
                NSMutableDictionary *durationDict = [Util convertDecimalHoursToApiTimeDict:entryHours];
                startSpecficDuration=durationDict;
            }
            else
                startSpecficDuration=[NSNull null];
            
            id relativeDuration=[timeOffEntryObject startDurationEntryType];
            //Fix for defect DE15385
            if ([relativeDuration isEqualToString:PARTIAL])
            {
                relativeDuration=[NSNull null];
            }
            id specfdict;
            id timedict;
            if ([[timeOffEntryObject startDurationEntryType] isEqualToString:FULLDAY_DURATION_TYPE_KEY]) {
                specfdict=[NSNull null];
                timedict=[NSNull null];
            }
            else
            {
                //Fix for defect DE15385
                if (![[timeOffEntryObject startDurationEntryType] isEqualToString:PARTIAL])
                    specfdict=[NSNull null];
                else
                    specfdict=startSpecficDuration;
                
                timedict=startTimeOfDay;
            }
            NSMutableDictionary *timeoffAllocationEntryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:specfdict,@"specificDuration",dateDict,@"date",timedict,@"timeOfDay",relativeDuration,@"relativeDuration",
                                                             nil];
            
            
            NSMutableDictionary *timeOff=[NSMutableDictionary dictionaryWithObject:timeoffAllocationEntryDict forKey:@"timeOff"];
            
            id timeoffUri;
            if ([timeOffEntryObject sheetId]!=nil && ![[timeOffEntryObject sheetId] isKindOfClass:[NSNull class]]) {
                timeoffUri=[timeOffEntryObject sheetId];
            }
            else
                timeoffUri=[NSNull null];
            NSMutableDictionary *target=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeoffUri,@"uri",nil];
            
            entryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         target,@"target",
                         owner,@"owner",
                         timeoffTypeDict,@"timeOffType",
                         timeOff,@"singleDay",
                         [NSNull null],@"multiDay",
                         customField,@"customFieldValues",
                         comments,@"comments",
                         nil];
            
        }
        else {
            NSDictionary *dict=[Util convertDateToApiDateDictionary:[timeOffEntryObject bookedStartDate]];
            int year=[[dict objectForKey:@"year"] intValue];
            int month=[[dict objectForKey:@"month"]intValue];
            int day=[[dict objectForKey:@"day"]intValue];;
            
            NSMutableDictionary *dateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"%d",year],@"year",
                                           [NSString stringWithFormat:@"%d",month],@"month",
                                           [NSString stringWithFormat:@"%d",day],@"day",
                                           nil];
            
            
            
            NSString *startTime=[timeOffEntryObject startTime];
            id startTimeOfDay;
            if (startTime!=nil && ![startTime isEqualToString:RPLocalizedString(START_AT, START_AT)])
            {
                startTime = [Util convert12HourTimeStringTo24HourTimeString:[startTime lowercaseString]];
                NSArray *inTimeComponentsArray=[startTime componentsSeparatedByString:@":"];
                int inHours=0;
                int inMinutes=0;
                int inSeconds=0;
                if ([inTimeComponentsArray count]>1)
                {
                    inHours=[[inTimeComponentsArray objectAtIndex:0] intValue];
                    inMinutes=[[inTimeComponentsArray objectAtIndex:1] intValue];
                }
                
                NSMutableDictionary *startTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      [NSString stringWithFormat:@"%d",inHours],@"hour",
                                                      [NSString stringWithFormat:@"%d",inMinutes],@"minute",
                                                      [NSString stringWithFormat:@"%d",inSeconds],@"second",
                                                      nil];
                startTimeOfDay=startTimeDict;
                
            }
            
            else
                startTimeOfDay=[NSNull null];
            
            
            NSString *entryHours=[timeOffEntryObject startNumberOfHours];
            id startSpecficDuration;
            if (entryHours!=nil) {
                
                NSMutableDictionary *durationDict = [Util convertDecimalHoursToApiTimeDict:entryHours];
                startSpecficDuration=durationDict;
            }
            else
                startSpecficDuration=[NSNull null];
            
            id relativeDuration=[timeOffEntryObject startDurationEntryType];
            //Fix for defect DE15385
            if ([relativeDuration isEqualToString:PARTIAL])
            {
                relativeDuration=[NSNull null];
            }
            
            id startspecfdict;
            id starttimedict;
            if ([[timeOffEntryObject startDurationEntryType] isEqualToString:FULLDAY_DURATION_TYPE_KEY]) {
                startspecfdict=[NSNull null];
                starttimedict=[NSNull null];
            }
            else
            {
                //Fix for defect DE15385
                if (![[timeOffEntryObject startDurationEntryType] isEqualToString:PARTIAL])
                    startspecfdict=[NSNull null];
                else
                    startspecfdict=startSpecficDuration;
                
                starttimedict=startTimeOfDay;
            }
            NSMutableDictionary *timeOffStartAllocationEntryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:startspecfdict,@"specificDuration",dateDict,@"date",starttimedict,@"timeOfDay",relativeDuration,@"relativeDuration",
                                                                  nil];
            
            
            NSDictionary *endDict=[Util convertDateToApiDateDictionary:[timeOffEntryObject bookedEndDate]];
            int endyear=[[endDict objectForKey:@"year"] intValue];
            int endmonth=[[endDict objectForKey:@"month"]intValue];
            int endday=[[endDict objectForKey:@"day"]intValue];;
            
            NSMutableDictionary *enddateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [NSString stringWithFormat:@"%d",endyear],@"year",
                                              [NSString stringWithFormat:@"%d",endmonth],@"month",
                                              [NSString stringWithFormat:@"%d",endday],@"day",
                                              nil];
            
            
            
            NSString *endTime=[timeOffEntryObject endTime];
            id endTimeOfDay;
            if (endTime!=nil&& ![endTime isEqualToString:RPLocalizedString(END_AT, END_AT)])
            {
                
                endTime = [Util convert12HourTimeStringTo24HourTimeString:[endTime lowercaseString]];
                NSArray *endTimeComponentsArray=[endTime componentsSeparatedByString:@":"];
                int endHours=0;
                int endMinutes=0;
                int endSeconds=0;
                if ([endTimeComponentsArray count]>1)
                {
                    endHours=[[endTimeComponentsArray objectAtIndex:0] intValue];
                    endMinutes=[[endTimeComponentsArray objectAtIndex:1] intValue];
                }
                
                NSMutableDictionary *endTimeDict= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   [NSString stringWithFormat:@"%d",endHours],@"hour",
                                                   [NSString stringWithFormat:@"%d",endMinutes],@"minute",
                                                   [NSString stringWithFormat:@"%d",endSeconds],@"second",
                                                   nil];
                endTimeOfDay=endTimeDict;
                
            }
            else
                endTimeOfDay=[NSNull null];
            NSString *endentryHours=[timeOffEntryObject endNumberOfHours];
            id endSpecficDuration;
            if (endentryHours!=nil)
            {
                NSMutableDictionary *enddurationDict = [Util convertDecimalHoursToApiTimeDict:endentryHours];
                endSpecficDuration=enddurationDict;
            }
            else
                endSpecficDuration=[NSNull null];
            id endrelativeDuration=[timeOffEntryObject endDurationEntryType];
            //Fix for defect DE15385
            if ([endrelativeDuration isEqualToString:PARTIAL])
            {
                endrelativeDuration=[NSNull null];
            }
            id endspecfdict;
            id endtimedict;
            if ([[timeOffEntryObject endDurationEntryType] isEqualToString:FULLDAY_DURATION_TYPE_KEY]) {
                endspecfdict=[NSNull null];
                endtimedict=[NSNull null];
            }
            else
            {
                //Fix for defect DE15385
                if (![[timeOffEntryObject endDurationEntryType] isEqualToString:PARTIAL])
                    endspecfdict=[NSNull null];
                else
                    endspecfdict=endSpecficDuration;
                
                endtimedict=endTimeOfDay;
            }
            
            NSMutableDictionary *timeOffEndAllocationEntryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:endspecfdict,@"specificDuration",enddateDict,@"date",endtimedict,@"timeOfDay",endrelativeDuration,@"relativeDuration",
                                                                nil];
            
            
            
            NSMutableDictionary *timeOff=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeOffStartAllocationEntryDict,@"timeOffStart",timeOffEndAllocationEntryDict,@"timeOffEnd",nil];
            
            id timeoffUri;
            if ([timeOffEntryObject sheetId]!=nil && ![[timeOffEntryObject sheetId] isKindOfClass:[NSNull class]]) {
                timeoffUri=[timeOffEntryObject sheetId];
            }
            else
                timeoffUri=[NSNull null];
            NSMutableDictionary *target=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeoffUri,@"uri",nil];
            
            entryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         target,@"target",
                         owner,@"owner",
                         timeoffTypeDict,@"timeOffType",
                         [NSNull null],@"singleDay",
                         timeOff,@"multiDay",
                         customField,@"customFieldValues",
                         comments,@"comments",
                         nil];
            
        }
        
    }
    
    
       
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      entryDict,@"data",
                                      [Util getRandomGUID],@"unitOfWorkId",
                                      resubmitComments,@"comments",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"SaveTimeoffData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"SaveTimeoffData"]];
    [self setServiceDelegate:self];
    [self executeRequest];
    
    
}

-(void)sendRequestToDeleteTimeoffDataForURI:(NSString *)timeoffUri
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timeoffUri ,@"timeOffUri",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"DeleteTimeOffData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"DeleteTimeOffData"]];
    [self setServiceDelegate:self];
    [self executeRequest];

}
-(void)sendRequestToBookedTimeOffBalancesDataForTimeoffURI:(NSString *)timesheetURI withEntryArray:(NSMutableArray *)timeoffEntryObjectArray withDelegate:(NavigationFlow)delegate{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;

    int count=[[[NSUserDefaults standardUserDefaults] objectForKey:@"LastBalanceValue"] intValue]+1;
 
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:count] forKey:@"LastBalanceValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
   /* if (delegate == TIMESHEET_PERIOD_NAVIGATION)
    {
        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;
        if (ctrl.userUri!=nil && ![ctrl.userUri isKindOfClass:[NSNull class]] &&![ctrl.userUri isEqualToString:@""])
        {
            strUserURI=ctrl.userUri;
        }
        
    }*/
    NSMutableDictionary *owner=[NSMutableDictionary dictionaryWithObjectsAndKeys:strUserURI,@"uri",[NSNull null],@"loginName",nil];
    id comments=@"";
    NSMutableDictionary *entryDict=[NSMutableDictionary dictionary];
    for (int i=0;i<[timeoffEntryObjectArray count]; i++)
    {
        TimeOffDetailsObject *timeOffEntryObject=(TimeOffDetailsObject *)[timeoffEntryObjectArray objectAtIndex:i];
        
        comments=[timeOffEntryObject comments];
        if (comments==nil||[comments isKindOfClass:[NSNull class]])
        {
            comments=@"";
        }
        NSString *timeoffTypeUri=nil;
        NSString *timeoffTypeName=nil;
        
        if ([timeOffEntryObject typeIdentity]!=nil && ![[timeOffEntryObject typeIdentity] isKindOfClass:[NSNull class]])
        {
            timeoffTypeUri=[timeOffEntryObject typeIdentity];
            timeoffTypeName=[timeOffEntryObject typeName];
        }
        
        NSMutableDictionary *timeoffTypeDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeoffTypeUri,@"uri",timeoffTypeName,@"name",nil];
        
        NSDateFormatter *temp = [[NSDateFormatter alloc] init];
        [temp setDateFormat:@"yyyy-MM-dd"];
        
        NSLocale *locale=[NSLocale currentLocale];
        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [temp setTimeZone:timeZone];
        [temp setLocale:locale];
        
        NSDate *stDt = [temp dateFromString:[temp stringFromDate:[timeOffEntryObject bookedStartDate]]];
        NSDate *endDt =  [temp dateFromString:[temp stringFromDate:[timeOffEntryObject bookedEndDate]]];
       
        
        
        if ((stDt!=nil && endDt!=nil) && [stDt compare:endDt]==NSOrderedSame)
        {
            int year = 2001;
            int month =1;
            int day = 1;
            
            if ([timeOffEntryObject bookedStartDate] != nil && ![[timeOffEntryObject bookedStartDate]  isKindOfClass:[NSNull class]]) {
                NSDictionary *dict=[Util convertDateToApiDateDictionary:[timeOffEntryObject bookedStartDate]];
                year=[[dict objectForKey:@"year"] intValue];
                month=[[dict objectForKey:@"month"]intValue];
                day=[[dict objectForKey:@"day"]intValue];;
            }
            
            NSMutableDictionary *dateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"%d",year],@"year",
                                           [NSString stringWithFormat:@"%d",month],@"month",
                                           [NSString stringWithFormat:@"%d",day],@"day",
                                           nil];
            
            
            
            NSString *startTime=[timeOffEntryObject startTime];
            id startTimeOfDay;
            if (startTime!=nil &&![startTime isKindOfClass:[NSNull class]] && ![startTime isEqualToString:RPLocalizedString(START_AT, START_AT)])
            {
                startTime = [Util convert12HourTimeStringTo24HourTimeString:[startTime lowercaseString]];
                NSArray *inTimeComponentsArray=[startTime componentsSeparatedByString:@":"];
                int inHours=0;
                int inMinutes=0;
                int inSeconds=0;
                if ([inTimeComponentsArray count]>1)
                {
                    inHours=[[inTimeComponentsArray objectAtIndex:0] intValue];
                    inMinutes=[[inTimeComponentsArray objectAtIndex:1] intValue];
                }
                
                NSMutableDictionary *startTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      [NSString stringWithFormat:@"%d",inHours],@"hour",
                                                      [NSString stringWithFormat:@"%d",inMinutes],@"minute",
                                                      [NSString stringWithFormat:@"%d",inSeconds],@"second",
                                                      nil];
                startTimeOfDay=startTimeDict;
                
            }
            
            else
                startTimeOfDay=[NSNull null];
            
            NSString *entryHours=[timeOffEntryObject startNumberOfHours];
            id startSpecficDuration;
            if (entryHours!=nil) {
                NSMutableDictionary *durationDict = [Util convertDecimalHoursToApiTimeDict:entryHours];
                startSpecficDuration=durationDict;
            }
            else
                startSpecficDuration=[NSNull null];
            
            id relativeDuration=[timeOffEntryObject startDurationEntryType];
            //Fix for defect DE15385
            if ([relativeDuration isEqualToString:PARTIAL])
            {
                relativeDuration=[NSNull null];
            }
            id specfdict;
            id timedict;
            if ([[timeOffEntryObject startDurationEntryType] isEqualToString:FULLDAY_DURATION_TYPE_KEY]) {
                specfdict=[NSNull null];
                timedict=[NSNull null];
            }
            else
            {
                //Fix for defect DE15385
                if (![[timeOffEntryObject startDurationEntryType] isEqualToString:PARTIAL])
                    specfdict=[NSNull null];
                else
                    specfdict=startSpecficDuration;
                
                timedict=startTimeOfDay;
            }
            NSMutableDictionary *timeoffAllocationEntryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:specfdict,@"specificDuration",dateDict,@"date",timedict,@"timeOfDay",relativeDuration,@"relativeDuration",
                                                             nil];
            
            
            NSMutableDictionary *timeOff=[NSMutableDictionary dictionaryWithObject:timeoffAllocationEntryDict forKey:@"timeOff"];
            
            id timeoffUri;
            if ([timeOffEntryObject sheetId]!=nil && ![[timeOffEntryObject sheetId] isKindOfClass:[NSNull class]]) {
                timeoffUri=[timeOffEntryObject sheetId];
            }
            else
                timeoffUri=[NSNull null];
            NSMutableDictionary *target=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeoffUri,@"uri",nil];
            
            entryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         target,@"target",
                         owner,@"owner",
                         timeoffTypeDict,@"timeOffType",
                         timeOff,@"singleDay",
                         [NSNull null],@"multiDay",
                         [NSNull null],@"customFieldValues",
                         [NSNull null],@"comments",
                         nil];
            
        }
        else {
            int year = 2001;
            int month =1;
            int day = 1;
            
            if ([timeOffEntryObject bookedStartDate] != nil && ![[timeOffEntryObject bookedStartDate]  isKindOfClass:[NSNull class]]) {
                NSDictionary *dict=[Util convertDateToApiDateDictionary:[timeOffEntryObject bookedStartDate]];
                year=[[dict objectForKey:@"year"] intValue];
                month=[[dict objectForKey:@"month"]intValue];
                day=[[dict objectForKey:@"day"]intValue];;
            }

            
            NSMutableDictionary *dateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"%d",year],@"year",
                                           [NSString stringWithFormat:@"%d",month],@"month",
                                           [NSString stringWithFormat:@"%d",day],@"day",
                                           nil];
            
            
            
            NSString *startTime=[timeOffEntryObject startTime];
            id startTimeOfDay;
            if (startTime!=nil &&![startTime isKindOfClass:[NSNull class]] && ![startTime isEqualToString:RPLocalizedString(START_AT, START_AT)])
            {
                startTime = [Util convert12HourTimeStringTo24HourTimeString:[startTime lowercaseString]];
                NSArray *inTimeComponentsArray=[startTime componentsSeparatedByString:@":"];
                int inHours=0;
                int inMinutes=0;
                int inSeconds=0;
                if ([inTimeComponentsArray count]>1)
                {
                    inHours=[[inTimeComponentsArray objectAtIndex:0] intValue];
                    inMinutes=[[inTimeComponentsArray objectAtIndex:1] intValue];
                }
                
                NSMutableDictionary *startTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      [NSString stringWithFormat:@"%d",inHours],@"hour",
                                                      [NSString stringWithFormat:@"%d",inMinutes],@"minute",
                                                      [NSString stringWithFormat:@"%d",inSeconds],@"second",
                                                      nil];
                startTimeOfDay=startTimeDict;
                
            }
            
            else
                startTimeOfDay=[NSNull null];
            
            
            NSString *entryHours=[timeOffEntryObject startNumberOfHours];
            id startSpecficDuration;
            if (entryHours!=nil) {
                NSMutableDictionary *durationDict = [Util convertDecimalHoursToApiTimeDict:entryHours];
                startSpecficDuration=durationDict;
            }
            else
                startSpecficDuration=[NSNull null];
            id relativeDuration=[timeOffEntryObject startDurationEntryType];
            //Fix for defect DE15385
            if ([relativeDuration isEqualToString:PARTIAL])
            {
                relativeDuration=[NSNull null];
            }
            
            id startspecfdict;
            id starttimedict;
            if ([[timeOffEntryObject startDurationEntryType] isEqualToString:FULLDAY_DURATION_TYPE_KEY]) {
                startspecfdict=[NSNull null];
                starttimedict=[NSNull null];
            }
            else
            {
                //Fix for defect DE15385
                if (![[timeOffEntryObject startDurationEntryType] isEqualToString:PARTIAL])
                    startspecfdict=[NSNull null];
                else
                    startspecfdict=startSpecficDuration;
                
                starttimedict=startTimeOfDay;
            }
            NSMutableDictionary *timeOffStartAllocationEntryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:startspecfdict,@"specificDuration",dateDict,@"date",starttimedict,@"timeOfDay",relativeDuration,@"relativeDuration",
                                                                  nil];
            
            int endyear = 2001;
            int endmonth =1;
            int endday = 1;
            
            if ([timeOffEntryObject bookedEndDate] != nil && ![[timeOffEntryObject bookedEndDate]  isKindOfClass:[NSNull class]]) {
                NSDictionary *endDict=[Util convertDateToApiDateDictionary:[timeOffEntryObject bookedEndDate]];
                endyear=[[endDict objectForKey:@"year"] intValue];
                endmonth=[[endDict objectForKey:@"month"]intValue];
                endday=[[endDict objectForKey:@"day"]intValue];;
            }

            
            
            NSMutableDictionary *enddateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [NSString stringWithFormat:@"%d",endyear],@"year",
                                              [NSString stringWithFormat:@"%d",endmonth],@"month",
                                              [NSString stringWithFormat:@"%d",endday],@"day",
                                              nil];
            
            
            
            NSString *endTime=[timeOffEntryObject endTime];
            id endTimeOfDay;
            if (endTime!=nil &&![endTime isKindOfClass:[NSNull class]]&& ![endTime isEqualToString:RPLocalizedString(END_AT, END_AT)])
            {
                
                endTime = [Util convert12HourTimeStringTo24HourTimeString:[endTime lowercaseString]];
                NSArray *endTimeComponentsArray=[endTime componentsSeparatedByString:@":"];
                int endHours=0;
                int endMinutes=0;
                int endSeconds=0;
                if ([endTimeComponentsArray count]>1)
                {
                    endHours=[[endTimeComponentsArray objectAtIndex:0] intValue];
                    endMinutes=[[endTimeComponentsArray objectAtIndex:1] intValue];
                }
                
                NSMutableDictionary *endTimeDict= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   [NSString stringWithFormat:@"%d",endHours],@"hour",
                                                   [NSString stringWithFormat:@"%d",endMinutes],@"minute",
                                                   [NSString stringWithFormat:@"%d",endSeconds],@"second",
                                                   nil];
                endTimeOfDay=endTimeDict;
                
            }
            else
                endTimeOfDay=[NSNull null];
            NSString *endentryHours=[timeOffEntryObject endNumberOfHours];
            id endSpecficDuration=nil;
            if (endentryHours!=nil)
            {
                
                NSMutableDictionary *enddurationDict = [Util convertDecimalHoursToApiTimeDict:endentryHours];
                endSpecficDuration=enddurationDict;
            }
            else
                endSpecficDuration=[NSNull null];
            id endrelativeDuration=[timeOffEntryObject endDurationEntryType];
            //Fix for defect DE15385
            if ([endrelativeDuration isEqualToString:PARTIAL])
            {
                endrelativeDuration=[NSNull null];
            }
            id endspecfdict;
            id endtimedict;
            if ([[timeOffEntryObject endDurationEntryType] isEqualToString:FULLDAY_DURATION_TYPE_KEY]) {
                endspecfdict=[NSNull null];
                endtimedict=[NSNull null];
            }
            else
            {
                //Fix for defect DE15385
                if (![[timeOffEntryObject endDurationEntryType] isEqualToString:PARTIAL])
                    endspecfdict=[NSNull null];
                else
                    endspecfdict=endSpecficDuration;
                
                endtimedict=endTimeOfDay;
            }
            
            NSMutableDictionary *timeOffEndAllocationEntryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:endspecfdict,@"specificDuration",enddateDict,@"date",endtimedict,@"timeOfDay",endrelativeDuration,@"relativeDuration",
                                                                nil];
            
            
            
            NSMutableDictionary *timeOff=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeOffStartAllocationEntryDict,@"timeOffStart",timeOffEndAllocationEntryDict,@"timeOffEnd",nil];
            
            id timeoffUri;
            if ([timeOffEntryObject sheetId]!=nil && ![[timeOffEntryObject sheetId] isKindOfClass:[NSNull class]]) {
                timeoffUri=[timeOffEntryObject sheetId];
            }
            else
                timeoffUri=[NSNull null];
            NSMutableDictionary *target=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeoffUri,@"uri",nil];
            
            entryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         target,@"target",
                         owner,@"owner",
                         timeoffTypeDict,@"timeOffType",
                         [NSNull null],@"singleDay",
                         timeOff,@"multiDay",
                         [NSNull null],@"customFieldValues",
                         comments,@"comments",
                         nil];
            
        }
        
    }
    NSMutableDictionary *countDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:count],@"LastBlanaceValueStored",
                                    nil];
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      entryDict,@"timeOff",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTimeOffBalanceSummaryAfterTimeOff"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetTimeOffBalanceSummaryAfterTimeOff"]];
    [self setServiceDelegate:self];
    [self executeRequest:countDict];
    
    
}//Implemented Resubmit As Per US7631
-(void)sendRequestToResubmitBookedTimeOffDataForTimeoffURI:(NSString *)timesheetURI withEntryArray:(NSMutableArray *)timeoffEntryObjectArray andUdfArray:(NSMutableArray *)udfArray withDelegate:(id)delegate{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    NSMutableDictionary *owner=[NSMutableDictionary dictionaryWithObjectsAndKeys:strUserURI,@"uri",[NSNull null],@"loginName",nil];
    id comments=@"";
    
    id customField=[NSNull null];
    NSMutableArray *customFieldArray=[NSMutableArray array];
    if (udfArray!=nil&&[udfArray count]>0)
    {
        for (int i=0; i<[udfArray count]; i++)
        {
//            NSMutableDictionary *dict=[udfArray objectAtIndex:i];
            NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
            //NSString *udfName=[dict objectForKey:@"name"];
            //            NSString *udfType=[dict objectForKey:@"type"];
            //            NSString *udfUri=[dict objectForKey:@"uri"];
            
            //            UDF_TYPE_TEXT,
            //            UDF_TYPE_NUMERIC,
            //            UDF_TYPE_DATE,
            //            UDF_TYPE_DROPDOWN,
            
            UdfObject *udfObj = [udfArray objectAtIndex:i];
           
            // NSString *udfType=[[udfArray objectAtIndex:i] objectForKey:@"type"];
            NSString *udfUri=udfObj.udfUri;
            if (udfObj.udfType == UDF_TYPE_TEXT)
            {
                NSString *defaultValue=udfObj.defaultValue;
                if (defaultValue!=nil && (![defaultValue isEqualToString:RPLocalizedString(ADD, @"")] && ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                {
                    [dataDict setObject:defaultValue forKey:@"text"];
                }
                else
                {
                    [dataDict setObject:[NSNull null] forKey:@"text"];
                }
                
                [dataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                [dataDict setObject:[NSNull null] forKey:@"date"];
                [dataDict setObject:[NSNull null] forKey:@"number"];
                
            }
            else if (udfObj.udfType == UDF_TYPE_NUMERIC)
            {
                NSString *defaultValue=udfObj.defaultValue;
                
                if (defaultValue!=nil && (![defaultValue isEqualToString:RPLocalizedString(ADD, @"")] && ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                {
                    [dataDict setObject:[NSNumber numberWithDouble:[defaultValue newDoubleValue]] forKey:@"number"];
                }
                else
                {
                    [dataDict setObject:[NSNull null] forKey:@"number"];
                }
                [dataDict setObject:[NSNull null] forKey:@"text"];
                [dataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                [dataDict setObject:[NSNull null] forKey:@"date"];
                
            }
            else if (udfObj.udfType == UDF_TYPE_DATE)
            {
                
                NSString *defaultValue=udfObj.defaultValue;
                
                
                if (defaultValue!=nil && (![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")] && ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    
                    NSLocale *locale=[NSLocale currentLocale];
                    [dateFormatter setLocale:locale];
                    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
                    NSDate *dropdownDateValue	=[dateFormatter dateFromString:defaultValue];
                    
                    if (dropdownDateValue!=nil )
                    {
                        NSDictionary *dateDict=[Util convertDateToApiDateDictionary:dropdownDateValue];
                        [dataDict setObject:dateDict      forKey:@"date"];
                    }
                    else
                    {
                        [dataDict setObject:[NSNull null]      forKey:@"date"];
                    }
                    
                }
                else
                {
                    [dataDict setObject:[NSNull null]      forKey:@"date"];
                }
                
                
                [dataDict setObject:[NSNull null] forKey:@"text"];
                [dataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                [dataDict setObject:[NSNull null] forKey:@"number"];
            }
            else if (udfObj.udfType == UDF_TYPE_DROPDOWN)
            {
                NSString *defaultValue=udfObj.dropDownOptionUri;;
                //Implemetation For MOBI-300//JUHI
                if (defaultValue!=nil && ![defaultValue isKindOfClass:[NSNull class]])
                {
                    if (![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")] && ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
                    {
                        NSMutableDictionary *dropDownOptionDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                 defaultValue,@"uri",
                                                                 [NSNull null],@"name",
                                                                 nil];
                        [dataDict setObject:dropDownOptionDict  forKey:@"dropDownOption"];
                    }
                }
                else
                {
                    [dataDict setObject:[NSNull null]  forKey:@"dropDownOption"];
                }
                
                [dataDict setObject:[NSNull null]  forKey:@"text"];
                [dataDict setObject:[NSNull null]  forKey:@"date"];
                [dataDict setObject:[NSNull null]  forKey:@"number"];
            }
            NSMutableDictionary *customFieldDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  udfUri,@"uri",
                                                  [NSNull null],@"name",
                                                  [NSNull null],@"groupUri",
                                                  nil];
            [dataDict setObject:customFieldDict        forKey:@"customField"];
            
            [customFieldArray addObject:dataDict];
        }
        customField=customFieldArray;
    }
    
     id resubmitComments=[NSNull null];
    NSMutableDictionary *entryDict=[NSMutableDictionary dictionary];
    for (int i=0;i<[timeoffEntryObjectArray count]; i++)
    {
        BookedTimeOffEntry *timeOffEntryObject=(BookedTimeOffEntry *)[timeoffEntryObjectArray objectAtIndex:i];
        
        if ([timeOffEntryObject resubmitComments]!=nil)
        {
            resubmitComments=[timeOffEntryObject resubmitComments];
        }

        
        comments=[timeOffEntryObject comments];
        if (comments==nil||[comments isKindOfClass:[NSNull class]])
        {
            comments=@"";
        }
        NSString *timeoffTypeUri=nil;
        NSString *timeoffTypeName=nil;
        
        if ([timeOffEntryObject typeIdentity]!=nil && ![[timeOffEntryObject typeIdentity] isKindOfClass:[NSNull class]])
        {
            timeoffTypeUri=[timeOffEntryObject typeIdentity];
            timeoffTypeName=[timeOffEntryObject typeName];
        }
        
        NSMutableDictionary *timeoffTypeDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeoffTypeUri,@"uri",timeoffTypeName,@"name",nil];
        
        NSDateFormatter *temp = [[NSDateFormatter alloc] init];
        [temp setDateFormat:@"yyyy-MM-dd"];
        
        NSLocale *locale=[NSLocale currentLocale];
        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [temp setTimeZone:timeZone];
        [temp setLocale:locale];
        
        NSDate *stDt = [temp dateFromString:[temp stringFromDate:[timeOffEntryObject bookedStartDate]]];
        NSDate *endDt =  [temp dateFromString:[temp stringFromDate:[timeOffEntryObject bookedEndDate]]];
       
        
        
        if ((stDt!=nil && endDt!=nil) && [stDt compare:endDt]==NSOrderedSame)
        {
            NSDictionary *dict=[Util convertDateToApiDateDictionary:[timeOffEntryObject bookedStartDate]];
            int year=[[dict objectForKey:@"year"] intValue];
            int month=[[dict objectForKey:@"month"]intValue];
            int day=[[dict objectForKey:@"day"]intValue];;
            
            NSMutableDictionary *dateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"%d",year],@"year",
                                           [NSString stringWithFormat:@"%d",month],@"month",
                                           [NSString stringWithFormat:@"%d",day],@"day",
                                           nil];
            
            
            
            NSString *startTime=[timeOffEntryObject startTime];
            id startTimeOfDay;
            if (startTime!=nil && ![startTime isEqualToString:RPLocalizedString(START_AT, START_AT)])
            {
                startTime = [Util convert12HourTimeStringTo24HourTimeString:[startTime lowercaseString]];
                NSArray *inTimeComponentsArray=[startTime componentsSeparatedByString:@":"];
                int inHours=0;
                int inMinutes=0;
                int inSeconds=0;
                if ([inTimeComponentsArray count]>1)
                {
                    inHours=[[inTimeComponentsArray objectAtIndex:0] intValue];
                    inMinutes=[[inTimeComponentsArray objectAtIndex:1] intValue];
                }
                
                NSMutableDictionary *startTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      [NSString stringWithFormat:@"%d",inHours],@"hour",
                                                      [NSString stringWithFormat:@"%d",inMinutes],@"minute",
                                                      [NSString stringWithFormat:@"%d",inSeconds],@"second",
                                                      nil];
                startTimeOfDay=startTimeDict;
                
            }
            
            else
                startTimeOfDay=[NSNull null];
            
            NSString *entryHours=[timeOffEntryObject startNumberOfHours];
            id startSpecficDuration;
            if (entryHours!=nil) {
                NSMutableDictionary *durationDict = [Util convertDecimalHoursToApiTimeDict:entryHours];
                startSpecficDuration=durationDict;
            }
            else
                startSpecficDuration=[NSNull null];
            
            id relativeDuration=[timeOffEntryObject startDurationEntryType];
            //Fix for defect DE15385
            if ([relativeDuration isEqualToString:PARTIAL])
            {
                relativeDuration=[NSNull null];
            }
            id specfdict;
            id timedict;
            if ([[timeOffEntryObject startDurationEntryType] isEqualToString:FULLDAY_DURATION_TYPE_KEY]) {
                specfdict=[NSNull null];
                timedict=[NSNull null];
            }
            else
            {
                //Fix for defect DE15385
                if (![[timeOffEntryObject startDurationEntryType] isEqualToString:PARTIAL])
                    specfdict=[NSNull null];
                else
                    specfdict=startSpecficDuration;
                
                timedict=startTimeOfDay;
            }
            NSMutableDictionary *timeoffAllocationEntryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:specfdict,@"specificDuration",dateDict,@"date",timedict,@"timeOfDay",relativeDuration,@"relativeDuration",
                                                             nil];
            
            
            NSMutableDictionary *timeOff=[NSMutableDictionary dictionaryWithObject:timeoffAllocationEntryDict forKey:@"timeOff"];
            
            id timeoffUri;
            if ([timeOffEntryObject sheetId]!=nil && ![[timeOffEntryObject sheetId] isKindOfClass:[NSNull class]]) {
                timeoffUri=[timeOffEntryObject sheetId];
            }
            else
                timeoffUri=[NSNull null];
            NSMutableDictionary *target=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeoffUri,@"uri",nil];
            
            entryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         target,@"target",
                         owner,@"owner",
                         timeoffTypeDict,@"timeOffType",
                         timeOff,@"singleDay",
                         [NSNull null],@"multiDay",
                         customField,@"customFieldValues",
                         comments,@"comments",
                         nil];
            
        }
        else {
            NSDictionary *dict=[Util convertDateToApiDateDictionary:[timeOffEntryObject bookedStartDate]];
            int year=[[dict objectForKey:@"year"] intValue];
            int month=[[dict objectForKey:@"month"]intValue];
            int day=[[dict objectForKey:@"day"]intValue];;
            
            NSMutableDictionary *dateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"%d",year],@"year",
                                           [NSString stringWithFormat:@"%d",month],@"month",
                                           [NSString stringWithFormat:@"%d",day],@"day",
                                           nil];
            
            
            
            NSString *startTime=[timeOffEntryObject startTime];
            id startTimeOfDay;
            if (startTime!=nil && ![startTime isEqualToString:RPLocalizedString(START_AT, START_AT)])
            {
                startTime = [Util convert12HourTimeStringTo24HourTimeString:[startTime lowercaseString]];
                NSArray *inTimeComponentsArray=[startTime componentsSeparatedByString:@":"];
                int inHours=0;
                int inMinutes=0;
                int inSeconds=0;
                if ([inTimeComponentsArray count]>1)
                {
                    inHours=[[inTimeComponentsArray objectAtIndex:0] intValue];
                    inMinutes=[[inTimeComponentsArray objectAtIndex:1] intValue];
                }
                
                NSMutableDictionary *startTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      [NSString stringWithFormat:@"%d",inHours],@"hour",
                                                      [NSString stringWithFormat:@"%d",inMinutes],@"minute",
                                                      [NSString stringWithFormat:@"%d",inSeconds],@"second",
                                                      nil];
                startTimeOfDay=startTimeDict;
                
            }
            
            else
                startTimeOfDay=[NSNull null];
            
            
            NSString *entryHours=[timeOffEntryObject startNumberOfHours];
            id startSpecficDuration;
            if (entryHours!=nil) {
                
                NSMutableDictionary *durationDict = [Util convertDecimalHoursToApiTimeDict:entryHours];
                startSpecficDuration=durationDict;
            }
            else
                startSpecficDuration=[NSNull null];
            
            id relativeDuration=[timeOffEntryObject startDurationEntryType];
            //Fix for defect DE15385
            if ([relativeDuration isEqualToString:PARTIAL])
            {
                relativeDuration=[NSNull null];
            }
            
            id startspecfdict;
            id starttimedict;
            if ([[timeOffEntryObject startDurationEntryType] isEqualToString:FULLDAY_DURATION_TYPE_KEY]) {
                startspecfdict=[NSNull null];
                starttimedict=[NSNull null];
            }
            else
            {
                //Fix for defect DE15385
                if (![[timeOffEntryObject startDurationEntryType] isEqualToString:PARTIAL])
                    startspecfdict=[NSNull null];
                else
                    startspecfdict=startSpecficDuration;
                
                starttimedict=startTimeOfDay;
            }
            NSMutableDictionary *timeOffStartAllocationEntryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:startspecfdict,@"specificDuration",dateDict,@"date",starttimedict,@"timeOfDay",relativeDuration,@"relativeDuration",
                                                                  nil];
            
            
            NSDictionary *endDict=[Util convertDateToApiDateDictionary:[timeOffEntryObject bookedEndDate]];
            int endyear=[[endDict objectForKey:@"year"] intValue];
            int endmonth=[[endDict objectForKey:@"month"]intValue];
            int endday=[[endDict objectForKey:@"day"]intValue];;
            
            NSMutableDictionary *enddateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [NSString stringWithFormat:@"%d",endyear],@"year",
                                              [NSString stringWithFormat:@"%d",endmonth],@"month",
                                              [NSString stringWithFormat:@"%d",endday],@"day",
                                              nil];
            
            
            
            NSString *endTime=[timeOffEntryObject endTime];
            id endTimeOfDay;
            if (endTime!=nil&& ![endTime isEqualToString:RPLocalizedString(END_AT, END_AT)])
            {
                
                endTime = [Util convert12HourTimeStringTo24HourTimeString:[endTime lowercaseString]];
                NSArray *endTimeComponentsArray=[endTime componentsSeparatedByString:@":"];
                int endHours=0;
                int endMinutes=0;
                int endSeconds=0;
                if ([endTimeComponentsArray count]>1)
                {
                    endHours=[[endTimeComponentsArray objectAtIndex:0] intValue];
                    endMinutes=[[endTimeComponentsArray objectAtIndex:1] intValue];
                }
                
                NSMutableDictionary *endTimeDict= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   [NSString stringWithFormat:@"%d",endHours],@"hour",
                                                   [NSString stringWithFormat:@"%d",endMinutes],@"minute",
                                                   [NSString stringWithFormat:@"%d",endSeconds],@"second",
                                                   nil];
                endTimeOfDay=endTimeDict;
                
            }
            else
                endTimeOfDay=[NSNull null];
            NSString *endentryHours=[timeOffEntryObject endNumberOfHours];
            id endSpecficDuration;
            if (endentryHours!=nil)
            {
                NSMutableDictionary *enddurationDict = [Util convertDecimalHoursToApiTimeDict:endentryHours];
                endSpecficDuration=enddurationDict;
            }
            else
                endSpecficDuration=[NSNull null];
            id endrelativeDuration=[timeOffEntryObject endDurationEntryType];
            //Fix for defect DE15385
            if ([endrelativeDuration isEqualToString:PARTIAL])
            {
                endrelativeDuration=[NSNull null];
            }
            id endspecfdict;
            id endtimedict;
            if ([[timeOffEntryObject endDurationEntryType] isEqualToString:FULLDAY_DURATION_TYPE_KEY]) {
                endspecfdict=[NSNull null];
                endtimedict=[NSNull null];
            }
            else
            {
                //Fix for defect DE15385
                if (![[timeOffEntryObject endDurationEntryType] isEqualToString:PARTIAL])
                    endspecfdict=[NSNull null];
                else
                    endspecfdict=endSpecficDuration;
                
                endtimedict=endTimeOfDay;
            }
            
            NSMutableDictionary *timeOffEndAllocationEntryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:endspecfdict,@"specificDuration",enddateDict,@"date",endtimedict,@"timeOfDay",endrelativeDuration,@"relativeDuration",
                                                                nil];
            
            
            
            NSMutableDictionary *timeOff=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeOffStartAllocationEntryDict,@"timeOffStart",timeOffEndAllocationEntryDict,@"timeOffEnd",nil];
            
            id timeoffUri;
            if ([timeOffEntryObject sheetId]!=nil && ![[timeOffEntryObject sheetId] isKindOfClass:[NSNull class]]) {
                timeoffUri=[timeOffEntryObject sheetId];
            }
            else
                timeoffUri=[NSNull null];
            NSMutableDictionary *target=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeoffUri,@"uri",nil];
            
            entryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         target,@"target",
                         owner,@"owner",
                         timeoffTypeDict,@"timeOffType",
                         [NSNull null],@"singleDay",
                         timeOff,@"multiDay",
                         customField,@"customFieldValues",
                         comments,@"comments",
                         nil];
            
        }
        
    }
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      entryDict,@"data",
                                      [Util getRandomGUID],@"unitOfWorkId",
                                      resubmitComments,@"comments",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"ResubmitTimeOffData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"ResubmitTimeOffData"]];
    [self setServiceDelegate:self];
    [self executeRequest];
    
    
}

#pragma mark -
#pragma mark Response Methods

/************************************************************************************************************
 @Function Name   : handleTimeoffFetchData
 @Purpose         : To save user's timeoff data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleTimeoffFetchData:(id)response
{
    [timeoffModel deleteAllTimeoffsFromDB];
    [timeoffModel deleteAllTypeBalanceSummaryFromDB];
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
         NSMutableArray *companyHolidaysArray=[responseDict objectForKey:@"holidays"];
        //Fix for multiple entry for company holiday calender
         NSMutableArray *companyHolidaysArrayFromDb=[timeoffModel getAllCompanyHolidaysFromDB];
        if ([companyHolidaysArrayFromDb count]==0)
        {
            [timeoffModel saveTimeoffCompanyHolidaysDataFromApiToDB:companyHolidaysArray];
        }
        
        
        NSMutableArray *rowsArray=[[responseDict objectForKey:@"timeOff"] objectForKey:@"rows"];
        NSMutableArray *timeoffTypeBalanceSummaryArray=[responseDict objectForKey:@"timeOffTypeBalanceSummaries"];
        
        //Fix for defect DE18992//JUHI
        NSString *calendarUri=nil;
        if ([responseDict objectForKey:@"holidayCalendar"]!=nil&&![[responseDict objectForKey:@"holidayCalendar"]isKindOfClass:[NSNull class]]) {
            calendarUri=[[responseDict objectForKey:@"holidayCalendar"] objectForKey:@"uri"];
        }
        
        NSMutableArray *weeklyDaysOffArray=[responseDict objectForKey:@"weeklyDaysOff"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timesheetsCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:timesheetsCount forKey:@"timeoffDownloadCount"];
        if (calendarUri!=nil) {
            [defaults setObject:calendarUri forKey:@"holidayCalendarURI"];
        }
        if ([weeklyDaysOffArray count]!=0) {
            NSMutableArray *weeklyDaysOffArrayCreated=[NSMutableArray array];
            for (int i=0; i<[weeklyDaysOffArray count]; i++)
            {
                NSString *uri=[[weeklyDaysOffArray objectAtIndex:i] objectForKey:@"uri"];
                if (uri!=nil) {
                    [weeklyDaysOffArrayCreated addObject:uri];
                }
            
            }
            [defaults setObject:weeklyDaysOffArrayCreated forKey:@"weeklyDaysOff"];
        }
        [defaults synchronize];
        [timeoffModel saveTimeoffDataFromApiToDB:responseDict];
        [timeoffModel saveTimeoffTypeBalanceSummaryDataFromApiToDB:timeoffTypeBalanceSummaryArray];
       
    }
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.isShowTimeOffSheetPlaceHolder=TRUE;
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
    self.didSuccessfullyFetchTimeoff = YES;
}

/************************************************************************************************************
 @Function Name   : handleNextTimeoffFetchData
 @Purpose         : To save user's next recent timeoff data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handleNextTimeoffFetchData:(id)response
{
    
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timesheetsCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:timesheetsCount forKey:@"timeoffDownloadCount"];
        [defaults synchronize];
        
        [timeoffModel saveNextTimeoffDataFromApiToDB:responseDict];
    }
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NEXT_RECENT_TIMEOFFS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}

/************************************************************************************************************
 @Function Name   : handleCompanyHolidaysFetchData
 @Purpose         : To save user's company holiday data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handleCompanyHolidaysFetchData:(id)response
{

    NSMutableArray *companyHolidaysArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    [timeoffModel saveTimeoffCompanyHolidaysDataFromApiToDB:companyHolidaysArray];
   [[NSNotificationCenter defaultCenter] postNotificationName:COMPANY_HOLIDAY_RECEIVED_NOTIFICATION object:nil];
}
/************************************************************************************************************
 @Function Name   : handleTimeoffEntryFetchData
 @Purpose         : To save timeoff entry data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleTimeoffEntryFetchData:(id)response
{
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        [timeoffModel saveTimeOffEntryDataFromApiToDB:responseDict andTimesheetUri:nil];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
    
}
/************************************************************************************************************
 @Function Name   : handleTimeoffSaveData
 @Purpose         : To save timesheets save response data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handleTimeoffSaveData:(id)response
{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        [timeoffModel saveTimeOffEntryDataFromApiToDB:responseDict andTimesheetUri:nil];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_SAVEDATA_RECEIVED_NOTIFICATION object:nil];
    //[[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
   
}

-(void)handleTimeoffDeleteData:(id)response
{
  
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOKEDTIMEOFF_DELETED_NOTIFICATION object:nil];
}
-(void)handleTimeOffBalanceSummaryAfterTimeOff:(id)response
{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableDictionary *balanceResponseDict=[NSMutableDictionary dictionary];
        NSString *balanceTotalDays=nil;
        NSString *requestedTotalDays=nil;
        NSString *balanceTotalHour=nil;
        NSString *requestedTotalHour=nil;
        //Fix for DE15147
        if ([responseDict objectForKey:@"balanceSummaryAfterTimeOff"]!=nil && ![[responseDict objectForKey:@"balanceSummaryAfterTimeOff"]isKindOfClass:[NSNull class]])
        {
            NSString *timeOffDisplayFormatUri=responseDict[@"balanceSummaryAfterTimeOff"][@"timeOffDisplayFormatUri"];

             [balanceResponseDict setObject:timeOffDisplayFormatUri forKey:@"timeOffDisplayFormatUri"];

            if ([[responseDict objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]!=nil &&![[[responseDict objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]isKindOfClass:[NSNull class]])
            {
                balanceTotalDays=[[[responseDict objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]objectForKey:@"decimalWorkdays"];
                NSDictionary *hoursDict=[[[responseDict objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]objectForKey:@"calendarDayDuration"];
                balanceTotalHour=[Util getRoundedValueFromDecimalPlaces:[[Util convertApiTimeDictToDecimal:hoursDict] newDoubleValue]withDecimalPlaces:2];
            }
        }
        if ([responseDict objectForKey:@"totalDurationOfTimeOff"]!=nil && ![[responseDict objectForKey:@"totalDurationOfTimeOff"]isKindOfClass:[NSNull class]])
        {
            if ([responseDict objectForKey:@"totalDurationOfTimeOff"]!=nil &&![[responseDict objectForKey:@"totalDurationOfTimeOff"]isKindOfClass:[NSNull class]]) {
                requestedTotalDays=[[responseDict objectForKey:@"totalDurationOfTimeOff"] objectForKey:@"decimalWorkdays"];
                NSDictionary *hoursDict=[[responseDict objectForKey:@"totalDurationOfTimeOff"]objectForKey:@"calendarDayDuration"];
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
       
        [[NSNotificationCenter defaultCenter] postNotificationName: TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil userInfo:balanceResponseDict];

    

    }

}//Implemented Resubmit As Per US7631
-(void)handleTimeoffResubmitData:(id)response
{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        [timeoffModel saveTimeOffEntryDataFromApiToDB:responseDict andTimesheetUri:nil];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_SAVEDATA_RECEIVED_NOTIFICATION object:nil];
    //[[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
    
}
#pragma mark -
#pragma mark ServiceURL Response Handling

- (void) serverDidRespondWithResponse:(id) response
{
    if (response!=nil)
    {
		
        NSDictionary *errorDict=[[response objectForKey:@"response"]objectForKey:@"error"];
        
        if (errorDict!=nil)
        {
            
            BOOL isErrorThrown=FALSE;
            
            
            NSArray *notificationsArr=[[errorDict objectForKey:@"details"] objectForKey:@"notifications"];
            NSString *errorMsg=@"";
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


            [self.spinnerDelegate hideTransparentLoadingOverlay];
            NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                                 forKey:@"isErrorOccured"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NEXT_RECENT_TIMEOFFS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
            [[NSNotificationCenter defaultCenter] postNotificationName:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName: TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil userInfo:nil];//Fix for DE15147
        }
        else
        {
            totalRequestsServed++;
            id _serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
            
            
            if ([_serviceID intValue]== GetTimeoffData_Service_ID_54)
            {
                [self handleTimeoffFetchData:response];
            }
            else if ([_serviceID intValue]== GetNextTimeoffData_Service_ID_55)
            {
                [self handleNextTimeoffFetchData:response];
                return;
            }
            else if ([_serviceID intValue]== GetRefreshedTimeoffData_Service_ID_56)
            {
                [self handleTimeoffFetchData:response];
                return;
                
            }
            else if ([_serviceID intValue]== GetCompanyHolidaysData_Service_ID_57)
            {
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                [self handleCompanyHolidaysFetchData:response];
                return;
                
            }
            else if ([_serviceID intValue]== GetTimeoffEntryData_Service_ID_64)
            {
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                [self handleTimeoffEntryFetchData:response];
                return;
                
            }
            else if ([_serviceID intValue]== SaveTimeoffData_Service_ID_65)
            {
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                [self handleTimeoffSaveData:response];
                return;
                
            }
            else if ([_serviceID intValue]== DeleteTimeoffData_Service_ID_66)
            {
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                [self handleTimeoffDeleteData:response];
                return;
                
            }
            else if ([_serviceID intValue]== GetTimeOffBalanceSummaryAfterTimeOff_Service_ID_67)
            {
                int lastCount=[[[NSUserDefaults standardUserDefaults]objectForKey:@"LastBalanceValue"] intValue];
                int countStored=[[[[response objectForKey:@"refDict"]objectForKey:@"params"]objectForKey:@"LastBlanaceValueStored" ] intValue];
                if (countStored==lastCount)
                {
                     [self handleTimeOffBalanceSummaryAfterTimeOff:response];
                }
                return;
                
            }//Implemented Resubmit As Per US7631
            else if ([_serviceID intValue]== ResubmitTimeOffData_Service_ID_71)
            {
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                [self handleTimeoffResubmitData:response];
                return;
                
            }
//            //Implemented as per US7812
//            else if ([_serviceID intValue]== GetTimeOffBalanceSummary_Service_ID_76)
//            {
//                [self handleTimeOffBalanceSummaryAfterTimeOff:response];
//                
//                return;
//            }
            if (totalRequestsServed == totalRequestsSent )
            {
                [self.spinnerDelegate hideTransparentLoadingOverlay];                [[NSNotificationCenter defaultCenter] postNotificationName:AllTimeoffRequestsServed object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
            }
            
        }
    }
}
#pragma mark -
#pragma mark ServiceURL Error Handling
- (void) serverDidFailWithError:(NSError *) error applicationState:(ApplicateState)applicationState
{
    
     totalRequestsServed++;
    
    [self.spinnerDelegate hideTransparentLoadingOverlay];
    
    if (applicationState == Foreground)
    {
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            
        }
        else
        {
            [Util handleNSURLErrorDomainCodes:error];
        }
    }

    
    
   
    [[NSNotificationCenter defaultCenter] postNotificationName:AllTimeoffRequestsServed object:nil];
    return;
}

    
    

@end
