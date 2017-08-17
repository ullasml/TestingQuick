//
//  ExpenseService.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 22/03/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "ExpenseService.h"
#import "AppDelegate.h"
#import "ExpenseEntryObject.h"
#import "LoginModel.h"
#import "ExpensesNavigationController.h"
#import "ListOfExpenseSheetsViewController.h"
#import "RepliconServiceManager.h"

@interface ExpenseService ()
@property(nonatomic, strong) id <SpinnerDelegate> spinnerDelegate;
@end

@implementation ExpenseService
@synthesize expenseModel;
- (id) init
{
    [super doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark -

- (id)initWithSpinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate {
    self = [super init];
    if (self != nil)
    {
        if(expenseModel == nil) {
            expenseModel = [[ExpenseModel alloc] init];
            self.spinnerDelegate = spinnerDelegate;
        }
    }
    return self;
}

#pragma mark Request Methods

/************************************************************************************************************
 @Function Name   : fetchExpenseSheetData
 @Purpose         : Called to get the user’s expense data ie description,incurred amount, date,approval status etc
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchExpenseSheetData:(id)_delegate
{
    
    self.didSuccessfullyFetchExpenses =NO;
   //Implementation of ExpenseSheetLastModified
    NSUserDefaults *userdefaults=[NSUserDefaults standardUserDefaults];
    
   
    [userdefaults removeObjectForKey:@"ExpenseSheetLastModifiedTime"];
    //[userdefaults setObject:lastUpdateDateStr forKey:@"ExpenseSheetLastModifiedTime"];
    [userdefaults synchronize];

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
                                             @"urn:replicon:expense-sheet-list-filter:expense-sheet-owner",@"filterDefinitionUri",
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
    
    NSDictionary *filterExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                           leftExpressionDict,@"leftExpression",
                                           @"urn:replicon:filter-operator:equal",@"operatorUri",
                                           rightExpressionDict,@"rightExpression",
                                           [NSNull null],@"value",
                                           [NSNull null],@"filterDefinitionUri",
                                           nil];
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getExpenseSheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        if ([columnName isEqualToString:@"Description"]||
            [columnName isEqualToString:@"Date"]||
            [columnName isEqualToString:@"Reimbursement Amount"]||[columnName isEqualToString:@"Incurred Amount"]||
            [columnName isEqualToString:@"Approval Status"]||[columnName isEqualToString:@"Expense"]||[columnName isEqualToString:@"Tracking Number"])
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        ;
        NSNumber *pageNum=[NSNumber numberWithInt:1];
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"expenseSheetDownloadCount"];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:pageNum forKey:@"NextExpenseSheetPageNo"];
        [defaults synchronize];
        
        NSMutableArray *sortArray=[NSMutableArray array];
//        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
//                                          @"urn:replicon:expense-sheet-list-column:date",@"columnUri",
//                                          @"false",@"isAscending",
//                                          nil];
//        [sortArray addObject:sortExpressionDict1];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:tracking-number",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        [sortArray addObject:sortExpressionDict2];
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [pageNum stringValue] ,@"page",
                                          [pageSize stringValue],@"pagesize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",filterExpressionDict,@"filterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetExpenseSheetData"]];
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetExpenseSheetData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
    
}
/************************************************************************************************************
 @Function Name   : fetchNextExpenseSheetData
 @Purpose         : Called to get the user’s next set of ie description,incurred amount, date,approval status etc
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchNextExpenseSheetData:(id)_delegate
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
                                             @"urn:replicon:expense-sheet-list-filter:expense-sheet-owner",@"filterDefinitionUri",
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
    
    NSDictionary *filterExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                        leftExpressionDict,@"leftExpression",
                                        @"urn:replicon:filter-operator:equal",@"operatorUri",
                                        rightExpressionDict,@"rightExpression",
                                        [NSNull null],@"value",
                                        [NSNull null],@"filterDefinitionUri",
                                        nil];
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getExpenseSheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        if ([columnName isEqualToString:@"Description"]||
            [columnName isEqualToString:@"Date"]||
            [columnName isEqualToString:@"Reimbursement Amount"]||[columnName isEqualToString:@"Incurred Amount"]||
            [columnName isEqualToString:@"Approval Status"]||[columnName isEqualToString:@"Expense"]||[columnName isEqualToString:@"Tracking Number"])
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        ;
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        int nextFetchPageNo=[[defaults objectForKey:@"NextExpenseSheetPageNo"] intValue];
        NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
        [defaults setObject:nextFetchPageNumber forKey:@"NextExpenseSheetPageNo"];
        [defaults synchronize];
        
        NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"expenseSheetDownloadCount"];
        
        NSMutableArray *sortArray=[NSMutableArray array];
       
//        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
//                                           @"urn:replicon:expense-sheet-list-column:date",@"columnUri",
//                                           @"false",@"isAscending",
//                                           nil];
//        [sortArray addObject:sortExpressionDict1];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:tracking-number",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        [sortArray addObject:sortExpressionDict2];
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [pageNum stringValue] ,@"page",
                                          [pageSize stringValue],@"pagesize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",filterExpressionDict,@"filterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetExpenseSheetData"]];
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextExpenseSheetData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
    
}
/************************************************************************************************************
 @Function Name   : fetchExpenseEntryDataForExpenseSheet
 @Purpose         : Called to get the expense entry data for expenseSheetUri
 @param           : expenseSheetUri,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchExpenseEntryDataForExpenseSheet:(NSString *)expenseSheetUri withDelegate:(id)_delegate
{
   
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      expenseSheetUri ,@"expenseSheetUri",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetExpenseEntryData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetExpenseEntryData"]];
    [self setServiceDelegate:self];
    [self executeRequest];
    
}
/************************************************************************************************************
 @Function Name   : fetchExpenseCurrencyDatawithDelegate
 @Purpose         : Called to get the currency and payment method data for user
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchExpenseCurrencyAndPaymentMethodDatawithDelegate:(id)_delegate
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      strUserURI ,@"userUri",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetCurrencyAndPaymentMethodData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetCurrencyAndPaymentMethodData"]];
    [self setServiceDelegate:self];
    [self executeRequest];
    
}
/************************************************************************************************************
 @Function Name   : fetchFirstClientsAndProjectsForExpenseSheetUri
 @Purpose         : Called to get the clients and projects for ExpenseSheet with uri
 @param           : ExpenseSheet,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchFirstClientsAndProjectsForExpenseSheetUri:(NSString *)expenseSheetUri withClientSearchText:(NSString *)clientText withProjectSearchText:(NSString *)projectText andDelegate:(id)delegate
{
    [expenseModel deleteAllClientsInfoFromDBForModuleName:ExpenseModuleName];
    [expenseModel deleteAllProjectsInfoFromDBForModuleName:ExpenseModuleName];
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *expenseSheetCount=[NSNumber numberWithInt:1];
    [defaults setObject:expenseSheetCount forKey:@"NextClientDownloadPageNo"];
    [defaults setObject:expenseSheetCount forKey:@"NextProjectDownloadPageNo"];
    [defaults synchronize];
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    
    NSMutableDictionary *queryDict=nil;
    if (clientText==nil && projectText==nil)
    {
        queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     expenseSheetUri ,@"expenseSheetUri",
                     [NSNull null],@"projectTextSearch",
                     [NSNull null],@"clientTextSearch",
                     pageSize,@"maximumResultCount",nil];
    }
    else
    {
        //Implementation for US8849//JUHI
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
                     expenseSheetUri ,@"expenseSheetUri",
                     projectSearchDict,@"projectTextSearch",
                     clientSearchDict,@"clientTextSearch",
                     pageSize,@"maximumResultCount",nil];
    }
    
    
    
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetFirstProjectsAndClientsForExpenseSheet"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetFirstProjectsAndClientsForExpenseSheet"]];
    [self setServiceDelegate:self];
    if (clientText==nil) {
        clientText=@"";
    }
    [self executeRequest:clientText];
    
    
    
}
/************************************************************************************************************
 @Function Name   : fetchFirstClientsForExpenseSheetUri
 @Purpose         : Called to get the clients for expenseSheet with uri for search text
 @param           : expenseSheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchFirstClientsForExpenseSheetUri:(NSString *)expenseSheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate
{
    [expenseModel deleteAllClientsInfoFromDBForModuleName:ExpenseModuleName];
    
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
                                      expenseSheetUri ,@"expenseSheetUri",
                                      textSearchDict,@"textSearch",
                                      pageSize,@"maximumResultCount",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetFirstClientsForExpenseSheet"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetFirstClientsForExpenseSheet"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}

/************************************************************************************************************
 @Function Name   : fetchNextClientsForExpenseSheetUri
 @Purpose         : Called to get the clients for expenseSheet with uri for search text
 @param           : expenseSheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchNextClientsForExpenseSheetUri:(NSString *)expenseSheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate
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
                                      expenseSheetUri ,@"expenseSheetUri",
                                      clientSearchDict,@"textSearch",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetNextClientForExpense"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextClientForExpense"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}
/************************************************************************************************************
 @Function Name   : fetchNextProjectsForExpenseSheetUri
 @Purpose         : Called to get the projects for expenseSheet with uri for search text
 @param           : expenseSheetUri,textSearch,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchNextProjectsForExpenseSheetUri:(NSString *)expenseSheetUri withSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate
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
                                      expenseSheetUri ,@"expenseSheetUri",
                                      projectSearchDict,@"textSearch",
                                      clientUri,@"clientUri",nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetNextProjectForExpense"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextProjectForExpense"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}
/************************************************************************************************************
 @Function Name   : fetchProjectsBasedOnclientsForExpenseSheetUri
 @Purpose         : Called to get the projects based on clients with client uri
 @param           : expenseSheetUri,textSearch,clientUri,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchProjectsBasedOnclientsForExpenseSheetUri:(NSString *)expenseSheetUri withSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate
{
    [expenseModel deleteAllProjectsInfoFromDBForModuleName:ExpenseModuleName];
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    if (textSearch==nil) {
        textSearch=@"";
    }
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:1];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:nextFetchPageNumber forKey:@"NextProjectBasedOnClientsDownloadPageNo"];
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
                                      expenseSheetUri ,@"expenseSheetUri",
                                      projectSearchDict,@"textSearch",
                                      clientUri,@"clientUri",nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetNextProjectForExpense"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetProjectsBasedOnClientForExpenseSheet"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}
/************************************************************************************************************
 @Function Name   : fetchNextProjectsBasedOnclientsForExpenseSheetUri
 @Purpose         : Called to get the projects based on clients with client uri
 @param           : expenseSheetUri,textSearch,clientUri,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchNextProjectsBasedOnclientsForExpenseSheetUri:(NSString *)expenseSheetUri withSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int nextFetchPageNo=[[defaults objectForKey:@"NextProjectBasedOnClientsDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextProjectBasedOnClientsDownloadPageNo"];
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
                                      expenseSheetUri ,@"expenseSheetUri",
                                      projectSearchDict,@"textSearch",
                                      clientUri,@"clientUri",nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetNextProjectForExpense"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextProjectsBasedOnClientsForExpense"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}
/************************************************************************************************************
 @Function Name   : fetchExpenseCodesBasedOnProjectsForExpenseSheetUri
 @Purpose         : Called to get the tasks based on projects with project uri
 @param           : expenseSheetUri,textSearch,projectUri,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchExpenseCodesBasedOnProjectsForExpenseSheetUri:(NSString *)expenseSheetUri withSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri andDelegate:(id)delegate
{
    [expenseModel deleteAllExpenseCodesFromDB];
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    if (textSearch==nil) {
        textSearch=@"";
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSNumber *pageCount=[NSNumber numberWithInt:1];
    [defaults setObject:pageCount forKey:@"NextExpenseCodesDownloadPageNo"];
    [defaults synchronize];
    
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"expenseCodesDownloadCount"];
    NSMutableDictionary *taskSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         textSearch ,@"queryText",
                                         @"true",@"searchInDisplayText",
                                         @"false",@"searchInName",
                                         @"false",@"searchInDescription",
                                         @"false",@"searchInCode",nil];
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
    [queryDict setObject:pageSize  forKey:@"maximumResultCount"];
    [queryDict setObject:expenseSheetUri  forKey:@"expenseSheetUri"];
    [queryDict setObject:taskSearchDict  forKey:@"textSearch"];
    if (projectUri!=nil && ![projectUri isKindOfClass:[NSNull class]]&& ![projectUri isEqualToString:NULL_STRING])
    {
        [queryDict setObject:projectUri  forKey:@"projectUri"];
    }
    else
    {
        [queryDict setObject:[NSNull null]  forKey:@"projectUri"];
    }

    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetExpenseCodesForExpenseSheet"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetExpenseCodesForExpenseSheet"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}

/************************************************************************************************************
 @Function Name   : fetchExpenseCodesBasedOnProjectsForExpenseSheetUri
 @Purpose         : Called to get the tasks based on projects with project uri
 @param           : expenseSheetUri,textSearch,projectUri,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchNextExpenseCodesBasedOnProjectsForExpenseSheetUri:(NSString *)expenseSheetUri withSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri andDelegate:(id)delegate
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    if (textSearch==nil) {
        textSearch=@"";
    }
    
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"expenseCodesDownloadCount"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int nextFetchPageNo=[[defaults objectForKey:@"NextExpenseCodesDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
    [defaults setObject:nextFetchPageNumber forKey:@"NextExpenseCodesDownloadPageNo"];
    [defaults synchronize];


    NSMutableDictionary * taskSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          textSearch ,@"queryText",
                                          @"true",@"searchInDisplayText",
                                          @"true",@"searchInName",
                                          @"false",@"searchInDescription",
                                          @"false",@"searchInCode",nil];
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
    [queryDict setObject:nextFetchPageNumber  forKey:@"page"];
    [queryDict setObject:pageSize  forKey:@"pageSize"];
    [queryDict setObject:expenseSheetUri  forKey:@"expenseSheetUri"];
    [queryDict setObject:taskSearchDict  forKey:@"textSearch"];

    if (projectUri!=nil && ![projectUri isKindOfClass:[NSNull class]]&& ![projectUri isEqualToString:NULL_STRING])
    {
        [queryDict setObject:projectUri  forKey:@"projectUri"];
    }
    else
    {
        [queryDict setObject:[NSNull null]  forKey:@"projectUri"];
    }
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetNextExpenseCodesForExpenseSheet"]];

    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextExpenseCodesForExpenseSheet"]];
    [self setServiceDelegate:self];
    [self executeRequest:textSearch];
}

-(void)sendRequestToUnsubmitExpensesDataForExpenseURI:(NSString *)expensesURI withComments:(NSString *)comments withDelegate:(id)delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      expensesURI,@"expenseUri",
                                      [Util getRandomGUID],@"unitOfWorkId",
                                      nil];
    
    
    
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"UnsubmitExpensesData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"UnsubmitExpensesData"]];
    [self setServiceDelegate:self];
    [self executeRequest];
    
    
}

-(void)sendRequestToGetRecieptForSelectedExpense:(id)expenseIdentity delegate:(id)_delegate{
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      expenseIdentity,@"expenseReceiptUri",
                                      nil];
    
    
    
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"ExpenseReceiptImage"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"ExpenseReceiptImage"]];
    [self setServiceDelegate:_delegate];
	[self executeRequestWithTimeOut:60];
	
}

-(void)sendRequestToDeleteExpensesSheetForExpenseURI:(NSString *)expensesURI
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      expensesURI,@"expenseSheetUri",
                                      nil];
    
    
    
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"DeleteExpenseSheet"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"DeleteExpenseSheet"]];
    [self setServiceDelegate:self];
    [self executeRequest];
    
    
}
/************************************************************************************************************
 @Function Name   : fetchExpenseCodesDetailsForExpenseCodeURI
 @Purpose         : Called to get the expense codes for expense sheet uri
 @param           : expenseSheetUri,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchExpenseCodesDetailsForExpenseCodeURI:(NSString *)expenseCodeURI andSheetUri:(NSString *)sheetUri andProjectUri:(NSString *)projectUri
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    id tempExpenseCodeUri=nil;
    if (expenseCodeURI!=nil && ![expenseCodeURI isKindOfClass:[NSNull class]]&& ![expenseCodeURI isEqualToString:@""]&& ![expenseCodeURI isEqualToString:NULL_STRING])
    {
        tempExpenseCodeUri=expenseCodeURI;
    }
    else
    {
        tempExpenseCodeUri=[NSNull null];
    }
    id tempProjectUri=nil;
    if (projectUri!=nil && ![projectUri isKindOfClass:[NSNull class]]&& ![projectUri isEqualToString:@""] && ![projectUri isEqualToString:NULL_STRING] )
    {
        tempProjectUri=projectUri;
    }
    else
    {
        tempProjectUri=[NSNull null];
    }
    id tempExpenseSheetUri=nil;
    if (sheetUri!=nil && ![sheetUri isKindOfClass:[NSNull class]]&& ![sheetUri isEqualToString:@""]&& ![sheetUri isEqualToString:NULL_STRING])
    {
        tempExpenseSheetUri=sheetUri;
    }
    else
    {
        tempExpenseSheetUri=[NSNull null];
    }

    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      tempExpenseCodeUri,@"expenseCodeUri",
                                      tempProjectUri,@"projectUri",
                                      tempExpenseSheetUri,@"expenseSheetUri",
                                      nil];
    
    
    
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetExpenseCodeDetails"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetExpenseCodeDetails"]];
    [self setServiceDelegate:self];
    [self executeRequest];

}

-(void)sendRequestToCreateNewExpensesDataForExpenseURIForExpenseSheetDict:(NSDictionary *)newExpenseSheetDetailsDict withDelegate:(id)delegate
{

    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    
   
    NSMutableDictionary *ownerDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      strUserURI,@"uri",
                                      [NSNull null],@"loginName",
                                      nil];
    NSString *reimbursementCurrencyUri=[newExpenseSheetDetailsDict objectForKey:@"reimbursementCurrencyUri"];
    NSMutableDictionary *reimbursementCurrencyDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    reimbursementCurrencyUri,@"uri",
                                                    [NSNull null],@"name",
                                                    [NSNull null],@"symbol",
                                                    nil];

    NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNull null],@"target",
                                     [NSMutableArray array],@"entries",
                                     [newExpenseSheetDetailsDict objectForKey:@"description"],@"description",
                                     reimbursementCurrencyDict,@"reimbursementCurrency",
                                     ownerDict,@"owner",
                                     [newExpenseSheetDetailsDict objectForKey:@"date"],@"date",
                                     nil];
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      dataDict,@"data",
                                      [Util getRandomGUID],@"unitOfWorkId",
                                      nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"CreateNewExpenseSheet"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"CreateNewExpenseSheet"]];
    [self setServiceDelegate:delegate];
    [self executeRequest];

}

-(void)sendRequestToSaveExpenseSheetForExpenseSheetDict:(NSMutableDictionary *)expenseSheetDetailsDict withExpenseEntriesArray:(NSMutableArray *)expenseEntriesArray withDelegate:(id)delegate isProjectAllowed:(BOOL)isProjectAllowed isProjectRequired:(BOOL)isProjectRequired isDisclaimerAccepted:(BOOL)isDisclaimerAccepted isExpenseSubmit:(BOOL)isExpenseSubmit withComments:(NSString *)comments
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    NSString *expenseSheetUri=[expenseSheetDetailsDict objectForKey:@"expenseSheetUri"];
    NSString *description=[expenseSheetDetailsDict objectForKey:@"description"];
    NSString *reimbursementCurrencyUri=[expenseSheetDetailsDict objectForKey:@"reimbursementCurrencyUri"];
    NSMutableDictionary *dateDict=[expenseSheetDetailsDict objectForKey:@"date"];
    
    
    NSMutableArray *entriesArray=[NSMutableArray array];
    for (int i=0; i<[expenseEntriesArray count]; i++)
    {
        ExpenseEntryObject *entryObj=(ExpenseEntryObject *)[expenseEntriesArray objectAtIndex:i];
        NSString *expenseEntryUri=entryObj.expenseEntryExpenseEntryUri;
        NSDate *expenseEntryDate=entryObj.expenseEntryIncurredDate;
        NSDictionary *expenseDateDict=[Util convertDateToApiDateDictionary:expenseEntryDate];
        NSString *description=entryObj.expenseEntryDescription;
        NSString *expenseBillingOptionUri=entryObj.expenseEntryBillingUri;
        NSString *expenseReimbursementOptionUri=entryObj.expenseEntryReimbursementUri;
        NSString *projectUri=entryObj.expenseEntryProjectUri;
        NSString *projectName=entryObj.expenseEntryProjectName;
        NSString *taskUri=entryObj.expenseEntryTaskUri;
        NSString *taskName=entryObj.expenseEntryTaskName;
        NSString *expenseCodeUri=entryObj.expenseEntryExpenseCodeUri;
        NSString *paymentMethodUri=entryObj.expenseEntryPaymentMethodUri;
        NSMutableArray *taxArray=entryObj.expenseEntryIncurredTaxesArray;
        NSString *expenseReceiptUri=entryObj.expenseEntryExpenseReceiptUri;
        NSString *expenseReceiptName=entryObj.expenseEntryExpenseReceiptName;
        NSString *expenseImageData=entryObj.receiptImageData;
        NSMutableArray *udfArray=entryObj.expenseEntryUdfArray;
        
        NSMutableArray *queryTaxArray=[NSMutableArray array];
        for (int k=0; k<[taxArray count]; k++)
        {
            NSString *amount=[[taxArray objectAtIndex:k]objectForKey:@"taxAmount"];
            
            if ([[Util detectDecimalMark] isEqualToString:@","] && amount!=nil && ![amount isKindOfClass:[NSNull class]])
            {
                amount=[amount stringByReplacingOccurrencesOfString:@"," withString:@"."];
            }
            
            NSString *currencyUri=[[taxArray objectAtIndex:k]objectForKey:@"taxCurrencyUri"];
            NSString *taxCodeUri=[[taxArray objectAtIndex:k]objectForKey:@"taxCodeUri"];
            
            if (![amount isEqualToString:NULL_STRING] &&
                ![currencyUri isEqualToString:NULL_STRING]&&
                ![taxCodeUri isEqualToString:NULL_STRING])
            {
                NSMutableDictionary *currencyDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                       currencyUri,@"uri",
                                                       [NSNull null],@"name",
                                                       [NSNull null],@"symbol",
                                                       nil];
                NSMutableDictionary *amountDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 amount,@"amount",
                                                 currencyDict,@"currency",
                                                 nil];
                
                NSMutableDictionary *taxCodeDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              taxCodeUri,@"uri",
                                              [NSNull null],@"name",
                                              nil];

                NSMutableDictionary *taxDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              taxCodeDict,@"taxCode",
                                              amountDict,@"amount",
                                              nil];
                
                
                [queryTaxArray addObject:taxDict];
            }
            

        }
        
        NSMutableDictionary *variableRateEntryDict=[NSMutableDictionary dictionary];
        NSMutableDictionary *flatAmountEntryDict=[NSMutableDictionary dictionary];
        NSString *entryEntryRateAmount=entryObj.expenseEntryRateAmount;
        if ([[Util detectDecimalMark] isEqualToString:@","] && entryEntryRateAmount!=nil && ![entryEntryRateAmount isKindOfClass:[NSNull class]])
        {
            entryEntryRateAmount=[entryEntryRateAmount stringByReplacingOccurrencesOfString:@"," withString:@"."];
        }
        NSString *entryEntryRateQuantity=entryObj.expenseEntryQuantity;
        if ([[Util detectDecimalMark] isEqualToString:@","] && entryEntryRateQuantity!=nil && ![entryEntryRateQuantity isKindOfClass:[NSNull class]])
        {
            entryEntryRateQuantity=[entryEntryRateQuantity stringByReplacingOccurrencesOfString:@"," withString:@"."];
        }
        if (entryEntryRateAmount!=nil && entryEntryRateQuantity!=nil &&
            ![entryEntryRateAmount isKindOfClass:[NSNull class]]&& ![entryEntryRateQuantity isKindOfClass:[NSNull class]] &&
            ![entryEntryRateQuantity isEqualToString:@""]&&![entryEntryRateQuantity isEqualToString:NULL_STRING])
        {
            flatAmountEntryDict=nil;
            [variableRateEntryDict setObject:entryEntryRateQuantity forKey:@"quantity"];
            
            NSString *rateOverRideAmount=entryObj.expenseEntryRateAmount;
            
            if ([rateOverRideAmount isEqualToString:@""] || [entryEntryRateQuantity isEqualToString:NULL_STRING])
            {
                rateOverRideAmount=@"0.00";
            }
            if ([[Util detectDecimalMark] isEqualToString:@","]  && rateOverRideAmount!=nil && ![rateOverRideAmount isKindOfClass:[NSNull class]])
            {
                rateOverRideAmount=[rateOverRideAmount stringByReplacingOccurrencesOfString:@"," withString:@"."];
            }
            NSMutableDictionary *currencyDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               entryObj.expenseEntryRateCurrencyUri,@"uri",
                                               [NSNull null],@"name",
                                               [NSNull null],@"symbol",
                                               nil];
            NSDictionary *rateOverRideDict=[NSDictionary dictionaryWithObjectsAndKeys:rateOverRideAmount,@"amount",currencyDict,@"currency", nil];
            [variableRateEntryDict setObject:rateOverRideDict forKey:@"rateOverride"];
            
        }
        else
        {
            variableRateEntryDict=nil;
            NSString *amount=entryObj.expenseEntryIncurredAmountNet;
            if ([[Util detectDecimalMark] isEqualToString:@","] && amount!=nil && ![amount isKindOfClass:[NSNull class]])
            {
                amount=[amount stringByReplacingOccurrencesOfString:@"," withString:@"."];
            }

            NSString *currencyUri=entryObj.expenseEntryIncurredAmountNetCurrencyUri;
            NSMutableDictionary *flatCurrencyDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 currencyUri,@"uri",
                                                 [NSNull null],@"name",
                                                 [NSNull null],@"symbol",
                                                 nil];
            NSMutableDictionary *flatAmountDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             amount,@"amount",
                                             flatCurrencyDict,@"currency",
                                             nil];
            [flatAmountEntryDict setObject:flatAmountDict forKey:@"incurredAmountNet"];
            [flatAmountEntryDict setObject:[NSNull null] forKey:@"incurredAmountGross"];
        }
        
        NSMutableDictionary *entryTargetDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [NSNull null],@"uri",
                                                [NSNull null],@"parameterCorrelationId",
                                                nil];
        
        if (expenseEntryUri!=nil && ![expenseEntryUri isKindOfClass:[NSNull class]])
        {
            [entryTargetDict setObject:expenseEntryUri forKey:@"uri"];
        }
        
       
        
        
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
        [dataDict setObject:entryTargetDict  forKey:@"target"];
        [dataDict setObject:expenseDateDict  forKey:@"incurredDate"];
        if (description==nil||[description isKindOfClass:[NSNull class]]||[description isEqualToString:NULL_STRING])
        {
            [dataDict setObject:[NSNull null]   forKey:@"description"];
        }
        else
        {
            [dataDict setObject:description   forKey:@"description"];
        }
        if (isProjectAllowed)
        {
            if (expenseBillingOptionUri==nil)
            {
                [dataDict setObject:[NSNull null]   forKey:@"expenseBillingOptionUri"];
            }
            else
            {
                [dataDict setObject:expenseBillingOptionUri   forKey:@"expenseBillingOptionUri"];
            }
        }
        else
        {
            [dataDict setObject:[NSNull null]   forKey:@"expenseBillingOptionUri"];
        }
        if (expenseReimbursementOptionUri==nil)
        {
            [dataDict setObject:[NSNull null]   forKey:@"expenseReimbursementOptionUri"];
        }
        else
        {
            [dataDict setObject:expenseReimbursementOptionUri   forKey:@"expenseReimbursementOptionUri"];
        }
        
        if (isProjectAllowed)
        {
            if (projectUri==nil||[projectUri isKindOfClass:[NSNull class]] || [projectUri isEqualToString:NULL_STRING])
            {
                [dataDict setObject:[NSNull null]   forKey:@"project"];
            }
            else
            {
                NSMutableDictionary *projectDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                          projectUri,@"uri",
                                                          projectName,@"name",
                                                          nil];
                [dataDict setObject:projectDict   forKey:@"project"];
            }
        }
        else
        {
            [dataDict setObject:[NSNull null]   forKey:@"project"];
        }
        
        
        if (taskUri==nil || [taskUri isKindOfClass:[NSNull class]] || [taskUri isEqualToString:NULL_STRING])
        {
            [dataDict setObject:[NSNull null]   forKey:@"task"];
        }
        else
        {
            NSMutableDictionary *taskDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                taskUri,@"uri",
                                                taskName,@"name",
                                                nil];
            [dataDict setObject:taskDict   forKey:@"task"];
        }
        
        NSMutableDictionary *expenseCodeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         expenseCodeUri,@"uri",
                                         [NSNull null],@"name",
                                         nil];

        [dataDict setObject:expenseCodeDict  forKey:@"expenseCode"];
        
        if (variableRateEntryDict==nil)
        {
            [dataDict setObject:[NSNull null]  forKey:@"variableRateEntry"];
        }
        else
        {
            [dataDict setObject:variableRateEntryDict forKey:@"variableRateEntry"];
        }
        
        if (flatAmountEntryDict==nil)
        {
            [dataDict setObject:[NSNull null] forKey:@"flatAmountEntry"];
        }
        else
        {
            [dataDict setObject:flatAmountEntryDict forKey:@"flatAmountEntry"];
        }
        
        if ([queryTaxArray count]!=0)
        {
            [dataDict setObject:queryTaxArray forKey:@"taxAmounts"];
        }
        else
        {
            [dataDict setObject:queryTaxArray forKey:@"taxAmounts"];
        }

        if (paymentMethodUri==nil||[paymentMethodUri isKindOfClass:[NSNull class]]||[paymentMethodUri isEqualToString:@""])
        {
            [dataDict setObject:[NSNull null]   forKey:@"paymentMethod"];
        }
        else
        {
            NSMutableDictionary *paymentMethodDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    paymentMethodUri,@"uri",
                                                    [NSNull null],@"name",
                                                    nil];
            [dataDict setObject:paymentMethodDict   forKey:@"paymentMethod"];
        }
        
                
        
        NSMutableDictionary *receiptDict=[NSMutableDictionary dictionary];
        if (expenseReceiptUri!=nil && ![expenseReceiptUri isKindOfClass:[NSNull class]] && expenseReceiptName!=nil && ![expenseReceiptName isKindOfClass:[NSNull class]] )
        {
            NSMutableDictionary *receiptTargetDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      expenseReceiptUri,@"uri",
                                                      [NSNull null],@"parameterCorrelationId",
                                                      nil];
//            NSMutableDictionary *receiptImageDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                                     [NSNull null],@"base64ImageData",
//                                                     [NSNull null],@"mimeType",
//                                                     nil];
            [receiptDict setObject:receiptTargetDict forKey:@"target"];
//            [receiptDict setObject:receiptImageDict forKey:@"image"];
            
 
        }
        else
        {
            NSMutableDictionary *receiptTargetDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNull null],@"uri",
                                                      [NSNull null],@"parameterCorrelationId",
                                                      nil];
            if (expenseImageData!=nil)
            {
                NSMutableDictionary *receiptImageDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         expenseImageData,@"base64ImageData",
                                                         @"image/jpeg",@"mimeType",
                                                         nil];
                [receiptDict setObject:receiptImageDict forKey:@"image"];
            }
            else
            {
                NSMutableDictionary *receiptImageDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         [NSNull null],@"base64ImageData",
                                                         [NSNull null],@"mimeType",
                                                         nil];
                [receiptDict setObject:receiptImageDict forKey:@"image"];
            }
            [receiptDict setObject:receiptTargetDict forKey:@"target"];
            

            
        }
        if ((expenseReceiptUri!=nil && ![expenseReceiptUri isKindOfClass:[NSNull class]] ) || expenseImageData!=nil)
        {
            [dataDict setObject:receiptDict forKey:@"expenseReceipt"];
        }
        else
        {
            [dataDict setObject:[NSNull null] forKey:@"expenseReceipt"];
        }
        
        NSMutableArray *customFieldValuesArray=[NSMutableArray array];
        for (int b=0; b<[udfArray count]; b++)
        {
            NSMutableDictionary *udfDataDict=[NSMutableDictionary dictionary];
            NSDictionary *udfDict=[udfArray objectAtIndex:b];
            NSString *udfType=[udfDict objectForKey:@"udfType"];
            NSString *udfUri=[udfDict objectForKey:@"udfUri"];
            NSString *udfValue=[udfDict objectForKey:@"udfValue"];
            if ([udfType isEqualToString:UDFType_DATE])
            {
                if ([udfValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]||
                    [udfValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]||
                    [udfValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]||
                    [udfValue isEqualToString:@""])
                {
                    [udfDataDict setObject:[NSNull null] forKey:@"date"];
                }
                else
                {
                    NSString *defaultValue=[NSString stringWithFormat:@"%@",udfValue];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    
                    NSLocale *locale=[NSLocale currentLocale];
                    [dateFormatter setLocale:locale];
                    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [dateFormatter setDateFormat:@"MMMM dd,yyyy"];
                    NSDate *dropdownDateValue	=[dateFormatter dateFromString:defaultValue];
                    if (dropdownDateValue==nil) {
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        dropdownDateValue	=[dateFormatter dateFromString:defaultValue];
                    }
                    
                    NSDictionary *dateDict=[Util convertDateToApiDateDictionary:dropdownDateValue];
                    [udfDataDict setObject:dateDict      forKey:@"date"];
                }
                
                [udfDataDict setObject:[NSNull null] forKey:@"text"];
                [udfDataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                [udfDataDict setObject:[NSNull null] forKey:@"number"];
            }
            else if ([udfType isEqualToString:UDFType_DROPDOWN])
            {
                //Implemetation For MOBI-300//JUHI
                if (udfValue!=nil && ![udfValue isKindOfClass:[NSNull class]])
                {
                    if ([udfValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]||
                        [udfValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]||
                        [udfValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]||
                        [udfValue isEqualToString:@""])
                    {
                        [udfDataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                    }
                    else
                    {
                        NSMutableDictionary *dropDownOptionDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                 udfValue,@"uri",
                                                                 [NSNull null],@"name",
                                                                 nil];
                        [udfDataDict setObject:dropDownOptionDict  forKey:@"dropDownOption"];
                    }

                }
               
                else
                {
                    NSMutableDictionary *dropDownOptionDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                             udfValue,@"uri",
                                                             [NSNull null],@"name",
                                                             nil];
                    [udfDataDict setObject:dropDownOptionDict  forKey:@"dropDownOption"];
                }

                [udfDataDict setObject:[NSNull null] forKey:@"text"];
                [udfDataDict setObject:[NSNull null] forKey:@"date"];
                [udfDataDict setObject:[NSNull null] forKey:@"number"];
            }
            else if ([udfType isEqualToString:UDFType_NUMERIC])
            {
                if ([udfValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]||
                    [udfValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]||
                    [udfValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]||
                    [udfValue isEqualToString:@""])
                {
                    [udfDataDict setObject:[NSNull null] forKey:@"number"];
                }
                else
                {
                    [udfDataDict setObject:[NSNumber numberWithDouble:[udfValue newDoubleValue]] forKey:@"number"];
                }

                [udfDataDict setObject:[NSNull null] forKey:@"text"];
                [udfDataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                [udfDataDict setObject:[NSNull null] forKey:@"date"];
                
            }
            else if ([udfType isEqualToString:UDFType_TEXT])
            {
                if ([udfValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]||
                    [udfValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]||
                    [udfValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]||
                    [udfValue isEqualToString:@""])
                {
                    [udfDataDict setObject:[NSNull null] forKey:@"text"];
                }
                else
                {
                    [udfDataDict setObject:udfValue forKey:@"text"];
                }
                
                [udfDataDict setObject:[NSNull null] forKey:@"dropDownOption"];
                [udfDataDict setObject:[NSNull null] forKey:@"date"];
                [udfDataDict setObject:[NSNull null] forKey:@"number"];
            }
            
            NSMutableDictionary *customFieldDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  udfUri,@"uri",
                                                  [NSNull null],@"name",
                                                  [NSNull null],@"groupUri",
                                                  nil];
            [udfDataDict setObject:customFieldDict        forKey:@"customField"];
            
            [customFieldValuesArray addObject:udfDataDict];

            
        }
        [dataDict setObject:customFieldValuesArray forKey:@"customFieldValues"];
        [dataDict setObject:[NSNull null] forKey:@"reimbursementAmountOverride"];
        [dataDict setObject:[NSNull null] forKey:@"exchangeRateOverride"];
        
        [entriesArray addObject:dataDict];
    }
    
    NSMutableDictionary *targetDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       expenseSheetUri,@"uri",
                                       nil];
    NSMutableDictionary *ownerDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       strUserURI,@"uri",
                                       [NSNull null],@"loginName",
                                       nil];
    
    NSMutableDictionary *reimbursementCurrencyDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    reimbursementCurrencyUri,@"uri",
                                                    [NSNull null],@"name",
                                                    [NSNull null],@"symbol",
                                                    nil];
    NSString *isDisclaimerAcceptedString=@"false";
    if (isDisclaimerAccepted)
    {
        isDisclaimerAcceptedString=@"true";
    }
    
    
    if (isExpenseSubmit)
    {
        
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         targetDict,@"target",
                                         ownerDict,@"owner",
                                         dateDict,@"date",
                                         description,@"description",
                                         reimbursementCurrencyDict,@"reimbursementCurrency",
                                         entriesArray,@"entries",
                                         isDisclaimerAcceptedString,@"noticeExplicitlyAccepted",
                                         nil];
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          dataDict,@"data",
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
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"SubmitExpensesData"]];
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"SubmitExpensesData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
    else{
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         targetDict,@"target",
                                         ownerDict,@"owner",
                                         dateDict,@"date",
                                         description,@"description",
                                         reimbursementCurrencyDict,@"reimbursementCurrency",
                                         entriesArray,@"entries",
                                         isDisclaimerAcceptedString,@"noticeExplicitlyAccepted",
                                         nil];
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          dataDict,@"data",
                                          [Util getRandomGUID],@"unitOfWorkId",
                                          nil];
        
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"SaveExpenseSheet"]];
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"SaveExpenseSheet"]];
        [self setServiceDelegate:self];
        [self executeRequest];
    }
    
    

}//Implementation of ExpenseSheetLastModified
/************************************************************************************************************
 @Function Name   : fetchExpenseSheetUpdateData
 @Purpose         : Called to get the user’s expense data ie description,incurred amount, date,approval status etc
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchExpenseSheetUpdateData:(id)_delegate
{

    self.didSuccessfullyFetchExpenses = NO;

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
                                      @"urn:replicon:expense-sheet-list-filter:expense-sheet-owner",@"filterDefinitionUri",
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
    
    NSDictionary *filterExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                        leftExpressionDict,@"leftExpression",
                                        @"urn:replicon:filter-operator:equal",@"operatorUri",
                                        rightExpressionDict,@"rightExpression",
                                        [NSNull null],@"value",
                                        [NSNull null],@"filterDefinitionUri",
                                        nil];
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getExpenseSheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        if ([columnName isEqualToString:@"Description"]||
            [columnName isEqualToString:@"Date"]||
            [columnName isEqualToString:@"Reimbursement Amount"]||[columnName isEqualToString:@"Incurred Amount"]||
            [columnName isEqualToString:@"Approval Status"]||[columnName isEqualToString:@"Expense"]||[columnName isEqualToString:@"Tracking Number"])
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        ;
        NSNumber *pageNum=[NSNumber numberWithInt:1];
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"expenseSheetDownloadCount"];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:pageNum forKey:@"NextExpenseSheetPageNo"];
        [defaults synchronize];
        
        NSMutableArray *sortArray=[NSMutableArray array];
//        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
//                                           @"urn:replicon:expense-sheet-list-column:date",@"columnUri",
//                                           @"false",@"isAscending",
//                                           nil];
//        [sortArray addObject:sortExpressionDict1];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:tracking-number",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        [sortArray addObject:sortExpressionDict2];
        
        
        
        NSMutableDictionary *lastUpdatedDateTimeDict = nil;
        id lastUpdatedDateTime;
        
        NSUserDefaults *userdefaults=[NSUserDefaults standardUserDefaults];
        NSString *lastUpdateDateStr=(NSString*)[userdefaults objectForKey:@"ExpenseSheetLastModifiedTime"];
        
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
       
        
                
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [pageSize stringValue],@"pageSize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",filterExpressionDict,@"filterExpression",
                                          lastUpdatedDateTime,@"lastUpdatedDateTime",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetExpenseSheetUpdateData"]];
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetExpenseSheetUpdateData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
    
}
#pragma mark -
#pragma mark Response Methods

/************************************************************************************************************
 @Function Name   : handleExpenseSheetsFetchData
 @Purpose         : To save user's expense sheet data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handleExpenseSheetsFetchData:(id)response
{
    [expenseModel deleteAllExpenseSheetsFromDB];
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *expenseSheetCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:expenseSheetCount forKey:@"ExpenseDownloadCount"];
        [defaults synchronize];
        [expenseModel saveExpenseSheetDataFromApiToDB:responseDict];
        
    }

    self.didSuccessfullyFetchExpenses = YES;
}
/************************************************************************************************************
 @Function Name   : handleNextRecentExpenseSheetsFetchData
 @Purpose         : To save user's next recent expense sheet data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleNextRecentExpenseSheetsFetchData:(id)response
{
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *expenseSheetCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:expenseSheetCount forKey:@"ExpenseDownloadCount"];
        [defaults synchronize];
        
        [expenseModel saveExpenseSheetDataFromApiToDB:responseDict];
    }
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NEXT_RECENT_EXPENSESHEET_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
    
}
/************************************************************************************************************
 @Function Name   : handleExpenseEntryFetchData
 @Purpose         : To save expense entry data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleExpenseEntryFetchData:(id)response
{
   
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        
        [expenseModel saveExpenseEntryDataFromApiToDB:responseDict];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSESHEET_ENTRY_RECIEVED_NOTIFICATION object:nil];
    
    
    
    
}
/************************************************************************************************************
 @Function Name   : handleExpenseCurrencyAndPaymentMethodFetchData
 @Purpose         : To save currency and payment method data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleExpenseCurrencyAndPaymentMethodFetchData:(id)response
{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSMutableArray *currencyArray=[responseDict objectForKey:@"currencies"];
    NSMutableArray *paymentMethodArray=[responseDict objectForKey:@"paymentMethods"];
    
    

        [expenseModel saveSystemCurrenciesDataToDatabase:currencyArray];
    

        [expenseModel saveSystemPaymentMethodsDataToDatabase:paymentMethodArray];
    
     [[NSNotificationCenter defaultCenter] postNotificationName:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION_AND_DONE_ACTION object:nil];
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
    
    
    NSNumber *clientsCount=[NSNumber numberWithUnsignedInteger:[clientsArray count]];
    NSNumber *projectsCount=[NSNumber numberWithUnsignedInteger:[projectsArray count]];
    
    if ([clientsArray count]!=0)
    {
        [expenseModel saveClientDetailsDataToDB:clientsArray];
    }
    
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];
   
    BOOL isProjectAllowed = NO;
    BOOL isProjectRequired = NO;
    if ([userDetailsArray count]!=0)
    {
        NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
        isProjectAllowed =[[userDict objectForKey:@"expenseEntryAgainstProjectsAllowed"] boolValue];
        isProjectRequired=[[userDict objectForKey:@"expenseEntryAgainstProjectsRequired"] boolValue];
    }
    if (isProjectAllowed==YES && isProjectRequired==NO)
    {

        NSDictionary *projectDict= [NSDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(NONE_STRING, NONE_STRING),@"displayText",[NSNull null],@"uri", nil];
        [projectsArray addObject: [NSDictionary dictionaryWithObjectsAndKeys:projectDict,@"project", nil]];
    }
    
    
    if ([projectsArray count]!=0)
    {
        [expenseModel saveProjectDetailsDataToDB:projectsArray];
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];

    [defaults setObject:clientsCount forKey:@"clientsDownloadCount"];
    [defaults setObject:projectsCount forKey:@"projectssDownloadCount"];
    [defaults setObject:totalClientCount forKey:@"totalClientCount"];
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
        [expenseModel saveClientDetailsDataToDB:clientsArray];
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
        [expenseModel saveProjectDetailsDataToDB:projectsArray];
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
    NSNumber *projectsCount=[NSNumber numberWithUnsignedInteger:[projectsArray count]];
    
   //This code not required since none project is not present for selected client
    
//    LoginModel *loginModel=[[LoginModel alloc]init];
//    NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];

//    BOOL isProjectAllowed = NO;
//    BOOL isProjectRequired = NO;
//    if ([userDetailsArray count]!=0)
//    {
//        NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
//        isProjectAllowed =[[userDict objectForKey:@"expenseEntryAgainstProjectsAllowed"] boolValue];
//        isProjectRequired=[[userDict objectForKey:@"expenseEntryAgainstProjectsRequired"] boolValue];
//    }
//    if (isProjectAllowed==YES && isProjectRequired==NO)
//    {
//        
//        NSDictionary *projectDict= [NSDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(NONE_STRING, NONE_STRING),@"displayText",[NSNull null],@"uri", nil];
//        [projectsArray addObject: [NSDictionary dictionaryWithObjectsAndKeys:projectDict,@"project", nil]];
//    }
    
    if ([projectsArray count]!=0)
    {
        [expenseModel saveProjectDetailsDataToDB:projectsArray];
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    [defaults setObject:projectsCount forKey:@"projectssDownloadCount"];
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
        [expenseModel saveProjectDetailsDataToDB:projectsArray];
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
 @Function Name   : handleExpenseCodesFetchData
 @Purpose         : To save currency and payment method data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleExpenseCodesFetchData:(id)response
{
    NSMutableArray *expenseCodesArray=[[[response objectForKey:@"response"]objectForKey:@"d"] objectForKey:@"expenseCodes"];
    if ([expenseCodesArray count]!=0)
    {
        [expenseModel saveExpenseCodesDataToDatabase:expenseCodesArray];
    }//Fix for MOBI-79//JUHI
    NSNumber *totalExpenseCodeCount=[NSNumber numberWithUnsignedInteger:[expenseCodesArray count]];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:totalExpenseCodeCount forKey:@"totalExpenseCodeCount"];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
}
/************************************************************************************************************
 @Function Name   : handleNextExpenseCodesFetchData
 @Purpose         : To save currency and payment method data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleNextExpenseCodesFetchData:(id)response
{
    NSMutableArray *expenseCodesArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([expenseCodesArray count]!=0)
    {
        [expenseModel saveExpenseCodesDataToDatabase:expenseCodesArray];
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithUnsignedInteger:[expenseCodesArray count]] forKey:@"totalExpenseCodeCount"];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
}


-(void)handleExpensesSubmitData:(id)response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SUBMITTED_NOTIFICATION object:nil];
}

-(void)handleExpensesUnsubmitData:(id)response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UNSUBMITTED_NOTIFICATION object:nil];
}

-(void)handleExpensesDeleteData:(id)response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSE_SHEET_DELETED_NOTIFICATION object:nil];
}
/************************************************************************************************************
 @Function Name   : handleExpenseCodesDetailsFetchData
 @Purpose         : To save expensecode deatils data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleExpenseCodesDetailsFetchData:(id)response
{
    NSMutableDictionary *expenseTaxcodesCodesResponseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if (expenseTaxcodesCodesResponseDict !=nil)
    {
        [expenseModel saveExpenseCodeDetailsResponseToDB:expenseTaxcodesCodesResponseDict];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSECODE_DETAILS_RECIEVED_NOTIFICATION object:nil];
    
}

/************************************************************************************************************
 @Function Name   : handleExpenseSheetSaveData
 @Purpose         : To save expense sheet details after save  into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleExpenseSheetSaveData:(id)response
{
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        [expenseModel saveExpenseEntryDataFromApiToDB:responseDict];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSE_SHEET_SAVE_NOTIFICATION object:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:FALSE] forKey:@"ERROR"]];
    
}//Implementation of ExpenseSheetLastModified
/************************************************************************************************************
 @Function Name   : handleExpenseSheetsUpdateFetchData
 @Purpose         : To save user's expense sheet data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handleExpenseSheetsUpdateFetchData:(id)response
{
    
//    NSUserDefaults *userdefaults=[NSUserDefaults standardUserDefaults];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
//    [dateFormatter setLocale:locale];
//    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *localDate =[NSDate date];
//    NSString *lastUpdateDateStr=[dateFormatter stringFromDate:localDate];

//    [userdefaults removeObjectForKey:@"ExpenseSheetLastModifiedTime"];
//    [userdefaults setObject:lastUpdateDateStr forKey:@"ExpenseSheetLastModifiedTime"];
//    [userdefaults synchronize];
    
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        if ([responseDict objectForKey:@"updateMode"]!=nil && ![[responseDict objectForKey:@"updateMode"] isKindOfClass:[NSNull class]])
        {
            if ([[responseDict objectForKey:@"updateMode"]isEqualToString:FULL_UPDATEMODE])
            {
                [expenseModel deleteAllExpenseSheetsFromDB];
                
                NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                
                NSNumber *pageNum=[NSNumber numberWithInt:1];
                [defaults setObject:pageNum forKey:@"NextExpenseSheetPageNo"];
                
                if ([[responseDict objectForKey:@"listData"] objectForKey:@"rows"]!=nil && ![[[responseDict objectForKey:@"listData"] objectForKey:@"rows"] isKindOfClass:[NSNull class]])
                {
                    NSMutableArray *rowsArray=[[responseDict objectForKey:@"listData"] objectForKey:@"rows"];
                    NSNumber *expenseSheetCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
                    [defaults setObject:expenseSheetCount forKey:@"ExpenseDownloadCount"];
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
                        if ([[deletedObjArray objectAtIndex:i] objectForKey:@"uri"]!=nil && ![[[deletedObjArray objectAtIndex:i] objectForKey:@"uri"] isKindOfClass:[NSNull class]])
                        {
                            NSString *expenseURI=[[deletedObjArray objectAtIndex:i] objectForKey:@"uri"];
                            [expenseModel deleteExpenseSheetFromDBForSheetUri:expenseURI];
                        }
                    }
                }
                UIViewController *allViewController = appDelegate.rootTabBarController.selectedViewController;
                
                if ([allViewController isKindOfClass:[ExpensesNavigationController class]])
                {
                    ExpensesNavigationController *expenseSheetNavController=(ExpensesNavigationController *)allViewController;
                    NSArray *expensesheetControllers = expenseSheetNavController.viewControllers;
                    for (UIViewController *viewController in expensesheetControllers)
                    {
                        if ([viewController isKindOfClass:[ListOfExpenseSheetsViewController class]])
                        {
                            ListOfExpenseSheetsViewController *expenseSheetListCtrl=(ListOfExpenseSheetsViewController *)viewController;
                            expenseSheetListCtrl.isDeltaUpdate=TRUE;
                            break;
                        }
                    }
                }

            }
        }
        
        if ([responseDict objectForKey:@"listData"]!=nil && ![[responseDict objectForKey:@"listData"] isKindOfClass:[NSNull class]])
        {
            [expenseModel saveExpenseSheetDataFromApiToDB:[responseDict objectForKey:@"listData"]];
        }
    }

    self.didSuccessfullyFetchExpenses = YES;
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
            [[NSNotificationCenter defaultCenter] postNotificationName:PULL_TO_REFRESH_EXPENSESHEET_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:NEXT_RECENT_EXPENSESHEET_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
            [[NSNotificationCenter defaultCenter] postNotificationName:NEXT_RECENT_CLIENTS_OR_PROJECTS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
            [[NSNotificationCenter defaultCenter] postNotificationName:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSE_SHEET_SAVE_NOTIFICATION object:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"ERROR"]];            
        }
        else
        {
            totalRequestsServed++;
            id _serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
            
            if ([_serviceID intValue]== GetExpenseSheetData_Service_ID_27)
            {
                [self handleExpenseSheetsFetchData:response];
                
            }
            if ([_serviceID intValue]==GetNextExpenseSheetData_Service_ID_28)
            {
                [self handleNextRecentExpenseSheetsFetchData:response];
                return;
                
            }
            else if ([_serviceID intValue]==GetExpenseEntryData_Service_ID_29 )
            {
                [self handleExpenseEntryFetchData:response];
                return;
            }
            else if ([_serviceID intValue]==GetCurrencyAndPaymentMethodData_Service_ID_30){
                [self handleExpenseCurrencyAndPaymentMethodFetchData:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
            else if ([_serviceID intValue]==GetFirstProjectsAndClientsForExpenseSheet_Service_ID_31)
            {
                [self handleClientsAndProjectsDownload:response];
               
                return;
            }
            else if ([_serviceID intValue]==GetNextClientForExpense_Service_ID_34)
            {
                [self handleNextClientsDownload:response];
                return;
            }
            else if ([_serviceID intValue]==GetNextProjectForExpense_Service_ID_35)
            {
                [self handleNextProjectsDownload:response];
                return;
            }
            else if ([_serviceID intValue]==GetExpenseCodesForExpenseSheet_Service_ID_36)
            {
                [self handleExpenseCodesFetchData:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
            else if ([_serviceID intValue]==GetProjectsBasedOnClientForExpenseSheet_Service_ID_37)
            {
                [self handleProjectsBasedOnClientsResponse:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
            else if ([_serviceID intValue]==GetNextProjectsBasedOnClientsForExpense_Service_ID_38)
            {
                [self handleNextProjectsBasedOnClientDownload:response];
                return;
            }
             else if([_serviceID intValue]== SubmitExpenseData_Service_ID_41)
            {
                [self handleExpensesSubmitData:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
            else if([_serviceID intValue]== UnsubmitExpensData_Service_ID_42)
            {
                [self handleExpensesUnsubmitData:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
            else if([_serviceID intValue]== DeleteExpenseSheet_Service_ID_44)
            {
                [self handleExpensesDeleteData:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
            else if([_serviceID intValue]== GetExpenseCodeDetails_Service_ID_45)
            {
                [self handleExpenseCodesDetailsFetchData:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
            else if ([_serviceID intValue]== SaveExpenseSheet_Service_ID_47)
            {
                [self handleExpenseSheetSaveData:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }//Implementation of ExpenseSheetLastModified
            else if ([_serviceID intValue]== GetExpenseSheetUpdateData_Service_ID_88)
            {
                [self handleExpenseSheetsUpdateFetchData:response];
                
            }
else if ([_serviceID intValue]==GetNextExpenseCodesForExpenseSheet_Service_ID_92)
            {
                [self handleNextExpenseCodesFetchData:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;
            }
        }
        
        
        if (totalRequestsServed == totalRequestsSent )
        {
            [self.spinnerDelegate hideTransparentLoadingOverlay];
            [[NSNotificationCenter defaultCenter] postNotificationName:AllExpenseSheetRequestsServed object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:PULL_TO_REFRESH_EXPENSESHEET_NOTIFICATION object:nil];
            
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
    
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AllExpenseSheetRequestsServed object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PULL_TO_REFRESH_EXPENSESHEET_NOTIFICATION object:nil];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NEXT_RECENT_EXPENSESHEET_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
    [[NSNotificationCenter defaultCenter] postNotificationName:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NEXT_RECENT_CLIENTS_OR_PROJECTS_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
    [[NSNotificationCenter defaultCenter] postNotificationName:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
    return;
}





@end
