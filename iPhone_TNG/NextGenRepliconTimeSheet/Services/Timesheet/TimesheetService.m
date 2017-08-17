//
//  TimesheetService.m
//  Replicon
//
//  Created by enl4macbkpro on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimesheetService.h"
#import "RepliconServiceManager.h"
#import "AppDelegate.h"
#import "TimesheetEntryObject.h"
#import "Util.h"
#import "EntryCellDetails.h"
#import "LoginModel.h"
#import "SNLog.h"
#import "TimesheetNavigationController.h"
#import "ListOfTimeSheetsViewController.h"
#import "TimesheetMainPageController.h"
#import <Crashlytics/Crashlytics.h>
#import "BookedTimeOffEntry.h"
#import "WidgetTSViewController.h"
#import "NSString+Double_Float.h"
#import "UdfObject.h"
#import <repliconkit/repliconkit.h>
#import "DayOffHelper.h"
@interface TimesheetService ()

@property (nonatomic, strong) id<SpinnerDelegate> spinnerDelegate;

@end

@implementation TimesheetService
@synthesize timesheetModel;
@synthesize widgetTimesheetDelegate;

- (instancetype)initWithSpinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate {
    self = [super init];
    if (self != nil)
    {
        self.spinnerDelegate = spinnerDelegate;

        if(timesheetModel == nil) {
            timesheetModel = [[TimesheetModel alloc] init];
        }
        if(timeoffModel == nil) {
            timeoffModel = [[TimeoffModel alloc] init];
        }
    }
    
    return self;
}

#pragma mark -
#pragma mark Request Methods

/************************************************************************************************************
 @Function Name   : fetchTimeSheetData
 @Purpose         : Called to get the user’s timesheet data ie timesheet period,due date,approval status etc
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchTimeSheetData:(id)_delegate
{

    self.didSuccessfullyFetchTimesheets = NO;

    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    //Implementation of TimeSheetLastModified
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    //[dateFormatter setLocale:locale];
    //[dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSDate *localDate =[NSDate date];
    //NSString *lastUpdateDateStr=[dateFormatter stringFromDate:localDate];
    
    [defaults removeObjectForKey:@"TimeSheetLastModifiedTime"];
    //[defaults setObject:lastUpdateDateStr forKey:@"TimeSheetLastModifiedTime"];
    [defaults synchronize];
    
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
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        ;
        NSNumber *pageNum=[NSNumber numberWithInteger:1];
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"timesheetDownloadCount"];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:pageNum forKey:@"NextTimeSheetPageNo"];
        [defaults synchronize];
        
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
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
         urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetFirstTimesheets"]];//Implementation as per US9331//JUHI
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetFirstTimesheets"]];//Implementation as per US9331//JUHI
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
    
}


-(void)fetchTimeSheetDataOnlyWhenUpdateFetchDataFails:(id)_delegate
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;

    
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
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
       
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
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"CreateTimesheetsDataOnlyWhenUpdateFetchDataFails"]];
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"CreateTimesheetsDataOnlyWhenUpdateFetchDataFails"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
    
}



/************************************************************************************************************
 @Function Name   : fetchTimeSheetSummaryDataForTimesheet
 @Purpose         : Called to get the timesheet summary data for timesheetUri
 @param           : timesheetUri,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchTimeSheetSummaryDataForTimesheet:(NSString *)timesheetUri withDelegate:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timesheetUri ,@"timesheetUri",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTimesheetSummaryData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetTimesheetSummaryData"]];
    [self setServiceDelegate:self];
    [self executeRequest:[NSNumber numberWithBool:YES]];
    
}

-(void)fetchEnabledTimeoffTypesDataForTimesheetForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)searchText andDelegate:(id)delegate
{
    
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    
    int nextFetchPageNo=[[defaults objectForKey:@"NextAdHocDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextAdHocDownloadPageNo"];
    [defaults synchronize];
    
    NSNumber *pageNum=[NSNumber numberWithInteger:nextFetchPageNo+1];
    
    
    
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"adHocOptionDataDownloadCount"];
    //Implementation as per US9109//JUHI
    id searchStr;
    id searchdict;
    if (searchText!=nil && ![searchText isKindOfClass:[NSNull class]])
    {
        searchStr=searchText;
    }
    else
        searchStr=[NSNull null];
    
    if (searchStr!=nil && ![searchStr isKindOfClass:[NSNull class]]) {
        NSMutableDictionary *timeoffSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                searchStr ,@"queryText",
                                                @"false", @"searchInDescription",
                                                @"true",@"searchInDisplayText",
                                                @"false",@"searchInName",nil];
        searchdict=timeoffSearchDict;
    }
    else
        searchdict=[NSNull null];
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      pageNum,@"page",
                                      timesheetUri ,@"timesheetUri",
                                      searchdict,@"textSearch",
                                      pageSize,@"pageSize",nil];
    
    
    
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetPageOfTimeOffTypesAvailableForTimeAllocationFilteredByTextSearch"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetPageOfTimeOffTypesAvailableForTimeAllocationFilteredByTextSearch"]];
    [self setServiceDelegate:self];
    if (searchText==nil) {
        searchText=@"";
    }
    [self executeRequest:searchText];
    
    
    
}





/************************************************************************************************************
 @Function Name   : fetchFirstClientsAndProjectsForTimesheetUri
 @Purpose         : Called to get the clients and projects for timesheet with uri
 @param           : timesheetUri,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchFirstClientsAndProjectsForTimesheetUri:(NSString *)timesheetUri withClientSearchText:(NSString *)clientText withProjectSearchText:(NSString *)projectText andDelegate:(id)delegate
{
    [timesheetModel deleteAllClientsInfoFromDBForModuleName:@"Timesheet"];
    [timesheetModel deleteAllProjectsInfoFromDBForModuleName:@"Timesheet"];
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *timesheetsCount=[NSNumber numberWithInteger:1];
    [defaults setObject:timesheetsCount forKey:@"NextClientDownloadPageNo"];
    [defaults setObject:timesheetsCount forKey:@"NextProjectDownloadPageNo"];
    [defaults synchronize];
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    
    NSMutableDictionary *queryDict=nil;
    if (clientText==nil && projectText==nil)
    {
        queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     timesheetUri ,@"timesheetUri",
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
                     timesheetUri ,@"timesheetUri",
                     projectSearchDict,@"projectTextSearch",
                     clientSearchDict,@"clientTextSearch",
                     pageSize,@"maximumResultCount",nil];
    }
    
    
    
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetFirstClientsOrProjects"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetFirstClientsOrProjects"]];
    [self setServiceDelegate:self];
    if (projectText==nil)
    {
        projectText=@"";
    }
    [self executeRequest:projectText];
    
    
    
}

/************************************************************************************************************
 @Function Name   : fetchNextClientsForTimesheetUri
 @Purpose         : Called to get the clients for timesheet with uri for search text
 @param           : timesheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchNextClientsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int nextFetchPageNo=[[defaults objectForKey:@"NextClientDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextClientDownloadPageNo"];
    [defaults synchronize];
    
    NSNumber *pageNum=[NSNumber numberWithInteger:nextFetchPageNo+1];
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
                                      timesheetUri ,@"timesheetUri",
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

-(void)fetchNextProjectsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int nextFetchPageNo=[[defaults objectForKey:@"NextProjectDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextProjectDownloadPageNo"];
    [defaults synchronize];
    
    NSNumber *pageNum=[NSNumber numberWithInteger:nextFetchPageNo+1];
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
                                      timesheetUri ,@"timesheetUri",
                                      projectSearchDict,@"textSearch",
                                      clientUri,@"clientUri",nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetNextProjects"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextProjects"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}
/************************************************************************************************************
 @Function Name   : fetchNextClientsForTimesheetUri
 @Purpose         : Called to get the clients for timesheet with uri for search text
 @param           : timesheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchFirstClientsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate
{
    [timesheetModel deleteAllClientsInfoFromDBForModuleName:@"Timesheet"];
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *pageNum=[NSNumber numberWithInteger:1];
    int nextFetchPageNo=[pageNum intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:nextFetchPageNo];
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
                                      timesheetUri ,@"timesheetUri",
                                      textSearchDict,@"textSearch",
                                      pageSize,@"maximumResultCount",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetFirstClients"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetFirstClients"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}

/************************************************************************************************************
 @Function Name   : fetchNextProjectsForTimesheetUri
 @Purpose         : Called to get the projects for timesheet with uri for search text
 @param           : timesheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchFirstProjectsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate
{
    [timesheetModel deleteAllProjectsInfoFromDBForModuleName:@"Timesheet"];
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *timesheetsCount=[NSNumber numberWithInteger:1];
    [defaults setObject:timesheetsCount forKey:@"NextProjectDownloadPageNo"];
    [defaults synchronize];
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    
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
                                      timesheetUri ,@"timesheetUri",
                                      [NSNull null],@"clientUri",
                                      textSearchDict,@"textSearch",
                                      pageSize,@"maximumResultCount",nil];
    
    
    
    
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetFirstProjects"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetFirstProjects"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}

/************************************************************************************************************
 @Function Name   : fetchProjectsBasedOnclientsForTimesheetUri
 @Purpose         : Called to get the projects based on clients with client uri
 @param           : timesheetUri,textSearch,clientUri,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchProjectsBasedOnclientsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate
{
    [timesheetModel deleteAllProjectsInfoFromDBForModuleName:@"Timesheet"];
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    if (textSearch==nil) {
        textSearch=@"";
    }
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:1];
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
                                      timesheetUri ,@"timesheetUri",
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

-(void)fetchTasksBasedOnProjectsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri andDelegate:(id)delegate
{
    [timesheetModel deleteAllTasksInfoFromDBForModuleName:@"Timesheet"];
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    if (textSearch==nil) {
        textSearch=@"";
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *pageCount=[NSNumber numberWithInteger:1];
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
                                      pageSize,@"maximumResultCount",
                                      timesheetUri ,@"timesheetUri",
                                      projectUri,@"projectUri",
                                      taskSearchDict,@"textSearch",nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetFirstTasks"]];
    
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

-(void)fetchNextTasksBasedOnProjectsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri andDelegate:(id)delegate

{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    int nextFetchPageNo=[[defaults objectForKey:@"NextTaskDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextTaskDownloadPageNo"];
    [defaults synchronize];
    
    NSNumber *pageNum=[NSNumber numberWithInteger:nextFetchPageNo+1];
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
                                      timesheetUri ,@"timesheetUri",
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
 @Function Name   : fetchProjectsBasedOnclientsForTimesheetUri
 @Purpose         : Called to get the projects based on clients with client uri
 @param           : timesheetUri,textSearch,clientUri,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchNextProjectsBasedOnclientsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int nextFetchPageNo=[[defaults objectForKey:@"NextProjectDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:nextFetchPageNo+1];
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
                                      timesheetUri ,@"timesheetUri",
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
 @Function Name   : fetchBillingRateBasedOnProjectForTimesheetUri
 @Purpose         : Called to get the billing rate based on project with project uri
 @param           : timesheetUri,textSearch,projectUri,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchBillingRateBasedOnProjectForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri taskUri:(NSString*)taskUri andDelegate:(id)delegate
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
    [defaults setObject:[NSNumber numberWithInteger:1] forKey:@"NextBillingRatePageNo"];
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
                                      [maximumResultCount stringValue],@"maximumResultCount",
                                      timesheetUri ,@"timesheetUri",
                                      projectUri,@"projectUri",
                                      searchdict,@"textSearch",
                                      taskStr,@"taskUri",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetFirstBillingRatesForTimesheet"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetBillingData"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
    
}


-(void)fetchDefaultBillingRateBasedOnProjectForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri taskUri:(NSString*)taskUri andDelegate:(id)delegate
{
    [timesheetModel deleteAllBillingInfoFromDBForModuleName:@"Timesheet"];
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
                                      @"1",@"maximumResultCount",
                                      timesheetUri ,@"timesheetUri",
                                      projectUri,@"projectUri",
                                      searchdict,@"textSearch",
                                      taskStr,@"taskUri",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetFirstBillingRatesForTimesheet"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetDefaultBillingData"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
    
}

/************************************************************************************************************
 @Function Name   : fetchNextBillingRateBasedOnProjectForTimesheetUri
 @Purpose         : Called to get next set of the billing rate based on project with project uri
 @param           : timesheetUri,textSearch,projectUri,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchNextBillingRateBasedOnProjectForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri taskUri:(NSString*)taskUri andDelegate:(id)delegate
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
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextBillingRatePageNo"];
    [defaults synchronize];
    
    NSNumber *pageNum=[NSNumber numberWithInteger:nextFetchPageNo+1];
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
                                      timesheetUri ,@"timesheetUri",
                                      projectUri,@"projectUri",
                                      searchdict,@"textSearch",
                                      taskStr,@"taskUri",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetBillingData"]];
    
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
-(void)fetchActivityBasedOnTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate
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
    [defaults setObject:[NSNumber numberWithInteger:1] forKey:@"NextActivityPageNo"];
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
                                      [maximumResultCount stringValue],@"maximumResultCount",
                                      timesheetUri ,@"timesheetUri",
                                      searchdict,@"textSearch",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetFirstActivitiesForTimesheet"]];
    
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
-(void)fetchNextActivityBasedOnTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate
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
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextActivityPageNo"];
    [defaults synchronize];
    
    NSNumber *pageNum=[NSNumber numberWithInteger:nextFetchPageNo+1];
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
                                      timesheetUri ,@"timesheetUri",
                                      searchdict,@"textSearch",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetActivityData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextActivityData"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}
//Implementation for JM-35734_DCAA compliance support//JUHI
/************************************************************************************************************
 @Function Name   : sendRequestToSaveTimesheetData
 @Purpose         : Called to save timesheet entries with timesheetURI
 @param           : timesheetUri,timeEntryObjectArray,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)sendRequestToSaveTimesheetDataForTimesheetURI:(NSString *)timesheetURI withEntryArray:(NSMutableArray *)timeEntryObjectArray withDelegate:(id)delegate isMultiInOutTimeSheetUser:(BOOL)isMultiInOutTimeSheetUser isNewAdhocEntryDict:(NSMutableDictionary *)adhocEntryDict isTimesheetSubmit:(BOOL)isTimesheetSubmit sheetLevelUdfArray:(NSMutableArray *)sheetLevelUdfArray submitComments:(NSString *)submitComments isAutoSave:(NSString*)isAutoSaveStr isDisclaimerAccepted:(BOOL)isDisclaimerAccepted rowUri:(NSString *)rowUri actionMode:(NSInteger)actionMode isExtendedInOutUser:(BOOL)isExtendedInOutUser reasonForChange:(NSString*)reasonForChange
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    
    NSMutableArray *entriesArray=[NSMutableArray array];
    
    NSMutableArray *cellArray=[NSMutableArray array];
    
    
    
    //REMOVE ALL TIMEOFFS's //LOAD 3 --> LOAD2
    NSMutableArray *temptimeEntryObjectArray=[NSMutableArray array];
    for (int i=0; i<[timeEntryObjectArray count]; i++)
    {
        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timeEntryObjectArray objectAtIndex:i];
        if (![[tsEntryObject entryType] isEqualToString:Time_Off_Key])
        {
            [temptimeEntryObjectArray addObject:tsEntryObject];
        }
    }
    timeEntryObjectArray=temptimeEntryObjectArray;
    
    if (isMultiInOutTimeSheetUser)
    {
        for (int i=0; i<[timeEntryObjectArray count]; i++)
        {
            
            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timeEntryObjectArray objectAtIndex:i];
            
            
            NSDictionary *dict=[Util convertDateToApiDateDictionary:[tsEntryObject timeEntryDate]];
            int year=[[dict objectForKey:@"year"] intValue];
            int month=[[dict objectForKey:@"month"] intValue];
            int day=[[dict objectForKey:@"day"] intValue];
            if (isExtendedInOutUser)
            {
                NSMutableArray *timePunchesArr=[tsEntryObject timePunchesArray];
                for (int k=0; k<[timePunchesArr count]; k++)
                {
                    year=[[dict objectForKey:@"year"] intValue];
                    month=[[dict objectForKey:@"month"] intValue];
                    day=[[dict objectForKey:@"day"] intValue];
                    NSMutableDictionary *inoutEntryDict=[timePunchesArr objectAtIndex:k];
                    NSString *inTime=[inoutEntryDict objectForKey:@"in_time"];
                    NSString *outTime=[inoutEntryDict objectForKey:@"out_time"];
                    NSString *commentsToSave=[inoutEntryDict objectForKey:@"comments"];
                    NSString *punchUriToSave=[inoutEntryDict objectForKey:@"timePunchesUri"];
                    if ((inTime!=nil && ![inTime isKindOfClass:[NSNull class]]&& ![inTime isEqualToString:@""])||(outTime!=nil && ![outTime isKindOfClass:[NSNull class]]&& ![outTime isEqualToString:@""]))
                    {
                        id inTimeInfoDict=nil;
                        if (inTime!=nil && ![inTime isKindOfClass:[NSNull class]]&& ![inTime isEqualToString:@""])
                        {
                            inTime = [Util convert12HourTimeStringTo24HourTimeString:inTime];
                            NSArray *inTimeComponentsArray=[inTime componentsSeparatedByString:@":"];
                            int inHours=0;
                            int inMinutes=0;
                            int inSeconds=0;
                            if ([inTimeComponentsArray count]>1)
                            {
                                inHours=[[inTimeComponentsArray objectAtIndex:0] intValue];
                                inMinutes=[[inTimeComponentsArray objectAtIndex:1] intValue];

                            }
                            
                            NSMutableDictionary *inTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                               [NSString stringWithFormat:@"%d",year],@"year",
                                                               [NSString stringWithFormat:@"%d",month],@"month",
                                                               [NSString stringWithFormat:@"%d",day],@"day",
                                                               [NSString stringWithFormat:@"%d",inHours],@"hour",
                                                               [NSString stringWithFormat:@"%d",inMinutes],@"minute",
                                                               [NSString stringWithFormat:@"%d",inSeconds],@"second",
                                                               [NSNull null],@"timeZoneUri",
                                                               nil];
                            BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutEntryDict];
                            if (isMidCrossOverForEntry)
                            {
                                NSDateComponents *components= [[NSDateComponents alloc] init];
                                [components setDay:1];
                                NSCalendar *calendar = [NSCalendar currentCalendar];
                                calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                                NSDate *dateIncremented= [calendar dateByAddingComponents:components toDate:[tsEntryObject timeEntryDate] options:0];
                                NSDictionary *dict=[Util convertDateToApiDateDictionary:dateIncremented];
                                year=[[dict objectForKey:@"year"] intValue];
                                month=[[dict objectForKey:@"month"] intValue];
                                day=[[dict objectForKey:@"day"] intValue];
                                
                            }
                            inTimeInfoDict=inTimeDict;
                            
                        }
                        else
                        {
                            inTimeInfoDict=[NSNull null];
                        }
                        id outTimeInfoDict=nil;
                        
                        if (outTime!=nil && ![outTime isKindOfClass:[NSNull class]]&& ![outTime isEqualToString:@""])
                        {
                            outTime = [Util convert12HourTimeStringTo24HourTimeString:outTime];
                            
                            NSArray *outTimeComponentsArray=[outTime componentsSeparatedByString:@":"];
                            int outHours=0;
                            int outMinutes=0;
                            int outSeconds=0;
                            if ([outTimeComponentsArray count]>1)
                            {
                                outHours=[[outTimeComponentsArray objectAtIndex:0] intValue];
                                outMinutes=[[outTimeComponentsArray objectAtIndex:1] intValue];

                                if ([tsEntryObject multiDayInOutEntry][@"isMidnightCrossover"]!=nil && ![[tsEntryObject multiDayInOutEntry][@"isMidnightCrossover"] isKindOfClass:[NSNull class]])
                                {
                                    if([[tsEntryObject multiDayInOutEntry][@"isMidnightCrossover"]boolValue])
                                    {
                                        outSeconds=59;
                                    }
                                }
                            }
                            
                            NSMutableDictionary *outTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                [NSString stringWithFormat:@"%d",year],@"year",
                                                                [NSString stringWithFormat:@"%d",month],@"month",
                                                                [NSString stringWithFormat:@"%d",day],@"day",
                                                                [NSString stringWithFormat:@"%d",outHours],@"hour",
                                                                [NSString stringWithFormat:@"%d",outMinutes],@"minute",
                                                                [NSString stringWithFormat:@"%d",outSeconds],@"second",
                                                                [NSNull null],@"timeZoneUri",
                                                                nil];
                            outTimeInfoDict=outTimeDict;
                        }
                        else
                        {
                            outTimeInfoDict=[NSNull null];
                        }
                        
                        
                        /*NSMutableDictionary *dateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [NSString stringWithFormat:@"%d",year],@"year",
                         [NSString stringWithFormat:@"%d",month],@"month",
                         [NSString stringWithFormat:@"%d",day],@"day",
                         nil];*/
                        NSMutableArray *customFieldValuesArray=[NSMutableArray array];
                        NSMutableArray *cellLevelcustomFieldArray=[inoutEntryDict objectForKey:@"udfArray"];
                        for (int k=0; k<[cellLevelcustomFieldArray count]; k++)
                        {
                            EntryCellDetails *udfDetails=[cellLevelcustomFieldArray objectAtIndex:k];
                            NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                            NSString *udfType=[udfDetails fieldType];
                            NSString *udfUri=[udfDetails udfIdentity];
                            if ([udfType isEqualToString:UDFType_TEXT])
                            {
                                NSString *defaultValue=[udfDetails fieldValue];
                                if (defaultValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
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
                            else if ([udfType isEqualToString:UDFType_NUMERIC])
                            {
                                NSString *defaultValue=[udfDetails fieldValue];
                                
                                if (defaultValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
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
                            else if ([udfType isEqualToString:UDFType_DATE])
                            {
                                NSString *defaultValue=[NSString stringWithFormat:@"%@",[udfDetails fieldValue]];
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                
                                NSLocale *locale=[NSLocale currentLocale];
                                [dateFormatter setLocale:locale];
                                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                                [dateFormatter setDateFormat:@"MMMM dd,yyyy"];
                                NSDate *dropdownDateValue	=[dateFormatter dateFromString:defaultValue];
                                
                                
                                if (dropdownDateValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                {
                                    NSDictionary *dateDict=[Util convertDateToApiDateDictionary:dropdownDateValue];
                                    [dataDict setObject:dateDict      forKey:@"date"];
                                }
                                else
                                {
                                    [dataDict setObject:[NSNull null]      forKey:@"date"];
                                }
                                
                                
                                [dataDict setObject:[NSNull null] forKey:@"text"];
                                [dataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                                [dataDict setObject:[NSNull null] forKey:@"number"];
                            }
                            else if ([udfType isEqualToString:UDFType_DROPDOWN])
                            {
                                NSString *defaultValue=[udfDetails dropdownOptionUri];
                                if (defaultValue!=nil && ![defaultValue isKindOfClass:[NSNull class]])
                                {
                                    if (![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
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
                            
                            [customFieldValuesArray addObject:dataDict];
                            
                        }
                        
                        id timePunchId=nil;
                        NSString *timePunchUri=punchUriToSave;
                        if (timePunchUri!=nil && ![timePunchUri isKindOfClass:[NSNull class]]&& ![timePunchUri isEqualToString:@""]) {
                            timePunchId=timePunchUri;
                        }
                        else
                        {
                            timePunchId=[NSNull null];
                        }
                        NSMutableDictionary *targetDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                           timePunchId,@"uri",
                                                           //[Util getRandomGUID],@"parameterCorrelationId",
                                                           nil];//35734 DCAA Changes
                        id target=nil;
                        if (timePunchUri!=nil && ![timePunchUri isKindOfClass:[NSNull class]]&& ![timePunchUri isEqualToString:@""])
                        {
                            target=targetDict;
                        }
                        else
                        {
                            target=[NSNull null];
                        }
                        id projectInfo=nil;
                        id taskInfo=nil;
                        id billingInfo=nil;
                        id activityInfo=nil;
                        id breakInfo=nil; //Implentation for US8956//JUHI
                        if (isExtendedInOutUser)
                        {
                            
                            NSString *projectUristr=[tsEntryObject timeEntryProjectUri];
                            NSString *taskUristr=[tsEntryObject timeEntryTaskUri];
                            NSString *billingUristr=[tsEntryObject timeEntryBillingUri];
                            NSString *activityUristr=[tsEntryObject timeEntryActivityUri];
                            //Implentation for US8956//JUHI
                            NSString *breakUriStr=[tsEntryObject breakUri];
                            if ([rowUri isEqualToString:[tsEntryObject timePunchUri]])
                            {
                                activityUristr=[adhocEntryDict objectForKey:@"activityUri"];
                                billingUristr=[adhocEntryDict objectForKey:@"billingUri"];
                                projectUristr=[adhocEntryDict objectForKey:@"projectUri"];
                                taskUristr=[adhocEntryDict objectForKey:@"taskUri"];
                                breakUriStr=[adhocEntryDict objectForKey:@"breakUri"];
                                
                            }
                            if ([projectUristr isEqualToString:@""]||[projectUristr isKindOfClass:[NSNull class]]||projectUristr==nil||[projectUristr isEqualToString:NULL_STRING])
                            {
                                projectInfo=[NSNull null];
                            }
                            else
                            {
                                projectInfo=[NSDictionary dictionaryWithObjectsAndKeys:projectUristr,@"uri", nil];
                            }
                            if ([taskUristr isEqualToString:@""]||[taskUristr isKindOfClass:[NSNull class]]||taskUristr==nil||[taskUristr isEqualToString:NULL_STRING])
                            {
                                taskInfo=[NSNull null];
                            }
                            else
                            {
                                taskInfo=[NSDictionary dictionaryWithObjectsAndKeys:taskUristr,@"uri", nil];
                                
                            }
                            if ([billingUristr isEqualToString:@""]||[billingUristr isKindOfClass:[NSNull class]]||billingUristr==nil||[billingUristr isEqualToString:NULL_STRING])
                            {
                                billingInfo=[NSNull null];
                            }
                            else
                            {
                                billingInfo=[NSDictionary dictionaryWithObjectsAndKeys:billingUristr,@"uri", nil];
                            }
                            if ([activityUristr isEqualToString:@""]||[activityUristr isKindOfClass:[NSNull class]]||activityUristr==nil||[activityUristr isEqualToString:NULL_STRING])
                            {
                                activityInfo=[NSNull null];
                            }
                            else
                            {
                                activityInfo=[NSDictionary dictionaryWithObjectsAndKeys:activityUristr,@"uri", nil];
                            }
                            //Implentation for US8956//JUHI
                            if ([breakUriStr isEqualToString:@""]||[breakUriStr isKindOfClass:[NSNull class]]||breakUriStr==nil)
                            {
                                breakInfo=[NSNull null];
                            }
                            else
                            {
                                breakInfo=[NSDictionary dictionaryWithObjectsAndKeys:breakUriStr,@"uri", nil];
                            }
                        }
                        else
                        {
                            projectInfo=[NSNull null];
                            taskInfo=[NSNull null];
                            billingInfo=[NSNull null];
                            activityInfo=[NSNull null];
                            breakInfo=[NSNull null];//Implentation for US8956//JUHI
                        }
                        id comments=nil;
                        if (commentsToSave==nil ||[commentsToSave isKindOfClass:[NSNull class]]||[commentsToSave isEqualToString:@""])
                        {
                            comments=[NSNull null];
                        }
                        else
                        {
                            comments=commentsToSave;
                        }
                        id customFieldValuesArrayID=customFieldValuesArray;
                        if (breakInfo!=nil&&![breakInfo isKindOfClass:[NSNull class]])
                        {
                            customFieldValuesArrayID=[NSNull null];
                        }
                        NSMutableDictionary *timePunchEntryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                   inTimeInfoDict,@"inTime",
                                                                   outTimeInfoDict,@"outTime",
                                                                   customFieldValuesArrayID,@"customFields",
                                                                   target,@"target",
                                                                   comments,@"comments",
                                                                   projectInfo,@"projectUri",
                                                                   taskInfo,@"taskUri",
                                                                   billingInfo,@"billingRateUri",
                                                                   activityInfo,@"activityUri",
                                                                   breakInfo,@"breakTypeUri",
                                                                   [NSNull null],@"timeOffTypeUri",
                                                                   
                                                                   nil];
                        
                        //                            NSMutableDictionary *entryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        //                                                              [NSNull null],@"timeAllocationEntry",
                        //                                                              timePunchEntryDict,@"timePunch",
                        //                                                              nil];
                        [entriesArray addObject:timePunchEntryDict];
                        
                    }
                    
                }
            }
            else
            {
                NSMutableDictionary *inoutEntryDict=[tsEntryObject multiDayInOutEntry];
                NSString *inTime=[inoutEntryDict objectForKey:@"in_time"];
                id inTimeInfoDict=nil;
                if (inTime!=nil && ![inTime isKindOfClass:[NSNull class]]&& ![inTime isEqualToString:@""])
                {
                    inTime = [Util convert12HourTimeStringTo24HourTimeString:inTime];
                    NSArray *inTimeComponentsArray=[inTime componentsSeparatedByString:@":"];
                    int inHours=0;
                    int inMinutes=0;
                    int inSeconds=0;
                    if ([inTimeComponentsArray count]>1)
                    {
                        inHours=[[inTimeComponentsArray objectAtIndex:0] intValue];
                        inMinutes=[[inTimeComponentsArray objectAtIndex:1] intValue];
                    }
                    
                    NSMutableDictionary *inTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                       [NSString stringWithFormat:@"%d",year],@"year",
                                                       [NSString stringWithFormat:@"%d",month],@"month",
                                                       [NSString stringWithFormat:@"%d",day],@"day",
                                                       [NSString stringWithFormat:@"%d",inHours],@"hour",
                                                       [NSString stringWithFormat:@"%d",inMinutes],@"minute",
                                                       [NSString stringWithFormat:@"%d",inSeconds],@"second",
                                                       [NSNull null],@"timeZoneUri",
                                                       nil];
                    BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutEntryDict];
                    if (isMidCrossOverForEntry)
                    {
                        NSDateComponents *components= [[NSDateComponents alloc] init];
                        [components setDay:1];
                        NSCalendar *calendar = [NSCalendar currentCalendar];
                        calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                        NSDate *dateIncremented= [calendar dateByAddingComponents:components toDate:[tsEntryObject timeEntryDate] options:0];
                        NSDictionary *dict=[Util convertDateToApiDateDictionary:dateIncremented];
                        year=[[dict objectForKey:@"year"] intValue];
                        month=[[dict objectForKey:@"month"] intValue];
                        day=[[dict objectForKey:@"day"] intValue];
                        
                    }
                    inTimeInfoDict=inTimeDict;
                    
                }
                else
                {
                    inTimeInfoDict=[NSNull null];
                }
                id outTimeInfoDict=nil;
                NSString *outTime=[inoutEntryDict objectForKey:@"out_time"];
                if (outTime!=nil && ![outTime isKindOfClass:[NSNull class]]&& ![outTime isEqualToString:@""])
                {
                    outTime = [Util convert12HourTimeStringTo24HourTimeString:outTime];
                    
                    NSArray *outTimeComponentsArray=[outTime componentsSeparatedByString:@":"];
                    int outHours=0;
                    int outMinutes=0;
                    int outSeconds=0;
                    if ([outTimeComponentsArray count]>1)
                    {
                        outHours=[[outTimeComponentsArray objectAtIndex:0] intValue];
                        outMinutes=[[outTimeComponentsArray objectAtIndex:1] intValue];
                    }
                    
                    NSMutableDictionary *outTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                        [NSString stringWithFormat:@"%d",year],@"year",
                                                        [NSString stringWithFormat:@"%d",month],@"month",
                                                        [NSString stringWithFormat:@"%d",day],@"day",
                                                        [NSString stringWithFormat:@"%d",outHours],@"hour",
                                                        [NSString stringWithFormat:@"%d",outMinutes],@"minute",
                                                        [NSString stringWithFormat:@"%d",outSeconds],@"second",
                                                        [NSNull null],@"timeZoneUri",
                                                        nil];
                    outTimeInfoDict=outTimeDict;
                }
                else
                {
                    outTimeInfoDict=[NSNull null];
                }
                
                
                /*NSMutableDictionary *dateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                 [NSString stringWithFormat:@"%d",year],@"year",
                 [NSString stringWithFormat:@"%d",month],@"month",
                 [NSString stringWithFormat:@"%d",day],@"day",
                 nil];*/
                NSMutableArray *customFieldValuesArray=[NSMutableArray array];
                NSMutableArray *cellLevelcustomFieldArray=[tsEntryObject timeEntryUdfArray];
                for (int k=0; k<[cellLevelcustomFieldArray count]; k++)
                {
                    EntryCellDetails *udfDetails=[cellLevelcustomFieldArray objectAtIndex:k];
                    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                    NSString *udfType=[udfDetails fieldType];
                    NSString *udfUri=[udfDetails udfIdentity];
                    if ([udfType isEqualToString:UDFType_TEXT])
                    {
                        NSString *defaultValue=[udfDetails fieldValue];
                        if (defaultValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
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
                    else if ([udfType isEqualToString:UDFType_NUMERIC])
                    {
                        NSString *defaultValue=[udfDetails fieldValue];
                        
                        if (defaultValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
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
                    else if ([udfType isEqualToString:UDFType_DATE])
                    {
                        NSString *defaultValue=[NSString stringWithFormat:@"%@",[udfDetails fieldValue]];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        
                        NSLocale *locale=[NSLocale currentLocale];
                        [dateFormatter setLocale:locale];
                        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                        [dateFormatter setDateFormat:@"MMMM dd,yyyy"];
                        NSDate *dropdownDateValue	=[dateFormatter dateFromString:defaultValue];
                        
                        
                        if (dropdownDateValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                        {
                            NSDictionary *dateDict=[Util convertDateToApiDateDictionary:dropdownDateValue];
                            [dataDict setObject:dateDict      forKey:@"date"];
                        }
                        else
                        {
                            [dataDict setObject:[NSNull null]      forKey:@"date"];
                        }
                        
                        
                        [dataDict setObject:[NSNull null] forKey:@"text"];
                        [dataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                        [dataDict setObject:[NSNull null] forKey:@"number"];
                    }
                    else if ([udfType isEqualToString:UDFType_DROPDOWN])
                    {
                        NSString *defaultValue=[udfDetails dropdownOptionUri];
                        if (defaultValue!=nil && ![defaultValue isKindOfClass:[NSNull class]])
                        {
                            if (![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
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
                    
                    [customFieldValuesArray addObject:dataDict];
                    
                }
                NSString *timePunchUri=[tsEntryObject timePunchUri];
                NSMutableDictionary *targetDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   timePunchUri,@"uri",
                                                   [NSNull null],@"parameterCorrelationId",
                                                   nil];
                id target=nil;
                if (timePunchUri!=nil && ![timePunchUri isKindOfClass:[NSNull class]]&& ![timePunchUri isEqualToString:@""])
                {
                    target=targetDict;
                }
                else
                {
                    target=[NSNull null];
                }
                id projectInfo=nil;
                id taskInfo=nil;
                id billingInfo=nil;
                id activityInfo=nil;
                id breakInfo=nil; //Implentation for US8956//JUHI
                if (isExtendedInOutUser)
                {
                    
                    NSString *projectUristr=[tsEntryObject timeEntryProjectUri];
                    NSString *taskUristr=[tsEntryObject timeEntryTaskUri];
                    NSString *billingUristr=[tsEntryObject timeEntryBillingUri];
                    NSString *activityUristr=[tsEntryObject timeEntryActivityUri];
                    //Implentation for US8956//JUHI
                    NSString *breakUriStr=[tsEntryObject breakUri];
                    if ([rowUri isEqualToString:[tsEntryObject timePunchUri]])
                    {
                        activityUristr=[adhocEntryDict objectForKey:@"activityUri"];
                        billingUristr=[adhocEntryDict objectForKey:@"billingUri"];
                        projectUristr=[adhocEntryDict objectForKey:@"projectUri"];
                        taskUristr=[adhocEntryDict objectForKey:@"taskUri"];
                        breakUriStr=[adhocEntryDict objectForKey:@"breakUri"];
                    }
                    if ([projectUristr isEqualToString:@""]||[projectUristr isKindOfClass:[NSNull class]]||projectUristr==nil)
                    {
                        projectInfo=[NSNull null];
                    }
                    else
                    {
                        projectInfo=projectUristr;
                    }
                    if ([taskUristr isEqualToString:@""]||[taskUristr isKindOfClass:[NSNull class]]||taskUristr==nil)
                    {
                        taskInfo=[NSNull null];
                    }
                    else
                    {
                        taskInfo=taskUristr;
                    }
                    if ([billingUristr isEqualToString:@""]||[billingUristr isKindOfClass:[NSNull class]]||billingUristr==nil)
                    {
                        billingInfo=[NSNull null];
                    }
                    else
                    {
                        billingInfo=billingUristr;
                    }
                    if ([activityUristr isEqualToString:@""]||[activityUristr isKindOfClass:[NSNull class]]||activityUristr==nil)
                    {
                        activityInfo=[NSNull null];
                    }
                    else
                    {
                        activityInfo=activityUristr;
                    }
                    
                    //Implentation for US8956//JUHI
                    if ([breakUriStr isEqualToString:@""]||[breakUriStr isKindOfClass:[NSNull class]]||breakUriStr==nil)
                    {
                        breakInfo=[NSNull null];
                    }
                    else
                    {
                        breakInfo=breakUriStr;
                    }
                }
                else
                {
                    projectInfo=[NSNull null];
                    taskInfo=[NSNull null];
                    billingInfo=[NSNull null];
                    activityInfo=[NSNull null];
                    breakInfo=[NSNull null];//Implentation for US8956//JUHI
                }
                NSMutableDictionary *timePunchEntryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                           inTimeInfoDict,@"inTime",
                                                           outTimeInfoDict,@"outTime",
                                                           customFieldValuesArray,@"customFields",
                                                           target,@"target",
                                                           [NSNull null],@"comments",
                                                           projectInfo,@"projectUri",
                                                           taskInfo,@"taskUri",
                                                           billingInfo,@"billingRateUri",
                                                           activityInfo,@"activityUri",
                                                           breakInfo,@"breakTypeUri",
                                                           [NSNull null],@"timeOffTypeUri",
                                                           
                                                           nil];
                
                //                    NSMutableDictionary *entryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                //                                                      [NSNull null],@"timeAllocationEntry",
                //                                                      timePunchEntryDict,@"timePunch",
                //                                                      nil];
                [entriesArray addObject:timePunchEntryDict];
            }
            
            
            
            
            
        }
        
    }
    else
    {
        NSMutableArray *tempDistinctProjectUriArray=[NSMutableArray array];
        NSMutableArray *distinctProjectUriArray=[NSMutableArray array];
        
        
        
        
        for (int i=0; i<[timeEntryObjectArray count]; i++)
        {
            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timeEntryObjectArray objectAtIndex:i];
            NSString *rowUri=[tsEntryObject rowUri];
            //Implementation for US9371//JUHI
            NSMutableArray *rowCustomFieldValuesArray=[NSMutableArray array];
            NSMutableArray *rowLevelcustomFieldArray=[tsEntryObject timeEntryRowUdfArray];
            for (int k=0; k<[rowLevelcustomFieldArray count]; k++)
            {
                EntryCellDetails *udfDetails=[rowLevelcustomFieldArray objectAtIndex:k];
                NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                NSString *udfType=[udfDetails fieldType];
                NSString *udfUri=[udfDetails udfIdentity];
                if ([udfType isEqualToString:UDFType_TEXT])
                {
                    NSString *defaultValue=[udfDetails fieldValue];
                    
                    if (defaultValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
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
                else if ([udfType isEqualToString:UDFType_NUMERIC])
                {
                    NSString *defaultValue=[udfDetails fieldValue];
                    if (defaultValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
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
                else if ([udfType isEqualToString:UDFType_DATE])
                {
                    NSString *defaultValue=[NSString stringWithFormat:@"%@",[udfDetails fieldValue]];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    
                    NSLocale *locale=[NSLocale currentLocale];
                    [dateFormatter setLocale:locale];
                    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [dateFormatter setDateFormat:@"MMMM dd,yyyy"];
                    NSDate *dropdownDateValue	=[dateFormatter dateFromString:defaultValue];
                    
                    
                    //Fix for Defect DE19008//JUHI
                    if (dropdownDateValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                    {
                        
                        NSDictionary *dateDict=[Util convertDateToApiDateDictionary:dropdownDateValue];
                        [dataDict setObject:dateDict      forKey:@"date"];
                    }
                    else
                    {
                        [dataDict setObject:[NSNull null]      forKey:@"date"];
                    }
                    
                    
                    [dataDict setObject:[NSNull null] forKey:@"text"];
                    [dataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                    [dataDict setObject:[NSNull null] forKey:@"number"];
                }
                else if ([udfType isEqualToString:UDFType_DROPDOWN])
                {
                    NSString *defaultValue=[udfDetails dropdownOptionUri];
                    if (defaultValue!=nil && ![defaultValue isKindOfClass:[NSNull class]])
                    {
                        if (![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
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
                
                [rowCustomFieldValuesArray addObject:dataDict];
                
            }
            if (![tempDistinctProjectUriArray containsObject:rowUri])
            {
                if(rowUri!=nil && ![rowUri isKindOfClass:[NSNull class]])
                {
                    [tempDistinctProjectUriArray addObject:rowUri];
                }
                
                
                
                id projectName=nil;
                id projectUri=nil;
                id activityName=nil;
                id activityUri=nil;
                id billingName=nil;
                id billingUri=nil;
                id taskName=nil;
                id taskUri=nil;
                
                
                NSString *timeEntryProjectName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryProjectName]];
                if (timeEntryProjectName==nil||[timeEntryProjectName isKindOfClass:[NSNull class]]||[timeEntryProjectName isEqualToString:@""]||[timeEntryProjectName isEqualToString:NULL_STRING]||[timeEntryProjectName isEqualToString:NULL_OBJECT_STRING])
                {
                    projectName=[NSNull null];
                }
                else
                {
                    projectName=timeEntryProjectName;
                }
                NSString *timeEntryProjectUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryProjectUri]];
                if (timeEntryProjectUri==nil||[timeEntryProjectUri isKindOfClass:[NSNull class]]||[timeEntryProjectUri isEqualToString:@""]||[timeEntryProjectUri isEqualToString:NULL_STRING]||[timeEntryProjectUri isEqualToString:NULL_OBJECT_STRING])
                {
                    projectUri=[NSNull null];
                }
                else
                {
                    projectUri=timeEntryProjectUri;
                }
                NSString *timeEntryActivityName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryActivityName]];
                if (timeEntryActivityName==nil||[timeEntryActivityName isKindOfClass:[NSNull class]]||[timeEntryActivityName isEqualToString:@""]||[timeEntryActivityName isEqualToString:NULL_STRING]||[timeEntryActivityName isEqualToString:NULL_OBJECT_STRING])
                {
                    activityName=[NSNull null];
                }
                else
                {
                    activityName=timeEntryActivityName;
                }
                NSString *timeEntryActivityUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryActivityUri]];
                if (timeEntryActivityUri==nil||[timeEntryActivityUri isKindOfClass:[NSNull class]]||[timeEntryActivityUri isEqualToString:@""]||[timeEntryActivityUri isEqualToString:NULL_STRING]||[timeEntryActivityUri isEqualToString:NULL_OBJECT_STRING])
                {
                    activityUri=[NSNull null];
                }
                else
                {
                    activityUri=timeEntryActivityUri;
                }
                NSString *timeEntryBillingName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryBillingName]];
                if (timeEntryBillingName==nil||[timeEntryBillingName isKindOfClass:[NSNull class]]||[timeEntryBillingName isEqualToString:@""]||[timeEntryBillingName isEqualToString:NULL_STRING]||[timeEntryBillingName isEqualToString:NULL_OBJECT_STRING])
                {
                    billingName=[NSNull null];
                }
                else
                {
                    billingName=timeEntryBillingName;
                }
                NSString *timeEntryBillingUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryBillingUri]];
                if (timeEntryBillingUri==nil||[timeEntryBillingUri isKindOfClass:[NSNull class]]||[timeEntryBillingUri isEqualToString:@""]||[timeEntryBillingUri isEqualToString:NULL_STRING]||[timeEntryBillingUri isEqualToString:NULL_OBJECT_STRING])
                {
                    billingUri=[NSNull null];
                }
                else
                {
                    billingUri=timeEntryBillingUri;
                }
                NSString *timeEntryTaskName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryTaskName]];
                if (timeEntryTaskName==nil||[timeEntryTaskName isKindOfClass:[NSNull class]]||[timeEntryTaskName isEqualToString:@""]||[timeEntryTaskName isEqualToString:NULL_STRING]||[timeEntryTaskName isEqualToString:NULL_OBJECT_STRING])
                {
                    taskName=[NSNull null];
                }
                else
                {
                    taskName=timeEntryTaskName;
                }
                NSString *timeEntryTaskUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryTaskUri]];
                if (timeEntryTaskUri==nil||[timeEntryTaskUri isKindOfClass:[NSNull class]]||[timeEntryTaskUri isEqualToString:@""]||[timeEntryTaskUri isEqualToString:NULL_STRING]||[timeEntryTaskUri isEqualToString:NULL_OBJECT_STRING])
                {
                    taskUri=[NSNull null];
                }
                else
                {
                    taskUri=timeEntryTaskUri;
                }
                
                //Implementation for US9371//JUHI
                NSMutableDictionary *infoDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               projectName,@"projectName",
                                               projectUri,@"projectUri",
                                               activityName,@"activityName",
                                               activityUri,@"activityUri",
                                               billingName,@"billingName",
                                               billingUri,@"billingUri",
                                               taskName,@"taskName",
                                               taskUri,@"taskUri",
                                              
                                               rowUri,@"rowUri",
                                               
                                               rowCustomFieldValuesArray,@"rowCustomField",nil];
                
                [distinctProjectUriArray addObject:infoDict];
            }
        }
        
        
        for (int k=0; k<[distinctProjectUriArray count]; k++)
        {
            NSString *tmpProjectName=[[distinctProjectUriArray objectAtIndex:k] objectForKey:@"projectName"];
            NSString *tmpProjectUri=[[distinctProjectUriArray objectAtIndex:k] objectForKey:@"projectUri"];
            NSString *tmpActivityName=[[distinctProjectUriArray objectAtIndex:k] objectForKey:@"activityName"];
            NSString *tmpActivityUri=[[distinctProjectUriArray objectAtIndex:k] objectForKey:@"activityUri"];
            NSString *tmpBillingName=[[distinctProjectUriArray objectAtIndex:k] objectForKey:@"billingName"];
            NSString *tmpBillingUri=[[distinctProjectUriArray objectAtIndex:k] objectForKey:@"billingUri"];
            NSString *tmpTaskName=[[distinctProjectUriArray objectAtIndex:k] objectForKey:@"taskName"];
            NSString *tmpTaskUri=[[distinctProjectUriArray objectAtIndex:k] objectForKey:@"taskUri"];
            NSString *tmpRowUri=[[distinctProjectUriArray objectAtIndex:k] objectForKey:@"rowUri"];
           
            
            //Implementation for US9371//JUHI
            NSMutableArray *rowCustomFieldValuesArray=[[distinctProjectUriArray objectAtIndex:k] objectForKey:@"rowCustomField"];
            NSMutableDictionary *projectDictionary=[NSMutableDictionary dictionary];
            if (tmpProjectUri!=nil && ![tmpProjectUri isKindOfClass:[NSNull class]]&& ![tmpProjectUri isEqualToString:@""] && ![tmpProjectUri isEqualToString:NULL_STRING])
            {
                [projectDictionary setObject:tmpProjectUri forKey:@"uri"];
                [projectDictionary setObject:tmpProjectName forKey:@"name"];
            }
            else
            {
                projectDictionary=nil;
            }
            NSMutableDictionary *taskDictionary=[NSMutableDictionary dictionary];
            if (tmpTaskUri!=nil && ![tmpTaskUri isKindOfClass:[NSNull class]]&& ![tmpTaskUri isEqualToString:@""])
            {
                [taskDictionary setObject:tmpTaskUri forKey:@"uri"];
                [taskDictionary setObject:tmpTaskName forKey:@"name"];
            }
            else
            {
                taskDictionary=nil;
            }
            NSMutableDictionary *activityDictionary=[NSMutableDictionary dictionary];
            if (tmpActivityUri!=nil && ![tmpActivityUri isKindOfClass:[NSNull class]]&& ![tmpActivityUri isEqualToString:@""])
            {
                [activityDictionary setObject:tmpActivityUri forKey:@"uri"];
                [activityDictionary setObject:tmpActivityName forKey:@"name"];
            }
            else
            {
                activityDictionary=nil;
            }
            NSMutableDictionary *billingDictionary=[NSMutableDictionary dictionary];
            if (tmpBillingUri!=nil && ![tmpBillingUri isKindOfClass:[NSNull class]]&& ![tmpBillingUri isEqualToString:@""])
            {
                [billingDictionary setObject:tmpBillingUri forKey:@"uri"];
                [billingDictionary setObject:tmpBillingName forKey:@"name"];
            }
            else
            {
                billingDictionary=nil;
            }
            
            

            
            NSMutableArray *customFieldValuesArrayForTimeoffs=[NSMutableArray array];
            NSMutableArray *arrayTemp=[NSMutableArray array];
            
            for (int i=0; i<[timeEntryObjectArray count]; i++)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timeEntryObjectArray objectAtIndex:i];
                if ([tsEntryObject isTimeoffSickRowPresent])
                {
                    NSString *rowUri=[tsEntryObject rowUri];
                    if (rowUri != nil && ![rowUri isKindOfClass:[NSNull class]]) {
                        if ([rowUri isEqualToString:tmpRowUri])
                        {
                            NSString *entryHours=[tsEntryObject timeEntryHoursInDecimalFormat];
                            
                            NSDictionary *dateDict=[Util convertDateToApiDateDictionary:[tsEntryObject timeEntryDate]];
                            NSMutableDictionary *durationDict = [Util convertDecimalHoursToApiTimeDict:entryHours];
                            BOOL hasAnyUdfValueChanged=NO;
                            NSMutableArray *customFieldValuesArray=[NSMutableArray array];
                            NSMutableArray *cellLevelcustomFieldArray=[tsEntryObject timeEntryUdfArray];
                            for (int k=0; k<[cellLevelcustomFieldArray count]; k++)
                            {
                                EntryCellDetails *udfDetails=[cellLevelcustomFieldArray objectAtIndex:k];
                                NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                                NSString *udfType=[udfDetails fieldType];
                                NSString *udfUri=[udfDetails udfIdentity];
                                if ([udfType isEqualToString:UDFType_TEXT])
                                {
                                    NSString *defaultValue=[udfDetails fieldValue];
                                    
                                    if (defaultValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                                    {
                                        hasAnyUdfValueChanged=YES;
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
                                else if ([udfType isEqualToString:UDFType_NUMERIC])
                                {
                                    NSString *defaultValue=[udfDetails fieldValue];
                                    
                                    
                                    if (defaultValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                                    {
                                        hasAnyUdfValueChanged=YES;
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
                                else if ([udfType isEqualToString:UDFType_DATE])
                                {
                                    NSString *defaultValue=[NSString stringWithFormat:@"%@",[udfDetails fieldValue]];
                                    
                                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                    
                                    NSLocale *locale=[NSLocale currentLocale];
                                    [dateFormatter setLocale:locale];
                                    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                                    [dateFormatter setDateFormat:@"MMMM dd,yyyy"];
                                    NSDate *dropdownDateValue	=[dateFormatter dateFromString:defaultValue];
                                    
                                    
                                    //Fix for Defect DE19008//JUHI
                                    if (dropdownDateValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                    {
                                        hasAnyUdfValueChanged=YES;
                                        NSDictionary *dateDict=[Util convertDateToApiDateDictionary:dropdownDateValue];
                                        [dataDict setObject:dateDict      forKey:@"date"];
                                    }
                                    else
                                    {
                                        [dataDict setObject:[NSNull null]      forKey:@"date"];
                                    }
                                    
                                    
                                    [dataDict setObject:[NSNull null] forKey:@"text"];
                                    [dataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                                    [dataDict setObject:[NSNull null] forKey:@"number"];
                                }
                                else if ([udfType isEqualToString:UDFType_DROPDOWN])
                                {
                                    NSString *defaultValue=[udfDetails dropdownOptionUri];
                                    if (defaultValue!=nil && ![defaultValue isKindOfClass:[NSNull class]])
                                    {
                                        if (![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                        {
                                            hasAnyUdfValueChanged=YES;
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
                                
                                [customFieldValuesArray addObject:dataDict];
                                [customFieldValuesArrayForTimeoffs addObject:customFieldValuesArray];
                            }
                            
                            if ([entryHours isEqualToString:@"0.00"]&&[[tsEntryObject entryType] isEqualToString:Time_Off_Key])
                            {
                                hasAnyUdfValueChanged=NO;
                            }
                            
                            NSString *comments=[tsEntryObject timeEntryComments];
                            if ((comments!=nil && ![comments isKindOfClass:[NSNull class]] && [comments length]>0)||![entryHours isEqualToString:@"0.00"]||hasAnyUdfValueChanged)
                            {
                                NSMutableDictionary *cellDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                 dateDict,@"date",
                                                                 durationDict,@"duration",
                                                                 [tsEntryObject timeEntryComments],@"comments",
                                                                 [NSNull null],@"customFieldValues",
                                                                 nil];
                                
                                
                                [arrayTemp addObject:cellDict];
                                
                            }
                            
                        }                    }
                }
                else
                {
                    NSString *rowUri=[tsEntryObject rowUri];
                    if (![rowUri isKindOfClass:[NSNull class]])
                    {
                        if ([rowUri isEqualToString:tmpRowUri] || (rowUri==nil && tmpRowUri ==nil))
                        {
                            NSString *entryHours=[tsEntryObject timeEntryHoursInDecimalFormat];

                            NSMutableDictionary *durationDict = [Util convertDecimalHoursToApiTimeDict:entryHours];
                            NSDictionary *dateDict=[Util convertDateToApiDateDictionary:[tsEntryObject timeEntryDate]];
                            //Fix for MOBI-648_DataLossIssueForUdf//JUHI
                            BOOL hasAnyTexttUdfValueChanged=NO;
                            BOOL hasAnyNumberUdfValueChanged=NO;
                            BOOL hasAnyDateUdfValueChanged=NO;
                            BOOL hasAnyDropDownUdfValueChanged=NO;
                            NSMutableArray *customFieldValuesArray=[NSMutableArray array];
                            NSMutableArray *cellLevelcustomFieldArray=[tsEntryObject timeEntryUdfArray];
                            for (int k=0; k<[cellLevelcustomFieldArray count]; k++)
                            {
                                EntryCellDetails *udfDetails=[cellLevelcustomFieldArray objectAtIndex:k];
                                NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                                NSString *udfType=[udfDetails fieldType];
                                NSString *udfUri=[udfDetails udfIdentity];
                                NSString *systemDefaultValue=[udfDetails systemDefaultValue];
                                if ([udfType isEqualToString:UDFType_TEXT])
                                {
                                    NSString *defaultValue=[udfDetails fieldValue];

                                    if (defaultValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                                    {
                                        //Fix for MOBI-648_DataLossIssueForUdf//JUHI
                                        if (systemDefaultValue!=nil && ![systemDefaultValue isKindOfClass:[NSNull class]])
                                        {
                                            if (![systemDefaultValue isEqualToString:defaultValue])
                                            {
                                                hasAnyTexttUdfValueChanged=YES;
                                            }
                                            else
                                            {
                                                hasAnyTexttUdfValueChanged=NO;
                                            }

                                        }
                                        else
                                        {
                                            hasAnyTexttUdfValueChanged=YES;
                                        }

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
                                else if ([udfType isEqualToString:UDFType_NUMERIC])
                                {
                                    NSString *defaultValue=[udfDetails fieldValue];
                                    if (defaultValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                                    {//Fix for MOBI-648_DataLossIssueForUdf//JUHI
                                        if (systemDefaultValue!=nil && ![systemDefaultValue isKindOfClass:[NSNull class]])
                                        {
                                            if (![systemDefaultValue isEqualToString:defaultValue])
                                            {
                                                hasAnyNumberUdfValueChanged=YES;
                                            }
                                            else
                                            {
                                                hasAnyNumberUdfValueChanged=NO;
                                            }

                                        }
                                        else
                                        {
                                            hasAnyNumberUdfValueChanged=YES;
                                        }
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
                                else if ([udfType isEqualToString:UDFType_DATE])
                                {
                                    NSString *defaultValue=[NSString stringWithFormat:@"%@",[udfDetails fieldValue]];
                                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

                                    NSLocale *locale=[NSLocale currentLocale];
                                    [dateFormatter setLocale:locale];
                                    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                                    [dateFormatter setDateFormat:@"MMMM dd,yyyy"];
                                    NSDate *dropdownDateValue	=[dateFormatter dateFromString:defaultValue];


                                    //Fix for Defect DE19008//JUHI
                                    if (dropdownDateValue!=nil && ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                    {//Fix for MOBI-648_DataLossIssueForUdf//JUHI
                                        if (systemDefaultValue!=nil && ![systemDefaultValue isKindOfClass:[NSNull class]])
                                        {
                                            if (![systemDefaultValue isEqualToString:defaultValue])
                                            {
                                                hasAnyDateUdfValueChanged=YES;
                                            }
                                            else
                                            {
                                                hasAnyDateUdfValueChanged=NO;
                                            }

                                        }
                                        else
                                        {
                                            hasAnyDateUdfValueChanged=YES;
                                        }
                                        NSDictionary *dateDict=[Util convertDateToApiDateDictionary:dropdownDateValue];
                                        [dataDict setObject:dateDict      forKey:@"date"];
                                    }
                                    else
                                    {
                                        [dataDict setObject:[NSNull null]      forKey:@"date"];
                                    }


                                    [dataDict setObject:[NSNull null] forKey:@"text"];
                                    [dataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                                    [dataDict setObject:[NSNull null] forKey:@"number"];
                                }
                                else if ([udfType isEqualToString:UDFType_DROPDOWN])
                                {
                                    NSString *defaultValue=[udfDetails dropdownOptionUri];


                                    if (defaultValue!=nil && ![defaultValue isKindOfClass:[NSNull class]])
                                    {
                                        if (![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                        {//Fix for MOBI-648_DataLossIssueForUdf//JUHI
                                            if (systemDefaultValue!=nil && ![systemDefaultValue isKindOfClass:[NSNull class]])
                                            {
                                                if (![systemDefaultValue isEqualToString:defaultValue])
                                                {
                                                    hasAnyDropDownUdfValueChanged=YES;
                                                }
                                                else
                                                {
                                                    hasAnyDropDownUdfValueChanged=NO;
                                                }

                                            }
                                            else
                                            {
                                                hasAnyDropDownUdfValueChanged=YES;
                                            }
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

                                [customFieldValuesArray addObject:dataDict];

                            }
                            NSString *comments=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryComments]];
                            //Fix for MOBI-648_DataLossIssueForUdf//JUHI
                            if ((comments!=nil && ![comments isKindOfClass:[NSNull class]] && [comments length]>0)||![entryHours isEqualToString:@"0.00"]||hasAnyDropDownUdfValueChanged||hasAnyDateUdfValueChanged||hasAnyNumberUdfValueChanged||hasAnyTexttUdfValueChanged)
                            {
                                NSMutableDictionary *cellDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                 dateDict,@"date",
                                                                 durationDict,@"duration",
                                                                 [tsEntryObject timeEntryComments],@"comments",
                                                                 customFieldValuesArray,@"customFieldValues",
                                                                 nil];
                                
                                
                                [arrayTemp addObject:cellDict];
                                
                            }
                            
                            
                        }
                    }

                }
                
            }
            
            id projectInfo=nil;
            id taskInfo=nil;
            id activityInfo=nil;
            id billingInfo=nil;
           
            if (projectDictionary!=nil)
            {
                projectInfo=projectDictionary;
            }
            else
            {
                projectInfo=[NSNull null];
            }
            if (taskDictionary!=nil)
            {
                taskInfo=taskDictionary;
            }
            else
            {
                taskInfo=[NSNull null];
            }
            
            if (billingDictionary!=nil)
            {
                billingInfo=billingDictionary;
            }
            else
            {
                billingInfo=[NSNull null];
            }
            
            if (activityDictionary!=nil)
            {
                activityInfo=activityDictionary;
            }
            else
            {
                activityInfo=[NSNull null];
            }
            
            
            
            //time entries
            id rowUri=nil;
            if ([tmpRowUri rangeOfString:@"urn:replicon"].location == NSNotFound || (tmpRowUri==nil || [tmpRowUri isKindOfClass:[NSNull class]]))
            {
                rowUri=[NSNull null];
            }
    
            
            else
            {
                rowUri=tmpRowUri;
            }
            
            
            
            
            NSMutableDictionary *targetDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               rowUri,@"uri",
                                               [NSNull null],@"parameterCorrelationId",nil];
            
            id tmprowCustomFieldValuesArray=nil;
            
            if (rowCustomFieldValuesArray==nil || [rowCustomFieldValuesArray isKindOfClass:[NSNull class]])
            {
                tmprowCustomFieldValuesArray=[NSNull null];
            }
            else
            {
                tmprowCustomFieldValuesArray=rowCustomFieldValuesArray;
            }
            
            //Implementation for US9371//JUHI
            NSMutableDictionary *rowDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            targetDict,@"target",
                                            //correlatedTimeOffUri,@"correlatedTimeOffUri", //LOAD 3 --> LOAD2
                                            projectInfo,@"project",
                                            taskInfo,@"task",
                                            billingInfo,@"billingRate",
                                            activityInfo,@"activity",
                                            //timeoffInfo,@"timeOffType", //LOAD 3 --> LOAD2
                                            tmprowCustomFieldValuesArray,@"customFieldValues",
                                            arrayTemp,@"cells",
                                            nil];
            
            [cellArray addObject:rowDict];
            
            
            
        }
        
    }
    
    
    NSMutableDictionary *dataDict=nil;
    NSString *strUserURI=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserUri"];
    NSMutableArray *sheetLevelcustomFieldArray=[NSMutableArray array];
    for (int i=0; i<[sheetLevelUdfArray count]; i++)
    {
        NSMutableDictionary *dict=[sheetLevelUdfArray objectAtIndex:i];
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSString *udfType=[dict objectForKey:@"type"];
        NSString *udfUri=[dict objectForKey:@"uri"];
        if ([udfType isEqualToString:TEXT_UDF_TYPE])
        {
            NSString *defaultValue=[dict objectForKey:@"defaultValue"];
            if (defaultValue!=nil && ![defaultValue isEqualToString:@""]&& ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")] && ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
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
        else if ([udfType isEqualToString:NUMERIC_UDF_TYPE])
        {
            NSString *defaultValue=[dict objectForKey:@"defaultValue"];
            
            if (defaultValue!=nil&& ![defaultValue isEqualToString:@""]&& ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")] && ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
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
        else if ([udfType isEqualToString:DATE_UDF_TYPE])
        {
            NSString *defaultValue=[NSString stringWithFormat:@"%@",[dict objectForKey:@"defaultValue"]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            
            NSLocale *locale=[NSLocale currentLocale];
            [dateFormatter setLocale:locale];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
            NSDate *dropdownDateValue	=[dateFormatter dateFromString:defaultValue];
            
            
            if (dropdownDateValue!=nil && ![defaultValue isEqualToString:@""]&& ![defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]&& ![defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")] && ![defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
            {
                NSDictionary *dateDict=[Util convertDateToApiDateDictionary:dropdownDateValue];
                [dataDict setObject:dateDict      forKey:@"date"];
            }
            else
            {
                [dataDict setObject:[NSNull null]      forKey:@"date"];
            }
            
            
            [dataDict setObject:[NSNull null] forKey:@"text"];
            [dataDict setObject:[NSNull null] forKey:@"dropDownOption"];
            [dataDict setObject:[NSNull null] forKey:@"number"];
        }
        else if ([udfType isEqualToString:DROPDOWN_UDF_TYPE])
        {
            NSString *defaultValue=[dict objectForKey:@"dropDownOptionUri"];
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
        
        [sheetLevelcustomFieldArray addObject:dataDict];
    }
    if (isMultiInOutTimeSheetUser)
    {
        NSMutableDictionary *userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       strUserURI,@"uri",
                                       [NSNull null],@"loginName",
                                       nil];
        NSMutableDictionary *targetDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         timesheetURI,@"uri",
                                         userDict,@"user",
                                         [NSNull null],@"date",
                                         nil];
        NSString *isDisclaimerAcceptedString=@"false";
        if (isDisclaimerAccepted)
        {
            isDisclaimerAcceptedString=@"true";
        }
        
        id entriesArrayID=[NSNull null];
        if ([entriesArray count]>0) {
            entriesArrayID=entriesArray;
        }
//        id timeoffArrayID=[NSNull null];
//        if ([timeoffArray count]>0) {
//            timeoffArrayID=timeoffArray;
//        }
        NSMutableDictionary *multiTimesheetDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 targetDict,@"target",
                                                 entriesArrayID,@"entries",
                                                 //timeoffArrayID,@"timeOff",//LOAD 3 --> LOAD2
                                                 sheetLevelcustomFieldArray,@"customFields",
                                                 isDisclaimerAcceptedString,@"noticeExplicitlyAccepted",
                                                 nil];
        
        dataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    multiTimesheetDict,@"inOutTimesheet",
                    [NSNull null],@"standardTimesheet",
                    nil];
    }
    else
    {
        NSMutableDictionary *userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       strUserURI,@"uri",
                                       [NSNull null],@"loginName",
                                       nil];
        NSMutableDictionary *targetDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         timesheetURI,@"uri",
                                         userDict,@"user",
                                         [NSNull null],@"date",
                                         nil];
        NSString *isDisclaimerAcceptedString=@"false";
        if (isDisclaimerAccepted)
        {
            isDisclaimerAcceptedString=@"true";
        }
        
        NSMutableDictionary *standardTimesheetDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    targetDict,@"target",
                                                    cellArray,@"rows",
                                                    sheetLevelcustomFieldArray,@"customFields",//Change
                                                    isDisclaimerAcceptedString,@"noticeExplicitlyAccepted",
                                                    nil];
        
        dataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    [NSNull null],@"inOutTimesheet",
                    standardTimesheetDict,@"standardTimesheet",
                    nil];
        
    }
    
    if (isTimesheetSubmit)
    {
        id comments=submitComments;
        if (comments!=nil)
        {
            comments=submitComments;
        }
        else
        {
            comments=[NSNull null];
        }
        
        id changeReason=reasonForChange;
        if (changeReason==nil)
        {
            changeReason=[NSNull null];
        }
        
        
        //MOBI-303 Ullas M L
        BOOL canEditTimesheet=[timesheetModel getTimeSheetEditStatusForSheetFromDB:timesheetURI];
        if (!canEditTimesheet)
        {
            NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              timesheetURI,@"timesheetUri",
                                              [Util getRandomGUID],@"unitOfWorkId",
                                              comments,@"comments",
                                              changeReason,@"changeReason",
                                              nil];
            NSError *err = nil;
            NSString *str = [JsonWrapper writeJson:queryDict error:&err];
            
            NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
            NSString *urlStr=nil;
            
            urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"SubmitTimesheetDataForLockedInOut"]];
            DLog(@"URL:::%@",urlStr);
            [paramDict setObject:urlStr forKey:@"URLString"];
            [paramDict setObject:str forKey:@"PayLoadStr"];
            [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
            [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"SubmitTimesheetData"]];
            [self setServiceDelegate:self];
            [self executeRequest];
        }
        else
        {
            NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              dataDict,@"data",
                                              [Util getRandomGUID],@"unitOfWorkId",
                                              comments,@"comments",
                                              changeReason,@"changeReason",
                                              nil];
            NSError *err = nil;
            NSString *str = [JsonWrapper writeJson:queryDict error:&err];
            
            NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
            NSString *urlStr=nil;
            urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"SubmitTimesheetData"]];
            
            DLog(@"URL:::%@",urlStr);
            [paramDict setObject:urlStr forKey:@"URLString"];
            [paramDict setObject:str forKey:@"PayLoadStr"];
            [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
            [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"SubmitTimesheetData"]];
            [self setServiceDelegate:self];
            [self executeRequest];
            
        }
        
        
    }
    else
    {
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          dataDict,@"data",
                                          [Util getRandomGUID],@"unitOfWorkId",
                                          nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"SaveTimesheetData"]];
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"SaveTimesheetData"]];
        [self setServiceDelegate:self];
        [self executeRequest:isAutoSaveStr];
        
    }
    
    
    
    
    
}

-(void)sendRequestToSubmitTimesheetDataForTimesheetURI:(NSString *)timesheetURI withComments:(NSString *)comments withDelegate:(id)delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timesheetURI,@"timesheetUri",
                                      [Util getRandomGUID],@"unitOfWorkId",
                                      nil];
    
    if (comments==nil || [comments isKindOfClass:[NSNull class]])
    {
        [queryDict setObject:[NSNull null] forKey:@"comments"];
    }
    else
    {
        [queryDict setObject:comments forKey:@"comments"];
    }
    
    
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"SubmitTimesheetData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"SubmitTimesheetData"]];
    [self setServiceDelegate:self];
    [self executeRequest];
    
    
}

-(void)sendRequestToUnsubmitTimesheetDataForTimesheetURI:(NSString *)timesheetURI withComments:(NSString *)comments withDelegate:(id)delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timesheetURI,@"timesheetUri",
                                      [Util getRandomGUID],@"unitOfWorkId",
                                      nil];
    
    
    
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"UnsubmitTimesheetData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"UnsubmitTimesheetData"]];
    [self setServiceDelegate:self];
    [self executeRequest];
    
    
}



//Implentation for US8956//JUHI
/************************************************************************************************************
 @Function Name   : fetchBreakForTimesheetUri
 @Purpose         : Called to get the break
 @param           : timesheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchBreakForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate
{
    [timesheetModel deleteAllBreakInfoFromDB];
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    id searchStr;
    id searchdict;
    
    
    NSNumber *maximumResultCount=[[AppProperties getInstance] getAppPropertyFor:@"breakDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:1] forKey:@"NextBreakPageNo"];
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
                                      timesheetUri ,@"timesheetUri",
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
-(void)fetchNextBreakForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate
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
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextBreakPageNo"];
    [defaults synchronize];
    
    NSNumber *pageNum=[NSNumber numberWithInteger:nextFetchPageNo+1];
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
                                      timesheetUri ,@"timesheetUri",
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

//Implemented as per TIME-495//JUHI
//***********************************************************************************************************
// @Function Name   : fetchTimeSheetSummaryDataForGen4Timesheet
// @Purpose         : Called to get the timesheet summary data for timesheetUri
// @param           : timesheetUri,delegate
// @return          : nil
// *************************************************************************************************************/
-(void)fetchTimeSheetTimeOffSummaryDataForGen4TimesheetWithStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate withDelegate:(id)_delegate withTimesheetUri:(NSString *)timesheetURI
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSDictionary *startDateApiDict=[Util convertDateToApiDateDictionary:startDate];
    NSDictionary *endDateApiDict=[Util convertDateToApiDateDictionary:endDate];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    NSMutableDictionary *dateRangeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          startDateApiDict ,@"startDate",
                                          endDateApiDict ,@"endDate",
                                          nil];
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      strUserURI ,@"userUri",
                                      dateRangeDict ,@"dateRange",
                                      [NSNull null] ,@"relativeDateRangeUri",
                                      [NSNull null] ,@"relativeDateRangeAsOfDate",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Gen4TimesheetTimeoffSummary"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"Gen4TimesheetTimeoffSummary"]];
    [self setServiceDelegate:self];
    [self executeRequest:timesheetURI];
    
}
/************************************************************************************************************
 @Function Name   : sendRequestToSaveWorkTimeEntryForGen4
 @Purpose         : Called to save time entry
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/
-(void)sendRequestToSaveWorkTimeEntryForGen4:(id)delegate withClientID:(NSString *)clientId isBlankTimeEntrySave:(BOOL)isBlankTimeEntrySave withTimeEntryUri:(NSString *)timeEntryUri withStartDate:(NSDate *)startDate forTimeSheetUri:(NSString *)timesheetUri withTimeDict:(NSDictionary *)timeDict timesheetFormat:(NSString *)timesheetFormat andColumnNameForEntryUri:(NSString *)columnName
{


    //SUPPORT OFFLINE SAVE FOR SIMPLE IN OUT TIMESHEET
    if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
    {
        if ([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
        {
            if (isBlankTimeEntrySave)
            {
                [self.timesheetModel insertBlankTimeEntryObjectForGen4:clientId andEntryDate:startDate andTimeSheetURI:timesheetUri];
                //[self.timesheetModel updateTimesheetWithOperationName:TIMESHEET_SAVE_OPERATION andTimesheetURI:timesheetUri];
            }

            else
            {
                NSMutableDictionary *changedTimepairDict=[NSMutableDictionary dictionary];

                NSString *inTime=[timeDict objectForKey:@"in_time"];
                NSString *outTime=[timeDict objectForKey:@"out_time"];
                NSString *comments=@"";

                if (inTime!=nil && ![inTime isKindOfClass:[NSNull class]])
                {
                    [changedTimepairDict setObject:inTime forKey:@"time_in"];
                }
                if (outTime!=nil && ![outTime isKindOfClass:[NSNull class]])
                {
                    [changedTimepairDict setObject:outTime forKey:@"time_out"];
                }
                if ([timeDict objectForKey:@"comments"]!=nil && ![[timeDict objectForKey:@"comments"] isKindOfClass:[NSNull class]])
                {
                    comments=[timeDict objectForKey:@"comments"];
                }

                NSString *decimalHours=@"0.00";
                if ( inTime!=nil && ![inTime isKindOfClass:[NSNull class]] && ![inTime isEqualToString:@""] &&
                    outTime!=nil && ![outTime isKindOfClass:[NSNull class]] && ![outTime isEqualToString:@""])
                {
                    decimalHours=[Util getNumberOfHoursForInTime:inTime outTime:outTime];
                }
                [changedTimepairDict setObject:decimalHours forKey:@"durationDecimalFormat"];
                [changedTimepairDict setObject:comments forKey:@"comments"];
                [changedTimepairDict setObject:[NSNumber numberWithInt:1] forKey:@"isModified"];
                [self.timesheetModel updateTimeEntryTableForTimesheetUri:timesheetUri andClientID:clientId withDataDict:changedTimepairDict andStartDate:startDate andIsBreak:NO andbreakName:nil andbreakUri:nil andEntryURIColumnName:columnName];

                //            [self.timesheetModel updateTimesheetWithOperationName:TIMESHEET_SAVE_OPERATION andTimesheetURI:timesheetUri];
                
            }
            
            [self.timesheetModel updateTotalTimeOnWidgetSummaryTableForTimeSheetUri:timesheetUri];
            
        }
    }

    

    
    [[NSNotificationCenter defaultCenter] postNotificationName: SAVE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:clientId,@"clientId",timeEntryUri,@"timeEntryUri", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName: BLANK_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:clientId,@"clientId",timeEntryUri,@"timeEntryUri", nil]];


}
/************************************************************************************************************
 @Function Name   : sendRequestToSaveBreakTimeEntryForGen4
 @Purpose         : Called to save time entry with breaks
 @param           : _delegate
 @return          : nil
 *************************************************************************************************************/
-(void)sendRequestToSaveBreakTimeEntryForGen4:(id)delegate withBreakUri:(NSString *)breakUri isBlankTimeEntrySave:(BOOL)isBlankTimeEntrySave withTimeEntryUri:(NSString *)timeEntryUri withStartDate:(NSDate *)startDate forTimeSheetUri:(NSString *)timesheetUri withTimeDict:(NSDictionary *)timeDict withClientID:(NSString *)clientId withBreakName:(NSString *)breakName timesheetFormat:(NSString *)timesheetFormat andColumnNameForEntryUri:(NSString *)columnName
{
    
    //SUPPORT OFFLINE SAVE FOR SIMPLE IN OUT TIMESHEET
    if ([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
    {
        if (isBlankTimeEntrySave)
        {
            [self.timesheetModel insertBlankBreakEntryObjectForGen4:clientId andEntryDate:startDate andTimeSheetURI:timesheetUri andBreakName:breakName andBreakUri:breakUri];
            //[self.timesheetModel updateTimesheetWithOperationName:TIMESHEET_SAVE_OPERATION andTimesheetURI:timesheetUri];
        }

        else
        {
            NSMutableDictionary *changedTimepairDict=[NSMutableDictionary dictionary];

            NSString *inTime=[timeDict objectForKey:@"in_time"];
            NSString *outTime=[timeDict objectForKey:@"out_time"];
            NSString *comments=@"";

            if (inTime!=nil && ![inTime isKindOfClass:[NSNull class]])
            {
                [changedTimepairDict setObject:inTime forKey:@"time_in"];
            }
            if (outTime!=nil && ![outTime isKindOfClass:[NSNull class]])
            {
                [changedTimepairDict setObject:outTime forKey:@"time_out"];
            }
            if ([timeDict objectForKey:@"comments"]!=nil && ![[timeDict objectForKey:@"comments"] isKindOfClass:[NSNull class]])
            {
                comments=[timeDict objectForKey:@"comments"];
            }
            if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]])
            {
                [changedTimepairDict setObject:breakUri forKey:@"breakUri"];
            }
            if (breakName!=nil && ![breakName isKindOfClass:[NSNull class]])
            {
                [changedTimepairDict setObject:breakName forKey:@"breakName"];
            }

            NSString *decimalHours=@"0.00";
            if ( inTime!=nil && ![inTime isKindOfClass:[NSNull class]] && ![inTime isEqualToString:@""] &&
                outTime!=nil && ![outTime isKindOfClass:[NSNull class]] && ![outTime isEqualToString:@""])
            {
                decimalHours=[Util getNumberOfHoursForInTime:inTime outTime:outTime];
            }
            [changedTimepairDict setObject:decimalHours forKey:@"durationDecimalFormat"];

            [changedTimepairDict setObject:comments forKey:@"comments"];
            [changedTimepairDict setObject:[NSNumber numberWithInt:1] forKey:@"isModified"];
            [self.timesheetModel updateTimeEntryTableForTimesheetUri:timesheetUri andClientID:clientId withDataDict:changedTimepairDict andStartDate:startDate andIsBreak:YES  andbreakName:breakName andbreakUri:breakUri  andEntryURIColumnName:columnName];

//            [self.timesheetModel updateTimesheetWithOperationName:TIMESHEET_SAVE_OPERATION andTimesheetURI:timesheetUri];

        }

        [self.timesheetModel updateTotalTimeOnWidgetSummaryTableForTimeSheetUri:timesheetUri];
        
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName: SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:clientId,@"clientId",timeEntryUri,@"timeEntryUri", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName: EDIT_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:clientId,@"clientId",timeEntryUri,@"timeEntryUri", nil]];
    
    
}
/************************************************************************************************************
 @Function Name   : sendRequestToDeleteTimeEntryForGen4WithTimeEntryUri
 @Purpose         : Called to delete timeentry
 @param           : timeEntryUri,delegate,isWork
 @return          : nil
 *************************************************************************************************************/
-(void)sendRequestToDeleteTimeEntryForGen4WithClientUri:(NSString *)timeEntryUri withDelegate:(id)delegate isWork:(BOOL)isWork withTimesheetUri:(NSString *)timesheetUri withRow:(NSInteger)row withSection:(NSInteger)section withEntryDate:(float)entryDate timesheetFormat:(NSString *)timesheetFormat andColumnNameForEntryUri:(NSString *)columnName
{
    
    NSMutableDictionary *changedTimepairDict=[NSMutableDictionary dictionary];
    
    
    [changedTimepairDict setObject:[NSNumber numberWithInt:1] forKey:@"isModified"];
    [changedTimepairDict setObject:[NSNumber numberWithInt:1] forKey:@"isDeleted"];
    
    
    //SUPPORT OFFLINE DELETE FOR SIMPLE IN OUT TIMESHEET
    if ([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
    {
        [self.timesheetModel updateTimeEntryTableForTimesheetUri:timesheetUri andClientID:timeEntryUri withDataDict:changedTimepairDict andStartDate:nil andIsBreak:NO  andbreakName:nil andbreakUri:nil andEntryURIColumnName:columnName];

        //[self.timesheetModel updateTimesheetWithOperationName:TIMESHEET_SAVE_OPERATION andTimesheetURI:timesheetUri];


        [self.timesheetModel updateTotalTimeOnWidgetSummaryTableForTimeSheetUri:timesheetUri];
        
    }

    
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInteger:row] ,@"row",
                                       [NSNumber numberWithInteger:section] ,@"section",
                                       nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: DELETE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil userInfo:paramsDict];
    


}
-(void)sendRequestToGetPunchHistoryForTimesheetWithTimesheetUri:(NSString *)timesheetUri delegate:(id)delegate
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
                                       timesheetUri ,@"timesheetUri",
                                       nil];
    [self executeRequest:paramsDict];
}

-(void)sendRequestToGetTimesheetApprovalSummaryForTimesheetUri:(NSString *)timesheetUri delegate:(id)delegate
{
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timesheetUri ,@"timesheetUri",
                                      [NSNull null],@"asOfDateTime",
                                      nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Gen4TimeheetApprovalSummary"]];;
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"Gen4TimeheetApprovalSummary"]];
    [self setServiceDelegate:self];
    BOOL isFromWidget=NO;
    if (delegate!=nil && [delegate isKindOfClass:[WidgetTSViewController class]])
    {
        isFromWidget=YES;
    }
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       timesheetUri ,@"timesheetUri",
                                       [NSNumber numberWithBool:isFromWidget],@"isFromWidget",
                                       nil];
    [self executeRequest:paramsDict];
}


-(void)sendRequestUpdateTimesheetAttestationStatusForTimesheetURI:(NSString *)timesheetURI forAttestationStatusUri:(NSString *)attestationStatusUri
{
    NSDictionary *timesheetDict=@{@"uri" : timesheetURI};
    NSDictionary *queryDict =  @{@"timesheet" : timesheetDict,@"attestationStatusUri" : attestationStatusUri};
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"UpdateTimesheetAttestationStatus"]];;

    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"UpdateTimesheetAttestationStatus"]];
    [self setServiceDelegate:self];
    [self executeRequest:@{@"timesheetUri" : timesheetURI,@"attestationStatus" : attestationStatusUri}];
    
}

/************************************************************************************************************
 @Function Name   : handleTimesheetsSummaryFetchDataForGen4
 @Purpose         : To save timesheet summary data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleTimesheetsSummaryFetchDataForGen4:(id)response
{
    /* DEPRECATED
    NSString *timesheetUri=[[response objectForKey:@"refDict"] objectForKey:@"params"];
    NSMutableArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    
    if ([responseArray count]>0 && responseArray!=nil)
    {
        [timesheetModel saveTimesheetSummaryDataFromApiToDBForGen4:responseArray withTimesheetUri:timesheetUri];
        
        
    }
    else
    {
        [timesheetModel deleteTimesheetSummaryDataFromApiToDBForGen4withTimesheetUri:timesheetUri];
    }
    [timesheetModel saveGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:responseArray isFromTimeoff:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
   
    */
    
    
}
//Implementation For TIME-495//JUHI
/************************************************************************************************************
 @Function Name   : handleTimesheetsSummaryFetchDataForGen4
 @Purpose         : To save timesheet summary data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleTimesheetsTimeoffSummaryFetchDataForGen4:(id)response
{
    NSString *timesheetUri=[[response objectForKey:@"refDict"] objectForKey:@"params"];
    NSMutableArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    
    if ([responseArray count]>0 && responseArray!=nil)
    {
        [timesheetModel saveTimesheetTimeOffSummaryDataFromApiToDBForGen4:responseArray withTimesheetUri:timesheetUri];
        
        
    }
    [timesheetModel saveGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:responseArray isFromTimeoff:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEET_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
   
}

//Implementation For Mobi-92//JUHI
-(void)handleTimesheetFormat:(id)response{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if (responseDict!=nil && ![responseDict isKindOfClass:[NSNull class]])
    {
        NSMutableDictionary *timesheetFormatDict=[NSMutableDictionary dictionary];
        NSString *timesheetFormat=nil;
        if ([responseDict objectForKey:@"timesheetFormat"]!=nil && ![[responseDict objectForKey:@"timesheetFormat"]isKindOfClass:[NSNull class]])
        {
            timesheetFormat=[responseDict objectForKey:@"timesheetFormat"];
        }
        if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]]) {
            [timesheetFormatDict setObject:timesheetFormat forKey:@"timesheetFormat"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName: TIMESHEETFORMAT_RECEIVED_NOTIFICATION object:nil userInfo:timesheetFormatDict];
    }
}
/*-(void)handleGen4TimesheetEffectivePolicyResponse:(id)response
{
    NSMutableDictionary *dataDict=[[response objectForKey:@"refDict"] objectForKey:@"params"];
    NSString *timesheetUri=[dataDict objectForKey:@"timesheetUri"];
    NSMutableArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    
    if ([responseArray count]>0 && responseArray!=nil)
    {
        [timesheetModel saveTimesheetEffectivePolicyToDBForGen4WithTimesheetUri:timesheetUri andResponseArray:responseArray];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: GEN4_TIMESHEET_EFFECTIVE_POLICY_DATA_NOTIFICATION object:nil];
}*/
-(void)handleTimesheetApprovalCapabilitiesResponse:(id)response
{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    
    NSMutableDictionary *dataDict=[[response objectForKey:@"refDict"] objectForKey:@"params"];
    NSString *timesheetUri=[dataDict objectForKey:@"timesheetUri"];
    SupportDataModel *supportModel=[[SupportDataModel alloc]init];
    NSMutableDictionary *timesheetPermittedApprovalActions=[NSMutableDictionary dictionary];
    if (![timesheetUri isKindOfClass:[NSNull class]] && timesheetUri!=nil )
    {
        [timesheetPermittedApprovalActions setObject:timesheetUri forKey:@"uri"];
        [timesheetPermittedApprovalActions setObject:TIMESHEET_MODULE_NAME forKey:@"module"];
        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetUri];
        int allowBreakForGen4=[[dict objectForKey:@"allowBreakForInOutGen4"] intValue];
        int allowTimeEntryCommentsForGen4=[[dict objectForKey:@"allowTimeEntryCommentsForInOutGen4"] intValue];
        int allowTimeEntryEditForGen4=[[dict objectForKey:@"allowTimeEntryEditForInOutGen4"] intValue];
        int allowReopenForGen4=[[dict objectForKey:@"allowReopenForGen4"] intValue];
        int alowReopenAfterApprovalForGen4=[[dict objectForKey:@"alowReopenAfterApprovalForGen4"] intValue];
        int allowResubmitWithBlankCommentsForGen4=[[dict objectForKey:@"allowResubmitWithBlankCommentsForGen4"] intValue];
        int allowTimeoffForGen4=[[dict objectForKey:@"allowTimeoffForGen4"] intValue];
        int allowBreakForPunchInGen4=[[dict objectForKey:@"allowBreakForPunchInGen4"] intValue];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:allowBreakForGen4] forKey:@"allowBreakForInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:allowTimeEntryCommentsForGen4] forKey:@"allowTimeEntryCommentsForInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:allowTimeEntryEditForGen4] forKey:@"allowTimeEntryEditForInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:allowReopenForGen4] forKey:@"allowReopenForGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:alowReopenAfterApprovalForGen4] forKey:@"alowReopenAfterApprovalForGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:allowResubmitWithBlankCommentsForGen4] forKey:@"allowResubmitWithBlankCommentsForGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:allowTimeoffForGen4] forKey:@"allowTimeoffForGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:allowBreakForPunchInGen4] forKey:@"allowBreakForPunchInGen4"];
        
    }
    
    if (responseDict!=nil && ![responseDict isKindOfClass:[NSNull class]])
    {
        BOOL canApproveReject=[[responseDict objectForKey:@"canApproveReject"] boolValue];
        if (canApproveReject)
        {
            [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:1] forKey:@"canApproveReject"];
        }
        else
        {
            [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:0] forKey:@"canApproveReject"];
        }
        BOOL canForceApproveReject=[[responseDict objectForKey:@"canForceApproveReject"] boolValue];
        if (canForceApproveReject)
        {
            [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:1] forKey:@"canForceApproveReject"];
        }
        else
        {
            [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:0] forKey:@"canForceApproveReject"];
        }
        BOOL canReopen=[[responseDict objectForKey:@"canReopen"] boolValue];
        if (canReopen)
        {
            [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:1] forKey:@"canReopen"];
        }
        else
        {
            [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:0] forKey:@"canReopen"];
        }
        BOOL canSubmit=[[responseDict objectForKey:@"canSubmit"] boolValue];
        if (canSubmit)
        {
            [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:1] forKey:@"canSubmit"];
        }
        else
        {
            [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:0] forKey:@"canSubmit"];
        }
        BOOL canUnsubmit=[[responseDict objectForKey:@"canUnsubmit"] boolValue];
        if (canUnsubmit)
        {
            [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:1] forKey:@"canUnsubmit"];
        }
        else
        {
            [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInteger:0] forKey:@"canUnsubmit"];
        }
        
    }
    SQLiteDB *myDB = [SQLiteDB getInstance];
    [myDB deleteFromTable:@"TimesheetPermittedApprovalActions" inDatabase:@""];
    [supportModel saveTimesheetPermittedApprovalActionsDataToDB:timesheetPermittedApprovalActions];
    [[NSNotificationCenter defaultCenter] postNotificationName: TIMESHEET_APPROVAL_CAPABILITIES_GEN4_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEET_CAPABILITIES_GEN4_RECEIVED_NOTIFICATION object:nil];
}
-(void)handleSaveTimeEntryForGen4:(id)response
{
    [timesheetModel saveTimeEntryDataForGen4TimesheetIntoDB:response];
    [[NSNotificationCenter defaultCenter] postNotificationName: SAVE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:response forKey:@"Response"]];
    [[NSNotificationCenter defaultCenter] postNotificationName: BLANK_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:response forKey:@"Response"]];
    
    
}
-(void)handleBreakTimeEntryForGen4:(id)response
{
    [timesheetModel saveBreakEntryDataForGen4TimesheetIntoDB:response];
    [[NSNotificationCenter defaultCenter] postNotificationName: SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:response forKey:@"Response"]];
    [[NSNotificationCenter defaultCenter] postNotificationName: EDIT_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:response forKey:@"Response"]];
    
}
-(void)handleWorkEntryDeleteResponse:(id)response
{
    NSMutableDictionary *dataDict=[[response objectForKey:@"refDict"] objectForKey:@"params"];
    NSString *timeEntryUri=[[dataDict objectForKey:@"query"] objectForKey:@"timeEntryUri"];
    NSString *timesheetUri=[dataDict objectForKey:@"timesheetUri"];
    NSString *entryDate=[dataDict objectForKey:@"entryDate"];
    
    [timesheetModel deleteInfoFromDBForEntryUri:timeEntryUri withTimesheetUri:timesheetUri andEntryDate:entryDate isWorkEntry:YES];
    NSDictionary *dict=[timesheetModel getSumOfDurationHoursForTimesheetUri:timesheetUri];
    NSString *totalInOutBreakHours=[dict objectForKey:@"breakHours"];
    NSString *totalInOutWorkHours=[dict objectForKey:@"regularHours"];
    NSString *totalInOutTimeOffHours=[dict objectForKey:@"timeoffHours"];
    NSMutableDictionary *updateDict=[NSMutableDictionary dictionary];
    [updateDict setObject:totalInOutBreakHours forKey:@"totalInOutBreakHours"];
    [updateDict setObject:totalInOutWorkHours forKey:@"totalInOutWorkHours"];
    [updateDict setObject:totalInOutTimeOffHours forKey:@"totalInOutTimeOffHours"];
    [timesheetModel updateSummaryDataForTimesheetUri:timesheetUri withDataDict:updateDict];
    [[NSNotificationCenter defaultCenter] postNotificationName: DELETE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil userInfo:[NSMutableDictionary dictionaryWithDictionary:response]];
}
-(void)handleBreakEntryDeleteResponse:(id)response
{
    NSMutableDictionary *dataDict=[[response objectForKey:@"refDict"] objectForKey:@"params"];
    NSString *timeEntryUri=[[dataDict objectForKey:@"query"] objectForKey:@"timeEntryUri"];
    NSString *timesheetUri=[dataDict objectForKey:@"timesheetUri"];
    NSString *entryDate=[dataDict objectForKey:@"entryDate"];
    
    [timesheetModel deleteInfoFromDBForEntryUri:timeEntryUri withTimesheetUri:timesheetUri andEntryDate:entryDate isWorkEntry:NO];
    NSDictionary *dict=[timesheetModel getSumOfDurationHoursForTimesheetUri:timesheetUri];
    NSString *totalInOutBreakHours=[dict objectForKey:@"breakHours"];
    NSString *totalInOutWorkHours=[dict objectForKey:@"regularHours"];
    NSString *totalInOutTimeOffHours=[dict objectForKey:@"timeoffHours"];
    NSMutableDictionary *updateDict=[NSMutableDictionary dictionary];
    [updateDict setObject:totalInOutBreakHours forKey:@"totalInOutBreakHours"];
    [updateDict setObject:totalInOutWorkHours forKey:@"totalInOutWorkHours"];
    [updateDict setObject:totalInOutTimeOffHours forKey:@"totalInOutTimeOffHours"];
    [timesheetModel updateSummaryDataForTimesheetUri:timesheetUri withDataDict:updateDict];
    [[NSNotificationCenter defaultCenter] postNotificationName: DELETE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil userInfo:[NSMutableDictionary dictionaryWithDictionary:response]];
}
-(void)handleGen4TimesheetsSubmitData:(id)response
{
    //Update to waiting for approval
//    NSMutableDictionary *dataDict=[[response objectForKey:@"refDict"] objectForKey:@"params"];
//    NSString *timesheetUri=[dataDict objectForKey:@"timesheetUri"];
//    [timesheetModel updateApprovalStatusForTimesheetIdentity:timesheetUri withStatus:WAITING_FOR_APRROVAL_STATUS];
    
    [self handleTimesheetsSummaryFetchData:response isFromSave:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SUBMITTED_NOTIFICATION object:nil];
    
    
}
-(void)handleGen4TimesheetsUnsubmitData:(id)response
{
    //Update to not submitted
//    NSMutableDictionary *dataDict=[[response objectForKey:@"refDict"] objectForKey:@"params"];
//    NSString *timesheetUri=[dataDict objectForKey:@"timesheetUri"];
//    [timesheetModel updateApprovalStatusForTimesheetIdentity:timesheetUri withStatus:NOT_SUBMITTED_STATUS];
    
     [self handleTimesheetsSummaryFetchData:response isFromSave:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UNSUBMITTED_NOTIFICATION object:nil];
}

-(void)handleGen4TimesheetApprovalsDetailsData:(id)response
{
    NSMutableDictionary *dataDict=[[response objectForKey:@"refDict"] objectForKey:@"params"];
    NSString *timesheetUri=[dataDict objectForKey:@"timesheetUri"];
    BOOL isFromWidget=[[dataDict objectForKey:@"isFromWidget"] boolValue];
    NSMutableArray *dataArray=[[[response objectForKey:@"response"] objectForKey:@"d"] objectForKey:@"history"];
    [timesheetModel saveTimesheetApproverSummaryDataToDBForTimesheetUri:timesheetUri dataArray:dataArray];
    NSString *approvalStatus=nil;
    if (isFromWidget)
    {
        //Update Timesheet Status on List of timesheets
        NSMutableArray *latestApprovalActions=[timesheetModel getAllTimesheetApproverSummaryFromDBInLatestOrderForTimesheetUri:timesheetUri];
        if ([latestApprovalActions count]>0)
        {
            NSMutableDictionary *latestApprovalActionDict=[latestApprovalActions objectAtIndex:0];
            NSString *actionUri=[latestApprovalActionDict objectForKey:@"actionUri"];
            
            
            if ([actionUri isEqualToString:Approved_Action_URI]||[actionUri isEqualToString:SystemApproved_Action_URI])
            {
                approvalStatus=APPROVED_STATUS;
            }
            else if ([actionUri isEqualToString:Submit_Action_URI])
            {
                approvalStatus=WAITING_FOR_APRROVAL_STATUS;
            }
            else if ([actionUri isEqualToString:Reopen_Action_URI])
            {
                approvalStatus=NOT_SUBMITTED_STATUS;
            }
            else if ([actionUri isEqualToString:Reject_Action_URI])
            {
                approvalStatus=REJECTED_STATUS;
            }
            if (approvalStatus!=nil && ![approvalStatus isKindOfClass:[NSNull class]])
            {
                [timesheetModel updateApprovalStatusForTimesheetIdentity:timesheetUri withStatus:approvalStatus];
            }
            

            
        }
        
    }
    NSMutableDictionary *userInfoDict=nil;
    if (approvalStatus!=nil && ![approvalStatus isKindOfClass:[NSNull class]])
    {
        userInfoDict=[NSMutableDictionary dictionaryWithObject:approvalStatus forKey:@"WIDGET_APPROVAL_STATUS_FOR_UPDATE"];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION object:nil userInfo:userInfoDict];
}


//Implemented as per TOFF-115//JUHI
/************************************************************************************************************
 @Function Name   : fetchTimeoffData
 @Purpose         : Called to get the user’s timeoff data ie timeoff date period,approval status etc
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchTimeoffData:(id)_delegate
{

    // TODO: replace with new boolean
//    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    appDelegate.isShowTimeOffSheetPlaceHolder=FALSE;

    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"timeoffDownloadCount"];
   
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    NSMutableArray *sortArray=[NSMutableArray array];
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      pageSize,@"timeOffPagesize",
                                      requestColumnUriArray,@"timeOffColumnUris",
                                      sortArray,@"timeOffSort",
                                      [NSNull null],@"timeOffFilterExpression",nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTimeoffData"]];
        
        
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetTimeoffData"]];
        
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
    if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
    {
         [self executeRequest:[NSDictionary dictionaryWithObject:timesheetUri forKey:@"timesheetUri"]];
    }
   else
   {
       [self executeRequest:[NSDictionary dictionaryWithObject:[NSNull null] forKey:@"timesheetUri"]];
   }
    
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
-(void)sendRequestToBookedTimeOffBalancesDataForTimeoffURI:(NSString *)timesheetURI withEntryArray:(NSMutableArray *)timeoffEntryObjectArray withDelegate:(id)delegate{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    int count=[[[NSUserDefaults standardUserDefaults] objectForKey:@"LastBalanceValue"] intValue]+1;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:count] forKey:@"LastBalanceValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    NSMutableDictionary *owner=[NSMutableDictionary dictionaryWithObjectsAndKeys:strUserURI,@"uri",[NSNull null],@"loginName",nil];
    id comments=@"";
    NSMutableDictionary *entryDict=[NSMutableDictionary dictionary];
    for (int i=0;i<[timeoffEntryObjectArray count]; i++)
    {
        BookedTimeOffEntry *timeOffEntryObject=(BookedTimeOffEntry *)[timeoffEntryObjectArray objectAtIndex:i];
        
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
                         [NSNull null],@"customFieldValues",
                         [NSNull null],@"comments",
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
                                    [NSNumber numberWithInteger:count],@"LastBlanaceValueStored",
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
            NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
            UdfObject *udfObj = [udfArray objectAtIndex:i];
            
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
//Implementation for PUNCH-492//JUHI
/************************************************************************************************************
 @Function Name   : sendRequestToGetAllTimeSegmentsForTimesheet
 @Purpose         : Called to get the timesheet Segments data for timesheetUri
 @param           : timesheetUri,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)sendRequestToGetAllTimeSegmentsForTimesheet:(NSString *)timesheetUri WithStartDate:(NSDate *)startDate withDelegate:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    
     NSDictionary *startDateApiDict=[Util convertDateToApiDateDictionary:startDate];
    NSString *strUserURI=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserUri"];
    NSMutableDictionary *userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   strUserURI,@"uri",
                                   [NSNull null],@"loginName",
                                   [NSNull null],@"parameterCorrelationId",
                                   nil];
    NSMutableDictionary *targetDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     timesheetUri,@"uri",
                                     userDict,@"user",
                                     startDateApiDict,@"date",
                                     nil];
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      targetDict ,@"target",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetAllTimeSegmentsForTimesheet"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetAllTimeSegmentsForTimesheet"]];
    [self setServiceDelegate:self];
    [self executeRequest];
    
}


-(void)sendRequestToGetValidationDataForTimesheet:(NSString *)timesheetUri
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timesheetUri ,@"timesheetUri",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Gen4TimesheetValidation"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"Gen4TimesheetValidation"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}

//MOBI-746
-(void)fetchFirstProgramsAndProjectsForTimesheetUri:(NSString *)timesheetUri withProgramSearchText:(NSString *)programText withProjectSearchText:(NSString *)projectText  andDelegate:(id)delegate
{
    [timesheetModel deleteAllClientsInfoFromDBForModuleName:@"Timesheet"];
    [timesheetModel deleteAllProjectsInfoFromDBForModuleName:@"Timesheet"];
    [timesheetModel deleteAllProgramsInfoFromDBForModuleName:@"Timesheet"];
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *timesheetsCount=[NSNumber numberWithInteger:1];
    [defaults setObject:timesheetsCount forKey:@"NextProgramDownloadPageNo"];
    [defaults setObject:timesheetsCount forKey:@"NextProjectDownloadPageNo"];
    [defaults synchronize];
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    
    NSMutableDictionary *queryDict=nil;
    if (programText==nil && programText==nil)
    {
        queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     timesheetUri ,@"timesheetUri",
                     [NSNull null],@"projectTextSearch",
                     [NSNull null],@"programTextSearch",
                     pageSize,@"maximumResultCount",nil];
    }
    else
    {//Implementation for US8849//JUHI
        NSMutableDictionary *clientSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               programText ,@"queryText",
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
                     timesheetUri ,@"timesheetUri",
                     projectSearchDict,@"projectTextSearch",
                     clientSearchDict,@"programTextSearch",
                     pageSize,@"maximumResultCount",nil];
    }
    
    
    
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetFirstProgramsOrProjects"]];
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetFirstProgramsOrProjects"]];
    [self setServiceDelegate:self];
    if (programText==nil) {
        programText=@"";
    }
    [self executeRequest:programText];
}

-(void)fetchProjectsBasedOnProgramsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withProgramUri:(NSString *)programUri andDelegate:(id)delegate
{
    [timesheetModel deleteAllProjectsInfoFromDBForModuleName:@"Timesheet"];
    [timesheetModel deleteAllProgramsInfoFromDBForModuleName:@"Timesheet"];
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    if (textSearch==nil) {
        textSearch=@"";
    }
    id programID=[NSNull null];
    if (programUri!=nil && ![programUri isKindOfClass:[NSNull class]] && ![programUri isEqualToString:@""]) {
        programID=programUri;
    }
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:1];
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
                                      timesheetUri ,@"timesheetUri",
                                      projectSearchDict,@"textSearch",
                                      programID,@"programUri",nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetProjectsBasedOnPrograms"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetProjectsBasedOnPrograms"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}
-(void)fetchNextProjectsBasedOnProgramsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withProgramUri:(NSString *)programUri andDelegate:(id)delegate
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    if (textSearch==nil) {
        textSearch=@"";
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int nextFetchPageNo=[[defaults objectForKey:@"NextProgramDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextProgramDownloadPageNo"];
    [defaults synchronize];
    id programID=[NSNull null];
    if (programUri!=nil && ![programUri isKindOfClass:[NSNull class]] && ![programUri isEqualToString:@""]) {
        programID=programUri;
    }
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    
   
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
                                      timesheetUri ,@"timesheetUri",
                                      projectSearchDict,@"textSearch",
                                      programID,@"programUri",nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetProjectsBasedOnPrograms"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetProjectsBasedOnPrograms"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}



-(void)fetchFirstProgramsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate
{
    [timesheetModel deleteAllProgramsInfoFromDBForModuleName:@"Timesheet"];
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *pageNum=[NSNumber numberWithInteger:1];
    int nextFetchPageNo=[pageNum intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:nextFetchPageNo];
    [defaults setObject:nextFetchPageNumber forKey:@"NextProgramDownloadPageNo"];
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
                                      timesheetUri ,@"timesheetUri",
                                      textSearchDict,@"textSearch",
                                      pageSize,@"maximumResultCount",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetFirstPrograms"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetFirstPrograms"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}

-(void)fetchNextProgramsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int nextFetchPageNo=[[defaults objectForKey:@"NextProgramDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInteger:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextProgramDownloadPageNo"];
    [defaults synchronize];
    
    NSNumber *pageNum=[NSNumber numberWithInteger:nextFetchPageNo+1];
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
                                      timesheetUri ,@"timesheetUri",
                                      clientSearchDict,@"textSearch",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetNextPrograms"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextPrograms"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}



#pragma mark -
#pragma mark Response Methods

/************************************************************************************************************
 @Function Name   : handleTimesheetsFetchData
 @Purpose         : To save user's timesheet data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleTimesheetsFetchData:(id)response
{
    
    [timesheetModel deleteAllTimesheetsFromDB];

    self.didSuccessfullyFetchTimesheets = YES;

    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timesheetsCount=[NSNumber numberWithInteger:[rowsArray count]];
        [defaults setObject:timesheetsCount forKey:@"timesheetsDownloadCount"];
        [defaults synchronize];
        
        [timesheetModel saveTimesheetPeriodDataFromApiToDB:responseDict];
        
    }
}

/************************************************************************************************************
 @Function Name   : handleNextRecentTimesheetsFetchData
 @Purpose         : To save user's next recent timesheet data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleNextRecentTimesheetsFetchData:(id)response
{
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timesheetsCount=[NSNumber numberWithInteger:[rowsArray count]];
        [defaults setObject:timesheetsCount forKey:@"timesheetsDownloadCount"];
        [defaults synchronize];
        
        [timesheetModel saveTimesheetPeriodDataFromApiToDB:responseDict];
    }

}

/************************************************************************************************************
 @Function Name   : handleTimesheetsSummaryFetchData
 @Purpose         : To save timesheet summary data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

- (void)handleTimesheetsSummaryFetchData:(id)response isFromSave:(BOOL)isFromSave
{
    BOOL isFromTimeSheetServiceFetchTimeSheetSummaryDataForTimesheet=NO;
     NSMutableDictionary *refDict=[response objectForKey:@"refDict"];
    if (refDict!=nil)
    {
        if ([refDict objectForKey:@"params"]!=nil && ![refDict isKindOfClass:[NSNull class]]) {
             isFromTimeSheetServiceFetchTimeSheetSummaryDataForTimesheet=[[refDict objectForKey:@"params"]boolValue];
        }
       
    }
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"] objectForKey:@"d"];
    NSString *timesheetUri=nil;
    if ([responseDict objectForKey:@"approvalDetails"]!=nil && ![[responseDict objectForKey:@"approvalDetails"] isKindOfClass:[NSNull class]])
    {
        timesheetUri =[[[responseDict objectForKey:@"approvalDetails"] objectForKey:@"timesheet"] objectForKey:@"uri"];
    }
   
    [timesheetModel deleteTimesheetSummaryDataFromApiToDBForGen4withTimesheetUri:timesheetUri];
    
    /* THIS IS MOVED OUT OF SCOPE FOR CURRENT REQUIREMENT
    SQLiteDB *myDB = [SQLiteDB getInstance];
    [myDB insertTimesheetSummaryDictionary:responseDict withURI:timesheetUri];
     
     */
    if ([responseDict count]>0 && responseDict!=nil)
    {
        
        [timesheetModel saveTimesheetSummaryDataFromApiToDB:responseDict isFromSave:isFromSave];
        NSDictionary *timesheetdaysoff = responseDict[@"timesheetDaysOff"];
        NSArray *dayOffList = [DayOffHelper getDayOffListFrom:timesheetdaysoff];
        NSDictionary *widgetTimesheetDetailsDict=[responseDict objectForKey:@"widgetTimesheetDetails"];
        if (widgetTimesheetDetailsDict!=nil && ![widgetTimesheetDetailsDict isKindOfClass:[NSNull class]])
        {
            if ([widgetTimesheetDetailsDict objectForKey:@"attestationStatus"]!=nil && ![[widgetTimesheetDetailsDict objectForKey:@"attestationStatus"] isKindOfClass:[NSNull class]])
            {
                BOOL attestationStatus=[[widgetTimesheetDetailsDict objectForKey:@"attestationStatus"]boolValue];
                [self.timesheetModel updateAttestationStatusForTimesheetIdentity:timesheetUri withStatus:attestationStatus];
            }
           
            
            NSMutableArray *widgetTimeEntries=[widgetTimesheetDetailsDict objectForKey:@"timeEntries"];
            NSMutableArray *timeEntryProjectTaskAncestryDetailsArr=[widgetTimesheetDetailsDict objectForKey:@"timeEntryProjectTaskAncestryDetails"];
             NSDictionary *timePunchTimeSegmentDetailsDict=[widgetTimesheetDetailsDict objectForKey:@"timePunchTimeSegmentDetails"];
            
            NSMutableArray *enableWidgetsArr=[timesheetModel getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
            
           
            
            
            for(NSDictionary *widgetUriDict in enableWidgetsArr)
            {
                 NSString *format=@"";
                
                if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
                {
                    format=GEN4_STANDARD_TIMESHEET;
                     [self handleTimesheetsSummaryFetchDataForGen4:widgetTimeEntries withTimesheetUri:timesheetUri timeEntryProjectTaskAncestryDetails:(NSMutableArray *)timeEntryProjectTaskAncestryDetailsArr andDayOffList:dayOffList];
                }
                else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
                {
                    format=GEN4_INOUT_TIMESHEET;
                     [self handleTimesheetsSummaryFetchDataForGen4:widgetTimeEntries withTimesheetUri:timesheetUri timeEntryProjectTaskAncestryDetails:(NSMutableArray *)timeEntryProjectTaskAncestryDetailsArr andDayOffList:dayOffList];
                    
                }
                else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
                {
                    format=GEN4_EXT_INOUT_TIMESHEET;
                    [self handleTimesheetsSummaryFetchDataForGen4:widgetTimeEntries withTimesheetUri:timesheetUri timeEntryProjectTaskAncestryDetails:(NSMutableArray *)timeEntryProjectTaskAncestryDetailsArr andDayOffList:dayOffList];

                }
                else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
                {
                    format=GEN4_PUNCH_WIDGET_TIMESHEET;
                    [self handleTimeSegmentsForTimesheetDataForGen4:timePunchTimeSegmentDetailsDict forTimeSheetUri:timesheetUri];
                    
                }
                else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:DAILY_FIELDS_WIDGET_URI])
                {
                    format=GEN4_DAILY_WIDGET_TIMESHEET;
                    [self handleDailyWidgetSummaryFetchDataForGen4:widgetTimesheetDetailsDict[@"dailyWidgetTimeEntries"] withTimesheetUri:timesheetUri andDayOffList:dayOffList];

                }
            }
            
            
           
            
            
            NSMutableArray *timeOffsArr=[responseDict objectForKey:@"overlappingTimeoff"];
            if ([timeOffsArr count]>0)
            {
                [self handleTimesheetsTimeoffSummaryFetchDataForGen4:timeOffsArr withTimesheetUri:timesheetUri andDayOffList:dayOffList];
            }
            
        }
        
        NSDictionary *standardTimesheetDetailsDict=[responseDict objectForKey:@"standardTimesheetDetails"];
        if (standardTimesheetDetailsDict!=nil && ![standardTimesheetDetailsDict isKindOfClass:[NSNull class]])
        {
            NSMutableArray *timeOffsArr=[responseDict objectForKey:@"overlappingTimeoff"];
            NSMutableArray *newTimeOffsArr = [NSMutableArray array];
            NSDate *startDate = [Util convertApiDictToDateFormat:standardTimesheetDetailsDict[@"dateRange"][@"startDate"]];
            NSDate *endDate = [Util convertApiDictToDateFormat:standardTimesheetDetailsDict[@"dateRange"][@"endDate"]];
            for (NSDictionary *timeOffDict in timeOffsArr)
            {
                NSMutableDictionary *newTimeOffDict = [NSMutableDictionary dictionaryWithDictionary:timeOffDict];
                if (timeOffDict[@"entries"] != nil && ![timeOffDict[@"entries"] isKindOfClass:[NSNull class]])
                {
                    NSArray *timeOffEntries = timeOffDict[@"entries"];
                    NSMutableArray *newTimeOffEntries = [NSMutableArray array];
                    for (NSDictionary *timeOffEntryDict in timeOffEntries)
                    {
                        
                        NSDate *entryDate=[Util convertApiDateDictToDateFormat:[timeOffEntryDict objectForKey:@"entryDate"]];
                        if ([Util date:entryDate isBetweenDate:startDate andDate:endDate])
                        {
                            [newTimeOffEntries addObject:timeOffEntryDict];
                        }
                    }
                    if (newTimeOffEntries.count>0)
                    {
                        newTimeOffDict[@"entries"] = newTimeOffEntries;
                    }
                    [newTimeOffsArr addObject:newTimeOffDict];
                }
            }
            if ([newTimeOffsArr count]>0)
            {
                [timesheetModel saveTimesheetTimeOffSummaryDataFromApiToDBForStandardAndInOutUsers:newTimeOffsArr withTimesheetUri:timesheetUri andFormat:STANDARD_TIMESHEET];
            }
        }
        
        NSDictionary *inOutTimesheetDetailsDict=[responseDict objectForKey:@"inOutTimesheetDetails"];
        if (inOutTimesheetDetailsDict!=nil && ![inOutTimesheetDetailsDict isKindOfClass:[NSNull class]])
        {
            NSMutableArray *timeOffsArr=[responseDict objectForKey:@"overlappingTimeoff"];
            NSMutableArray *newTimeOffsArr = [NSMutableArray array];
            NSDate *startDate = [Util convertApiDictToDateFormat:inOutTimesheetDetailsDict[@"dateRange"][@"startDate"]];
            NSDate *endDate = [Util convertApiDictToDateFormat:inOutTimesheetDetailsDict[@"dateRange"][@"endDate"]];
            for (NSDictionary *timeOffDict in timeOffsArr)
            {
                NSMutableDictionary *newTimeOffDict = [NSMutableDictionary dictionaryWithDictionary:timeOffDict];
                if (timeOffDict[@"entries"] != nil && ![timeOffDict[@"entries"] isKindOfClass:[NSNull class]])
                {
                    NSArray *timeOffEntries = timeOffDict[@"entries"];
                    NSMutableArray *newTimeOffEntries = [NSMutableArray array];
                    for (NSDictionary *timeOffEntryDict in timeOffEntries)
                    {
                        
                        NSDate *entryDate=[Util convertApiDateDictToDateFormat:[timeOffEntryDict objectForKey:@"entryDate"]];
                        if ([Util date:entryDate isBetweenDate:startDate andDate:endDate])
                        {
                            [newTimeOffEntries addObject:timeOffEntryDict];
                        }
                    }
                    if (newTimeOffEntries.count>0)
                    {
                        newTimeOffDict[@"entries"] = newTimeOffEntries;
                    }
                    [newTimeOffsArr addObject:newTimeOffDict];
                }
            }
            if ([newTimeOffsArr count]>0)
            {
                BOOL isExtendedInOutUserPermission=NO;
                NSDictionary *timesheetCapabilities=[responseDict objectForKey:@"capabilities"];
                if ([[timesheetCapabilities objectForKey:@"hasProjectAccess"] boolValue] == YES || [[timesheetCapabilities objectForKey:@"hasActivityAccess"] boolValue] == YES  )
                {
                    isExtendedInOutUserPermission=YES;
                }
                if (isExtendedInOutUserPermission)
                {
                    [timesheetModel saveTimesheetTimeOffSummaryDataFromApiToDBForStandardAndInOutUsers:newTimeOffsArr withTimesheetUri:timesheetUri andFormat:EXTENDED_INOUT_TIMESHEET];
                }
                else
                {
                    [timesheetModel saveTimesheetTimeOffSummaryDataFromApiToDBForStandardAndInOutUsers:timeOffsArr withTimesheetUri:timesheetUri andFormat:INOUT_TIMESHEET];
                }
                
                
            }
        }
    }
    
    if (isFromTimeSheetServiceFetchTimeSheetSummaryDataForTimesheet)
    {
         [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil userInfo:responseDict];
    }
    
   
    
    
    
}
/************************************************************************************************************
 @Function Name   : handleEnabledTimeoffTypes
 @Purpose         : To save enabled timeoff data types into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleEnabledTimeoffTypes:(id)response
{
    NSMutableArray *responseArray=[[response objectForKey:@"response"] objectForKey:@"d"];
    
    
    [timesheetModel saveEnabledTimeoffTypesDataToDB:responseArray];
    
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_TYPES_RECIEVED_NOTIFICATION object:nil userInfo:dataDict];
}

-(void)handleGetPageOfTimeOffTypesAvailableForTimeAllocation:(id)response
{
    NSMutableArray *adHocArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([adHocArray count]!=0)
    {
        [timesheetModel saveEnabledTimeoffTypesDataToDB:adHocArray];
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *projectsCount=[NSNumber numberWithInteger:[adHocArray count]];
    [defaults setObject:projectsCount forKey:@"adHocOptionDataDownloadCount"];
    [defaults synchronize];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_TYPES_RECIEVED_NOTIFICATION object:nil userInfo:dataDict];
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
    
    NSNumber *projectsCount=[NSNumber numberWithInteger:[projectsArray count]];
    
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];
    
    BOOL isProjectAllowed = NO;
    BOOL isProjectRequired = NO;
    if ([userDetailsArray count]!=0)
    {
        NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
        isProjectAllowed =[[userDict objectForKey:@"hasTimesheetProjectAccess"] boolValue];
        isProjectRequired=[[userDict objectForKey:@"timesheetProjectTaskSelectionRequired"] boolValue];
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
    NSNumber *clientsCount=[NSNumber numberWithInteger:[clientsArray count]];
    
    [defaults setObject:clientsCount forKey:@"clientsDownloadCount"];
    [defaults setObject:projectsCount forKey:@"projectssDownloadCount"];
    [defaults setObject:totalClientCount forKey:@"totalClientCount"];
    [defaults setObject:totalProjectCount forKey:@"totalProjectCount"];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
}
//MOBI-746
-(void)handleProgramsAndProjectsDownload:(id)response
{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSMutableArray *clientsArray=[[responseDict objectForKey:@"programsDetails"] objectForKey:@"programs"];
    NSMutableArray *projectsArray=[[responseDict objectForKey:@"projectsDetails"] objectForKey:@"projects"];
    NSNumber *totalClientCount=[[responseDict objectForKey:@"programsDetails"] objectForKey:@"totalProgramCount"];
    NSNumber *totalProjectCount=[[responseDict objectForKey:@"projectsDetails"] objectForKey:@"totalProjectCount"];
    if ([clientsArray count]!=0)
    {
        [timesheetModel saveProgramDetailsDataToDB:clientsArray];
    }
    
    NSNumber *projectsCount=[NSNumber numberWithInteger:[projectsArray count]];
    
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];
    
    BOOL isProjectAllowed = NO;
    BOOL isProjectRequired = NO;
    if ([userDetailsArray count]!=0)
    {
        NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
        isProjectAllowed =[[userDict objectForKey:@"hasTimesheetProjectAccess"] boolValue];
        isProjectRequired=[[userDict objectForKey:@"timesheetProjectTaskSelectionRequired"] boolValue];
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
    NSNumber *clientsCount=[NSNumber numberWithInteger:[clientsArray count]];
    
    [defaults setObject:clientsCount forKey:@"programsDownloadCount"];
    [defaults setObject:projectsCount forKey:@"projectssDownloadCount"];
    [defaults setObject:totalClientCount forKey:@"totalProgramCount"];
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
    NSMutableArray *clientsArray=[[[response objectForKey:@"response"]objectForKey:@"d"] objectForKey:@"clients"];
    if ([clientsArray count]!=0)
    {
        [timesheetModel saveClientDetailsDataToDB:clientsArray];
    }
    NSNumber *totalClientCount=[[[response objectForKey:@"response"]objectForKey:@"d"] objectForKey:@"totalClientCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *clientsCount=[NSNumber numberWithInteger:[clientsArray count]];
    [defaults setObject:clientsCount forKey:@"clientsDownloadCount"];
    [defaults setObject:totalClientCount forKey:@"totalClientCount"];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
}
//MOBI-746
-(void)handleFirstProgramsDownload:(id)response
{
    NSMutableArray *clientsArray=[[[response objectForKey:@"response"]objectForKey:@"d"] objectForKey:@"programs"];
    if ([clientsArray count]!=0)
    {
        [timesheetModel saveProgramDetailsDataToDB:clientsArray];
    }
    NSNumber *totalClientCount=[[[response objectForKey:@"response"]objectForKey:@"d"] objectForKey:@"totalProgramCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *clientsCount=[NSNumber numberWithInteger:[clientsArray count]];
    [defaults setObject:clientsCount forKey:@"programsDownloadCount"];
    [defaults setObject:totalClientCount forKey:@"totalProgramCount"];
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
    NSMutableArray *projectsArray=[[[response objectForKey:@"response"]objectForKey:@"d"] objectForKey:@"projects"];
    NSNumber *totalProjectCount=[[[response objectForKey:@"response"]objectForKey:@"d"] objectForKey:@"totalProjectCount"];
    
    NSNumber *projectsCount=[NSNumber numberWithInteger:[projectsArray count]];
    
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];
    
    BOOL isProjectAllowed = NO;
    BOOL isProjectRequired = NO;
    if ([userDetailsArray count]!=0)
    {
        NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
        isProjectAllowed =[[userDict objectForKey:@"hasTimesheetProjectAccess"] boolValue];
        isProjectRequired=[[userDict objectForKey:@"timesheetProjectTaskSelectionRequired"] boolValue];
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
    [defaults setObject:totalProjectCount forKey:@"totalProjectCount"];
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
    NSNumber *clientsCount=[NSNumber numberWithInteger:[clientsArray count]];
    [defaults setObject:clientsCount forKey:@"clientsDownloadCount"];
    [defaults synchronize];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"isErrorOccured",
                              [NSNumber numberWithBool:YES],@"isClientMoreAction",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NEXT_RECENT_CLIENTS_OR_PROJECTS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}

//MOBI-746
-(void)handleNextProgramsDownload:(id)response
{
    NSMutableArray *clientsArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([clientsArray count]!=0)
    {
        [timesheetModel saveProgramDetailsDataToDB:clientsArray];
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *clientsCount=[NSNumber numberWithInteger:[clientsArray count]];
    [defaults setObject:clientsCount forKey:@"programsDownloadCount"];
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
    NSNumber *projectsCount=[NSNumber numberWithInteger:[projectsArray count]];
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
    NSNumber *projectsCount=[NSNumber numberWithInteger:[projectsArray count]];
    [defaults setObject:projectsCount forKey:@"projectssDownloadCount"];
    [defaults synchronize];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}
//MOBI-746
-(void)handleProjectsBasedOnProgramsResponse:(id)response
{
    NSMutableArray *projectsArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([projectsArray count]!=0)
    {
        [timesheetModel saveProjectDetailsDataToDB:projectsArray];
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *projectsCount=[NSNumber numberWithInteger:[projectsArray count]];
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
    NSMutableArray *tasksArray=[[[response objectForKey:@"response"]objectForKey:@"d"] objectForKey:@"tasks"];
    [self.spinnerDelegate hideTransparentLoadingOverlay];
    if ([tasksArray count]!=0)
    {
        [timesheetModel saveTaskDetailsDataToDB:tasksArray];
        [self.spinnerDelegate hideTransparentLoadingOverlay];
    }
    else
    {
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *tasksCount=[NSNumber numberWithInteger:[tasksArray count]];
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
    NSNumber *tasksCount=[NSNumber numberWithInteger:[tasksArray count]];
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
    NSNumber *projectsCount=[NSNumber numberWithInteger:[projectsArray count]];
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
    NSDictionary *billingDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    BOOL isNonBillableTimeAllocationAllowed=[[billingDict objectForKey:@"isNonBillableTimeAllocationAllowed"]boolValue];
    
    NSMutableArray *billingArray=[billingDict objectForKey:@"billingRates"];
    NSNumber *billingRatesCount=[NSNumber numberWithInteger:[billingArray count]];
    
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
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
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
    NSNumber *timesheetsCount=[NSNumber numberWithInteger:[billingArray count]];
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
    NSDictionary *activityDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSMutableArray *activityArray=[activityDict objectForKey:@"activities"];
    
    NSNumber *activitiesCount=[NSNumber numberWithInteger:[activityArray count]];
    
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];
    
    BOOL isActivitySelectionRequired = NO;
    
    if ([userDetailsArray count]!=0)
    {
        NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
        isActivitySelectionRequired =[[userDict objectForKey:@"timesheetActivitySelectionRequired"] boolValue];
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
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
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
    NSNumber *timesheetsCount=[NSNumber numberWithInteger:[activtyArray count]];
    [defaults setObject:timesheetsCount forKey:@"activityDataDownloadCount"];
    [defaults synchronize];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:ACTIVITY_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}
/************************************************************************************************************
 @Function Name   : handleTimesheetsSaveData
 @Purpose         : To save timesheets save response data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handleTimesheetsSaveData:(id)response
{
    [self handleTimesheetsSummaryFetchData:response isFromSave:YES];
    NSString *isAutoSaveStr=[[response objectForKey:@"refDict"]objectForKey:@"params"];
    if ([isAutoSaveStr isEqualToString:@"NO"])
    {
        [LogUtil logLoggingInfo:[NSString stringWithFormat:@"-----EXPLICIT SAVE-----"] forLogLevel:LoggerCocoaLumberjack];

        CLS_LOG(@"-----TIMESHEET EXPLICIT SAVE-----");
        [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    }
    else
    {
        [LogUtil logLoggingInfo:[NSString stringWithFormat:@"-----AUTO SAVE-----"] forLogLevel:LoggerCocoaLumberjack];

        CLS_LOG(@"-----TIMESHEET AUTO SAVE-----");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AutoSaveRequestServed" object:nil];
    }
    
}
/************************************************************************************************************
 @Function Name   : handleTimesheetsSubmitData
 @Purpose         : To handle timesheets submit/save response data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleTimesheetsSubmitData:(id)response
{
//    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
//    if ([responseDict count]>0 && responseDict!=nil)
//    {
//        [timesheetModel saveTimesheetSummaryDataFromApiToDB:responseDict];
//        
//    }
    
    
    [self handleTimesheetsSummaryFetchData:response isFromSave:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SUBMITTED_NOTIFICATION object:nil];
}

-(void)handleTimesheetsUnsubmitData:(id)response
{
    
    [self handleTimesheetsSummaryFetchData:response isFromSave:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UNSUBMITTED_NOTIFICATION object:nil];
}
//Implementation of TimeSheetLastModified
/************************************************************************************************************
 @Function Name   : handleTimesheetsUpdateFetchData
 @Purpose         : To save user's timesheet data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleTimesheetsUpdateFetchData:(id)response
{
    
    self.didSuccessfullyFetchTimesheets = YES;

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        if ([responseDict objectForKey:@"updateMode"]!=nil && ![[responseDict objectForKey:@"updateMode"] isKindOfClass:[NSNull class]])
        {
            if ([[responseDict objectForKey:@"updateMode"]isEqualToString:FULL_UPDATEMODE])
            {
                [timesheetModel deleteAllTimesheetsFromDB];
                NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                
                NSNumber *pageNum=[NSNumber numberWithInteger:1];
                [defaults setObject:pageNum forKey:@"NextTimeSheetPageNo"];
                if ([[responseDict objectForKey:@"listData"] objectForKey:@"rows"]!=nil && ![[[responseDict objectForKey:@"listData"] objectForKey:@"rows"] isKindOfClass:[NSNull class]]) {
                    NSMutableArray *rowsArray=[[responseDict objectForKey:@"listData"] objectForKey:@"rows"];
                    NSNumber *timesheetsCount=[NSNumber numberWithInteger:[rowsArray count]];
                    [defaults setObject:timesheetsCount forKey:@"timesheetsDownloadCount"];
                }
                [defaults synchronize];
            }
            else if ([[responseDict objectForKey:@"updateMode"]isEqualToString:DELTA_UPDATEMODE])
            {
                if ([responseDict objectForKey:@"deletedObjects"]!=nil && ![[responseDict objectForKey:@"deletedObjects"] isKindOfClass:[NSNull class]])
                {
                    NSMutableArray *deletedObjArray=[responseDict objectForKey:@"deletedObjects"];
                    for (int i=0; i<[deletedObjArray count]; i++)
                    {
                        if ([[deletedObjArray objectAtIndex:i] objectForKey:@"uri"]!=nil && ![[[deletedObjArray objectAtIndex:i] objectForKey:@"uri"] isKindOfClass:[NSNull class]]) {
                            NSString *timesheetURI=[[deletedObjArray objectAtIndex:i] objectForKey:@"uri"];
                            [timesheetModel deleteTimesheetsFromDBForForTimesheetIdentity:timesheetURI];
                        }
                        
                        
                    }
                }
                UIViewController *allViewController = appDelegate.rootTabBarController.selectedViewController;
                
                if ([allViewController isKindOfClass:[TimesheetNavigationController class]])
                {
                    TimesheetNavigationController *timeSheetNavController=(TimesheetNavigationController *)allViewController;
                    NSArray *timeSheetControllers = timeSheetNavController.viewControllers;
                    for (UIViewController *viewController in timeSheetControllers)
                    {
                        if ([viewController isKindOfClass:[ListOfTimeSheetsViewController class]])
                        {
                            ListOfTimeSheetsViewController *timeSheetListCtrl=(ListOfTimeSheetsViewController *)viewController;
                            timeSheetListCtrl.isDeltaUpdate=TRUE;
                            break;
                        }
                    }
                }
            }
        }
        
        if ([responseDict objectForKey:@"listData"]!=nil && ![[responseDict objectForKey:@"listData"] isKindOfClass:[NSNull class]])
        {
            [timesheetModel saveTimesheetPeriodDataFromApiToDB:[responseDict objectForKey:@"listData"]];
        }
    }

}
//Implentation for US8956//JUHI
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
    NSNumber *breakCount=[NSNumber numberWithInteger:[breakArray count]];
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
    NSNumber *breakCount=[NSNumber numberWithInteger:[breakArray count]];
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

//Implentation for US8956//JUHI
/************************************************************************************************************
 @Function Name   : handleReasonForChange
 @Purpose         : To save Reason for change details into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handleReasonForChange:(id)response
{
    if (response!=nil && ![response isKindOfClass:[NSNull class]]) {
        NSMutableDictionary *balanceResponseDict=[NSMutableDictionary dictionary];
        [balanceResponseDict setObject:response forKey:@"timesheetModificationsRequiringChangeReason"];
         [[NSNotificationCenter defaultCenter] postNotificationName: SUBMITTED_NOTIFICATION object:nil userInfo:balanceResponseDict];
    }
    
}


//Implemented as per TOFF-115//JUHI
/************************************************************************************************************
 @Function Name   : handleTimeoffFetchData
 @Purpose         : To save user's timeoff data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleTimeoffFetchData:(id)response
{
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSString *calendarUri=nil;
        if ([responseDict objectForKey:@"holidayCalendar"]!=nil&&![[responseDict objectForKey:@"holidayCalendar"]isKindOfClass:[NSNull class]]) {
            calendarUri=[[responseDict objectForKey:@"holidayCalendar"] objectForKey:@"uri"];
        }
        NSMutableArray *rowsArray=[[responseDict objectForKey:@"timeOff"] objectForKey:@"rows"];
        NSMutableArray *weeklyDaysOffArray=[responseDict objectForKey:@"weeklyDaysOff"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timesheetsCount=[NSNumber numberWithInteger:[rowsArray count]];
        [defaults setObject:timesheetsCount forKey:@"timeoffDownloadCount"];
        if (calendarUri!=nil) {
            [defaults setObject:calendarUri forKey:@"holidayCalendarURI"];
        }
        if ([responseDict objectForKey:@"hoursPerWorkday"]!=nil && ![[responseDict objectForKey:@"hoursPerWorkday"] isKindOfClass:[NSNull class]] )
        {
            NSDictionary *shiftDurationDict=[responseDict objectForKey:@"hoursPerWorkday"];
            [[NSUserDefaults standardUserDefaults] setObject:shiftDurationDict forKey:@"hoursPerWorkday"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
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
        if ([responseDict objectForKey:@"timeOffTypeDetails"]!=nil && ![[responseDict objectForKey:@"timeOffTypeDetails"] isKindOfClass:[NSNull class]] )
        {
            [timesheetModel saveTimeoffTypeDetailDataToDB:[responseDict objectForKey:@"timeOffTypeDetails"]];
            
        }
        [defaults synchronize];
        
    }
// TODO: replace with new boolean
//    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    appDelegate.isShowTimeOffSheetPlaceHolder=TRUE;
    [[NSNotificationCenter defaultCenter] postNotificationName:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
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
    NSString *timesheetUri=[[[response objectForKey:@"refDict"]objectForKey:@"params"]objectForKey:@"timesheetUri"];
    NSMutableDictionary *timeoffDict=[NSMutableDictionary dictionary];
    NSMutableDictionary *timeoffDetailDict=[NSMutableDictionary dictionary];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableDictionary *timeOffDetailsDict=[responseDict objectForKey:@"timeOffDetails"];
        NSString *timeoffUri=[timeOffDetailsDict objectForKey:@"uri"];
        
        
        NSNumber *shiftDurationDecimal=nil;
        NSString *shiftDurationHourStr=nil;
        NSDictionary *timeoffCapabilities=[responseDict objectForKey:@"capabilities"];
        //Implemented as per US7660
        int hasTimeOffEditAcess     =0;
        int hasTimeOffDeletetAcess  =0;
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
        
        
        
        NSDictionary *shiftDurationDict=[[NSUserDefaults standardUserDefaults]objectForKey:@"hoursPerWorkday"];
        if (shiftDurationDict!=nil && ![shiftDurationDict isKindOfClass:[NSNull class]])
        {
            shiftDurationDecimal=[Util convertApiTimeDictToDecimal:shiftDurationDict];
            shiftDurationHourStr=[Util convertApiTimeDictToString:shiftDurationDict];
        }
        NSString*status=nil;
        
        status=[[responseDict objectForKey:@"approvalStatus"]objectForKey:@"displayText"];
        
        
       
        
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
        //Implemented as per US7660
        [timeoffDict setObject:[NSNumber numberWithInteger:hasTimeOffDeletetAcess] forKey:@"hasTimeOffDeletetAcess"];
        [timeoffDict setObject:[NSNumber numberWithInteger:hasTimeOffEditAcess] forKey:@"hasTimeOffEditAcess"];
        
        NSString *comments=[timeOffDetailsDict objectForKey:@"comments"];
        [timeoffDict setObject:comments forKey:@"comments"];
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
            [timeoffDict setObject:totalHours      forKey:@3];
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
        [timeoffDetailDict setObject:timeoffDict forKey:@"TimeoffEntry"];

        if ([timeOffDetailsDict objectForKey:@"customFields"]!=nil && ![[timeOffDetailsDict objectForKey:@"customFields"] isKindOfClass:[NSNull class]]) {
            NSArray *sheetCustomFieldsArray=[timeOffDetailsDict objectForKey:@"customFields"];
            NSMutableArray *customFieldArray=[NSMutableArray array];
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
                
                NSString *value=[udfDict objectForKey:@"text"];
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
                
                [customFieldArray addObject:udfDataDict];
                
                
            }
            [timeoffDetailDict setObject:customFieldArray forKey:@"customFields"];
        }
        
    }
    if ([responseDict count]>0 && responseDict!=nil)
    {
        [timeoffModel saveTimeOffEntryDataFromApiToDB:responseDict andTimesheetUri:timesheetUri];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil userInfo:timeoffDetailDict];
    
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
        [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_SAVEDATA_RECEIVED_NOTIFICATION object:nil];
        
    }
    
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
        NSString *balanceTotal=nil;
        NSString *requestedTotal=nil;
        //Fix for DE15147
        if ([responseDict objectForKey:@"balanceSummaryAfterTimeOff"]!=nil && ![[responseDict objectForKey:@"balanceSummaryAfterTimeOff"]isKindOfClass:[NSNull class]])
        {
            if ([[responseDict objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]!=nil &&![[[responseDict objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]isKindOfClass:[NSNull class]])
            {
                balanceTotal=[[[responseDict objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]objectForKey:@"decimalWorkdays"];
            }
        }
        if ([responseDict objectForKey:@"totalDurationOfTimeOff"]!=nil && ![[responseDict objectForKey:@"totalDurationOfTimeOff"]isKindOfClass:[NSNull class]])
        {
            if ([responseDict objectForKey:@"totalDurationOfTimeOff"]!=nil &&![[responseDict objectForKey:@"totalDurationOfTimeOff"]isKindOfClass:[NSNull class]]) {
                requestedTotal=[[responseDict objectForKey:@"totalDurationOfTimeOff"] objectForKey:@"decimalWorkdays"];
            }
        }
        
        if (balanceTotal!=nil &&![balanceTotal isKindOfClass:[NSNull class]]) {
            [balanceResponseDict setObject:balanceTotal forKey:@"balanceRemainingDays"];
        }
        if (requestedTotal!=nil &&![requestedTotal isKindOfClass:[NSNull class]]) {
            [balanceResponseDict setObject:requestedTotal forKey:@"requestedDays"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName: TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil userInfo:balanceResponseDict];
        
        
        
    }
    
}//Implemented Resubmit As Per US7631
-(void)handleTimeoffResubmitData:(id)response
{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_SAVEDATA_RECEIVED_NOTIFICATION object:nil];
        
    }
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
    
}

-(void)handleTimeSegmentsForTimesheetData:(id)response
{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSMutableDictionary *paramsDict=[[response objectForKey:@"refDict"] objectForKey:@"params"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        PunchHistoryModel *punchModel=[[PunchHistoryModel alloc]init];
        [punchModel deleteAllTeamPunchesInfoFromDBIsFromWidgetTimesheet:YES approvalsModule:nil];
        NSString *timesheetUri=nil;
        if ([paramsDict objectForKey:@"timesheetUri"]!=nil && ![[paramsDict objectForKey:@"timesheetUri"] isKindOfClass:[NSNull class]])
        {
            timesheetUri=[paramsDict objectForKey:@"timesheetUri"];
        }
        [punchModel savepunchHistoryDataFromApiToDB:[responseDict objectForKey:@"timeSegments"] isFromWidget:YES approvalsModule:nil andTimeSheetUri:timesheetUri];
        if ([paramsDict objectForKey:@"timesheetUri"]!=nil && ![[paramsDict objectForKey:@"timesheetUri"] isKindOfClass:[NSNull class]])
        {
            NSString *timesheetUri=[paramsDict objectForKey:@"timesheetUri"];
            [punchModel updateTimesheetHoursInTimesheetTableWithTimesheetUri:timesheetUri approvalsModule:nil];
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GEN4_PUNCH_TIMESHEET_NOTIFICATION object:nil];
    
}

-(void)handleTimeSegmentsForTimesheetDataForGen4:(NSDictionary *)timePunchTimeSegmentDetailsDict forTimeSheetUri:(NSString *)timesheetUri
{
   
    if (timePunchTimeSegmentDetailsDict!=nil && ![timePunchTimeSegmentDetailsDict isKindOfClass:[NSNull class]])
    {
        PunchHistoryModel *punchModel=[[PunchHistoryModel alloc]init];
        [punchModel deleteAllTeamPunchesInfoFromDBIsFromWidgetTimesheet:YES approvalsModule:nil andtimesheetUri:timesheetUri];
        [punchModel savepunchHistoryDataFromApiToDB:[timePunchTimeSegmentDetailsDict objectForKey:@"timeSegments"] isFromWidget:YES approvalsModule:nil andTimeSheetUri:timesheetUri];
        BOOL isOnlyPunchWidget=YES;
        NSMutableArray *enableWidgetsArr=[timesheetModel getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
        for(NSDictionary *widgetUriDict in enableWidgetsArr)
        {
            if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
            {
                isOnlyPunchWidget=FALSE;
            }
            else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
            {
                isOnlyPunchWidget=FALSE;
                
            }
        }
        if (isOnlyPunchWidget)
        {
            [timesheetModel saveGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:[NSMutableArray array] isFromTimeoff:NO];
        }
        
        
        //[punchModel updateTimesheetHoursInTimesheetTableWithTimesheetUri:timesheetUri approvalsModule:nil];
        
    }
    
    
    
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
            if (widgetTimesheetDelegate!=nil && ![widgetTimesheetDelegate isKindOfClass:[NSNull class]])
            {
                int receivedServiceID=[serviceID intValue];
                if (receivedServiceID==GetGen4TimesheetValidationData_Service_ID_137)
                {
                    WidgetTSViewController *ctrl=(WidgetTSViewController *)widgetTimesheetDelegate;
                    [ctrl serviceFailureWithServiceID:[serviceID intValue]];
                    return;
                }
                
            }
            
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
            else
            {
                if ([[errorDict objectForKey:@"details"] objectForKey:@"timesheetModificationsRequiringChangeReason"]!=nil && ![[[errorDict objectForKey:@"details"] objectForKey:@"timesheetModificationsRequiringChangeReason"] isKindOfClass:[NSNull class]])
                {
                     totalRequestsServed++;
                    NSArray *timesheetModificationsRequiringChangeReason=[[errorDict objectForKey:@"details"] objectForKey:@"timesheetModificationsRequiringChangeReason"];
                    [self handleReasonForChange:timesheetModificationsRequiringChangeReason];
                    isErrorThrown=TRUE;
                    [self.spinnerDelegate hideTransparentLoadingOverlay];
                    return;
                }
                
            }
            if (!isErrorThrown)
            {
                errorMsg=[[errorDict objectForKey:@"details"] objectForKey:@"displayText"];
                
            }
            
            //DON'T THROW ERROR POPUPS FOR AUTO SAVE
            id _serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
            if([_serviceID intValue]== SaveTimesheetData_Service_ID_26)
            {
                NSString *isAutoSaveStr=[[response objectForKey:@"refDict"]objectForKey:@"params"];
                if ([isAutoSaveStr isEqualToString:@"NO"])
                {
                    
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
                    UIViewController *allViewController = appDelegate.rootTabBarController.selectedViewController;
                    
                    if ([allViewController isKindOfClass:[TimesheetNavigationController class]])
                    {
                        TimesheetNavigationController *timeSheetNavController=(TimesheetNavigationController *)allViewController;
                        NSArray *timesheetControllers = timeSheetNavController.viewControllers;
                        
                        for (UIViewController *viewController in timesheetControllers)
                        {
                            if ([viewController isKindOfClass:[TimesheetMainPageController class]])
                            {
                                TimesheetMainPageController *timesheetMainPageController=(TimesheetMainPageController *)viewController;
                                
                                if (timesheetMainPageController.isDeleteTimeEntry_AdHoc_RequestInQueue)
                                {
                                    [[NSNotificationCenter defaultCenter] removeObserver: timesheetMainPageController name: START_AUTOSAVE object: nil];
                                    [[NSNotificationCenter defaultCenter] addObserver: timesheetMainPageController
                                                                             selector: @selector(backAndSaveAction:)
                                                                                 name: START_AUTOSAVE
                                                                               object: nil];
                                    
                                    [appDelegate performSelector:@selector(startSyncTimer) withObject:nil];
                                    timesheetMainPageController.isDeleteTimeEntry_AdHoc_RequestInQueue=FALSE;
                                    timesheetMainPageController.isAutoSaveInQueue=FALSE;
                                    timesheetMainPageController.isExplicitSaveRequested=FALSE;
                                }
                                
                                
                                break;
                            }
                        }
                    }
                    
                }
                else
                {
                    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                    UIViewController *allViewController = appDelegate.rootTabBarController.selectedViewController;
                    
                    if ([allViewController isKindOfClass:[TimesheetNavigationController class]])
                    {
                        TimesheetNavigationController *timeSheetNavController=(TimesheetNavigationController *)allViewController;
                        NSArray *timesheetControllers = timeSheetNavController.viewControllers;
                        
                        for (UIViewController *viewController in timesheetControllers)
                        {
                            if ([viewController isKindOfClass:[TimesheetMainPageController class]])
                            {
                                TimesheetMainPageController *timesheetMainPageController=(TimesheetMainPageController *)viewController;
                                if (timesheetMainPageController.isDeleteTimeEntry_AdHoc_RequestInQueue)
                                {
                                    timesheetMainPageController.isAutoSaveInQueue=FALSE;
                                    timesheetMainPageController.isExplicitSaveRequested=FALSE;
                                }
                                
                            }
                        }
                    }
                    //DONT DO ANYTHING
                }
            }
            //
            else
            {
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
            }
            
            
            

            [self.spinnerDelegate hideTransparentLoadingOverlay];
            NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                                 forKey:@"isErrorOccured"];


            [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_TYPES_RECIEVED_NOTIFICATION object:nil userInfo:dataDict];
            [[NSNotificationCenter defaultCenter] postNotificationName:NEXT_RECENT_CLIENTS_OR_PROJECTS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
            [[NSNotificationCenter defaultCenter] postNotificationName:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AutoSaveRequestServed" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:GEN4_TIMESHEET_VALIDATION_DATA_NOTIFICATION object:nil userInfo:nil];
        }
        else
        {
            totalRequestsServed++;
            id _serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
            
            //Implementation as per US9331//JUHI
            if ([_serviceID intValue]== GetFirstTimesheets_ID_93)
            {
                [self handleTimesheetsFetchData:response];
                
            }
            else if ([_serviceID intValue]== NextRecentTimesheetDetails_Service_ID_3)
            {
                [self handleNextRecentTimesheetsFetchData:response];
                return;
            }
            else if ([_serviceID intValue]== TimesheetSummaryDetails_Service_ID_4)
            {
                [self handleTimesheetsSummaryFetchData:response isFromSave:NO];
                return;
            }
             else if ([_serviceID intValue]== TimesheetSummaryDetailsForGen4_Service_ID_114)
            {
                [self handleTimesheetsSummaryFetchDataForGen4:response];
                return;
            }
            else if ([_serviceID intValue]== EnabledTimeoffTypes_Service_ID_5)
            {
                [self handleEnabledTimeoffTypes:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
            else if ([_serviceID intValue]== FirstClientsAndProjectsSummaryDetails_Service_ID_13)
            {
                [self handleClientsAndProjectsDownload:response];
                return;
            }//MOBI-746
            else if ([_serviceID intValue]==FirstProgramsAndProjectsSummaryDetails_Service_ID_153)
            {
                [self handleProgramsAndProjectsDownload:response];
                return;
            }
            else if ([_serviceID intValue]== NextClientsSummaryDetails_Service_ID_14)
            {
                [self handleNextClientsDownload:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
            else if ([_serviceID intValue]== NextProgramsSummaryDetails_Service_ID_156)
            {
                [self handleNextProgramsDownload:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
            else if ([_serviceID intValue]== NextProjectsSummaryDetails_Service_ID_15)
            {
                [self handleNextProjectsDownload:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
            else if ([_serviceID intValue]== FirstTasksSummaryDetails_Service_ID_16)
            {
                [self handleTasksBasedOnProjectsResponse:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
            else if ([_serviceID intValue]== GetProjectsBasedOnclient_Service_ID_18)
            {
                [self handleProjectsBasedOnClientsResponse:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
                
            }
            else if ([_serviceID intValue]== GetProjectsBasedOnPrograms_Service_ID_154)
            {
                [self handleProjectsBasedOnProgramsResponse:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
                
            }
            else if ([_serviceID intValue]== NextTasksBasedOnProject_Service_ID_17)
            {
                [self handleNextTasksBasedOnProjectsResponse:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
                
            }
            else if ([_serviceID intValue]== GetNextProjectsBasedOnClients_Service_ID_19)
            {
                [self handleNextProjectsBasedOnClientDownload:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
                
            }
            else if ([_serviceID intValue]== FirstClientsSummaryDetails_Service_ID_20)
            {
                [self handleFirstClientsDownload:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
                
            }
            //MOBI-746
            else if ([_serviceID intValue]== FirstProgramsSummaryDetails_Service_ID_155)
            {
                [self handleFirstProgramsDownload:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
                
            }
            else if ([_serviceID intValue]== FirstProjectsSummaryDetails_Service_ID_21)
            {
                [self handleFirstProjectsDownload:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
                
            }
            
            else if ([_serviceID intValue]== GetBillingData_Service_ID_22)
            {
                [self handleBillingRateBasedOnProjectDownload:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
                
            }
            else if ([_serviceID intValue]== GetNextBillingData_Service_ID_23)
            {
                [self handleNextBillingRateBasedOnProjectDownload:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
                
            }
            else if ([_serviceID intValue]== GetActivityData_Service_ID_24)
            {
                [self handleActivityBasedOnTimesheetDownload:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
                
            }
            else if ([_serviceID intValue]== GetNextActivityData_Service_ID_25)
            {
                [self handleNextActivityBasedOnTimesheetDownload:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
                
            }
            else if([_serviceID intValue]== SaveTimesheetData_Service_ID_26)
            {
                
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                UIViewController *allViewController = appDelegate.rootTabBarController.selectedViewController;
                BOOL isHideOverlay=TRUE;
                if ([allViewController isKindOfClass:[TimesheetNavigationController class]])
                {
                    TimesheetNavigationController *timeSheetNavController=(TimesheetNavigationController *)allViewController;
                    NSArray *timesheetControllers = timeSheetNavController.viewControllers;
                    
                    for (UIViewController *viewController in timesheetControllers)
                    {
                        if ([viewController isKindOfClass:[TimesheetMainPageController class]])
                        {
                            TimesheetMainPageController *timesheetMainPageController=(TimesheetMainPageController *)viewController;
                            if (timesheetMainPageController.isDeleteTimeEntry_AdHoc_RequestInQueue)
                            {
                                isHideOverlay=FALSE;
                            }
                            break;
                        }
                    }
                }
                
                
                [self handleTimesheetsSaveData:response];
                
                if (isHideOverlay)
                {
                    [self.spinnerDelegate hideTransparentLoadingOverlay];
                }
                return;
            }
            else if([_serviceID intValue]== SubmitTimesheetData_Service_ID_39)
            {
                [self handleTimesheetsSubmitData:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];                return;
            }
            else if([_serviceID intValue]== UnsubmitTimesheetData_Service_ID_40)
            {
                [self handleTimesheetsUnsubmitData:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];                return;
            }
            else if ([_serviceID intValue]== GetPageOfTimeOffTypesAvailableForTimeAllocationFilteredByTextSearch_75)
            {
                [self handleGetPageOfTimeOffTypesAvailableForTimeAllocation:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];                return;
            } //Implementation of TimeSheetLastModified
            else if ([_serviceID intValue]== GetTimesheetUpdateData_Service_ID_87)
            {
                [self handleTimesheetsUpdateFetchData:response];
                
                TimesheetModel *timeSheetModel=[[TimesheetModel alloc]init];
                BOOL isTimeSheetExist=[timeSheetModel getTimeSheetForStartDate:[NSDate date] andEndDate:[NSDate date]];
                
                if (!isTimeSheetExist)
                {
                    if ([NetworkMonitor isNetworkAvailableForListener:self] == YES)
                    {
                        
                        [[RepliconServiceManager timesheetService] fetchTimeSheetDataOnlyWhenUpdateFetchDataFails: nil];
                    }
                    else
                    {
                        [Util showOfflineAlert];
                    }
                }
                
            }
            
            //Implentation for US8956//JUHI
            else if ([_serviceID intValue]== GetBreakData_Service_ID_90)
            {
                [self handleBreakDownload:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
                
            }
            else if ([_serviceID intValue]== GetNextBreakData_Service_ID_91)
            {
                [self handleNextBreakDownload:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
                
            }//Implemented as per TOFF-115//JUHI
            else if ([_serviceID intValue]== GetTimeoffEntryData_Service_ID_64)
            {
                //[self.spinnerDelegate hideTransparentLoadingOverlay];
                [self handleTimeoffEntryFetchData:response];
                return;
                
            }
            else if ([_serviceID intValue]== GetTimeoffData_Service_ID_54)
            {
                [self handleTimeoffFetchData:response];
            }
            else if ([_serviceID intValue]== SaveTimeoffData_Service_ID_65)
            {
                
                [self handleTimeoffSaveData:response];
                return;
                
            }
            else if ([_serviceID intValue]== DeleteTimeoffData_Service_ID_66)
            {
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

            else if ([_serviceID intValue]== TimesheetsDataOnlyWhenUpdateFetchDataFails_139)
            {
                [self handleTimesheetsDataOnlyWhenUpdateFetchDataFails:response];
                
               
            }
else if ([_serviceID intValue]== GetTimesheetFormat_Service_ID_115)
            {
                [self handleTimesheetFormat:response];
                //MOBI-571 Ullas M L
                //AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                //[appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                return;
                
            }
            else if ([_serviceID intValue]== GetTimesheetCapabilitiesForGen4_Service_ID_134)
            {
                //[self handleGen4TimesheetEffectivePolicyResponse:response];
                return;
            
            }
            else if ([_serviceID intValue]== GetTimesheetApprovalCapabilities_Service_ID_124)
            {
                //[self handleTimesheetApprovalCapabilitiesResponse:response];
                return;
                
            }
            else if ([_serviceID intValue]== SaveWorkTimeEntryForGen4_Service_ID_117)
            {
                [self handleSaveTimeEntryForGen4:response];
               return;
            }
            else if ([_serviceID intValue]== SaveBreakTimeEntryForGen4_Service_ID_118)
            {
                [self handleBreakTimeEntryForGen4:response];
                return;
            }
            else if ([_serviceID intValue]== DeleteWorkTimeEntryForGen4_Service_ID_119)
            {
                [self handleWorkEntryDeleteResponse:response];
                return;
            }
            else if ([_serviceID intValue]== DeleteBreakTimeEntryForGen4_Service_ID_120)
            {
                [self handleBreakEntryDeleteResponse:response];
               return;
            }
            else if([_serviceID intValue]== Gen4SubmitTimesheetData_Service_ID_122)
            {
                [self handleGen4TimesheetsSubmitData:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
            else if([_serviceID intValue]== Gen4UnsubmitTimesheetData_Service_ID_123)
            {
                [self handleGen4TimesheetsUnsubmitData:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
            else if([_serviceID intValue]== GetTimesheetApprovalSummary_Service_ID_125)
            {
                [self handleGen4TimesheetApprovalsDetailsData:response];
                return;
            }
            else if([_serviceID intValue]== Gen4TimesheetTimeoffSummary_Service_ID_128)
            {
                [self handleTimesheetsTimeoffSummaryFetchDataForGen4:response];
                return;
            }
            else if([_serviceID intValue]== GetGen4TimesheetValidationData_Service_ID_137)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:GEN4_TIMESHEET_VALIDATION_DATA_NOTIFICATION object:nil userInfo:response];
                return;
            }

            //Implementation for PUNCH-492//JUHI
            else if([_serviceID intValue]== GetAllPunchTimeSegmentsForTimesheet_Service_ID_138)
            {
                
                [self handleTimeSegmentsForTimesheetData:response];
                return;
            }
            
            else if ([_serviceID intValue]== GetDefaultBillingData_Service_ID_159)
            {
                [self handleDefaultBillingRateResponse:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
                
            }

            else if ([_serviceID intValue]== UpdateTimesheetAttestationStatus_Service_ID_164)
            {
                NSDictionary *paramsDict=[[response objectForKey:@"refDict"]objectForKey:@"params"];
                BOOL status=NO;
                if ([paramsDict[@"attestationStatus"]isEqualToString:ATTESTATION_STATUS_UNATTESTED])
                {
                    status=NO;
                }
                else if ([paramsDict[@"attestationStatus"]isEqualToString:ATTESTATION_STATUS_ATTESTED])
                {
                    status=YES;
                }

                [self.timesheetModel updateAttestationStatusForTimesheetIdentity:paramsDict[@"timesheetUri"] withStatus:status];
                return;

            }
        }
        
        
        if (totalRequestsServed == totalRequestsSent )
        {
            [self.spinnerDelegate hideTransparentLoadingOverlay];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"allTimesheetRequestsServed" object:nil];


            
        }
        
    }
}
#pragma mark -
#pragma mark ServiceURL Error Handling
- (void) serverDidFailWithError:(NSError *) error applicationState:(ApplicateState)applicationState
{
    
    totalRequestsServed++;
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"allTimesheetRequestsServed" object:nil];


    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_TYPES_RECIEVED_NOTIFICATION object:nil userInfo:dataDict];

    [[NSNotificationCenter defaultCenter] postNotificationName:NEXT_RECENT_CLIENTS_OR_PROJECTS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
    [[NSNotificationCenter defaultCenter] postNotificationName:GEN4_TIMESHEET_VALIDATION_DATA_NOTIFICATION object:nil userInfo:nil];
    
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
    
   
    
    return;
}



-(void)handleTimesheetsDataOnlyWhenUpdateFetchDataFails:(id)response
{
    
    
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        
        
        [timesheetModel saveTimesheetPeriodDataFromApiToDB:responseDict];
        
    }
    
   
    
}

-(void)handleDefaultBillingRateResponse:(id)response
{
    NSDictionary *billingDict=[[response objectForKey:@"response"]objectForKey:@"d"];
   
    
    NSMutableArray *billingArray=[billingDict objectForKey:@"billingRates"];
    
    NSMutableDictionary *userInfoDict=nil;
    
    if ([billingArray count]>0)
    {
        NSDictionary *dict=[billingArray objectAtIndex:0];
        NSString *billingName=nil;
        NSString *billingUri=nil;
        if (dict!=nil && ![dict isKindOfClass:[NSNull class]])
        {
            billingName=[dict objectForKey:@"displayText"];
            billingUri=[dict objectForKey:@"uri"];
        }
        userInfoDict=[NSMutableDictionary dictionary];
        [userInfoDict setObject:billingName forKey:@"billingName"];
        [userInfoDict setObject:billingUri forKey:@"billingUri"];
    }
    
    
   
    [[NSNotificationCenter defaultCenter] postNotificationName:DEFAULT_BILLING_RECEIVED_NOTIFICATION object:nil userInfo:userInfoDict];
}


-(void)handleTimesheetsSummaryFetchDataForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri timeEntryProjectTaskAncestryDetails:(NSMutableArray *)timeEntryProjectTaskAncestryDetailsArr andDayOffList:(NSArray *)dayOffList
{
    
    [timesheetModel deleteTimesheetSummaryDataFromApiToDBForGen4withTimesheetUri:timesheetUri andWidgetEntries:widgetTimeEntriesArr];
    [timesheetModel saveTimesheetSummaryDataFromApiToDBForGen4:widgetTimeEntriesArr withTimesheetUri:timesheetUri andTimeEntryProjectTaskAncestryDetails:timeEntryProjectTaskAncestryDetailsArr];
    [timesheetModel saveGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:widgetTimeEntriesArr dayOffList:dayOffList isFromTimeoff:NO];
}

-(void)handleTimesheetsTimeoffSummaryFetchDataForGen4:(NSMutableArray *)timeOffsArr withTimesheetUri:(NSString *)timesheetUri andDayOffList:(NSArray *)dayOffList
{
    
    [timesheetModel saveTimesheetTimeOffSummaryDataFromApiToDBForGen4:timeOffsArr withTimesheetUri:timesheetUri];
    [timesheetModel saveGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:timeOffsArr dayOffList:dayOffList isFromTimeoff:YES];
}


-(void)handleDailyWidgetSummaryFetchDataForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri andDayOffList:(NSArray *)dayOffList
{
    [timesheetModel deleteTimesheetSummaryDataFromApiToDBForGen4withTimesheetUri:timesheetUri andWidgetEntries:widgetTimeEntriesArr];
    [timesheetModel saveDailyWidgetTimesheetSummaryDataFromApiToDBForGen4:widgetTimeEntriesArr withTimesheetUri:timesheetUri];
    [timesheetModel saveGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:widgetTimeEntriesArr dayOffList:dayOffList isFromTimeoff:NO];
}


@end
